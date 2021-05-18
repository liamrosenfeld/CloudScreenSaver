//
//  PlayerView.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/6/21.
//

import AppKit
import AVFoundation

class PlayerView: NSView {
    
    init(frame: NSRect, queueManager: QueueManager) {
        super.init(frame: frame)
        
        let player = ContentPlayer(frame: frame, queueManager: queueManager)
        self.wantsLayer = true
        self.layer = player
        
        player.play()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
