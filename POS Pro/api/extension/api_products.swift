//
//  api_products.swift
//  pos
//
//  Created by Khaled on 8/6/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

extension api {

    func get_product_product( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
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
        
        let pos_categ_ids = SharedManager.shared.pos_categ_ids
        if pos_categ_ids.count > 0 {
            fillter.append(["pos_categ_id", "in", pos_categ_ids])
        }
        
        if restrict_products.count > 0 {
            fillter.append(["product_tmpl_id", "not in", restrict_products])

        }
        if let id_brand = pos.brand_id , id_brand != 0{
            fillter.append(contentsOf:["|",[ "pos_categ_id.brand_id","=",false] ,[ "pos_categ_id.brand_id","=",id_brand]])
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
                    "fields": [
                        "id","display_name","name","variant_names","other_lang_variant_names", "list_price", "lst_price", "standard_price", "categ_id", "pos_categ_id", "taxes_id",
                        "barcode", "default_code",  "uom_id", "description_sale", "description",
                        "product_tmpl_id","tracking","image_small","currency_id","original_name","is_combo", "product_combo_ids","calories","name_ar","other_lang_name","invisible_in_ui","product_variant_ids","__last_update" ,"active","attribute_names","sequence","attribute_value_ids","type","company_id","calculated_quantity","insurance_product","select_weight","allow_extra_fees"
                    ],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_product_product"),header: header, param: param, completion: completion);
        
    }
    
    func fetchProductAvailability(for productsIds: [Int]? = [], completion: @escaping (_ result: api_Results) -> Void) {
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        guard let branchId = SharedManager.shared.posConfig().branch_id else { return }
        //TODO: - fetch product_product  IDS as  params then pass them in Body for  "product_ids"
        //TODO: - if pass wrong product_ids API response
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.product",
                "method": "get_product_qty_with_branch",
                "args": [],
                "kwargs": [
                    "product_ids": productsIds,
                    "branch_id": branchId
                    
                ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        SharedManager.shared.printLog("HEADER: \(header) AND BRANCH: \(branchId)")
        callApi(url: url,keyForCash: getCashKey(key:"get_product_qty_with_branch"),header: header, param: param, completion: completion)
    }
    
    func get_porduct_combo( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.combo",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [fillter_date() ],
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
        
        callApi(url: url,keyForCash: getCashKey(key:"get_porduct_combo"),header: header, param: param, completion: completion);
        
    }
    
    func get_porduct_template( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.template",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["id","name", "display_name", "product_variant_ids","__last_update" ,
                               "valid_product_template_attribute_line_ids",
                             "valid_product_attribute_ids",
                             "valid_product_attribute_value_ids",
                             "optional_product_ids",  "sale_ok","available_in_pos" ,"open_price","storage_unit_qty_available"],
                    "domain": [["sale_ok","=",true],["available_in_pos","=",true],fillter_date() ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context":   get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_porduct_template"),header: header, param: param, completion: completion);
        
    }
    
    func get_product_template_attribute_line( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        
        let fillter = [  fillter_date() ]
        
         
        
        let param:[String:Any] = [
       
              "jsonrpc": "2.0",
              "method": "call",
              "id": 1,
              "params": [
                "model": "product.template.attribute.line",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["product_tmpl_id", "attribute_id", "value_ids"],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_product_template_attribute_line"),header: header, param: param, completion: completion);
        
    }
    
    
    func get_product_template_attribute_value( completion: @escaping (_ result: api_Results) -> Void)  {
           
           guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
           
           
           let fillter = [  fillter_date() ]
           
            
           
           let param:[String:Any] = [
          
                 "jsonrpc": "2.0",
                 "method": "call",
                 "id": 1,
                 "params": [
                   "model": "product.template.attribute.value",
                   "method": "search_read",
                   "args": [],
                   "kwargs": [
                       "fields": ["product_attribute_value_id","product_tmpl_id","attribute_id","price_extra","own_sequence"],
                       "domain": fillter,
                       "offset": 0,
                       "limit": false,
                    "context": get_context()

                   ]
//                   "context":   get_context()
                 ]
               ]
               
         
           
           let Cookie = api.get_Cookie()
           
           let header:[String:String] = [
               "Cookie" :  Cookie
           ]
           
           callApi(url: url,keyForCash:  getCashKey(key: "get_product_template_attribute_value"),header: header, param: param, completion: completion);
           
       }
    
    func get_product_attribute_value( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let fillter = [  fillter_date() ]
        
         
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.attribute.value",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["name", "attribute_id"],
                    "domain":fillter,
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context":   get_context()
            ]
        ]
            
      
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_product_attribute_value"),header: header, param: param, completion: completion);
        
    }
    
    func get_product_attribute( completion: @escaping (_ result: api_Results) -> Void)  {
         
         guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
         
         let fillter = [  fillter_date() ]
         
          
         
         let param:[String:Any] = [
             "jsonrpc": "2.0",
             "method": "call",
             "id": 1,
             "params": [
                 "model": "product.attribute",
                 "method": "search_read",
                 "args": [],
                 "kwargs": [
                     "fields": ["value_ids", "name"],
                     "domain":fillter,
                     "offset": 0,
                     "limit": false,
                    "context": get_context()

                 ]
//                 "context":  get_context()
             ]
         ]
             
       
         
         let Cookie = api.get_Cookie()
         
         let header:[String:String] = [
             "Cookie" :  Cookie
         ]
         
         callApi(url: url,keyForCash:  getCashKey(key: "get_product_attribute"),header: header, param: param, completion: completion);
         
     }
    
    
}
