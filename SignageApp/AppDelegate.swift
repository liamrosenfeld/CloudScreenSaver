//
//  AppDelegate.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/6/21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let queueManager = QueueManager()
    
    // MARK: - Lifecycle
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // open a main window
        openWindow(self)
        
        // open preferences if bucket is not set
        if Preferences.retrieveFromFile().bucketName == "" {
            preferences(self)
        }
        
        // update cache
        DispatchQueue.global(qos: .default).async {
            Networking.updateIfTime()
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            if sender.windows.count > 0 {
                for window in sender.windows {
                    window.makeKeyAndOrderFront(self)
                }
            } else {
                openWindow(sender)
            }
        }
        return true
    }
    
    // MARK: - Preferences
    var preferencesWindow: NSWindow?
    
    @IBAction func preferences(_ sender: Any) {
        if preferencesWindow == nil {
            let frame = NSRect(x: 0, y: 0, width: 500, height: 700)
            preferencesWindow = NSWindow(
                contentRect: frame,
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            preferencesWindow?.isReleasedWhenClosed = false
            preferencesWindow?.center()
            preferencesWindow?.setFrameAutosaveName("Preferences")
            preferencesWindow?.contentView = NSHostingView(rootView: PreferencesView().padding())
        }
        preferencesWindow?.makeKeyAndOrderFront(sender)
    }
    
    // MARK: - Menu Bar
    @IBAction func openWindow(_ sender: Any) {
        let frame = NSRect(x: 0, y: 0, width: 480, height: 300)
        
        // create view
        let playerView = PlayerView(frame: frame, queueManager: queueManager)
        playerView.autoresizingMask = [.width, .height]
        
        // create window
        let win = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.setFrameAutosaveName("Cloud Screen Saver")
        
        // position window
        if let topWindow = NSApplication.shared.orderedWindows.first {
            win.cascadeTopLeft(from: topWindow.frame.origin)
        } else {
            win.center()
        }
        
        // add view to window
        win.contentView = playerView
        
        // add window to controller
        let controller = NSWindowController(window: win) // this is keeping windows from getting deallocated
        controller.showWindow(nil)
    }
    
    @IBAction func clearCache(_ sender: Any) {
        Cache.clearCache()
    }
    
    @IBAction func updateNow(_ sender: Any) {
        Networking.updateFromCloud()
    }
}
