//
//  schedyApp.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 28/11/24.
//

import SwiftUI
import Sentry

@main
struct SchedyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        SentrySDK.start { options in
            options.dsn = Constants.sentryIngestUrl
            options.debug = false

            options.tracesSampler = { context in
                if context.transactionContext.name == "update-earlier-events" {
                    return 0.1
                } else {
                    return 1
                }
            }
            options.enableAppLaunchProfiling = true
            options.enableAutoPerformanceTracing = true
            options.enableCrashHandler = true
            options.enableUncaughtNSExceptionReporting = true
        }

        SentrySDK.startProfiler()
    }

    var body: some Scene {
        MenuBarView()
            .environmentObject(appDelegate)
            .modelContainer(SwiftDataManager.shared.container)

        Window("Settings", id: "settings") {
            MainWindowView(updater: self.appDelegate.appStateManager.updaterController?.updater)
        }
        .commands {
            if let updater = self.appDelegate.appStateManager.updaterController?.updater {
                CommandGroup(after: .appInfo) {
                    CheckForUpdatesView(updater: updater)
                }
            }

            SidebarCommands()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .environmentObject(appDelegate)
        .modelContainer(SwiftDataManager.shared.container)
    }
}
