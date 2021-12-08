//
//  S3Client.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 12/6/20.
//

import Foundation

struct S3Client {
    let bucketUrl: URL
    
    init?(bucketName: String) {
        guard let url = URL(string: "https://\(bucketName).s3.amazonaws.com/") else {
            return nil
        }
        bucketUrl = url
    }
    
    func downloadFile(_ file: S3File) async throws -> URL {
        // download file from server
        let url = bucketUrl.appendingPathComponent(file.cloudName)
        let (downloadLocation, response) = try await URLSession.shared.download(from: url)
        
        // handle errors
        guard let status = (response as? HTTPURLResponse)?.statusCode else {
            throw URLError(.badServerResponse)
        }
        guard 200 <= status && status < 299 else {
            throw URLError(.badServerResponse)
        }
        
        return downloadLocation
    }
    
    func listFiles() async throws -> Set<S3File> {
        // list from server
        let url = bucketUrl.appendingQueryItems([URLQueryItem(name: "list-type", value: "2")])!
        let decoder = FileListDecoder()
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // handle errors
        guard let status = (response as? HTTPURLResponse)?.statusCode else {
            throw URLError(.badServerResponse)
        }
        guard 200 <= status && status < 299 else {
            throw URLError(.badServerResponse)
        }
        
        // return decoded text
        return try decoder.decode(Set<S3File>.self, from: data)
    }
}

extension URL {
    /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
    /// URL must conform to RFC 3986.
    func appendingQueryItems(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            // URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
            return nil
        }
        // append the query items to the existing ones
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
        
        // return the url from new url components
        return urlComponents.url
    }
}


