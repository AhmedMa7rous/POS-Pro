//
//  pos_driver_class.swift
//  pos
//
//  Created by M-Wageh on 16/09/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
class pos_driver_class : NSObject  {
    var id : Int = 0
    var row_id : Int = 0

    var name : String?
    var code : String?
    var driver_cost:Int?
    var dbClass:database_class?
    var deleted : Bool = false

    override init() {
        
    }
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        id = dictionary["id"] as? Int ?? 0

        row_id = dictionary["row_id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        code = dictionary["code"] as? String ?? ""
        driver_cost = dictionary["driver_cost"] as? Int ?? 0
        deleted = dictionary["deleted"] as? Bool ?? false

        dbClass = database_class(table_name: "pos_driver", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        dictionary["id"] = id
        dictionary["row_id"] = row_id
        dictionary["name"] = name
        dictionary["code"] = code
        dictionary["driver_cost"] = driver_cost
        dictionary["deleted"] = deleted

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
        
        self.id =  dbClass!.save()
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = pos_driver_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")

//     _ =   cls.dbClass!.runSqlStatament(sql: "delete from \(table) where row_id != 0")
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = pos_driver_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = false
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [pos_driver_class] {
        
        let cls = pos_driver_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where deleted = 0")
        
        return arr.map({pos_driver_class(fromDictionary: $0)})
        
    }
    static func get(driver_id:Int?)-> pos_driver_class?
    {
        if driver_id != nil
        {
            
            
            let cls = pos_driver_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(driver_id!) + " and deleted = 0")
            if row !=  nil
            {
                let temp:pos_driver_class = pos_driver_class(fromDictionary: row!  )
                return temp
            }
        }
        return nil
    }
    static func get(row_id:Int?)-> pos_driver_class?
    {
        if row_id != nil
        {
            
            
            let cls = pos_driver_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   row_id = " + String(row_id!) + " and deleted = 0")
            if row !=  nil
            {
                let temp:pos_driver_class = pos_driver_class(fromDictionary: row!  )
                return temp
            }
        }
        return nil
    }
   
    
}
