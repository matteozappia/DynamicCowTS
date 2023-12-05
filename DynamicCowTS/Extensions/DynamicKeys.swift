//
//  DynamicKeys.swift
//  DynamicCowTS
//
//  Created by zeph on 28/11/23.
//

import Foundation

enum DynamicKeys: String, CaseIterable{
    case isEnabled = "isEnabled"
    case currentSet = "currentSet"
    case originalDeviceSubType = "OriginalDeviceSubType"
    case isFirstLaunch = "isFirstLaunch"
}

extension UserDefaults {
    func resetAppState() {
        DynamicKeys.allCases.forEach { key in
            if key != .isFirstLaunch {
                removeObject(forKey: key.rawValue)
            }
        }
    }
}
