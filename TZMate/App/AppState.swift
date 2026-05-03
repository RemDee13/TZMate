import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: PopoverTab = .contacts
    @Published private(set) var settings: AppSettings

    let settingsStorageService: SettingsStorageService

    init(settingsStorageService: SettingsStorageService = SettingsStorageService()) {
        self.settingsStorageService = settingsStorageService
        settings = settingsStorageService.loadSettings()
    }

    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        settingsStorageService.saveSettings(newSettings)
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
