import SwiftUI
import FirebaseAuth

struct PhoneLoginView: View {

    // 🔗 DIŞ STATE
    @Binding var isLoggedIn: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager
    @EnvironmentObject var auth: AuthManager   // 🔥 AUTH MANAGER

    // 🧾 FORM STATE
    @State private var email = ""
    @State private var password = ""
    @State private var goRegister = false
    @State private var goForgotPassword = false

    // ⚠️ ERROR & LOADING
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                // BACKGROUND
                LinearGradient(
                    colors: [
                        Color(red: 0.78, green: 0.90, blue: 1.0),
                        Color(red: 0.35, green: 0.65, blue: 0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {

                    // 🔙 CUSTOM BACK
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }

                    Spacer(minLength: 10)

                    // 🪽 ANGEL LOGO
                    Image("angel_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .shadow(color: .white.opacity(0.5), radius: 16)

                    // APP NAME
                    Text("SafeMap")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)

                    // SUBTITLE
                    Text(lm.text("login_subtitle"))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)

                    // LOGIN CARD
                    GlassCard {
                        VStack(spacing: 18) {

                            // EMAIL
                            TextField(
                                lm.text("login_email_placeholder"),
                                text: $email
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(14)

                            // PASSWORD
                            SecureField(
                                lm.text("login_password_placeholder"),
                                text: $password
                            )
                            .padding()
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(14)

                            // 🔑 FORGOT PASSWORD (SAĞ ALT)
                            HStack {
                                Spacer()
                                Button {
                                    goForgotPassword = true
                                } label: {
                                    Text(lm.text("forgot_password"))
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }

                            // LOGIN BUTTON
                            GradientButton(
                                title: isLoading
                                ? lm.text("loading")
                                : lm.text("button_login")
                            ) {
                                login()
                            }
                            .disabled(isLoading)
                        }
                    }

                    // REGISTER
                    Button {
                        goRegister = true
                    } label: {
                        Text(lm.text("login_no_account"))
                            .font(.footnote)
                            .foregroundColor(.white)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)

            // ➡️ REGISTER
            .navigationDestination(isPresented: $goRegister) {
                PhoneRegisterView(isLoggedIn: $isLoggedIn)
            }

            // ➡️ FORGOT PASSWORD
            .navigationDestination(isPresented: $goForgotPassword) {
                ForgotPasswordView()
            }
        }

        // ❌ ERROR ALERT
        .alert(lm.text("error_title"), isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - FIREBASE LOGIN
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = lm.text("error_fill_all_fields")
            showError = true
            return
        }

        isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }

                // ✅ SESSION AÇIK KALIR
                auth.isLoggedIn = true
                isLoggedIn = true
            }
        }
    }
}

