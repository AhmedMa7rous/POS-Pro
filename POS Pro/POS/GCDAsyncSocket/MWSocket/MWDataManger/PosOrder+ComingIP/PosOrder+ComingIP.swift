//
//  PosOrder+ComingIP.swift
//  pos
//
//  Created by M-Wageh on 19/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation


extension pos_order_class {
     func updateOrder(fromIp dictionary:[String:Any]){
        sequence_number = dictionary["sequence_number"] as? Int ?? 0
        create_user_id = dictionary["create_user_id"] as? Int ?? 0
        write_user_id = dictionary["write_user_id"] as? Int ?? 0
        create_pos_id = dictionary["create_pos_id"] as? Int ?? 0
        write_pos_id = dictionary["write_pos_id"] as? Int ?? 0
        table_control_by_user_id = dictionary["table_control_by_user_id"] as? Int ?? 0
        table_control_by_user_name = dictionary["table_control_by_user_name"] as? String ?? ""
        write_user_name = dictionary["write_user_name"] as? String ?? ""
        write_pos_code = dictionary["write_pos_code"] as? String ?? ""
        table_name = dictionary["table_name"] as? String ?? ""
        table_id = dictionary["table_id"]  as? Int ?? 0
        floor_name = dictionary["floor_name"] as? String ?? ""
        total_items = dictionary["total_items"] as? Double ?? 0
        note = dictionary["note"] as? String ?? ""
        driver_id = dictionary["driver_id"] as? Int ?? 0
        driver_row_id = dictionary["driver_row_id"] as? Int ?? 0
        partner_id = dictionary["partner_id"] as? Int ?? 0
        partner_row_id = dictionary["partner_row_id"] as? Int ?? 0
         
         
         session_id_local = pos_session_class.getActiveSession()?.id
         write_date =  dictionary["write_date"] as? String ?? ""
         write_pos_name =  dictionary["write_pos_name"] as? String ?? ""
         delivery_type_id =  dictionary["delivery_type_id"] as? Int ?? 0
         amount_tax =  dictionary["amount_tax"] as? Double ?? 0
         amount_paid = dictionary["amount_paid"] as? Double ?? 0
         amount_total = dictionary["amount_total"] as? Double ?? 0
         amount_return = dictionary["amount_return"] as? Double ?? 0
         void_status = void_status_enum(rawValue:  dictionary["void_status"] as? Int ?? 0)
         is_closed = dictionary["is_closed"] as? Bool ?? false
         is_sync = dictionary["is_sync"] as? Bool ?? false
         promotion_code = dictionary["promotion_code"] as? String ?? ""
         bill_uid = dictionary["bill_uid"] as? String ?? ""
         guests_number = dictionary["guests_number"] as? Int 
         pickup_user_id = dictionary["pickup_user_id"] as? Int
         brand_id = dictionary["brand_id"] as? Int
         membership_sale_order_id = dictionary["membership_sale_order_id"] as? Int

         

    }
}
