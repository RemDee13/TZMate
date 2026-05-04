//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import WidgetKit

struct TZMateWidgetEntry: TimelineEntry {
    let date: Date
    let contacts: [Contact]
    let settings: AppSettings
}

struct TZMateWidgetProvider: TimelineProvider {
    private let contactStorageService = ContactStorageService(allowsStandardFallback: false)
    private let settingsStorageService = SettingsStorageService(allowsStandardFallback: false)

    func placeholder(in context: Context) -> TZMateWidgetEntry {
        TZMateWidgetEntry(
            date: Date(),
            contacts: [Contact.sample],
            settings: AppSettings.default
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TZMateWidgetEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TZMateWidgetEntry>) -> Void) {
        let entry = makeEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 5, to: entry.date) ?? entry.date.addingTimeInterval(300)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func makeEntry() -> TZMateWidgetEntry {
        let settings = settingsStorageService.loadSettings()
        let contacts = contactStorageService.loadContacts()
        let favoriteContacts = contacts.filter(\.isFavorite)
        let displayContacts = favoriteContacts.isEmpty ? contacts : favoriteContacts

        logDebugSnapshot(
            sharedDefaultsAvailable: contactStorageService.isSharedStorageAvailable,
            contactCount: contacts.count,
            favoriteCount: favoriteContacts.count
        )

        return TZMateWidgetEntry(
            date: Date(),
            contacts: Array(displayContacts.prefix(8)),
            settings: settings
        )
    }

    private func logDebugSnapshot(sharedDefaultsAvailable: Bool, contactCount: Int, favoriteCount: Int) {
        #if DEBUG
        WidgetDebugDiagnostics.log(
            sharedDefaultsAvailable: sharedDefaultsAvailable,
            contactCount: contactCount,
            favoriteCount: favoriteCount
        )
        #endif
    }
}

#if DEBUG
private enum WidgetDebugDiagnostics {
    private static var didLog = false

    static func log(sharedDefaultsAvailable: Bool, contactCount: Int, favoriteCount: Int) {
        guard !didLog else {
            return
        }

        didLog = true
        print(
            "TZ Mate widget storage: sharedDefaultsAvailable=\(sharedDefaultsAvailable), contacts=\(contactCount), favorites=\(favoriteCount)"
        )
    }
}
#endif
