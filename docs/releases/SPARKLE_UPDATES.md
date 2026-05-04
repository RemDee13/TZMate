# Sparkle Updates

TZ Mate uses Sparkle 2 to support update checking for releases distributed outside the Mac App Store.

Sparkle should be used only for public GitHub Releases that are signed, notarized, and published with a valid HTTPS appcast.

## Current Configuration

- Package: `https://github.com/sparkle-project/Sparkle`
- Appcast URL: `https://remdee13.github.io/TZMate/appcast.xml`
- Key account used for generation: `com.remdee.tzmate`
- Public key location: `TZMate/Info.plist` as `SUPublicEDKey`

Confirm the appcast URL before the first public binary release.

## Required Release Flow

1. Build a Release archive of `TZMate`.
2. Sign the app with Developer ID Application.
3. Notarize the app or final DMG with Apple.
4. Package the signed and notarized app as a `.dmg` or `.zip`.
5. Sign the release archive with Sparkle tools.
6. Generate or update `appcast.xml`.
7. Publish the appcast over HTTPS.
8. Upload the release artifact to GitHub Releases.
9. Test `Check for Updates…` from the installed app.

## Key Generation

Sparkle EdDSA keys can be generated with Sparkle's `generate_keys` tool:

```sh
generate_keys --account com.remdee.tzmate
```

The tool stores the private key in the macOS Keychain and prints the public key for `SUPublicEDKey`.

Private signing keys must never be committed to Git. Do not export or store private keys in the repository.

## Signing Release Archives

Sparkle release archives should be signed with Sparkle's `sign_update` tool:

```sh
sign_update path/to/TZMate.zip --account com.remdee.tzmate
```

Use the output signature in `appcast.xml`.

## Appcast Hosting

The appcast must be served over HTTPS.

Recommended layout:

```text
GitHub Releases
└── TZMate-v0.1.0.dmg

GitHub Pages
└── appcast.xml
```

The app currently points to:

```text
https://remdee13.github.io/TZMate/appcast.xml
```

Update `SUFeedURL` in `TZMate/Info.plist` if the final hosted appcast URL changes.

## Production Requirements

- Developer ID signing
- Apple notarization
- Sparkle EdDSA public key in the app
- Sparkle-signed release archive
- HTTPS appcast
- No private keys, Apple credentials, or notarization credentials in Git

Mac App Store distribution is not required for the initial release.
