//
//  ImagePlayer.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/17/21.
//

import AppKit

final class ImagePlayer: CALayer {
    // MARK: - Properties
    var timer: Timer?
    var images: [NSImage]
    var index: Int = 0
    
    // MARK: - Init
    override init() {
        images = Cache.getImageIndex().compactMap { Cache.getImage($0) }
        super.init()
        
        let image = images[0]
        self.contents = image
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
    
    func nextImage(timer: Timer ) {
        index += 1
        if index == images.count {
            index = 0
        }
        self.contents = images[index]
    }
    
}


