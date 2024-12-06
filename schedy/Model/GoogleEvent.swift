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
    var start: String
    var end: String
    var meetLink: String?
    var htmlLink: String?
    var eventDescription: String?
    var calendar: GoogleCalendar
    
    init(event: GTLRCalendar_Event, calendar: GoogleCalendar) {
        self.googleId = event.identifier!
        self.title = event.summary!
        self.start = event.start!.dateTime!.stringValue
        self.end = event.end!.dateTime!.stringValue
        self.meetLink = event.hangoutLink
        self.htmlLink = event.htmlLink
        self.eventDescription = event.descriptionProperty
        self.calendar = calendar
    }
    
    func update(event: GTLRCalendar_Event) {
        self.googleId = event.identifier!
        self.title = event.summary!
        self.start = event.start!.dateTime!.stringValue
        self.end = event.end!.dateTime!.stringValue
        self.meetLink = event.hangoutLink
        self.htmlLink = event.htmlLink
        self.eventDescription = event.descriptionProperty
    }
}

extension GoogleEvent {
    func getStartHour() -> String {
        let dateTime = self.getDateStartTime()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        
        return dateFormatter.string(from: dateTime)
    }
    
    func getEndHour() -> String {
        let dateTime = self.getDateEndTime()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        
        return dateFormatter.string(from: dateTime)
    }
    
    func getDateStartTime() -> Date {
        return self.convertGoogleDateTimeToDate(eventDateTime: self.start)!
    }
    
    func getDateEndTime() -> Date {
        return self.convertGoogleDateTimeToDate(eventDateTime: self.end)!
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
            now >= $0.getDateStartTime() && now <= $0.getDateEndTime()
        }) {
            return currentEvent
        }
        
        return self
            .filter { $0.getDateStartTime() > now }
            .min { $0.getDateStartTime() < $1.getDateStartTime() }
            .self
    }
}

private extension GoogleEvent {
    func timeUntilEvent(eventDate: String) -> String {
        let calendar = Calendar.current
        
        guard let datetime = convertGoogleDateTimeToDate(eventDateTime: eventDate) else {
            return ""
        }
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: Date(), to: datetime)
        
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
    
    func convertGoogleDateTimeToDate(eventDateTime: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: eventDateTime)
    }
}
