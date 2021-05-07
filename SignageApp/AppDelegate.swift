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

    var mainWindow: NSWindow!
    var preferencesWindow: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let frame = NSRect(x: 0, y: 0, width: 480, height: 300)
        
        // create view
        let playerView = PlayerView(frame: frame)
        playerView.autoresizingMask = [.width, .height]
        
        // create window
        mainWindow = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        mainWindow.isReleasedWhenClosed = false
        mainWindow.center()
        mainWindow.setFrameAutosaveName("Cloud Screen Saver")
        
        // add view to window
        mainWindow.contentView = playerView
        mainWindow.makeKeyAndOrderFront(nil)
    }
    
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
    
    @IBAction func clearCache(_ sender: Any) {
        Cache.clearCache()
    }
    
    @IBAction func updateNow(_ sender: Any) {
        Networking.updateFromCloud()
    }
}

