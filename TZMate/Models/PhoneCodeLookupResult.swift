import Foundation

enum PhoneCodeLookupResult: Equatable {
    case noMatch(query: String)
    case singleCountrySingleTimeZone(CountryTimeData)
    case singleCountryMultipleTimeZones(CountryTimeData)
    case multipleCountries([CountryTimeData])

    var countries: [CountryTimeData] {
        switch self {
        case .noMatch:
            return []
        case .singleCountrySingleTimeZone(let country):
            return [country]
        case .singleCountryMultipleTimeZones(let country):
            return [country]
        case .multipleCountries(let countries):
            return countries
        }
    }
}
