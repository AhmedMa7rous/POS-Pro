//
//  shiftClass.swift
//  pos
//
//  Created by khaled on 11/12/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation
class discountProgramClass: NSObject {
    
    var id : Int = 0
    var name: String = ""
    var dicount_type: String = ""
    var amount : Double  = 0
    
    var discount_product : productClass?

    

    
    override init() {
        super.init()
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        dicount_type = dictionary["dicount_type"] as? String ?? ""
        amount = dictionary["amount"] as? Double ?? 0
   
        let discount_product_dic = dictionary["discount_product"]
        if discount_product_dic != nil
        {
            discount_product = productClass(fromDictionary: discount_product_dic as! [String : Any])
        }
 
        
    }
    
    func toDictionary() -> [String:Any]
    {
        
        var dictionary = [String:Any]()
        
         dictionary["id"] = id
        dictionary["name"] = name
        dictionary["dicount_type"] = dicount_type
        dictionary["amount"] = amount
   
 
        if discount_product != nil
        {
            dictionary["discount_product"] = discount_product?.toDictionary()

        }

        
 
        
        return dictionary
        
    }
    
}
