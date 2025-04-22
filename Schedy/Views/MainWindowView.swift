import Foundation
import SwiftData
import SwiftUI
import Sparkle

enum SettingsItem: String.LocalizationValue {
    case accounts
    case settings
}

struct MainWindowView: View {
    private let updater: SPUUpdater?

    @Environment(\.dismissWindow) var dismissWindow
    @State private var selectedItem: SettingsItem = .accounts
    private let pub = NotificationCenter.default.publisher(
        for: NSNotification.Name("close-settings"))

    init(updater: SPUUpdater?) {
        self.updater = updater
    }

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
                SettingsView(updater: self.updater)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 400, max: 600)
            }
        }
        .onReceive(pub) { _ in
            dismissWindow(id: "settings")
        }
        .navigationTitle(LocalizedString.capitalized(self.selectedItem.rawValue))
    }
}
