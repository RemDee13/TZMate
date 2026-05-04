import AppKit
import SwiftUI

struct ContactsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var formContext: ContactFormContext?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            searchField
            content
        }
        .sheet(item: $formContext) { context in
            ContactFormView(contact: context.contact) { contact in
                if context.contact == nil {
                    appState.addContact(contact)
                } else {
                    appState.updateContact(contact)
                }
            }
        }
    }

    private var header: some View {
        SectionCardView {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Contacts")
                        .font(.headline)

                    Text("\(appState.contacts.count) saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    formContext = ContactFormContext(contact: nil)
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search contacts", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var content: some View {
        if appState.contacts.isEmpty {
            emptyState(
                title: "No contacts yet.",
                message: "Add your first client to see their local time here."
            )
        } else if filteredContacts.isEmpty {
            emptyState(
                title: "No contacts found.",
                message: "Try a different name, country, city, or phone code."
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredContacts) { contact in
                        ContactRowView(
                            contact: contact,
                            settings: appState.settings,
                            onEdit: {
                                formContext = ContactFormContext(contact: contact)
                            },
                            onDelete: {
                                appState.deleteContact(id: contact.id)
                            },
                            onToggleFavorite: {
                                appState.toggleFavorite(for: contact.id)
                            }
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var filteredContacts: [Contact] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return appState.contacts
        }

        return appState.contacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(query)
                || contact.countryName.localizedCaseInsensitiveContains(query)
                || contact.cityName.localizedCaseInsensitiveContains(query)
                || (contact.phoneCode?.localizedCaseInsensitiveContains(query) ?? false)
                || (contact.note?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    private func emptyState(title: String, message: String) -> some View {
        SectionCardView {
            VStack(spacing: 10) {
                Spacer()

                Image(systemName: "person.2")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)

                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct ContactFormContext: Identifiable {
    let id = UUID()
    let contact: Contact?
}
