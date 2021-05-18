//
//  WindowManager.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/15/21.
//

import AppKit
import SwiftUI

class WindowManager {
    // things shared between windows
    var queueManager = QueueManager()
    var mouseDeledate = MouseDelegate()
    
    // MARK: - Main Window
    func initialOpen() {
        // get prefs
        let prefs = Preferences.retrieveFromFile()
        let startingScreen = prefs.startingScreen
        let startFullscreen = prefs.startFullscreen
        
        // open windows on screens set in preferences
        switch startingScreen {
        case .main:
            newMainWindow(screen: nil, fullscreen: startFullscreen)
        case .all:
            for screen in NSScreen.screens {
                newMainWindow(screen: screen, fullscreen: startFullscreen)
            }
        case .custom(let selectedScreens):
            let screenIDs = selectedScreens.map(\.id)
            let screens = NSScreen.screens.filter { screenIDs.contains($0.id) }
            for screen in screens {
                newMainWindow(screen: screen, fullscreen: startFullscreen)
            }
        }
    }
    
    func openNewMain() {
        newMainWindow(screen: nil, fullscreen: false)
    }
    
    private func newMainWindow(screen: NSScreen?, fullscreen: Bool) {
        let frame = NSRect(x: 0, y: 0, width: 800, height: 500)
        
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
        
        // add view controller to window
        let playerVC = PlayerViewController(frame: frame, queueManager: queueManager, mouseDelegate: mouseDeledate)
        win.contentViewController = playerVC
        
        // open window
        // controllers are needed here to keep the app from crashing when a window is closed
        // if they are not used the app delegate get deallocated
        let controller = NSWindowController(window: win)
        controller.showWindow(self)
        
        // make fullscreen if enabled
        if fullscreen && win.styleMask != .fullScreen  {
            win.toggleFullScreen(self)
            playerVC.startedFullscreen()
        }
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
