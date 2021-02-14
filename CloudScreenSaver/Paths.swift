//
//  Paths.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/9/21.
//

import Foundation

enum Paths {
    static var cacheFolder: URL = {
        let cache = supportPath.appendingPathComponent("Cache")
        
        if !FileManager.default.fileExists(atPath: cache.path) {
            print("Creating cache directory...")
            do {
                try FileManager.default.createDirectory(
                    at: cache,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            } catch let error {
                fatalError("FATAL : Couldn't create Cache directory in CloudScreenSaver's AppSupport directory: \(error)")
            }
        }
        
        return cache
    }()
    
    static var preferencesFile: URL = {
        return rootFile(named: "preferences.json")
    }()
    
    static var cacheIndexFile: URL = {
        return rootFile(named: "cache-index.json")
    }()
    
    static var lastUpdateFile: URL = {
        return rootFile(named: "last-update.txt")
    }()
    
    static private func rootFile(named name: String) -> URL {
        let url = supportPath.appendingPathComponent(name)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            print("Creating \(name)")
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        
        return url
    }
    
    private static var supportPath: URL = {
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
        
        if !cssFolderExists {
            print("Creating app support directory...")
            do {
                try FileManager.default.createDirectory(
                    at: cssFolder,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            } catch let error {
                fatalError("FATAL : Couldn't create app support directory in User directory: \(error)")
            }
        }
        
        return cssFolder
    }()
}
