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
    
    private static let backgroundColor = CGColor(red: 0.00, green: 0.01, blue: 0.00, alpha: 1.0)
    
    // MARK: - Setup
    init(frame: NSRect) {
        // init players
        self.videoPlayer = VideoPlayer()
        self.imagePlayer = ImagePlayer()
        self.currentPlayer = .image
        
        // setup layer
        super.init()
        self.frame = frame
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            videoPlayer.play()
        case .image:
            imagePlayer.play()
        }
    }
}
