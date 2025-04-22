import Foundation
import SwiftUI
import SwiftData
import SentrySwiftUI

struct MenuBarView: Scene {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var appDelegate: AppDelegate
    @ObservedObject private var viewModel: MenuBarViewModel = MenuBarViewModel()

    var body: some Scene {
        MenuBarExtra(
            self.viewModel.titleBarEvent?.getMenuBarString(
                currentTime: self.viewModel.currentTime
            ) ?? "Schedy"
        ) {
            if self.viewModel.isThereAnyEvents {
                if !self.viewModel.todaysPastEvents.isEmpty {
                    MenuBarItemListView(
                        sectionTitle: "\(LocalizedString.capitalized("earlier today"))",
                        events: self.viewModel.todaysPastEvents,
                        currentEvent: self.viewModel.titleBarEvent
                    )

                    Divider()
                }

                if !self.viewModel.currentEvents.isEmpty {
                    MenuBarItemListView(
                        sectionTitle: "\(LocalizedString.capitalized("now"))",
                        events: self.viewModel.currentEvents,
                        currentEvent: self.viewModel.titleBarEvent
                    )

                    Divider()
                }

                if !self.viewModel.todaysNextEvents.isEmpty {
                    MenuBarItemListView(
                        sectionTitle: "\(LocalizedString.capitalized("next")):",
                        events: self.viewModel.todaysNextEvents,
                        currentEvent: self.viewModel.titleBarEvent
                    )

                    Divider()
                }

                if !self.viewModel.tomorrowsEvents.isEmpty {
                    MenuBarItemListView(
                        sectionTitle: "\(LocalizedString.capitalized("tomorrow")) (\(self.viewModel.tomorrowFormatted)):",
                        events: self.viewModel.tomorrowsEvents,
                        currentEvent: self.viewModel.titleBarEvent
                    )

                    Divider()
                }
            } else {
                Text("You don't have any events for now")

                Divider()
            }

            if self.appDelegate.appStateManager.isUpdateAvailable {
                Button("Version \(self.appDelegate.appStateManager.updateData?.versionString ?? "") available!") {
                    self.appDelegate.appStateManager.updaterController?.checkForUpdates(nil)
                }
            } else {
                Button("Check for updates") {
                    self.appDelegate.appStateManager.updaterController?.checkForUpdates(nil)
                }
            }

            Divider()

            Button("Settings") {
                NSApplication.shared.setActivationPolicy(.regular)
                openWindow(id: "settings")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            }.keyboardShortcut(",", modifiers: [.command, .shift])

            Button(LocalizedString.capitalized("quit"), action: self.quitApp)
                .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
    }

    func quitApp() {
        self.appDelegate.shouldQuit = true
        NSApplication.shared.terminate(nil)
    }
}
