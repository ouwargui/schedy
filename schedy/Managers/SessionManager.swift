//
//  UserManager.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 05/12/24.
//

import Foundation
import GTMAppAuth

class SessionManager {
    static let shared = SessionManager()
    
    @MainActor
    func createNewSession(auth: AuthSession, calendars: [GoogleCalendar] = []) {
        do {
            try KeychainStore(itemName: auth.userEmail!).save(authSession: auth)
        } catch (let error) {
            print("Failed to save session to keychain: \(error.localizedDescription)")
            return
        }
        
        let user = GoogleUser(id: auth.userID!, email: auth.userEmail!)
        SwiftDataManager.shared.container.mainContext.insert(user)
    }
}
