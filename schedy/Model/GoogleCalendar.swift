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
    var account: GoogleUser
    @Relationship(deleteRule: .cascade) var events = [GoogleEvent]()
    
    init(calendar: GTLRCalendar_CalendarListEntry, account: GoogleUser, isEnabled: Bool = true) {
        self.id = calendar.identifier!
        self.googleId = calendar.identifier!
        self.name = calendar.summaryOverride ?? calendar.summary!
        self.isEnabled = isEnabled
        self.account = account
    }
}
