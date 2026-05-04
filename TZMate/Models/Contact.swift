//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

struct Contact: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var countryName: String
    var countryCode: String
    var cityName: String
    var phoneCode: String?
    var timeZoneIdentifier: String
    var note: String?
    var isFavorite: Bool
    var widgetOrder: Int?
    var createdAt: Date
    var updatedAt: Date

    static let sample = Contact(
        id: UUID(uuidString: "A7C3C21E-D1C2-4F87-B986-AD74C7C1D04A") ?? UUID(),
        name: "Mr. Kurt",
        countryName: "Germany",
        countryCode: "DE",
        cityName: "Berlin",
        phoneCode: "+49",
        timeZoneIdentifier: "Europe/Berlin",
        note: "Sample contact for previews.",
        isFavorite: true,
        widgetOrder: 0,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}
