//
//  VersionManager.swift
//  pos
//
//  Created by Mahmoud wageh on 18/09/2025.
//  Copyright © 2025 khaled. All rights reserved.
//

import UIKit

class VersionManager {
    private let lastVersionKey = "version"
    
    func checkForUpdate() -> Bool {
        // Get current version from Info.plist
        print(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0")
        let currentVersion = Bundle.main.fullVersion
        print(currentVersion)
        // Get saved version from UserDefaults
        let savedVersion = cash_data_class.get(key: lastVersionKey)
        // Save current version for next launch
        setVersion()
        // If no saved version, it’s first launch → not considered update
        guard let savedVersion = savedVersion else {
            return false
        }
        
        // If versions differ → app was updated
        return savedVersion != currentVersion
    }
    
    func setVersion(){
        let version = Bundle.main.fullVersion

        cash_data_class.set(key: lastVersionKey, value: version)
        
        let date = Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: true)

        cash_data_class.set(key: version , value: date)
    }
}
