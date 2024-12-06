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
    @Query var events: [GoogleEvent]
    
    var body: some Scene {
        MenuBarExtra("schedy") {
            Text("Today")
            Divider()
            ForEach(self.events) { event in
                Text(event.title)
            }
            Divider()
            Text("Tomorrow")
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
