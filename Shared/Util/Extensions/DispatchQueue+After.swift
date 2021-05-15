//
//  DispatchQueue+After.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/14/21.
//

import Foundation

extension DispatchQueue {
    func asyncAfter(_ timeInterval: Int, execute work: @escaping () -> Void) {
        self.asyncAfter(deadline: .now().advanced(by: .seconds(timeInterval)), execute: work)
    }
}
