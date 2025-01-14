//
//  MenuBarView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 02/12/24.
//

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
            ) ?? "schedy"
        ) {
            if self.viewModel.isThereAnyEvents {
                if !self.viewModel.todaysPastEvents.isEmpty {
                    MenuBarItemListView(
                        sectionTitle: "\(LocalizedString.capitalized("earlier today"))",
                        events: self.viewModel.todaysPastEvents
                    )

                    Divider()
                }

                if !self.viewModel.currentEvents.isEmpty {
                    MenuBarItemListView(
                        sectionTitle: "\(LocalizedString.capitalized("now"))",
                        events: self.viewModel.currentEvents
                    )

                    Divider()
                }

                if !self.viewModel.todaysNextEvents.isEmpty {
                    MenuBarItemListView(
                        sectionTitle: "\(LocalizedString.capitalized("next")):",
                        events: self.viewModel.todaysNextEvents
                    )

                    Divider()
                }

                if !self.viewModel.tomorrowsEvents.isEmpty {
                    // swiftlint:disable line_length
                    MenuBarItemListView(
                        sectionTitle: "\(LocalizedString.capitalized("tomorrow")) (\(self.viewModel.tomorrowFormatted)):",
                    // swiftlint:enable line_length
                        events: self.viewModel.tomorrowsEvents
                    )

                    Divider()
                }
            } else {
                Text("You don't have any events for now")
            }

            Button("Settings") {
                NSApplication.shared.setActivationPolicy(.regular)
                NSApplication.shared.activate()
                openWindow(id: "settings")
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
