import Foundation
import GTMAppAuth
import SwiftData

@Model
class GoogleUser {
  var googleId: String
  var email: String
  var isSessionActive: Bool
  @Relationship(deleteRule: .cascade, inverse: \GoogleCalendar.account) var calendars:
    [GoogleCalendar]
  @Transient @MainActor
  private lazy var calendarSyncManager = CalendarSyncManager(user: self)
  @Transient var lastSyncedAt: Date?

  init(id: String, email: String, calendars: [GoogleCalendar] = []) {
    self.googleId = id
    self.email = email
    self.calendars = calendars
    self.isSessionActive = true
  }
}

extension GoogleUser {
  @MainActor
  func startSync() {
    self.calendarSyncManager.startSync()
  }

  @MainActor
  func stopSync() {
    self.calendarSyncManager.stopSync()
  }

  func getSession() -> AuthSession {
    return SessionManager.shared.getSession(for: self.email)!
  }

  func getLastSyncRelativeTime(relativeTo: Date = Date.now) -> String? {
    if let lastSyncedAt = self.lastSyncedAt {
      let formatter = RelativeDateTimeFormatter()
      formatter.unitsStyle = .full
      let relativeDate = formatter.localizedString(for: lastSyncedAt, relativeTo: relativeTo)
      return relativeDate
    }

    return nil
  }
}
