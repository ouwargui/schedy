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
    }
}
