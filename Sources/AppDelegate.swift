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
            button.image = Self.makeMenuBarIcon()
            button.imagePosition = .imageLeft
            log += "image set OK\n"
            _ = log  // suppress unused warning after this block
        } else {
            log += "button is nil!\n"
        }

        try? log.write(toFile: "/tmp/canmenubar.log", atomically: true, encoding: .utf8)

        buildMenu()
        observeAppState()
        updateMenuState()
    }

    // MARK: - Menu Bar Icon

    /// Draws the CAN logo (triangle/W shape) as a template image for the menu bar.
    /// SVG source viewBox: 442.7 x 221.5. Rendered at 36x18pt (2:1 ratio).
    private static func makeMenuBarIcon() -> NSImage {
        let w: CGFloat = 27
        let h: CGFloat = 13.5
        let img = NSImage(size: NSSize(width: w, height: h))
        img.lockFocus()

        // Scale from SVG coords (442.7 x 221.5) to output size
        let sx = w / 442.7
        let sy = h / 221.5

        // Helper: convert SVG point (Y flipped for Cocoa coords)
        func pt(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
            NSPoint(x: x * sx, y: h - y * sy)
        }

        NSColor.black.setStroke()

        // Thin lines (SVG st0, stroke-width 5)
        let thin = NSBezierPath()
        thin.lineWidth = 0.5
        thin.lineCapStyle = .round
        thin.lineJoinStyle = .round
        thin.move(to: pt(121.5, 15));  thin.line(to: pt(325.6, 15))
        thin.move(to: pt(121.5, 15));  thin.line(to: pt(223.6, 206.5))
        thin.move(to: pt(223.6, 206.5)); thin.line(to: pt(427.7, 206.5))
        thin.stroke()

        // Thick polyline (SVG st1, stroke-width 20)
        let thick = NSBezierPath()
        thick.lineWidth = 1.5
        thick.lineCapStyle = .round
        thick.lineJoinStyle = .round
        thick.move(to: pt(121.5, 15))
        thick.line(to: pt(15,    206.5))
        thick.line(to: pt(223.6, 206.5))
        thick.line(to: pt(325.6, 15))
        thick.line(to: pt(427.7, 206.5))
        thick.stroke()

        img.unlockFocus()
        img.isTemplate = true  // Allows macOS to invert for dark mode
        return img
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
