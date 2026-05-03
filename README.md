# TZ Mate

TZ Mate is a simple macOS menu bar app and widget for checking client local time, converting time zones, and planning international calls.

Before you call or message an international client, check their local time in one click.

## Why TZ Mate Exists

If you work with international clients, it is easy to call or message at the wrong time. TZ Mate helps real estate agents, sales managers, recruiters, consultants, freelancers, support teams, and remote workers quickly check whether it is a good time to reach someone.

The app is intentionally small: no CRM, no login, no backend, and no cloud dependency.

## Features

- Native macOS menu bar app
- Compact SwiftUI popover
- Contact list with each client's local time
- Favorite contacts
- macOS WidgetKit widget
- Time zone converter
- Phone code country lookup
- Multiple time zones for large countries
- Practical time status labels
- Light, dark, and system theme
- 12-hour and 24-hour time format
- Local-first storage
- Works offline

## Screenshots

Screenshots will be added as the app UI stabilizes.

- Menu bar popover
- Contacts tab
- Time converter
- Widget

## Installation

TZ Mate is currently in development.

For now, build the app from source using Xcode. GitHub Releases and a DMG installer will be added later.

## Development

Requirements:

- macOS 13 Ventura or newer
- Xcode with macOS development tools installed

List available schemes:

```sh
xcodebuild -list
```

Build the main app without signing:

```sh
xcodebuild -scheme TZMate -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

Build the widget extension without signing:

```sh
xcodebuild -scheme TZMateWidgetExtension -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

Signed builds require selecting a Development Team in Xcode and enabling App Groups for both the main app target and widget extension target.

## Project Structure

```text
TZMate/
├── TZMate.xcodeproj
├── TZMate/
│   ├── App/
│   ├── Data/
│   ├── Models/
│   ├── Services/
│   ├── Utilities/
│   ├── Views/
│   ├── Info.plist
│   └── TZMate.entitlements
├── TZMateWidgetExtension/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── PRIVACY.md
└── CHANGELOG.md
```

## App Groups And Signing

TZ Mate uses this App Group identifier:

```text
group.com.remdee.tzmate
```

Both the main app and the widget extension need the same App Group enabled so they can share local contacts and settings.

For local unsigned builds, use `CODE_SIGNING_ALLOWED=NO`. For normal Xcode builds, configure Signing & Capabilities for both targets.

## Privacy

- No account required
- No backend
- No analytics
- No tracking
- Contacts and settings are stored locally on the user's Mac
- The widget reads local shared storage only

## Roadmap

- Signed and notarized release
- DMG installer
- Better country and time zone database
- Meeting time suggestions
- Contact import/export
- Homebrew cask
- iCloud sync maybe later

## Contributing

Issues and pull requests are welcome. Please keep the app native, compact, local-first, and focused on quick time-zone decisions.

## License

MIT License. See [LICENSE](LICENSE).
