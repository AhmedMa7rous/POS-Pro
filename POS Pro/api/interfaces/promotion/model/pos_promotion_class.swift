//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

 
class pos_promotion_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0 // id on server
 
    var display_name : String = ""
    var promotion_code : String = ""
    var promotion_type : String = ""
    var from_date : String = ""
    var to_date : String = ""
    var from_time : String = ""
    var to_time : String = ""
    var _operator : String = ""

    
    
    var sequence : Int = 0
 
    var total_amount: Double = 0
    var total_discount : Double = 0
    var max_discount : Double = 1000000000

    var active : Bool = false
    var discount_product_id : Int = 0
    var product_id_amt : Int = 0
    var product_id_qty : Int = 0
 
    
    var day_of_week_ids : [Int] = []
    var parent_product_ids : [Int] = []
    var apply_on_pos : [Int] = []
    var apply_on_order_types : [Int] = []

    var no_of_applied_times:Int  = 1000
    
    var promotionType:promotion_types?
    
    var required_code :  Bool = false
    var filter_code : String = ""

    
    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
  
        no_of_applied_times  = dictionary["no_of_applied_times"] as? Int ?? 0

        display_name = dictionary["display_name"] as? String ?? ""
        _operator = dictionary["operator"] as? String ?? ""
        promotion_code = dictionary["promotion_code"] as? String ?? ""
        promotion_type = dictionary["promotion_type"] as?  String ?? ""
        from_date = dictionary["from_date"] as?  String ?? ""
        to_date = dictionary["to_date"] as?  String ?? ""
        from_time = dictionary["from_time"] as?  String ?? ""
        to_time = dictionary["to_time"] as?  String ?? ""
 
    
        sequence = dictionary["sequence"] as? Int ?? 0
 
        total_amount = dictionary["total_amount"] as? Double ?? 0
        total_discount = dictionary["total_discount"] as? Double ?? 0
        max_discount = dictionary["max_discount"] as? Double ?? 1000000000
        active = dictionary["active"] as? Bool ?? false
        
        
        day_of_week_ids = dictionary["day_of_week_ids"] as? [Int] ?? []
        parent_product_ids = dictionary["parent_product_ids"] as? [Int] ?? []
        apply_on_pos = dictionary["apply_on_pos"] as? [Int] ?? []
        apply_on_order_types = dictionary["apply_on_order_types"] as? [Int] ?? []

         promotionType = promotion_types.init(rawValue: promotion_type)

         discount_product_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "discount_product", keyOfDatabase: "discount_product_id",Index: 0) as? Int ?? 0
        product_id_amt = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_id_amt", keyOfDatabase: "product_id_amt",Index: 0) as? Int ?? 0
        product_id_qty = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_id_qty", keyOfDatabase: "product_id_qty",Index: 0) as? Int ?? 0

        required_code = dictionary["required_code"] as? Bool ?? false
        filter_code = dictionary["filter_code"] as? String ?? ""

        dbClass = database_class(table_name: "pos_promotion", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
             dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["operator"] = _operator
        dictionary["promotion_code"] = promotion_code
        dictionary["promotion_type"] = promotion_type
   
        dictionary["from_date"] = from_date
        dictionary["to_date"] = to_date
        dictionary["from_time"] = from_time
        dictionary["to_time"] = to_time

        dictionary["sequence"] = sequence
        dictionary["total_amount"] = total_amount
        dictionary["total_discount"] = total_discount
        dictionary["active"] = active
        dictionary["discount_product_id"] = discount_product_id
        dictionary["product_id_amt"] = product_id_amt
        dictionary["apply_on_pos"] = apply_on_pos
        dictionary["apply_on_order_types"] = apply_on_order_types
        dictionary["product_id_qty"] = product_id_qty
        dictionary["no_of_applied_times"] = no_of_applied_times

        
        dictionary["required_code"] = required_code
        dictionary["filter_code"] = filter_code
        dictionary["max_discount"] = max_discount

        return baseClass.fillterProperties(dictionary: dictionary, excludeProperties: ["day_of_week_ids","parent_product_ids"])
    }
    
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        dbClass?.insertId = true
        
        relations_database_class(re_id1: self.id, re_id2: day_of_week_ids, re_table1_table2: "pos_promotion|day_of_week_ids").save()
        relations_database_class(re_id1: self.id, re_id2: parent_product_ids, re_table1_table2: "pos_promotion|parent_product_ids").save()
        relations_database_class(re_id1: self.id, re_id2: apply_on_pos, re_table1_table2: "pos_promotion|apply_on_pos").save()
        relations_database_class(re_id1: self.id, re_id2: apply_on_order_types, re_table1_table2: "pos_promotion|apply_on_order_types").save()

        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        _ =  dbClass!.save()
        
    }
    
    
    func get_day_of_week_ids() ->[Int]
    {
          return  dbClass?.get_relations_rows(re_id1:  id, re_table1_table2: "pos_promotion|day_of_week_ids") ?? []
    }
    
    func get_parent_product_ids() ->[Int]
    {
             return  dbClass?.get_relations_rows(re_id1:  id, re_table1_table2: "pos_promotion|parent_product_ids") ?? []
     }
    func get_apply_on_pos_ids() ->[Int]
    {
             return  dbClass?.get_relations_rows(re_id1:  id, re_table1_table2: "pos_promotion|apply_on_pos") ?? []
     }
    func get_apply_on_order_types_ids() ->[Int]
    {
             return  dbClass?.get_relations_rows(re_id1:  id, re_table1_table2: "pos_promotion|apply_on_order_types") ?? []
     }
    static func reset(temp:Bool = false)
    {
        let cls = pos_promotion_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_promotion|day_of_week_ids' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_promotion|parent_product_ids' ")

        
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = pos_promotion_class(fromDictionary: item)
            pos.dbClass?.insertId = false
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = pos_promotion_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func get(id:Int)-> pos_promotion_class?
    {
         
            
            let cls = pos_promotion_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(id))
            if row !=  nil
            {
                let temp:pos_promotion_class = pos_promotion_class(fromDictionary: row!  )
                return temp
            }
        
        return nil
    }
    
    static func get(promotion_type:String,filter_code:String?,orderType:Int)-> pos_promotion_class?
    {
        let filterCode = filter_code != nil ? " and filter_code ='\(filter_code!)'" : " and filter_code = '' "
            

            let cls = pos_promotion_class(fromDictionary: [:])
//            let row  = cls.dbClass!.get_row(whereSql: " where   promotion_type = '" + promotion_type + "' \(filterCode)")
        let row  = cls.dbClass!.get_row(sql:"""
                                SELECT pos_promotion.* from pos_promotion inner join relations
                                on pos_promotion.id  = relations.re_id1
                                WHERE re_table1_table2 ="pos_promotion|apply_on_order_types"
                                and relations.re_id2 = \(orderType)
                                and  promotion_type = '\(promotion_type)' \(filterCode)
        """)

            if row !=  nil
            {
                let temp:pos_promotion_class = pos_promotion_class(fromDictionary: row!  )
                return temp
            }
        
        return nil
    }
    
     
    static func get(sql:String)-> pos_promotion_class?
    {
         
            
            let cls = pos_promotion_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(sql: sql)
            if row !=  nil
            {
                let temp:pos_promotion_class = pos_promotion_class(fromDictionary: row!  )
                return temp
            }
        
        return nil
    }
    
}
