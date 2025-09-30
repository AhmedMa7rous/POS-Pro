//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_attribute_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
   
    var name : String = ""
     
 
     var value_ids:[Int] = []


    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""

        
        value_ids = dictionary["value_ids"] as? [Int] ?? []

       
 

        dbClass = database_class(table_name: "product_attribute", dictionary: self.toDictionary(),id: id,id_key:"id")

        
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
 
 
         
        
        return dictionary
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = product_attribute_class(fromDictionary: [:])
        
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
        
 
        relations_database_class(re_id1: self.id, re_id2: value_ids, re_table1_table2: "product_attribute|value_ids").save()

        
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = product_attribute_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = product_attribute_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
      
    }
    
    
}
