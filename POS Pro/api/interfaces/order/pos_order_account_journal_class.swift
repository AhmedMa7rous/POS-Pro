//
//  pos_order_account_journal.swift
//  pos
//
//  Created by Khaled on 4/23/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class pos_order_account_journal_class: NSObject {
    var dbClass:database_class?

    var id:Int?
    var order_id:Int?
    var account_Journal_id:Int = 0
    var due:Double?
    var tendered:String?
    var changes:Double?
    var rest:Double?
    var mean_code:PAYMENT_MEANS_CODE?

    
    override init() {
        
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        order_id = dictionary["order_id"] as? Int ?? 0
        account_Journal_id = dictionary["account_Journal_id"] as? Int ?? 0
        due = dictionary["due"] as? Double ?? 0
        tendered = dictionary["tendered"] as? String ??  ""
        changes = dictionary["changes"] as? Double ?? 0
        rest = dictionary["rest"] as? Double ?? 0
        mean_code = PAYMENT_MEANS_CODE(rawValue:  dictionary["mean_code"] as? Int ?? 10)

         
        dbClass = database_class(table_name: "pos_order_account_journal", dictionary: self.toDictionary(),id: id!,id_key:"id")
        
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["order_id"] = order_id
        dictionary["account_Journal_id"] = account_Journal_id
        dictionary["due"] = due
        dictionary["tendered"] = tendered
        dictionary["changes"] = changes
        dictionary["rest"] = rest
        dictionary["mean_code"] = mean_code?.rawValue ?? 10

        
        
        
        return dictionary
    }
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id!
        dbClass?.insertId = false
        _ =  dbClass!.save()
        
        
    }
    
    
    static func get(order_id:Int) ->  [pos_order_account_journal_class]?
    {
        
        let cls = pos_order_account_journal_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where order_id =\(order_id)")
        
        if arr.count == 0
        {
            return nil
        }
        
        
        var list_products : [pos_order_account_journal_class] = []
        
        for item in arr
        {
            let cls:pos_order_account_journal_class = pos_order_account_journal_class(fromDictionary: item  )
            list_products.append(cls)
        }
        
        
        return list_products
    }
    
    
}
