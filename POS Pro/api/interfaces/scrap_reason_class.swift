//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class scrap_reason_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var name : String = ""
    var description_ : String = ""
    var __last_update : String = ""
    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        
        name = dictionary["name"] as? String ?? ""
        description_ = dictionary["description"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        
        dbClass = database_class(table_name: "scrap_reason", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["description"] = description_
        dictionary["__last_update"] = __last_update
        
        
        
        return dictionary
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = scrap_reason_class(fromDictionary: [:])
        
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
            let pos = scrap_reason_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    
    
    static func getDefault() ->  [[String:Any]] {
        
        let cls = scrap_reason_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
        //             var list : [scrapReasonClass] = []
        //
        //             for item in arr
        //             {
        //                 let cls = scrapReasonClass(fromDictionary: item  )
        //                 list.append(cls)
        //             }
        //             return list
    }
    
    
}
