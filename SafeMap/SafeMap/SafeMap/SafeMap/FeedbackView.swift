import SwiftUI
import MessageUI

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager

    @State private var message = ""

    // 📬 Mail state
    @State private var showMail = false
    @State private var showMailError = false
    @State private var showSuccess = false   // ✅ başarı alerti

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
                        Text(lm.text("feedback_title"))
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

                    // ICON
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    // TEXT EDITOR
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(lm.text("feedback_description"))
                                .font(.headline)

                            TextEditor(text: $message)
                                .frame(height: 160)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    // SEND BUTTON
                    Button {
                        sendFeedback()
                    } label: {
                        Text(lm.text("feedback_send_button"))
                            .font(.headline)
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

        // 📬 MAIL SHEET
        .sheet(isPresented: $showMail) {
            MailView(
                subject: "SafeMap Feedback",
                recipients: ["gurocakilayda2001@gmail.com"],
                body: message,              // ✅ feedback birebir mail içinde
                onSent: {
                    message = ""            // ✅ sayfa reset
                    showSuccess = true      // ✅ başarı mesajı
                }
            )
        }

        // ❌ MAIL ERROR
        .alert(lm.text("error_title"), isPresented: $showMailError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(lm.text("feedback_mail_error"))
        }

        // ✅ SUCCESS ALERT
        .alert(lm.text("feedback_success_title"), isPresented: $showSuccess) {
            Button("OK") {}
        } message: {
            Text(lm.text("feedback_success_message"))
        }
    }

    // MARK: - SEND FEEDBACK
    private func sendFeedback() {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        if MFMailComposeViewController.canSendMail() {
            showMail = true
        } else {
            showMailError = true
        }
    }
}


struct MailView: UIViewControllerRepresentable {

    let subject: String
    let recipients: [String]
    let body: String
    let onSent: () -> Void   // ✅ callback

    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setToRecipients(recipients)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, onSent: onSent)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        let onSent: () -> Void

        init(dismiss: DismissAction, onSent: @escaping () -> Void) {
            self.dismiss = dismiss
            self.onSent = onSent
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            if result == .sent {
                onSent()   // ✅ sadece gönderilince
            }
            dismiss()
        }
    }
}

