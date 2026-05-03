import Foundation

struct AppSettings: Codable, Equatable {
    var defaultCountryName: String
    var defaultCountryCode: String
    var defaultCity: String
    var defaultTimeZoneIdentifier: String
    var timeFormat: TimeFormat
    var theme: AppTheme
    var showTimeInMenuBar: Bool
    var launchAtLogin: Bool

    static var `default`: AppSettings {
        let systemTimeZoneIdentifier = TimeZone.current.identifier

        if systemTimeZoneIdentifier == "Asia/Bangkok" {
            return AppSettings(
                defaultCountryName: "Thailand",
                defaultCountryCode: "TH",
                defaultCity: "Bangkok",
                defaultTimeZoneIdentifier: "Asia/Bangkok",
                timeFormat: .twentyFourHour,
                theme: .system,
                showTimeInMenuBar: false,
                launchAtLogin: false
            )
        }

        return AppSettings(
            defaultCountryName: "Local",
            defaultCountryCode: "",
            defaultCity: "System Time Zone",
            defaultTimeZoneIdentifier: systemTimeZoneIdentifier,
            timeFormat: .twentyFourHour,
            theme: .system,
            showTimeInMenuBar: false,
            launchAtLogin: false
        )
    }
}
