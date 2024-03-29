//
//  CloudScreenSaverView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 9/12/20.
//

import ScreenSaver
import AVFoundation
import SwiftUI

class CloudScreenSaverView: ScreenSaverView {
    
    var contentPlayer: ContentPlayer
    var queueManager: QueueManager
    
    // MARK: Initialization
    static let secondPerFrame = 1.0 / 30.0
    
    override init?(frame: NSRect, isPreview: Bool) {
        // frames in screensavers are given relative to the main monitor
        // this undoes this because this frame is used independently on each monitor
        let adjustedFrame = NSRect(origin: .zero, size: frame.size)
        
        queueManager = QueueManager()
        contentPlayer = ContentPlayer(frame: adjustedFrame, queueManager: queueManager)
        super.init(frame: frame, isPreview: isPreview)
        
        setupLayer()
        
        Task(priority: .medium) {
            await Networking.updateIfTime()
        }
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayer() {
        self.wantsLayer = true
        self.layer = contentPlayer
        self.animationTimeInterval = Self.secondPerFrame
    }

    // MARK: Lifecycle
    override func startAnimation() {
        super.startAnimation()
        contentPlayer.play()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        contentPlayer.pause()
    }
    
    // MARK: Preferences
    lazy var preferencesWindow: NSWindow = {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 575),
            styleMask: [.titled, .fullSizeContentView, .utilityWindow],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        let view = NSHostingView(rootView: OptionsView(window: window))
        window.contentView = view
        return window
    }()
    
    override var hasConfigureSheet: Bool {
        return true
    }
    
    override var configureSheet: NSWindow? {
        return preferencesWindow
    }
}
