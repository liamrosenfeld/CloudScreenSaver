//
//  CloudPrefsView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 1/1/22.
//

import SwiftUI

struct CloudPrefsView: View {
    @Binding var bucketName: String
    @Binding var updateFreq: TimeInterval
    
    var body: some View {
        Group {
            Text("Cloud").font(.system(size: 18))
                .padding(.top, 3)
            
            HStack {
                Text("S3 Bucket Name: ")
                TextField("Bucket Name", text: $bucketName)
                Text(".s3.amazonaws.com")
            }
            
            HStack {
                Text("Update Frequency")
                TimeIntervalPicker(interval: $updateFreq)
            }
        }
    }
}
