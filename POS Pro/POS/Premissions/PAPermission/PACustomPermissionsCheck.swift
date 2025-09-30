//
//  PACustomPermissionsCheck.swift
//  pos
//
//  Created by M-Wageh on 17/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import UIKit

class PACustomPermissionsCheck: PAPermissionsCheck {

    override init() {
        super.init()
        self.status = .disabled
        self.canBeDisabled = true
    }
    
    open override func checkStatus() {
        self.updateStatus()
    }
    
    open override func defaultAction() {
        if self.status == .enabled {
            self.status = .disabled
        }else{
            self.status = .enabled
        }
        self.updateStatus()
    }
}
