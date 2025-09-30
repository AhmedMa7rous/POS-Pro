//
//  PALocalNetworkPermissionsCheck.swift
//  pos
//
//  Created by Muhammed Elsayed on 14/02/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
import Reachability
class PALocalNetworkPermissionsCheck: PAPermissionsCheck {
    let reachability = try! Reachability()
    override func checkStatus() {
        if isReachableToLocalNetwork() {
            self.status = .enabled
        } else {
            self.status = .disabled
        }
        self.updateStatus()
    }
    
    override func defaultAction() {
        self.openSettings()
    }
    //MARK: This function will return true if your device is connected to a network (WiFi or cellular), but it doesn't verify if there's actual internet access through that network.
    private func isReachableToLocalNetwork() -> Bool {
        return reachability.connection != .unavailable
    }
}
