//
//  ActionsView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/13/21.
//

import SwiftUI

struct ActionsView: View {
    @State private var updating = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Actions").font(.title)
            
            Button("Update Now", action: {
                Task(priority: .medium) {
                    updating = true
                    await Networking.updateFromCloud()
                    updating = false
                }
            }).disabled(updating)
            
            Button("Clear Cache", action: Cache.clearCache)
        }
    }
}
