import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                defaultTimeZoneSection
                preferencesSection
                launchAtLoginSection
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

    private var launchAtLoginSection: some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 6) {
                Toggle("Launch at login", isOn: .constant(appState.settings.launchAtLogin))
                    .disabled(true)

                Text("Coming later")
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

    private func binding<Value>(for keyPath: WritableKeyPath<AppSettings, Value>) -> Binding<Value> {
        Binding(
            get: {
                appState.settings[keyPath: keyPath]
            },
            set: { newValue in
                var updatedSettings = appState.settings
                updatedSettings[keyPath: keyPath] = newValue
                appState.updateSettings(updatedSettings)
            }
        )
    }
}
