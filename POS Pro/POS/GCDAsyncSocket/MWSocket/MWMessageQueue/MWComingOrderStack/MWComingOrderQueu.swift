//
//  MWComingOrderQueu.swift
//  pos
//
//  Created by M-Wageh on 20/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MWComingOrderQueu{
    var comingOrder:pos_order_class?{
        get {
           return getComingOrder()
        }
    }
    let comingOrderUID:String
    let excludIP:String
    let ipMessage:IP_MESSAGE_TYPES
    let return_lines_uid:String

    init(comingOrderUID:String,excludIP:String,ipMessage:IP_MESSAGE_TYPES,return_lines_uids:[String] = []) {
        self.ipMessage = ipMessage
        self.comingOrderUID = comingOrderUID
        self.excludIP = excludIP
        self.return_lines_uid = return_lines_uids.count > 0 ? return_lines_uids.joined(separator: ",") : ""
    }
    func isFromSubCashier()->Bool{
        if let type  = socket_device_class.getDevice(by: self.excludIP)?.type, type == .SUB_CASHER{
            return true
        }
        return false
    }
    func getComingOrder() -> pos_order_class? {
         return pos_order_helper_class.getOrders_status_sorted(options: getOrderOption()).first
    }
    func getOrderOption()->ordersListOpetions{
        let opetions = ordersListOpetions()
        opetions.uid = comingOrderUID
        opetions.get_lines_void = true
//        opetions.void = false
        opetions.parent_product = true
        opetions.orderDesc = false
        return opetions
    }

}
