import GoogleAPIClientForREST_Calendar
import XCTest

@testable import Schedy

class GoogleEventTests: XCTestCase {
  func test_getMenuBarString_showsFutureRelativeDateWithDays() async throws {
    let user = MockManager.makeUser()

    let now = Date()

    let title = "Test Event"
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .hour, value: 26, to: now)!
    let event = MockManager.makeGoogleEvent(
      id: "evt-1",
      start: startDate,
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    let menuBarString = event.getMenuBarString(currentTime: now)

    let expected = "\(title) (in 1d)"

    XCTAssertTrue(
      menuBarString == expected,
      "Expected '\(expected)', got '\(menuBarString)'")
  }

  func test_getMenuBarString_showsFutureRelativeDateWithHoursAndMinutes() async throws {
    let user = MockManager.makeUser()

    let now = Date()

    let title = "Test Event"
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .hour, value: 22, to: now)!
    let event = MockManager.makeGoogleEvent(
      id: "evt-1",
      start: startDate,
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    let menuBarString = event.getMenuBarString(currentTime: now)

    let expected = "\(title) (in 22h 0m)"

    XCTAssertTrue(
      menuBarString == expected,
      "Expected '\(expected)', got '\(menuBarString)'")
  }

  func test_getMenuBarString_showsFutureRelativeDateWithMinutes() async throws {
    let user = MockManager.makeUser()

    let now = Date()

    let title = "Test Event"
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .minute, value: 30, to: now)!
    let event = MockManager.makeGoogleEvent(
      id: "evt-1",
      start: startDate,
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    let menuBarString = event.getMenuBarString(currentTime: now)

    let expected = "\(title) (in 30m)"

    XCTAssertTrue(
      menuBarString == expected,
      "Expected '\(expected)', got '\(menuBarString)'")
  }

  func test_getMenuBarString_showsFutureRelativeDateWithSeconds() async throws {
    let user = MockManager.makeUser()

    let now = Date()

    let title = "Test Event"
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .second, value: 30, to: now)!
    let event = MockManager.makeGoogleEvent(
      id: "evt-1",
      start: startDate,
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    let menuBarString = event.getMenuBarString(currentTime: now)

    let expected = "\(title) (in 30s)"

    XCTAssertTrue(
      menuBarString == expected,
      "Expected '\(expected)', got '\(menuBarString)'")
  }

  func test_getMenuBarString_showsFutureRelativeDateWithSingleMinute() async throws {
    let user = MockManager.makeUser()

    let now = Date()

    let title = "Test Event"
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .second, value: 65, to: now)!
    let event = MockManager.makeGoogleEvent(
      id: "evt-1",
      start: startDate,
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    let menuBarString = event.getMenuBarString(currentTime: now)

    let expected = "\(title) (in 1m)"

    XCTAssertTrue(
      menuBarString == expected,
      "Expected '\(expected)', got '\(menuBarString)'")
  }

  func test_getTimeUntilEndFormatted_showsTimeLeftInDays() async throws {
    let user = MockManager.makeUser()

    let now = Date()

    let title = "Current Event"
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .day, value: -2, to: now)!  // Started 2 days ago
    let endDate = calendar.date(byAdding: .day, value: 1, to: now)!  // Ends in 1 day

    let event = MockManager.makeGoogleEvent(
      id: "evt-current",
      start: startDate,
      end: endDate,
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    // The event is ongoing, so getMenuBarString should show time left
    let menuBarString = event.getMenuBarString(currentTime: now)

    let expected = "\(title) (1d left)"

    XCTAssertTrue(
      menuBarString == expected,
      "Expected '\(expected)', got '\(menuBarString)'")
  }

  func test_getTimeUntilEndFormatted_showsTimeLeftInHoursAndMinutes() async throws {
    let user = MockManager.makeUser()

    let now = Date()

    let title = "Current Event"
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .hour, value: -1, to: now)!  // Started 1 hour ago
    let endDate = calendar.date(byAdding: .hour, value: 3, to: now)!  // Ends in 3 hours

    let event = MockManager.makeGoogleEvent(
      id: "evt-current",
      start: startDate,
      end: endDate,
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    // The event is ongoing, so getMenuBarString should show time left
    let menuBarString = event.getMenuBarString(currentTime: now)

    let expected = "\(title) (3h 0m left)"

    XCTAssertTrue(
      menuBarString == expected,
      "Expected '\(expected)', got '\(menuBarString)'")
  }

  func test_getTimeUntilEndFormatted_showsTimeLeftInMinutes() async throws {
    let user = MockManager.makeUser()

    let now = Date()

    let title = "Current Event"
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .minute, value: -10, to: now)!  // Started 10 minutes ago
    let endDate = calendar.date(byAdding: .minute, value: 20, to: now)!  // Ends in 20 minutes

    let event = MockManager.makeGoogleEvent(
      id: "evt-current",
      start: startDate,
      end: endDate,
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    // The event is ongoing, so getMenuBarString should show time left
    let menuBarString = event.getMenuBarString(currentTime: now)

    let expected = "\(title) (20m left)"

    XCTAssertTrue(
      menuBarString == expected,
      "Expected '\(expected)', got '\(menuBarString)'")
  }

  func test_getTimeUntilEndFormatted_showsTimeLeftInSeconds() async throws {
    let user = MockManager.makeUser()

    let now = Date()

    let title = "Current Event"
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .second, value: -30, to: now)!  // Started 30 seconds ago
    let endDate = calendar.date(byAdding: .second, value: 15, to: now)!  // Ends in 15 seconds

    let event = MockManager.makeGoogleEvent(
      id: "evt-current",
      start: startDate,
      end: endDate,
      title: title,
      calendar: MockManager.makeGoogleCalendar(id: "cal-1", name: title, user: user))

    // The event is ongoing, so getMenuBarString should show time left
    let menuBarString = event.getMenuBarString(currentTime: now)

    let expected = "\(title) (15s left)"

    XCTAssertTrue(
      menuBarString == expected,
      "Expected '\(expected)', got '\(menuBarString)'")
  }
}
