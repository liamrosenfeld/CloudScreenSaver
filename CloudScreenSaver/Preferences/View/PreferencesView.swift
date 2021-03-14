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
                    Text("Note: Not guaranteed to be contiguous if Video Player Duration is less time.")
                        .font(.footnote)
                }
                
                Group {
                    NumberField(numberValue: $preferences.imageDuration, title: "Image Duration")
                    Text("The amount of time that each individual image will show on screen.")
                        .font(.footnote)
                }
                
                Group {
                    NumberField(numberValue: $preferences.videoPlayerDuration, title: "Video Player Duration")
                    NumberField(numberValue: $preferences.imagePlayerDuration, title: "Image Player Duration")
                    Text("Player duration is the minimum contiguous time that a type of content will play.")
                        .font(.footnote)
                    Text("Note: When playing, it will never cut off content (will increase to fit).")
                        .font(.footnote)
                }
               
                Text("All durations are in seconds.")
                    .font(.footnote)
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
            }
            
            Text("Remember to click enter to finish editing text fields before applying")
                .font(.footnote)
            Button("Apply", action: preferences.saveToFile)
        }
    }
}
