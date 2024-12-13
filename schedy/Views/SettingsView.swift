//
//  SettingsView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 09/12/24.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @State private var isShowingClearAppDataAlert = false

    var appVersion: String {
        if let releaseVersion = Bundle.main.releaseVersion, let buildVersion = Bundle.main.buildVersion {
            return "\(releaseVersion).\(buildVersion)"
        }

        return ""
    }

    var body: some View {
        Spacer()
        VStack {
            HStack {
                Spacer()

                Form {
                    KeyboardShortcuts.Recorder("Open event URL", name: .openEventUrl)
                }
            }

            Spacer()

            HStack {
                Text("Schedy \(self.appVersion)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Clear app data", action: self.showClearAppDataAlert)
                    .alert("Clear app data?", isPresented: self.$isShowingClearAppDataAlert) {
                        Button("Clear app data", role: .destructive, action: self.clearAppData)
                        Button("Cancel", role: .cancel, action: self.hideClearAppDataAlert)
                    } message: {
                        Text("All users, calendars and events will be deleted")
                    }
            }
        }
        .padding(10)

        Spacer()
    }

    private func hideClearAppDataAlert() {
        self.isShowingClearAppDataAlert = false
    }

    private func showClearAppDataAlert() {
        self.isShowingClearAppDataAlert = true
    }

    private func clearAppData() {
        try? SwiftDataManager.shared.delete(model: GoogleUser.self, where: nil)
    }
}

// #Preview {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    
//    MainWindowView()
//        .environmentObject(appDelegate)
//        .modelContainer(SwiftDataManager.shared.container)
// }
