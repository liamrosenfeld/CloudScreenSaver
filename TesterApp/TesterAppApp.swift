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
            PreferencesView(window: NSWindow())
                .frame(width: 350, height: 500)
        }
    }
}
