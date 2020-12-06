//
//  VideoPlayer.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 9/14/20.
//

import AVFoundation

final class VideoPlayer {
    
    let layer: AVPlayerLayer
    let queue: AVQueuePlayer
    
    // MARK: Lifecycle
    init(videos: [Video], shouldRandomize: Bool) {
        // Get each video from the cache
        let items = (shouldRandomize ? videos.shuffled() : videos)
            .reduce(into: [AVPlayerItem]()) { (players, video) in
                guard let asset = Cache.getVideo(video) else { return }
                let player = AVPlayerItem(asset: asset)
                players.append(player)
            }
        
        // Make player
        self.queue = AVQueuePlayer(items: items)
        self.layer = AVPlayerLayer(player: queue)
        
        observe()
    }
    
    deinit {
        unobserve()
    }
    
    // MARK: - Actions
    func play() {
        queue.play()
    }
    
    func pause() {
        queue.pause()
    }
    
    // MARK: - Observers
    func observe() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil
        ) { _ in
            guard let currentItem = self.queue.currentItem?.copy() as? AVPlayerItem else { return }
            self.queue.insert(currentItem, after: self.queue.items().last)
        }
    }
    
    func unobserve() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
}

