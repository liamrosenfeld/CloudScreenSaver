//
//  View+OnChange.swift
//  CloudScreenSaver
//
//  From https://betterprogramming.pub/implementing-swiftui-onchange-support-for-ios13-577f9c086c9
//

import Combine
import SwiftUI

@available(macOS, deprecated: 11.0, message: "Use the built-in API instead")
extension View {
    @ViewBuilder func onChange<T: Equatable>(of value: T, perform action: @escaping (T) -> Void) -> some View {
        self.onReceive(Just(value)) { (value) in
            action(value)
        }
    }
}
