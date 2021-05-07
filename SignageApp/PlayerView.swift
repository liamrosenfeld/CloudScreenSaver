//
//  PlayerView.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/6/21.
//

import AppKit
import AVFoundation

class PlayerView: NSView {
    
    var contentPlayer: ContentPlayer
    
    override init(frame: NSRect) {
        contentPlayer = ContentPlayer(frame: frame)
        super.init(frame: frame)
        
        setupLayer()
        Networking.updateIfTime()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayer() {
        self.wantsLayer = true
        self.layer = contentPlayer
        contentPlayer.play()
    }
}
