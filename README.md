# TZ Mate

TZ Mate is a simple macOS menu bar app and widget for checking client local time, converting time zones, and planning international calls.

Before you call or message an international client, check their local time in one click.

## What It Does

TZ Mate is built for people who work with international clients: real estate agents, sales managers, recruiters, consultants, freelancers, support teams, and remote workers.

The app stays small on purpose. It is not a CRM, it has no account system, and it does not need a backend.

## Features

- Native macOS menu bar app
- Compact SwiftUI popover
- Contacts with each client's local time
- Favorite contacts
- macOS WidgetKit widget
- Time zone converter
- Phone code lookup
- Country name lookup
- Expanded local country and time zone dataset
- Multiple time zones for large countries
- Practical time status labels
- Light, dark, and system theme
- 12-hour and 24-hour time format
- Launch at Login
- Sparkle-based update checking foundation
- Quit action from Settings and the status item menu
- Local-first storage
- Works offline

## Screenshots

Screenshots will be added in `docs/screenshots/` before the first public binary release.

- Contacts - `docs/screenshots/01-contacts.png` coming soon
- Lookup - `docs/screenshots/02-add-contact-phone-lookup.png` coming soon
- Converter - `docs/screenshots/03-converter.png` coming soon
- Settings - `docs/screenshots/04-settings.png` coming soon
- Widget - `docs/screenshots/05-widget.png` coming soon

## Installation

TZ Mate is currently available as a source-only alpha/developer preview.

### Build From Source

1. Clone the repository.
2. Open `TZMate.xcodeproj` in Xcode.
3. Select your Development Team for both targets:
   - `TZMate`
   - `TZMateWidgetExtension`
4. Enable App Groups for both targets:

```text
group.com.remdee.tzmate
```

5. Build and run the `TZMate` scheme.

### GitHub Releases

The first GitHub Release is intended to be source-only for alpha testing. A public `.dmg` download is planned later. The intended binary release artifact is a signed and notarized `.dmg`.

Unsigned local builds may trigger macOS Gatekeeper warnings. Public binary releases outside the Mac App Store should be signed with a Developer ID certificate and notarized by Apple.

Update checking is planned through Sparkle and GitHub-hosted appcasts. The app currently points to:

```text
https://remdee13.github.io/TZMate/appcast.xml
```

This URL must be confirmed before the first public binary release.

### Homebrew

A Homebrew cask is planned later. It is not available yet.

## Distribution

Initial distribution is through GitHub, not the Mac App Store. The Mac App Store is not planned for the first public version.

## Usage

- Open TZ Mate from the macOS menu bar.
- Add contacts to see client local time, status, and time difference.
- Use Lookup to search by phone code or country name.
- Use Convert to plan a call across time zones.
- Add the macOS widget to see favorite contacts at a glance.
- Use Settings to check for updates or enable automatic update checks once releases are configured.
- Enable Launch at Login in Settings if you want TZ Mate to start automatically.
- Quit the app from Settings or by right-clicking the menu bar item and choosing `Quit TZ Mate`.

## Development

Requirements:

- macOS 13 Ventura or newer
- Xcode with macOS development tools installed

List schemes:

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

Sparkle is included through Swift Package Manager. If Xcode needs to resolve packages manually:

```sh
xcodebuild -resolvePackageDependencies -project TZMate.xcodeproj
```

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
│   ├── Assets.xcassets/
│   ├── Info.plist
│   └── TZMate.entitlements
├── TZMateWidgetExtension/
├── docs/
│   ├── releases/
│   └── screenshots/
├── scripts/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── PRIVACY.md
├── CHANGELOG.md
├── QA_CHECKLIST.md
└── RELEASE_CHECKLIST.md
```

## App Groups And Signing

TZ Mate uses this App Group identifier:



Both the main app and widget extension need the same App Group enabled so they can share local contacts and settings.

## Updates

TZ Mate uses Sparkle 2 for the update-checking foundation needed by GitHub Releases distribution.

Production updates require:

- A Developer ID signed and notarized app
- The Sparkle EdDSA public key in `TZMate/Info.plist`
- A signed release archive
- An HTTPS `appcast.xml`
- A confirmed final appcast URL

Until the final appcast and signed release archives are published, the update UI is present for prerelease testing but production updates are not active.

## Widget Troubleshooting

If the widget does not appear in macOS:

- Build and run the main app.
- Open Notification Center, choose Edit Widgets, and search for `TZ Mate`.
- Clean the build folder and rebuild if the widget is still missing.
- Make sure both `TZMate` and `TZMateWidgetExtension` use the same Development Team.
- Make sure both targets have App Groups enabled with.

## Privacy

- No account required
- No backend
- No analytics
- No tracking
- Contacts and settings are stored locally on the user's Mac
- The widget reads local App Group storage only
- Optional update checks use Sparkle and the configured HTTPS appcast URL

## Roadmap

- Signed and notarized GitHub Release
- DMG installer
- Better screenshot set
- Meeting time suggestions
- Contact import/export
- Homebrew cask
- Optional iCloud sync later

## Author

Anton Pavlov  
GitHub: https://github.com/RemDee13

## Contributing

Issues and pull requests are welcome. Please keep the app native, compact, local-first, and focused on quick time-zone decisions.

## License

MIT License. See [LICENSE](LICENSE).
