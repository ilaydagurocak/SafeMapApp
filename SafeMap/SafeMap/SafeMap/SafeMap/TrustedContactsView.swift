import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Contacts
import Foundation

struct TrustedContact: Identifiable {
    let id: String
    let name: String
    let phone: String
}


struct TrustedContactsView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager
    @EnvironmentObject var auth: AuthManager

    @State private var contacts: [TrustedContact] = []

    @State private var showContactPicker = false
    @State private var showPermissionAlert = false

    private let db = Firestore.firestore()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.78, green: 0.90, blue: 1.0),
                    Color(red: 0.35, green: 0.65, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // HEADER
                    ZStack {
                        Text(lm.text("trusted_contacts_title"))
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // INFO
                    Text(lm.text("trusted_contacts_info"))
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // LIST
                    SettingsCard {
                        ForEach(contacts) { contact in
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(contact.name)
                                        .font(.headline)

                                    Text(contact.phone)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()
                            }
                            .padding(.vertical, 10)

                            if contact.id != contacts.last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal)

                    // ADD BUTTON
                    Button {
                        requestContactsPermission()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text(lm.text("trusted_contacts_add"))
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(14)
                        .shadow(radius: 6)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)

        // 📱 CONTACT PICKER
        .sheet(isPresented: $showContactPicker) {
            ContactPicker { contact in
                saveContact(contact)
            }
        }

        // ⚠️ PERMISSION ALERT
        .alert(lm.text("permission_title"), isPresented: $showPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(lm.text("permission_contacts"))
        }

        .onAppear {
            fetchContacts()
        }
    }

    // MARK: - PERMISSION
    private func requestContactsPermission() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    showContactPicker = true
                } else {
                    showPermissionAlert = true
                }
            }
        }
    }

    // MARK: - SAVE
    private func saveContact(_ contact: CNContact) {
        guard
            let uid = Auth.auth().currentUser?.uid,
            let phone = contact.phoneNumbers.first?.value.stringValue
        else { return }

        let name = "\(contact.givenName) \(contact.familyName)"

        let data: [String: Any] = [
            "name": name,
            "phone": phone,
            "createdAt": Timestamp()
        ]

        db.collection("users")
            .document(uid)
            .collection("trustedContacts")
            .addDocument(data: data) { _ in
                fetchContacts()
            }
    }

    // MARK: - FETCH
    private func fetchContacts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users")
            .document(uid)
            .collection("trustedContacts")
            .order(by: "createdAt", descending: false)
            .getDocuments { snap, _ in
                contacts = snap?.documents.map {
                    TrustedContact(
                        id: $0.documentID,
                        name: $0["name"] as? String ?? "",
                        phone: $0["phone"] as? String ?? ""
                    )
                } ?? []
            }
    }
}

