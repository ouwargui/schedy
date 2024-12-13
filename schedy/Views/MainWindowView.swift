//
//  SettingsView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 29/11/24.
//

import Foundation
import SwiftUI
import SwiftData

enum SettingsItem: String.LocalizationValue {
    case accounts
    case settings
}

struct MainWindowView: View {
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
                SettingsView()
                    .navigationSplitViewColumnWidth(min: 200, ideal: 400, max: 600)
            }
        }
        .navigationTitle(LocalizedString.capitalized(self.selectedItem.rawValue))
    }
}
