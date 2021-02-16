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
    
    func downloadFile(_ file: S3File) {
        let url = bucketUrl.appendingPathComponent(file.cloudName)
        let downloadTask = URLSession.shared.downloadTask(with: url) {
            downloadUrl, response, error in
            // check for and handle errors
            if let error = error {
                print("download error \(error)")
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode else { return }
            guard 200 <= status && status < 299 else {
                print("download failed with status code: \(status)")
                return
            }
            
            // move file from temp location
            guard let fileURL = downloadUrl else { return }
            Cache.saveFile(currentUrl: fileURL, file: file)
            print(fileURL)

        }
        downloadTask.resume()
    }
    
    func listFiles(completion: @escaping (Result<Set<S3File>, Error>) -> ()) {
        // get session
        let session = URLSession.shared
        
        // create the request
        let url = bucketUrl.appendingQueryItems([URLQueryItem(name: "list-type", value: "2")])!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Start a new Task
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                print("list failed with error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let status = (response as? HTTPURLResponse)?.statusCode else { return }
            guard 200 <= status && status < 299 else {
                completion(.failure("list failed with status code: \(status)"))
                return
            }
            
            guard let data = data else { return }
            let parser = XMLParser(data: data)
            let fileParserManager = FileListParser()
            parser.delegate = fileParserManager
            parser.parse()
            completion(.success(fileParserManager.files))
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    class FileListParser: NSObject, XMLParserDelegate {
        var files: Set<S3File> = Set<S3File>()
        var elementName: String = String()
        var fileName = String()
        var fileTag = String()
        
        // when <Content> is encountered
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            
            if elementName == "Contents" {
                fileName = String()
                fileTag = String()
            }
            
            self.elementName = elementName
        }
        
        // when </Content> is encountered
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            if elementName == "Contents" {
                let name: NSString = fileName as NSString
                let file = S3File(name: name.deletingPathExtension, ext: name.pathExtension, etag: fileTag)
                files.insert(file)
            }
        }
        
        // execute the actual parsing
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            let foundString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if (!foundString.isEmpty) {
                switch self.elementName {
                case "Key":
                    fileName += foundString
                case "ETag":
                    var trimmed = foundString.dropFirst()
                    trimmed = trimmed.dropLast()
                    fileTag += String(trimmed)
                default:
                    return
                }
            }
        }
    }
}

struct S3File: Codable {
    let name: String
    let ext: String
    let etag: String
    
    var localName: String {
        return "\(etag).\(ext)"
    }
    
    var cloudName: String {
        return "\(name).\(ext)"
    }
}

extension S3File: Equatable, Hashable {
    static func == (lhs: S3File, rhs: S3File) -> Bool {
        return lhs.etag == rhs.etag
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(etag)
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

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

