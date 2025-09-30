//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

 
class pos_conditions_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0 // id on server
 
    var display_name : String = ""
  
    var pos_promotion_rel_id : Int = 0
   var pos_promotion_rel_name : String = ""
    
    var product_x_id : Int = 0
    var _operator : String = ""

    
    var quantity: Double = 0
    var quantity_y : Double = 0

    var product_y_id : Int = 0

    var no_of_applied_times : Int = 1000


    
    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
  
        display_name = dictionary["display_name"] as? String ?? ""
        _operator = dictionary["operator"] as? String ?? ""
        
        no_of_applied_times  = dictionary["no_of_applied_times"] as? Int ?? 0
        
         
        pos_promotion_rel_id =  baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_promotion_rel", keyOfDatabase: "pos_promotion_rel_id",Index: 0) as? Int ?? 0
        pos_promotion_rel_name =   baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_promotion_rel", keyOfDatabase: "pos_promotion_rel_name",Index: 1) as? String ?? ""

        
        product_x_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_x_id", keyOfDatabase: "product_x_id",Index: 0) as? Int ?? 0
        quantity = dictionary["quantity"] as? Double ?? 0
        quantity_y = dictionary["quantity_y"] as? Double ?? 0

        
        product_y_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_y_id", keyOfDatabase: "product_y_id",Index: 0)  as? Int ?? 0

        
       
        dbClass = database_class(table_name: "pos_conditions", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
             dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["operator"] = _operator
        dictionary["pos_promotion_rel_id"] = pos_promotion_rel_id
        dictionary["pos_promotion_rel_name"] = pos_promotion_rel_name
   
        dictionary["product_x_id"] = product_x_id
        dictionary["quantity"] = quantity
        dictionary["quantity_y"] = quantity_y
        dictionary["product_y_id"] = product_y_id

        dictionary["no_of_applied_times"] = no_of_applied_times

        
 
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
        let cls = pos_conditions_class(fromDictionary: [:])
        
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
            let pos = pos_conditions_class(fromDictionary: item)
            pos.dbClass?.insertId = false
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = pos_conditions_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
  
    
    static func get(id:Int)-> pos_conditions_class?
    {
         
            
            let cls = pos_conditions_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(id))
            if row !=  nil
            {
                let temp:pos_conditions_class = pos_conditions_class(fromDictionary: row!  )
                return temp
            }
        
        return nil
    }
    
     
    static func getAll(promotion_id:Int,product_x_id:Int? = nil) ->  [[String:Any]] {
        
        let cls = pos_conditions_class(fromDictionary: [:])
        
        var withProductID = ""
        if product_x_id != nil
        {
            withProductID = " And product_x_id =\(product_x_id!)"
        }
        
        let arr  = cls.dbClass!.get_rows(whereSql: " where pos_promotion_rel_id = \(promotion_id) \(withProductID)")
        return arr
        
    }
     
    
    
    
}
