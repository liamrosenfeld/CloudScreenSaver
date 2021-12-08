//
//  URLSession+AsyncBack.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 12/7/21.
//

import Foundation

@available(macOS, deprecated: 12.0, message: "Use the built-in API instead")
extension URLSession {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
    
    func download(from url: URL) async throws -> (URL, URLResponse) {
        // URLSession.downloadTask deletes the file when the completion handler finishes
        // so that can't be used for this
        // this recreates URLSession.download(from:) so it can be a replacement until macOS 12 is the min target
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                // get data
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                // save data to temp directory
                let tempUrl = Paths.tempFolder.appendingPathComponent("TempFile\(Int.random(in: 1000...9999)).tmp")
                do {
                    try data.write(to: tempUrl)
                } catch let error {
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (tempUrl, response))
            }

            task.resume()
        }
    }
}
