//
//  PreferencesView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/9/21.
//

import SwiftUI

struct PreferencesView: View {
    var window: NSWindow
    
    @State var preferences: Preferences
    
    init(window: NSWindow) {
        self._preferences = State(initialValue: Preferences.retrieveFromFile())
        self.window = window
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Preferences").font(.title2)
                
                Text("S3 Bucket Name")
                HStack {
                    TextField("Bucket Name", text: $preferences.bucketName)
                    Text(".s3.amazonaws.com")
                }
                
                Text("Update Frequency")
                Picker("Update Frequency", selection: $preferences.updateFrequency) {
                    Text("Every Time")
                        .tag(0.0)
                    Text("Hourly")
                        .tag(3600.0)
                    Text("Twice Daily")
                        .tag(43200.0)
                    Text("Daily")
                        .tag(86400.0)
                    Text("Twice Weekly")
                        .tag(302400.0)
                    Text("Weekly")
                        .tag(604800.0)
                }
                
                Button("Apply", action: preferences.saveToFile)
            }
            
            Divider()
            
            Group {
                Text("Actions").font(.title2)
                
                Button("Update Now", action: Cache.updateFromCloud)
                
                Button("Clear Cache", action: Cache.clearCache)
                
            }
            
            Divider()
            
            Button("Close", action: close)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func close() {
        window.sheetParent?.endSheet(window)
    }
}
