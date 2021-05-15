//
//  Set+Diff.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/14/21.
//

import Foundation

extension Set where Element: Equatable {
    func diff(old: Self) -> (added: Self, removed: Self) {
        let difference = self.symmetricDifference(old)
        let added = difference.intersection(self)
        let removed = difference.intersection(old)
        return (added, removed)
    }
}
