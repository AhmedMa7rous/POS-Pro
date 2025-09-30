//
//  conditions.swift
//  pos
//
//  Created by khaled on 03/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class conditions: NSObject {

    
   static func is_order_type_enabled() -> Bool
    {
        let enable_delivery = SharedManager.shared.posConfig().enable_delivery
        if enable_delivery == true
        {
            let order_type_enabled = SharedManager.shared.appSetting().enable_OrderType == .disable ? false : true

            return order_type_enabled
        }
        
        return enable_delivery
      
    }
    
    
}
