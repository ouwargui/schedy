//
//  schedyApp.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 28/11/24.
//

import GoogleSignIn
import SwiftUI

@main
struct schedyApp: App {
    var body: some Scene {
        MenuBarExtra("schedy") {
            Text("Test")
            Divider()
            SettingsLink {
                Text(LocalizedString.capitalized("open-preferences"))
            }.keyboardShortcut(",", modifiers: [.command, .shift])
            Button(LocalizedString.capitalized("quit")) {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
        
        Settings {
            SettingsView()
        }
        .windowLevel(.floating)
    }
}
