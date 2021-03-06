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
    
    private var currentPlayer: PlayerType
    private var didFinishObserver: NSObjectProtocol?
    
    private let noPlayerLayer: CATextLayer
    private var vidDownObserver: NSObjectProtocol?
    private var imgDownObserver: NSObjectProtocol?
    
    private static let backgroundColor = CGColor(red: 0.00, green: 0.01, blue: 0.00, alpha: 1.0)
    
    // MARK: - Setup
    init(frame: NSRect) {
        // init players
        self.videoPlayer = VideoPlayer()
        self.imagePlayer = ImagePlayer()
        self.currentPlayer = .none
        
        self.noPlayerLayer = CATextLayer()
        noPlayerLayer.fontSize = 30
        noPlayerLayer.string = "Downloading Screensavers. If this screen persists, check screen saver and network preferences."
        
        // setup layers
        super.init()
        self.frame = frame
        configureLayers()
        activatePlayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let observer = didFinishObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = vidDownObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = imgDownObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Activating Players
    private func activatePlayers() {
        let videoEnabled = videoPlayer.isEnabled
        let imageEnabled = imagePlayer.isEnabled
        
        if videoEnabled && imageEnabled {
            // if both players are enabled, enable switching immediately
            // starting with videos
            currentPlayer = .video
            self.addSublayer(videoPlayer.layer)
            scheduleNextSwitch()
        } else if videoEnabled || imageEnabled {
            // if only one is enabled, start that one
            // then start switching if the other is added
            if videoEnabled {
                // video is immediately enabled
                currentPlayer = .video
                self.addSublayer(videoPlayer.layer)
                videoPlayer.play()
                
                // observer set to enable image if downloaded
                imgDownObserver = NotificationCenter.default.addObserver(
                    forName: .NewImageDownloaded,
                    object: nil,
                    queue: nil
                ) { notification in
                    self.scheduleNextSwitch()
                    NotificationCenter.default.removeObserver(self.imgDownObserver!)
                }
            } else {
                // image is immediately enabled
                currentPlayer = .image
                self.addSublayer(imagePlayer)
                imagePlayer.play()
                
                // observer set to enable video if downloaded
                vidDownObserver = NotificationCenter.default.addObserver(
                    forName: .NewVideoDownloaded,
                    object: nil,
                    queue: nil
                ) { notification in
                    self.scheduleNextSwitch()
                    NotificationCenter.default.removeObserver(self.vidDownObserver!)
                }
            }
        } else {
            // neither are enabled
            // add temp no video layer
            self.addSublayer(noPlayerLayer)
            
            // add observers for both
            vidDownObserver = NotificationCenter.default.addObserver(
                forName: .NewVideoDownloaded,
                object: nil,
                queue: nil
            ) { [self] notification in
                if imagePlayer.isEnabled {
                    scheduleNextSwitch()
                } else {
                    replaceSublayer(noPlayerLayer, with: videoPlayer.layer)
                    currentPlayer = .video
                    videoPlayer.play()
                }
                NotificationCenter.default.removeObserver(vidDownObserver!)
            }
            
            imgDownObserver = NotificationCenter.default.addObserver(
                forName: .NewImageDownloaded,
                object: nil,
                queue: nil
            ) { [self] notification in
                if videoPlayer.isEnabled {
                    scheduleNextSwitch()
                } else {
                    replaceSublayer(noPlayerLayer, with: imagePlayer)
                    currentPlayer = .image
                    imagePlayer.play()
                }
                NotificationCenter.default.removeObserver(imgDownObserver!)
            }
        }
    }
    
    // MARK: - Layers
    private func configureLayers() {
        // configure this layer
        self.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        self.needsDisplayOnBoundsChange = true
        self.contentsGravity = .resizeAspect
        self.backgroundColor = backgroundColor
        
        // configure sub layers
        configureLayer(videoPlayer.layer)
        configureLayer(imagePlayer)
        configureLayer(noPlayerLayer)
        
        // this is only needed on the video layer
        videoPlayer.layer.needsDisplayOnBoundsChange = true
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
        case .none:
            print("no active player to switch")
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
        case .none:
            print("no active player to play")
        }
    }
    
    func pause() {
        switch currentPlayer {
        case .video:
            videoPlayer.pause()
        case .image:
            imagePlayer.pause()
        case .none:
            print("no active player to pause")
        }
    }
}

enum PlayerType {
    case video
    case image
    case none
}
