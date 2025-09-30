//
//  kds_order_class.swift
//  pos
//
//  Created by Khaled on 5/20/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

enum kds_order_stauts {
    case new,changed,delayed
}
class kds_order_class: NSObject {
    
    static func get_kds_order_status(order:pos_order_class) -> kds_order_stauts
    {
 
         if !(order.write_date ?? "").isEmpty
        {
                let time_delayed = 10 * 60 // 10 mintues
                   var def_date = baseClass.compareTwoDate(order.create_date!, dt2_new: order.write_date!, formate: baseClass.date_formate_database)
                   
                   
                   
                 
                   if def_date > 0 && def_date < time_delayed
                   {
                       return kds_order_stauts.changed
                       
                   }
                   else if def_date > time_delayed
                   {
                       return kds_order_stauts.delayed
                   }
                    
        }
      
          return kds_order_stauts.new
        
    }
}
