import GTMAppAuth
import GoogleAPIClientForREST_Calendar
import SwiftData
import XCTest

@testable import Schedy

// Simple mocks for protocol dependencies
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

@MainActor
final class CalendarSyncManagerTests: XCTestCase {
  // Helper to create a GoogleUser
  func makeUser(withCalendars calendars: [GoogleCalendar] = []) -> GoogleUser {
    GoogleUser(id: "user-id", email: "user@example.com", calendars: calendars)
  }

  // Helper to create a GTLRCalendar_CalendarListEntry
  func makeCalendarEntry(id: String, summary: String, deleted: Bool = false)
    -> GTLRCalendar_CalendarListEntry
  {  // swiftlint:disable:this opening_brace
    let entry = GTLRCalendar_CalendarListEntry()
    entry.identifier = id
    entry.summary = summary
    entry.deleted = deleted as NSNumber
    return entry
  }

  // Helper to create a GoogleCalendar
  func makeGoogleCalendar(id: String, name: String, user: GoogleUser) -> GoogleCalendar {
    GoogleCalendar(calendar: makeCalendarEntry(id: id, summary: name), account: user)
  }

  // Helper to create a GTLRCalendar_Event
  func makeEvent(id: String, status: String = "confirmed") -> GTLRCalendar_Event {
    let event = GTLRCalendar_Event()
    event.identifier = id
    event.status = status

    let now = Date()
    let isoFormatter = ISO8601DateFormatter()

    // Create GTLRDateTime objects directly with ISO8601 strings
    let startGTLRDateTime = GTLRDateTime(rfc3339String: isoFormatter.string(from: now))
    let endGTLRDateTime = GTLRDateTime(
      rfc3339String: isoFormatter.string(from: now.addingTimeInterval(3600)))  // 1 hour later

    // Create GTLRCalendar_EventDateTime objects and assign the GTLRDateTime objects
    let startEventDateTime = GTLRCalendar_EventDateTime()
    startEventDateTime.dateTime = startGTLRDateTime
    event.start = startEventDateTime

    let endEventDateTime = GTLRCalendar_EventDateTime()
    endEventDateTime.dateTime = endGTLRDateTime
    event.end = endEventDateTime

    event.summary = "Event"
    event.htmlLink = "https://event"
    return event
  }

  // Helper to create a GoogleEvent
  func makeGoogleEvent(id: String, calendar: GoogleCalendar) -> GoogleEvent {
    GoogleEvent(event: makeEvent(id: id), calendar: calendar)
  }

  func test_processCalendars_insertsNewCalendar() async {
    let user = makeUser()
    let mockData = MockDataManager()
    let manager = CalendarSyncManager(user: user, dataManager: mockData)
    let newEntry = makeCalendarEntry(id: "cal-1", summary: "Test Cal")

    manager.processCalendars([newEntry])

    XCTAssertEqual(mockData.insertedModels.count, 1)
    XCTAssertTrue(mockData.insertedModels.first is GoogleCalendar)
  }

  func test_processCalendars_updatesExistingCalendar() async {
    let user = makeUser()
    let calendar = makeGoogleCalendar(id: "cal-1", name: "Old Name", user: user)
    user.calendars = [calendar]
    let mockData = MockDataManager()
    let manager = CalendarSyncManager(user: user, dataManager: mockData)
    let updatedEntry = makeCalendarEntry(id: "cal-1", summary: "New Name")

    manager.processCalendars([updatedEntry])

    XCTAssertTrue(mockData.updatedCalled)
    XCTAssertEqual(calendar.name, "New Name")
  }

  func test_processCalendars_deletesCalendar() async {
    let user = makeUser()
    let calendar = makeGoogleCalendar(id: "cal-1", name: "Test Cal", user: user)
    user.calendars = [calendar]
    let mockData = MockDataManager()
    let manager = CalendarSyncManager(user: user, dataManager: mockData)
    let deletedEntry = makeCalendarEntry(id: "cal-1", summary: "Test Cal", deleted: true)

    manager.processCalendars([deletedEntry])

    XCTAssertEqual(mockData.deletedModels.count, 1)
    XCTAssertTrue(mockData.deletedModels.first is GoogleCalendar)
  }

  func test_processEvents_insertsNewEvent() async {
    let user = makeUser()
    let calendar = makeGoogleCalendar(id: "cal-1", name: "Test Cal", user: user)
    let mockData = MockDataManager()
    let manager = CalendarSyncManager(user: user, dataManager: mockData)
    let newEvent = makeEvent(id: "evt-1")

    manager.processEvents([newEvent], for: calendar)

    print("[TEST] insertedModels: \(mockData.insertedModels)")
    XCTAssertEqual(mockData.insertedModels.count, 1)
    XCTAssertTrue(mockData.insertedModels.first is GoogleEvent)
  }

  func test_processEvents_deletesCancelledEvent() async {
    let user = makeUser()
    let calendar = makeGoogleCalendar(id: "cal-1", name: "Test Cal", user: user)
    let event = makeGoogleEvent(id: "evt-1", calendar: calendar)
    calendar.events = [event]
    let mockData = MockDataManager()
    let manager = CalendarSyncManager(user: user, dataManager: mockData)
    let cancelledEvent = makeEvent(id: "evt-1", status: "cancelled")

    manager.processEvents([cancelledEvent], for: calendar)

    print("[TEST] deletedModels: \(mockData.deletedModels)")
    XCTAssertEqual(mockData.deletedModels.count, 1)
    XCTAssertTrue(mockData.deletedModels.first is GoogleEvent)
  }
}
