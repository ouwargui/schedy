import AppAuthCore
import AppKit
import Sentry
import Sparkle
import SwiftData
import SwiftUI
import UserNotifications

class AppStateManager: ObservableObject {
    var shouldQuit = false
    var updaterController: SPUStandardUpdaterController?
    @State var isUpdateAvailable: Bool = false
    @State var updateData: SUAppcastItem?
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var shouldQuit = false
    let updaterDelegate: UpdaterManager
    let appStateManager: AppStateManager

    override init() {
        self.appStateManager = AppStateManager()
        self.updaterDelegate = UpdaterManager(appStateManager: appStateManager)
        self.appStateManager.updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: updaterDelegate,
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
