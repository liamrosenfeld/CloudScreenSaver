//
//  LoopPlayer.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 9/14/20.
//

import AVFoundation

// MARK: Init
extension AVPlayerItem {
    convenience init?(video: Video, for caller: AnyClass) {
        guard let url = Bundle(for: caller).url(forResource: video.name, withExtension: video.ext.rawValue) else { return nil }
        self.init(url: url)
    }
}

// MARK: - Extension
enum Extension: String {
    case mp4
}


final class LoopPlayer: AVQueuePlayer {
    
    // MARK: Lifecycle
    init(items: [Video], numberOfLoops: Int, shouldRandomize: Bool) {
        let items = (shouldRandomize ? items.shuffled() : items)
            .reduce(into: [AVPlayerItem]()) { (player, video) in
                guard let item = AVPlayerItem(video: video, for: LoopPlayer.self) else { return }
                player.append(contentsOf: Array(copy: item, count: numberOfLoops))
            }
            .prepareForQueue()
        
        super.init(items: items)
        observe()
    }
    
    override init() {
        super.init()
    }
    
    
    deinit {
        unobserve()
    }
    
    // MARK: - Observers
    func observe() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil
        ) { _ in
            guard let currentItemCopy = self.currentItem?.copy() as? AVPlayerItem else { return }
            self.insert(currentItemCopy, after: self.items().last)
        }
    }
    
    func unobserve() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
    }
    
    // MARK: - Actions
    func play(_ video: Video) {
        guard let item = AVPlayerItem(video: video, for: LoopPlayer.self) else { return }
        actionAtItemEnd = .none
        removeAllItems()
        [item].prepareForQueue().forEach {
            insert($0, after: items().last)
        }
        actionAtItemEnd = .advance
    }
}

// MARK: - AVPlayerItems' Utils
fileprivate extension Array where Element: AVPlayerItem {
    
    func prepareForQueue() -> [AVPlayerItem] {
        if count == 1, let itemCopy = first?.copy() as? AVPlayerItem {
            return self + [itemCopy]
        }
        
        return self
    }
    
    init(copy item: Element, count: Int) {
        let elements = [Int](0...count).compactMap { _ in return item.copy() as? Element }
        self.init(elements)
    }
}

