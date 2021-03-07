//
//  URLSesson+Combine.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/7/21.
//

import Foundation
import Combine

extension URLSession {
    func downloadFile(url: URL) -> Future<URL, Error> {
        Future { promise in
            let downloadTask = URLSession.shared.downloadTask(with: url) {
                downloadUrl, response, error in
                // check for and handle errors
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let status = (response as? HTTPURLResponse)?.statusCode else { return }
                guard 200 <= status && status < 299 else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                
                // get temp location of file
                guard let fileURL = downloadUrl else { return }
                promise(.success(fileURL))
            }
            downloadTask.resume()
        }
    }
    
    func makeRequest(request: URLRequest) -> Future<Data, Error> {
        Future { promise in
            let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let status = (response as? HTTPURLResponse)?.statusCode else { return }
                guard 200 <= status && status < 299 else {
                    promise(.failure(URLError(.badServerResponse)))
                    return
                }
                
                guard let data = data else { return }
                promise(.success(data))
            }
            task.resume()
        }
    }
}
