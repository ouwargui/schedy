import GoogleAPIClientForREST_Calendar
import SwiftData

@testable import Schedy

@MainActor
class MockDataManager: DataManaging {
  var insertedModels: [Any] = []
  var updatedCalled = false
  var deletedModels: [Any] = []
  var fetchAllResult: Any?

  func insert<T>(model: T) where T: PersistentModel {
    insertedModels.append(model)
  }
  func update() {
    updatedCalled = true
  }
  func delete<T>(model: T) where T: PersistentModel {
    deletedModels.append(model)
  }
  func fetchAll<T>(fetchDescriptor: FetchDescriptor<T>) -> Result<[T], Error> {
    if let result = fetchAllResult as? [T] {
      return .success(result)
    }
    return .success([])
  }
}

final class MockManager {
  static func makeUser(withCalendars calendars: [GoogleCalendar] = []) -> GoogleUser {
    GoogleUser(id: "user-id", email: "user@example.com", calendars: calendars)
  }

  static func makeCalendarEntry(id: String, summary: String, deleted: Bool = false)
    -> GTLRCalendar_CalendarListEntry
  {  // swiftlint:disable:this opening_brace
    let entry = GTLRCalendar_CalendarListEntry()
    entry.identifier = id
    entry.summary = summary
    entry.deleted = deleted as NSNumber
    return entry
  }

  static func makeGoogleCalendar(id: String, name: String, user: GoogleUser) -> GoogleCalendar {
    GoogleCalendar(calendar: makeCalendarEntry(id: id, summary: name), account: user)
  }

  static func makeEvent(
    id: String, start: Date = Date(), end: Date = Date().addingTimeInterval(3600),
    title: String = "Event", status: String = "confirmed"
  ) -> GTLRCalendar_Event {
    let event = GTLRCalendar_Event()
    event.identifier = id
    event.status = status

    let isoFormatter = ISO8601DateFormatter()

    // Create GTLRDateTime objects directly with ISO8601 strings
    let startGTLRDateTime = GTLRDateTime(rfc3339String: isoFormatter.string(from: start))
    let endGTLRDateTime = GTLRDateTime(
      rfc3339String: isoFormatter.string(from: end))

    // Create GTLRCalendar_EventDateTime objects and assign the GTLRDateTime objects
    let startEventDateTime = GTLRCalendar_EventDateTime()
    startEventDateTime.dateTime = startGTLRDateTime
    event.start = startEventDateTime

    let endEventDateTime = GTLRCalendar_EventDateTime()
    endEventDateTime.dateTime = endGTLRDateTime
    event.end = endEventDateTime

    event.summary = title
    event.htmlLink = "https://event"
    return event
  }

  static func makeGoogleEvent(
    id: String, start: Date = Date(), end: Date = Date().addingTimeInterval(3600),
    title: String = "Event",
    calendar: GoogleCalendar
  ) -> GoogleEvent {
    GoogleEvent(event: makeEvent(id: id, start: start, end: end, title: title), calendar: calendar)
  }
}
