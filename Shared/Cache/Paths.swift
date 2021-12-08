//
//  Paths.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/9/21.
//

import Foundation

enum Paths {
    static var cacheFolder: URL = {
        getOrMakeFolder(named: "Cache")
    }()
    
    static var tempFolder: URL = {
        getOrMakeFolder(named: "Temp")
    }()
    
    static var preferencesFile: URL = {
        return rootFile(named: "preferences.json")
    }()
    
    static var cacheVideoIndexFile: URL = {
        print(rootFile(named: "cache-video-index.json"))
        return rootFile(named: "cache-video-index.json")
    }()
    
    static var cacheImageIndexFile: URL = {
        return rootFile(named: "cache-image-index.json")
    }()
    
    static var lastUpdateFile: URL = {
        return rootFile(named: "last-update.txt")
    }()
    
    // MARK: - Helpers
    static private func getOrMakeFolder(named name: String) -> URL {
        let dir = supportPath.appendingPathComponent(name)
        
        if !FileManager.default.fileExists(atPath: dir.path) {
            print("Creating \(name) directory...")
            do {
                try FileManager.default.createDirectory(
                    at: dir,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            } catch let error {
                fatalError("FATAL : Couldn't create \(name) directory in CloudScreenSaver's AppSupport directory: \(error)")
            }
        }
        
        return dir
    }
    
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
