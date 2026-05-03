import Foundation

struct TimeZoneService {
    func currentTime(in timeZoneIdentifier: String) -> Date {
        Date()
    }

    func formatTime(_ date: Date, in timeZoneIdentifier: String, format: TimeFormat) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone(for: timeZoneIdentifier)
        formatter.dateFormat = format == .twentyFourHour ? "HH:mm" : "h:mm a"
        return formatter.string(from: date)
    }

    func formatDate(_ date: Date, in timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone(for: timeZoneIdentifier)
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    func timeDifferenceDescription(
        from sourceTimeZoneIdentifier: String,
        to targetTimeZoneIdentifier: String
    ) -> String {
        let referenceDate = Date()
        let sourceOffset = timeZone(for: sourceTimeZoneIdentifier).secondsFromGMT(for: referenceDate)
        let targetOffset = timeZone(for: targetTimeZoneIdentifier).secondsFromGMT(for: referenceDate)
        let differenceInSeconds = targetOffset - sourceOffset

        guard differenceInSeconds != 0 else {
            return "Same time"
        }

        let sign = differenceInSeconds > 0 ? "+" : "-"
        let absoluteDifference = abs(differenceInSeconds)
        let hours = absoluteDifference / 3_600
        let minutes = (absoluteDifference % 3_600) / 60

        if minutes == 0 {
            return "\(sign)\(hours)h"
        }

        return "\(sign)\(hours)h \(minutes)m"
    }

    func timeStatus(for date: Date, in timeZoneIdentifier: String) -> TimeStatus {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone(for: timeZoneIdentifier)

        let hour = calendar.component(.hour, from: date)

        switch hour {
        case 7...8:
            return .earlyMorning
        case 9...17:
            return .goodTime
        case 18...20:
            return .evening
        default:
            return .lateNight
        }
    }

    func convert(
        date: Date,
        from sourceTimeZoneIdentifier: String,
        to targetTimeZoneIdentifier: String
    ) -> Date {
        date
    }

    func dateRelation(
        from sourceDate: Date,
        sourceTimeZoneIdentifier: String,
        targetDate: Date,
        targetTimeZoneIdentifier: String
    ) -> DateRelation {
        let sourceDay = dayOrdinal(for: sourceDate, in: sourceTimeZoneIdentifier)
        let targetDay = dayOrdinal(for: targetDate, in: targetTimeZoneIdentifier)

        if targetDay == sourceDay {
            return .sameDay
        }

        if targetDay == sourceDay - 1 {
            return .previousDay
        }

        if targetDay == sourceDay + 1 {
            return .nextDay
        }

        return .differentDate
    }

    private func timeZone(for identifier: String) -> TimeZone {
        TimeZone(identifier: identifier) ?? .current
    }

    private func dayOrdinal(for date: Date, in timeZoneIdentifier: String) -> Int {
        var sourceCalendar = Calendar(identifier: .gregorian)
        sourceCalendar.timeZone = timeZone(for: timeZoneIdentifier)

        let dateComponents = sourceCalendar.dateComponents([.year, .month, .day], from: date)

        var comparisonCalendar = Calendar(identifier: .gregorian)
        comparisonCalendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        guard let comparisonDate = comparisonCalendar.date(from: dateComponents),
              let ordinal = comparisonCalendar.ordinality(of: .day, in: .era, for: comparisonDate) else {
            return 0
        }

        return ordinal
    }
}
