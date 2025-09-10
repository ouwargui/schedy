import Foundation
import GoogleAPIClientForREST_Calendar
import SwiftData

@Model
class GoogleEvent {
  var googleId: String
  var title: String
  var start: Date
  var end: Date
  var meetLink: String?
  var htmlLink: String
  var eventDescription: String?
  var calendar: GoogleCalendar

  init(event: GTLRCalendar_Event, calendar: GoogleCalendar) {
    self.googleId = event.identifier!
    self.title = event.summary ?? event.identifier ?? "Untitled"
    self.start = ISO8601DateFormatter().date(from: event.start!.dateTime!.stringValue)!
    self.end = ISO8601DateFormatter().date(from: event.end!.dateTime!.stringValue)!
    self.meetLink = event.hangoutLink
    self.htmlLink = event.htmlLink!
    self.eventDescription = event.descriptionProperty
    self.calendar = calendar
  }

  func update(event: GTLRCalendar_Event) {
    self.googleId = event.identifier!
    self.title = event.summary ?? event.identifier ?? "Untitled"
    self.start = ISO8601DateFormatter().date(from: event.start!.dateTime!.stringValue)!
    self.end = ISO8601DateFormatter().date(from: event.end!.dateTime!.stringValue)!
    self.meetLink = event.hangoutLink
    self.htmlLink = event.htmlLink!
    self.eventDescription = event.descriptionProperty
  }
}

// predicates
extension GoogleEvent {
  static var todaysNextPredicate: Predicate<GoogleEvent> {
    let now = Date()
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
    let startOfTomorrow = Calendar.current.startOfDay(for: tomorrow)

    return #Predicate<GoogleEvent> {
      $0.calendar.isEnabled && $0.start >= now && $0.start < startOfTomorrow
    }
  }

  static var pastPredicate: Predicate<GoogleEvent> {
    let now = Date()
    let startOfDay = Calendar.current.startOfDay(for: now)

    return #Predicate<GoogleEvent> {
      $0.calendar.isEnabled && $0.end < now && $0.start >= startOfDay
    }
  }

  static var currentsPredicate: Predicate<GoogleEvent> {
    let now = Date()

    return #Predicate<GoogleEvent> {
      $0.calendar.isEnabled && $0.start <= now && $0.end > now
    }
  }

  static var todaysPredicate: Predicate<GoogleEvent> {
    let startOfDay = Calendar.current.startOfDay(for: Date())
    let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

    return #Predicate<GoogleEvent> { event in
      event.calendar.isEnabled && event.start >= startOfDay && event.start < endOfDay
    }
  }

  static var tomorrowsPredicate: Predicate<GoogleEvent> {
    let startOfTomorrow = Calendar.current.date(
      byAdding: .day,
      value: 1,
      to: Calendar.current.startOfDay(for: Date())
    )!
    let startOfDayAfterTomorrow = Calendar.current.date(
      byAdding: .day, value: 1, to: startOfTomorrow)!

    return #Predicate<GoogleEvent> { event in
      event.calendar.isEnabled && event.start >= startOfTomorrow
        && event.start < startOfDayAfterTomorrow
    }
  }
}

extension GoogleEvent {
  func isHappening() -> Bool {
    self.start < Date() && self.end > Date()
  }

  func hasPassed() -> Bool {
    self.end < Date()
  }

  func getHtmlLinkWithAuthUser() -> URL {
    let urlQueryItem = URLQueryItem(name: "authuser", value: self.calendar.account.email)
    let urlQueryItems: [URLQueryItem] = [urlQueryItem]

    return URL(string: self.htmlLink)!
      .appending(queryItems: urlQueryItems)
  }

  func getLinkDestination() -> URL? {
    let urlQueryItem = URLQueryItem(name: "authuser", value: self.calendar.account.email)
    let urlQueryItems: [URLQueryItem] = [urlQueryItem]

    if let meetLink = self.meetLink {
      return URL(string: meetLink)!
        .appending(queryItems: urlQueryItems)
    }

    return nil
  }

  func getStartHour() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.dateStyle = .none

    return dateFormatter.string(from: self.start)
  }

  func getEndHour() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.dateStyle = .none

    return dateFormatter.string(from: self.end)
  }

  func getMinutesUntilEvent(currentTime: Date) -> Int {
    let calendar = Calendar.current
    return calendar.dateComponents([.minute], from: currentTime, to: self.start).minute ?? 0
  }

  func getMenuBarString(currentTime: Date) -> String {
    let isOnEvent = self.start <= currentTime && self.end >= currentTime
    let time =
      isOnEvent
      ? self.getTimeUntilEndFormatted(to: currentTime)
      : self.getTimeUntilEventFormatted(from: currentTime)
    let timeToEndString = "\(time) \(LocalizedString.localized("left"))"
    let timeUntilString = "\(LocalizedString.localized("in")) \(time)"
    let stringToUse = isOnEvent ? timeToEndString : timeUntilString

    let result = "\(self.title.truncated()) (\(stringToUse))"

    return result
  }
}

extension Collection where Element == GoogleEvent {
  func getCurrentOrNextEvent() -> GoogleEvent? {
    let now = Date()

    if let currentEvent = self.first(where: {
      now >= $0.start && now <= $0.end
    }) {
      return currentEvent
    }

    return
      self
      .filter { $0.start > now }
      .min { $0.start < $1.start }
      .self
  }
}

extension GoogleEvent {
  // A single function to handle all relative time formatting
  fileprivate func getRelativeTimeString(from startDate: Date, to endDate: Date) -> String {
    // Get the interval in seconds between the two dates
    let interval = endDate.timeIntervalSince(startDate)

    // Use absolute value since the time could be in the future (positive) or past (negative)
    let absoluteInterval = abs(interval)

    // Round up to the nearest second
    let totalSeconds = Int(ceil(absoluteInterval))

    if totalSeconds <= 0 {
      return "0s"
    }

    let secondsInMinute = 60
    let secondsInHour = 60 * secondsInMinute
    let secondsInDay = 24 * secondsInHour

    let days = totalSeconds / secondsInDay
    if days > 0 {
      return "\(days)d"
    }

    let hours = totalSeconds / secondsInHour
    if hours > 0 {
      let remainingMinutes = (totalSeconds % secondsInHour) / secondsInMinute
      // Use a local variable for the formatted string
      let formattedString = "\(hours)h \(remainingMinutes)m"
      return formattedString
    }

    let minutes = totalSeconds / secondsInMinute
    if minutes > 0 {
      return "\(minutes)m"
    }

    return "\(totalSeconds)s"
  }

  fileprivate func getTimeUntilEndFormatted(to currentTime: Date) -> String {
    // For time left in an event, we want time from current to end
    return getRelativeTimeString(from: currentTime, to: self.end)
  }

  fileprivate func getTimeUntilEventFormatted(from currentTime: Date) -> String {
    // For time until an event starts, we want time from current to start
    return getRelativeTimeString(from: currentTime, to: self.start)
  }
}
