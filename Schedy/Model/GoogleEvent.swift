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
    self.title = event.summary!
    self.start = ISO8601DateFormatter().date(from: event.start!.dateTime!.stringValue)!
    self.end = ISO8601DateFormatter().date(from: event.end!.dateTime!.stringValue)!
    self.meetLink = event.hangoutLink
    self.htmlLink = event.htmlLink!
    self.eventDescription = event.descriptionProperty
    self.calendar = calendar
  }

  func update(event: GTLRCalendar_Event) {
    self.googleId = event.identifier!
    self.title = event.summary!
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
  fileprivate func getTimeUntilEndFormatted(to toEnd: Date) -> String {
    let calendar = Calendar.current

    let components = calendar.dateComponents(
      [.day, .hour, .minute, .second], from: self.end, to: toEnd)

    var result = ""
    if let days = components.day, days < 0 {
      result += "\(abs(days))d "
    }

    if let hours = components.hour, hours < 0 {
      result += "\(abs(hours))h "
    }

    if let minutes = components.minute, minutes < 0 {
      result += "\(abs(minutes))m"
    } else {
      if let seconds = components.second {
        result += "\(abs(seconds))s"
      }
    }

    return result.trimmingCharacters(in: .whitespaces)
  }

  fileprivate func getTimeUntilEventFormatted(from fromDate: Date) -> String {
    let calendar = Calendar.current

    let components = calendar.dateComponents(
      [.day, .hour, .minute], from: fromDate, to: self.start)

    var result = ""
    if let days = components.day, days > 0 {
      result += "\(abs(days))d "
    }

    if let hours = components.hour, hours > 0 {
      result += "\(abs(hours))h "
    }

    if let minutes = components.minute, minutes > 0 {
      result += "\(abs(minutes))m"
    } else {
      if let seconds = components.second {
        result += "\(abs(seconds))s"
      }
    }

    return result.trimmingCharacters(in: .whitespaces)
  }
}
