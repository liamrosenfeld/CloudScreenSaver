//
//  NumberField.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/13/21.
//

import SwiftUI

struct NumberField: View {
    
    @Binding private var numberValue: Int
    @State private var title: String
    
    init(_ number: Binding<Int>, title: String) {
        self._numberValue = number
        self.title = title
    }
    
    var body: some View {
        HStack {
            Text("\(title): ")
            TextField(title, value: $numberValue, formatter: NumberFormatter())
                .labelsHidden()
                .frame(maxWidth: 75)
            Stepper("\(title)", value: $numberValue)
                .labelsHidden()
        }
    }
}
