//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import AppKit
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: PopoverTab = .contacts
    @Published private(set) var settings: AppSettings
    @Published private(set) var contacts: [Contact]
    @Published private(set) var launchAtLoginErrorMessage: String?
    @Published private(set) var automaticallyChecksForUpdates: Bool

    let settingsStorageService: SettingsStorageService
    let contactStorageService: ContactStorageService
    let launchAtLoginService: LaunchAtLoginService
    let updateService: UpdateService

    init(
        settingsStorageService: SettingsStorageService? = nil,
        contactStorageService: ContactStorageService = ContactStorageService(),
        launchAtLoginService: LaunchAtLoginService = LaunchAtLoginService(),
        updateService: UpdateService? = nil
    ) {
        self.settingsStorageService = settingsStorageService ?? SettingsStorageService(
            defaultSettingsProvider: {
                DefaultSettingsService().defaultSettings()
            }
        )
        self.contactStorageService = contactStorageService
        self.launchAtLoginService = launchAtLoginService
        self.updateService = updateService ?? UpdateService()
        settings = self.settingsStorageService.loadSettings()
        contacts = contactStorageService.loadContacts()
        automaticallyChecksForUpdates = self.updateService.automaticallyChecksForUpdates
        DispatchQueue.main.async { [weak self] in
            self?.syncLaunchAtLoginStatus()
        }
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

    func setLaunchAtLogin(_ enabled: Bool) {
        launchAtLoginErrorMessage = nil

        do {
            try launchAtLoginService.setEnabled(enabled)
            var updatedSettings = settings
            updatedSettings.launchAtLogin = launchAtLoginService.isEnabled()
            updateSettings(updatedSettings)
        } catch {
            launchAtLoginErrorMessage = launchAtLoginService.errorMessage(for: error)
        }
    }

    func quitApplication() {
        NSApplication.shared.terminate(nil)
    }

    func checkForUpdates() {
        updateService.checkForUpdates()
    }

    func setAutomaticallyChecksForUpdates(_ enabled: Bool) {
        updateService.setAutomaticallyChecksForUpdates(enabled)
        automaticallyChecksForUpdates = updateService.automaticallyChecksForUpdates
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

    private func syncLaunchAtLoginStatus() {
        let systemValue = launchAtLoginService.isEnabled()

        guard settings.launchAtLogin != systemValue else {
            return
        }

        var updatedSettings = settings
        updatedSettings.launchAtLogin = systemValue
        settings = updatedSettings
        settingsStorageService.saveSettings(updatedSettings)
    }
}

enum PopoverTab: String, CaseIterable, Identifiable {
    case contacts
    case lookup
    case converter
    case settings

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .contacts:
            return "Contacts"
        case .lookup:
            return "Lookup"
        case .converter:
            return "Convert"
        case .settings:
            return "Settings"
        }
    }

    var systemImageName: String {
        switch self {
        case .contacts:
            return "person.2"
        case .lookup:
            return "magnifyingglass.circle"
        case .converter:
            return "clock.arrow.circlepath"
        case .settings:
            return "gearshape"
        }
    }
}
