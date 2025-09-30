//
//  promo_coupon_class.swift
//  pos
//
//  Created by Ahmed Mahrous on 09/09/2025.
//  Copyright © 2025 khaled. All rights reserved.
//

class promo_coupon_class: NSObject {
    var dbClass:database_class?
    var id: Int?
    var name, code: String?
    var active: Bool?
    var number_of_apply: Int?
    var type: String?
    var amount, max_amount, min_order_amount: Double?
    var expiry_date: String?
    var orders_count, remaining_coupons_number, coupon_category_id: Int?
    var customer_ids: [Int] = []
    var order_type_ids: [Int] = []
    var pos_config_ids: [Int] = []
    var tag_ids: [Int] = []
    var display_name, create_date, write_date: String?
    
    var order_uid:String?
    
    override init() {
        super.init()
    }
    
    init(fromDictionary dictionary: [String:Any], order:pos_order_class?) {
        super.init()
        id = dictionary["id"] as? Int ?? 0
        if let order = order {
            order_uid = order.uid
        } else {
            order_uid = dictionary["order_uid"] as? String ?? ""
        }
        name = dictionary["name"] as? String
        code = dictionary["code"] as? String
        active = dictionary["active"] as? Bool ?? false
        number_of_apply = dictionary["number_of_apply"] as? Int
        type = dictionary["type"] as? String
        amount = dictionary["amount"] as? Double
        min_order_amount = dictionary["min_order_amount"] as? Double
        expiry_date = dictionary["expiry_date"] as? String
        max_amount = dictionary["max_amount"] as? Double
        orders_count = dictionary["orders_count"] as? Int
        remaining_coupons_number = dictionary["remaining_coupons_number"] as? Int
        coupon_category_id = dictionary["coupon_category_id"] as? Int
        customer_ids = dictionary["number_of_apply"] as? [Int] ?? []
        order_type_ids = dictionary["number_of_apply"] as? [Int] ?? []
        pos_config_ids = dictionary["number_of_apply"] as? [Int] ?? []
        tag_ids = dictionary["number_of_apply"] as? [Int] ?? []
        display_name = dictionary["display_name"] as? String
        create_date = dictionary["create_date"] as? String
        write_date = dictionary["write_date"] as? String
        
        dbClass = database_class(table_name: "promo_coupon", dictionary: self.toDictionary(),id: id!,id_key:"id")
    }
    
    func toDictionary() -> [String:Any] {
        var dictionary:[String:Any] = [:]
        dictionary["id"] = id
        dictionary["order_uid"] = order_uid
        dictionary["name"] = name
        dictionary["code"] = code
        dictionary["active"] = active
        dictionary["number_of_apply"] = number_of_apply
        dictionary["type"] = type
        dictionary["amount"] = amount
        dictionary["min_order_amount"] = min_order_amount
        dictionary["expiry_date"] = expiry_date
        dictionary["max_amount"] = max_amount
        dictionary["orders_count"] = orders_count
        dictionary["remaining_coupons_number"] = remaining_coupons_number
        dictionary["coupon_category_id"] = coupon_category_id
        dictionary["customer_ids"] = customer_ids
        dictionary["order_type_ids"] = order_type_ids
        dictionary["pos_config_ids"] = pos_config_ids
        dictionary["tag_ids"] = tag_ids
        dictionary["display_name"] = display_name
        dictionary["create_date"] = create_date
        dictionary["write_date"] = write_date
        return dictionary
    }
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id!
        dbClass?.insertId = false
        _ =  dbClass!.save()
        
//        relations_database_class(re_id1: self.id!, re_id2: customer_ids, re_table1_table2: "promo_coupon|customer_ids").save()
//        relations_database_class(re_id1: self.id!, re_id2: order_type_ids, re_table1_table2: "promo_coupon|order_type_ids").save()
//        relations_database_class(re_id1: self.id!, re_id2: pos_config_ids, re_table1_table2: "promo_coupon|pos_config_ids").save()
//        relations_database_class(re_id1: self.id!, re_id2: tag_ids, re_table1_table2: "promo_coupon|tag_ids").save()
    }
    
    static func get(by uid:String)->promo_coupon_class?{
        var sql = """
        select *  from promo_coupon
        WHERE order_uid = '\(uid)'
"""
        print("UID ORDER: \(uid)")
        if let dicRow = database_class(connect: .database).get_row(sql:sql) {
            return promo_coupon_class(fromDictionary: dicRow, order: nil)
        }
        return nil
    }
}
