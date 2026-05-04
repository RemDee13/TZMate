//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

struct WidgetDiagnostics: Equatable {
    let sharedDefaultsAvailable: Bool
    let appGroupContainerAvailable: Bool
    let sharedContactsRawDataExists: Bool
    let sharedContactsCount: Int
    let sharedFavoritesCount: Int
    let standardContactsRawDataExists: Bool
    let standardContactsCount: Int
    let migrationNeeded: Bool
    let appGroupIdentifier: String
    let contactsStorageKey: String

    static let empty = WidgetDiagnostics(
        sharedDefaultsAvailable: false,
        appGroupContainerAvailable: false,
        sharedContactsRawDataExists: false,
        sharedContactsCount: 0,
        sharedFavoritesCount: 0,
        standardContactsRawDataExists: false,
        standardContactsCount: 0,
        migrationNeeded: false,
        appGroupIdentifier: Constants.appGroupIdentifier,
        contactsStorageKey: Constants.contactsStorageKey
    )

    var reportText: String {
        [
            "TZ Mate Widget Diagnostics",
            "App Group: \(appGroupIdentifier)",
            "Storage key: \(contactsStorageKey)",
            "Shared storage: \(sharedDefaultsAvailable ? "Available" : "Not available")",
            "App Group container: \(appGroupContainerAvailable ? "Available" : "Not available")",
            "Shared raw data exists: \(sharedContactsRawDataExists ? "Yes" : "No")",
            "Shared contacts: \(sharedContactsCount)",
            "Shared favorites: \(sharedFavoritesCount)",
            "Standard raw data exists: \(standardContactsRawDataExists ? "Yes" : "No")",
            "Standard contacts: \(standardContactsCount)",
            "Migration needed: \(migrationNeeded ? "Yes" : "No")"
        ].joined(separator: "\n")
    }
}

struct WidgetDiagnosticsService {
    private let sharedUserDefaults: UserDefaults?
    private let standardUserDefaults: UserDefaults
    private let contactsKey = Constants.contactsStorageKey

    init(
        sharedUserDefaults: UserDefaults? = UserDefaults(suiteName: Constants.appGroupIdentifier),
        standardUserDefaults: UserDefaults = .standard
    ) {
        self.sharedUserDefaults = sharedUserDefaults
        self.standardUserDefaults = standardUserDefaults
    }

    func loadDiagnostics() -> WidgetDiagnostics {
        let sharedData = sharedUserDefaults?.data(forKey: contactsKey)
        let standardData = standardUserDefaults.data(forKey: contactsKey)
        let sharedContacts = sharedData.flatMap { Self.decodeContacts(from: $0) } ?? []
        let standardContacts = standardData.flatMap { Self.decodeContacts(from: $0) } ?? []

        return WidgetDiagnostics(
            sharedDefaultsAvailable: sharedUserDefaults != nil,
            appGroupContainerAvailable: Self.appGroupContainerAvailable(),
            sharedContactsRawDataExists: sharedData != nil,
            sharedContactsCount: sharedContacts.count,
            sharedFavoritesCount: sharedContacts.filter(\.isFavorite).count,
            standardContactsRawDataExists: standardData != nil,
            standardContactsCount: standardContacts.count,
            migrationNeeded: sharedContacts.isEmpty && !standardContacts.isEmpty,
            appGroupIdentifier: Constants.appGroupIdentifier,
            contactsStorageKey: contactsKey
        )
    }

    @discardableResult
    func migrateContactsToSharedStorageIfNeeded() -> Bool {
        guard let sharedUserDefaults,
              let standardData = standardUserDefaults.data(forKey: contactsKey),
              let standardContacts = Self.decodeContacts(from: standardData),
              !standardContacts.isEmpty else {
            return false
        }

        let sharedData = sharedUserDefaults.data(forKey: contactsKey)
        let sharedContacts = sharedData.flatMap { Self.decodeContacts(from: $0) } ?? []

        guard sharedContacts.isEmpty else {
            return false
        }

        sharedUserDefaults.set(standardData, forKey: contactsKey)
        _ = sharedUserDefaults.synchronize()
        return true
    }

    private static func decodeContacts(from data: Data) -> [Contact]? {
        do {
            return try JSONDecoder().decode([Contact].self, from: data)
        } catch {
            #if DEBUG
            print("TZ Mate diagnostics: failed to decode contacts: \(error)")
            #endif
            return nil
        }
    }

    private static func appGroupContainerAvailable() -> Bool {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier
        ) != nil
    }
}
