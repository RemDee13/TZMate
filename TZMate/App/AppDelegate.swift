//
//  TZ Mate
//  Copyright (c) 2026 Anton Pavlov
//  GitHub: https://github.com/RemDee13
//  Licensed under the MIT License.
//

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
            button.action = #selector(handleStatusItemClick(_:))
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
    private func handleStatusItemClick(_ sender: AnyObject?) {
        if shouldShowStatusMenu {
            showStatusMenu()
            return
        }

        togglePopover(sender)
    }

    @objc
    private func openFromStatusMenu(_ sender: AnyObject?) {
        showPopover()
    }

    @objc
    private func quitFromStatusMenu(_ sender: AnyObject?) {
        popover.close()
        NSApp.terminate(nil)
    }

    private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            showPopover()
        }
    }

    private var shouldShowStatusMenu: Bool {
        guard let event = NSApp.currentEvent else {
            return false
        }

        return event.type == .rightMouseUp || event.modifierFlags.contains(.control)
    }

    private func showStatusMenu() {
        let menu = NSMenu()

        let openItem = NSMenuItem(title: "Open TZ Mate", action: #selector(openFromStatusMenu(_:)), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit TZ Mate", action: #selector(quitFromStatusMenu(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
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
