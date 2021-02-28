//
//  Notifications.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/17/21.
//

import Foundation

extension Notification.Name {
    static let NewVideoDownloaded: Self = Notification.Name(rawValue: "NewVideoDownloaded")
    static let NewImageDownloaded: Self = Notification.Name(rawValue: "NewImageDownloaded")
}
