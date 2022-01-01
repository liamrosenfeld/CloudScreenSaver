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
    private let queue: AVQueuePlayer
    
    var numberOfLoops = Preferences.retrieveFromFile().loopCount
    
    var finishedVideo = PassthroughSubject<Void, Never>()
    
    init() {
        // Make player
        self.queue = AVQueuePlayer()
        self.layer = AVPlayerLayer(player: queue)
    }
    
    func play() {
        queue.play()
    }
    
    func pause() {
        queue.pause()
    }
    
    func addVideo(_ video: AVPlayerItem) {
        // add all but last loop
        for _ in 0..<(numberOfLoops-1) {
            queue.insert(video.copy() as! AVPlayerItem, after: queue.items().last)
        }
        
        // add final loop (so it can be observed)
        let finalLoopItem = video.copy() as! AVPlayerItem
        queue.insert(finalLoopItem, after: queue.items().last)
        
        // observe when the final video in a loop finishes
        var didPlayToEndSub: AnyCancellable?
        didPlayToEndSub = NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime, object: finalLoopItem)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.queue.remove(self.queue.items().first!)
                didPlayToEndSub?.cancel()
                self.finishedVideo.send()
            }
    }
}
