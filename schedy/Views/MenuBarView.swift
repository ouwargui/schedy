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
    
    var body: some Scene {
        let currentOrNextGoogleEvent = self.appDelegate.events.getCurrentOrNextEvent()
        
        MenuBarExtra(currentOrNextGoogleEvent?.getMenuBarString() ?? "schedy") {
            ForEach(self.$appDelegate.events) { $googleEvent in
                Text("\(googleEvent.getStartHour())        \(googleEvent.getEndHour())        \(googleEvent.event.summary ?? "")")
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
