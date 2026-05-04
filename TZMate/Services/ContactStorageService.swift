//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

struct ContactStorageService {
    private let sharedUserDefaults: UserDefaults?
    private let standardUserDefaults: UserDefaults
    private let allowsStandardFallback: Bool
    private let contactsKey = Constants.contactsStorageKey

    init(
        sharedUserDefaults: UserDefaults? = SharedUserDefaultsProvider.makeSharedDefaults(),
        standardUserDefaults: UserDefaults = .standard,
        allowsStandardFallback: Bool = true
    ) {
        self.sharedUserDefaults = sharedUserDefaults
        self.standardUserDefaults = standardUserDefaults
        self.allowsStandardFallback = allowsStandardFallback

        if allowsStandardFallback {
            Self.migrateContactsIfNeeded(key: contactsKey, from: standardUserDefaults, to: sharedUserDefaults)
        }
    }

    var isSharedStorageAvailable: Bool {
        sharedUserDefaults != nil
    }

    func loadContacts() -> [Contact] {
        if let sharedData = sharedUserDefaults?.data(forKey: contactsKey),
           let contacts = Self.decodeContacts(from: sharedData) {
            return sortedContacts(contacts)
        }

        guard allowsStandardFallback else {
            return []
        }

        if let standardData = standardUserDefaults.data(forKey: contactsKey),
           let contacts = Self.decodeContacts(from: standardData) {
            return sortedContacts(contacts)
        }

        return []
    }

    func saveContacts(_ contacts: [Contact]) {
        do {
            let data = try JSONEncoder().encode(sortedContacts(contacts))
            storageUserDefaults.set(data, forKey: contactsKey)
            _ = storageUserDefaults.synchronize()
            logDebugSave(contactCount: contacts.count)
        } catch {
            assertionFailure("Failed to encode contacts: \(error)")
        }
    }

    func addContact(_ contact: Contact, to contacts: [Contact]) -> [Contact] {
        sortedContacts(contacts + [contact])
    }

    func updateContact(_ contact: Contact, in contacts: [Contact]) -> [Contact] {
        let updatedContacts = contacts.map { existingContact in
            existingContact.id == contact.id ? contact : existingContact
        }

        return sortedContacts(updatedContacts)
    }

    func deleteContact(id: UUID, from contacts: [Contact]) -> [Contact] {
        sortedContacts(contacts.filter { $0.id != id })
    }

    private var storageUserDefaults: UserDefaults {
        sharedUserDefaults ?? standardUserDefaults
    }

    private static func decodeContacts(from data: Data) -> [Contact]? {
        do {
            return try JSONDecoder().decode([Contact].self, from: data)
        } catch {
            #if DEBUG
            print("TZ Mate storage: failed to decode contacts: \(error)")
            #endif
            return nil
        }
    }

    private func sortedContacts(_ contacts: [Contact]) -> [Contact] {
        contacts.sorted { leftContact, rightContact in
            if leftContact.isFavorite != rightContact.isFavorite {
                return leftContact.isFavorite && !rightContact.isFavorite
            }

            switch (leftContact.widgetOrder, rightContact.widgetOrder) {
            case let (leftOrder?, rightOrder?) where leftOrder != rightOrder:
                return leftOrder < rightOrder
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            default:
                break
            }

            let nameComparison = leftContact.name.localizedStandardCompare(rightContact.name)
            if nameComparison != .orderedSame {
                return nameComparison == .orderedAscending
            }

            return leftContact.createdAt < rightContact.createdAt
        }
    }

    private static func migrateContactsIfNeeded(key: String, from standardUserDefaults: UserDefaults, to sharedUserDefaults: UserDefaults?) {
        guard let sharedUserDefaults,
              let standardData = standardUserDefaults.data(forKey: key),
              let standardContacts = decodeContacts(from: standardData),
              !standardContacts.isEmpty else {
            return
        }

        if let sharedData = sharedUserDefaults.data(forKey: key),
           let sharedContacts = decodeContacts(from: sharedData),
           !sharedContacts.isEmpty {
            return
        }

        sharedUserDefaults.set(standardData, forKey: key)
        _ = sharedUserDefaults.synchronize()
    }

    private func logDebugSave(contactCount: Int) {
        #if DEBUG
        ContactStorageDebugLogger.log(
            contactCount: contactCount,
            sharedDefaultsAvailable: sharedUserDefaults != nil
        )
        #endif
    }
}

#if DEBUG
private enum ContactStorageDebugLogger {
    private static var didLog = false

    static func log(contactCount: Int, sharedDefaultsAvailable: Bool) {
        guard !didLog else {
            return
        }

        didLog = true
        print("TZ Mate app storage: saved contacts=\(contactCount) to sharedDefaultsAvailable=\(sharedDefaultsAvailable)")
    }
}
#endif
