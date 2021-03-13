//
//  ImagePlayer.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/17/21.
//

import AppKit
import Combine

final class ImagePlayer: CALayer {
    // MARK: - Properties
    var timer: Timer?
    var imgQueue: [NSImage]
    var index: Int = 0
    
    var subscriptions = Set<AnyCancellable>()
    
    var isEnabled: Bool {
        imgQueue.count != 0
    }
    
    // MARK: - Init
    override init() {
        imgQueue = Cache.getImageIndex().compactMap { Cache.getImage($0) }
        super.init()
        
        self.contents = imgQueue.first
        
        // add downloaded files to queue
        Cache
            .newImageDownloaded
            .compactMap { Cache.getImage($0) }
            .sink { self.imgQueue.append($0) }
            .store(in: &subscriptions)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Looping
    override func display() {
        guard !imgQueue.isEmpty else {
            return
        }
        self.contents = imgQueue[index]
    }

    func play() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: nextImage)
        timer?.fire()
    }
    
    func pause() {
        timer?.invalidate()
    }
    
    func nextImage(_: Timer) {
        // check that there are images
        guard !imgQueue.isEmpty else {
            return
        }
        
        // notify content view of switch
        NotificationCenter.default.post(Notification(name: .ContentFinished))
        
        // switch image
        index += 1
        if index == imgQueue.count {
            index = 0
        }
        
        DispatchQueue.main.async {
            self.contents = self.imgQueue[self.index]
        }
        
    }
    
}


