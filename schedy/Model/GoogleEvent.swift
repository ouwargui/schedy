//
//  GoogleEvent.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 03/12/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar

class GoogleEvent: Identifiable {
    var id: String
    var event: GTLRCalendar_Event
    
    init(event: GTLRCalendar_Event) {
        self.id = event.identifier ?? UUID().uuidString
        self.event = event
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        return self.convertGoogleDateTimeToDate(eventDateTime: self.event.start)!
    }
    
    func getDateEndTime() -> Date {
        return self.convertGoogleDateTimeToDate(eventDateTime: self.event.end)!
    }
    
    func getTimeUntilEvent() -> String {
        return self.timeUntilEvent(eventDate: self.event.start)
    }
    
    func getMenuBarString() -> String {
        guard let summary = self.event.summary else {
            return "schedy"
        }
        
        return "\(summary) (\(LocalizedString.localized("in")) \(self.getTimeUntilEvent()))"
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
    func timeUntilEvent(eventDate: GTLRCalendar_EventDateTime?) -> String {
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
    
    func convertGoogleDateTimeToDate(eventDateTime: GTLRCalendar_EventDateTime?) -> Date? {
        guard let dateTimeString = eventDateTime?.dateTime!.stringValue else {
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateTimeString)
    }
}
