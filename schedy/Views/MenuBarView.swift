//
//  MenuBarView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 02/12/24.
//

import Foundation
import SwiftUI
import SwiftData

struct MenuBarView: Scene {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var appDelegate: AppDelegate
    @ObservedObject private var viewModel: MenuBarViewModel = MenuBarViewModel()
    
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self.viewModel.currentTime)!
    }
    
    var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        formatter.locale = Locale.current
        return formatter.string(from: self.viewModel.currentTime)
    }
    
    var tomorrowFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        formatter.locale = Locale.current
        return formatter.string(from: self.tomorrow)
    }
    
    var body: some Scene {
        MenuBarExtra(self.viewModel.currentEvent?.getMenuBarString(currentTime: self.viewModel.currentTime) ?? "schedy") {
            Text("\(LocalizedString.capitalized("today")) (\(self.todayFormatted)):")

            Divider()

            ForEach(self.viewModel.todaysEvents) { event in
                MenuBarItemView(event: event, isCurrentEvent: self.viewModel.currentEvent?.googleId == event.googleId)
            }

            Divider()

            Text("\(LocalizedString.capitalized("tomorrow")) (\(self.tomorrowFormatted)):")

            Divider()

            ForEach(self.viewModel.tomorrowsEvents) { event in
                MenuBarItemView(event: event)
            }

            Divider()

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
