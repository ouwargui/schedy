//
//  SettingsView.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 09/12/24.
//

import SwiftUI
import KeyboardShortcuts
import Sparkle

struct SettingsView: View {
    private let updater: SPUUpdater
    @State private var isShowingClearAppDataAlert = false
    @State private var automaticallyChecksForUpdates: Bool
    @State private var automaticallyDownloadsUpdates: Bool

    init(updater: SPUUpdater) {
        self.updater = updater
        self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        self.automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
    }

    var buildVersion: String {
        if let buildVersion = Bundle.main.buildVersion {
            return buildVersion
        }
        return ""
    }

    var commitSha: String {
        if let commitSha = Bundle.main.releaseVersion {
            return commitSha
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

                    VStack {
                        Toggle("Automatically check for updates", isOn: self.$automaticallyChecksForUpdates)
                            .onChange(of: self.automaticallyChecksForUpdates) { newValue, _ in
                                updater.automaticallyChecksForUpdates = newValue
                            }

                        Toggle("Automatically download updates", isOn: self.$automaticallyDownloadsUpdates)
                            .onChange(of: self.automaticallyDownloadsUpdates) { newValue, _ in
                                updater.automaticallyDownloadsUpdates = newValue
                            }
                    }
                }
            }

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Build \(self.buildVersion)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    let commitUrl = URL(string: "https://github.com/ouwargui/schedy/commit/\(self.commitSha)")
                    if let commitUrl = commitUrl {
                        if #available(macOS 15.0, *) {
                            Link("Commit SHA \(self.commitSha)", destination: commitUrl)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .pointerStyle(.link)
                        } else {
                            Link("Commit SHA \(self.commitSha)", destination: commitUrl)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .onHover { isHovered in
                                    if isHovered {
                                        NSCursor.pointingHand.push()
                                    } else {
                                        NSCursor.pop()
                                    }
                                }
                        }
                    } else {
                        Text("Commit SHA \(self.commitSha)")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }

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
