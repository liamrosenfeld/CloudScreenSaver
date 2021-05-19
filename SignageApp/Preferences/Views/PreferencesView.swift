//
//  PreferencesView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/9/21.
//

import SwiftUI

struct PreferencesView: View {
    @State var preferences: Preferences
    @State var selectedScreens: Set<Screen>
    
    init() {
        let retrievedPrefs = Preferences.retrieveFromFile()
        self._preferences = State(initialValue: retrievedPrefs)
        switch retrievedPrefs.startingScreen {
        case .custom(let screens):
            self._selectedScreens = State(initialValue: screens)
        default:
            self._selectedScreens = State(initialValue: Set())
        }
        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Content").font(.system(size: 18))
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
            
            Spacer()
            
            Group {
                Text("Cloud").font(.system(size: 18))
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
            
            Spacer()
            
            Group {
                Text("Launching").font(.system(size: 18))
                    .padding(.top, 3)
                
                Toggle("Start Fullscreen", isOn: $preferences.startFullscreen)
                
                Picker("Stating Screen(s)", selection: $preferences.startingScreen) {
                    Text("Main").tag(ScreenOption.main)
                    Text("All").tag(ScreenOption.all)
                    Text("Custom").tag(ScreenOption.custom(screens: Set()))
                }
                
                if case .custom(_) = preferences.startingScreen {
                    ScreenPicker(selectedScreens: $selectedScreens)
                }
            }
            
            Spacer()
            
            Group {
                Text("Remember to click enter to finish editing text fields before applying")
                Button("Apply", action: applyPrefs)
            }
        }
    }
    
    func applyPrefs() {
        // apply selected screens
        if case .custom(_) = preferences.startingScreen {
            preferences.startingScreen = .custom(screens: selectedScreens)
        }
        
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
