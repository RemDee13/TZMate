//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

struct CountryDataService {
    private let countries: [CountryTimeData]

    init(bundle: Bundle = .main) {
        countries = Self.loadCountries(from: bundle)
    }

    init(countries: [CountryTimeData]) {
        self.countries = countries
    }

    func getAllCountries() -> [CountryTimeData] {
        countries
    }

    func searchByCountryName(_ query: String) -> [CountryTimeData] {
        let normalizedQuery = Self.normalizedSearchText(query)

        guard !normalizedQuery.isEmpty else {
            return countries
        }

        if let aliasISOCodes = Self.exactAliasMatches[normalizedQuery] {
            return countries.filter {
                aliasISOCodes.contains($0.isoCode.uppercased())
            }
        }

        return countries.filter {
            Self.searchTerms(for: $0).contains { term in
                term.contains(normalizedQuery)
            }
        }
    }

    func searchCountries(_ query: String) -> [CountryTimeData] {
        searchByCountryName(query)
    }

    func searchByPhoneCode(_ phoneCode: String) -> [CountryTimeData] {
        let normalizedQuery = Self.normalizedPhoneCode(phoneCode)

        guard !normalizedQuery.isEmpty else {
            return []
        }

        return countries.filter {
            Self.normalizedPhoneCode($0.phoneCode) == normalizedQuery
        }
    }

    func getCountry(byISOCode isoCode: String) -> CountryTimeData? {
        let normalizedISOCode = isoCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        return countries.first {
            $0.isoCode.uppercased() == normalizedISOCode
        }
    }

    func getTimeZones(forCountry country: CountryTimeData) -> [CountryTimeZone] {
        country.timeZones
    }

    static func normalizedPhoneCode(_ phoneCode: String) -> String {
        let trimmedCode = phoneCode.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedCode.isEmpty else {
            return ""
        }

        if trimmedCode.hasPrefix("+") {
            return trimmedCode
        }

        return "+\(trimmedCode)"
    }

    private static let exactAliasMatches: [String: Set<String>] = [
        "america": ["US"],
        "britain": ["GB"],
        "czech republic": ["CZ"],
        "emirates": ["AE"],
        "england": ["GB"],
        "great britain": ["GB"],
        "ivory coast": ["CI"],
        "korea": ["KR"],
        "macau": ["MO"],
        "macao": ["MO"],
        "republic of korea": ["KR"],
        "turkiye": ["TR"],
        "uae": ["AE"],
        "uk": ["GB"],
        "united states of america": ["US"],
        "us": ["US"],
        "usa": ["US"]
    ]

    private static let countryAliases: [String: [String]] = [
        "AE": ["UAE", "Emirates"],
        "BO": ["Bolivia"],
        "BN": ["Brunei"],
        "CI": ["Ivory Coast", "Cote d Ivoire"],
        "CZ": ["Czech Republic"],
        "GB": ["UK", "Britain", "Great Britain", "England"],
        "HK": ["Hong Kong"],
        "IR": ["Iran"],
        "KP": ["North Korea"],
        "KR": ["South Korea", "Korea", "Republic of Korea"],
        "LA": ["Laos"],
        "MD": ["Moldova"],
        "MO": ["Macau", "Macao"],
        "PS": ["Palestine"],
        "RU": ["Russia"],
        "SY": ["Syria"],
        "TR": ["Turkey", "Turkiye"],
        "TW": ["Taiwan"],
        "TZ": ["Tanzania"],
        "US": ["USA", "US", "America", "United States of America"],
        "VA": ["Vatican"],
        "VE": ["Venezuela"],
        "VN": ["Vietnam"]
    ]

    private static func searchTerms(for country: CountryTimeData) -> [String] {
        let aliases = countryAliases[country.isoCode.uppercased(), default: []]
        return ([country.countryName, country.isoCode] + aliases).map(normalizedSearchText)
    }

    private static func normalizedSearchText(_ value: String) -> String {
        let foldedValue = value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()

        let scalars = foldedValue.unicodeScalars.map { scalar -> Character in
            if CharacterSet.alphanumerics.contains(scalar) {
                return Character(scalar)
            }

            return " "
        }

        return String(scalars)
            .split(separator: " ")
            .joined(separator: " ")
    }

    private static func loadCountries(from bundle: Bundle) -> [CountryTimeData] {
        guard let url = bundle.url(forResource: "country_time_data", withExtension: "json") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([CountryTimeData].self, from: data)
        } catch {
            return []
        }
    }
}
