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
            Text("Preferences").font(.title2)
            
            Group {
                Text("Content").font(.title3)
                    .padding(.top, 3)
                
                NumberField(numberValue: $preferences.loopCount, title: "Video Loop Count")
                NumberField(numberValue: $preferences.imageDuration, title: "Image Duration (Sec)")
                NumberField(numberValue: $preferences.switchFrequency, title: "Video/Image Switch Frequency (Sec)")
            }
            
            Group {
                Text("Cloud").font(.title3)
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
            
            Button("Apply", action: preferences.saveToFile)
        }
    }
}
