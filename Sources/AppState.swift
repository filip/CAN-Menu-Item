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
        stopTimer()

        if hasCredentials {
            Task { await self.initialize() }
        }
    }

    // Syncs count from server, then starts polling
    func initialize() async {
        await poll()
        await MainActor.run { self.startTimer() }
    }

    func poll() async {
        let shouldProceed = await MainActor.run { () -> Bool in
            guard !self.isLoading, self.hasCredentials else { return false }
            self.isLoading = true
            return true
        }
        guard shouldProceed else { return }

        let (username, password) = await MainActor.run { (self.username, self.appPassword) }

        do {
            let profile = try await api.fetchMemberProfile(username: username, password: password)
            await MainActor.run {
                self.newPostCount = profile.newActivityCount ?? 0
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
