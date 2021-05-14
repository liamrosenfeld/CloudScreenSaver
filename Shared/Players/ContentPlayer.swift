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
    let queueManager: QueueManager
    var index: Int = -1
    var lastContent: Content?
    var nextIndex: Int {
        (index + 1) % queueManager.queue.count
    }
    
    private let videoPlayer: VideoPlayer
    private let imagePlayer: ImagePlayer
    private let noPlayer:    NoPlayer
    
    private var downloadSub: AnyCancellable?
    private var subscribers = Set<AnyCancellable>()
    
    // MARK: - Setup
    init(frame: NSRect, queueManager: QueueManager) {
        // init players
        self.videoPlayer = VideoPlayer()
        self.imagePlayer = ImagePlayer()
        self.noPlayer = NoPlayer()
        
        self.queueManager = queueManager
        
        // setup layers
        super.init()
        self.frame = frame
        configureLayers()
        
        showStart()
        
        videoPlayer.finishedVideo
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: showNextIndex)
            .store(in: &subscribers)
        imagePlayer.finishedImage
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: showNextIndex)
            .store(in: &subscribers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Iterating
    func showStart() {
        if queueManager.queue.count == 0 {
            self.addSublayer(noPlayer)
        } else {
            showNextIndex()
        }
    }
    
    func showNextIndex() {
        index = nextIndex
        let content = queueManager.queue[index]
        let nextContent = queueManager.queue[nextIndex]
        
        switch content {
        case .image(let image):
            // show image
            // depends on what was last
            switch lastContent {
            case .image(_):
                break
            case .video(_):
                replaceSublayer(videoPlayer.layer, with: imagePlayer)
                imagePlayer.play()
            case .none:
                imagePlayer.addImage(image)
                self.addSublayer(imagePlayer)
            }
            
            imagePlayer.frame = frame
            
            // prep next
            // depends on what comes next
            switch nextContent {
            case .image(let nextImage):
                imagePlayer.addImage(nextImage)
            case .video(let nextVideo):
                videoPlayer.pause()
                videoPlayer.addVideo(nextVideo)
            }
        case .video(let video):
            // show video
            // depends on what was last
            switch lastContent {
            case .image(_):
                videoPlayer.play()
                replaceSublayer(imagePlayer, with: videoPlayer.layer)
            case .video(_):
                break
            case .none:
                videoPlayer.addVideo(video)
                self.addSublayer(videoPlayer.layer)
            }
            
            videoPlayer.layer.frame = frame
            
            // prep next
            // depends on what comes next
            switch nextContent {
            case .image(let nextImage):
                imagePlayer.pause()
                imagePlayer.addImage(nextImage)
            case .video(let nextVideo):
                videoPlayer.addVideo(nextVideo)
            }
        }
        
        lastContent = content
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
        videoPlayer.layer.videoGravity = .resizeAspect
        configureLayer(imagePlayer)
        imagePlayer.contentsGravity = .resizeAspect
        configureLayer(noPlayer)
    }
    
    private func configureLayer(_ layer: CALayer) {
        layer.frame = frame
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        layer.backgroundColor = .black
        layer.needsDisplayOnBoundsChange = true
    }
    
    // MARK: - Toggle Playback
    func play() {
        if queueManager.queue.count == 0 {
            downloadSub = queueManager
                .newContentDownloaded
                .receive(on: DispatchQueue.main)
                .sink {
                    self.downloadSub?.cancel()
                    self.noPlayer.removeFromSuperlayer()
                    self.showNextIndex()
                    self.play()
                }
        } else {
            switch queueManager.queue[index] {
            case .image(_):
                imagePlayer.play()
            case .video(_):
                videoPlayer.play()
            }
        }
    }
    
    func pause() {
        if queueManager.queue.count == 0 {
            downloadSub?.cancel()
        } else {
            switch queueManager.queue[index] {
            case .image(_):
                imagePlayer.pause()
            case .video(_):
                videoPlayer.pause()
            }
        }
    }
}
