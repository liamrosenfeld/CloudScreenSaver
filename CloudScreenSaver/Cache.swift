//
//  Cache.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 12/4/20.
//

import Cocoa
import AVKit

/**
In `.../Application Support/CloudScreenSaver/Cache/`
 
 Folder location depends on macOS Version:
 - 10.15+: `~/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver/Data/Library/Application Support/CloudScreenSaver/`
 - Lower: `~/Library/Application Support/CloudScreenSaver/`
 */

struct Cache {
    // MARK: - Interactions
    static func clearCache() {
        do {
            let directoryContent = try FileManager.default.contentsOfDirectory(at: cachePath, includingPropertiesForKeys: nil)
            let videoURLs = directoryContent.filter { $0.pathExtension == "mp4" || $0.pathExtension == "mov"}
            
            for video in videoURLs {
                try? FileManager.default.removeItem(at: video)
            }
        } catch {
            fatalError("Error during removal of videos: \(error.localizedDescription)")
        }
    }
    
    static func getVideo(_ video: Video) -> AVAsset? {
        let url = cachePath.appendingPathComponent("\(video.name).\(video.ext.rawValue)")
        if !FileManager.default.fileExists(atPath: url.path) {
            print("\(video.name) not found")
            return nil
        }
        return AVAsset(url: url)
    }
    
    // MARK: - Testing
    static func setupMock() {
        storeVideoFromBundle("auroraBorealis")
        storeVideoFromBundle("bits")
    }
    
    static func storeVideoFromBundle(_ name: String) {
        let bundle = Bundle.main.url(forResource: name, withExtension: "mp4")!
        let dest = cachePath.appendingPathComponent("\(name).mp4")
        if FileManager.default.fileExists(atPath: dest.path) {
            print("\(name) already exists")
            return
        }
        try! FileManager.default.copyItem(
            at: bundle,
            to: dest
        )
    }
    
    // MARK: - Directories
    private static var supportPath: URL {
        // Grab an array of Application Support paths
        let appSupportPaths = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask,
            true
        )
        
        if appSupportPaths.isEmpty {
            fatalError("FATAL : app support does not exist!")
        }
        
        let appSupportDirectory = URL(fileURLWithPath: appSupportPaths[0], isDirectory: true)
        
        let cssFolder = appSupportDirectory.appendingPathComponent("CloudScreenSaver")
        let cssFolderExists = FileManager.default.fileExists(atPath: cssFolder.path)
        
        if cssFolderExists {
            return cssFolder
        } else {
            print("Creating app support directory...")
            
            do {
                try FileManager.default.createDirectory(
                    at: cssFolder,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
                return cssFolder
            } catch let error {
                fatalError("FATAL : Couldn't create app support directory in User directory: \(error)")
            }
        }
    }
    
    private static var cachePath: URL = {
        let cache = Cache.supportPath.appendingPathComponent("Cache")
        
        if FileManager.default.fileExists(atPath: cache.path) {
            return cache
        } else {
            do {
                try FileManager.default.createDirectory(
                    at: cache,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
                return cache
            } catch let error {
                fatalError("FATAL : Couldn't create Cache directory in CloudScreenSaver's AppSupport directory: \(error)")
            }
        }
    }()
}
