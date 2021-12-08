//
//  FileListDecoder.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/6/21.
//

import Foundation

struct FileListDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        let parser = XMLParser(data: data)
        let fileParserManager = FileListParser()
        parser.delegate = fileParserManager
        parser.parse()
        return fileParserManager.files as! T
    }
    
    class FileListParser: NSObject, XMLParserDelegate {
        var files: Set<S3File> = Set<S3File>()
        var elementName: String = String()
        var fileName = String()
        var fileTag = String()
        
        // when <Content> is encountered
        func parser(
            _ parser: XMLParser,
            didStartElement elementName: String,
            namespaceURI: String?,
            qualifiedName qName: String?,
            attributes attributeDict: [String : String] = [:]
        ) {
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
                let file = S3File(name: name.deletingPathExtension, ext: name.pathExtension.lowercased(), etag: fileTag)
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
