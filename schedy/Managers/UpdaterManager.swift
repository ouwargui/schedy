//
//  UpdaterManager.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 17/04/25.
//

import Foundation
import Sparkle
import AppKit
import UserNotifications

let UPDATE_NOTIFICATION_IDENTIFIER = "UpdateCheck"

class UpdaterManager: NSObject, SPUUpdaterDelegate, SPUStandardUserDriverDelegate, NSUserNotificationCenterDelegate {
    let appStateManager: AppStateManager

    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
    }

    var supportsGentleScheduledUpdateReminders: Bool {
        return true
    }

    func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        let allowedBetaUpdates = UserDefaults.standard.bool(forKey: "allowed-beta-updates")
        if (allowedBetaUpdates) {
            return Set(["beta"])
        } else {
            return Set([])
        }
    }

    func updater(_ updater: SPUUpdater, willScheduleUpdateCheckAfterDelay delay: TimeInterval) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
            // Examine granted outcome and error if desired...
        }
    }

    func standardUserDriverShouldHandleShowingScheduledUpdate(_ update: SUAppcastItem, andInImmediateFocus immediateFocus: Bool) -> Bool {
        // If the standard user driver will show the update in immediate focus (e.g. near app launch),
        // then let Sparkle take care of showing the update.
        // Otherwise we will handle showing any other scheduled updates
        return immediateFocus
    }

    func standardUserDriverWillHandleShowingUpdate(_ handleShowingUpdate: Bool, forUpdate update: SUAppcastItem, state: SPUUserUpdateState) {
        guard !handleShowingUpdate else { return }

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

                let request = UNNotificationRequest(identifier: UPDATE_NOTIFICATION_IDENTIFIER, content: content, trigger: nil)

                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        // Clear the dock badge indicator for the update
        NSApp.dockTile.badgeLabel = ""

        // Dismiss active update notifications if the user has given attention to the new update
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [UPDATE_NOTIFICATION_IDENTIFIER])
    }

    func standardUserDriverWillFinishUpdateSession() {
        self.appStateManager.isUpdateAvailable = false
        self.appStateManager.updateData = nil
        NotificationCenter.default.post(name: NSNotification.Name("close-settings"), object: self)
        NSApp.setActivationPolicy(.accessory)
    }

    func updaterWillRelaunchApplication(_ updater: SPUUpdater) {
        self.appStateManager.shouldQuit = true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == UPDATE_NOTIFICATION_IDENTIFIER && response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // If the notificaton is clicked on, make sure we bring the update in focus
            // If the app is terminated while the notification is clicked on,
            // this will launch the application and perform a new update check.
            // This can be more likely to occur if the notification alert style is Alert rather than Banner
            self.appStateManager.updaterController?.checkForUpdates(nil)
        }

        completionHandler()
    }
}
