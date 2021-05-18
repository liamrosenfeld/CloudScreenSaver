//
//  MouseDelegate.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/16/21.
//

import AppKit
import Combine

class MouseDelegate: NSResponder {
    let mouseMoved = PassthroughSubject<Void, Never>()
    var cancellable: AnyCancellable?
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        mouseMoved.send()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        setupHider()
        mouseMoved.send()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        // make sure mouse does not disappear outside of window
        cancellable?.cancel()
    }
    
    func setupHider() {
        // hide the mouse after 2 seconds of not moving the mouse
        cancellable = mouseMoved
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { _ in
                NSCursor.setHiddenUntilMouseMoves(true)
            }
    }
}
