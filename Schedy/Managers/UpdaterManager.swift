import AppKit
import Foundation
import Sparkle
import UserNotifications

let UPDATE_NOTIFICATION_IDENTIFIER = "UpdateCheck"

class UpdaterManager: NSObject, SPUUpdaterDelegate, SPUStandardUserDriverDelegate
{  // swiftlint:disable:this opening_brace
  let appStateManager: AppStateManager

  init(appStateManager: AppStateManager) {
    self.appStateManager = appStateManager
  }

  var supportsGentleScheduledUpdateReminders: Bool {
    return true
  }

  func allowedChannels(for updater: SPUUpdater) -> Set<String> {
    let allowedBetaUpdates = UserDefaults.standard.bool(forKey: "allowed-beta-updates")
    if allowedBetaUpdates {
      return Set(["beta"])
    } else {
      return Set([])
    }
  }

  func updater(_: SPUUpdater, willScheduleUpdateCheckAfterDelay delay: TimeInterval) {
    UNUserNotificationCenter
      .current()
      .requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in
        // Examine granted outcome and error if desired...
      }
  }

  func standardUserDriverShouldHandleShowingScheduledUpdate(
    _ update: SUAppcastItem, andInImmediateFocus immediateFocus: Bool
  ) -> Bool {
    // If the standard user driver will show the update in immediate focus (e.g. near app launch),
    // then let Sparkle take care of showing the update.
    // Otherwise we will handle showing any other scheduled updates
    return immediateFocus
  }

  func standardUserDriverWillHandleShowingUpdate(
    _ handleShowingUpdate: Bool, forUpdate update: SUAppcastItem, state: SPUUserUpdateState
  ) {
    self.appStateManager.isUpdateAvailable = true
    self.appStateManager.updateData = update

    NSApp.setActivationPolicy(.regular)

    if !state.userInitiated {
      // And add a badge to the app's dock icon indicating one alert occurred
      NSApp.dockTile.badgeLabel = "1"

      // Post a user notification
      // For banner style notification alerts, this may only trigger when the app is currently inactive.
      // For alert style notification alerts, this will trigger when the app is active or inactive.
      do {
        let content = UNMutableNotificationContent()
        content.title = "A new update is available"
        content.body = "Version \(update.versionString) is now available!"

        let request = UNNotificationRequest(
          identifier: UPDATE_NOTIFICATION_IDENTIFIER, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request)
      }
    }
  }

  func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
    // Clear the dock badge indicator for the update
    NSApp.dockTile.badgeLabel = ""

    // Dismiss active update notifications if the user has given attention to the new update
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [
      UPDATE_NOTIFICATION_IDENTIFIER
    ])
  }

  func standardUserDriverWillFinishUpdateSession() {
    NotificationCenter.default.post(name: NSNotification.Name("close-settings"), object: self)
    NSApp.setActivationPolicy(.accessory)
  }

  func updater(_ updater: SPUUpdater, willInstallUpdate item: SUAppcastItem) {
    self.appStateManager.shouldQuit = true
  }

  func updaterWillRelaunchApplication(_ updater: SPUUpdater) {
    self.appStateManager.shouldQuit = true
  }
}
