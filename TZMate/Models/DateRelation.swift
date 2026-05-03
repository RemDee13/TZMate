import Foundation

enum DateRelation: String, Codable, Equatable {
    case previousDay
    case sameDay
    case nextDay
    case differentDate

    var displayName: String {
        switch self {
        case .previousDay:
            return "Previous day"
        case .sameDay:
            return "Same day"
        case .nextDay:
            return "Next day"
        case .differentDate:
            return "Different date"
        }
    }
}
