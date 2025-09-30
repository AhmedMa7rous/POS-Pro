//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

 
class get_discount_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0 // id on server
 
    var display_name : String = ""
  
    var pos_quantity_dis_rel_id : Int = 0
   var pos_quantity_dis_rel_name : String = ""
    
     var product_id_dis_id : Int = 0
    var product_id_dis_name : String = ""
 
    
    var qty: Double = 0
    var discount_dis_x : Double = 0
    var discount_fixed_x : Double = 0

    
    var no_of_applied_times : Int = 1000
    var deleted : Bool = false

 
    
    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
  
        display_name = dictionary["display_name"] as? String ?? ""
 
        no_of_applied_times  = dictionary["no_of_applied_times"] as? Int ?? 0

        pos_quantity_dis_rel_id =  baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_quantity_dis_rel", keyOfDatabase: "pos_quantity_dis_rel_id",Index: 0) as? Int ?? 0
        pos_quantity_dis_rel_name =  baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_quantity_dis_rel", keyOfDatabase: "pos_quantity_dis_rel_name",Index: 1) as? String ?? ""

        product_id_dis_id =  baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_id_dis", keyOfDatabase: "product_id_dis_id",Index: 0) as? Int ?? 0
        product_id_dis_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_id_dis", keyOfDatabase: "product_id_dis_name",Index: 1)  as? String ?? ""
        
         qty = dictionary["qty"] as? Double ?? 0
        discount_dis_x = dictionary["discount_dis_x"] as? Double ?? 0
        discount_fixed_x = dictionary["discount_fixed_x"] as? Double ?? 0

        
  
        dbClass = database_class(table_name: "get_discount", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
             dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["pos_quantity_dis_rel_id"] = pos_quantity_dis_rel_id
        dictionary["pos_quantity_dis_rel_name"] = pos_quantity_dis_rel_name
        dictionary["product_id_dis_id"] = product_id_dis_id
   
        dictionary["product_id_dis_id"] = product_id_dis_id
        dictionary["product_id_dis_name"] = product_id_dis_name
        dictionary["qty"] = qty
        dictionary["discount_dis_x"] = discount_dis_x

        dictionary["no_of_applied_times"] = no_of_applied_times
        dictionary["discount_fixed_x"] = discount_fixed_x
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
        
        _ =  dbClass!.save()
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = get_discount_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
  
        
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = get_discount_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = false
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = get_discount_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func getAll(promotion_id:Int) ->  [[String:Any]] {
        
        let cls = get_discount_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where pos_quantity_dis_rel_id = \(promotion_id)")
        return arr
        
    }
    
    static func get(id:Int)-> get_discount_class?
    {
         
            
            let cls = get_discount_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(id))
            if row !=  nil
            {
                let temp:get_discount_class = get_discount_class(fromDictionary: row!  )
                return temp
            }
        
        return nil
    }
    
    static func get(product_id_dis_id:Int)-> get_discount_class?
    {
          
            let cls = get_discount_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   product_id_dis_id = " + String(product_id_dis_id))
            if row !=  nil
            {
                let temp:get_discount_class = get_discount_class(fromDictionary: row!  )
                return temp
            }
        
        return nil
    }
    
     
    
    
}
