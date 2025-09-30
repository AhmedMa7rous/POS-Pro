//
//  init_variant.swift
//  pos
//
//  Created by Khaled on 8/7/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
typealias init_variant = combo_vc
extension init_variant
{
    
    
    func load_variant()
    {
        if product_combo?.is_combo_line == true && product_combo?.parent_line_id != 0
        {
            return
        }
        
        get_variant()
        get_variant_selected()
       
    }
    
    func get_variant_selected()
    {
        if product_combo?.combo_edit == false
        {
            return
        }
        
        let varints_list = product_attribute_value_class.get_product_attribute_value(product_id: (product_combo?.product_id)!)

        for row in varints_list
        {
            list_attribute_selected[row.attribute_id_id] = row
        }
        
    }
      
    func get_variant_item_selected() -> product_attribute_value_class?
     {
        let cls =  list_attribute_selected.values.first
        return cls
     }
    
    func get_variant()
    {
        let varints_list = product_attribute_value_class.get_product_attribute_value(product_tmpl_id: (product_combo?.product.product_tmpl_id)!)
               
               for item in varints_list
               {
                   var arr = list_attribute[item.attribute_id_name] ?? []
                   arr.append(item)
                   list_attribute[item.attribute_id_name] = arr
                   
                   
               }
               
               let all_keys = Array( list_attribute.keys).sorted(by: <)
               
          
        
               var index = 0
               for key  in all_keys
               {
                   let sec = section_view.init(index_row:index, title: key, type: .variant)
                   index += 1
                   list_collection_keys.append(sec)
                   
                   // select  first
                   let item = list_attribute[key]?[0]
                   if item != nil
                   {
                       list_attribute_selected[item!.attribute_id_id] = item
                   }
               }
        
        
        
    }
    
    
    func get_protduct_id()-> Int?
    {
        var arr_selected_ids :[Int] = []
        // get ids
        for item in list_attribute_selected
        {
            arr_selected_ids.append(item.value.id)
        }
        
        var items_by_id :[Int:[Int]] = [:]
        if let productTmpID = product_combo?.product.product_tmpl_id {
            let arr = product_attribute_value_class.get_all_attribute_value(product_tmpl_id: productTmpID)
            for row in arr
            {
                let product_id =  row["re_id1"] as? Int ?? 0
                let value_id =  row["re_id2"] as? Int ?? 0
                
                var arr_int = items_by_id[product_id] ?? []
                arr_int.append(value_id)
                items_by_id[product_id]  = arr_int
                
            }
        }
        
        for (key,val) in items_by_id
        {
            if val.sorted() == arr_selected_ids.sorted()
             {
                return key
            }
        }
        
        return nil
        
    }
    
    
}
