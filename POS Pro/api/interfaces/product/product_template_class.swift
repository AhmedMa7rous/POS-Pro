//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_template_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    
    var display_name : String = ""
    var name : String = ""
    
    var __last_update : String = ""
    
    var sale_ok:Bool = false
    var available_in_pos:Bool = false

    var product_variant_ids:[Int] = []
    var valid_product_template_attribute_line_ids:[Int] = []
    var valid_product_attribute_ids:[Int] = []
    var valid_product_attribute_value_ids:[Int] = []
    var optional_product_ids:[Int] = []

    var open_price:Bool = false
    var deleted : Bool = false
    var storage_unit_qty_available:Double?

 
    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        
        display_name = dictionary["display_name"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        
        sale_ok = dictionary["sale_ok"] as? Bool ?? false
        available_in_pos = dictionary["available_in_pos"] as? Bool ?? false
        open_price = dictionary["open_price"] as? Bool ?? false

        
        
        product_variant_ids = dictionary["product_variant_ids"] as? [Int] ?? []
        valid_product_template_attribute_line_ids = dictionary["valid_product_template_attribute_line_ids"] as? [Int] ?? []
        valid_product_attribute_ids = dictionary["valid_product_attribute_ids"] as? [Int] ?? []
        valid_product_attribute_value_ids = dictionary["valid_product_attribute_value_ids"] as? [Int] ?? []
        optional_product_ids = dictionary["optional_product_ids"] as? [Int] ?? []
        storage_unit_qty_available = dictionary["storage_unit_qty_available"] as? Double ?? 0.0

        dbClass = database_class(table_name: "product_template", dictionary: self.toDictionary(),id: id,id_key:"id")

        
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["name"] = name
        dictionary["__last_update"] = __last_update
        dictionary["sale_ok"] = sale_ok
        dictionary["available_in_pos"] = available_in_pos
        dictionary["open_price"] = open_price
        dictionary["deleted"] = deleted
        dictionary["storage_unit_qty_available"] = storage_unit_qty_available

        
        
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
        
        relations_database_class(re_id1: self.id, re_id2: product_variant_ids, re_table1_table2: "product_template|product_product").save()
        relations_database_class(re_id1: self.id, re_id2: valid_product_template_attribute_line_ids, re_table1_table2: "product_template|valid_product_template_attribute_line_ids").save()
        relations_database_class(re_id1: self.id, re_id2: valid_product_attribute_ids, re_table1_table2: "product_template|valid_product_attribute_ids").save()
        relations_database_class(re_id1: self.id, re_id2: valid_product_attribute_value_ids, re_table1_table2: "product_template|valid_product_attribute_value_ids").save()
        relations_database_class(re_id1: self.id, re_id2: optional_product_ids, re_table1_table2: "product_template|optional_product_ids").save()

        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = product_template_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='product_template|product_product' ")
        relations_database_class.reset(  re_table1_table2: "product_template|product_product")

//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='product_template|valid_product_template_attribute_line_ids' ")
        relations_database_class.reset(  re_table1_table2: "product_template|valid_product_template_attribute_line_ids")

//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='product_template|valid_product_attribute_ids' ")
        relations_database_class.reset(  re_table1_table2: "product_template|valid_product_attribute_ids")

//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='product_template|valid_product_attribute_value_ids' ")
        relations_database_class.reset(  re_table1_table2: "product_template|valid_product_attribute_value_ids")

//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='product_template|optional_product_ids' ")
        relations_database_class.reset(  re_table1_table2: "product_template|optional_product_ids")

 
        
    }
    
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = product_template_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = product_template_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
      
    }
    
    static func get(id:Int) -> product_template_class?
    {
        var cls = product_template_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id = \(String(id))"  )
        if row != nil
        {
            cls = product_template_class(fromDictionary: row!)
        }
        else
        {
            return nil
        }
        
        return cls
    }
    
    
}
