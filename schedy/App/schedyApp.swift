//
//  schedyApp.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 28/11/24.
//

import SwiftUI
import Sentry

@main
struct schedyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        SentrySDK.start { options in
            options.dsn = "https://9c3d6ee2586dbfa3a58e08fdeff5fa64@o4508453036359680.ingest.us.sentry.io/4508453145018368"
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
            MainWindowView()
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: self.appDelegate.updaterController.updater)
            }
            
            SidebarCommands()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .environmentObject(appDelegate)
        .modelContainer(SwiftDataManager.shared.container)
    }
}
