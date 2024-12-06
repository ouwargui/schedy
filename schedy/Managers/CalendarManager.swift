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
    
    func fetchUserCalendars(for user: GoogleUser) async -> [GoogleCalendar] {
        let authSession = user.getSession()
        
        do {
            let result = try await GoogleCalendarService.shared.fetchUserCalendars(fetcherAuthorizer: authSession)
            let googleCalendars = result.map { calendar in
                let googleCalendar = GoogleCalendar(calendar: calendar, account: user)
                return googleCalendar
            }
            
            SwiftDataManager.shared.batchInsert(models: googleCalendars)
            return googleCalendars
        } catch (let error) {
            print("Failed to fetch user calendars: \(error.localizedDescription)")
            return []
        }
    }
}
