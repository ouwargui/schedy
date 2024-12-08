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
    @EnvironmentObject private var appDelegate: AppDelegate
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
            case .settings:
                Text("settings")
            }
        }
        .navigationTitle(LocalizedString.capitalized(self.selectedItem.rawValue))
        .frame(width: 500)
    }
    
    private func signIn() {
        self.appDelegate.currentAuthorizationFlow = GoogleAuthService.shared.signIn(appDelegate: self.appDelegate)
    }
    
    private func signOut(for user: GoogleUser) {
        GoogleAuthService.shared.signOut(user: user)
    }
}

#Preview {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    SettingsView()
        .environmentObject(appDelegate)
        .modelContainer(SwiftDataManager.shared.container)
}
