import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager
    @EnvironmentObject var auth: AuthManager

    // FORM STATE
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var age: String = ""
    @State private var gender: Gender = .female

    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let db = Firestore.firestore()

    var body: some View {
        ZStack {

            //  BACKGROUND
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

                    // 🔝 HEADER
                    ZStack {
                        Text(lm.text("edit_profile_title"))
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

                    // 👤 ICON
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.white)

                    // 📋 FORM
                    SettingsCard {
                        VStack(spacing: 16) {

                            // FULL NAME
                            formField(
                                title: lm.text("edit_profile_fullname"),
                                content: TextField(
                                    lm.text("edit_profile_fullname"),
                                    text: $fullName
                                )
                            )

                            // EMAIL (READ ONLY)
                            formField(
                                title: lm.text("edit_profile_email"),
                                content: TextField(
                                    lm.text("edit_profile_email"),
                                    text: $email
                                )
                                .disabled(true)
                            )

                            // AGE
                            formField(
                                title: lm.text("edit_profile_age"),
                                content: TextField(
                                    lm.text("edit_profile_age"),
                                    text: $age
                                )
                                .keyboardType(.numberPad)
                            )

                            // GENDER
                            VStack(alignment: .leading, spacing: 6) {
                                Text(lm.text("edit_profile_gender"))
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                Picker(
                                    lm.text("edit_profile_gender"),
                                    selection: $gender
                                ) {
                                    ForEach(Gender.allCases) { g in
                                        Text(g.title(lm: lm)).tag(g)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 💾 SAVE
                    Button {
                        saveProfile()
                    } label: {
                        Text(isLoading ? lm.text("loading") : lm.text("save"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(14)
                            .shadow(radius: 6)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)

        // 🔄 LOAD USER
        .onAppear {
            loadUser()
        }

        // ❌ ERROR
        .alert(lm.text("error_title"), isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - LOAD USER
    private func loadUser() {
        guard let user = auth.user else { return }

        fullName = user.fullName
        email = user.email

        db.collection("users").document(user.id).getDocument { snap, _ in
            let data = snap?.data() ?? [:]
            age = data["age"] as? String ?? ""
            if let genderRaw = data["gender"] as? String,
               let g = Gender(rawValue: genderRaw) {
                gender = g
            }
        }
    }

    // MARK: - SAVE
    private func saveProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        isLoading = true

        let data: [String: Any] = [
            "fullName": fullName,
            "age": age,
            "gender": gender.rawValue
        ]

        db.collection("users").document(uid).updateData(data) { error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }

                // 🔄 LOCAL USER UPDATE
                auth.user = AppUser(
                    id: uid,
                    fullName: fullName,
                    email: email
                )

                dismiss()
            }
        }
    }

    // MARK: - FIELD
    @ViewBuilder
    func formField<Content: View>(
        title: String,
        content: Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            content
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

enum Gender: String, CaseIterable, Identifiable {
    case female
    case male

    var id: String { rawValue }

    func title(lm: LocalizationManager) -> String {
        switch self {
        case .female:
            return lm.text("gender_female")
        case .male:
            return lm.text("gender_male")
        }
    }
}

