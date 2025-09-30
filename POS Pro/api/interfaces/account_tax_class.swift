//
//  account_tax.swift
//  pos
//
//  Created by khaled on 8/23/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class account_tax_class: NSObject {
    var dbClass:database_class?

    enum amount_type_taxs:String {
        case fixed = "fixed"
        case percent = "percent"
        case division = "division"
        case group = "group"
    }
    
    
    public var id : Int = 0
    public var name : String = ""
    public var amount_type : String = ""
    public var amount : Double = 0
    public var price_include : Bool = false
    public var include_base_amount : Bool = false
    public var __last_update : String = ""
    
   
        var company_id : Int?
    
    public var children_tax_ids : [Any] = []
    var deleted : Bool = false

 

    
    override init() {
           
       }
    
    
    init(fromDictionary dictionary: [String:Any]) {
        
        super.init()
          
           id = dictionary["id"] as? Int ?? 0
          company_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_id",Index: 0) as? Int ?? 0


        
        __last_update = dictionary["__last_update"] as? String ?? ""
           
           name = dictionary["name"] as? String ?? ""
        amount_type = dictionary["amount_type"] as? String ?? ""
   
        amount = dictionary["amount"] as? Double ?? 0

        price_include = dictionary["price_include"] as? Bool ?? false
        include_base_amount = dictionary["include_base_amount"] as? Bool ?? false
        
        dbClass = database_class(table_name: "account_tax", dictionary: self.toDictionary(),id: id,id_key:"id")

  
    }
    
    
    public func toDictionary() -> [String:Any] {
        
        var dictionary:[String:Any] = [:]
 
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["amount_type"] = amount_type
        dictionary["amount"] = amount
        dictionary["price_include"] = price_include
        dictionary["include_base_amount"] = include_base_amount
        dictionary["__last_update"] = __last_update
        dictionary["company_id"] = company_id
        dictionary["deleted"] = deleted

        
        return dictionary
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = account_tax_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
 
        
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
               let pos = account_tax_class(fromDictionary: item)
               pos.deleted = false
               pos.dbClass?.insertId = true
               pos.save(temp: temp)
           }
       }
       
    
    static func getAll() ->  [[String:Any]] {
         
         let cls = account_tax_class(fromDictionary: [:])
         let arr  = cls.dbClass!.get_rows(whereSql: "")
         return arr
         
     }
        static func getAll() ->  [account_tax_class] {
 
            
              let cls = account_tax_class(fromDictionary: [:])
              let arr  = cls.dbClass!.get_rows(whereSql: "")
            
            var list  : [account_tax_class] = []
            
            for item in arr
            {
                let cls:account_tax_class = account_tax_class(fromDictionary: item  )
                list.append(cls)
            }
            
            
            return list
        }
    
    
    static func get(tax_id:Int) ->account_tax_class
     {
             var cls = account_tax_class(fromDictionary: [:])
         
         let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id = \(tax_id)")
         if row != nil
              {
          cls = account_tax_class(fromDictionary: row!)
         }
         
         return cls
     }
    
  
    static func get(company_id:Int) ->account_tax_class
     {
             var cls = account_tax_class(fromDictionary: [:])
         
         let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where company_id = \(company_id)")
         if row != nil
              {
          cls = account_tax_class(fromDictionary: row!)
         }
         
         return cls
     }
    
 
}
