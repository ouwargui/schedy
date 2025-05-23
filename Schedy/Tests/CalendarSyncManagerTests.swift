import GTMAppAuth
import GoogleAPIClientForREST_Calendar
import SwiftData
import XCTest

@testable import Schedy

final class CalendarSyncManagerTests: XCTestCase {
  struct FakeCalendarList: CalendarServiceProtocol {
    var calendarsReturned: [GTLRCalendar_CalendarListEntry]
    var eventsReturned: [GTLRCalendar_Event]

    func fetchUserCalendars(
      fetcherAuthorizer: AuthSession,
      syncToken: String?
    ) async throws -> GTLRCalendar_CalendarList {
      let list = GTLRCalendar_CalendarList()
      list.items = calendarsReturned
      list.nextSyncToken = "abc-token"
      return list
    }

    func fetchEvents(
      for calendarId: String,
      fetcherAuthorizer: AuthSession,
      syncToken: String?
    ) async throws -> GTLRCalendar_Events {
      let events = GTLRCalendar_Events()
      events.items = eventsReturned
      events.nextSyncToken = "evt-token"
      return events
    }
  }

  class SpyDataManager: DataManaging {
    private(set) var inserts = 0
    func update() {}
    func delete<T>(model: T) where T: PersistentModel {}
    func insert<T>(model: T) where T: PersistentModel {
      inserts += 1
    }
    func fetchAll<T>(
      fetchDescriptor: FetchDescriptor<T>
    ) -> Result<[T], Error> {
      return .success([])
    }
  }

  func test_startSync_invokeServiceAndInserts() async throws {
    throw XCTSkip("Not ready")
    // let user = GoogleUser(id: "id", email: "me@example.com")
    // let calEntry = GTLRCalendar_CalendarListEntry()
    // calEntry.identifier = "c-1"
    // calEntry.summary = "Test Cal"

    // let gEvent = GTLRCalendar_Event()
    // gEvent.identifier = "e-1"
    // let dt = GTLRCalendar_EventDateTime(json: .init())
    // gEvent.start = dt
    // gEvent.end = dt
    // gEvent.summary = "Hi"
    // gEvent.htmlLink = "https://x"

    // let fakeSvc = FakeCalendarList(
    //   calendarsReturned: [calEntry],
    //   eventsReturned: [gEvent]
    // )
    // let spyDM = await SpyDataManager()

    // let mgr = await CalendarSyncManager(
    //   user: user,
    //   service: fakeSvc,
    //   dataManager: spyDM,
    //   timerInterval: 0.01
    // )

    // let exp = expectation(description: "sync happens twice")
    // exp.expectedFulfillmentCount = 2

    // let inserts = await spyDM.inserts

    // DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
    //   XCTAssertGreaterThanOrEqual(inserts, 1)
    //   exp.fulfill()
    // }

    // await mgr.startSync()
    // await fulfillment(of: [exp], timeout: 1)

    // await mgr.stopSync()
  }
}
