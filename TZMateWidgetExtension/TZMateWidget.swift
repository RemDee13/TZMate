//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

import WidgetKit
import SwiftUI

struct TZMateWidget: Widget {
    let kind = "TZMateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TZMateWidgetProvider()) { entry in
            TZMateWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TZ Mate")
        .description("Check client local time before you call or message.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
