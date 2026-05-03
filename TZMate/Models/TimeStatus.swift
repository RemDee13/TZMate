import Foundation

enum TimeStatus: String, Codable, CaseIterable, Identifiable, Equatable {
    case earlyMorning
    case goodTime
    case evening
    case lateNight

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .earlyMorning:
            return "Early morning"
        case .goodTime:
            return "Good time"
        case .evening:
            return "Evening"
        case .lateNight:
            return "Late night"
        }
    }
}
