import SwiftUI
import FirebaseAuth

struct PhoneRegisterView: View {

    // 🔗 DIŞ STATE
    @Binding var isLoggedIn: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager
    @EnvironmentObject var auth: AuthManager

    // 🧾 FORM STATE
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""

    // ⚠️ ERROR STATE
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isLoading = false

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

            VStack(spacing: 22) {

                // 🔙 BACK
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Spacer()
                }

                Image("angel_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text("SafeMap")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)

                Text(lm.text("register_title"))
                    .foregroundColor(.white.opacity(0.9))

                GlassCard {
                    VStack(spacing: 18) {

                        TextField(
                            lm.text("register_fullname_placeholder"),
                            text: $fullName
                        )
                        .padding()
                        .background(Color.white)
                        .cornerRadius(14)

                        TextField(
                            lm.text("register_email_placeholder"),
                            text: $email
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(14)

                        SecureField(
                            lm.text("register_password_placeholder"),
                            text: $password
                        )
                        .padding()
                        .background(Color.white)
                        .cornerRadius(14)

                        GradientButton(
                            title: isLoading
                            ? lm.text("loading")
                            : lm.text("button_register_continue")
                        ) {
                            register()
                        }
                        .disabled(isLoading)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .alert(lm.text("error_title"), isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - REGISTER
    private func register() {
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = lm.text("error_fill_all_fields")
            showError = true
            return
        }

        isLoading = true

        auth.register(
            email: email,
            password: password,
            fullName: fullName
        ) { success, error in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    isLoggedIn = true
                } else {
                    errorMessage = error
                    showError = true
                }
            }
        }
    }
}

