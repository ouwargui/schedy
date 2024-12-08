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
    var googleId: String
    var email: String
    var isSessionActive: Bool
    @Relationship(deleteRule: .cascade, inverse: \GoogleCalendar.account) var calendars: [GoogleCalendar]
    @Transient private var calendarSyncManager: CalendarSyncManager {
        return CalendarSyncManager(user: self)
    }
    @Transient var lastSyncedAt: Date?
    
    init(id: String, email: String, calendars: [GoogleCalendar] = []) {
        self.googleId = id
        self.email = email
        self.calendars = calendars
        self.isSessionActive = true
    }
}

extension GoogleUser {
    func startSync() {
        self.calendarSyncManager.startSync()
    }
    
    func stopSync() {
        self.calendarSyncManager.stopSync()
    }
    
    func getSession() -> AuthSession {
        return SessionManager.shared.getSession(for: self.email)!
    }
    
    func getLastSyncRelativeTime() -> String? {
        if let lastSyncedAt = self.lastSyncedAt {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let relativeDate = formatter.localizedString(for: lastSyncedAt, relativeTo: Date.now)
            return relativeDate
        }
        
        return nil
    }
}
