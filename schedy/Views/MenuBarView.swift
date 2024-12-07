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
    @EnvironmentObject private var appDelegate: AppDelegate
    @Query(filter: GoogleEvent.todaysPredicate) var todayEvents: [GoogleEvent]
    @Query(filter: GoogleEvent.tomorrowsPredicate) var tomorrowEvents: [GoogleEvent]
    @State var today: Date
    @State var tomorrow: Date
    
    var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        formatter.locale = Locale.current
        return formatter.string(from: self.today)
    }
    
    var tomorrowFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        formatter.locale = Locale.current
        return formatter.string(from: self.tomorrow)
    }
    
    init() {
        let today = Date()
        self.today = today
        self.tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    }
    
    var body: some Scene {
        MenuBarExtra("schedy") {
            Text("\(LocalizedString.capitalized("today")) (\(self.todayFormatted))")
            Divider()
            ForEach(self.todayEvents) { event in
                if (event.hasPassed()) {
                    Text(event.title)
                } else {
                    Link(event.title, destination: event.getHtmlLinkWithAuthUser())
                }
            }
            Divider()
            Text("\(LocalizedString.capitalized("tomorrow")) (\(self.tomorrowFormatted))")
            Divider()
            ForEach(self.tomorrowEvents) { event in
                Link(event.title, destination: event.getHtmlLinkWithAuthUser())
            }
            Divider()
            SettingsLink {
                Text(LocalizedString.capitalized("open-preferences"))
            }.keyboardShortcut(",", modifiers: [.command, .shift])
            Button(LocalizedString.capitalized("quit")) {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
    }
}
