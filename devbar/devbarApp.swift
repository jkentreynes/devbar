//
//  devbarApp.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI

@main
struct devbarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Empty scene - we're using menu bar only
        Settings {
            EmptyView()
        }
    }
}
class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 800, height: 550)
        popover.behavior = .transient
        let contentView = ContentView()
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Create the status bar item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = self.statusBarItem.button {
            button.image = NSImage(systemSymbolName: "wrench.and.screwdriver.fill", accessibilityDescription: "Devbar")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Close popover when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self, self.popover.isShown else { return }
            self.popover.close()
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }
}

