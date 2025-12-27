import SwiftUI

struct AboutSafeMapView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager

    var body: some View {
        ZStack {
            // BACKGROUND (SafeMap theme)
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
                        Text(lm.text("about_title"))
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

                    // APP ICON
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 90))
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    // ABOUT CARD
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {

                            Text(lm.text("about_what_title"))
                                .font(.headline)

                            Text(lm.text("about_description"))
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    // COMMUNITY RULES CARD
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {

                            Text(lm.text("community_rules_title"))
                                .font(.headline)

                            rule(
                                lm.text("rule_respect_title"),
                                lm.text("rule_respect_desc")
                            )

                            rule(
                                lm.text("rule_truth_title"),
                                lm.text("rule_truth_desc")
                            )

                            rule(
                                lm.text("rule_privacy_title"),
                                lm.text("rule_privacy_desc")
                            )

                            rule(
                                lm.text("rule_protect_title"),
                                lm.text("rule_protect_desc")
                            )

                            Text(lm.text("rules_warning"))
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Rule Item
    @ViewBuilder
    func rule(_ title: String, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("• \(title)")
                .font(.subheadline)
                .bold()

            Text(description)
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

