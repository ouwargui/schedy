import SwiftUI

@main
struct SchedyApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
