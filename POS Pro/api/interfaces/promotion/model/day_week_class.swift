//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

 
class day_week_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0 // id on server
 
    var display_name : String = ""
    var name : String = ""
     
    
    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
  
        display_name = dictionary["display_name"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
         
       
        dbClass = database_class(table_name: "day_week", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
             dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["name"] = name
        
        return dictionary
    }
    
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        dbClass?.insertId = true
        
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        _ =  dbClass!.save()
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = day_week_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
  
        
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = day_week_class(fromDictionary: item)
            pos.dbClass?.insertId = false
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = day_week_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func get(id:Int)-> day_week_class?
    {
         
            
            let cls = day_week_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(id))
            if row !=  nil
            {
                let temp:day_week_class = day_week_class(fromDictionary: row!  )
                return temp
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
        
        let cls = day_week_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where id in (\(str_ids)) ")
        return arr
        
    }
 
    
     
    
    
}
