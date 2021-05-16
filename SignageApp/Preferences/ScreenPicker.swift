//
//  ScreenPicker.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/16/21.
//

import SwiftUI

struct ScreenPicker: View {
    
    @Binding var selectedScreens: Set<Screen>
    
    var allScreens: Set<Screen>
    var disconnectedScreens: Set<Screen>
    
    init(_ selectedScreens: Binding<Set<Screen>>) {
        _selectedScreens = selectedScreens
        
        let connectedScreens = Set(NSScreen.screens.map { Screen(nsscreen: $0) })
        
        self.disconnectedScreens = selectedScreens.wrappedValue.subtracting(connectedScreens)
        self.allScreens = selectedScreens.wrappedValue.union(connectedScreens)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Selected").font(.body.bold())
            ForEach(Array(selectedScreens)) { screen in
                HStack {
                    Button("-") {
                        selectedScreens.remove(screen)
                    }
                    Text("\(screen.name) - \(screen.id)")
                    if disconnectedScreens.contains(screen) {
                        Text("(Disconnected)")
                    }
                }
            }
            if selectedScreens.isEmpty {
                Text("No Screens Selected").padding([.top, .bottom], 2)
            }
            
            Text("Available").font(.body.bold())
            ForEach(Array(allScreens.subtracting(selectedScreens))) { screen in
                HStack {
                    Button("+") {
                        selectedScreens.insert(screen)
                    }
                    Text("\(screen.name) - \(screen.id)")
                }
            }
            if allScreens.subtracting(selectedScreens).isEmpty {
                Text("No More Screens Available").padding(.top, 2)
            }
        }
        
    }
}
