//
//  pos_delivery_area_class.swift
//  pos
//
//  Created by M-Wageh on 06/11/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class pos_delivery_area_class:NSObject{
    var dbClass:database_class?
    
    var id : Int = 0
    var name : String = ""
    var display_name : String = ""
    var delivery_product_id : Int = 0
    var delivery_product_name :  String = ""
    var delivery_amount : Double = 0.0
    var active : Bool = true
    var deleted : Bool = false
    var __last_update : String = ""

    
    
    override init() {
        
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        display_name = dictionary["display_name"] as? String ?? ""
        delivery_product_id =   baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "delivery_product_id", keyOfDatabase: "delivery_product_id",Index: 0) as? Int ?? 0
        delivery_product_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "delivery_product_id", keyOfDatabase: "delivery_product_name",Index: 1)as? String  ?? ""
        delivery_amount = dictionary["delivery_amount"]  as?  Double ?? 0.0

        __last_update = dictionary["__last_update"] as? String ?? ""

 
         
        active = dictionary["active"] as? Bool ?? false

        
        
      
        dbClass = database_class(table_name: "pos_delivery_area", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    
    func toDictionary() -> [String:Any]
    {
     var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["display_name"] = display_name
        dictionary["delivery_product_id"] = delivery_product_id
        dictionary["delivery_product_name"] = delivery_product_name
        dictionary["delivery_amount"] = delivery_amount
        dictionary["deleted"] = deleted
        dictionary["active"] = active


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
        let cls = pos_delivery_area_class(fromDictionary: [:])
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
            let pos = pos_delivery_area_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        let cls = pos_delivery_area_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " order by id")
        return arr
    }
    static func getBy(id:Int) ->  pos_delivery_area_class?{
        let cls = pos_delivery_area_class(fromDictionary: [:])
        if let object  = cls.dbClass!.get_row(whereSql: " where id = \(id) order by id"){
                return pos_delivery_area_class(fromDictionary: object)
        }
        return nil
    }
    
  
    
}
