//
//  ImagePlayer.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/17/21.
//

import AppKit
import Combine

final class ImagePlayer: CALayer {
    
    private var queue: [NSImage] = []
    private var currentImg: NSImage? {
        didSet {
            // persist current image if set to nil
            if let img = currentImg {
                self.contents = img
            }
        }
    }
    private var paused = false
    private let imgDuration = Preferences.retrieveFromFile().imageDuration
    
    var finishedImage = PassthroughSubject<Void, Never>()
    
    override func display() {
        self.contents = currentImg
    }
    
    func addImage(_ image: NSImage) {
        if currentImg == nil {
            // if no image is currently displayed, just display it immediately
            currentImg = image
        } else {
            queue.append(image)
        }
    }

    func play() {
        paused = false
        DispatchQueue.main.asyncAfter(imgDuration, execute: nextImage)
    }
    
    func pause() {
        paused = true
    }
    
    private func nextImage() {
        // if there is nothing in the queue, set current image to nil
        // allows the add image function to know when to set immediately
        guard !queue.isEmpty else {
            currentImg = nil
            finishedImage.send()
            return
        }
        
        // notify of switch
        finishedImage.send()
        
        // don't show next image if it is paused
        guard !paused else {
            return
        }
        
        // switch image
        currentImg = queue.removeFirst()
        
        // set timer for next switch
        DispatchQueue.main.asyncAfter(imgDuration, execute: nextImage)
    }
}

extension DispatchQueue {
    func asyncAfter(_ timeInterval: Int, execute work: @escaping () -> Void) {
        self.asyncAfter(deadline: .now().advanced(by: .seconds(timeInterval)), execute: work)
    }
}
