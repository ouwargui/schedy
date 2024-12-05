//
//  MenuBarView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 02/12/24.
//

import Foundation
import SwiftUI

struct MenuBarView: Scene {
    @EnvironmentObject private var appDelegate: AppDelegate
    @Environment(\.modelContext) var modelContext
    
    var body: some Scene {
        let currentOrNextGoogleEvent = self.appDelegate.events.getCurrentOrNextEvent()
        
        MenuBarExtra(currentOrNextGoogleEvent?.getMenuBarString() ?? "schedy") {
            Text("Today")
            Divider()
            ForEach(self.$appDelegate.users, id:\.self) { $user in
                Text(user)
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
