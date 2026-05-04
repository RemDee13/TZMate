//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

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
