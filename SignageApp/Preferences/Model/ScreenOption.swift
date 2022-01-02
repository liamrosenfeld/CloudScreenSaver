//
//  ScreenOption.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/14/21.
//

import AppKit

enum ScreenOption {
    case main
    case all
    case custom(screens: Set<Screen>)
}

struct Screen: Identifiable {
    var id: CGDirectDisplayID
    var name: String
    
    init(nsscreen: NSScreen) {
        self.id = nsscreen.id
        self.name = nsscreen.localizedName
    }
}

extension ScreenOption: Hashable, Codable { }
extension Screen: Codable, Hashable { }
