//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_template_attribute_value_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    
    var product_tmpl_id_id : Int = 0
    var product_tmpl_id_name : String = ""

    var attribute_id_id : Int = 0
    var attribute_id_name : String = ""
     
    var product_attribute_value_id_id : Int = 0
   var product_attribute_value_id_name : String = ""
    
    var price_extra:Double = 0
   
    var own_sequence : Int = 0

    
  
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        price_extra = dictionary["price_extra"] as? Double ?? 0
        own_sequence = dictionary["own_sequence"] as? Int ?? 0

        
        
        product_tmpl_id_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id_id",Index: 0) as? Int ?? 0
        product_tmpl_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id_name",Index: 1) as? String ??  ""

 
        attribute_id_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "attribute_id", keyOfDatabase: "attribute_id_id",Index: 0) as? Int ?? 0
       attribute_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "attribute_id", keyOfDatabase: "attribute_id_name",Index: 1) as? String ??  ""
        
        product_attribute_value_id_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_attribute_value_id", keyOfDatabase: "product_attribute_value_id_id",Index: 0) as? Int ?? 0
       product_attribute_value_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_attribute_value_id", keyOfDatabase: "product_attribute_value_id_name",Index: 1) as? String ??  ""
          
        
        
 

        dbClass = database_class(table_name: "product_template_attribute_value", dictionary: self.toDictionary(),id: id,id_key:"id")

        
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["product_tmpl_id_id"] = product_tmpl_id_id
        dictionary["product_tmpl_id_name"] = product_tmpl_id_name
        dictionary["attribute_id_id"] = attribute_id_id
        dictionary["attribute_id_name"] = attribute_id_name

        dictionary["product_attribute_value_id_id"] = product_attribute_value_id_id
        dictionary["product_attribute_value_id_name"] = product_attribute_value_id_name
        dictionary["price_extra"] = price_extra
        dictionary["own_sequence"] = own_sequence

        
        
        return dictionary
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = product_template_attribute_value_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
  
        
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
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = product_template_attribute_value_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = product_template_attribute_value_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
      
    }
    
    
}
