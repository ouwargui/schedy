import Foundation
import GTMAppAuth
import GoogleAPIClientForREST_Calendar
import Sentry
import SwiftData

let DEFAULT_TIME_INTERVAL: TimeInterval = 30
let THREE_HOURS_IN_SECONDS: TimeInterval = 10_800

@MainActor
class CalendarSyncManager {
  private let service: CalendarServiceProtocol
  private let dataManager: DataManaging
  private let timerInterval: TimeInterval

  private var timer: Timer?
  private var eventSyncTokens = [String: String]()
  private var calendarSyncToken: String?
  private var timePassedSinceFirstSync: TimeInterval = 0

  private var user: GoogleUser

  init(
    user: GoogleUser,
    service: CalendarServiceProtocol? = nil,
    dataManager: DataManaging? = nil,
    timerInterval: TimeInterval = DEFAULT_TIME_INTERVAL
  ) {
    self.user = user
    self.service = service ?? GoogleCalendarService.shared
    self.dataManager = dataManager ?? SwiftDataManager.shared
    self.timerInterval = timerInterval
  }

  func startSync() {
    Task {
      print("started syncing")
      await self.performCalendarSync()
      await self.performEventsSync()
      self.deleteOldEvents()
      self.user.lastSyncedAt = Date()
    }

    timer = Timer.scheduledTimer(withTimeInterval: self.timerInterval, repeats: true) {
      [weak self] _ in
      guard let self = self else { return }
      print("syncing")
      Task { @MainActor in
        await self.performCalendarSync()
        await self.performEventsSync()

        self.timePassedSinceFirstSync += self.timerInterval

        if self.timePassedSinceFirstSync >= THREE_HOURS_IN_SECONDS {
          self.deleteOldEvents()
        }

        self.user.lastSyncedAt = Date()
      }
    }
  }

  func stopSync() {
    print("stopped syncing")
    timer?.invalidate()
    timer = nil
  }

  private func performCalendarSync() async {
    guard
      let calendars = try? await GoogleCalendarService.shared.fetchUserCalendars(
        fetcherAuthorizer: user.getSession(),
        syncToken: self.calendarSyncToken
      )
    else {
      return
    }

    self.calendarSyncToken = calendars.nextSyncToken

    self.processCalendars(calendars.items ?? [])
  }

  private func performEventsSync() async {
    let calendars = user.calendars

    await withTaskGroup(of: Void.self) { [weak self] group in
      guard let self = self else { return }
      for calendar in calendars {
        group.addTask { @MainActor in
          guard
            let events = try? await GoogleCalendarService.shared.fetchEvents(
              for: calendar.googleId,
              fetcherAuthorizer: self.user.getSession(),
              syncToken: self.eventSyncTokens[calendar.googleId]
            )
          else {
            return
          }

          self.eventSyncTokens[calendar.googleId] = events.nextSyncToken

          self.processEvents(events.items ?? [], for: calendar)
        }
      }

      await group.waitForAll()
    }
  }

  @MainActor
  private func processCalendars(_ calendars: [GTLRCalendar_CalendarListEntry]) {
    let storedCalendars = user.calendars

    for calendar in calendars {
      if calendar.deleted == true {
        self.handleCalendarDeleted(storedCalendars: storedCalendars, calendar: calendar)
      } else {
        self.handleChangedCalendar(storedCalendars: storedCalendars, calendar: calendar)
      }
    }
  }

  @MainActor
  private func handleCalendarDeleted(
    storedCalendars: [GoogleCalendar], calendar: GTLRCalendar_CalendarListEntry
  ) {
    if let storedCalendar = storedCalendars.first(where: {
      $0.googleId == calendar.identifier!
    }) {
      self.dataManager.delete(model: storedCalendar)
    }
  }

  @MainActor
  private func handleChangedCalendar(
    storedCalendars: [GoogleCalendar], calendar: GTLRCalendar_CalendarListEntry
  ) {
    if let storedCalendar = storedCalendars.first(where: { $0.googleId == calendar.identifier }) {
      storedCalendar.update(calendar: calendar)
      self.dataManager.update()
    } else {
      let newCalendar = GoogleCalendar(calendar: calendar, account: user)
      self.dataManager.insert(model: newCalendar)
    }
  }

  @MainActor
  private func processEvents(_ events: [GTLRCalendar_Event], for calendar: GoogleCalendar) {
    for event in events {
      if event.start?.dateTime == nil || event.end?.dateTime == nil {
        continue
      }

      if event.status == "cancelled" {
        self.handleCanceledEvent(event: event, calendar: calendar)
        continue
      } else {
        self.handleChangedEvent(event: event, calendar: calendar)
        continue
      }
    }
  }

  @MainActor
  private func handleCanceledEvent(event: GTLRCalendar_Event, calendar: GoogleCalendar) {
    if let storedEvent = calendar.events.first(where: {
      $0.googleId == event.identifier!
    }) {
      self.dataManager.delete(model: storedEvent)
    }
  }

  @MainActor
  private func handleChangedEvent(event: GTLRCalendar_Event, calendar: GoogleCalendar) {
    if let storedEvent = calendar.events.first(where: { $0.googleId == event.identifier }) {
      storedEvent.update(event: event)
      self.dataManager.update()
    } else {
      let newEvent = GoogleEvent(event: event, calendar: calendar)
      self.dataManager.insert(model: newEvent)
    }

    return
  }

  @MainActor
  private func deleteOldEvents() {
    let thresholdDate = Calendar.current.startOfDay(for: Date())
    let descriptor = FetchDescriptor<GoogleEvent>(
      predicate: #Predicate { event in
        event.end < thresholdDate
      }
    )

    guard let events = self.dataManager.fetchAll(fetchDescriptor: descriptor).unwrapOrNil() else {
      return
    }

    events.forEach(self.dataManager.delete)
  }
}
