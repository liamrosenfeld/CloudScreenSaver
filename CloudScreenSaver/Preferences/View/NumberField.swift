//
//  NumberField.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/13/21.
//

import SwiftUI

struct NumberField<Number: Numeric & Strideable>: View {
    
    @Binding var numberValue: Number
    @State var title: String
    
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
