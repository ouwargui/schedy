import SwiftUI
import Sparkle

struct CheckForUpdatesView: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    @ObservedObject private var appDelegate: AppDelegate

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        let updater = appDelegate.appStateManager.updaterController?.updater
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }

    var body: some View {
        if let updater = self.appDelegate.appStateManager.updaterController?.updater {
            if self.appDelegate.appStateManager.isUpdateAvailable {
                Button("Version \(self.appDelegate.appStateManager.updateData?.versionString ?? "") available!") {
                    updater.checkForUpdates()
                }
            } else {
                Button("Check for updates") {
                    updater.checkForUpdates()
                }
                .disabled(!self.checkForUpdatesViewModel.canCheckForUpdates)
            }
        }
    }
}
