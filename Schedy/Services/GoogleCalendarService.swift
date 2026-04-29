import Foundation
import GTMAppAuth
import GoogleAPIClientForREST_Calendar

class GoogleCalendarService: CalendarServiceProtocol {
  static let shared = GoogleCalendarService()
  private let service = GTLRCalendarService()

  func fetchEvents(
    for calendarId: String,
    fetcherAuthorizer: AuthSession,
    syncToken: String?
  ) async throws -> GTLRCalendar_Events {
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .hour, value: -3, to: Date())!
    let nextDay = calendar.date(byAdding: .day, value: 2, to: startDate)!
    let endDate = calendar.startOfDay(for: nextDay)

    let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarId)
    query.timeMin = GTLRDateTime(date: startDate)
    query.timeMax = GTLRDateTime(date: endDate)
    query.orderBy = kGTLRCalendarOrderByStartTime
    query.singleEvents = true
    query.syncToken = syncToken
    query.showDeleted = true
    query.maxResults = 20

    service.authorizer = fetcherAuthorizer

    return try await withCheckedThrowingContinuation {
      // swiftlint:disable:next closure_parameter_position
      (continuation: CheckedContinuation<GTLRCalendar_Events, Error>) in
      service.executeQuery(query) { (_, result, error) in
        if let error = error {
          print("Error executing query: \(error.localizedDescription)")
          continuation.resume(throwing: error)
          return
        }

        guard let eventList = result as? GTLRCalendar_Events else {
          print("Error getting events result")
          continuation.resume(throwing: NSError(domain: "", code: -1))
          return
        }
        continuation.resume(returning: eventList)
      }
    }
  }

  func fetchUserCalendars(
    fetcherAuthorizer: AuthSession,
    syncToken: String?
  ) async throws -> GTLRCalendar_CalendarList {
    let calendarListQuery = GTLRCalendarQuery_CalendarListList.query()
    calendarListQuery.syncToken = syncToken
    calendarListQuery.showDeleted = true
    service.authorizer = fetcherAuthorizer

    let calendars = try await withCheckedThrowingContinuation {
      // swiftlint:disable:next closure_parameter_position
      (continuation: CheckedContinuation<GTLRCalendar_CalendarList, Error>) in
      service.executeQuery(calendarListQuery) { (_, result, error) in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }
        guard let calendarList = result as? GTLRCalendar_CalendarList else {
          continuation.resume(throwing: NSError(domain: "", code: -1))
          return
        }
        continuation.resume(returning: calendarList)
      }
    }

    return calendars
  }

  func updateEventResponse(
    eventId: String,
    calendarId: String,
    attendeeEmail: String,
    responseStatus: GoogleEventResponseStatus,
    fetcherAuthorizer: AuthSession
  ) async throws -> GTLRCalendar_Event {
    let attendee = GTLRCalendar_EventAttendee()
    attendee.email = attendeeEmail
    attendee.responseStatus = responseStatus.rawValue
    attendee.selfProperty = NSNumber(value: true)

    let event = GTLRCalendar_Event()
    event.attendees = [attendee]
    event.attendeesOmitted = NSNumber(value: true)

    let query = GTLRCalendarQuery_EventsPatch.query(
      withObject: event,
      calendarId: calendarId,
      eventId: eventId
    )

    service.authorizer = fetcherAuthorizer

    return try await withCheckedThrowingContinuation {
      // swiftlint:disable:next closure_parameter_position
      (continuation: CheckedContinuation<GTLRCalendar_Event, Error>) in
      service.executeQuery(query) { (_, result, error) in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard let event = result as? GTLRCalendar_Event else {
          continuation.resume(throwing: NSError(domain: "", code: -1))
          return
        }

        continuation.resume(returning: event)
      }
    }
  }
}
