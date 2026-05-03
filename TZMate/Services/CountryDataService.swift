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
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedQuery.isEmpty else {
            return countries
        }

        return countries.filter {
            $0.countryName.range(of: normalizedQuery, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
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
