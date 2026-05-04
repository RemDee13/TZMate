//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import AppKit
import SwiftUI

struct TimeConverterView: View {
    @EnvironmentObject private var appState: AppState

    private let countries: [CountryTimeData]
    private let timeZoneService = TimeZoneService()

    @State private var myCountryISOCode: String
    @State private var myTimeZoneIdentifier: String
    @State private var myCityName: String
    @State private var myTimeSelection = Date()
    @State private var clientCountryISOCode: String
    @State private var clientTimeZoneIdentifier: String
    @State private var clientCityName: String
    @State private var clientTimeSelection = Date()
    @State private var lastEditedSide: ConverterSide = .my
    @State private var isUpdatingProgrammatically = false
    @State private var didApplySettingsDefault = false
    @State private var didInitializeTimeSelections = false

    init(countryDataService: CountryDataService = CountryDataService()) {
        let loadedCountries = countryDataService.getAllCountries()
        countries = loadedCountries

        let myFallbackCountry = loadedCountries.first { $0.isoCode == "TH" } ?? loadedCountries.first
        let clientFallbackCountry = loadedCountries.first { $0.isoCode == "GB" }
            ?? loadedCountries.first { $0.isoCode == "DE" }
            ?? loadedCountries.first

        _myCountryISOCode = State(initialValue: myFallbackCountry?.isoCode ?? "")
        _myTimeZoneIdentifier = State(initialValue: myFallbackCountry?.defaultTimeZone ?? TimeZone.current.identifier)
        _myCityName = State(initialValue: myFallbackCountry?.defaultCity ?? "Local")
        _clientCountryISOCode = State(initialValue: clientFallbackCountry?.isoCode ?? "")
        _clientTimeZoneIdentifier = State(initialValue: clientFallbackCountry?.defaultTimeZone ?? "Europe/London")
        _clientCityName = State(initialValue: clientFallbackCountry?.defaultCity ?? "London")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                locationSection(
                    title: "Your Location",
                    countryISOCode: $myCountryISOCode,
                    timeZoneIdentifier: $myTimeZoneIdentifier,
                    timeSelection: $myTimeSelection,
                    side: .my
                )

                locationSection(
                    title: "Client Location",
                    countryISOCode: $clientCountryISOCode,
                    timeZoneIdentifier: $clientTimeZoneIdentifier,
                    timeSelection: $clientTimeSelection,
                    side: .client
                )

                resultSection
            }
            .padding(.vertical, 2)
        }
        .onAppear {
            applyInitialSettingsDefaultIfNeeded()
            initializeTimeSelectionsIfNeeded()
        }
        .onChange(of: myCountryISOCode) { newISOCode in
            guard let country = country(for: newISOCode) else {
                return
            }

            applyCountryDefaults(country, to: .my)
        }
        .onChange(of: clientCountryISOCode) { newISOCode in
            guard let country = country(for: newISOCode) else {
                return
            }

            applyCountryDefaults(country, to: .client)
        }
        .onChange(of: myTimeZoneIdentifier) { newTimeZoneIdentifier in
            applyCityForSelectedTimeZone(newTimeZoneIdentifier, to: .my)
            recalculateFromLastEditedSide()
        }
        .onChange(of: clientTimeZoneIdentifier) { newTimeZoneIdentifier in
            applyCityForSelectedTimeZone(newTimeZoneIdentifier, to: .client)
            recalculateFromLastEditedSide()
        }
        .onChange(of: myTimeSelection) { _ in
            handleTimeSelectionChange(from: .my)
        }
        .onChange(of: clientTimeSelection) { _ in
            handleTimeSelectionChange(from: .client)
        }
    }

    private var sourceInstant: Date {
        makeSourceInstantForToday(from: lastEditedSide) ?? Date()
    }

    private var activeDateRelation: DateRelation {
        timeZoneService.dateRelation(
            from: sourceInstant,
            sourceTimeZoneIdentifier: timeZoneIdentifier(for: lastEditedSide),
            targetDate: sourceInstant,
            targetTimeZoneIdentifier: timeZoneIdentifier(for: targetSide)
        )
    }

    private var resultSection: some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Result")
                    .font(.headline)

                Text(resultSummary)
                    .font(.callout.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)

                Text("Difference: \(timeZoneService.timeDifferenceDescription(from: myTimeZoneIdentifier, to: clientTimeZoneIdentifier))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let activeDayBoundaryNote {
                    Text(activeDayBoundaryNote)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Button {
                    copyResult()
                } label: {
                    Label("Copy result", systemImage: "doc.on.doc")
                }
                .controlSize(.small)
            }
        }
    }

    private var resultSummary: String {
        "\(formattedYourTime) in \(myCityName) = \(formattedClientTime) in \(clientCityName)"
    }

    private var formattedYourTime: String {
        timeZoneService.formatTime(
            sourceInstant,
            in: myTimeZoneIdentifier,
            format: appState.settings.timeFormat
        )
    }

    private var formattedClientTime: String {
        timeZoneService.formatTime(
            sourceInstant,
            in: clientTimeZoneIdentifier,
            format: appState.settings.timeFormat
        )
    }

    private var targetSide: ConverterSide {
        lastEditedSide == .my ? .client : .my
    }

    private var activeDayBoundaryNote: String? {
        let targetName = targetSide == .my ? "Your time" : "Client time"

        switch activeDateRelation {
        case .previousDay:
            return "\(targetName) is previous day"
        case .sameDay:
            return nil
        case .nextDay:
            return "\(targetName) is next day"
        case .differentDate:
            return "\(targetName) is on a different date"
        }
    }

    private func locationSection(
        title: String,
        countryISOCode: Binding<String>,
        timeZoneIdentifier: Binding<String>,
        timeSelection: Binding<Date>,
        side: ConverterSide
    ) -> some View {
        let selectedCountry = country(for: countryISOCode.wrappedValue)
        let timeZones = selectedCountry?.timeZones ?? []

        return SectionCardView {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)

                if countries.isEmpty {
                    Text("Country data unavailable")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        fieldLabel("Country")

                        Picker("Country", selection: countryISOCode) {
                            ForEach(countries) { country in
                                Text(country.countryName)
                                    .tag(country.isoCode)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        fieldLabel("City/time zone")

                        if timeZones.count > 1 {
                            Picker("City/time zone", selection: timeZoneIdentifier) {
                                ForEach(timeZones) { timeZone in
                                    Text(timeZonePickerLabel(for: timeZone))
                                        .lineLimit(1)
                                        .tag(timeZone.identifier)
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else if let timeZone = timeZones.first {
                            Text(timeZonePickerLabel(for: timeZone))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    timeInput(title: side == .my ? "Your time" : "Client time", selection: timeSelection, side: side)
                }
            }
        }
    }

    private func timeInput(title: String, selection: Binding<Date>, side: ConverterSide) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            fieldLabel(title)

            DatePicker(title, selection: selection, displayedComponents: .hourAndMinute)
                .labelsHidden()

            if side == targetSide, let activeDayBoundaryNote {
                Text(activeDayBoundaryNote)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }

    private func makeSourceInstantForToday(from side: ConverterSide) -> Date? {
        let sourceTimeZoneIdentifier = timeZoneIdentifier(for: side)
        let sourceTimeSelection = timeSelection(for: side)

        var sourceCalendar = Calendar(identifier: .gregorian)
        sourceCalendar.timeZone = TimeZone(identifier: sourceTimeZoneIdentifier) ?? .current

        let todayComponents = sourceCalendar.dateComponents([.year, .month, .day], from: Date())
        let selectedTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: sourceTimeSelection)

        guard let year = todayComponents.year,
              let month = todayComponents.month,
              let day = todayComponents.day,
              let hour = selectedTimeComponents.hour,
              let minute = selectedTimeComponents.minute else {
            return nil
        }

        return timeZoneService.makeDate(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            in: sourceTimeZoneIdentifier
        )
    }

    private func applyInitialSettingsDefaultIfNeeded() {
        guard !didApplySettingsDefault else {
            return
        }

        didApplySettingsDefault = true

        if let settingsCountry = countries.first(where: { country in
            country.timeZones.contains { $0.identifier == appState.settings.defaultTimeZoneIdentifier }
        }) {
            myCountryISOCode = settingsCountry.isoCode
            myTimeZoneIdentifier = appState.settings.defaultTimeZoneIdentifier
            myCityName = appState.settings.defaultCity
        } else if let firstCountry = countries.first {
            applyCountryDefaults(firstCountry, to: .my)
        }
    }

    private func initializeTimeSelectionsIfNeeded() {
        guard !didInitializeTimeSelections else {
            return
        }

        didInitializeTimeSelections = true
        setTimeSelections(from: Date())
    }

    private func applyCountryDefaults(_ country: CountryTimeData, to side: ConverterSide) {
        switch side {
        case .my:
            myTimeZoneIdentifier = country.defaultTimeZone
            myCityName = country.defaultCity
        case .client:
            clientTimeZoneIdentifier = country.defaultTimeZone
            clientCityName = country.defaultCity
        }
    }

    private func applyCityForSelectedTimeZone(_ timeZoneIdentifier: String, to side: ConverterSide) {
        let country = side == .my ? country(for: myCountryISOCode) : country(for: clientCountryISOCode)
        guard let timeZone = country?.timeZones.first(where: { $0.identifier == timeZoneIdentifier }) else {
            return
        }

        let cityName = timeZone.majorCities.first ?? country?.defaultCity ?? ""

        switch side {
        case .my:
            myCityName = cityName
        case .client:
            clientCityName = cityName
        }
    }

    private func handleTimeSelectionChange(from side: ConverterSide) {
        guard !isUpdatingProgrammatically else {
            return
        }

        lastEditedSide = side
        updateOppositeTime(from: side)
    }

    private func recalculateFromLastEditedSide() {
        updateOppositeTime(from: lastEditedSide)
    }

    private func updateOppositeTime(from side: ConverterSide) {
        guard let instant = makeSourceInstantForToday(from: side) else {
            return
        }

        isUpdatingProgrammatically = true

        switch side {
        case .my:
            clientTimeSelection = timeSelectionDate(from: instant, in: clientTimeZoneIdentifier)
        case .client:
            myTimeSelection = timeSelectionDate(from: instant, in: myTimeZoneIdentifier)
        }

        DispatchQueue.main.async {
            isUpdatingProgrammatically = false
        }
    }

    private func setTimeSelections(from instant: Date) {
        isUpdatingProgrammatically = true
        myTimeSelection = timeSelectionDate(from: instant, in: myTimeZoneIdentifier)
        clientTimeSelection = timeSelectionDate(from: instant, in: clientTimeZoneIdentifier)

        DispatchQueue.main.async {
            isUpdatingProgrammatically = false
        }
    }

    private func timeSelectionDate(from instant: Date, in timeZoneIdentifier: String) -> Date {
        var displayCalendar = Calendar(identifier: .gregorian)
        displayCalendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .current

        let components = displayCalendar.dateComponents([.hour, .minute], from: instant)
        var localComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        localComponents.hour = components.hour
        localComponents.minute = components.minute

        return Calendar.current.date(from: localComponents) ?? instant
    }

    private func timeSelection(for side: ConverterSide) -> Date {
        side == .my ? myTimeSelection : clientTimeSelection
    }

    private func timeZoneIdentifier(for side: ConverterSide) -> String {
        side == .my ? myTimeZoneIdentifier : clientTimeZoneIdentifier
    }

    private func country(for isoCode: String) -> CountryTimeData? {
        countries.first { $0.isoCode == isoCode }
    }

    private func timeZonePickerLabel(for timeZone: CountryTimeZone) -> String {
        let cities = timeZone.majorCities.prefix(2).joined(separator: ", ")

        guard !cities.isEmpty else {
            return timeZone.label
        }

        return "\(timeZone.label) - \(cities)"
    }

    private func copyResult() {
        let text = activeDayBoundaryNote.map { "\(resultSummary) (\($0))" } ?? resultSummary
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

private enum ConverterSide {
    case my
    case client
}
