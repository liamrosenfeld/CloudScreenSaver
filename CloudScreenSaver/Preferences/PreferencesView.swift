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
