//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

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
        `default`(for: TimeZone.current.identifier)
    }

    static func `default`(for timeZoneIdentifier: String) -> AppSettings {
        if timeZoneIdentifier == "Asia/Bangkok" {
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
            defaultTimeZoneIdentifier: timeZoneIdentifier,
            timeFormat: .twentyFourHour,
            theme: .system,
            showTimeInMenuBar: false,
            launchAtLogin: false
        )
    }
}
