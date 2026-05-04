import AppKit
import SwiftUI

struct ContactRowView: View {
    let contact: Contact
    let settings: AppSettings
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void

    private let timeZoneService = TimeZoneService()

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 60)) { context in
            rowContent(for: context.date)
        }
    }

    private func rowContent(for date: Date) -> some View {
        let localTime = timeZoneService.formatTime(
            date,
            in: contact.timeZoneIdentifier,
            format: settings.timeFormat
        )
        let difference = timeZoneService.timeDifferenceDescription(
            from: settings.defaultTimeZoneIdentifier,
            to: contact.timeZoneIdentifier
        )
        let status = timeZoneService.timeStatus(for: date, in: contact.timeZoneIdentifier)

        return HStack(alignment: .center, spacing: 10) {
            Button(action: onToggleFavorite) {
                Image(systemName: contact.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(contact.isFavorite ? .yellow : .secondary)
                    .frame(width: 18)
            }
            .buttonStyle(.plain)
            .help(contact.isFavorite ? "Hide from widget" : "Show in widget")

            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)

                Text("\(contact.cityName), \(contact.countryName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(difference)
                    StatusBadgeView(status: status)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Text(localTime)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .monospacedDigit()

                HStack(spacing: 8) {
                    Button {
                        copyLocalTimeSummary(for: date)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                    .help("Copy local time")

                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.plain)
                    .help("Edit contact")

                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .help("Delete contact")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(nsColor: .separatorColor).opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func copyLocalTimeSummary(for date: Date) {
        let localTime = timeZoneService.formatTime(
            date,
            in: contact.timeZoneIdentifier,
            format: settings.timeFormat
        )
        let summary = "\(contact.name) local time: \(localTime) in \(contact.cityName), \(contact.countryName)"

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(summary, forType: .string)
    }
}
