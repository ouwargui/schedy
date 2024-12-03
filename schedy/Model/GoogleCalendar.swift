//
//  Calendar.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 02/12/24.
//

import Foundation
import GoogleAPIClientForREST_Calendar

class GoogleCalendar: Identifiable {
    var calendar: GTLRCalendar_CalendarListEntry
    var isOn: Bool
    
    var id: String
    
    init(calendar: GTLRCalendar_CalendarListEntry, isOn: Bool) {
        self.calendar = calendar
        self.isOn = isOn
        self.id = calendar.identifier!
    }
}
