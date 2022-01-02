//
//  PreferencesView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 2/9/21.
//

import SwiftUI

struct PreferencesView: View {
    @State var prefs: Preferences = Preferences.retrieveFromFile()
    
    var body: some View {
        VStack(alignment: .leading) {
            ContentPrefsView(vidLoopCount: $prefs.loopCount, imgDuration: $prefs.imageDuration)
            CloudPrefsView(bucketName: $prefs.bucketName, updateFreq: $prefs.updateFrequency)
            ScreenPrefsView(startFull: $prefs.startFullscreen, startingScreen: $prefs.startingScreen)
            HStack {
                Spacer()
                VStack {
                    Text("Remember to click enter to finish editing text fields before applying")
                    Button("Apply", action: applyPrefs)
                }
                Spacer()
            }.padding(.top)
            Divider()
            CacheActionsView()
        }
    }
    
    func applyPrefs() {
        // save new preferences to preferences file
        let origPrefs = Preferences.retrieveFromFile()
        prefs.saveToFile()
        
        // if this is adding a bucket for the first time,
        // pull new files immediately
        if origPrefs.bucketName.isEmpty && !prefs.bucketName.isEmpty {
            Task(priority: .medium) {
                await Networking.updateFromCloud()
            }
        }
    }
}
