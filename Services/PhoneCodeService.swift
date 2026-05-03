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
        let normalizedQuery = CountryDataService.normalizedPhoneCode(phoneCode)

        guard !normalizedQuery.isEmpty else {
            return []
        }

        return countries.filter {
            CountryDataService.normalizedPhoneCode($0.phoneCode) == normalizedQuery
        }
    }

    func lookup(_ phoneCode: String) -> PhoneCodeLookupResult {
        let matches = searchByPhoneCode(phoneCode)

        guard !matches.isEmpty else {
            return .noMatch
        }

        if matches.count > 1 {
            return .multipleCountries(matches)
        }

        guard let country = matches.first else {
            return .noMatch
        }

        if country.timeZones.count == 1 {
            return .singleCountrySingleTimeZone(country)
        }

        return .singleCountryMultipleTimeZones(country)
    }
}
