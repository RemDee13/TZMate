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
