import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager

    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {

            // 🌈 BACKGROUND (aynı tema)
            LinearGradient(
                colors: [
                    Color(red: 0.78, green: 0.90, blue: 1.0),
                    Color(red: 0.35, green: 0.65, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                // 🔝 HEADER
                ZStack {
                    Text(lm.text("forgot_password_title"))
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer(minLength: 20)

                // 🔐 ICON
                Image(systemName: "lock.rotation")
                    .font(.system(size: 80))
                    .foregroundColor(.white)

                Text(lm.text("forgot_password_description"))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // 📋 FORM
                GlassCard {
                    VStack(spacing: 16) {

                        TextField(
                            lm.text("login_email_placeholder"),
                            text: $email
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(14)

                        GradientButton(
                            title: isLoading
                            ? lm.text("loading")
                            : lm.text("forgot_password_send")
                        ) {
                            sendResetMail()
                        }
                        .disabled(isLoading)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)

        // ✅ SUCCESS
        .alert(lm.text("forgot_password_success_title"), isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(lm.text("forgot_password_success_message"))
        }

        // ❌ ERROR
        .alert(lm.text("error_title"), isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - FIREBASE RESET
    private func sendResetMail() {
        guard !email.isEmpty else {
            errorMessage = lm.text("error_fill_all_fields")
            showError = true
            return
        }

        isLoading = true

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else {
                    showSuccess = true
                }
            }
        }
    }
}

