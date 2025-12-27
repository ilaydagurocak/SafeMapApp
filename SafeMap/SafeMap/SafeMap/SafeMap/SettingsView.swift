import SwiftUI

struct SettingsView: View {

    @Binding var isLoggedIn: Bool

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager
    @EnvironmentObject var auth: AuthManager

    // ALERT STATE
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

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

                    // 🔝 HEADER
                    ZStack {
                        Text(lm.text("settings_title"))
                            .font(.headline)
                            .foregroundColor(.white)

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
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // 👤 PROFILE
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 90))
                            .foregroundColor(.white)

                        Text(auth.user?.fullName.isEmpty == false
                             ? auth.user!.fullName
                             : lm.text("loading"))
                            .font(.title2.bold())
                            .foregroundColor(.white)

                    }

                    // ⚙️ MAIN SETTINGS
                    SettingsCard {

                        navRow(
                            icon: "pencil",
                            title: lm.text("settings_edit_profile"),
                            destination: EditProfileView()
                        )

                        Divider()

                        navRow(
                            icon: "person.2.fill",
                            title: lm.text("settings_trusted_contacts"),
                            destination: TrustedContactsView()
                        )

                        Divider()

                        navRow(
                            icon: "location.fill",
                            title: lm.text("settings_location"),
                            destination: LocationSettingsView()
                        )

                        Divider()

                        navRow(
                            icon: "bell.fill",
                            title: lm.text("settings_notifications"),
                            destination: NotificationSettingsView()
                        )

                        Divider()

                        navRow(
                            icon: "globe",
                            title: lm.text("settings_language"),
                            destination: LanguageView()
                        )

                        Divider()

                        navRow(
                            icon: "text.bubble",
                            title: lm.text("settings_my_reports"),
                            destination: UserReportsView()
                        )

                        Divider()

                        navRow(
                            icon: "info.circle.fill",
                            title: lm.text("settings_about"),
                            destination: AboutSafeMapView()
                        )

                        Divider()

                        navRow(
                            icon: "envelope.fill",
                            title: lm.text("settings_feedback"),
                            destination: FeedbackView()
                        )
                    }
                    .padding(.horizontal)

                    // 🔐 ACCOUNT
                    SettingsCard {

                        // 🚪 LOGOUT
                        Button {
                            showLogoutAlert = true
                        } label: {
                            SettingsRow(
                                icon: "arrow.backward.square",
                                title: lm.text("settings_logout"),
                                iconColor: .red,
                                showChevron: false
                            )
                        }

                        Divider()

                        // 🗑 DELETE (UI)
                        Button {
                            showDeleteAlert = true
                        } label: {
                            SettingsRow(
                                icon: "trash",
                                title: lm.text("settings_delete_account"),
                                iconColor: .red,
                                showChevron: false
                            )
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)

        // 🔄 USER GARANTİ
        .onAppear {
            auth.checkSession()
        }

        // 🔴 LOGOUT ALERT
        .alert(lm.text("logout_title"), isPresented: $showLogoutAlert) {
            Button(lm.text("logout_confirm"), role: .destructive) {
                auth.logout()
                isLoggedIn = false
                dismiss()
            }
            Button(lm.text("cancel"), role: .cancel) {}
        } message: {
            Text(lm.text("logout_message"))
        }

        // 🔴 DELETE ALERT (LOGIC SONRA)
        .alert(lm.text("delete_title"), isPresented: $showDeleteAlert) {
            Button(lm.text("delete_confirm"), role: .destructive) {
                auth.logout()
                isLoggedIn = false
                dismiss()
            }
            Button(lm.text("cancel"), role: .cancel) {}
        } message: {
            Text(lm.text("delete_message"))
        }
    }

    // MARK: - NAV ROW
    func navRow<Destination: View>(
        icon: String,
        title: String,
        destination: Destination
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            SettingsRow(icon: icon, title: title)
        }
    }
}



// MARK: - CARD
struct SettingsCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 6)
    }
}

// MARK: - ROW
struct SettingsRow: View {
    let icon: String
    let title: String
    var iconColor: Color = .blue
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 22)

            Text(title)
                .foregroundColor(.black)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 12)
    }
}

