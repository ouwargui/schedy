//
//  CalendarManager.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 28/11/24.
//

import GoogleAPIClientForREST_Calendar
import GoogleSignIn
import AppKit
import GTMAppAuth

@MainActor
class CalendarManager {
    static let shared = CalendarManager()
    private let service = GTLRCalendarService()
    
    private var isSignedIn: Bool {
        return GIDSignIn.sharedInstance.hasPreviousSignIn()
    }
    
    func fetchCalendarEvents(for calendarId: String, with authSession: AuthSession, _ syncToken: String?) async -> GTLRCalendar_Events? {
        guard let result = try? await GoogleCalendarService.shared.fetchEvents(
            for: calendarId,
            fetcherAuthorizer: authSession,
            syncToken: syncToken
        ) else {
            return nil
        }
        
        return result
    }
}
