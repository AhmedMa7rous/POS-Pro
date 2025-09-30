//
//  api + cloudKitchen.swift
//  pos
//
//  Created by M-Wageh on 13/10/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension api {
    func get_cloud_kitench_product_product(with brand_id:Int, completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        var fields =  [
            "id","display_name","name","variant_names","other_lang_variant_names", "list_price", "lst_price", "standard_price", "categ_id", "pos_categ_id", "taxes_id",
            "barcode", "default_code",  "uom_id", "description_sale", "description",
            "product_tmpl_id","tracking","image_small","currency_id","original_name","is_combo", "product_combo_ids","calories","name_ar","other_lang_name","invisible_in_ui","product_variant_ids","__last_update" ,"active","attribute_names","sequence","attribute_value_ids","type","company_id","calculated_quantity","allow_extra_fees"
        ]
        
        var fillter:[Any] = [["sale_ok","=",true],["available_in_pos","=",true], ["active","=",true] ]
        
        let pos = SharedManager.shared.posConfig()
        if pos.product_restriction_type != ""
        {
            if pos.product_restriction_type != "exclude"
            {
                fillter.append(["product_tmpl_id", "in", pos.product_tmpl_ids])
            }
            else
            {
                fillter.append(["product_tmpl_id", "not in", pos.product_tmpl_ids])
            }
        }
        let exclude_pos_categ_ids = pos.exclude_pos_categ_ids
        let restrict_products = pos.exclude_product_ids
        
        if exclude_pos_categ_ids.count > 0 {
            fillter.append(["pos_categ_id", "not in", exclude_pos_categ_ids])
        }
        if restrict_products.count > 0 {
            fillter.append(["product_tmpl_id", "not in", restrict_products])

        }
        
      if brand_id != 0{
            fields.append("brand_id")
            fillter.append(contentsOf:[[ "pos_categ_id.brand_id","=",brand_id]])
        }

        if pos.exclude_product_ids.count > 0{
            
        }
        
//                var category = ["pos_categ_id", "=", 2] as [Any]
        //        category = ["","",""]
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.product",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": fields,
                    "domain": fillter,
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
            
            
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_cloud_kitench_product_product_\(brand_id)"),header: header, param: param, completion: completion);
        
    }
    func get_cloud_kitench_category(with brand_id:Int, completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        var fields = ["id","name","image","__last_update","sequence","display_name","invisible_in_ui","parent_id","child_id","company_id"]
        var fillter: [Any] = []
        let pos = SharedManager.shared.posConfig()
        let exclude_pos_categ_ids = pos.exclude_pos_categ_ids
        if exclude_pos_categ_ids.count > 0 {
            fillter.append(["id", "not in", exclude_pos_categ_ids])
        }
       if   brand_id != 0{
            fields.append("brand_id")
            fillter.append(contentsOf:[["brand_id","=",brand_id]])
        }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.category",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields":fields ,
                    "domain": fillter,
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context":  get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_cloud_kitench_category_\(brand_id)"),header: header, param: param, completion: completion);
        
    }
}
