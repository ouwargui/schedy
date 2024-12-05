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
    
    func fetchAllCalendarEvents(fetcherAuthorizer: GTMSessionFetcherAuthorizer) async -> (events: [GoogleEvent], calendars: [GoogleCalendar]) {
        if let result = try? await GoogleCalendarService.shared.fetchAllCalendarEvents(fetcherAuthorizer: fetcherAuthorizer) {
            let calendars = result.calendars.map({ calendar in
                return GoogleCalendar(calendar: calendar)
            })
            
            let events = result.events
                .filter { event in
                    return event.start?.dateTime != nil && event.end?.dateTime != nil
                }
                .map { event in
                    return GoogleEvent(event: event)
                }
            
            return (events, calendars)
        }
        
        return ([], [])
    }
}
