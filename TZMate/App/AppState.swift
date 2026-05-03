import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: PopoverTab = .contacts
    @Published private(set) var settings: AppSettings
    @Published private(set) var contacts: [Contact]

    let settingsStorageService: SettingsStorageService
    let contactStorageService: ContactStorageService

    init(
        settingsStorageService: SettingsStorageService = SettingsStorageService(),
        contactStorageService: ContactStorageService = ContactStorageService()
    ) {
        self.settingsStorageService = settingsStorageService
        self.contactStorageService = contactStorageService
        settings = settingsStorageService.loadSettings()
        contacts = contactStorageService.loadContacts()
    }

    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        settingsStorageService.saveSettings(newSettings)
    }

    func addContact(_ contact: Contact) {
        let normalizedContact = contactWithWidgetOrderIfNeeded(contact)
        contacts = contactStorageService.addContact(normalizedContact, to: contacts)
        contactStorageService.saveContacts(contacts)
    }

    func updateContact(_ contact: Contact) {
        var updatedContact = contactWithWidgetOrderIfNeeded(contact)
        updatedContact.updatedAt = Date()
        contacts = contactStorageService.updateContact(updatedContact, in: contacts)
        contactStorageService.saveContacts(contacts)
    }

    func deleteContact(id: UUID) {
        contacts = contactStorageService.deleteContact(id: id, from: contacts)
        contactStorageService.saveContacts(contacts)
    }

    func toggleFavorite(for contactID: UUID) {
        guard let contact = contacts.first(where: { $0.id == contactID }) else {
            return
        }

        var updatedContact = contact
        updatedContact.isFavorite.toggle()
        updatedContact.widgetOrder = updatedContact.isFavorite ? nextWidgetOrder() : nil
        updatedContact.updatedAt = Date()

        contacts = contactStorageService.updateContact(updatedContact, in: contacts)
        contactStorageService.saveContacts(contacts)
    }

    private func contactWithWidgetOrderIfNeeded(_ contact: Contact) -> Contact {
        var updatedContact = contact

        if updatedContact.isFavorite && updatedContact.widgetOrder == nil {
            updatedContact.widgetOrder = nextWidgetOrder()
        }

        if !updatedContact.isFavorite {
            updatedContact.widgetOrder = nil
        }

        return updatedContact
    }

    private func nextWidgetOrder() -> Int {
        let maxOrder = contacts.compactMap(\.widgetOrder).max() ?? -1
        return maxOrder + 1
    }
}

enum PopoverTab: String, CaseIterable, Identifiable {
    case contacts
    case converter
    case settings

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .contacts:
            return "Contacts"
        case .converter:
            return "Converter"
        case .settings:
            return "Settings"
        }
    }

    var systemImageName: String {
        switch self {
        case .contacts:
            return "person.2"
        case .converter:
            return "clock.arrow.circlepath"
        case .settings:
            return "gearshape"
        }
    }
}
