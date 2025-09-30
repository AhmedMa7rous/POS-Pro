//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class pos_discount_program_class: NSObject {
    var dbClass:database_class?

    var id : Int = 0
    var amount : Double = 0

    var display_name : String = ""
  var name : String = ""

     var __last_update : String = ""
    var dicount_type : String = ""

    
    var customer_restricted : Bool = false

    
   var discount_product : pos_order_line_class?
    {
        get
        {
            return pos_discount_program_class.get_discount_product()
        }
        
        
    }
    var deleted : Bool = false

    override init()
    {
        
        
    }
    

      init(fromDictionary dictionary: [String:Any]){
          super.init()

           id = dictionary["id"] as? Int ?? 0
          

          amount = dictionary["amount"] as? Double ?? 0

          display_name = dictionary["display_name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        dicount_type = dictionary["dicount_type"] as? String ?? ""
        if dicount_type.isEmpty
        {
            dicount_type = dictionary["discount_type"] as? String ?? ""

        }

        customer_restricted = dictionary["customer_restricted"] as? Bool ?? false

    
        dbClass = database_class(table_name: "pos_discount_program", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    
      func toDictionary() -> [String:Any]
        {
           var dictionary:[String:Any] = [:]
            
            dictionary["id"] = id
            dictionary["amount"] = amount
            dictionary["display_name"] = display_name
            dictionary["__last_update"] = __last_update

            dictionary["name"] = name
            dictionary["dicount_type"] = dicount_type
        dictionary["customer_restricted"] = customer_restricted
            dictionary["deleted"] = deleted


        
            
            return dictionary
        }
    
    
    static func reset(temp:Bool = false)
    {
        let cls = pos_discount_program_class(fromDictionary: [:])
        
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
                let pos = pos_discount_program_class(fromDictionary: item)
                pos.deleted = false
                pos.dbClass?.insertId = true
                pos.save(temp: temp)
            }
        }
    
    static func getAll(delet:Bool? = nil) ->  [[String:Any]] {
                       
                         let cls = pos_discount_program_class(fromDictionary: [:])
        var sql = " where customer_restricted =0"
        if let delet = delet {
            sql += " and deleted = \(delet ? 1:0)"
        }
                         let arr  = cls.dbClass!.get_rows(whereSql: sql)
                        return arr
       
         }
    
    static func get(id:Int) ->pos_discount_program_class
              {
               
               let cls = pos_discount_program_class(fromDictionary: [:])
               let dic  = cls.dbClass!.get_row(whereSql: " where id = " + String(id)  ) ?? [:]
                          
               return pos_discount_program_class(fromDictionary: dic)
              }
       
     
 static  func get_discount_product() -> pos_order_line_class?
    {
        let pos = SharedManager.shared.posConfig()
        let product = product_product_class.get(id: pos.discount_program_product_id!)
        
        if product != nil
        {
            let line = pos_order_line_class(fromDictionary: [:])
            line.product = product
            line.discount_display_name = product?.display_name ?? ""
            return line
        }
        
//
//        if (pos.discount_program_product_id != nil)
//        {
//            //            let discount_program_product_id = pos.discount_program_product_id[0] as? Int ?? 0
//
//            for item in org_list_product
//            {
//                let product = pos_order_line_class(fromDictionary: item as! [String : Any])
//
//                if product.id == pos.discount_program_product_id
//                {
//                    return product
//                }
//
//            }
//
//        }
        
        
        return nil
    }
         

}
