//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class delivery_type_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var name : String = ""
    var display_name : String = ""
    var pricelist_id :  Int = 0
    var pricelist_name :  String = ""
    
    var sequence : Int = 0
    var require_info : Bool = false
    
    var category_id :  Int = 0
//    var extra_product_id :  Int = 0

    var required_driver: Bool = false
    
    var show_customer_info: Bool = false

    private var journal_ids_store : [Int] = []
    var journal_ids : [Int]
    {
        get {
            return get_journal_ids()
        }
        set(new)
        {
            journal_ids_store = new
        }
    }
    
    var order_type : String = ""
    var delivery_product_id : Int = 0
    var delivery_amount : Double = 0.0
    var __last_update : String = ""
    
    var required_table: Bool = false
    var deleted : Bool = false
    var require_customer: Bool = false
    var default_customer_id : Int = 0

    var tip_product_id : Int = 0
    var service_product_id : Int = 0
    var service_charge : Double?
    
    var required_guest_number: Bool = false
    
    // not used in database
//    var delivery_product  : pos_order_line_class?
    
    
    
    
    
    override init() {
        
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        sequence = dictionary["sequence"] as? Int ?? 0
 
         
        require_info = dictionary["require_info"] as? Bool ?? false

        required_driver = dictionary["required_driver"] as? Bool ?? false
        show_customer_info = dictionary["show_customer_info"] as? Bool ?? false
        require_customer = dictionary["require_customer"] as? Bool ?? false
        name = dictionary["name"] as? String ?? ""
        display_name = dictionary["display_name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        
        journal_ids = dictionary["journal_ids"]  as? [Int] ?? []
        
        service_charge = dictionary["service_charge"] as? Double

        category_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "category_id", keyOfDatabase: "category_id",Index: 0) as? Int ?? 0

//        pricelist_id = (dictionary["pricelist_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        pricelist_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pricelist_id", keyOfDatabase: "pricelist_id",Index: 0) as? Int ?? 0
        pricelist_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pricelist_id", keyOfDatabase: "pricelist_name",Index: 1)as? String  ?? ""
//        extra_product_id  = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "extra_product_id", keyOfDatabase: "extra_product_id",Index: 0) as? Int ?? 0
        
        order_type = dictionary["order_type"]  as? String ?? ""
//        delivery_product_id =  (dictionary["delivery_product_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
      delivery_product_id =   baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "delivery_product_id", keyOfDatabase: "delivery_product_id",Index: 0) as? Int ?? 0
        
        delivery_amount = dictionary["delivery_amount"]  as?  Double ?? 0.0
        required_table = dictionary["required_table"] as? Bool ?? false
        
        //        let delivery_product_dic = dictionary["delivery_product"]  as?  [String:Any]
        //        if delivery_product_dic != nil
        //        {
        //            delivery_product = productClass(fromDictionary: delivery_product_dic!)
        //        }
        default_customer_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "default_customer", keyOfDatabase: "default_customer_id",Index: 0) as? Int ?? 0

        tip_product_id =   baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "tip_product_id", keyOfDatabase: "tip_product_id",Index: 0) as? Int ?? 0
        service_product_id =   baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "service_product_id", keyOfDatabase: "service_product_id",Index: 0) as? Int ?? 0
        required_guest_number = dictionary["required_guest_number"] as? Bool ?? false
        dbClass = database_class(table_name: "delivery_type", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    
    func toDictionary() -> [String:Any]
    {
     var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["display_name"] = display_name
        dictionary["pricelist_id"] = pricelist_id
        dictionary["pricelist_name"] = pricelist_name
        
        dictionary["journal_ids"] = journal_ids
        
        dictionary["order_type"] = order_type
        dictionary["delivery_product_id"] = delivery_product_id
        dictionary["delivery_amount"] = delivery_amount
        dictionary["__last_update"] = __last_update
        dictionary["sequence"] = sequence
        dictionary["require_info"] = require_info
        dictionary["category_id"] = category_id
 
        dictionary["required_driver"] = required_driver
        dictionary["show_customer_info"] = show_customer_info
        dictionary["required_table"] = required_table
        dictionary["deleted"] = deleted
        dictionary["require_customer"] = require_customer
        dictionary["default_customer_id"] = default_customer_id
        dictionary["tip_product_id"] = tip_product_id
        dictionary["service_product_id"] = service_product_id
        dictionary["service_charge"] = service_charge
        dictionary["required_guest_number"] = required_guest_number
//        dictionary["extra_product_id"] = extra_product_id
 

        
        //        if delivery_product != nil
        //        {
        //            dictionary["delivery_product"] = delivery_product?.toDictionary()
        //
        //        }
        
        
        return dictionary
    }
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        _ =  dbClass!.save()
        
        
        
        relations_database_class(re_id1: self.id, re_id2: journal_ids_store, re_table1_table2: "delivery_type|account_journal").save()
        
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = delivery_type_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")
         relations_database_class.reset(  re_table1_table2: "delivery_type|account_journal")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
//
//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='delivery_type|account_journal' ")
 
        
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = delivery_type_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll(category_id:Int? = nil) ->  [[String:Any]] {
        
        let cls = delivery_type_class(fromDictionary: [:])
        if category_id == nil
        {
            let arr  = cls.dbClass!.get_rows(whereSql: " order by sequence")
            return arr
        }
        else
        {
            let arr  = cls.dbClass!.get_rows(whereSql: " where category_id = \(category_id!) order by sequence")
            return arr
        }

        
    }
    
    static func getAll(category_id:Int? = nil) -> [delivery_type_class] {
        //        let className:String = "get_product_pricelist"
        let  pos = SharedManager.shared.posConfig()
        let delivery_method_ids = pos.delivery_method_ids
        
        
         
        let arr:[[String:Any]] = delivery_type_class.getAll(category_id: category_id)
        var list_products :[delivery_type_class] = []
        
        for item in arr
        {
            let cls:delivery_type_class = delivery_type_class(fromDictionary: item    )
            
            if delivery_method_ids.firstIndex(of: cls.id ) != nil {
                list_products.append(cls)
            }
            
        }
        
        
        return  list_products
    }
    
    
    static func get_delivery_not_have_category(deleted:Bool? = nil) ->  [[String:Any]] {
           
        let pos = SharedManager.shared.posConfig()
           var deleted_sql = ""
        var deleted_condation_sql = ""

           if let deleted = deleted {
               deleted_sql = "and delivery_type_avalible.deleted = \(deleted ? 1:0)"
               deleted_condation_sql = "and relations.deleted = \(deleted ? 1:0)"
           }
         let sql = """
                SELECT  delivery_type_avalible.* from

                          (SELECT  delivery_type.* from delivery_type
                          where delivery_type.id  in
                         (SELECT re_id2 FROM relations
                         where relations .re_table1_table2  ='pos_config|delivery_type' and re_id1 =  \(pos.id) \(deleted_condation_sql) )) as delivery_type_avalible
                         
                         left join   delivery_type_category
                         on delivery_type_category.id  =  delivery_type_avalible.category_id
                         WHERE delivery_type_category.id is NULL \(deleted_sql)
                         ORDER BY delivery_type_avalible."sequence"
            """
        let cls = delivery_type_class(fromDictionary: [:])

        return ( cls.dbClass?.get_rows(sql: sql)) ?? []
           
       }
    
    static func getDeliveryProduct(for id:Int? ) -> delivery_type_class
       {
           var cls = delivery_type_class(fromDictionary: [:])
           var condationID = ""
           if let id = id {
               condationID = " and id = \(id) "
           }
           let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where order_type = 'delivery' and delivery_product_id != 0 \(condationID) and deleted = 0"  )
           if row != nil
                {
             cls = delivery_type_class(fromDictionary: row!)
           }

           return cls
       }
    static func getServiceChargeProduct(for id:Int? ) -> delivery_type_class
       {
           var cls = delivery_type_class(fromDictionary: [:])
           var condationID = ""
           if let id = id {
               condationID = " and id = \(id) "
           }
           let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where service_product_id != 0 \(condationID) and deleted = 0"  )
           if row != nil
                {
             cls = delivery_type_class(fromDictionary: row!)
           }

           return cls
       }
    
    static func getExtraProduct() -> delivery_type_class
       {
           var cls = delivery_type_class(fromDictionary: [:])

           let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where order_type = 'extra'"  )
           if row != nil
                {
             cls = delivery_type_class(fromDictionary: row!)
           }

           return cls
       }
    
    
    static func getDefault()-> delivery_type_class?
    {
        let  pos = SharedManager.shared.posConfig()
        if pos.delivery_method_id != nil
        {
            //            let default_id = pos.delivery_method_id[0] as? Int ?? 0
            let list:[[String:Any]]  = delivery_type_class.getAll() // api.get_last_cash_result(keyCash:"get_order_type")
            for item in list
            {
                let cls:delivery_type_class = delivery_type_class(fromDictionary: item )
                if cls.id == pos.delivery_method_id
                {
                    return cls
                    
                }
                
                
            }
        }
        
        return nil
    }
    
    static func get(id:Int?)-> delivery_type_class?
    {
        if id != nil
        {
            
            
            let cls = delivery_type_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where id = " + String(id!))
            if row !=  nil
            {
                let temp:delivery_type_class = delivery_type_class(fromDictionary: row!  )
                return temp
            }
        }
        return nil
    }
    
    static func get(ids:[Int]) ->  [[String:Any]] {
        if ids.count == 0
        {
            return []
        }
        
        var str_ids = ""
        for i in ids
        {
            str_ids = str_ids + "," + String(i)
        }
        
        str_ids.removeFirst()
        
        let cls = delivery_type_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where id in (\(str_ids)) ")
        return arr
        
    }
 
    
    func get_journal_ids() -> [Int]
      {
          return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "delivery_type|account_journal") ?? []
      }
     func getPromotionIds() -> [Int]{
         var promotionIds:[Int] = []
        let sql = """
        SELECT re_id1  as promID from relations where re_table1_table2 = 'pos_promotion|apply_on_order_types' and re_id2 = \(self.id )
"""
         let result:[[String:Any]] = self.dbClass!.get_rows(sql: sql )
             if result.count > 0 {
                 promotionIds = Array(Set(result.compactMap{ ( $0["promID"] as? Int)}))
             }
         return promotionIds
         
        
    }
    
}
