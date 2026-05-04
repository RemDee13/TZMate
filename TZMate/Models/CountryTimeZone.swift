//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

struct CountryTimeZone: Identifiable, Codable, Equatable {
    var identifier: String
    var label: String
    var majorCities: [String]

    var id: String {
        identifier
    }
}
