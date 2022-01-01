//
//  AppDelegate.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/6/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let windowManager = WindowManager()
    var updateTimer: Timer?

    // MARK: - Lifecycle
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // open the main window(s)
        windowManager.initialOpen()
        
        // open preferences if bucket is not set
        if Preferences.retrieveFromFile().bucketName.isEmpty {
            windowManager.openPreferences()
        }
        
        // update cache
        Task(priority: .medium) {
            await Networking.updateIfTime()
        }
        
        // update during app run
        let timeBetween = Preferences.retrieveFromFile().updateFrequency
        if timeBetween != 0 {
            updateTimer = Timer.scheduledTimer(withTimeInterval: timeBetween, repeats: true) { _ in
                print("updating...")
                Task(priority: .medium) {
                    await Networking.updateFromCloud()
                }
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            if sender.windows.count > 0 {
                for window in sender.windows {
                    window.makeKeyAndOrderFront(self)
                }
            } else {
                newWindow(sender)
            }
        }
        return true
    }
    
    // MARK: - Menu Bar
    @IBAction func newWindow(_ sender: Any) {
        windowManager.openNewMain()
    }
    
    @IBAction func openPreferences(_ sender: Any) {
        windowManager.openPreferences()
    }
    
    @IBAction func clearCache(_ sender: Any) {
        Cache.clearCache()
    }
    
    @IBAction func updateNow(_ sender: Any) {
        Task(priority: .medium) {
            await Networking.updateFromCloud()
        }
    }
}
