import Foundation

struct CountryTimeZone: Identifiable, Codable, Equatable {
    var identifier: String
    var label: String
    var majorCities: [String]

    var id: String {
        identifier
    }
}
