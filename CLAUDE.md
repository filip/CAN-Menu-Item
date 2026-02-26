# CAN Menu Bar App

A native macOS menu bar app for [CreativeApplications.Net](https://www.creativeapplications.net), built with Swift and SwiftUI.

## Project Overview

Provides quick access to the CAN activity feed, notifications, and social interactions from the macOS menu bar. Targets members who want to stay connected to CAN without keeping a browser tab open.

## Tech Stack

- **Language:** Swift
- **UI:** SwiftUI
- **Target:** macOS (menu bar app, no dock icon)
- **Networking:** URLSession (native, no third-party HTTP libs)
- **Auth:** HTTP Basic Auth with App Passwords (see API docs)

## Key Files

- `CAN-API.md` — Full API documentation (endpoints, response shapes, auth, rate limits)

## Architecture Notes

- Use `MenuBarExtra` (macOS 13+) for the menu bar presence
- Store credentials securely in the macOS **Keychain** — never in UserDefaults or files
- Use `silent=1` query param when background-polling to avoid clearing the user's "last visited" indicator on the website
- On startup, fetch own member profile (`/can/v1/member/{username}`) to sync the `lastActivityVisit` baseline

## API

Base URL: `https://www.creativeapplications.net/wp-json`

Auth: HTTP Basic with username + App Password (24-char, generated at Edit Profile > App Password)

Key endpoints used by this app:
- `GET /wp/v2/activity-logs` — main feed (supports `filter`, `page`, `per_page`, `silent`)
- `GET /can/v1/mentions` — unread mentions
- `POST /can/v1/mark-mentions-read` — mark mentions read
- `GET /can/v1/member/{username}` — own profile + `lastActivityVisit`
- `POST /can/v1/toggle-like` — like/unlike
- `POST /can/v1/activity-comment` — post comment
- `GET /can/v1/activity-thread/{id}` — full thread
- `POST /can/v1/post-activity-entry` — post new entry (rate-limited: 1/2min)
- `POST /can/v1/upload-activity-image` — upload image for entry

See `CAN-API.md` for full request/response documentation.

## Security

- **Never** commit credentials or App Passwords
- Credentials go in Keychain (`Security` framework)
- No logging of auth headers or passwords

## Coding Conventions

- SwiftUI views stay thin — business logic in `@Observable` model classes or view models
- Async/await for all network calls
- No third-party dependencies unless absolutely necessary
- Minimum deployment target: macOS 13 (Ventura) for `MenuBarExtra`
