import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private let appState = AppState()
    private let popover = NSPopover()
    private var statusItem: NSStatusItem?
    private var hostingController: NSViewController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configurePopover()
        configureStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        popover.close()
        statusItem = nil
        hostingController = nil
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = item.button {
            button.title = "TZ"
            button.toolTip = "TZ Mate"
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        statusItem = item
    }

    private func configurePopover() {
        let rootView = RootPopoverView()
            .environmentObject(appState)

        let controller = NSHostingController(rootView: rootView)
        controller.view.frame = NSRect(x: 0, y: 0, width: 430, height: 620)

        hostingController = controller
        popover.contentViewController = controller
        popover.contentSize = NSSize(width: 430, height: 620)
        popover.behavior = .semitransient
        popover.animates = true
        popover.delegate = self
    }

    @objc
    private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem?.button else {
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }
}
