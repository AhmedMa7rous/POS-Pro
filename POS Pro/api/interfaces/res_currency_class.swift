//
//  posSessionClass.swift
//  pos
//
//  Created by khaled on 11/12/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation
class res_currency_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var name: String = ""
    var symbol: String = ""
    var position: String = ""
    var rounding : Double  = 0
    var rate : Double  = 0
    var __last_update : String?
    
    
    
    override init() {
        super.init()
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        __last_update = dictionary["__last_update"] as? String ?? ""
        
        name = dictionary["name"] as? String ?? ""
        symbol = dictionary["symbol"] as? String ?? ""
        position = dictionary["position"] as?  String ?? ""
        
        rounding = dictionary["rounding"] as? Double ?? 0
        rate = dictionary["rate"] as? Double ?? 0
        
        dbClass = database_class(table_name: "res_currency", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    func toDictionary() -> [String:Any]
    {
        
     var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["symbol"] = symbol
        dictionary["position"] = position
        dictionary["rounding"] = rounding
        dictionary["rate"] = rate
        dictionary["__last_update"] = __last_update
        
        
        
        
        
        return dictionary
        
    }
    
    
    static func reset(temp:Bool = false)
    {
        let cls = res_currency_class(fromDictionary: [:])
        
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
            let pos = res_currency_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    
      static func get(currency_id:Int)-> res_currency_class?
       {
          let cls = res_currency_class(fromDictionary: [:])
          let row  = cls.dbClass!.get_row(whereSql: " where id = " + String(currency_id))
         if row !=  nil
         {
           let temp:res_currency_class = res_currency_class(fromDictionary: row!  )
           return temp
         }
    
           
           
           return nil
       }
    
}
