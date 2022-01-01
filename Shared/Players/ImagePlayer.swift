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
            // keeps it from flashing in when switching to the image view
            currentImg = image
        } else {
            queue.append(image)
        }
    }
    
    func play() {
        paused = false
        
        Task {
            while !paused {
                try? await Task<Never, Never>.sleep(nanoseconds: UInt64(imgDuration * 1_000_000_000))
                nextImage()
            }
        }
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
            pause()
            return
        }
        
        // notify of switch
        finishedImage.send()
        
        // switch image
        currentImg = queue.removeFirst()
    }
}
