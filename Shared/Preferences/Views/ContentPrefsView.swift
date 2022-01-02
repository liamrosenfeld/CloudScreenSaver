//
//  ContentPrefsView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 1/1/22.
//

import SwiftUI

struct ContentPrefsView: View {
    @Binding var vidLoopCount: Int
    @Binding var imgDuration: Int
    
    var body: some View {
        Group {
            Text("Content").font(.system(size: 18))
                .padding(.top, 3)
            
            Group {
                NumberField(numberValue: $vidLoopCount, title: "Video Loop Count")
                Text("The number of times the same video will play in a row.")
                    .font(.footnote)
            }
            
            Group {
                NumberField(numberValue: $imgDuration, title: "Image Duration")
                Text("The amount of time that each individual image will show on screen (in seconds).")
                    .font(.footnote)
            }
        }
    }
}
