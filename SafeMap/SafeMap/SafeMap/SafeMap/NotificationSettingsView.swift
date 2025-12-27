import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager

    // ANA TOGGLE
    @State private var notificationsEnabled = true

    // ALT TOGGLE'LAR
    @State private var nearbyAlerts = true
    @State private var trustedAlerts = true

    var body: some View {
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

            ScrollView {
                VStack(spacing: 24) {

                    // HEADER
                    ZStack {
                        Text(lm.text("notification_settings_title"))
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
                    Image(systemName: "bell.circle.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    // MAIN CARD
                    SettingsCard {
                        VStack(spacing: 16) {

                            // ANA BİLDİRİM TOGGLE
                            Toggle(isOn: $notificationsEnabled) {
                                Text(lm.text("notification_main_toggle"))
                                    .font(.headline)
                            }

                            Divider()

                            // ALT AYARLAR
                            VStack(spacing: 12) {

                                Toggle(
                                    lm.text("notification_nearby_risks"),
                                    isOn: $nearbyAlerts
                                )
                                .disabled(!notificationsEnabled)
                                .opacity(notificationsEnabled ? 1 : 0.5)

                                Toggle(
                                    lm.text("notification_trusted_alerts"),
                                    isOn: $trustedAlerts
                                )
                                .disabled(!notificationsEnabled)
                                .opacity(notificationsEnabled ? 1 : 0.5)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // INFO
                    Text(lm.text("notification_info"))
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

