# ClientTime — Codex Project Context

## 1. Project Overview

ClientTime is a native macOS menu bar application for people who work with international clients.

The app helps users quickly understand:

- What time it is now in a client’s country or city
- Whether it is a good time to call or message a client
- What time it will be for the user when it is a specific time for the client
- What country/region is associated with a phone number code
- What local time it is for saved contacts

The app should be simple, fast, and live in the macOS menu bar.

This is intended to be an open-source public GitHub project that users can download and use.

The product is not just a world clock. It is a client time assistant for salespeople, real estate agents, recruiters, consultants, freelancers, and anyone working across countries.

Core positioning:

"Before you call or message an international client, check their local time in one click."

---

## 2. App Name

Working name: ClientTime

Alternative names:
- CallTime
- Client Clock
- ZoneMate
- TimeBuddy
- WorldCall

Use `ClientTime` as the current app name unless changed later.

---

## 3. Platform

Target platform:

- macOS
- Native menu bar app
- Swift
- SwiftUI

Recommended minimum macOS version:

- macOS 13 Ventura or newer

Reason:

- Modern SwiftUI support
- MenuBarExtra support
- Better native macOS experience

---

## 4. Main Product Requirements

The app must live in the macOS menu bar.

When the user clicks the menu bar icon, a compact popover should open.

The popover should have three main tabs:

1. Contacts
2. Time Converter
3. Settings

The app should be lightweight, local-first, and work offline.

No login, no backend, no cloud sync in MVP.

---

## 5. MVP Scope

The first version should include:

- macOS menu bar icon
- Popover UI
- Three tabs: Contacts, Time Converter, Settings
- Add, edit, delete contacts
- Show current local time for each contact
- Show time difference between the user and each contact
- Show simple status: Good time, Evening, Late night, Early morning
- Search country/region by phone code
- Handle countries with multiple time zones
- Time converter between user time zone and client time zone
- Local app settings
- Theme setting: system, light, dark
- 12-hour / 24-hour format
- Local JSON dataset for countries, phone codes, cities, and time zones
- Local data storage

Do not build account system, paid features, cloud sync, calendar integration, or iPhone version in the MVP.

---

## 6. UI Structure

The menu bar popover should be compact and clean.

Recommended size:

- Width: 380–440 px
- Height: 520–640 px

The app should not feel like a full CRM. It should feel like a quick utility.

Main layout:

```text
ClientTime Popover
├── Header
│   ├── App name or current local time
│   └── Optional small settings icon
│
├── Tab Picker
│   ├── Contacts
│   ├── Converter
│   └── Settings
│
└── Active Tab Content

## Widget Support

The app should support macOS widgets in addition to the menu bar app.

The widget name should be TZ Mate.

Widgets should show selected contacts with their current local time, country/city, and time status.

Widget sizes:

- Small: 1–2 favorite contacts
- Medium: 3–4 favorite contacts
- Large: 5–8 favorite contacts with more details

The widget should be read-only in MVP.

The user edits contacts and settings in the main menu bar app.

Clicking the widget should open the main app.

The widget and the main app must share contact and settings data.

Use App Groups for shared storage between the main app and widget extension.

Suggested App Group identifier:

group.com.yourname.tzmate

For MVP, use shared UserDefaults or a shared JSON file inside the App Group container.

The widget should support system, light, and dark appearance automatically.

Widget should update timeline periodically to keep displayed local times reasonably fresh.