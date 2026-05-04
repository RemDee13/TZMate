//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import AppKit
import SwiftUI

struct ContactFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    private let contact: Contact?
    private let countries: [CountryTimeData]
    private let onSave: (Contact) -> Void
    private let timeZoneService = TimeZoneService()

    @State private var name: String
    @State private var selectedCountryISOCode: String
    @State private var cityName: String
    @State private var phoneCode: String
    @State private var selectedTimeZoneIdentifier: String
    @State private var note: String
    @State private var isFavorite: Bool
    @State private var lookupResult: PhoneCodeLookupResult?
    @State private var lookupTimeZoneIdentifier: String
    @State private var isApplyingLookupSelection = false

    init(
        contact: Contact? = nil,
        countryDataService: CountryDataService = CountryDataService(),
        onSave: @escaping (Contact) -> Void
    ) {
        self.contact = contact
        self.onSave = onSave

        let loadedCountries = countryDataService.getAllCountries()
        countries = loadedCountries

        let contactCountry = contact.flatMap { existingContact in
            loadedCountries.first { $0.isoCode == existingContact.countryCode }
        }
        let initialCountry = contactCountry ?? loadedCountries.first

        _name = State(initialValue: contact?.name ?? "")
        _selectedCountryISOCode = State(initialValue: contact?.countryCode ?? initialCountry?.isoCode ?? "")
        _cityName = State(initialValue: contact?.cityName ?? initialCountry?.defaultCity ?? "")
        _phoneCode = State(initialValue: contact?.phoneCode ?? initialCountry?.phoneCode ?? "")
        _selectedTimeZoneIdentifier = State(
            initialValue: contact?.timeZoneIdentifier ?? initialCountry?.defaultTimeZone ?? TimeZone.current.identifier
        )
        _lookupTimeZoneIdentifier = State(
            initialValue: contact?.timeZoneIdentifier ?? initialCountry?.defaultTimeZone ?? TimeZone.current.identifier
        )
        _note = State(initialValue: contact?.note ?? "")
        _isFavorite = State(initialValue: contact?.isFavorite ?? false)
        _lookupResult = State(initialValue: nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(contact == nil ? "Add Contact" : "Edit Contact")
                .font(.headline)

            Form {
                TextField("Name", text: $name)
                phoneCodeLookupSection

                if countries.isEmpty {
                    Text("Country data unavailable")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Country", selection: $selectedCountryISOCode) {
                        ForEach(countries) { country in
                            Text(country.countryName)
                                .tag(country.isoCode)
                        }
                    }

                    TextField("City", text: $cityName)

                    if currentTimeZones.count > 1 {
                        Picker("Time zone", selection: $selectedTimeZoneIdentifier) {
                            ForEach(currentTimeZones) { timeZone in
                                Text(timeZonePickerLabel(for: timeZone))
                                    .tag(timeZone.identifier)
                            }
                        }
                    } else if let onlyTimeZone = currentTimeZones.first {
                        LabeledContent("Time zone") {
                            Text(timeZonePickerLabel(for: onlyTimeZone))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                TextField("Note", text: $note)

                Toggle("Show in widget", isOn: $isFavorite)
            }

            if !isValid {
                Text("Name and valid time zone are required.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Save") {
                    saveContact()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
        }
        .padding(20)
        .frame(width: 420, height: 580)
        .onChange(of: selectedCountryISOCode) { newISOCode in
            if isApplyingLookupSelection {
                isApplyingLookupSelection = false
                return
            }

            guard let country = countries.first(where: { $0.isoCode == newISOCode }) else {
                return
            }

            applyCountryDefaults(country)
        }
        .onChange(of: selectedTimeZoneIdentifier) { newTimeZoneIdentifier in
            guard let timeZone = currentTimeZones.first(where: { $0.identifier == newTimeZoneIdentifier }),
                  let firstCity = timeZone.majorCities.first else {
                return
            }

            cityName = firstCity
        }
    }

    private var phoneCodeLookupSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Phone code or number prefix", text: $phoneCode)

                Button("Lookup") {
                    runPhoneCodeLookup()
                }
                .disabled(phoneCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if let lookupResult {
                phoneCodeLookupResultView(lookupResult)
            }
        }
    }

    private var selectedCountry: CountryTimeData? {
        countries.first { $0.isoCode == selectedCountryISOCode } ?? countries.first
    }

    private var currentTimeZones: [CountryTimeZone] {
        selectedCountry?.timeZones ?? []
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && TimeZone(identifier: selectedTimeZoneIdentifier) != nil
            && selectedCountry != nil
    }

    private func timeZonePickerLabel(for timeZone: CountryTimeZone) -> String {
        let cities = timeZone.majorCities.prefix(3).joined(separator: ", ")

        guard !cities.isEmpty else {
            return timeZone.label
        }

        return "\(timeZone.label) - \(cities)"
    }

    @ViewBuilder
    private func phoneCodeLookupResultView(_ result: PhoneCodeLookupResult) -> some View {
        switch result {
        case .noMatch:
            Text("No country found for this phone code.")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .singleCountrySingleTimeZone(let country):
            if let timeZone = defaultTimeZone(for: country) {
                lookupCountryCard(
                    country: country,
                    timeZone: timeZone,
                    actionTitle: "Use this country"
                ) {
                    applyLookupSelection(country: country, timeZone: timeZone)
                }
            }
        case .singleCountryMultipleTimeZones(let country):
            multipleTimeZoneLookupView(for: country)
        case .multipleCountries(let countries):
            multipleCountryLookupView(countries)
        }
    }

    private func lookupCountryCard(
        country: CountryTimeData,
        timeZone: CountryTimeZone,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(country.countryName)
                .font(.caption.weight(.semibold))

            Text("\(country.defaultCity) - \(timeZoneService.formatTime(Date(), in: timeZone.identifier, format: appState.settings.timeFormat))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(timeZone.label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button(actionTitle, action: action)
                .controlSize(.small)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(nsColor: .separatorColor).opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func multipleTimeZoneLookupView(for country: CountryTimeData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(country.countryName)
                .font(.caption.weight(.semibold))

            Text("Current time range: \(timeZoneService.timeRangeDescription(for: country.timeZones, format: appState.settings.timeFormat))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("This country has multiple time zones. Choose a city/time zone.")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Picker("Choose city/time zone", selection: $lookupTimeZoneIdentifier) {
                ForEach(country.timeZones) { timeZone in
                    Text(lookupTimeZoneLabel(for: timeZone))
                        .tag(timeZone.identifier)
                }
            }

            Button("Use selected time zone") {
                let timeZone = timeZone(in: country, matching: lookupTimeZoneIdentifier)
                    ?? defaultTimeZone(for: country)

                guard let timeZone else {
                    return
                }

                applyLookupSelection(country: country, timeZone: timeZone)
            }
            .controlSize(.small)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(nsColor: .separatorColor).opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func multipleCountryLookupView(_ countries: [CountryTimeData]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This phone code is used by multiple countries. Choose one.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(countries) { country in
                HStack(alignment: .center, spacing: 8) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(country.countryName)
                            .font(.caption.weight(.semibold))

                        Text(country.defaultCity)
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text(countryTimeSummary(for: country))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("Use") {
                        guard let timeZone = defaultTimeZone(for: country) else {
                            return
                        }

                        applyLookupSelection(country: country, timeZone: timeZone)
                    }
                    .controlSize(.small)
                }
                .padding(6)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private func runPhoneCodeLookup() {
        let result = PhoneCodeService(countries: countries).lookup(phoneCode)
        lookupResult = result

        switch result {
        case .singleCountryMultipleTimeZones(let country):
            lookupTimeZoneIdentifier = defaultTimeZone(for: country)?.identifier ?? country.defaultTimeZone
        default:
            break
        }
    }

    private func countryTimeSummary(for country: CountryTimeData) -> String {
        if country.timeZones.count > 1 {
            return "Current time range: \(timeZoneService.timeRangeDescription(for: country.timeZones, format: appState.settings.timeFormat))"
        }

        guard let timeZone = defaultTimeZone(for: country) else {
            return ""
        }

        return "Current local time: \(timeZoneService.formatTime(Date(), in: timeZone.identifier, format: appState.settings.timeFormat))"
    }

    private func lookupTimeZoneLabel(for timeZone: CountryTimeZone) -> String {
        let city = timeZone.majorCities.first ?? "City"
        return "\(city) - \(timeZone.label)"
    }

    private func defaultTimeZone(for country: CountryTimeData) -> CountryTimeZone? {
        country.timeZones.first { $0.identifier == country.defaultTimeZone } ?? country.timeZones.first
    }

    private func timeZone(in country: CountryTimeData, matching identifier: String) -> CountryTimeZone? {
        country.timeZones.first { $0.identifier == identifier }
    }

    private func applyLookupSelection(country: CountryTimeData, timeZone: CountryTimeZone) {
        isApplyingLookupSelection = selectedCountryISOCode != country.isoCode
        selectedCountryISOCode = country.isoCode
        phoneCode = country.phoneCode
        selectedTimeZoneIdentifier = timeZone.identifier
        cityName = timeZone.majorCities.first ?? country.defaultCity
        lookupTimeZoneIdentifier = timeZone.identifier
    }

    private func applyCountryDefaults(_ country: CountryTimeData) {
        cityName = country.defaultCity
        phoneCode = country.phoneCode
        selectedTimeZoneIdentifier = country.defaultTimeZone
    }

    private func saveContact() {
        guard let country = selectedCountry else {
            return
        }

        let now = Date()
        let cleanedPhoneCode = phoneCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedCity = cityName.trimmingCharacters(in: .whitespacesAndNewlines)

        let savedContact = Contact(
            id: contact?.id ?? UUID(),
            name: cleanedName,
            countryName: country.countryName,
            countryCode: country.isoCode,
            cityName: cleanedCity.isEmpty ? country.defaultCity : cleanedCity,
            phoneCode: cleanedPhoneCode.isEmpty ? nil : cleanedPhoneCode,
            timeZoneIdentifier: selectedTimeZoneIdentifier,
            note: cleanedNote.isEmpty ? nil : cleanedNote,
            isFavorite: isFavorite,
            widgetOrder: isFavorite ? contact?.widgetOrder : nil,
            createdAt: contact?.createdAt ?? now,
            updatedAt: now
        )

        onSave(savedContact)
        dismiss()
    }
}
