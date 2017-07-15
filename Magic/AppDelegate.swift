//
//  AppDelegate.swift
//  Magic
//
//  Created by Jie Zhang on 15/7/17.
//  Copyright © 2017 Jie Zhang. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let rightClickMenu = NSMenu()

    var display = true

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        rightClickMenu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem.button?.image = #imageLiteral(resourceName: "statusbar-icon")
        statusItem.button?.action = #selector(statusbarClicked(sender:))
        statusItem.button?.sendAction(on: [.leftMouseDown, .rightMouseDown])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func statusbarClicked(sender: NSStatusBarButton) {

        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseDown {
            statusItem.popUpMenu(rightClickMenu)
            return
        }

        display = !display

        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", "defaults write com.apple.finder CreateDesktop \(display); killall Finder"]
        process.launch()
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

}

