//
//  AppDelegate.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import AppAuthCore
import AppKit
import Sentry
import Sparkle
import SwiftData
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var shouldQuit = false
    let updaterController: SPUStandardUpdaterController
    @State var isUpdateAvailable: Bool = false
    @State var updateData: SUAppcastItem?

    override init() {
        self.updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.setEventHandlers()
        self.startSyncingUsers()
    }

    @MainActor
    private func startSyncingUsers() {
        let result = SwiftDataManager.shared.fetchAll(
            fetchDescriptor: FetchDescriptor<GoogleUser>())

        if case .failure(let error) = result {
            SentrySDK.capture(error: error)
        }

        if case .success(let users) = result {
            users.forEach({ user in
                user.startSync()
            })
        }
    }

    private func setEventHandlers() {
        NSAppleEventManager.shared()
            .setEventHandler(
                self,
                andSelector: #selector(self.handleUrlEvent(getURLEvent:replyEvent:)),
                forEventClass: AEEventClass(kInternetEventClass),
                andEventID: AEEventID(kAEGetURL)
            )
    }

    func applicationWillTerminate(_ notification: Notification) {
        let result = SwiftDataManager.shared.fetchAll(
            fetchDescriptor: FetchDescriptor<GoogleUser>())

        if case .failure(let error) = result {
            SentrySDK.capture(error: error)
            return
        }

        if case .success(let users) = result {
            users.forEach({ user in
                user.stopSync()
            })
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if self.shouldQuit {
            return .terminateNow
        } else {
            NotificationCenter.default.post(
                name: NSNotification.Name("close-settings"), object: self)
            NSApplication.shared.setActivationPolicy(.accessory)
            return .terminateCancel
        }
    }

    @objc
    private func handleUrlEvent(
        getURLEvent event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor
    ) {
        if let string = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
           let url = URL(string: string) {
               self.currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url)
           }
    }
}

let UPDATE_NOTIFICATION_IDENTIFIER = "UpdateCheck"

extension AppDelegate: SPUUpdaterDelegate, SPUStandardUserDriverDelegate, UNUserNotificationCenterDelegate {
    var supportsGentleScheduledUpdateReminders: Bool {
        return true
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

        self.isUpdateAvailable = true
        self.updateData = update

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
        self.isUpdateAvailable = false
        self.updateData = nil
        NotificationCenter.default.post(name: NSNotification.Name("close-settings"), object: self)
        NSApp.setActivationPolicy(.accessory)
    }

    func updaterWillRelaunchApplication(_ updater: SPUUpdater) {
        self.shouldQuit = true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == UPDATE_NOTIFICATION_IDENTIFIER && response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // If the notificaton is clicked on, make sure we bring the update in focus
            // If the app is terminated while the notification is clicked on,
            // this will launch the application and perform a new update check.
            // This can be more likely to occur if the notification alert style is Alert rather than Banner
            updaterController.checkForUpdates(nil)
        }

        completionHandler()
    }
}
