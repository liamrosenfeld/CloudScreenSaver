//
//  ScreenPicker.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 5/16/21.
//

import SwiftUI

struct ScreenPicker: View {
    
    @Binding var selectedScreens: Set<Screen>
    
    @State private var connectedScreens = Set<Screen>()
    @State private var allScreens = Set<Screen>()
    @State private var disconnectedScreens = Set<Screen>()
    
    let displaySettingChange = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
    
    func getScreens() {
        let retrievedScreens = Set(NSScreen.screens.map { Screen(nsscreen: $0) })
        if retrievedScreens != connectedScreens {
            connectedScreens = Set(NSScreen.screens.map { Screen(nsscreen: $0) })
            disconnectedScreens = selectedScreens.subtracting(connectedScreens)
            allScreens = selectedScreens.union(connectedScreens)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Selected").font(.body.bold())
            ForEach(Array(selectedScreens)) { screen in
                HStack {
                    Button("-") {
                        selectedScreens.remove(screen)
                    }
                    Text(verbatim: "\(screen.name) (ID: \(screen.id))")
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
                    Text(verbatim: "\(screen.name) (ID: \(screen.id))")
                }
            }
            if allScreens.subtracting(selectedScreens).isEmpty {
                Text("No More Screens Available").padding(.top, 2)
            }
        }
        .onAppear(perform: getScreens)
        .onReceive(displaySettingChange, perform: { _ in getScreens() })
    }
}
