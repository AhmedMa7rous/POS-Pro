//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class delivery_type_category_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var name : String = ""
    var display_name : String = ""
 
    
    var __last_update : String = ""
    var deleted : Bool = false

    
 
    
    
    override init() {
        
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
    

        
        name = dictionary["name"] as? String ?? ""
        display_name = dictionary["display_name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        
  
        dbClass = database_class(table_name: "delivery_type_category", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    
    func toDictionary() -> [String:Any]
    {
     var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["display_name"] = display_name

        dictionary["__last_update"] = __last_update
        dictionary["deleted"] = deleted

 
        return dictionary
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = delivery_type_category_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
 
        
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
            let pos = delivery_type_category_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = delivery_type_category_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func getAllHaveDelivery(deleted:Bool? = nil) ->  [[String:Any]] {
        var deleted_sql = ""
        if let deleted = deleted {
            deleted_sql = "WHERE delivery_type.deleted = \(deleted ? 1:0)"
        }
        let sql = """
             SELECT  delivery_type_category.* from delivery_type
                inner join   delivery_type_category
                on delivery_type_category.id  =  delivery_type.category_id
                \(deleted_sql)
                GROUP BY delivery_type_category.id
        """
        
        let cls = delivery_type_category_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        return arr
        
    }
    
}
