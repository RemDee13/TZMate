# Contributing

Thanks for your interest in improving TZ Mate.

## Setup

Open `TZMate.xcodeproj` in Xcode, or build from the command line:

```sh
xcodebuild -list
xcodebuild -scheme TZMate -configuration Debug build CODE_SIGNING_ALLOWED=NO
xcodebuild -scheme TZMateWidgetExtension -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

Signed builds require a Development Team and App Groups enabled for both targets:

```text
group.com.remdee.tzmate
```

## Guidelines

- Keep the UI native, compact, and menu bar friendly.
- Use IANA time zone identifiers such as `Asia/Bangkok` and `Europe/London`.
- Do not manually calculate daylight saving time.
- Avoid backend, account, payment, or cloud-sync logic.
- Keep TZ Mate focused on quick client time checks and time-zone conversion.
- Open issues and pull requests with clear context and screenshots when UI changes are involved.
