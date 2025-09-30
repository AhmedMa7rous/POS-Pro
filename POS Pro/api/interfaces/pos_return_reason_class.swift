//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class pos_return_reason_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var name : String = ""
    var display_name : String = ""
 
    var company_id : Int = 0

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
        
        company_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_id",Index: 0) as? Int ?? 0

        dbClass = database_class(table_name: "pos_return_reason", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    
    func toDictionary() -> [String:Any]
    {
     var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["display_name"] = display_name
        dictionary["company_id"] = company_id

        dictionary["__last_update"] = __last_update
        
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
             let cls = pos_return_reason_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
          _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")
      }
      
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = pos_return_reason_class(fromDictionary: item)
            pos.deleted = false
            
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = pos_return_reason_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    static func get(by id:Int) ->  pos_return_reason_class? {
        
        let cls = pos_return_reason_class(fromDictionary: [:])
        if let returnDic  = cls.dbClass!.get_row(whereSql: "where id = id"){
            return pos_return_reason_class(fromDictionary: returnDic)
        }
        return nil
        
    }
    
    
}
