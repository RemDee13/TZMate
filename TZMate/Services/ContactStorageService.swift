import Foundation

struct ContactStorageService {
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

    func loadContacts() -> [Contact] {
        if let sharedData = sharedUserDefaults?.data(forKey: contactsKey),
           let contacts = decodeContacts(from: sharedData) {
            return sortedContacts(contacts)
        }

        if let standardData = standardUserDefaults.data(forKey: contactsKey),
           let contacts = decodeContacts(from: standardData) {
            sharedUserDefaults?.set(standardData, forKey: contactsKey)
            return sortedContacts(contacts)
        }

        return []
    }

    func saveContacts(_ contacts: [Contact]) {
        do {
            let data = try JSONEncoder().encode(sortedContacts(contacts))
            storageUserDefaults.set(data, forKey: contactsKey)
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

    private func decodeContacts(from data: Data) -> [Contact]? {
        do {
            return try JSONDecoder().decode([Contact].self, from: data)
        } catch {
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
}
