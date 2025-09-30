//
//  pos_product_void.swift
//  pos
//
//  Created by M-Wageh on 21/04/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class pos_product_void{
    var pos_config_id:Int?
    var user_id:Int?
    var pos_session_id: Int?
    var product_id: Int?
    var date:String?
    var quantity:Double?
    var total_price:Double?
    var unit_price:Double?
    var void_type:String?
    var order_udid:String?
    var order_id:Int?
    var return_reason:String?

    init(from session:pos_session_class,line:pos_order_line_class){
        var qty = 1.0
        if line.last_qty > 0 {
            qty = line.last_qty
        }else{
            if line.qty > 0 {
                qty = line.qty
            }
        }
        
        pos_config_id = session.posID
        pos_session_id = session.server_session_id
        product_id = line.product_id
        date = (line.write_date?.isEmpty ?? true) ? line.create_date : line.write_date
        quantity = qty
        total_price = line.price_subtotal_incl
        unit_price = line.price_unit
        void_type = line.void_status == .after_sent_to_kitchen ? "after" : "before"
        user_id = line.write_user_id
        order_id = line.order_id
        return_reason = line.return_reason

    }
    func toDictionary()->[String:Any?]{
        self.setOrderUdid()
        return [
            "user_id": SharedManager.shared.getCashDomainUserId(),
            "pos_config_id": pos_config_id ,
            "pos_session_id": pos_session_id ,
            "product_id": product_id ,
            "date":date,
            "quantity":quantity,
            "total_price":total_price,
            "unit_price":unit_price,
            "void_type":void_type,
            "pos_user_id":user_id,
            "order_udid":order_udid,
            "return_reason":return_reason
        ]
    }
    func setOrderUdid(){
        if let result = database_class(connect: .database).get_row(sql: " select uid from pos_order where id = \(order_id ?? 0) ") {
            if let uid = result["uid"] as? String {
                self.order_udid = uid
            }
        }
    }
    
}
