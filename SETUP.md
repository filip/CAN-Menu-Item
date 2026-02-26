# Xcode Setup Guide

## One-time project setup (~3 minutes)

### 1. Create the Xcode project

1. Open Xcode → **File › New › Project**
2. Choose **macOS › App**, click Next
3. Fill in:
   - Product Name: `CANMenuBar`
   - Bundle Identifier: `net.creativeapplications.CANMenuBar`
   - Interface: **SwiftUI**
   - Language: **Swift**
4. Save it anywhere (the Sources folder in this repo is fine)

### 2. Add the source files

1. Delete the generated `ContentView.swift` (move to Trash)
2. Drag all 6 files from `Sources/` into the Xcode project navigator:
   - `CANMenuBarApp.swift`
   - `AppState.swift`
   - `APIClient.swift`
   - `KeychainHelper.swift`
   - `MenuView.swift`
   - `SettingsView.swift`
3. When prompted, make sure **"Add to target: CANMenuBar"** is checked

### 3. Set deployment target

1. Click the project in the navigator (top blue icon)
2. Select the **CANMenuBar** target
3. Under **General › Minimum Deployments**, set macOS to **13.0** or later

### 4. Hide the Dock icon

The app should live only in the menu bar, not the Dock.

1. In the project navigator, click `Info.plist` (or open **Target › Info**)
2. Add a new row:
   - Key: `Application is agent (UIElement)`
   - Value: `YES`
   *(Or search for `LSUIElement` — it's the same thing)*

### 5. Build & Run

Press **⌘R**. The app will appear in your menu bar as a radio-wave icon.

---

## First-time use

1. Click the menu bar icon → **Settings…**
2. Enter your CAN username and App Password
   - Generate one at [creativeapplications.net](https://www.creativeapplications.net) › Edit Profile › App Password
3. Click **Save** — the app fetches your last-visit baseline and starts polling

---

## How it works

- On startup, the app fetches your `lastActivityVisit` timestamp from your member profile
- Every N minutes (your setting), it silently polls the activity feed and counts posts newer than that timestamp
- The count appears next to the icon in the menu bar
- Clicking **"X new posts on CAN"** opens `creativeapplications.net/activity/` in your browser and resets the counter (also stamps the visit on the server, syncing with the website's dot indicator)
- Polling uses `silent=1` so background checks don't clear the website's new-content indicator

---

## To launch at login

After building, you can add the app to **System Settings › General › Login Items**.
