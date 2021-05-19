//
//  Screen.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/15/21.
//

import AppKit

struct Screen: Identifiable {
    var id: CGDirectDisplayID
    var name: String
    
    init(nsscreen: NSScreen) {
        self.id = nsscreen.id
        self.name = nsscreen.localizedName
    }
}

extension Screen: Codable, Hashable { }
