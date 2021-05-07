//
//  ContentPlayer.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/18/21.
//

import AppKit
import Combine

final class ContentPlayer: CALayer {
    // MARK: - Properties
    private let videoPlayer: VideoPlayer
    private let imagePlayer: ImagePlayer
    private let noPlayer:    NoPlayer
    
    private var currentPlayer: PlayerType
    private var readyToSwitchSubscribers = Set<AnyCancellable>()
    
    
    private var vidDownSubscriber: AnyCancellable?
    private var imgDownSubscriber: AnyCancellable?
    
    private static let backgroundColor = CGColor(red: 0.00, green: 0.01, blue: 0.00, alpha: 1.0)
    
    private var videoPlayerDuration = Preferences.retrieveFromFile().videoPlayerDuration
    private var imagePlayerDuration = Preferences.retrieveFromFile().imagePlayerDuration
    
    // MARK: - Setup
    init(frame: NSRect) {
        // init players
        self.videoPlayer = VideoPlayer()
        self.imagePlayer = ImagePlayer()
        self.noPlayer = NoPlayer()
        self.currentPlayer = .none
        
        // setup layers
        super.init()
        self.frame = frame
        configureLayers()
        observeReadyToSwitch()
        activatePlayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                imgDownSubscriber = Cache
                    .newImageDownloaded
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        self.scheduleNextSwitch()
                        self.imgDownSubscriber?.cancel()
                    }
            } else {
                // image is immediately enabled
                currentPlayer = .image
                self.addSublayer(imagePlayer)
                imagePlayer.play()
                
                // observer set to enable video if downloaded
                vidDownSubscriber = Cache
                    .newVideoDownloaded
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        self.scheduleNextSwitch()
                        self.vidDownSubscriber?.cancel()
                    }
            }
        } else {
            // neither are enabled
            // add temp no video layer
            self.addSublayer(noPlayer)
            
            // add observers for both
            vidDownSubscriber = Cache
                .newVideoDownloaded
                .receive(on: DispatchQueue.main)
                .sink { [self] _ in
                    if imagePlayer.isEnabled {
                        scheduleNextSwitch()
                    } else {
                        replaceSublayer(noPlayer, with: videoPlayer.layer)
                        currentPlayer = .video
                        videoPlayer.play()
                    }
                    vidDownSubscriber?.cancel()
                }
            
            imgDownSubscriber = Cache
                .newImageDownloaded
                .receive(on: DispatchQueue.main)
                .sink { [self] _ in
                    if videoPlayer.isEnabled {
                        scheduleNextSwitch()
                    } else {
                        replaceSublayer(noPlayer, with: imagePlayer)
                        currentPlayer = .image
                        imagePlayer.play()
                    }
                    imgDownSubscriber?.cancel()
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
        configureLayer(noPlayer)
    }
    
    private func configureLayer(_ layer: CALayer) {
        layer.frame = frame
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        layer.contentsGravity = .resizeAspect
        layer.backgroundColor = Self.backgroundColor
        layer.needsDisplayOnBoundsChange = true
    }
    
    // MARK: - Switching Players
    private func observeReadyToSwitch() {
        videoPlayer
            .readyToSwitch
            .sink(receiveValue: switchVideoToImage)
            .store(in: &readyToSwitchSubscribers)
        imagePlayer
            .readyToSwitch
            .sink(receiveValue: switchImageToVideo)
            .store(in: &readyToSwitchSubscribers)
    }
    
    private func scheduleNextSwitch() {
        switch currentPlayer {
        case .video:
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(videoPlayerDuration)), execute: prepareToSwitch)
        case .image:
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(imagePlayerDuration)), execute: prepareToSwitch)
        case .none:
            print("no active player to play")
        }
    }
    
    private func prepareToSwitch() {
        switch currentPlayer {
        case .video:
            videoPlayer.willStop = true
        case .image:
            imagePlayer.willStop = true
        case .none:
            print("no active player to switch")
        }
    }
    
    private func switchVideoToImage() {
        imagePlayer.play()
        self.replaceSublayer(videoPlayer.layer, with: imagePlayer)
        videoPlayer.pause()
        currentPlayer = .image
        
        scheduleNextSwitch()
    }
    
    private func switchImageToVideo() {
        videoPlayer.play()
        self.replaceSublayer(imagePlayer, with: videoPlayer.layer)
        imagePlayer.pause()
        currentPlayer = .video
        
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