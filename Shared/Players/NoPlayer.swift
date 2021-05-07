//
//  NoPlayer.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 5/6/21.
//

import QuartzCore.CoreAnimation

class NoPlayer: CATextLayer {
    override init() {
        super.init()
        configure()
    }
    
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        fontSize = 30
        string = "Downloading content. If this screen persists, check the S3 bucket name in preferences and internet connection."
        alignmentMode = .center
        isWrapped = true
    }
    
    override func draw(in context: CGContext) {
        let height = self.bounds.size.height
        let fontSize = self.fontSize
        let yDiff = (height-fontSize)/2 - fontSize/10
        
        context.saveGState()
        context.translateBy(x: 0, y: -yDiff) // -yDiff when in non-flipped coordinates (macOS's default)
        super.draw(in: context)
        context.restoreGState()
    }
}
