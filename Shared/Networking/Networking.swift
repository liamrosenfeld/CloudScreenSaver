//
//  Networking.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/6/21.
//

import Foundation
import Combine

enum Networking {
    static var cancellables = Set<AnyCancellable>()
    
    static func updateIfTime() {
        // get time of the next fetch
        let lastFetch   = Cache.getLastUpdate()
        let timeBetween = Preferences.retrieveFromFile().updateFrequency
        let nextFetch   = lastFetch.addingTimeInterval(timeBetween)
        
        // update if update frequency preference has passed
        // always update if nothing is downloaded
        if  nextFetch <= Date() || Cache.getCombinedIndex().count == 0 {
            print("updating...")
            DispatchQueue.global(qos: .default).async {
                Networking.updateFromCloud()
            }
        }
    }
    
    static func updateFromCloud() {
        guard let bucket = S3Client(bucketName: Preferences.retrieveFromFile().bucketName) else {
            fatalError("invalid bucket")
        }
        bucket
            .listFiles()
            .map(\.diffFromIndex)
            .sink(receiveCompletion: { completion in
                print("listFiles completed: \(completion)")
            }, receiveValue: { (added, removed) in
                downloadFiles(added, bucket: bucket)
                removeFiles(removed)
                Cache.updateLastUpdate()
            }).store(in: &cancellables)
    }
    
    static private func downloadFiles(_ files: Set<S3File>, bucket: S3Client) {
        if #available(macOS 11.0, *) {
            files
                .publisher
                .flatMap { file in
                    bucket.downloadFile(file).map { fileURL -> (file: S3File, fileURL: URL) in
                        (file, fileURL)
                    }
                }
                .sink(
                    receiveCompletion: { completion in
                        print("download finished: \(completion)")
                    },
                    receiveValue: { fileInfo in
                        Cache.saveFile(currentUrl: fileInfo.fileURL, file: fileInfo.file)
                    }
                )
                .store(in: &cancellables)
        } else {
            files.forEach { file in
                bucket
                    .downloadFile(file)
                    .sink(
                        receiveCompletion: { completion in
                            print("download finished: \(completion)")
                        },
                        receiveValue: { fileURL in
                            Cache.saveFile(currentUrl: fileURL, file: file)
                        }
                    ).store(in: &cancellables)
            }
        }
    }
    
    static private func removeFiles(_ files: Set<S3File>) {
        files
            .publisher
            .sink { file in
                Cache.removeFile(file: file)
            }
            .store(in: &cancellables)
    }
}

fileprivate extension Set where Element == S3File {
    var diffFromIndex: (Self, Self) {
        return self.diff(old: Cache.getCombinedIndex())
    }
}
