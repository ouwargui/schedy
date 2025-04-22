import Foundation
import GoogleAPIClientForREST_Calendar
import SwiftData

@Model
class GoogleCalendar {
    var googleId: String
    var name: String
    var isEnabled: Bool
    var account: GoogleUser
    @Relationship(deleteRule: .cascade, inverse: \GoogleEvent.calendar) var events = [GoogleEvent]()

    init(calendar: GTLRCalendar_CalendarListEntry, account: GoogleUser, isEnabled: Bool = true) {
        self.googleId = calendar.identifier!
        self.name = calendar.summaryOverride ?? calendar.summary!
        self.isEnabled = isEnabled
        self.account = account
    }

    func update(calendar: GTLRCalendar_CalendarListEntry) {
        self.googleId = calendar.identifier!
        self.name = calendar.summaryOverride ?? calendar.summary!
    }
}
