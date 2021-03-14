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
    private var timer: Timer?
    private var imgQueue: [NSImage]
    private var index: Int = 0
    private var imgDuration = Preferences.retrieveFromFile().imageDuration
    
    private var subscriptions = Set<AnyCancellable>()
    
    var isEnabled: Bool {
        imgQueue.count != 0
    }
    
    var readyToSwitch = PassthroughSubject<Void, Never>()
    var willStop = false
    
    // MARK: - Init
    override init() {
        imgQueue = Cache.getImageIndex().compactMap { Cache.getImage($0) }
        super.init()
        
        self.contents = imgQueue.first
        
        // add downloaded files to queue
        Cache
            .newImageDownloaded
            .compactMap { Cache.getImage($0) }
            .sink { image in
                self.imgQueue.append(image)
                
                // display immediately if first image
                if self.imgQueue.count == 1 {
                    DispatchQueue.main.async {
                        self.contents = image
                    }
                }
            }
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
        timer = Timer.scheduledTimer(withTimeInterval: imgDuration, repeats: true, block: nextImage)
    }
    
    func pause() {
        willStop = false
        timer?.fire() // one last fire to get a new image next time it is shown
        timer?.invalidate()
    }

    func nextImage(_: Timer) {
        // check that there are images
        guard !imgQueue.isEmpty else {
            return
        }
        
        // notify content view of switch
        if willStop {
            readyToSwitch.send()
        } else {
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
}


