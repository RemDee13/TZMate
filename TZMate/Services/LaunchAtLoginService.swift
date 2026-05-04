//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation
import ServiceManagement

struct LaunchAtLoginService {
    func isEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try registerIfNeeded()
        } else {
            try unregisterIfNeeded()
        }
    }

    func errorMessage(for error: Error) -> String {
        "Could not update Launch at Login. Check Signing & Capabilities and try again. \(error.localizedDescription)"
    }

    private func registerIfNeeded() throws {
        guard SMAppService.mainApp.status != .enabled else {
            return
        }

        try SMAppService.mainApp.register()
    }

    private func unregisterIfNeeded() throws {
        guard SMAppService.mainApp.status != .notRegistered else {
            return
        }

        try SMAppService.mainApp.unregister()
    }
}
