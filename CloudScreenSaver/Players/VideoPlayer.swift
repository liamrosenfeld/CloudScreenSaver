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
        let loopCount = Preferences.retrieveFromFile().loopCount
        let items = Cache.getVideoIndex().reduce(into: [AVPlayerItem]()) { (players, file) in
            guard let asset = Cache.getVideo(file) else { return }
            let player = AVPlayerItem(asset: asset)
            players.append(contentsOf: Array(copy: player, count: loopCount))
        }
        
        // Make player
        self.queue = AVQueuePlayer(items: items)
        self.layer = AVPlayerLayer(player: queue)
        
        observe()
    }
    
    deinit {
        unobserve()
    }
    
    // MARK: - Toggle Playback
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

fileprivate extension Array where Element: AVPlayerItem {
    init(copy item: Element, count: Int) {
        let elements = [Int](0..<count).compactMap { _ in return item.copy() as? Element }
        self.init(elements)
    }
}