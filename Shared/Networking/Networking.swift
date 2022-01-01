//
//  Networking.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/6/21.
//

import Foundation

enum Networking {
    static func updateIfTime() async {
        // get time of the next fetch
        let lastFetch   = Cache.getLastUpdate()
        let timeBetween = Preferences.retrieveFromFile().updateFrequency
        let nextFetch   = lastFetch.addingTimeInterval(timeBetween)
        
        // update if update frequency preference has passed
        // always update if nothing is downloaded
        if nextFetch <= Date() || Cache.getCombinedIndex().count == 0 {
            print("updating...")
            Task(priority: .medium) {
                await Networking.updateFromCloud()
            }
        }
    }
    
    static func updateFromCloud() async {
        guard let bucket = S3Client(bucketName: Preferences.retrieveFromFile().bucketName) else {
            print("invalid bucket")
            return
        }
        guard let fileDiff = try? await bucket.listFiles().diffFromIndex else {
            print("could not connect to bucket")
            return
        }
        
        for file in fileDiff.added {
            do {
                let url = try await bucket.downloadFile(file)
                Cache.saveFile(currentUrl: url, file: file)
            } catch let error {
                print("downloading files failed: \(error.localizedDescription)")
            }
        }
        
        for file in fileDiff.removed {
            Cache.removeFile(file: file)
        }
        
        Cache.updateLastUpdate()
    }
}

fileprivate extension Set where Element == S3File {
    var diffFromIndex: (added: Self, removed: Self) {
        return self.diff(old: Cache.getCombinedIndex())
    }
}
