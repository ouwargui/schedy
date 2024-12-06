//
//  GoogleUser.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 05/12/24.
//

import Foundation
import SwiftData
import GTMAppAuth

@Model
class GoogleUser {
    var id: String
    var email: String
    var isSessionActive: Bool
    @Relationship(deleteRule: .cascade, inverse: \GoogleCalendar.account) var calendars: [GoogleCalendar]
    
    init(id: String, email: String, calendars: [GoogleCalendar] = []) {
        self.id = id
        self.email = email
        self.calendars = calendars
        self.isSessionActive = true
    }
}

extension GoogleUser {
    func getSession() -> AuthSession {
        return SessionManager.shared.getSession(for: self.email)!
    }
}
