import AppKit
import Foundation
import KeyboardShortcuts
import SwiftData
import SwiftUI

let MENU_BAR_REFRESH_INTERVAL: TimeInterval = 1

@MainActor
class MenuBarViewModel: ObservableObject {
  @Published private(set) var currentTime = Date()
  @Published var todaysPastEvents: [GoogleEvent] = []
  @Published var currentEvent: GoogleEvent?
  @Published var currentEvents: [GoogleEvent] = []
  @Published var todaysNextEvents: [GoogleEvent] = []
  @Published var todaysEvents: [GoogleEvent] = []
  @Published var tomorrowsEvents: [GoogleEvent] = []
  @Published private var eventIdsUpdatingResponse = Set<String>()
  private var timer: Timer?
  private var isMenuOpen = false
  private var lastMenuBarTitle: String?

  var tomorrow: Date {
    return Calendar.current.date(byAdding: .day, value: 1, to: self.currentTime)!
  }

  var todayFormatted: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM"
    formatter.locale = Locale.current
    return formatter.string(from: self.currentTime)
  }

  var tomorrowFormatted: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM"
    formatter.locale = Locale.current
    return formatter.string(from: self.tomorrow)
  }

  var todaysEventsWithoutCurrent: [GoogleEvent] {
    let currentEventGoogleId = self.currentEvent?.googleId ?? ""
    if let eventsWithouCurrent = try? self.todaysEvents.filter(
      #Predicate<GoogleEvent> {
        $0.googleId != currentEventGoogleId
      })
    {  // swiftlint:disable:this opening_brace
      return eventsWithouCurrent
    }

    return self.todaysEvents
  }

  var isThereAnyEvents: Bool {
    return !self.todaysEvents.isEmpty || !self.tomorrowsEvents.isEmpty
  }

  var titleBarEvent: GoogleEvent? {
    self.getTitleBarEvent(currentTime: self.currentTime)
  }

  func menuBarTitle(currentTime: Date) -> String {
    self.getTitleBarEvent(currentTime: currentTime)?.getMenuBarString(
      currentTime: currentTime
    ) ?? "Schedy"
  }

  private func getTitleBarEvent(currentTime: Date) -> GoogleEvent? {
    if let todaysNextEventsFirst = self.todaysNextEvents.first,
      todaysNextEventsFirst.getMinutesUntilEvent(currentTime: currentTime) < 15
    {  // swiftlint:disable:this opening_brace
      return todaysNextEventsFirst
    }

    return self.currentEvent ?? self.todaysNextEvents.first
  }

  init() {
    KeyboardShortcuts
      .onKeyUp(for: .openEventUrl) { [weak self] in
        guard let self = self else { return }
        print("got open event url shortcut")
        if let currentEvent = self.titleBarEvent {
          NSWorkspace.shared.open(
            currentEvent.getLinkDestination() ?? currentEvent.getHtmlLinkWithAuthUser())
        }
      }

    Task {
      self.update()
    }

    self.observeMenuTracking()

    timer = Timer.scheduledTimer(withTimeInterval: MENU_BAR_REFRESH_INTERVAL, repeats: true) {
      [weak self] _ in
      guard let self = self else { return }
      Task {
        if self.isMenuOpen {
          self.updateMenuBarTitle()
        } else {
          self.update()
        }
      }
    }
  }

  func isUpdatingResponse(for event: GoogleEvent) -> Bool {
    self.eventIdsUpdatingResponse.contains(self.responseUpdateKey(for: event))
  }

  func updateResponse(
    for event: GoogleEvent,
    to responseStatus: GoogleEventResponseStatus,
    appDelegate: AppDelegate
  ) {
    let key = self.responseUpdateKey(for: event)
    guard !self.eventIdsUpdatingResponse.contains(key) else { return }

    self.eventIdsUpdatingResponse.insert(key)

    Task { @MainActor in
      defer {
        self.eventIdsUpdatingResponse.remove(key)
      }

      guard let attendeeEmail = event.invitationAttendeeEmail else {
        print("Failed to update event RSVP: missing attendee email")
        return
      }

      let hasPermission = await self.ensureCalendarWriteAccess(
        for: event.calendar.account,
        appDelegate: appDelegate
      )

      guard hasPermission else { return }

      do {
        let updatedEvent = try await GoogleCalendarService.shared.updateEventResponse(
          eventId: event.googleId,
          calendarId: event.calendar.googleId,
          attendeeEmail: attendeeEmail,
          responseStatus: responseStatus,
          fetcherAuthorizer: event.calendar.account.getSession()
        )

        event.update(event: updatedEvent)
        SwiftDataManager.shared.update()
      } catch let error {
        print("Failed to update event RSVP: \(error.localizedDescription)")
      }
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    timer?.invalidate()
    timer = nil
  }

  private func update() {
    self.currentTime = Date()
    self.updateEarlierEvents()
    self.updateCurrentEvent()
    self.updateTodaysEvents()
    self.updateTodaysNextEvents()
    self.updateTomorrowsEvents()
    self.lastMenuBarTitle = self.menuBarTitle(currentTime: self.currentTime)
  }

  private func updateMenuBarTitle() {
    let title = self.menuBarTitle(currentTime: Date())

    MenuBarStatusItemUpdater.updateTitle(title, matchingPreviousTitle: self.lastMenuBarTitle)
    self.lastMenuBarTitle = title
  }

  private func observeMenuTracking() {
    NotificationCenter.default.addObserver(
      forName: NSMenu.didBeginTrackingNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.isMenuOpen = true
      }
    }

    NotificationCenter.default.addObserver(
      forName: NSMenu.didEndTrackingNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.isMenuOpen = false
        self?.update()
      }
    }
  }

  private func responseUpdateKey(for event: GoogleEvent) -> String {
    "\(event.calendar.googleId):\(event.googleId)"
  }

  private func ensureCalendarWriteAccess(
    for user: GoogleUser,
    appDelegate: AppDelegate
  ) async -> Bool {
    if GoogleAuthService.shared.hasCalendarWriteAccess(user: user) {
      return true
    }

    guard self.confirmCalendarWriteAccessRequest() else {
      return false
    }

    return await GoogleAuthService.shared.requestCalendarWriteAccess(
      user: user,
      appDelegate: appDelegate
    )
  }

  private func confirmCalendarWriteAccessRequest() -> Bool {
    let alert = NSAlert()
    alert.messageText = "Allow Schedy to update invitations?"
    alert.informativeText =
      "Schedy needs permission to update your Google Calendar RSVP when you accept, maybe, or decline an invitation."
    alert.alertStyle = .informational
    alert.addButton(withTitle: "Continue")
    alert.addButton(withTitle: "Cancel")

    return alert.runModal() == .alertFirstButtonReturn
  }

  private func updateEarlierEvents() {
    let descriptor = FetchDescriptor<GoogleEvent>(
      predicate: GoogleEvent.pastPredicate,
      sortBy: [SortDescriptor(\.start)]
    )

    guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil()
    else {
      return
    }

    self.todaysPastEvents = events
  }

  private func updateCurrentEvent() {
    let descriptor = FetchDescriptor<GoogleEvent>(
      predicate: GoogleEvent.currentsPredicate,
      sortBy: [SortDescriptor(\.end)]
    )

    guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil()
    else {
      return
    }

    self.currentEvent = events.first
    self.currentEvents = events
  }

  private func updateTodaysNextEvents() {
    let descriptor = FetchDescriptor<GoogleEvent>(
      predicate: GoogleEvent.todaysNextPredicate,
      sortBy: [SortDescriptor(\.start)]
    )

    guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil()
    else {
      return
    }

    self.todaysNextEvents = events
  }

  private func updateTodaysEvents() {
    let descriptor = FetchDescriptor<GoogleEvent>(
      predicate: GoogleEvent.todaysPredicate,
      sortBy: [SortDescriptor(\.start)]
    )

    guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil()
    else {
      return
    }

    self.todaysEvents = events
  }

  private func updateTomorrowsEvents() {
    let descriptor = FetchDescriptor<GoogleEvent>(
      predicate: GoogleEvent.tomorrowsPredicate,
      sortBy: [SortDescriptor(\.start)]
    )

    guard let events = SwiftDataManager.shared.fetchAll(fetchDescriptor: descriptor).unwrapOrNil()
    else {
      return
    }

    self.tomorrowsEvents = events
  }
}
