//
//  WindowManager.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/15/21.
//

import AppKit
import SwiftUI

class WindowManager {
    
    var queueManager: QueueManager
    
    init(queueManager: QueueManager) {
        self.queueManager = queueManager
    }
    
    // MARK: - Main Window
    func initialOpen() {
        let screenOption = Preferences.retrieveFromFile().startingScreen
        
        // controllers are needed here to keep the app from crashing when a window is closed
        // if they are not used the app delegate get deallocated
        switch screenOption {
        case .main:
            let win = newMainWindow(screen: nil)
            let controller = NSWindowController(window: win)
            controller.showWindow(self)
        case .all:
            for screen in NSScreen.screens {
                let win = newMainWindow(screen: screen)
                let controller = NSWindowController(window: win)
                controller.showWindow(self)
            }
        case .custom(let selectedScreens):
            let screenIDs = selectedScreens.map(\.id)
            let screens = NSScreen.screens.filter { screenIDs.contains($0.id) }
            for screen in screens {
                let win = newMainWindow(screen: screen)
                let controller = NSWindowController(window: win)
                controller.showWindow(self)
            }
        }
    }
    
    func openNewMain() {
        let win = newMainWindow(screen: nil)
        let controller = NSWindowController(window: win)
        controller.showWindow(self)
    }
    
    private func newMainWindow(screen: NSScreen?) -> NSWindow {
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
        if let screen = screen {
            // if a screen is passed, put the window on it
            win.setFrameOrigin(screen.frame.origin)
        } else if let topWindow = NSApplication.shared.orderedWindows.first {
            // if no screen, cascade it on the current top
            win.cascadeTopLeft(from: topWindow.frame.origin)
        } else {
            // if neither, open it on the center of the main screen
            win.center()
        }
        
        // add view to window
        win.contentView = playerView
        
        return win
    }
    
    // MARK: - Preferences
    private var preferencesWindow: NSWindow?
    
    func openPreferences() {
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
            preferencesWindow?.contentView = NSHostingView(rootView: PreferencesView().padding().frame(width: 500, height: 600))
            preferencesWindow?.title = "Preferences"
        }
        preferencesWindow?.makeKeyAndOrderFront(self)
    }
}


extension NSScreen {
    public var id: CGDirectDisplayID {
        self.deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as! CGDirectDisplayID
    }
}
