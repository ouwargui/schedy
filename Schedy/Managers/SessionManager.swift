import Foundation
import GTMAppAuth

class SessionManager {
    static let shared = SessionManager()

    @MainActor
    func createNewSession(auth: AuthSession, calendars: [GoogleCalendar] = []) {
        do {
            try KeychainStore(itemName: auth.userEmail!).save(authSession: auth)
        } catch let error {
            print("Failed to save session to keychain: \(error.localizedDescription)")
            return
        }

        let user = GoogleUser(id: auth.userID!, email: auth.userEmail!)
        SwiftDataManager.shared.insert(model: user)
        user.startSync()
    }

    @MainActor
    func deleteSession(for user: GoogleUser) {
        do {
            let email = user.email
            try KeychainStore(itemName: email).removeAuthSession()
            user.stopSync()
            try SwiftDataManager.shared.delete(model: GoogleUser.self, where: #Predicate {
                $0.email == email
            })
            return
        } catch let error {
            print("Error deleting session for \(user.email): \(error.localizedDescription)")
            return
        }
    }

    func getSession(for email: String) -> AuthSession? {
        do {
            return try KeychainStore(itemName: email).retrieveAuthSession()
        } catch let error {
            print("Failed to retrieve user session for \(email): \(error.localizedDescription)")
            return nil
        }
    }
}
