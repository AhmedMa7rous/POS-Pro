//
//  loyalty_check.swift
//  pos
//
//  Created by khaled on 18/07/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class loyalty_check: NSObject {
    let con_sync = SharedManager.shared.conAPI()

  static  func apply_loyalty(_ order:pos_order_class) -> pos_order_class
    {
        if !SharedManager.shared.posConfig().enable_pos_loyalty {
            return order
        }
        
        if order.partner_id == nil
        {
            return order
        }
        if order.partner_id == 0
        {
            return order
        }
        
       
        let loyalty_setting = loyalty_config_settings_class.get();
        
        if loyalty_setting.points_based_on == "order"
        {
           
            
            
            if order.amount_total >= loyalty_setting.minimum_purchase
            {
                order.loyalty_earned_point = (order.amount_total * loyalty_setting.point_calculation) / 100
//                order.loyalty_earned_amount = (loyalty_setting.point_calculation / Double(loyalty_setting.points)) *  loyalty_setting.to_amount
                let points = Double(loyalty_setting.points)
                
                if points > 0 {
                order.loyalty_earned_amount = ( order.loyalty_earned_point * loyalty_setting.to_amount) / points
                }
            }
            
            let loyalty  = account_journal_class.get_loyalty_default()
            if loyalty != nil
            {
                let payment_loyalty = order.list_account_journal.first(where: {$0.id == loyalty!.id})
                if payment_loyalty != nil
                {
                    let amount = payment_loyalty!.tendered.toDouble() ?? 0
                    order.loyalty_redeemed_amount = amount
                    let toAmount = Double(loyalty_setting.to_amount)
                    if toAmount > 0 {
                    order.loyalty_redeemed_point = (Double(loyalty_setting.points) * amount) / toAmount
                    }
                }
            }

       

            
        }
    
    return order

        
     }
    
// func get_customer_loyalty(_ partner_id:Int) -> res_partner_class?
//    {
//            
//            var customer:res_partner_class?
// 
////                self.con_sync.timeout = 0
//                self.con_sync.userCash = .stopCash
//    
//    
//                let semaphore = DispatchSemaphore(value: 0)
//
//                self.con_sync.get_customer_by_id(id: partner_id) { (results) in
//                    let response = results.response
//
//                    let  result  = response!["result"] as? [[String:Any]]
//                    if result != nil
//                    {
//                        if result!.count > 0
//                        {
//                            let temp = result![0]
//                              customer = res_partner_class(fromDictionary: temp)
//        //                    customer.save()
//
//                        }
//                    }
//
//                    semaphore.signal()
//
//                }
//                semaphore.wait()
//                
//       
//        
//
//        return customer
//
//    }
    
    
}
