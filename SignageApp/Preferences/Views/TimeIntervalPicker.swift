//
//  TimeIntervalPicker.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/13/21.
//

import SwiftUI

struct TimeIntervalPicker: View {
    @Binding var interval: TimeInterval
    
    var body: some View {
        Picker("Update Frequency", selection: $interval) {
            Text("Launch Only")
                .tag(0.0)
            Text("Hourly")
                .tag(3600.0)
            Text("Twice Daily")
                .tag(43200.0)
            Text("Daily")
                .tag(86400.0)
            Text("Twice Weekly")
                .tag(302400.0)
            Text("Weekly")
                .tag(604800.0)
        }.labelsHidden()
    }
}
