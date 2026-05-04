//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

struct DefaultSettingsService {
    private let countryDataService: CountryDataService
    private let timeZone: TimeZone

    init(
        countryDataService: CountryDataService = CountryDataService(),
        timeZone: TimeZone = .current
    ) {
        self.countryDataService = countryDataService
        self.timeZone = timeZone
    }

    func defaultSettings() -> AppSettings {
        let timeZoneIdentifier = timeZone.identifier

        guard let match = matchedCountryAndTimeZone(for: timeZoneIdentifier) else {
            return AppSettings.default(for: timeZoneIdentifier)
        }

        return AppSettings(
            defaultCountryName: match.country.countryName,
            defaultCountryCode: match.country.isoCode,
            defaultCity: match.timeZone.majorCities.first ?? match.country.defaultCity,
            defaultTimeZoneIdentifier: timeZoneIdentifier,
            timeFormat: .twentyFourHour,
            theme: .system,
            showTimeInMenuBar: false,
            launchAtLogin: false
        )
    }

    private func matchedCountryAndTimeZone(for timeZoneIdentifier: String) -> (country: CountryTimeData, timeZone: CountryTimeZone)? {
        for country in countryDataService.getAllCountries() {
            if let timeZone = country.timeZones.first(where: { $0.identifier == timeZoneIdentifier }) {
                return (country, timeZone)
            }
        }

        return nil
    }
}
