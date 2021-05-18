//
//  PlayerViewController.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/16/21.
//

import AppKit

class PlayerViewController: NSViewController {
    var playerView: NSView
    var mouseDelegate: MouseDelegate
    var trackingArea: NSTrackingArea?
    
    init(frame: NSRect, queueManager: QueueManager, mouseDelegate: MouseDelegate) {
        self.playerView = PlayerView(frame: frame, queueManager: queueManager)
        self.mouseDelegate = mouseDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = playerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        setupTracking()
    }
    
    func setupTracking() {
        trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved, .inVisibleRect],
            owner: mouseDelegate,
            userInfo: nil
        )
        view.addTrackingArea(trackingArea!)
    }
    
    // MARK: - Fullscreen Workaround
    // for some reason the tracking area need to be reset when the view starts in fullscreen
    var needsNewTracking = false
    
    func startedFullscreen() {
        needsNewTracking = true
    }
    
    override func viewDidLayout() {
        if needsNewTracking {
            if let area = trackingArea {
                view.removeTrackingArea(area)
            }
            mouseDelegate.setupHider()
            setupTracking()
            needsNewTracking = false
        }
    }
}
