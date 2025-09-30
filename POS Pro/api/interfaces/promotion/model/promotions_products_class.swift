//
//  promotions_class.swift
//  pos
//
//  Created by khaled on 06/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

enum discount_types:String {
    case
        fixed = "fixed"
        ,percentage = "percentage"
        
}

class  promotions_products_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var promotion_id : Int = 0
 
    var product_x : Int = 0
    
    var operator_x : String = ""
     var quantity_x : Double = 0.0

    
     var product_y : Int = 0
    var operator_y : String = ""
     var quantity_y : Double = 0.0
    
    
     var total : Double = 0.0
    var discount : Double = 0.0
    var discount_type:discount_types = discount_types.fixed
    
    var no_applied : Int = 0

    override init() {
        
    }
   
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        promotion_id = dictionary["promotion_id"] as? Int ?? 0
        product_x = dictionary["product_x"] as? Int ?? 0
        product_y = dictionary["product_y"] as? Int ?? 0

        operator_x = dictionary["operator_x"] as? String ?? ""
        operator_y = dictionary["operator_y"] as? String ?? ""

        quantity_x = dictionary["quantity_x"] as? Double ?? 0
        quantity_y = dictionary["quantity_y"] as? Double ?? 0

        total = dictionary["total"] as? Double ?? 0
        discount = dictionary["discount"] as? Double ?? 0


        no_applied = dictionary["no_applied"] as? Int ?? 0

        discount_type = discount_types.init(rawValue: dictionary["discount_type"] as? String ?? "fixed") ?? .fixed


        dbClass = database_class(table_name: "promotions_products", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
  
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
             dictionary["id"] = id
         dictionary["promotion_id"] = promotion_id
        dictionary["product_x"] = product_x
        dictionary["product_y"] = product_y
        dictionary["operator_x"] = operator_x
        dictionary["operator_y"] = operator_y
        dictionary["quantity_x"] = quantity_x
        dictionary["quantity_y"] = quantity_y
        dictionary["total"] = total
        dictionary["discount"] = discount
        dictionary["no_applied"] = no_applied
        dictionary["discount_type"] = discount_type.rawValue

    
        

        
 
        return dictionary
    }
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
 
        _ =  dbClass!.save()
        
    }
    
    
    
}
