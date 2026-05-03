import SwiftUI

struct RootPopoverView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            tabPicker
            activeTab
        }
        .padding(20)
        .frame(width: 410, height: 580)
        .preferredColorScheme(appState.settings.theme.colorScheme)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("TZ Mate")
                .font(.title3.weight(.semibold))

            Spacer()

            Text("Menu Bar")
                .font(.caption)
                .foregroundStyle(.secondary)
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
        case .converter:
            TimeConverterView()
        case .settings:
            SettingsView()
        }
    }
}
