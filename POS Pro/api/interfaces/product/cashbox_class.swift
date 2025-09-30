//
//  cashboxClass.swift
//  pos
//
//  Created by Khaled on 12/12/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class cashbox_class: NSObject {
    var dbClass:database_class?

    var id:Int?
    var sessionID:Int?

    var cashbox_in_out : String = ""
    var cashbox_reason : String = ""
    var cashbox_amount : Double = 0
    var date: String?

    
    var cashier:res_users_class?
 
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()

            id = dictionary["id"] as? Int ?? 0

        
           sessionID = dictionary["sessionID"] as? Int ?? 0

        cashbox_in_out = dictionary["cashbox_in_out"] as? String ?? ""
        cashbox_reason = dictionary["cashbox_reason"] as? String ?? ""
        cashbox_amount = dictionary["cashbox_amount"] as? Double ?? 0
        date = dictionary["date"] as? String
        
        
        dbClass = database_class(table_name: "cashbox", dictionary: self.toDictionary(),id: id!,id_key:"id")
 
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["sessionID"] = sessionID

        dictionary["cashbox_in_out"] = cashbox_in_out
        dictionary["cashbox_reason"] = cashbox_reason
        dictionary["cashbox_amount"] = cashbox_amount
        dictionary["date"] = date

        return dictionary
        
    }
    
    
    func save()
      {
          dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id!
          dbClass?.insertId = false
          _ =  dbClass!.save()
          
           
          
      }
      
      static func saveAll(arr:[[String:Any]])
      {
          for item in arr
          {
              let pos = cashbox_class(fromDictionary: item)
              pos.dbClass?.insertId = false
              pos.save()
          }
      }
    
    
    static func get(session:Int)-> [[String:Any]]
          {
            
                  let cls = cashbox_class(fromDictionary: [:])
            return  cls.dbClass!.get_rows(whereSql: " where sessionID = " + String(session) + " order by id asc")
               
          }
}
