import Foundation
import Combine
import AppKit

final class AppState: ObservableObject {
    @Published var newPostCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var lastError: String?

    private(set) var username: String = ""
    private(set) var appPassword: String = ""
    private(set) var refreshIntervalMinutes: Int = 5

    private var lastActivityVisit: TimeInterval = 0
    private var timer: Timer?
    private let api = APIClient()

    init() {
        loadSettings()
        if hasCredentials {
            Task { await self.initialize() }
        }
    }

    var hasCredentials: Bool {
        !username.isEmpty && !appPassword.isEmpty
    }

    // Called from SettingsView when user taps Save
    func applySettings(username: String, password: String, intervalMinutes: Int) {
        self.username = username
        self.appPassword = password
        self.refreshIntervalMinutes = intervalMinutes
        persistSettings()

        newPostCount = 0
        lastActivityVisit = 0
        stopTimer()

        if hasCredentials {
            Task { await self.initialize() }
        }
    }

    // Syncs lastActivityVisit baseline from server, then starts polling
    func initialize() async {
        let (u, p) = await MainActor.run { (self.username, self.appPassword) }
        if let visit = try? await api.fetchLastActivityVisit(username: u, password: p) {
            await MainActor.run { self.lastActivityVisit = visit }
        }
        await poll()
        await MainActor.run { self.startTimer() }
    }

    func poll() async {
        // Atomically check and set isLoading on main thread
        let shouldProceed = await MainActor.run { () -> Bool in
            guard !self.isLoading, self.hasCredentials else { return false }
            self.isLoading = true
            return true
        }
        guard shouldProceed else { return }

        // Capture mutable state on main thread before going async
        let (username, password, cutoff) = await MainActor.run {
            (self.username, self.appPassword, self.lastActivityVisit)
        }

        do {
            let logs = try await api.fetchActivityLogs(
                username: username, password: password, perPage: 50, silent: true
            )
            let count = logs.filter { log in
                guard let date = Self.parseWPDate(log.date) else { return false }
                return date.timeIntervalSince1970 > cutoff
            }.count
            await MainActor.run {
                self.newPostCount = count
                self.lastError = nil
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.lastError = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // Call from main thread only
    func openActivityFeedAndReset() {
        NSWorkspace.shared.open(URL(string: "https://www.creativeapplications.net/activity/")!)
        newPostCount = 0
        lastActivityVisit = Date().timeIntervalSince1970

        // Stamp visit on server (fetch without silent=1)
        let (u, p) = (username, appPassword)
        Task {
            _ = try? await api.fetchActivityLogs(username: u, password: p, perPage: 1, silent: false)
        }
    }

    // MARK: - Timer (call on main thread)

    private func startTimer() {
        stopTimer()
        guard hasCredentials else { return }
        let interval = TimeInterval(refreshIntervalMinutes * 60)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.poll() }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Date parsing

    // WP returns "yyyy-MM-dd'T'HH:mm:ss" without timezone — treat as UTC
    private static func parseWPDate(_ string: String) -> Date? {
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: string) { return date }

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.timeZone = TimeZone(abbreviation: "UTC")
        return df.date(from: string)
    }

    // MARK: - Persistence

    private func loadSettings() {
        username = UserDefaults.standard.string(forKey: "can_username") ?? ""
        let saved = UserDefaults.standard.integer(forKey: "can_refreshInterval")
        refreshIntervalMinutes = saved > 0 ? saved : 5
        if !username.isEmpty {
            appPassword = KeychainHelper.load() ?? ""
        }
    }

    private func persistSettings() {
        UserDefaults.standard.set(username, forKey: "can_username")
        UserDefaults.standard.set(refreshIntervalMinutes, forKey: "can_refreshInterval")
        KeychainHelper.save(password: appPassword)
    }
}
