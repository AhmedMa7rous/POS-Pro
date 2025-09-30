//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

 
class discount_above_price_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0 // id on server
 
    var display_name : String = ""
  
    var pos_promotion_id_id : Int = 0
   var pos_promotion_id_name : String = ""
     
    var discount: Double = 0
    var price : Double = 0
 var fix_price_discount : Double = 0

    var discount_type : String = ""

        var free_product_id : Int = 0
    
    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
  
        display_name = dictionary["display_name"] as? String ?? ""
 discount_type = dictionary["discount_type"] as? String ?? ""

         
        pos_promotion_id_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_promotion_id", keyOfDatabase: "pos_promotion_id_id",Index: 0) as? Int ?? 0
        pos_promotion_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_promotion_id", keyOfDatabase: "pos_promotion_id_name",Index: 1) as? String ?? ""

 
        
         discount = dictionary["discount"] as? Double ?? 0
        price = dictionary["price"] as? Double ?? 0
        fix_price_discount = dictionary["fix_price_discount"] as? Double ?? 0

        free_product_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "free_product", keyOfDatabase: "free_product_id",Index: 0)  as? Int ?? 0

  
        dbClass = database_class(table_name: "discount_above_price", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
             dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["discount_type"] = discount_type
        dictionary["pos_promotion_id_id"] = pos_promotion_id_id
        dictionary["pos_promotion_id_name"] = pos_promotion_id_name
        dictionary["discount"] = discount
        dictionary["price"] = price
        dictionary["fix_price_discount"] = fix_price_discount
        dictionary["free_product_id"] = free_product_id
        


 
 
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
        let cls = discount_above_price_class(fromDictionary: [:])
        
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
            let pos = discount_above_price_class(fromDictionary: item)
            pos.dbClass?.insertId = false
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = discount_above_price_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func get(id:Int)-> discount_above_price_class?
    {
         
            
            let cls = discount_above_price_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(id))
            if row !=  nil
            {
                let temp:discount_above_price_class = discount_above_price_class(fromDictionary: row!  )
                return temp
            }
        
        return nil
    }
    
     
    
     
    
    
}
