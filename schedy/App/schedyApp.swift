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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarView()
            .environmentObject(appDelegate)
        
        Settings {
            SettingsView()
        }
        .windowLevel(.floating)
    }
}
