//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import AppKit
import SwiftUI

struct SectionCardView<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.22), lineWidth: 1)
            )
    }
}

struct StatusBadgeView: View {
    let status: TimeStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .foregroundStyle(tint)
            .background(
                Capsule(style: .continuous)
                    .fill(tint.opacity(0.14))
            )
    }

    private var tint: Color {
        switch status {
        case .earlyMorning:
            return .orange
        case .goodTime:
            return .green
        case .evening:
            return .blue
        case .lateNight:
            return .purple
        }
    }
}
