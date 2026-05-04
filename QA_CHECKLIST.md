# QA Checklist

Use this checklist before publishing a developer prerelease or public GitHub Release.

## 1. Environment

- [ ] macOS version recorded:
- [ ] Xcode version recorded:
- [ ] Apple Development Team selected for `TZMate`
- [ ] Apple Development Team selected for `TZMateWidgetExtension`
- [ ] App Groups enabled for both targets
- [ ] App Group is `group.com.remdee.tzmate`
- [ ] Build configuration used:
- [ ] Build command recorded:

## 2. Main App Launch

- [ ] App launches without a normal Dock window
- [ ] Menu bar item appears
- [ ] Clicking the menu bar item opens compact popover
- [ ] Buttons, text fields, pickers, and sheets are clickable inside the popover
- [ ] Right-click or Control-click on the menu bar item opens the status menu
- [ ] Status menu includes `Open TZ Mate`
- [ ] Status menu includes `Quit TZ Mate`
- [ ] Popover size is reasonable
- [ ] App name is `TZ Mate`

## 3. Settings

- [ ] Theme: System
- [ ] Theme: Light
- [ ] Theme: Dark
- [ ] 12-hour format
- [ ] 24-hour format
- [ ] Default time zone display is correct
- [ ] Enable Launch at Login
- [ ] Disable Launch at Login
- [ ] Check for Updates opens Sparkle update UI
- [ ] Automatically Check for Updates toggle changes state
- [ ] Quit TZ Mate from Settings
- [ ] Settings persist after relaunch

## 4. Contacts

- [ ] Empty state appears
- [ ] Add contact manually
- [ ] Add contact with one-time-zone country
- [ ] Add contact with multi-time-zone country
- [ ] Edit contact
- [ ] Delete contact
- [ ] Search contact
- [ ] Toggle favorite
- [ ] Copy local time
- [ ] Contacts persist after relaunch

## 5. Phone Code Lookup

- [ ] Country name search: `Japan`
- [ ] Country name search: `Germany`
- [ ] Country name search: `United States`
- [ ] Country name search: `United Arab Emirates`
- [ ] `+49` -> Germany
- [ ] `49` -> Germany
- [ ] `+49 170` -> Germany
- [ ] `+66` -> Thailand
- [ ] `+44` -> United Kingdom
- [ ] `+1` -> United States and Canada
- [ ] `+1 212` -> United States and Canada
- [ ] `+7` -> Russia and Kazakhstan
- [ ] `+61` -> Australia with multiple time zones
- [ ] Invalid code -> no match

## 6. Time Converter

- [ ] Bangkok 15:00 -> London 09:00
- [ ] Berlin 10:00 Jan 3 -> Bangkok 16:00 Jan 3
- [ ] Los Angeles 23:00 May 3 -> Bangkok 13:00 May 4
- [ ] Direction switch: My time -> Client
- [ ] Direction switch: Client -> My time
- [ ] Multi-time-zone country selection
- [ ] Copy result
- [ ] 12-hour output
- [ ] 24-hour output

## 7. Widget

- [ ] Widget appears in macOS widget gallery
- [ ] Small widget shows 1-2 contacts
- [ ] Medium widget shows 3-4 contacts
- [ ] Large widget shows 5-8 contacts
- [ ] Empty state works
- [ ] Favorites appear first
- [ ] Widget reads shared contacts
- [ ] Widget updates local time
- [ ] Widget opens app when clicked if implemented

## 8. Privacy And Offline

- [ ] App works without login
- [ ] App works offline
- [ ] No network requests expected except optional update checks
- [ ] Data stored locally

## 9. Known Issues

Record discovered issues here:

- [ ] Issue:
- [ ] Issue:
- [ ] Issue:

## 10. Release Decision

- [ ] Ready for developer prerelease: yes/no
- [ ] Ready for public user release: yes/no
- [ ] Requires signed/notarized build: yes/no
