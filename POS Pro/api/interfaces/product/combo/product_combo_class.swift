//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_combo_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    
    var display_name : String = ""
    
    var __last_update : String = ""
    
    var product_tmpl_id: Int = 0
    var product_tmpl_name: String = ""
    
    var require:Bool = false
    var pos_category_id : Int = 0
    var pos_category_id_name: String = ""
    
    var sequence : Int = 0

    
    
    var product_ids:[Int] = []
    var valid_product_attribute_value_ids:[Int] = []
    var attribute_value_ids:[Int] = []

    
    var no_of_items : Int = 0
    var min_no_of_items : Int = 0

    var deleted : Bool = false

    
    // not used in database
    var app_require : Bool = false
    var app_selected : Bool = false
    
    var is_combo : Bool = false
    var product_id : Int = 0
    //    var extra_price : Double = 0
    //    var auto_select_num : Double = 0
    
   

    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        min_no_of_items = dictionary["min_no_of_items"] as? Int ?? 0

        
        sequence = dictionary["sequence"] as? Int ?? 0

        no_of_items = dictionary["no_of_items"] as? Int ?? 0
        require = dictionary["required"] as? Bool ?? false
        
        display_name = dictionary["display_name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        
        product_ids = dictionary["product_ids"] as? [Int] ?? []
        valid_product_attribute_value_ids = dictionary["valid_product_attribute_value_ids"] as? [Int] ?? []
        attribute_value_ids = dictionary["attribute_value_ids"] as? [Int] ?? []

        //        product_tmpl_id = (dictionary["product_tmpl_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        product_tmpl_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id",Index: 0) as? Int ?? 0
        product_tmpl_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_name",Index: 1)as? String  ?? ""
        
        //        pos_category_id = (dictionary["pos_category_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        pos_category_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_category_id", keyOfDatabase: "pos_category_id",Index: 0) as? Int ?? 0
        pos_category_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_category_id", keyOfDatabase: "pos_category_id_name",Index: 1)as? String  ?? ""
        
        
        dbClass = database_class(table_name: "product_combo", dictionary: self.toDictionary(),id: id,id_key:"id")
        
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["no_of_items"] = no_of_items
        dictionary["display_name"] = display_name
        dictionary["__last_update"] = __last_update
        
        dictionary["product_tmpl_id"] = product_tmpl_id
        dictionary["product_tmpl_name"] = product_tmpl_name
        dictionary["pos_category_id"] = pos_category_id
        dictionary["pos_category_id_name"] = pos_category_id_name
        dictionary["require"] = require
        dictionary["sequence"] = sequence
        dictionary["deleted"] = deleted
        dictionary["min_no_of_items"] = min_no_of_items

        
        
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
        
        relations_database_class(re_id1: self.id, re_id2: product_ids, re_table1_table2: "product_combo|product_product").save()
        relations_database_class(re_id1: self.id, re_id2: valid_product_attribute_value_ids, re_table1_table2: "product_combo|valid_product_attribute_value_ids").save()

          relations_database_class(re_id1: self.id, re_id2: attribute_value_ids, re_table1_table2: "product_combo|attribute_value_ids").save()
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = product_combo_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")
         relations_database_class.reset(  re_table1_table2: "product_combo|product_product")
        relations_database_class.reset(  re_table1_table2: "product_combo|valid_product_attribute_value_ids")
        relations_database_class.reset(  re_table1_table2: "product_combo|attribute_value_ids")

        
//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
//
//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='product_combo|product_product' ")
//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='product_combo|valid_product_attribute_value_ids' ")
//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='product_combo|attribute_value_ids' ")

        
    }
    
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = product_combo_class(fromDictionary: item)
            pos.deleted = false

            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = product_combo_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    func productProductIDS() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "product_combo|product_product") ?? []
    }
    
    func  validProductAttributeValueIds() -> [Int]
     {
         return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "product_combo|valid_product_attribute_value_ids") ?? []
     }
    
    func  attributeValueIds() -> [Int]
        {
            return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "product_combo|attribute_value_ids") ?? []
        }
       
    
  static func get_combo(ID:Int) -> product_combo_class
 {
     var cls = product_combo_class(fromDictionary: [:])
     
     let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id = \(String(ID))"  )
     if row != nil
     {
         cls = product_combo_class(fromDictionary: row!)
     }
     
     return cls
 }
    static func get_combo(product_tmpl_id:Int) -> product_combo_class?
   {
       let cls = product_combo_class(fromDictionary: [:])
       
       let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where product_tmpl_id = \(String(product_tmpl_id))"  )
       if row != nil
       {
            return product_combo_class(fromDictionary: row!)
       }
       
       return nil
   }
    
}
