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

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var shouldQuit = false
    let updaterController: SPUStandardUpdaterController

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

extension AppDelegate: SPUUpdaterDelegate, SPUStandardUserDriverDelegate {
    func updaterWillRelaunchApplication(_ updater: SPUUpdater) {
        self.shouldQuit = true
    }
}
