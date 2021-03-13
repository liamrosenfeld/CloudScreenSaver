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
        Cache.newImageDownloaded.sink { file in
            // add image to queue
            guard let newImage = Cache.getImage(file) else { return }
            self.imgQueue.append(newImage)
        }.store(in: &subscriptions)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Looping
    func play() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: nextImage)
    }
    
    func pause() {
        timer?.invalidate()
    }
    
    func nextImage(timer: Timer) {
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
        self.contents = imgQueue[index]
    }
    
}


