//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_template_attribute_line_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    
    var product_tmpl_id_id : Int = 0
    var product_tmpl_id_name : String = ""

    var attribute_id_id : Int = 0
    var attribute_id_name : String = ""
     
 
   
    
    var value_ids:[Int] = []
  

    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
 
        
        
        product_tmpl_id_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id_id",Index: 0) as? Int ?? 0
        product_tmpl_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id_name",Index: 1) as? String ??  ""

 
        attribute_id_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "attribute_id", keyOfDatabase: "attribute_id_id",Index: 0) as? Int ?? 0
       attribute_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "attribute_id", keyOfDatabase: "attribute_id_name",Index: 1) as? String ??  ""
        
  
        
        
        value_ids = dictionary["value_ids"] as? [Int] ?? []
 

        dbClass = database_class(table_name: "product_template_attribute_line", dictionary: self.toDictionary(),id: id,id_key:"id")

        
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["product_tmpl_id_id"] = product_tmpl_id_id
        dictionary["product_tmpl_id_name"] = product_tmpl_id_name
        dictionary["attribute_id_id"] = attribute_id_id
        dictionary["attribute_id_name"] = attribute_id_name

 
        
        
        return dictionary
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = product_template_attribute_line_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from '\(table)'")
        
  
        relations_database_class.reset(re_table1_table2: "product_template_attribute_line|value_ids")
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
        
        relations_database_class(re_id1: self.id, re_id2: value_ids, re_table1_table2: "product_template_attribute_line|value_ids").save()
   
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = product_template_attribute_line_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = product_template_attribute_line_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
      
    }
    
    
}
