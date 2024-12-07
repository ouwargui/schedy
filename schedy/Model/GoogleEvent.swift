//
//  GoogleEvent.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 03/12/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar
import SwiftData

@Model
class GoogleEvent {
    var googleId: String
    var title: String
    var start: Date
    var end: Date
    var meetLink: String?
    var htmlLink: String
    var eventDescription: String?
    var calendar: GoogleCalendar
    
    init(event: GTLRCalendar_Event, calendar: GoogleCalendar) {
        self.googleId = event.identifier!
        self.title = event.summary!
        self.start = ISO8601DateFormatter().date(from: event.start!.dateTime!.stringValue)!
        self.end = ISO8601DateFormatter().date(from: event.end!.dateTime!.stringValue)!
        self.meetLink = event.hangoutLink
        self.htmlLink = event.htmlLink!
        self.eventDescription = event.descriptionProperty
        self.calendar = calendar
    }
    
    func update(event: GTLRCalendar_Event) {
        self.googleId = event.identifier!
        self.title = event.summary!
        self.start = ISO8601DateFormatter().date(from: event.start!.dateTime!.stringValue)!
        self.end = ISO8601DateFormatter().date(from: event.end!.dateTime!.stringValue)!
        self.meetLink = event.hangoutLink
        self.htmlLink = event.htmlLink!
        self.eventDescription = event.descriptionProperty
    }
}

// predicates
extension GoogleEvent {
    static var todaysPredicate: Predicate<GoogleEvent> {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return #Predicate<GoogleEvent> { event in
            event.calendar.isEnabled &&
            event.start >= startOfDay &&
            event.start < endOfDay
        }
    }
    
    static var tomorrowsPredicate: Predicate<GoogleEvent> {
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        let startOfDayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfTomorrow)!
        
        return #Predicate<GoogleEvent> { event in
            event.calendar.isEnabled &&
            event.start >= startOfTomorrow &&
            event.start < startOfDayAfterTomorrow
        }
    }
}

extension GoogleEvent {
    func hasPassed() -> Bool {
        self.end < Date()
    }
    
    func getHtmlLinkWithAuthUser() -> URL {
        let urlQueryItem = URLQueryItem(name: "authuser", value: self.calendar.account.email)
        let urlQueryItems: [URLQueryItem] = [urlQueryItem]
        
        return URL(string: self.htmlLink)!
            .appending(queryItems: urlQueryItems)
    }
    
    func getStartHour() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        
        return dateFormatter.string(from: self.start)
    }
    
    func getEndHour() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        
        return dateFormatter.string(from: self.end)
    }
    
    func getTimeUntilEvent() -> String {
        return self.timeUntilEvent(eventDate: self.start)
    }
    
    func getMenuBarString() -> String {
        return "\(self.title) (\(LocalizedString.localized("in")) \(self.getTimeUntilEvent()))"
    }
}

extension Collection where Element == GoogleEvent {
    func getCurrentOrNextEvent() -> GoogleEvent? {
        let now = Date()
        
        if let currentEvent = self.first(where: {
            now >= $0.start && now <= $0.end
        }) {
            return currentEvent
        }
        
        return self
            .filter { $0.start > now }
            .min { $0.start < $1.start }
            .self
    }
}

private extension GoogleEvent {
    func timeUntilEvent(eventDate: Date) -> String {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: Date(), to: eventDate)
        
        var result = ""
        if let days = components.day, days > 0 {
            result += "\(days)d "
        }
        
        if let hours = components.hour, hours > 0 {
            result += "\(hours)h "
        }
        
        if let minutes = components.minute, minutes > 0 {
            result += "\(minutes)m"
        }
        
        return result.trimmingCharacters(in: .whitespaces)
    }
}
