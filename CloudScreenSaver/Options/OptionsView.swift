//
//  OptionsView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/13/21.
//

import SwiftUI

struct OptionsView: View {
    var window: NSWindow
    
    @State var prefs = Preferences.retrieveFromFile()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                VStack {
                    Text("Preferences").font(.title)
                }
                Spacer()
            }.padding(.top, 3)
            
            ContentPrefsView(vidLoopCount: $prefs.loopCount, imgDuration: $prefs.imageDuration)
            
            CloudPrefsView(bucketName: $prefs.bucketName, updateFreq: $prefs.updateFrequency)
            Text("The cache will update when the screen saver starts if it has been longer than this time interval.")
                .font(.footnote)
            
            HStack {
                Spacer()
                VStack {
                    Text("Remember to click enter to finish editing text fields before applying")
                    Button("Apply", action: prefs.saveToFile)
                }
                Spacer()
            }.padding(.top)
            
            Divider()
                .padding(.vertical, 4)
            
            CacheActionsView()
            
            Divider()
            
            HStack {
                Spacer()
                Button("Close", action: close)
                Spacer()
            }.padding(.vertical)
        }.padding()
    }
    
    private func close() {
        window.sheetParent?.endSheet(window)
    }
    
}
