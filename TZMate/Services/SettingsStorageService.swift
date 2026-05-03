import Foundation

struct SettingsStorageService {
    private let userDefaults: UserDefaults
    private let settingsKey = "tzmate.appSettings"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadSettings() -> AppSettings {
        guard let data = userDefaults.data(forKey: settingsKey) else {
            return AppSettings.default
        }

        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            return AppSettings.default
        }
    }

    func saveSettings(_ settings: AppSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            userDefaults.set(data, forKey: settingsKey)
        } catch {
            assertionFailure("Failed to encode app settings: \(error)")
        }
    }
}
