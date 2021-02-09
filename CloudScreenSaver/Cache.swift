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

enum Cache {
    // MARK: - Actions
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
    
    static func saveFile(currentUrl: URL, file: S3File) {
        // save file
        let savedURL = cachePath.appendingPathComponent(file.name)
        do {
            try FileManager.default.moveItem(at: currentUrl, to: savedURL)
        } catch {
            print ("file error: \(error)")
        }
        
        // update index
        var files = getIndex()
        files.update(with: file)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(files)
        FileManager.default.createFile(atPath: cacheIndex.path, contents: data, attributes: nil)
        
        // notify video display
        let notification = Notification(name: .NewVideoDownloaded, object: file, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    static func removeFile(file: S3File) {
        // save file
        let savedURL = cachePath.appendingPathComponent(file.name)
        do {
            try FileManager.default.removeItem(at: savedURL)
        } catch {
            print ("file error: \(error)")
        }
        
        // update index
        var files = getIndex()
        files.remove(file)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(files)
        FileManager.default.createFile(atPath: cacheIndex.path, contents: data, attributes: nil)
    }
    
    static func pullFiles() {
//        clearCache()
        
        guard let bucket = S3Client(bucketName: "cloud-screen-saver") else {
            fatalError("invalid bucket")
        }
        bucket.listFiles { result in
            switch result {
            case .success(let files):
                let existingFiles = getIndex()
                let diff = files.diff(old: existingFiles)
                diff.added.forEach { file in
                    bucket.downloadFile(file)
                }
                diff.removed.forEach { file in
                    removeFile(file: file)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Retrieving
    static func getFile(_ file: S3File) -> AVAsset? {
        let url = cachePath.appendingPathComponent(file.name)
        if !FileManager.default.fileExists(atPath: url.path) {
            print("\(file.name) not found")
            return nil
        }
        return AVAsset(url: url)
    }
    
    static func getIndex() -> Set<S3File> {
        let existingFilesData = try! Data(contentsOf: cacheIndex)
        let decoder = JSONDecoder()
        let files = (try? decoder.decode(Set<S3File>.self, from: existingFilesData)) ?? Set<S3File>()
        return files
    }
    
    // MARK: - Directories
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
    
    private static var cachePath: URL = {
        let cache = Cache.supportPath.appendingPathComponent("Cache")
        
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
    
    private static var cacheIndex: URL = {
        let cache = Cache.supportPath.appendingPathComponent("cache-index.json")
        
        if !FileManager.default.fileExists(atPath: cache.path) {
            print("Creating cache index...")
            FileManager.default.createFile(atPath: cache.path, contents: nil, attributes: nil)
        }
        
        return cache
    }()
}


extension Set where Element: Equatable {
    func diff(old: Self) -> (added: Self, removed: Self) {
        let difference = self.symmetricDifference(old)
        let added = difference.intersection(self)
        let removed = difference.intersection(old)
        return (added, removed)
    }
}
