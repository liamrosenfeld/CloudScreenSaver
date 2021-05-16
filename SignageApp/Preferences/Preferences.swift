//
//  Preferences.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/8/21.
//

import Foundation

struct Preferences {
    // content
    @GreaterThanOne var loopCount: Int = 1
    @GreaterThanOne var imageDuration: Int = 3
    
    // cloud
    var bucketName: String = ""
    var updateFrequency: TimeInterval = 86400.0
    
    // launcing
    var startingScreen: ScreenOption = .main
    var startFullscreen: Bool = false
    
    static func retrieveFromFile() -> Preferences {
        let existingFilesData = try! Data(contentsOf: Paths.preferencesFile)
        let decoder = JSONDecoder()
        let preferences = (try? decoder.decode(Preferences.self, from: existingFilesData)) ?? Preferences()
        return preferences
    }
    
    func saveToFile() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        FileManager.default.createFile(atPath: Paths.preferencesFile.path, contents: data, attributes: nil)
    }
}

extension Preferences: Codable {}
