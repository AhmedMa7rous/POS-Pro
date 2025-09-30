//
//  res_country.swift
//  pos
//
//  Created by Khaled on 12/5/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class res_country_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var name : String = ""
    var vat_label : String = ""
    var __last_update : String?
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        
        name = dictionary["name"] as? String ?? ""
        vat_label = dictionary["vat_label"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        
        dbClass = database_class(table_name: "res_country", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["vat_label"] = vat_label
        dictionary["__last_update"] = __last_update
        
        
        
        return dictionary
        
    }
    static func reset(temp:Bool = false)
    {
        let cls = res_country_class(fromDictionary: [:])
        
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
            let pos = res_country_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = res_country_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
}
