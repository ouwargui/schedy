import AppKit
import Foundation
import SwiftData
@preconcurrency
import UserNotifications

let EVENT_NOTIFICATION_PREFIX = "event-"

@MainActor
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
  static let shared = NotificationManager()

  private override init() {
    super.init()
  }

  func setup() {
    UNUserNotificationCenter.current().delegate = self
  }

  func requestAuthorization() {
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
        if let error = error {
          print("Notification authorization error: \(error)")
        }
      }
  }

  var isEnabled: Bool {
    UserDefaults.standard.bool(forKey: "notifications-enabled")
  }

  var minutesBefore: Int {
    UserDefaults.standard.integer(forKey: "notification-timing")
  }

  func scheduleNotifications(for events: [GoogleEvent]) {
    guard isEnabled else {
      removeAllEventNotifications()
      return
    }

    let center = UNUserNotificationCenter.current()

    // Collect event info on main actor before going off-main
    let minutesBefore = self.minutesBefore
    let eventInfos: [(id: String, title: String, start: Date, meetLink: String?, htmlLink: String, accountEmail: String)] = events.map { event in
      (
        id: event.googleId,
        title: event.title,
        start: event.start,
        meetLink: event.meetLink,
        htmlLink: event.htmlLink,
        accountEmail: event.calendar.account.email
      )
    }

    center.getPendingNotificationRequests { requests in
      let eventIds = requests
        .filter { $0.identifier.hasPrefix(EVENT_NOTIFICATION_PREFIX) }
        .map { $0.identifier }
      center.removePendingNotificationRequests(withIdentifiers: eventIds)

      for info in eventInfos {
        guard
          let notificationDate = Calendar.current.date(
            byAdding: .minute, value: -minutesBefore, to: info.start)
        else { continue }

        guard notificationDate > Date() else { continue }

        let content = UNMutableNotificationContent()
        content.title = info.title

        if minutesBefore == 0 {
          content.body = "Starting now"
        } else {
          content.body =
            "Starting in \(minutesBefore) minute\(minutesBefore == 1 ? "" : "s")"
        }

        content.sound = .default

        var userInfo: [String: String] = [
          "eventId": info.id,
          "htmlLink": info.htmlLink,
          "accountEmail": info.accountEmail,
        ]
        if let meetLink = info.meetLink {
          userInfo["meetLink"] = meetLink
        }
        content.userInfo = userInfo

        let components = Calendar.current.dateComponents(
          [.year, .month, .day, .hour, .minute, .second], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let identifier = "\(EVENT_NOTIFICATION_PREFIX)\(info.id)"
        let request = UNNotificationRequest(
          identifier: identifier, content: content, trigger: trigger)

        center.add(request)
      }
    }
  }

  func removeAllEventNotifications() {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { requests in
      let eventIds = requests
        .filter { $0.identifier.hasPrefix(EVENT_NOTIFICATION_PREFIX) }
        .map { $0.identifier }
      center.removePendingNotificationRequests(withIdentifiers: eventIds)
    }
    center.getDeliveredNotifications { notifications in
      let eventIds = notifications
        .filter { $0.request.identifier.hasPrefix(EVENT_NOTIFICATION_PREFIX) }
        .map { $0.request.identifier }
      center.removeDeliveredNotifications(withIdentifiers: eventIds)
    }
  }

  func rescheduleNotifications() {
    let nextDescriptor = FetchDescriptor<GoogleEvent>(
      predicate: GoogleEvent.todaysNextPredicate,
      sortBy: [SortDescriptor(\.start)]
    )

    let tomorrowDescriptor = FetchDescriptor<GoogleEvent>(
      predicate: GoogleEvent.tomorrowsPredicate,
      sortBy: [SortDescriptor(\.start)]
    )

    let nextEvents =
      SwiftDataManager.shared.fetchAll(fetchDescriptor: nextDescriptor).unwrapOrNil() ?? []
    let tomorrowEvents =
      SwiftDataManager.shared.fetchAll(fetchDescriptor: tomorrowDescriptor).unwrapOrNil() ?? []

    scheduleNotifications(for: nextEvents + tomorrowEvents)
  }

  // MARK: - UNUserNotificationCenterDelegate

  nonisolated func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let identifier = response.notification.request.identifier

    if identifier == UPDATE_NOTIFICATION_IDENTIFIER {
      Task { @MainActor in
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
          appDelegate.appStateManager.updaterController?.checkForUpdates(nil)
        }
      }
    } else if identifier.hasPrefix(EVENT_NOTIFICATION_PREFIX) {
      if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
        let userInfo = response.notification.request.content.userInfo

        let accountEmail = userInfo["accountEmail"] as? String ?? ""
        let authQuery = URLQueryItem(name: "authuser", value: accountEmail)

        if let meetLink = userInfo["meetLink"] as? String,
          let url = URL(string: meetLink)
        {  // swiftlint:disable:this opening_brace
          NSWorkspace.shared.open(url.appending(queryItems: [authQuery]))
        } else if let htmlLink = userInfo["htmlLink"] as? String,
          let url = URL(string: htmlLink)
        {  // swiftlint:disable:this opening_brace
          NSWorkspace.shared.open(url.appending(queryItems: [authQuery]))
        }
      }
    }

    completionHandler()
  }

  nonisolated func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show notification banner even when app is in foreground
    // (menu bar apps are effectively always in foreground)
    completionHandler([.banner, .sound])
  }
}
