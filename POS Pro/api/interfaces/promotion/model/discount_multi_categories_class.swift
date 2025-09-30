//
//  customerClass.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

 
class discount_multi_categories_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0 // id on server
 
    var display_name : String = ""
  
    var multi_categ_dis_rel_id : Int = 0
   var multi_categ_dis_rel_name : String = ""
     
    var categ_discount: Double = 0
 
    
    override init() {
        
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
  
        display_name = dictionary["display_name"] as? String ?? ""
 
         
        multi_categ_dis_rel_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "multi_categ_dis_rel", keyOfDatabase: "multi_categ_dis_rel_id",Index: 0) as? Int ?? 0
        multi_categ_dis_rel_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "multi_categ_dis_rel", keyOfDatabase: "multi_categ_dis_rel_name",Index: 1) as? String ?? ""

 
        
         categ_discount = dictionary["categ_discount"] as? Double ?? 0
 
        
  
        dbClass = database_class(table_name: "discount_multi_categories", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
             dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["multi_categ_dis_rel_id"] = multi_categ_dis_rel_id
        dictionary["multi_categ_dis_rel_name"] = multi_categ_dis_rel_name
        dictionary["categ_discount"] = categ_discount
 

 
 
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
        let cls = discount_multi_categories_class(fromDictionary: [:])
        
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
            let pos = discount_multi_categories_class(fromDictionary: item)
            pos.dbClass?.insertId = false
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = discount_multi_categories_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func get(id:Int)-> discount_multi_categories_class?
    {
         
            
            let cls = discount_multi_categories_class(fromDictionary: [:])
            let row  = cls.dbClass!.get_row(whereSql: " where   id = " + String(id))
            if row !=  nil
            {
                let temp:discount_multi_categories_class = discount_multi_categories_class(fromDictionary: row!  )
                return temp
            }
        
        return nil
    }
    
     
    
     
    
    
}
