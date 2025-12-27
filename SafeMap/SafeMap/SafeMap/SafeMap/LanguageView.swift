import SwiftUI

struct LanguageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager

    let languages: [(code: String, name: String, flag: String)] = [
        ("tr", "Türkçe", "🇹🇷"),
        ("en", "English", "🇬🇧"),
        ("fr", "Français", "🇫🇷"),
        ("de", "Deutsch", "🇩🇪"),
        ("it", "Italiano", "🇮🇹"),
        ("es", "Español", "🇪🇸"),
        ("pt", "Português", "🇵🇹"),
        ("nl", "Nederlands", "🇳🇱"),
        ("sv", "Svenska", "🇸🇪"),
        ("da", "Dansk", "🇩🇰"),
        ("fi", "Suomi", "🇫🇮"),
        ("he", "עברית", "🇮🇱"),
        ("ja", "日本語", "🇯🇵"),
        ("ko", "한국어", "🇰🇷"),
        ("zh-Hans", "中文 (简体)", "🇨🇳"),
        ("zh-Hant", "中文 (繁體)", "🇹🇼"),
        ("th", "ไทย", "🇹🇭"),
        ("vi", "Tiếng Việt", "🇻🇳"),
        ("hi", "हिन्दी", "🇮🇳"),
        ("id", "Bahasa Indonesia", "🇮🇩"),
        ("ru", "Русский", "🇷🇺"),
        ("uk", "Українська", "🇺🇦"),
        ("pl", "Polski", "🇵🇱"),
        ("cs", "Čeština", "🇨🇿"),
        ("hu", "Magyar", "🇭🇺"),
        ("ro", "Română", "🇷🇴"),
        ("el", "Ελληνικά", "🇬🇷")
    ]

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
                        Text(lm.text("language_title"))
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // INFO
                    Text(lm.text("language_subtitle"))
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    // LANGUAGE LIST
                    SettingsCard {
                        ForEach(languages, id: \.code) { language in
                            Button {
                                lm.currentLanguage = language.code
                            } label: {
                                HStack {
                                    Text(language.flag)
                                        .font(.title2)

                                    Text(language.name)
                                        .foregroundColor(.black)

                                    Spacer()

                                    if lm.currentLanguage == language.code {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 10)
                            }

                            if language.code != languages.last?.code {
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

