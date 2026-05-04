//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                defaultTimeZoneSection
                preferencesSection
                updatesSection
                launchAtLoginSection
                widgetDiagnosticsSection
                appLifecycleSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var defaultTimeZoneSection: some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Default Time Zone")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 4) {
                    Text(defaultLocationText)
                        .font(.body.weight(.medium))

                    Text(appState.settings.defaultTimeZoneIdentifier)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var preferencesSection: some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Time format", selection: binding(for: \.timeFormat)) {
                    ForEach(TimeFormat.allCases) { format in
                        Text(format.displayName)
                            .tag(format)
                    }
                }

                Picker("Theme", selection: binding(for: \.theme)) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.displayName)
                            .tag(theme)
                    }
                }

                Toggle("Show time in menu bar", isOn: binding(for: \.showTimeInMenuBar))
            }
        }
    }

    private var updatesSection: some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Updates")
                    .font(.headline)

                Button {
                    appState.checkForUpdates()
                } label: {
                    Label("Check for Updates…", systemImage: "arrow.down.circle")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

                Toggle("Automatically Check for Updates", isOn: automaticallyChecksForUpdatesBinding)

                Text("TZ Mate can check for new GitHub Releases when updates are configured.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var launchAtLoginSection: some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Launch at Login", isOn: launchAtLoginBinding)

                Text("Open TZ Mate automatically when you sign in.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let errorMessage = appState.launchAtLoginErrorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private var appLifecycleSection: some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 10) {
                Text("App")
                    .font(.headline)

                Text("Close TZ Mate from the menu bar when you no longer need it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button(role: .destructive) {
                    appState.quitApplication()
                } label: {
                    Label("Quit TZ Mate", systemImage: "power")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }

    private var widgetDiagnosticsSection: some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Widget Diagnostics")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    diagnosticRow("App Group", appState.widgetDiagnostics.appGroupIdentifier)
                    diagnosticRow(
                        "Shared storage",
                        appState.widgetDiagnostics.sharedDefaultsAvailable ? "Available" : "Not available"
                    )
                    diagnosticRow(
                        "App Group container",
                        appState.widgetDiagnostics.appGroupContainerAvailable ? "Available" : "Not available"
                    )
                    diagnosticRow("Shared contacts", "\(appState.widgetDiagnostics.sharedContactsCount)")
                    diagnosticRow("Shared favorites", "\(appState.widgetDiagnostics.sharedFavoritesCount)")
                    diagnosticRow("Standard contacts", "\(appState.widgetDiagnostics.standardContactsCount)")
                    diagnosticRow(
                        "Migration needed",
                        appState.widgetDiagnostics.migrationNeeded ? "Yes" : "No"
                    )
                    diagnosticRow("Storage key", appState.widgetDiagnostics.contactsStorageKey)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Button("Refresh Diagnostics") {
                            appState.refreshWidgetDiagnostics()
                        }

                        Button("Reload Widget") {
                            appState.reloadWidgetTimelinesManually()
                        }
                    }

                    Button("Copy Diagnostics") {
                        appState.copyWidgetDiagnosticsToPasteboard()
                    }

                    Button("Migrate Contacts to Shared Storage") {
                        appState.migrateContactsToSharedStorage()
                    }
                    .disabled(!appState.widgetDiagnostics.migrationNeeded)
                    .help("Copies contacts from standard local storage into the App Group store without deleting anything.")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Text("Diagnostics show counts only. Contact names are not included.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var defaultLocationText: String {
        let settings = appState.settings

        if settings.defaultCountryCode.isEmpty {
            return "\(settings.defaultCity), \(settings.defaultCountryName)"
        }

        return "\(settings.defaultCity), \(settings.defaultCountryName) (\(settings.defaultCountryCode))"
    }

    private func diagnosticRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 8)

            Text(value)
                .font(.caption.monospacedDigit())
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }

    private func binding<Value>(for keyPath: WritableKeyPath<AppSettings, Value>) -> Binding<Value> {
        Binding(
            get: {
                appState.settings[keyPath: keyPath]
            },
            set: { newValue in
                var updatedSettings = appState.settings
                updatedSettings[keyPath: keyPath] = newValue
                DispatchQueue.main.async {
                    appState.updateSettings(updatedSettings)
                }
            }
        )
    }

    private var automaticallyChecksForUpdatesBinding: Binding<Bool> {
        Binding(
            get: {
                appState.automaticallyChecksForUpdates
            },
            set: { enabled in
                DispatchQueue.main.async {
                    appState.setAutomaticallyChecksForUpdates(enabled)
                }
            }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: {
                appState.settings.launchAtLogin
            },
            set: { enabled in
                DispatchQueue.main.async {
                    appState.setLaunchAtLogin(enabled)
                }
            }
        )
    }
}
