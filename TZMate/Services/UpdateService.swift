//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation
import Sparkle

@MainActor
final class UpdateService {
    private let userDriverDelegate = SparkleUserDriverDelegate()
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: userDriverDelegate
        )
    }

    var automaticallyChecksForUpdates: Bool {
        updaterController.updater.automaticallyChecksForUpdates
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }

    func setAutomaticallyChecksForUpdates(_ enabled: Bool) {
        updaterController.updater.automaticallyChecksForUpdates = enabled
    }
}

private final class SparkleUserDriverDelegate: NSObject, SPUStandardUserDriverDelegate {
    nonisolated var supportsGentleScheduledUpdateReminders: Bool {
        true
    }

    nonisolated func standardUserDriverShouldHandleShowingScheduledUpdate(
        _ update: SUAppcastItem,
        andInImmediateFocus immediateFocus: Bool
    ) -> Bool {
        true
    }
}
