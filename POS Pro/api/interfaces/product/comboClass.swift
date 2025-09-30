//
//  product.swift
//  pos
//
//  Created by khaled on 8/15/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class comboClass: NSObject {
    
    var dictionary_values: [String:Any]!

    
    
    var id : Int = 0
    var is_combo : Bool = false
    var require : Bool = false
    var no_of_items : Double = 0

    var app_require : Bool = false
    var app_selected : Bool = false
    
    var product_ids : [Int] = []
    var pos_category_id : [Any] = []
    
    var product_tmpl_id : [Any] = []
    var product_id : [Any] = []
    var extra_price : Double = 0
    var auto_select_num : Double = 0

    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        dictionary_values = dictionary
       

        id = dictionary["id"] as? Int ?? 0
        no_of_items = dictionary["no_of_items"] as? Double ?? 0
        extra_price = dictionary["extra_price"] as? Double ?? 0
        auto_select_num = dictionary["auto_select_num"] as? Double ?? 0


        is_combo = dictionary["is_combo"] as? Bool ?? false
        app_require = dictionary["app_require"] as? Bool ?? false
        app_selected = dictionary["app_selected"] as? Bool ?? false
        require = dictionary["require"] as? Bool ?? false
 
        
        product_ids = dictionary["product_ids"] as? [Int] ?? []
        pos_category_id = dictionary["pos_category_id"] as? [Any] ?? []
//        product_id = dictionary["product_id"] as? [Any] ?? []
        product_tmpl_id = dictionary["product_tmpl_id"] as? [Any] ?? []
 
    }
    
 
    
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()

        dictionary["app_selected"] = app_selected

       dictionary["app_require"] = app_require
        dictionary["require"] = require

     
            dictionary["pos_category_id"] = pos_category_id
      
            dictionary["no_of_items"] = no_of_items
     
            dictionary["is_combo"] = is_combo
        
            dictionary["product_ids"] = product_ids
        
            dictionary["id"] = id
       
        dictionary["product_tmpl_id"] = product_tmpl_id
//        dictionary["product_id"] = product_id
        dictionary["extra_price"] = extra_price
        dictionary["auto_select_num"] = auto_select_num

 
        return dictionary
    }
    
    
    
}

