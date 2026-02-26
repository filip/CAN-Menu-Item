import Cocoa
import Combine
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    let appState = AppState()
    var settingsWindow: NSWindow?

    private var statusMenuItem: NSMenuItem!
    private var refreshMenuItem: NSMenuItem!
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        var log = "launched at \(Date())\n"
        NSApp.setActivationPolicy(.accessory)
        log += "activation policy: accessory\n"

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        log += "statusItem: \(String(describing: statusItem))\n"
        log += "button: \(String(describing: statusItem.button))\n"

        if let button = statusItem.button {
            if let img = NSImage(systemSymbolName: "dot.radiowaves.left.and.right",
                                 accessibilityDescription: "CAN") {
                button.image = img
                button.imagePosition = .imageLeft
                log += "image set OK\n"
            } else {
                button.title = "CAN"
                log += "image nil — using title CAN\n"
            }
        } else {
            log += "button is nil!\n"
        }

        try? log.write(toFile: "/tmp/canmenubar.log", atomically: true, encoding: .utf8)

        buildMenu()
        observeAppState()
        updateMenuState()
    }

    // MARK: - Menu

    private func buildMenu() {
        let menu = NSMenu()

        statusMenuItem = NSMenuItem(title: "Loading…", action: #selector(openActivityFeed), keyEquivalent: "")
        statusMenuItem.target = self
        menu.addItem(statusMenuItem)

        menu.addItem(.separator())

        refreshMenuItem = NSMenuItem(title: "Refresh Now", action: #selector(manualRefresh), keyEquivalent: "r")
        refreshMenuItem.target = self
        menu.addItem(refreshMenuItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    private func observeAppState() {
        appState.$newPostCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateMenuState() }
            .store(in: &cancellables)

        appState.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateMenuState() }
            .store(in: &cancellables)

        appState.$lastError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateMenuState() }
            .store(in: &cancellables)
    }

    private func updateMenuState() {
        let count   = appState.newPostCount
        let loading = appState.isLoading
        let ready   = appState.hasCredentials

        // Status menu item label
        if !ready {
            statusMenuItem.title     = "Not configured — open Settings"
            statusMenuItem.isEnabled = false
        } else if count > 0 {
            statusMenuItem.title     = "\(count) new \(count == 1 ? "post" : "posts") on CAN"
            statusMenuItem.isEnabled = true
        } else {
            statusMenuItem.title     = "No new posts"
            statusMenuItem.isEnabled = true
        }

        // Badge count — always keep at least the image visible
        if let button = statusItem.button {
            if button.image != nil {
                // Image is showing: append count as text alongside it
                button.title = count > 0 ? " \(count)" : ""
            } else {
                // Text-only fallback: show count or "CAN"
                button.title = count > 0 ? "CAN \(count)" : "CAN"
            }
        }

        // Refresh item
        refreshMenuItem.title     = loading ? "Refreshing…" : "Refresh Now"
        refreshMenuItem.isEnabled = ready && !loading
    }

    // MARK: - Actions

    @objc private func openActivityFeed() {
        appState.openActivityFeedAndReset()
    }

    @objc private func manualRefresh() {
        Task { await appState.poll() }
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let hosting = NSHostingController(
                rootView: SettingsView().environmentObject(appState)
            )
            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 440, height: 280),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            win.title = "CAN Settings"
            win.contentViewController = hosting
            win.isReleasedWhenClosed = false
            win.center()
            settingsWindow = win
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
