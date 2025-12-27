import SwiftUI

final class LocalizationManager: ObservableObject {

    static let shared = LocalizationManager()

    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "app_language")
        }
    }

    private init() {
        self.currentLanguage =
            UserDefaults.standard.string(forKey: "app_language")
            ?? Locale.current.languageCode
            ?? "en"
    }

    // 🔑 STRING OKUYUCU
    func text(_ key: String) -> String {
        let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj")
        let bundle = path != nil ? Bundle(path: path!) : .main
        return NSLocalizedString(key, bundle: bundle!, comment: "")
    }
}

