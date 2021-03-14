//
//  TesterAppApp.swift
//  TesterApp
//
//  Created by Liam Rosenfeld on 9/14/20.
//

import SwiftUI

@main
struct TesterAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Settings {
            OptionsView(window: NSWindow())
                .frame(width: 450, height: 600)
        }
    }
}
