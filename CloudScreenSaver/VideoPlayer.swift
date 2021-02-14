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
    init() {
        // Get each video from the cache
        let items = Cache.getIndex().reduce(into: [AVPlayerItem]()) { (players, file) in
            guard let asset = Cache.getVideo(file) else { return }
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
        // loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil
        ) { _ in
            guard let currentItem = self.queue.currentItem?.copy() as? AVPlayerItem else { return }
            self.queue.insert(currentItem, after: self.queue.items().last)
        }
        
        // add downloaded files to queue
        NotificationCenter.default.addObserver(
            forName: .NewVideoDownloaded,
            object: nil,
            queue: nil
        ) { notification in
            let file = notification.object as! S3File
            guard let asset = Cache.getVideo(file) else { return }
            let player = AVPlayerItem(asset: asset)
            self.queue.insert(player, after: self.queue.items().last)
        }
    }
    
    func unobserve() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: .NewVideoDownloaded,
            object: nil
        )
    }
}

extension NSNotification.Name {
    static let NewVideoDownloaded: Self = NSNotification.Name(rawValue: "NewVideoDownloaded")
}
