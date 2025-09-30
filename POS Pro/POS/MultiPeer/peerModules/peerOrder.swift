//
//  oneOrderClass.swift
//  pos
//
//  Created by khaled on 8/21/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

 

struct peerOrder: Codable {
    
    var messageType:Int = 0

    var id:Int?
    var sequence_number:Int = 0
    
    // price
    var table_id:Int?
    var total_items:String?
    var amount_tax:String?
    var amount_paid:String?
    var amount_return:String?
    var amount_total:String?
    var delivery_amount:String?
    var setvice_charge_amount:String?
    var discount_amount:String?
    var tobaco_fees_amount:String?
    var customerName:String?
    var customerPhone:String?
    
    var closed:Bool = false
    var void:Bool = false


    // =============================
    var pos_order_lines:[peerOrderLine]  = []
    // =============================
    // loyalty
    
    var loyalty_earned_point:String?
    var loyalty_earned_amount:String?
    var loyalty_redeemed_point:String?
    var loyalty_redeemed_amount:String?

    var loyalty_points_remaining_partner:String?
    var loyalty_amount_remaining_partner:String?
 
     
       
    static func toClass(json:String) -> peerOrder?
     {
         do {
             let decoded = try JSONDecoder().decode(peerOrder.self, from: Data(json.utf8))
             return decoded
         } catch {
            SharedManager.shared.printLog("Failed to decode JSON")
         }
         
         return nil
     }
     
     func toJson() -> String?
     {
         do {
            let data = try JSONEncoder().encode(self)
            // Print the encoded JSON data
            if let jsonString = String(data: data, encoding: .utf8) {
               return jsonString
            }
         } catch _ {
            SharedManager.shared.printLog("Failed to encode JSON")
         }
         
         return nil
     }
    
}

 
