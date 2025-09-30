//
//  ir_translation_class.swift
//  pos
//
//  Created by Khaled on 12/13/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation


class ir_translation_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var res_id : Int = 0

    
    var lang : String = ""
    var name : String = ""
    var value : String = ""
    var state : String = ""
    var src : String = ""
    var __last_update : String?

  
    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        res_id = dictionary["res_id"] as? Int ?? 0

        name = dictionary["name"] as? String ?? ""
        value = dictionary["value"] as? String ?? ""
        state = dictionary["state"] as? String ?? ""
        src = dictionary["src"] as? String ?? ""
        lang = dictionary["lang"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""

  
        dbClass = database_class(table_name: "ir_translation", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
       dictionary["id"] = id
        dictionary["res_id"] = res_id

        dictionary["name"] = name
        dictionary["value"] = value
        dictionary["state"] = state
        dictionary["src"] = src
        dictionary["lang"] = lang
        dictionary["__last_update"] = __last_update

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
        let cls = ir_translation_class(fromDictionary: [:])
        
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
            let pos = ir_translation_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = ir_translation_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func get(id:Int?)-> ir_translation_class?
    {
        if id != nil
        {
             
            let cls = ir_translation_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(id!))
            if row !=  nil
            {
                let temp:ir_translation_class = ir_translation_class(fromDictionary: row!  )
                return temp
            }
        }
        return nil
    }
    
     
    
    
 
    
}
