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
    
    // MARK: Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = Self.secondPerFrame
        Cache.updateIfTime()
        configure()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        animationTimeInterval = Self.secondPerFrame
        Cache.updateIfTime()
        configure()
    }
    
    // MARK: Constant
    static let secondPerFrame = 1.0 / 30.0
    static let backgroundColor = CGColor(red: 0.00, green: 0.01, blue: 0.00, alpha: 1.0)
    
    // MARK: Video Player
    var videoPlayer: VideoPlayer?
    
    func configure() {
        // create video player
        videoPlayer = VideoPlayer()
        
        // add layer
        self.wantsLayer = true
        configureVideoLayer(videoPlayer!.layer)
        self.layer = videoPlayer?.layer
    }
    
    func configureVideoLayer(_ videoLayer: AVPlayerLayer) {
        videoLayer.frame = bounds
        videoLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        videoLayer.needsDisplayOnBoundsChange = true
        videoLayer.contentsGravity = .resizeAspect
        videoLayer.backgroundColor = Self.backgroundColor
    }
    
    // MARK: Lifecycle
    override func startAnimation() {
        super.startAnimation()
        videoPlayer?.play()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        videoPlayer?.pause()
    }
    
    // MARK: Preferences
    lazy var preferencesWindow: NSWindow = {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 500),
            styleMask: [.titled, .fullSizeContentView, .utilityWindow],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        let view = NSHostingView(rootView: PreferencesView(window: window))
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
