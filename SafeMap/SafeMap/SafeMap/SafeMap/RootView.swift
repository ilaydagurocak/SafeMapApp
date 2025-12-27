import SwiftUI

struct RootView: View {

    @EnvironmentObject var auth: AuthManager

    var body: some View {
        Group {
            if auth.isLoggedIn {
                HomeView(isLoggedIn: .constant(true))
            } else {
                ContentView()
            }
        }
    }
}

