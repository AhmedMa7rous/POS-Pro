//
//  load_loyalty_config_settings.swift
//  pos
//
//  Created by khaled on 17/07/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class loyalty_config_settings_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0

    
    var points_based_on : String = ""
 
    var minimum_purchase : Double = 0
    var point_calculation : Double = 0
    var to_amount : Double = 0

    var points : Int = 0

 
    
    
 
    
    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
 
        
        id = dictionary["id"] as? Int ?? 0

        points_based_on = dictionary["points_based_on"] as? String ?? ""
    
        points = dictionary["points"] as? Int ?? 0
 
        minimum_purchase = dictionary["minimum_purchase"] as? Double ?? 0
        point_calculation = dictionary["point_calculation"] as? Double ?? 0
        to_amount = dictionary["to_amount"] as? Double ?? 0

        
        dbClass = database_class(table_name: "load_loyalty_config_settings", dictionary: self.toDictionary(),id: id,id_key:"id")
        
       

    }
    
    
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["points_based_on"] = points_based_on
        dictionary["points"] = points
        
        dictionary["minimum_purchase"] = minimum_purchase
        dictionary["point_calculation"] = point_calculation
        dictionary["to_amount"] = to_amount
        
        
        
        return dictionary
    }
    
    
    static func reset()
    {
        let cls = loyalty_config_settings_class(fromDictionary: [:])
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from load_loyalty_config_settings")
         
    }
    
    
 
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        _ =  dbClass!.save()
        
    }
        
        
    static func get() -> loyalty_config_settings_class
    {
        var cls = loyalty_config_settings_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "limit 0,1")
        if row != nil
        {
            cls = loyalty_config_settings_class(fromDictionary: row!)
        }
        
        return cls
    }

}
