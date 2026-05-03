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
