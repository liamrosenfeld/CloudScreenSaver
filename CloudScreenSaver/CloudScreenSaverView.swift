//
//  CloudScreenSaverView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 9/12/20.
//

import ScreenSaver
import AVFoundation

class CloudScreenSaverView: ScreenSaverView {
    
    // MARK: Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = Self.secondPerFrame
        configure()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        animationTimeInterval = Self.secondPerFrame
        configure()
    }
    
    // MARK: Constant
    static let secondPerFrame = 1.0 / 30.0
    static let backgroundColor = NSColor(red: 0.00, green: 0.01, blue: 0.00, alpha:1.0)
    
    // MARK: Outlets
    private let videoLayer = AVPlayerLayer()
    
    // MARK: - Configuration
    func configure() {
        // define layer
        wantsLayer = true
        defineVideoLayer()
        layer = videoLayer
        
        // setup layer
        videoLayer.player = LoopPlayer(
            items: [
                Video(name: "auroraBorealis", ext: .mp4),
                Video(name: "bits", ext: .mp4)
            ],
            numberOfLoops: 2,
            shouldRandomize: true
        )
    }
    
    
    func defineVideoLayer() {
        videoLayer.frame = bounds
        videoLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        videoLayer.needsDisplayOnBoundsChange = true
        videoLayer.contentsGravity = .resizeAspect
        videoLayer.backgroundColor = Self.backgroundColor.cgColor
    }

    
    // MARK: Lifecycle
    override func startAnimation() {
        super.startAnimation()
        videoLayer.player?.play()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        videoLayer.player?.pause()
    }
    
    // MARK: Preferences
    override var hasConfigureSheet: Bool {
        return false
//        return true
    }
    
    override var configureSheet: NSWindow? {
        return nil
//        return preferences.window
    }
}

struct Video {
    var name: String
    var ext: Extension
}

protocol CloudAccess {
    
}

