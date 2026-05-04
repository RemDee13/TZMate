//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import Foundation

enum SharedUserDefaultsProvider {
    static func makeSharedDefaults() -> UserDefaults? {
        guard FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) != nil else {
            return nil
        }

        return UserDefaults(suiteName: Constants.appGroupIdentifier)
    }
}
