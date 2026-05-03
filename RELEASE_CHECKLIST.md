# Release Checklist

TZ Mate is intended to ship through GitHub Releases for the initial public version. Mac App Store distribution is not required for the initial release.

## 1. Pre-release Checks

- Confirm the working tree contains only intended changes.
- Run the app locally from Xcode.
- Test the menu bar popover.
- Test contacts, favorites, phone code lookup, settings, and time converter.
- Test the widget after enabling the App Group for both targets.
- Confirm `group.com.remdee.tzmate` is enabled for the main app and widget extension.

## 2. Version Bump

- Update marketing version and build number in Xcode.
- Update `CHANGELOG.md`.
- Confirm the release notes match the shipped behavior.

## 3. Build

Track A - Development / unsigned build:

- Build from Xcode or with `CODE_SIGNING_ALLOWED=NO`.
- Use this only for local development and testing.
- Do not recommend unsigned builds for public users.

```sh
xcodebuild -scheme TZMate -configuration Debug build CODE_SIGNING_ALLOWED=NO
xcodebuild -scheme TZMateWidgetExtension -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

Track B - Public GitHub Release:

- Archive the app in Xcode.
- Build a Release configuration.
- Use Developer ID signing for distribution outside the Mac App Store.
- Include the widget extension in the signed app bundle.

## 4. Signing

- Use an Apple Developer Program account.
- Sign the main app with Developer ID Application.
- Sign the widget extension with the matching team.
- Keep provisioning profiles and private certificates out of Git.
- Verify App Groups are enabled for both targets.

## 5. Notarization

- Submit the signed app or packaged archive to Apple notarization.
- Wait for notarization success.
- Staple the notarization ticket to the app or DMG.
- Validate the final artifact on a clean macOS user account if possible.

## 6. DMG Or ZIP Packaging

- Package the signed and notarized app as `.dmg` or `.zip`.
- Prefer DMG for a more polished user install flow.
- Keep generated `.dmg`, `.zip`, `.app`, and `.xcarchive` files out of Git.

## 7. GitHub Release

- Create a version tag.
- Draft a GitHub Release.
- Upload the signed and notarized `.dmg` or `.zip`.
- Include release notes and known limitations.
- Mention that Mac App Store distribution is not part of the initial release.

## 8. Post-release Checks

- Download the artifact from GitHub Releases.
- Confirm macOS does not show unexpected Gatekeeper warnings for the signed/notarized build.
- Launch the app and open the menu bar popover.
- Confirm the widget can read shared contacts after App Groups are configured.
- Watch incoming issues for signing, launch, or widget visibility problems.
