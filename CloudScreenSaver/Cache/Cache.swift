//
//  Cache.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 12/4/20.
//

import Cocoa
import AVKit
import Combine

/**
In `.../Application Support/CloudScreenSaver/Cache/`
 
 Folder location depends on macOS Version:
 - 10.15+: `~/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver/Data/Library/Application Support/CloudScreenSaver/`
 - Lower: `~/Library/Application Support/CloudScreenSaver/`
 */

enum Cache {
    // MARK: - Subjects
    static let newVideoDownloaded = PassthroughSubject<S3File, Never>()
    static let newImageDownloaded = PassthroughSubject<S3File, Never>()
    
    // MARK: - Actions
    static func clearCache() {
        do {
            // remove all videos
            let directoryContent = try FileManager.default.contentsOfDirectory(at: Paths.cacheFolder, includingPropertiesForKeys: nil)
            for video in directoryContent {
                try? FileManager.default.removeItem(at: video)
            }
            
            // clear index
            try? FileManager.default.removeItem(at: Paths.cacheVideoIndexFile)
            try? FileManager.default.removeItem(at: Paths.cacheImageIndexFile)
        } catch {
            fatalError("Error during removal of videos: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Add + Remove
    static func saveFile(currentUrl: URL, file: S3File) {
        // sort
        // (extensions were lowercased in xml parser)
        let videoExts = ["mov", "mp4"]
        let imageExts = ["png", "jpg", "jpeg"]
        
        var type: MediaType = .video
        if videoExts.contains(file.ext) {
            type = .video
        } else if imageExts.contains(file.ext) {
            type = .image
        } else {
            print("\(file.ext) is not a valid format")
            return
        }
        
        // save file
        let saveURL = Paths.cacheFolder.appendingPathComponent(file.localName)
        do {
            try FileManager.default.moveItem(at: currentUrl, to: saveURL)
            print("saved \(saveURL)")
        } catch {
            print ("saveFile error: \(error)")
        }
        
        // update index
        let index: URL = {
            switch type {
            case .video:
                return Paths.cacheVideoIndexFile
            case .image:
                return Paths.cacheImageIndexFile
            }
        }()
        var files = index.getDecodableFile() ?? Set<S3File>()
        files.update(with: file)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(files)
        FileManager.default.createFile(atPath: index.path, contents: data, attributes: nil)
        
        // notify respective player
        switch type {
        case .video:
            return newVideoDownloaded.send(file)
        case .image:
            return newImageDownloaded.send(file)
        }
    }
    
    static func removeFile(file: S3File) {
        // save file
        let savedURL = Paths.cacheFolder.appendingPathComponent(file.localName)
        do {
            try FileManager.default.removeItem(at: savedURL)
        } catch {
            print ("file error: \(error)")
        }
        
        // update index
        var files = getVideoIndex()
        files.remove(file)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(files)
        FileManager.default.createFile(atPath: Paths.cacheVideoIndexFile.path, contents: data, attributes: nil)
    }
    
    // MARK: - Retrieving
    static func getVideo(_ file: S3File) -> AVAsset? {
        let url = Paths.cacheFolder.appendingPathComponent(file.localName)
        if !FileManager.default.fileExists(atPath: url.path) {
            print("\(file.localName) not found")
            return nil
        }
        return AVAsset(url: url)
    }
    
    static func getImage(_ file: S3File) -> NSImage? {
        let url = Paths.cacheFolder.appendingPathComponent(file.localName)
        if !FileManager.default.fileExists(atPath: url.path) {
            print("\(file.localName) not found")
            return nil
        }
        return NSImage(contentsOf: url)!
    }
    
    // MARK: - Internal Files
    static func getVideoIndex() -> Set<S3File> {
        return Paths.cacheVideoIndexFile.getDecodableFile() ?? Set<S3File>()
    }
    
    static func getImageIndex() -> Set<S3File> {
        return Paths.cacheImageIndexFile.getDecodableFile() ?? Set<S3File>()
    }
    
    static func getLastUpdate() -> Date {
        let str = (try? String(contentsOf: Paths.lastUpdateFile)) ?? "0"
        let interval = Double(str) ?? 0
        return Date.init(timeIntervalSince1970: interval)
    }
}

extension URL {
    func getDecodableFile<Dest: Decodable>() -> Dest? {
        guard let data = try? Data(contentsOf: self) else { return nil }
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

enum MediaType {
    case video
    case image
}
