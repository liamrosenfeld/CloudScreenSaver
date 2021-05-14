//
//  QueueManager.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 5/8/21.
//

import AVFoundation
import Combine

class QueueManager {
    
    private(set) public var queue: [Content] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    var newContentDownloaded = PassthroughSubject<Void, Never>()
    
    init() {
        populate()
        listen()
    }
    
    private func populate() {
        // get images
        let images: [Content] = Cache.getImageIndex().compactMap {
            guard let image = Cache.getImage($0) else { return nil}
            return Content.image(image)
        }
        queue.append(contentsOf: images)
        
        // get videos
        let videos: [Content] = Cache.getVideoIndex().compactMap { file in
            guard let asset = Cache.getVideo(file) else { return nil }
            return Content.video(AVPlayerItem(asset: asset))
        }
        queue.append(contentsOf: videos)
        
        // shuffle
        queue.shuffle()
    }
    
    
    private func listen() {
        // images
        Cache
            .newImageDownloaded
            .compactMap { Cache.getImage($0) }
            .map { Content.image($0) }
            .sink {
                self.queue.append($0)
                self.newContentDownloaded.send()
            }
            .store(in: &subscriptions)
        
        // videos
        Cache
            .newVideoDownloaded
            .compactMap { Cache.getVideo($0) }
            .map { Content.video(AVPlayerItem(asset: $0)) }
            .sink {
                self.queue.append($0)
                self.newContentDownloaded.send()
            }
            .store(in: &subscriptions)
        
    }
}

