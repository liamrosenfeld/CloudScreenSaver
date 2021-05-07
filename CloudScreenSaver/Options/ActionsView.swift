//
//  ActionsView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/13/21.
//

import SwiftUI

struct ActionsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Actions").font(.title)
            
            Button("Update Now", action: Networking.updateFromCloud)
            
            Button("Clear Cache", action: Cache.clearCache)
        }
    }
}
