//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

struct SettingsStorageService {
    private let sharedUserDefaults: UserDefaults?
    private let standardUserDefaults: UserDefaults
    private let defaultSettingsProvider: () -> AppSettings
    private let settingsKey = Constants.appSettingsStorageKey

    init(
        sharedUserDefaults: UserDefaults? = SharedUserDefaultsProvider.makeSharedDefaults(),
        standardUserDefaults: UserDefaults = .standard,
        defaultSettingsProvider: @escaping () -> AppSettings = { AppSettings.default }
    ) {
        self.sharedUserDefaults = sharedUserDefaults
        self.standardUserDefaults = standardUserDefaults
        self.defaultSettingsProvider = defaultSettingsProvider
        Self.migrateValueIfNeeded(key: settingsKey, from: standardUserDefaults, to: sharedUserDefaults)
    }

    func loadSettings() -> AppSettings {
        if let sharedData = sharedUserDefaults?.data(forKey: settingsKey),
           let settings = decodeSettings(from: sharedData) {
            return settings
        }

        if let standardData = standardUserDefaults.data(forKey: settingsKey),
           let settings = decodeSettings(from: standardData) {
            return settings
        }

        return defaultSettingsProvider()
    }

    func saveSettings(_ settings: AppSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            storageUserDefaults.set(data, forKey: settingsKey)
        } catch {
            assertionFailure("Failed to encode app settings: \(error)")
        }
    }

    private var storageUserDefaults: UserDefaults {
        sharedUserDefaults ?? standardUserDefaults
    }

    private func decodeSettings(from data: Data) -> AppSettings? {
        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            return nil
        }
    }

    private static func migrateValueIfNeeded(key: String, from standardUserDefaults: UserDefaults, to sharedUserDefaults: UserDefaults?) {
        guard let sharedUserDefaults,
              sharedUserDefaults.data(forKey: key) == nil,
              let standardData = standardUserDefaults.data(forKey: key) else {
            return
        }

        sharedUserDefaults.set(standardData, forKey: key)
    }
}
