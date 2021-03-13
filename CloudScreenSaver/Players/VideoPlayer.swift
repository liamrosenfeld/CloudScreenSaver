//
//  VideoPlayer.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 9/14/20.
//

import AVFoundation
import Combine

final class VideoPlayer {
    
    let layer: AVPlayerLayer
    let queue: AVQueuePlayer
    
    var subscriptions = Set<AnyCancellable>()
    
    var isEnabled: Bool {
        queue.items().count != 0
    }
    
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
    
    // MARK: - Toggle Playback
    func play() {
        queue.play()
    }
    
    func pause() {
        queue.pause()
    }
    
    // MARK: - Observers
    func observe() {
        // loop the videos
        // when a video finishes, move it to the end of the queue
        NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { _ in
                NotificationCenter.default.post(Notification(name: .ContentFinished))
                guard let currentItem = self.queue.currentItem?.copy() as? AVPlayerItem else { return }
                self.queue.insert(currentItem, after: self.queue.items().last)
            }
            .store(in: &subscriptions)
        
        // add downloaded files to queue
        Cache
            .newVideoDownloaded
            .compactMap { Cache.getVideo($0) }
            .map { AVPlayerItem(asset: $0) }
            .sink { self.queue.append($0) }
            .store(in: &subscriptions)
    }
}

fileprivate extension Array where Element: AVPlayerItem {
    init(copy item: Element, count: Int) {
        let elements = [Int](0..<count).compactMap { _ in return item.copy() as? Element }
        self.init(elements)
    }
}

extension AVQueuePlayer {
    func append(_ element: AVPlayerItem) {
        insert(element, after: items().last)
    }
}
