import Foundation
import SwiftData
import SwiftUI

struct MenuBarView: Scene {
  @Environment(\.openWindow) private var openWindow
  @EnvironmentObject private var appDelegate: AppDelegate
  @StateObject private var viewModel: MenuBarViewModel = MenuBarViewModel()

  var body: some Scene {
    MenuBarExtra(
      self.viewModel.menuBarTitle(currentTime: self.viewModel.currentTime)
    ) {
      if self.viewModel.isThereAnyEvents {
        if !self.viewModel.todaysPastEvents.isEmpty {
          MenuBarItemListView(
            sectionTitle: "\(LocalizedString.capitalized("earlier today"))",
            events: self.viewModel.todaysPastEvents,
            currentEvent: self.viewModel.titleBarEvent,
            isUpdatingResponse: self.viewModel.isUpdatingResponse,
            updateResponse: self.updateResponse
          )

          Divider()
        }

        if !self.viewModel.currentEvents.isEmpty {
          MenuBarItemListView(
            sectionTitle: "\(LocalizedString.capitalized("now"))",
            events: self.viewModel.currentEvents,
            currentEvent: self.viewModel.titleBarEvent,
            isUpdatingResponse: self.viewModel.isUpdatingResponse,
            updateResponse: self.updateResponse
          )

          Divider()
        }

        if !self.viewModel.todaysNextEvents.isEmpty {
          MenuBarItemListView(
            sectionTitle: "\(LocalizedString.capitalized("next")):",
            events: self.viewModel.todaysNextEvents,
            currentEvent: self.viewModel.titleBarEvent,
            isUpdatingResponse: self.viewModel.isUpdatingResponse,
            updateResponse: self.updateResponse
          )

          Divider()
        }

        if !self.viewModel.tomorrowsEvents.isEmpty {
          MenuBarItemListView(
            sectionTitle:
              "\(LocalizedString.capitalized("tomorrow")) (\(self.viewModel.tomorrowFormatted)):",
            events: self.viewModel.tomorrowsEvents,
            currentEvent: self.viewModel.titleBarEvent,
            isUpdatingResponse: self.viewModel.isUpdatingResponse,
            updateResponse: self.updateResponse
          )

          Divider()
        }
      } else {
        Text("You don't have any events for now")

        Divider()
      }

      CheckForUpdatesView(appDelegate: self.appDelegate)

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
    self.appDelegate.appStateManager.shouldQuit = true
    NSApplication.shared.terminate(nil)
  }

  func updateResponse(event: GoogleEvent, responseStatus: GoogleEventResponseStatus) {
    self.viewModel.updateResponse(
      for: event,
      to: responseStatus,
      appDelegate: self.appDelegate
    )
  }
}
