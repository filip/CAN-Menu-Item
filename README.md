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

On startup the app fetches your `lastActivityVisit` timestamp from the CAN member API. Every N minutes it silently polls the activity feed (`?silent=1`) and counts entries newer than that timestamp. When you click through to the feed, it fetches once without `silent=1` to update the server-side timestamp, keeping the website's own new-content indicator in sync.

Credentials are authenticated via [CAN App Passwords](https://www.creativeapplications.net) (HTTP Basic Auth). Your App Password is stored in the macOS Keychain and never written to disk.

---

## Launch at Login

After building, add the app to **System Settings → General → Login Items**.

---

## API

This app uses the [CAN Member API](https://www.creativeapplications.net/api/). See link for full documentation.
