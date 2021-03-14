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
        let lastFetch   = Cache.getLastUpdate()
        let timeBetween = Preferences.retrieveFromFile().updateFrequency
        let nextFetch   = lastFetch.addingTimeInterval(timeBetween)
        if  nextFetch <= Date() {
            print("updating...")
            updateFromCloud()
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
                if #available(macOS 11.0, *) {
                    added
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
                    added.forEach { file in
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
                
                removed
                    .publisher
                    .sink { file in
                        Cache.removeFile(file: file)
                    }
                    .store(in: &cancellables)
            }).store(in: &cancellables)
    }
}

fileprivate extension Set where Element == S3File {
    var diffFromIndex: (Self, Self) {
        let existingFiles = Cache.getVideoIndex().union(Cache.getImageIndex())
        return self.diff(old: existingFiles)
    }
}