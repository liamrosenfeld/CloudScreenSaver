//
//  GreaterThanOne.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/13/21.
//

import Foundation

@propertyWrapper
struct GreaterThanOne<Value: Numeric & Comparable> {
    var value: Value

    init(wrappedValue: Value) {
        self.value = max(Value(exactly: 1)!, wrappedValue)
    }
    
    var wrappedValue: Value {
        get { value }
        set(newValue) { value = max(Value(exactly: 1)!, newValue) }
    }
}

extension GreaterThanOne: Codable where Value: Codable {}
