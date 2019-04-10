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

//    var display = true
//    this value does not persist
//    when the app relauches, Desktop could be already hidden
//    then the user would have to click the menubar item twice
//    to make Desktop reappear

    var isDesktopHidden: Bool {
        var finderPlistPath: URL?

        if #available(OSX 10.12, *) {
            finderPlistPath = FileManager().homeDirectoryForCurrentUser
        } else {
            // Fallback on earlier versions
            finderPlistPath = URL(fileURLWithPath: NSHomeDirectory())
        }

        finderPlistPath = finderPlistPath!.appendingPathComponent("Library/Preferences/com.apple.finder.plist")

        if #available(OSX 10.13, *) {
            var dict: NSDictionary?
            do {
                dict = try NSDictionary(contentsOf: finderPlistPath!, error: ())
            } catch {
                print("Plist Convertion Error: \(error)")
            }

            if let value = dict?.value(forKey: "CreateDesktop") as? String,
                let result = Bool(value) {
                return result
            }
        } else {
            // Fallback on earlier versions
            if let dict = NSDictionary(contentsOf: finderPlistPath!),
                let value = dict.value(forKey: "CreateDesktop") as? String,
                let result = Bool(value) {
                return result
            }
            //    dict.value(forKey: "CreateDesktop") would produce
            //    Any?, Bool initializer only accepts (Bool), (String), (NSNumber)
            //    dict.value(forKey: "CreateDesktop") as? Bool
            //    does not work either, somehow the system would try to convert
            //    dict.value(forKey: "CreateDesktop") NSTaggedPointerString
            //    to NSNumber first, which fails.
        }
        
        return false
        
    }

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

        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", "defaults write com.apple.finder CreateDesktop \(!isDesktopHidden); killall Finder"]
        process.launch()
        print("Desktop State Flipped")
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

}

