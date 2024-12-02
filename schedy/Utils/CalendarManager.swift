//
//  CalendarManager.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 28/11/24.
//

import GoogleAPIClientForREST_Calendar
import GoogleSignIn
import AppKit

@MainActor
class CalendarManager {
    static let shared = CalendarManager()
    private let service = GTLRCalendarService()
    
    private var isSignedIn: Bool {
        return GIDSignIn.sharedInstance.hasPreviousSignIn()
    }
    
    func fetchAllCalendarEvents(fetcherAuthorizer: GTMSessionFetcherAuthorizer) async -> (events: [GTLRCalendar_Event], calendars: [GoogleCalendar]) {
        if let result = try? await GoogleCalendarService.shared.fetchAllCalendarEvents(fetcherAuthorizer: fetcherAuthorizer) {
            return (result.events, result.calendars.map({ calendar in
                return GoogleCalendar(calendar: calendar, isOn: true)
            }))
        }
        
        return ([], [])
    }
    
    func getCurrentEvent(events: [GTLRCalendar_Event]) async -> GTLRCalendar_Event? {        
        return nil
    }
}
