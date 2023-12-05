//
//  DynamicCowTSApp.swift
//  DynamicCowTS
//
//  Created by zeph on 28/11/23.
//

import SwiftUI

@main
struct DynamicCowTSApp: App {
    
    @AppStorage(DynamicKeys.isFirstLaunch.rawValue) private var isFirstLaunch: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onAppear {
                    if isFirstLaunch {
                        DynamicBackup.performDynamicBackup()
                        isFirstLaunch = false
                    }
                }
        }
    }
}
