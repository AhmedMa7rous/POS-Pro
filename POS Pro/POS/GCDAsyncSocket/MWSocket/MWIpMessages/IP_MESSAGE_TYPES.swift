//
//  IP_MESSAGE_TYPES.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum IP_MESSAGE_TYPES:Int{
    case None = 0, 
         NEW_ORDER,
         ChANGED_ORDER,
         VOID_ORDER,
         PAYIED_ORDER,
         RETURNED_ORDER,
         RE_SEND,
         PENDING_ORDERS,
         RE_SEND_PENDING,
         REQUEST_SEQ,
         SEND_DEVICE_INFO,
         SCRAP_ORDER,
         SPLIT_ORDER,
        MOVE_ORDER
    
    static func workMessages()->[IP_MESSAGE_TYPES]{
        return [.NEW_ORDER,.ChANGED_ORDER,.VOID_ORDER,.PAYIED_ORDER,.RETURNED_ORDER,.RE_SEND]
    }
    static func appMessages()->[IP_MESSAGE_TYPES]{
        return [.PENDING_ORDERS,.RE_SEND_PENDING,.REQUEST_SEQ,.SEND_DEVICE_INFO]
    }
    
    func isAppMessages()->Bool {
        return IP_MESSAGE_TYPES.appMessages().contains(self)
    }
    
}

