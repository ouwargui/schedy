import SwiftUI
import Sentry

@main
struct SchedyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        SentrySDK.start { options in
            options.dsn = Constants.sentryIngestUrl
#if DEBUG
            options.debug = true
            options.environment = "Debug"
#else
            options.debug = false
            options.environment = Bundle.main.isBeta ? "Beta" : "Production"
#endif
            options.tracesSampleRate = 0.1
            options.configureProfiling = {
                $0.sessionSampleRate = 0.1
                $0.lifecycle = .trace
            }
            options.enableAutoPerformanceTracing = true
            options.enableCrashHandler = true
            options.enableUncaughtNSExceptionReporting = true
        }
    }

    var body: some Scene {
        MenuBarView()
            .environmentObject(appDelegate)
            .modelContainer(SwiftDataManager.shared.container)

        Window("Settings", id: "settings") {
            MainWindowView(updater: self.appDelegate.appStateManager.updaterController?.updater)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(appDelegate: appDelegate)
            }

            SidebarCommands()
        }
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .environmentObject(appDelegate)
        .modelContainer(SwiftDataManager.shared.container)
    }
}
