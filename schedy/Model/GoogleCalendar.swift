//
//  Calendar.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 02/12/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar
import SwiftData

@Model
class GoogleCalendar: Identifiable {
    var id: String
    var googleId: String
    var name: String
    var isEnabled: Bool
    @Relationship(deleteRule: .cascade) var events: [GoogleEvent]
    @Relationship(inverse: \GoogleUser.calendars) var account: GoogleUser?
    
    init(calendar: GTLRCalendar_CalendarListEntry, events: [GoogleEvent] = [], isEnabled: Bool = true) {
        self.id = calendar.identifier!
        self.googleId = calendar.identifier!
        self.name = calendar.summaryOverride ?? calendar.summary!
        self.events = events
        self.isEnabled = isEnabled
    }
}
