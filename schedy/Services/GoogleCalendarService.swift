//
//  GoogleCalendarService.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 02/12/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar

class GoogleCalendarService {
    static let shared = GoogleCalendarService()
    private let service = GTLRCalendarService()
    
    func fetchEvents(for calendarId: String, fetcherAuthorizer: any GTMSessionFetcherAuthorizer) async throws -> [GTLRCalendar_Event] {
        let calendar = Calendar.current
        let startDate = Date()
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let endDate = calendar.startOfDay(for: nextDay)
        
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarId)
        query.timeMin = GTLRDateTime(date: startDate)
        query.timeMax = GTLRDateTime(date: endDate)
        query.orderBy = kGTLRCalendarOrderByStartTime
        query.singleEvents = true
        query.maxResults = 20
        
        service.authorizer = fetcherAuthorizer
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[GTLRCalendar_Event], Error>) in
            service.executeQuery(query) { (_, result, error) in
                if let error = error {
                    print("Error executing query: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let eventList = result as? GTLRCalendar_Events else {
                    print("Error getting events result")
                    continuation.resume(throwing: NSError(domain: "", code: -1))
                    return
                }
                continuation.resume(returning: eventList.items ?? [])
            }
        }
    }
    
    func fetchAllCalendarEvents(fetcherAuthorizer: any GTMSessionFetcherAuthorizer) async throws -> (events: [GTLRCalendar_Event], calendars: [GTLRCalendar_CalendarListEntry]) {
        // First get list of calendars
        let calendars = try await fetchUserCalendars(fetcherAuthorizer: fetcherAuthorizer)
        
        // Fetch events from all calendars concurrently
        let eventArrays = try await withThrowingTaskGroup(of: [GTLRCalendar_Event].self) { group in
            for calendar in calendars {
                guard let calendarId = calendar.identifier else { continue }
                group.addTask {
                    return try await self.fetchEvents(for: calendarId, fetcherAuthorizer: fetcherAuthorizer)
                }
            }
            
            var allEvents: [[GTLRCalendar_Event]] = []
            for try await events in group {
                allEvents.append(events)
            }
            return allEvents
        }
        
        return (events: eventArrays.flatMap { $0 }, calendars: calendars)
    }
    
    func fetchUserCalendars(fetcherAuthorizer: any GTMSessionFetcherAuthorizer) async throws -> [GTLRCalendar_CalendarListEntry] {
        let calendarListQuery = GTLRCalendarQuery_CalendarListList.query()
        service.authorizer = fetcherAuthorizer
        
        let calendars = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[GTLRCalendar_CalendarListEntry], Error>) in
            service.executeQuery(calendarListQuery) { (_, result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let calendarList = result as? GTLRCalendar_CalendarList else {
                    continuation.resume(throwing: NSError(domain: "", code: -1))
                    return
                }
                continuation.resume(returning: calendarList.items ?? [])
            }
        }
        
        return calendars
    }
}
