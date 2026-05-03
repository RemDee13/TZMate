import AppKit
import SwiftUI

struct TimeConverterView: View {
    @EnvironmentObject private var appState: AppState

    private let countries: [CountryTimeData]
    private let timeZoneService = TimeZoneService()

    @State private var direction: ConverterDirection = .myTimeToClientTime
    @State private var myCountryISOCode: String
    @State private var myTimeZoneIdentifier: String
    @State private var myCityName: String
    @State private var myDateTime = Date()
    @State private var clientCountryISOCode: String
    @State private var clientTimeZoneIdentifier: String
    @State private var clientCityName: String
    @State private var clientDateTime = Date()
    @State private var didApplySettingsDefault = false

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
        VStack(alignment: .leading, spacing: 12) {
            Picker("Direction", selection: $direction) {
                ForEach(ConverterDirection.allCases) { direction in
                    Text(direction.title)
                        .tag(direction)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    converterSection(
                        title: "My Time",
                        countryISOCode: $myCountryISOCode,
                        timeZoneIdentifier: $myTimeZoneIdentifier,
                        cityName: $myCityName,
                        dateTime: $myDateTime,
                        isEditable: direction == .myTimeToClientTime,
                        resultDate: direction == .clientTimeToMyTime ? convertedInstant : nil
                    )

                    converterSection(
                        title: "Client Time",
                        countryISOCode: $clientCountryISOCode,
                        timeZoneIdentifier: $clientTimeZoneIdentifier,
                        cityName: $clientCityName,
                        dateTime: $clientDateTime,
                        isEditable: direction == .clientTimeToMyTime,
                        resultDate: direction == .myTimeToClientTime ? convertedInstant : nil
                    )

                    resultSection
                }
                .padding(.vertical, 2)
            }
        }
        .onAppear {
            applyInitialSettingsDefaultIfNeeded()
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
        }
        .onChange(of: clientTimeZoneIdentifier) { newTimeZoneIdentifier in
            applyCityForSelectedTimeZone(newTimeZoneIdentifier, to: .client)
        }
    }

    private var sourceTimeZoneIdentifier: String {
        direction == .myTimeToClientTime ? myTimeZoneIdentifier : clientTimeZoneIdentifier
    }

    private var targetTimeZoneIdentifier: String {
        direction == .myTimeToClientTime ? clientTimeZoneIdentifier : myTimeZoneIdentifier
    }

    private var sourceDateTime: Date {
        direction == .myTimeToClientTime ? myDateTime : clientDateTime
    }

    private var sourceCityName: String {
        direction == .myTimeToClientTime ? myCityName : clientCityName
    }

    private var targetCityName: String {
        direction == .myTimeToClientTime ? clientCityName : myCityName
    }

    private var convertedInstant: Date {
        timeZoneService.convert(
            date: sourceDateTime,
            from: sourceTimeZoneIdentifier,
            to: targetTimeZoneIdentifier
        )
    }

    private var dateRelation: DateRelation {
        timeZoneService.dateRelation(
            from: convertedInstant,
            sourceTimeZoneIdentifier: sourceTimeZoneIdentifier,
            targetDate: convertedInstant,
            targetTimeZoneIdentifier: targetTimeZoneIdentifier
        )
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Result")
                .font(.headline)

            Text(resultSummary)
                .font(.callout.weight(.semibold))
                .textSelection(.enabled)

            HStack(spacing: 8) {
                Text("Difference: \(timeZoneService.timeDifferenceDescription(from: sourceTimeZoneIdentifier, to: targetTimeZoneIdentifier))")

                if dateRelation != .sameDay {
                    Text(dateRelation.displayName)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Button {
                copyResult()
            } label: {
                Label("Copy result", systemImage: "doc.on.doc")
            }
            .controlSize(.small)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var resultSummary: String {
        let sourceTime = timeZoneService.formatTime(
            convertedInstant,
            in: sourceTimeZoneIdentifier,
            format: appState.settings.timeFormat
        )
        let targetTime = timeZoneService.formatTime(
            convertedInstant,
            in: targetTimeZoneIdentifier,
            format: appState.settings.timeFormat
        )

        guard dateRelation != .sameDay else {
            return "\(sourceTime) in \(sourceCityName) = \(targetTime) in \(targetCityName)"
        }

        let sourceDate = timeZoneService.formatDate(convertedInstant, in: sourceTimeZoneIdentifier)
        let targetDate = timeZoneService.formatDate(convertedInstant, in: targetTimeZoneIdentifier)
        return "\(sourceTime) in \(sourceCityName) on \(sourceDate) = \(targetTime) in \(targetCityName) on \(targetDate)"
    }

    private func converterSection(
        title: String,
        countryISOCode: Binding<String>,
        timeZoneIdentifier: Binding<String>,
        cityName: Binding<String>,
        dateTime: Binding<Date>,
        isEditable: Bool,
        resultDate: Date?
    ) -> some View {
        let selectedCountry = country(for: countryISOCode.wrappedValue)
        let timeZones = selectedCountry?.timeZones ?? []

        return VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            if countries.isEmpty {
                Text("Country data unavailable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Picker("Country", selection: countryISOCode) {
                    ForEach(countries) { country in
                        Text(country.countryName)
                            .tag(country.isoCode)
                    }
                }

                if timeZones.count > 1 {
                    Picker("City/time zone", selection: timeZoneIdentifier) {
                        ForEach(timeZones) { timeZone in
                            Text(timeZonePickerLabel(for: timeZone))
                                .tag(timeZone.identifier)
                        }
                    }
                } else if let timeZone = timeZones.first {
                    LabeledContent("City/time zone") {
                        Text(timeZonePickerLabel(for: timeZone))
                            .foregroundStyle(.secondary)
                    }
                }

                if isEditable {
                    DatePicker("Date", selection: dateTime, displayedComponents: .date)
                    DatePicker("Time", selection: dateTime, displayedComponents: .hourAndMinute)
                } else if let resultDate {
                    convertedTimeDisplay(for: resultDate, timeZoneIdentifier: timeZoneIdentifier.wrappedValue)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.32))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func convertedTimeDisplay(for date: Date, timeZoneIdentifier: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timeZoneService.formatTime(date, in: timeZoneIdentifier, format: appState.settings.timeFormat))
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .monospacedDigit()

            Text(timeZoneService.formatDate(date, in: timeZoneIdentifier))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
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
        } else if let thailand = countries.first(where: { $0.isoCode == "TH" }) {
            applyCountryDefaults(thailand, to: .my)
        }
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

    private func country(for isoCode: String) -> CountryTimeData? {
        countries.first { $0.isoCode == isoCode }
    }

    private func timeZonePickerLabel(for timeZone: CountryTimeZone) -> String {
        let cities = timeZone.majorCities.prefix(3).joined(separator: ", ")

        guard !cities.isEmpty else {
            return timeZone.label
        }

        return "\(timeZone.label) - \(cities)"
    }

    private func copyResult() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resultSummary, forType: .string)
    }
}

private enum ConverterDirection: String, CaseIterable, Identifiable {
    case myTimeToClientTime
    case clientTimeToMyTime

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .myTimeToClientTime:
            return "My time -> Client"
        case .clientTimeToMyTime:
            return "Client -> My time"
        }
    }
}

private enum ConverterSide {
    case my
    case client
}
