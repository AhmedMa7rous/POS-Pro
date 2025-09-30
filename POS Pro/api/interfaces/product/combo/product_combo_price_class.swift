//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_combo_price_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    
    var display_name : String = ""
    
    var __last_update : String = ""
    
    var product_tmpl_id: Int = 0
    var product_tmpl_name: String = ""
    
    
    var product_id : Int = 0
    var product_name: String = ""
    
    
    var extra_price: Double = 0.0
    var auto_select_num : Int = 0
    
    var attribute_value_id : Int = 0
    var deleted : Bool = false

    
    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        auto_select_num = dictionary["auto_select_num"] as? Int ?? 0
        extra_price = dictionary["extra_price"] as? Double ?? 0
        
        display_name = dictionary["display_name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        
        
        //        product_tmpl_id = (dictionary["product_tmpl_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        product_tmpl_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id",Index: 0) as? Int ?? 0
        product_tmpl_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_name",Index: 1)as? String  ?? ""
        
        //        product_id = (dictionary["product_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        product_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_id", keyOfDatabase: "product_id",Index: 0) as? Int ?? 0
        product_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_id", keyOfDatabase: "product_name",Index: 1) as? String  ?? ""
        
        attribute_value_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "attribute_value_id", keyOfDatabase: "attribute_value_id",Index: 0) as? Int ?? 0
        
        dbClass = database_class(table_name: "product_combo_price", dictionary: self.toDictionary(),id: id,id_key:"id")
        
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["auto_select_num"] = auto_select_num
        dictionary["extra_price"] = extra_price
        
        dictionary["display_name"] = display_name
        dictionary["__last_update"] = __last_update
        
        dictionary["product_tmpl_id"] = product_tmpl_id
        dictionary["product_tmpl_name"] = product_tmpl_name
        dictionary["product_id"] = product_id
        dictionary["product_name"] = product_name
        dictionary["attribute_value_id"] = attribute_value_id
        dictionary["deleted"] = deleted

        
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
        
        
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = product_combo_price_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
 
        
    }
    
     static func clear()
     {
         let cls = product_combo_price_class(fromDictionary: [:])
        _  = cls.dbClass!.runSqlStatament(sql: "delete from product_combo_price")
     }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        clear()
        
        for item in arr
        {
            let pos = product_combo_price_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = product_combo_price_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
}
