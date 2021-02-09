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
        let url = bucketUrl.appendingPathComponent(file.name)
        let downloadTask = URLSession.shared.downloadTask(with: url) {
            urlOrNil, responseOrNil, errorOrNil in
            // check for and handle errors:
            // * errorOrNil should be nil
            // * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299
            
            guard let fileURL = urlOrNil else { return }
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
                // Failure
                print("URL Session Task Failed: \(error)")
                completion(.failure(error))
            } else if let data = data {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                
                let parser = XMLParser(data: data)
                let fileParserManager = FileListParser()
                parser.delegate = fileParserManager
                parser.parse()
                completion(.success(fileParserManager.files))
            }
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
                let file = S3File(name: fileName, etag: fileTag)
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
    let etag: String
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



