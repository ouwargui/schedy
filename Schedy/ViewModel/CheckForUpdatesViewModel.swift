import Foundation
import Sparkle

final class CheckForUpdatesViewModel: ObservableObject {
  @Published var canCheckForUpdates = false

  init(updater: SPUUpdater?) {
    guard let updater = updater else { return }
    updater.publisher(for: \.canCheckForUpdates)
      .assign(to: &$canCheckForUpdates)
  }
}
