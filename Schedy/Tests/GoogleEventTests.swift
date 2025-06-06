import GoogleAPIClientForREST_Calendar
import XCTest

@testable import Schedy

class GoogleEventTests: XCTestCase {
  func test_getMenuBarString_showsDays() async throws {
    let user = MockManager.makeUser()

    let now = Date()
    let title = "Test Event"

    let event = MockManager.makeGoogleEvent(
      id: "evt-1",
      start: now.addingTimeInterval(60 * 60 * 24 * 1 + 30),
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    let menuBarString = event.getMenuBarString(currentTime: now)
    print(menuBarString)
    XCTAssertTrue(
      menuBarString == "\(title) (in 1d)", "Expected '\(title) (in 1d)', got '\(menuBarString)'")
  }
}
