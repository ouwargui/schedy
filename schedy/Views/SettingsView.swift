//
//  SettingsView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import Foundation
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import SwiftData

enum SettingsItem: String.LocalizationValue {
    case accounts
    case settings
}

struct SettingsView: View {
    @Query var users: [GoogleUser]
    @State private var selectedItem: SettingsItem = .accounts
    
    var body: some View {
        NavigationSplitView {
            List(selection: self.$selectedItem) {
                NavigationLink(value: SettingsItem.accounts) {
                    Label("Accounts", systemImage: "at")
                }
                NavigationLink(value: SettingsItem.settings) {
                    Label("Settings", systemImage: "gear")
                }
            }
        } detail: {
            switch self.selectedItem {
            case .accounts:
                AccountsView()
                    .navigationSplitViewColumnWidth(min: 200, ideal: 400, max: 600)
            case .settings:
                Text("settings")
            }
        }
        .navigationTitle(LocalizedString.capitalized(self.selectedItem.rawValue))
    }
}

//#Preview {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    
//    SettingsView()
//        .environmentObject(appDelegate)
//        .modelContainer(SwiftDataManager.shared.container)
//}
