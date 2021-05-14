//
//  PreferencesView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/9/21.
//

import SwiftUI

struct PreferencesView: View {
    @State var preferences = Preferences.retrieveFromFile()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Preferences").font(.title)
            
            Group {
                Text("Content").font(.headline)
                    .padding(.top, 3)
                
                Group {
                    NumberField(numberValue: $preferences.loopCount, title: "Video Loop Count")
                    Text("The number of times the same video will play in a row.")
                        .font(.footnote)
                }
                
                Group {
                    NumberField(numberValue: $preferences.imageDuration, title: "Image Duration")
                    Text("The amount of time that each individual image will show on screen (in seconds).")
                        .font(.footnote)
                }
            }
            
            Group {
                Text("Cloud").font(.headline)
                    .padding(.top, 3)
                
                HStack {
                    Text("S3 Bucket Name: ")
                    TextField("Bucket Name", text: $preferences.bucketName)
                    Text(".s3.amazonaws.com")
                }
                
                HStack {
                    Text("Update Frequency")
                    TimeIntervalPicker(interval: $preferences.updateFrequency)
                }
                Text("The cache will update on start after this time period has passed since last update.")
                    .font(.footnote)
            }
            
            Text("Remember to click enter to finish editing text fields before applying")
            Button("Apply", action: applyPrefs)
        }
    }
    
    func applyPrefs() {
        // save new preferences to preferences file
        let origPrefs = Preferences.retrieveFromFile()
        preferences.saveToFile()
        
        // if this is adding a bucket for the first time,
        // pull new files immediately
        if origPrefs.bucketName.isEmpty && !preferences.bucketName.isEmpty {
            Networking.updateFromCloud()
        }
    }
}
