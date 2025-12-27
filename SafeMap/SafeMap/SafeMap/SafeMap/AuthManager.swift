import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AppUser: Identifiable {
    let id: String
    let fullName: String
    let email: String
}

final class AuthManager: ObservableObject {

    @Published var isLoggedIn = false
    @Published var user: AppUser?

    private let db = Firestore.firestore()

    init() {
        checkSession()
    }

    // 🔄 SESSION
    func checkSession() {
        guard let currentUser = Auth.auth().currentUser else {
            isLoggedIn = false
            user = nil
            return
        }

        isLoggedIn = true
        fetchUser(uid: currentUser.uid)
    }

    // 🔐 REGISTER
    func register(
        email: String,
        password: String,
        fullName: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { res, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let uid = res?.user.uid else {
                completion(false, "User creation failed")
                return
            }

            let data: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "createdAt": Timestamp()
            ]

            self.db.collection("users").document(uid).setData(data) { err in
                if let err = err {
                    completion(false, err.localizedDescription)
                    return
                }

                self.fetchUser(uid: uid)
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    completion(true, nil)
                }
            }
        }
    }

    // 🔐 LOGIN
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { res, _ in
            guard let uid = res?.user.uid else { return }
            self.fetchUser(uid: uid)
            DispatchQueue.main.async {
                self.isLoggedIn = true
            }
        }
    }

    // 📥 FETCH USER
    private func fetchUser(uid: String) {
        db.collection("users").document(uid).getDocument { snap, _ in
            guard let data = snap?.data() else { return }

            DispatchQueue.main.async {
                self.user = AppUser(
                    id: uid,
                    fullName: data["fullName"] as? String ?? "",
                    email: data["email"] as? String ?? ""
                )
            }
        }
    }

    // 🚪 LOGOUT
    func logout() {
        try? Auth.auth().signOut()
        isLoggedIn = false
        user = nil
    }
}

