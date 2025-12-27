import SwiftUI

struct ContentView: View {

    // 🔥 FIREBASE AUTH STATE
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var lm: LocalizationManager

    @State private var goLogin = false
    @State private var goRegister = false

    var body: some View {
        NavigationStack {

            // 🔐 OTURUM AÇIKSA DİREKT HOME
            if auth.isLoggedIn {
                HomeView(isLoggedIn: $auth.isLoggedIn)
            } else {

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

                    VStack(spacing: 24) {

                        Spacer()

                        // 🕊️ ANGEL LOGO
                        Image("angel_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)

                        // APP NAME
                        Text("SafeMap")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)

                        // SUBTITLE
                        Text(lm.text("home_subtitle"))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)

                        // LOGIN BUTTON
                        Button {
                            goLogin = true
                        } label: {
                            Text(lm.text("button_login"))
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                                .shadow(radius: 6)
                        }
                        .padding(.horizontal)

                        // REGISTER BUTTON
                        Button {
                            goRegister = true
                        } label: {
                            Text(lm.text("button_register"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.95))
                                .cornerRadius(18)
                                .shadow(radius: 6)
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                }
                // NAVIGATION
                .navigationDestination(isPresented: $goLogin) {
                    PhoneLoginView(isLoggedIn: $auth.isLoggedIn)
                }
                .navigationDestination(isPresented: $goRegister) {
                    PhoneRegisterView(isLoggedIn: $auth.isLoggedIn)
                }
            }
        }
    }
}

