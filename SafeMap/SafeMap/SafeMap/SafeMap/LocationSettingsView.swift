import SwiftUI
import CoreLocation

struct LocationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager

    @StateObject private var locationManager = LocationPermissionManager()

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
                        Text(lm.text("location_settings_title"))
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
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    // INFO CARD (AYNI UI)
                    SettingsCard {
                        VStack(spacing: 12) {

                            Text(lm.text("location_settings_info"))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)

                            // 🔵 STATUS TEXT (EK)
                            Text(
                                locationManager.isAuthorized
                                ? lm.text("location_status_on")
                                : lm.text("location_status_off")
                            )
                            .font(.footnote)
                            .foregroundColor(
                                locationManager.isAuthorized ? .green : .red
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)

                    // OPEN SETTINGS BUTTON
                    Button {
                        handleLocationAction()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                            Text(lm.text("location_settings_open"))
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
        .onAppear {
            locationManager.checkStatus()
        }
    }

    // MARK: - ACTION
    private func handleLocationAction() {
        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .notDetermined:
            // 🟢 İlk kez → popup
            locationManager.requestPermission()

        case .denied, .restricted:
            // 🔴 Reddedilmiş → Ayarlar > Konum
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }

        case .authorizedWhenInUse, .authorizedAlways:
            // 🟢 Zaten açık → Ayarlar’a gitsin
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }

        @unknown default:
            break
        }
    }
}

