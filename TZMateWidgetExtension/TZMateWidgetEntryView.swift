//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import SwiftUI
import WidgetKit

struct TZMateWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: TZMateWidgetEntry

    private let timeZoneService = TimeZoneService()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header

            if entry.contacts.isEmpty {
                emptyState
            } else {
                contactList
            }
        }
        .padding(10)
        .widgetURL(URL(string: "tzmate://open"))
    }

    private var header: some View {
        HStack {
            Text("TZ Mate")
                .font(.headline)

            Spacer()

            Text(timeZoneService.formatTime(entry.date, in: entry.settings.defaultTimeZoneIdentifier, format: entry.settings.timeFormat))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("No contacts yet")
                .font(.subheadline.weight(.semibold))

            Text("Add contacts in TZ Mate")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var contactList: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            ForEach(Array(entry.contacts.prefix(contactLimit))) { contact in
                contactRow(contact)
            }
        }
    }

    private func contactRow(_ contact: Contact) -> some View {
        let localTime = timeZoneService.formatTime(
            entry.date,
            in: contact.timeZoneIdentifier,
            format: entry.settings.timeFormat
        )
        let status = timeZoneService.timeStatus(for: entry.date, in: contact.timeZoneIdentifier)
        let difference = timeZoneService.timeDifferenceDescription(
            from: entry.settings.defaultTimeZoneIdentifier,
            to: contact.timeZoneIdentifier
        )

        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)

                Text(locationText(for: contact))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if widgetFamily == .systemLarge {
                    Text(difference)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 2) {
                Text(localTime)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()

                Text(status.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var contactLimit: Int {
        switch widgetFamily {
        case .systemSmall:
            return 2
        case .systemMedium:
            return 4
        case .systemLarge:
            return 8
        default:
            return 4
        }
    }

    private var rowSpacing: CGFloat {
        widgetFamily == .systemLarge ? 7 : 5
    }

    private func locationText(for contact: Contact) -> String {
        if widgetFamily == .systemSmall {
            return contact.cityName
        }

        return "\(contact.cityName), \(contact.countryName)"
    }
}
