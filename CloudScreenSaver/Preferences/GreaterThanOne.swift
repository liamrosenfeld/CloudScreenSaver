//
//  GreaterThanOne.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/13/21.
//

import Foundation

@propertyWrapper
struct GreaterThanOne {
    var value: Int
    
    init(wrappedValue: Int) {
        self.value = max(1, wrappedValue)
    }
    
    var wrappedValue: Int {
        get { value }
        set(newValue) { value = max(1, newValue) }
    }
}

extension GreaterThanOne: Codable {}
