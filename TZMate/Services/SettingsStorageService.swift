import Foundation

struct SettingsStorageService {
    private let sharedUserDefaults: UserDefaults?
    private let standardUserDefaults: UserDefaults
    private let settingsKey = Constants.appSettingsStorageKey

    init(
        sharedUserDefaults: UserDefaults? = UserDefaults(suiteName: Constants.appGroupIdentifier),
        standardUserDefaults: UserDefaults = .standard
    ) {
        self.sharedUserDefaults = sharedUserDefaults
        self.standardUserDefaults = standardUserDefaults
    }

    func loadSettings() -> AppSettings {
        if let sharedData = sharedUserDefaults?.data(forKey: settingsKey),
           let settings = decodeSettings(from: sharedData) {
            return settings
        }

        if let standardData = standardUserDefaults.data(forKey: settingsKey),
           let settings = decodeSettings(from: standardData) {
            sharedUserDefaults?.set(standardData, forKey: settingsKey)
            return settings
        }

        return AppSettings.default
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
}
