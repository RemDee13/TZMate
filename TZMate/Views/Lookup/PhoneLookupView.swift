import SwiftUI

struct PhoneLookupView: View {
    @EnvironmentObject private var appState: AppState

    private let countries: [CountryTimeData]
    private let countryDataService: CountryDataService
    private let timeZoneService = TimeZoneService()

    @State private var query = ""
    @State private var result: LookupSearchResult?

    init(countryDataService: CountryDataService = CountryDataService()) {
        self.countryDataService = countryDataService
        countries = countryDataService.getAllCountries()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            lookupInput
            resultContent
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Phone Lookup")
                .font(.headline)

            Text("Find countries and local time from a phone code or country name.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var lookupInput: some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    TextField("+49, +1 212, Japan, Germany", text: $query)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(runLookup)

                    Button {
                        runLookup()
                    } label: {
                        Label("Lookup", systemImage: "magnifyingglass")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(trimmedQuery.isEmpty)
                }

                Text("Search by phone code or country name.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var resultContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let result {
                    resultView(result)
                } else {
                    SectionCardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "magnifyingglass.circle")
                                .font(.title2)
                                .foregroundStyle(.secondary)

                            Text("Enter a phone code or country name to see matching countries, time zones, and current local time.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 1)
        }
    }

    @ViewBuilder
    private func resultView(_ result: LookupSearchResult) -> some View {
        switch result {
        case .phone(let phoneResult):
            phoneResultView(phoneResult)
        case .countryName(_, let countries):
            countryNameResultView(countries)
        }
    }

    @ViewBuilder
    private func phoneResultView(_ result: PhoneCodeLookupResult) -> some View {
        switch result {
        case .noMatch:
            SectionCardView {
                Text("No country found for this phone code.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        case .singleCountrySingleTimeZone(let country):
            countryCard(country, showsAllTimeZones: false)
        case .singleCountryMultipleTimeZones(let country):
            countryCard(country, showsAllTimeZones: true)
        case .multipleCountries(let countries):
            VStack(alignment: .leading, spacing: 10) {
                SectionCardView {
                    Text("This phone code is used by multiple countries.")
                        .font(.callout.weight(.medium))
                }

                ForEach(countries) { country in
                    countryCard(country, showsAllTimeZones: country.timeZones.count > 1)
                }
            }
        }
    }

    @ViewBuilder
    private func countryNameResultView(_ countries: [CountryTimeData]) -> some View {
        if countries.isEmpty {
            SectionCardView {
                Text("No country found.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(countries) { country in
                    countryCard(country, showsAllTimeZones: country.timeZones.count > 1)
                }
            }
        }
    }

    private func countryCard(_ country: CountryTimeData, showsAllTimeZones: Bool) -> some View {
        SectionCardView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(country.countryName)
                            .font(.headline)

                        Text("\(country.isoCode) · \(country.phoneCode) · \(country.defaultCity)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if country.timeZones.count > 1 {
                        Text(timeZoneService.timeRangeDescription(for: country.timeZones, format: appState.settings.timeFormat))
                            .font(.callout.weight(.semibold))
                            .monospacedDigit()
                    }
                }

                if showsAllTimeZones {
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(country.timeZones) { timeZone in
                            timeZoneRow(timeZone)
                        }
                    }
                } else if let timeZone = country.timeZones.first {
                    singleTimeZoneDetail(timeZone)
                }
            }
        }
    }

    private func singleTimeZoneDetail(_ timeZone: CountryTimeZone) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(timeZoneService.formatTime(Date(), in: timeZone.identifier, format: appState.settings.timeFormat))
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .monospacedDigit()

                Spacer()

                Text(timeZone.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(timeZone.identifier)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func timeZoneRow(_ timeZone: CountryTimeZone) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(timeZone.majorCities.prefix(3).joined(separator: ", "))
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)

                Text("\(timeZone.label) · \(timeZone.identifier)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(timeZoneService.formatTime(Date(), in: timeZone.identifier, format: appState.settings.timeFormat))
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func runLookup() {
        guard !trimmedQuery.isEmpty else {
            result = nil
            return
        }

        if shouldSearchByCountryName(trimmedQuery) {
            result = .countryName(query: trimmedQuery, countries: countryDataService.searchCountries(trimmedQuery))
        } else {
            result = .phone(PhoneCodeService(countries: countries).lookup(trimmedQuery))
        }
    }

    private func shouldSearchByCountryName(_ value: String) -> Bool {
        let hasLetters = value.rangeOfCharacter(from: .letters) != nil

        if hasLetters {
            return true
        }

        let digitCount = value.filter(\.isNumber).count
        return digitCount == 0 && !value.hasPrefix("+")
    }
}

private enum LookupSearchResult: Equatable {
    case phone(PhoneCodeLookupResult)
    case countryName(query: String, countries: [CountryTimeData])
}
