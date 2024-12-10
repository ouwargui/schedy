//
//  CheckForUpdatesViewModel.swift
//  schedy
//
//  Created by Guilherme D'Alessandro on 10/12/24.
//

import Foundation
import Sparkle

final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}
