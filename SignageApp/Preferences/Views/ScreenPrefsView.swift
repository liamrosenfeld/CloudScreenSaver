//
//  ScreenPrefsPicker.swift
//  SignageApp
//
//  Created by Liam Rosenfeld on 1/1/22.
//

import SwiftUI
import Combine

struct ScreenPrefsView: View {
    @Binding var startFull: Bool
    @Binding var startingScreen: ScreenOption
            
    @State private var pickerSelection: ScreenPickerOption = .none
    @State private var selectedScreens: Set<Screen> = .init()
    
    var body: some View {
        Group {
            Text("Launching").font(.system(size: 18))
                .padding(.top, 3)
            
            Toggle("Start Fullscreen", isOn: $startFull)
            
            Picker("Stating Screen(s)", selection: $pickerSelection) {
                Text("Main").tag(ScreenPickerOption.main)
                Text("All").tag(ScreenPickerOption.all)
                Text("Custom").tag(ScreenPickerOption.custom)
            }
            
            if case .custom(_) = startingScreen {
                ScreenPicker(selectedScreens: $selectedScreens)
            }
        }
        .onAppear {
            // set local states to match starting screen
            pickerSelection = ScreenPickerOption.from(startingScreen)
            if case let .custom(screens) = startingScreen {
                selectedScreens = screens
            }
        }
        .onChange(of: pickerSelection) { option in
            switch option {
            case .main:
                startingScreen = .main
            case .all:
                startingScreen = .all
            case .custom:
                startingScreen = .custom(screens: selectedScreens)
            case .none:
                break
            }
        }
        .onChange(of: selectedScreens) { screens in
            if case .custom(_) = startingScreen {
                startingScreen = .custom(screens: screens)
            }
        }
    }
    
    private enum ScreenPickerOption: Hashable {
        case main
        case all
        case custom
        case none
        
        static func from(_ option: ScreenOption) -> Self {
            switch option {
            case .main:
                return .main
            case .all:
                return .all
            case .custom(_):
                return .custom
            }
        }
    }
}
