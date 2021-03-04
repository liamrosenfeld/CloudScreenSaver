//
//  ContentPlayer.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/18/21.
//

import AppKit

final class ContentPlayer: CALayer {
    // MARK: - Properties
    private let videoPlayer: VideoPlayer
    private let imagePlayer: ImagePlayer
    
    private var currentPlayer: MediaType
    private var didFinishObserver: NSObjectProtocol?
    
    private static let backgroundColor = CGColor(red: 0.00, green: 0.01, blue: 0.00, alpha: 1.0)
    
    // MARK: - Setup
    init(frame: NSRect) {
        // init players
        self.videoPlayer = VideoPlayer()
        self.imagePlayer = ImagePlayer()
        self.currentPlayer = .image
        
        // setup layers
        super.init()
        self.frame = frame
        configure()
        scheduleNextSwitch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let observer = didFinishObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func configure() {
        // configure this layer
        self.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        self.needsDisplayOnBoundsChange = true
        self.contentsGravity = .resizeAspect
        self.backgroundColor = backgroundColor
        
        // configure sub layers
        configureLayer(videoPlayer.layer)
        configureLayer(imagePlayer)
        
        // this is only needed on the video layer
        videoPlayer.layer.needsDisplayOnBoundsChange = true
        
        // add initial layer
        self.addSublayer(imagePlayer)
    }
    
    private func configureLayer(_ layer: CALayer) {
        layer.frame = frame
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        layer.contentsGravity = .resizeAspect
        layer.backgroundColor = Self.backgroundColor
    }
    
    // MARK: - Switching Players
    private func scheduleNextSwitch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: prepareToSwitch)
    }
    
    private func prepareToSwitch() {
        didFinishObserver = NotificationCenter.default.addObserver(
            forName: .ContentFinished,
            object: nil,
            queue: nil,
            using: switchPlayer
        )
    }
    
    private func switchPlayer(_: Notification) {
        // pause and switch sublayer
        switch currentPlayer {
        case .video:
            imagePlayer.play()
            self.replaceSublayer(videoPlayer.layer, with: imagePlayer)
            currentPlayer = .image
            videoPlayer.pause()
        case .image:
            videoPlayer.play()
            self.replaceSublayer(imagePlayer, with: videoPlayer.layer)
            currentPlayer = .video
            imagePlayer.pause()
        }
        
        // remove observer because prepare has been handled
        if let observer = didFinishObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // set "timer" for next switch
        scheduleNextSwitch()
    }
    
    // MARK: - Toggle Playback
    func play() {
        switch currentPlayer {
        case .video:
            videoPlayer.play()
        case .image:
            imagePlayer.play()
        }
    }
    
    func pause() {
        switch currentPlayer {
        case .video:
            videoPlayer.pause()
        case .image:
            imagePlayer.pause()
        }
    }
}
