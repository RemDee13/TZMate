//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

struct PhoneCodeService {
    private let countries: [CountryTimeData]

    init(countries: [CountryTimeData]) {
        self.countries = countries
    }

    init(countryDataService: CountryDataService = CountryDataService()) {
        countries = countryDataService.getAllCountries()
    }

    func searchByPhoneCode(_ phoneCode: String) -> [CountryTimeData] {
        guard let matchedPhoneCode = matchedPhoneCode(for: phoneCode) else {
            return []
        }

        return countries.filter {
            CountryDataService.normalizedPhoneCode($0.phoneCode) == matchedPhoneCode
        }
    }

    func lookup(_ phoneCode: String) -> PhoneCodeLookupResult {
        let matches = searchByPhoneCode(phoneCode)

        guard !matches.isEmpty else {
            return .noMatch(query: phoneCode)
        }

        if matches.count > 1 {
            return .multipleCountries(matches)
        }

        guard let country = matches.first else {
            return .noMatch(query: phoneCode)
        }

        if country.timeZones.count == 1 {
            return .singleCountrySingleTimeZone(country)
        }

        return .singleCountryMultipleTimeZones(country)
    }

    private func matchedPhoneCode(for input: String) -> String? {
        let inputDigits = digitsOnly(input)

        guard !inputDigits.isEmpty else {
            return nil
        }

        let availablePhoneCodes = Set(countries.map { digitsOnly($0.phoneCode) })
            .filter { !$0.isEmpty }
            .sorted { leftCode, rightCode in
                if leftCode.count != rightCode.count {
                    return leftCode.count > rightCode.count
                }

                return leftCode < rightCode
            }

        guard let matchedCode = availablePhoneCodes.first(where: { inputDigits.hasPrefix($0) }) else {
            return nil
        }

        return "+\(matchedCode)"
    }

    private func digitsOnly(_ value: String) -> String {
        value.filter(\.isNumber)
    }
}
