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
    
    func fetchEvents() async throws -> [GTLRCalendar_Event] {
        print("---- DEBUG ----")
        if !isSignedIn {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not signed in"])
        }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.timeMin = GTLRDateTime(date: startDate)
        query.timeMax = GTLRDateTime(date: endDate)
        query.orderBy = kGTLRCalendarOrderByStartTime
        query.singleEvents = true
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[GTLRCalendar_Event], Error>) in
            service.executeQuery(query) { (_, result, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let eventList = result as? GTLRCalendar_Events else {
                    continuation.resume(throwing: NSError(domain: "", code: -1))
                    return
                }
                
                continuation.resume(returning: eventList.items ?? [])
            }
        }
    }
}
