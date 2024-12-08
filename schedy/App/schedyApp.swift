//
//  schedyApp.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 28/11/24.
//

import SwiftUI

@main
struct schedyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarView()
            .environmentObject(appDelegate)
            .modelContainer(SwiftDataManager.shared.container)
        
        Window("Settings", id: "settings") {
            MainWindowView()
        }
        .commands {
            SidebarCommands()
        }
        .windowLevel(.normal)
        .windowResizability(.contentSize)
        .windowStyle(.titleBar)
        .environmentObject(appDelegate)
        .modelContainer(SwiftDataManager.shared.container)
    }
}
