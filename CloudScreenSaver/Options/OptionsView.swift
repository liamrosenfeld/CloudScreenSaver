//
//  OptionsView.swift
//  CloudScreenSaver
//
//  Created by Liam Rosenfeld on 3/13/21.
//

import SwiftUI

struct OptionsView: View {
    var window: NSWindow
    
    var body: some View {
        VStack {
            PreferencesView()
                .padding(.top, 1)
            
            Divider()
                .padding(.vertical, 4)
            
            ActionsView()
                .padding(.top, 1)
            
            Divider()
            
            Button("Close", action: close)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func close() {
        window.sheetParent?.endSheet(window)
    }
    
}
