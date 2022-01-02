//
//  CacheActionsView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 1/1/22.
//

import SwiftUI

struct CacheActionsView: View {
    @State private var updating = false
    @State private var lastUpdate = Date()
    
    var body: some View {
        Group {
            Text("Actions").font(.title)
            
            Button("Update Now", action: updateNow).disabled(updating)
            Text("Last updated on \(lastUpdate, formatter: dateFormatter)")
                .font(.footnote)
            
            Button("Clear Cache", action: Cache.clearCache)
        }
        .onAppear {
            lastUpdate = Cache.getLastUpdate()
        }
    }
    
    func updateNow() {
        Task(priority: .medium) {
            updating = true
            await Networking.updateFromCloud()
            updating = false
            lastUpdate = Cache.getLastUpdate()
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy HH:mm:ss"
        return formatter
    }()
}
