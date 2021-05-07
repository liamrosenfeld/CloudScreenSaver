//
//  S3Client.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 12/6/20.
//

import Foundation
import Combine

struct S3Client {
    let bucketUrl: URL
    
    init?(bucketName: String) {
        guard let url = URL(string: "https://\(bucketName).s3.amazonaws.com/") else {
            return nil
        }
        bucketUrl = url
    }
    
    func downloadFile(_ file: S3File) -> Future<URL, Error> {
        let url = bucketUrl.appendingPathComponent(file.cloudName)
        return URLSession.shared.downloadFile(url: url)
    }
    
    func listFiles() -> AnyPublisher<Set<S3File>, Error> {
        // create the request
        let url = bucketUrl.appendingQueryItems([URLQueryItem(name: "list-type", value: "2")])!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Start a new Task
        return URLSession.shared
            .makeRequest(request: request)
            .decode(type: Set<S3File>.self, decoder: FileListDecoder())
            .eraseToAnyPublisher()
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


