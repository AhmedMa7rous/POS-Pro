//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class restaurant_floor_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
     var pos_config_id : Int = 0

 
    var name : String = ""
    var pos_config_name : String = ""
  
    
 var table_ids : [Int] = []

    
    
    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        pos_config_id = dictionary["pos_config_id"] as? Int ?? 0

        
        
        name = dictionary["name"] as? String ?? ""
 
        table_ids = dictionary["table_ids"] as? [Int] ?? []

        
         pos_config_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_config_id", keyOfDatabase: "pos_config_id",Index: 0) as? Int ?? 0
         pos_config_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_config_id", keyOfDatabase: "pos_config_name",Index: 1)as? String  ?? ""

        
        dbClass = database_class(table_name: "restaurant_floor", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
             dictionary["id"] = id
        dictionary["name"] = name

     dictionary["pos_config_id"] = pos_config_id
        dictionary["pos_config_name"] = pos_config_name

        
        
        return dictionary
    }
    
    
    static func reset(temp:Bool = false)
    {
        let cls = restaurant_floor_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='restaurant_floor|restaurant_table' ")
 
        
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
        
        
        relations_database_class(re_id1: self.id, re_id2: table_ids, re_table1_table2: "restaurant_floor|restaurant_table").save()

        
    }
    
    func get_table_ids() -> [Int]
      {
          return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "restaurant_floor|restaurant_table") ?? []
      }
    
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = restaurant_floor_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = restaurant_floor_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func get(id:Int?)-> restaurant_floor_class?
    {
        if id != nil
        {
            
            
            let cls = restaurant_floor_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(id!))
            if row !=  nil
            {
                let temp:restaurant_floor_class = restaurant_floor_class(fromDictionary: row!  )
                return temp
            }
        }
        return nil
    }
    
     
    
    
 
    
}
