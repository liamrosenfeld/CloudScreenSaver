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
            // remove all videos
            let directoryContent = try FileManager.default.contentsOfDirectory(at: Paths.cacheFolder, includingPropertiesForKeys: nil)
            for video in directoryContent {
                try? FileManager.default.removeItem(at: video)
            }
            
            // clear index
            try? FileManager.default.removeItem(at: Paths.cacheIndexFile)
        } catch {
            fatalError("Error during removal of videos: \(error.localizedDescription)")
        }
    }
    
    static func updateIfTime() {
        let lastFetch   = getLastUpdate()
        let timeBetween = Preferences.retrieveFromFile().updateFrequency
        print(timeBetween)
        let nextFetch   = lastFetch.addingTimeInterval(timeBetween)
        print(nextFetch)
        if  nextFetch <= Date() {
            print("updating")
            updateFromCloud()
        }
    }
    
    static func updateFromCloud() {
        guard let bucket = S3Client(bucketName: "cloud-screen-saver") else {
            fatalError("invalid bucket")
        }
        bucket.listFiles { result in
            switch result {
            case .success(let files):
                // get diff
                let existingFiles = getIndex()
                let diff = files.diff(old: existingFiles)
                
                // apply diff
                diff.added.forEach { file in
                    bucket.downloadFile(file)
                }
                diff.removed.forEach { file in
                    removeFile(file: file)
                }
                
                // record fetch time
                let date = String(Date().timeIntervalSince1970)
                try! date.write(to: Paths.lastUpdateFile, atomically: true, encoding: .utf8)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Add + Remove
    static func saveFile(currentUrl: URL, file: S3File) {
        // save file
        let savedURL = Paths.cacheFolder.appendingPathComponent(file.name)
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
        FileManager.default.createFile(atPath: Paths.cacheIndexFile.path, contents: data, attributes: nil)
        
        // notify video display
        let notification = Notification(name: .NewVideoDownloaded, object: file, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    static func removeFile(file: S3File) {
        // save file
        let savedURL = Paths.cacheFolder.appendingPathComponent(file.name)
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
        FileManager.default.createFile(atPath: Paths.cacheIndexFile.path, contents: data, attributes: nil)
    }
    
    // MARK: - Retrieving
    static func getVideo(_ file: S3File) -> AVAsset? {
        let url = Paths.cacheFolder.appendingPathComponent(file.name)
        if !FileManager.default.fileExists(atPath: url.path) {
            print("\(file.name) not found")
            return nil
        }
        return AVAsset(url: url)
    }
    
    // MARK: - Internal Files
    static func getIndex() -> Set<S3File> {
        return Paths.cacheIndexFile.getDecodableFile() ?? Set<S3File>()
    }
    
    static func getLastUpdate() -> Date {
        let str = (try? String(contentsOf: Paths.lastUpdateFile)) ?? "0"
        let interval = Double(str) ?? 0
        return Date.init(timeIntervalSince1970: interval)
    }
}

extension URL {
    func getDecodableFile<Dest: Decodable>() -> Dest? {
        let data = try! Data(contentsOf: self)
        let decoder = JSONDecoder()
        let files = (try? decoder.decode(Dest.self, from: data))
        return files
    }
}

extension Set where Element: Equatable {
    func diff(old: Self) -> (added: Self, removed: Self) {
        let difference = self.symmetricDifference(old)
        let added = difference.intersection(self)
        let removed = difference.intersection(old)
        return (added, removed)
    }
}
