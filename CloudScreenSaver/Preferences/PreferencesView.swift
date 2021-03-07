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
    @State var loopText: String
    
    init(window: NSWindow) {
        let prefs = Preferences.retrieveFromFile()
        self._preferences = State(initialValue: prefs)
        self.window = window
        self._loopText = State(initialValue: "\(prefs.loopCount)")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Preferences").font(.title2)
                
                Group {
                    Text("Content").font(.title3)
                        .padding(.top, 3)
                    
                    Text("Video Loop Count")
                    HStack {
                        TextField("Video Loop Count", text: $loopText)
                            .labelsHidden()
                        Stepper("Video Loop Count", value: $preferences.loopCount, in: 1...100)
                            .labelsHidden()
                    }.frame(maxWidth: 200)
                }
                
                Group {
                    Text("Cloud").font(.title3)
                        .padding(.top, 3)
                    
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
                    }.labelsHidden()
                }
                
                Button("Apply", action: preferences.saveToFile)
            }.padding(.top, 1)
            
            Divider()
                .padding(.vertical, 4)
            
            Group {
                Text("Actions").font(.title2)
                
                Button("Update Now", action: Networking.updateFromCloud)
                
                Button("Clear Cache", action: Cache.clearCache)
                
            }.padding(.top, 1)
            
            Divider()
            
            Button("Close", action: close)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: preferences.loopCount) { value in
            loopText = "\(value)"
        }
        .onChange(of: loopText) { value in
            guard let num = Int(value), num > 0 else {
                loopText = "\(preferences.loopCount)"
                return
            }
            preferences.loopCount = num
        }
    }
    
    private func close() {
        window.sheetParent?.endSheet(window)
    }
}
