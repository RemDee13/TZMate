import SwiftUI

@main
struct TZMateApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("TZ Mate", systemImage: "clock") {
            RootPopoverView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
    }
}
