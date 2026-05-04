import AppKit
import SwiftUI

struct RootPopoverView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            tabPicker
            activeTab
        }
        .padding(18)
        .frame(width: 430, height: 620)
        .background(Color(nsColor: .windowBackgroundColor))
        .preferredColorScheme(appState.settings.theme.colorScheme)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 1) {
                Text("TZ Mate")
                    .font(.title3.weight(.semibold))

                Text("Check client local time before you call.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var tabPicker: some View {
        Picker("Section", selection: $appState.selectedTab) {
            ForEach(PopoverTab.allCases) { tab in
                Text(tab.title)
                    .tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    @ViewBuilder
    private var activeTab: some View {
        switch appState.selectedTab {
        case .contacts:
            ContactsView()
        case .lookup:
            PhoneLookupView()
        case .converter:
            TimeConverterView()
        case .settings:
            SettingsView()
        }
    }
}
