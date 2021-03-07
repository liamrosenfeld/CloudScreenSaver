//
//  ContentView.swift
//  TesterApp
//
//  Created by Liam Rosenfeld on 9/14/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { reader in
                ScreenSaver(frame: NSRect(origin: .zero, size: reader.size))
            }
        }
    }
}

struct ScreenSaver: NSViewRepresentable {

    var frame: NSRect
    
    func makeNSView(context: Context) -> some NSView {
        let view = CloudScreenSaverView(frame: frame, isPreview: false)!
        view.startAnimation()
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) { }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
