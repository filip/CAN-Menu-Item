# CAN Menu Bar

A minimal macOS menu bar app for [CreativeApplications.Net](https://www.creativeapplications.net) members. It silently polls the CAN activity feed in the background and shows a count of new posts since your last visit — right in your menu bar.

Click the icon to open the activity feed in your browser. The counter resets and your "last visited" timestamp syncs with the website automatically.

---

## Features

- Live new-post count in the menu bar, refreshed automatically
- Configurable refresh interval (1 – 60 minutes)
- Clicking the count opens `creativeapplications.net/activity/` and resets the counter
- Silent background polling — does not interfere with the website's own new-content indicator
- Credentials stored securely in macOS Keychain (never on disk)
- No Dock icon — lives entirely in the menu bar

---

## Requirements

- macOS 12 Monterey or later
- Xcode 14 or later (to build)
- A [CreativeApplications.Net](https://www.creativeapplications.net) member account

---

## Build & Install

**1. Clone the repo**

```bash
git clone https://github.com/your-username/CAN-Menu-Item.git
cd CAN-Menu-Item
```

**2. Open in Xcode**

```bash
open CANMenuBar.xcodeproj
```

**3. Set your signing team**

In Xcode, select the `CANMenuBar` target → **Signing & Capabilities** → set your Team.

**4. Build & Run**

Press **⌘R** in Xcode, or from the command line:

```bash
xcodebuild -project CANMenuBar.xcodeproj -target CANMenuBar -configuration Debug \
  CONFIGURATION_BUILD_DIR="$(pwd)/build" build

open build/CANMenuBar.app
```

---

## First-time Setup

1. Click the menu bar icon → **Settings…**
2. Enter your CAN **username** and an **App Password**
   - Generate one at [creativeapplications.net](https://www.creativeapplications.net) → Edit Profile → App Password
3. Choose how often to refresh
4. Click **Save** — the app fetches your last-visit baseline from the server and starts counting

---

## How It Works

Every N minutes the app calls the CAN member profile API (`/can/v1/member/{username}`) and reads `newActivityCount` directly — the same value shown on the website dot and iOS app. No local date comparison, no feed polling. When you click through to the feed, it fetches once without `silent=1` to stamp `last_activity_visit` on the server, keeping all clients in sync.

Credentials are authenticated via [CAN App Passwords](https://www.creativeapplications.net) (HTTP Basic Auth). Your App Password is stored in the macOS Keychain and never written to disk.

---

## Launch at Login

After building, add the app to **System Settings → General → Login Items**.

---

## API

This app uses the [CAN Member API](CAN-API.md). See `CAN-API.md` for full documentation.

---

## Version History

### v1.1 (build 2) — 2026-04-16
- New-post count now reads `newActivityCount` directly from the member profile API — same source of truth as the website dot and iOS app. Eliminates local date comparison and feed polling for count.
- Fixed: count was always 0 due to server `last_activity_visit` timestamp being stored in local time instead of UTC (`current_time('timestamp')` → `time()` on server).
- Added app icon — light grey background with menu-app glyph.
- User agent updated to `Activity OSX Menu Item/{version} ({build})`.

### v1.0 (build 1) — initial release
- Menu bar new-post counter with configurable refresh interval.
- Silent background polling via `?silent=1`.
- Credentials stored in macOS Keychain.
- Click to open activity feed and reset counter.
