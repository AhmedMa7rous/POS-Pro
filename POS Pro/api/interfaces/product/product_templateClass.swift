//
//  product_templateClass.swift
//  pos
//
//  Created by Khaled on 2/2/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_templateClass: NSObject {

    public var id : Int   = 0
    public var name : String = ""
    public var display_name : String = ""
    var product_variant_ids : [Int] = []
    
    
     
       init(fromDictionary dictionary: [String:Any]) {

           id = dictionary["id"] as? Int ?? 0
           name = dictionary["name"] as? String ?? ""
           display_name = dictionary["display_name"] as? String ?? ""
           product_variant_ids = dictionary["product_variant_ids"] as? [Int] ?? []
 
            
           
       }

       public func toDictionary() -> [String:Any] {

           var dictionary:[String:Any] = [:]
            dictionary["id"] = self.id
           dictionary["name"] = self.name
           dictionary["display_name"] = self.display_name
           dictionary["product_variant_ids"] = self.product_variant_ids
      

           return dictionary
       }
       
    
    
}
