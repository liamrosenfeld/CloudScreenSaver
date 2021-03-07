//
//  S3File.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/7/21.
//

import Foundation

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
