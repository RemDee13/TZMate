//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

enum TimeFormat: String, Codable, CaseIterable, Identifiable {
    case twelveHour
    case twentyFourHour

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .twelveHour:
            return "12-hour"
        case .twentyFourHour:
            return "24-hour"
        }
    }
}
