//
//  ScreenOption.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/14/21.
//

import Foundation

enum ScreenOption {
    case main
    case all
    case custom(screens: Set<CGDirectDisplayID>)
}

extension ScreenOption: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case associatedValues

        enum CustomKeys: String, CodingKey {
            case screens
        }
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .type) {
        case "main":
            self = .main
        case "all":
            self = .all
        case "custom":
            let subContainer = try container.nestedContainer(keyedBy: CodingKeys.CustomKeys.self, forKey: .associatedValues)
            let associatedValues0 = try subContainer.decode(Set<CGDirectDisplayID>.self, forKey: .screens)
            self = .custom(screens: associatedValues0)
        default:
            throw DecodingError.keyNotFound(CodingKeys.type, .init(codingPath: container.codingPath, debugDescription: "Unknown key"))
        }
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .main:
            try container.encode("main", forKey: .type)
        case .all:
            try container.encode("all", forKey: .type)
        case let .custom(screens):
            try container.encode("custom", forKey: .type)
            var subContainer = container.nestedContainer(keyedBy: CodingKeys.CustomKeys.self, forKey: .associatedValues)
            try subContainer.encode(screens, forKey: .screens)
        }
    }
}
