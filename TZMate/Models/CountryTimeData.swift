import Foundation

struct CountryTimeData: Identifiable, Codable, Equatable {
    var countryName: String
    var isoCode: String
    var phoneCode: String
    var defaultCity: String
    var defaultTimeZone: String
    var timeZones: [CountryTimeZone]

    var id: String {
        isoCode
    }
}
