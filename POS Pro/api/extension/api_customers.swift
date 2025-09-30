//
//  api_customers.swift
//  pos
//
//  Created by khaled on 18/07/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

extension api {
    func create_pos_product_void(products:[pos_product_void] , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let args = products.map(){$0.toDictionary()}
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.product.void",
                "method": "create",
                "args" : [args
                         ],
                "kwargs":[
                    "context": get_context()
                ]
//                "context":get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"create_pos_product_void"),header: header, param: param, completion: completion);
        
    }
    
    func create_customer(customer:res_partner_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        var paramBody:[String:Any] = [
            "name" : customer.name,
            "street" : customer.street,
            "city" : customer.city,
            "zip" : customer.zip,
//                    "country_id" : customer.country_Id,
            "email" : customer.email,
            "phone" : customer.phone,
            "barcode" : customer.barcode,
            "vat" : customer.vat,
            "property_product_pricelist" : 1
            
            ]
        if customer.parent_id != 0{
            paramBody["parent_id"] = customer.parent_id
        }
        if customer.pos_delivery_area_id != 0{
            paramBody["pos_delivery_area_id"] = customer.pos_delivery_area_id
        }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.customer",
                "method": "create",
                "args" : [
                    paramBody
                ],
                "kwargs":[
                    "context": get_context()

                ]
//                "context":get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"create_customer_\(customer.name)"),header: header, param: param, completion: completion);
        
    }
    
    
    func update_customer(customer:res_partner_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw/res.partner/write") else { return }
        var paramBody:[String:Any] = [
            "name" : customer.name,
            "street" : customer.street,
            "city" : customer.city,
            "zip" : customer.zip,
            "email" : customer.email,
            "phone" : customer.phone,
            "barcode" : customer.barcode,
            "vat" : customer.vat
            ]
        if customer.parent_id != 0{
            paramBody["parent_id"] = customer.parent_id
        }
        if customer.pos_delivery_area_id != 0{
            paramBody["pos_delivery_area_id"] = customer.pos_delivery_area_id
        }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.customer",
                "method": "write",
                "args" : [
                    [customer.id]
                    ,
                    paramBody
                    ],
                "kwargs":[
                    "context": get_context()

                ]
             ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"create_customer_\(customer.name)"),header: header, param: param, completion: completion);
        
    }
    
    func update_customer(customers:[res_partner_class] , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw/res.partner/write") else { return }
        var paramBodyArray:[Any] = []
        customers.forEach { customer in
            var paramBody:[String:Any] = [
                "name" : customer.name,
                "street" : customer.street,
                "city" : customer.city,
                "zip" : customer.zip,
                "email" : customer.email,
                "phone" : customer.phone,
                "barcode" : customer.barcode,
                "vat" : customer.vat
            ]
            if customer.parent_id != 0{
                paramBody["parent_id"] = customer.parent_id
            }
            if customer.pos_delivery_area_id != 0{
                paramBody["pos_delivery_area_id"] = customer.pos_delivery_area_id
            }
            paramBodyArray.append([customer.id])
            paramBodyArray.append(paramBody)
        }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.customer",
                "method": "write",
                "args" : paramBodyArray,
                "kwargs":[
                    "context": get_context()

                ]
             ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"update_customer_customers"),header: header, param: param, completion: completion);
        
    }
    func get_customer_by_phone(phone:String, completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let company_id = SharedManager.shared.posConfig().company_id

        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.customer",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": self.getFieldsPosCustomer(),
                    "domain": [[ "company_id","=",company_id!],["phone","=",phone]],
                    "offset": 0,
                    "limit": false,
                    "context": get_context(extra_fields: ["pos_delivery_area_id"])

                ]
//                "context":  get_context()
            ]
            
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_customer_by_phone"),header: header, param: param, completion: completion);
        
    }
    
    func get_customer_by_id(id:Int, completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let company_id = SharedManager.shared.posConfig().company_id

        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.customer",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields":self.getFieldsPosCustomer(),
                    "domain": [ "|",[ "company_id","=",false] ,[ "company_id","=",company_id!],["id","=",id]],
                    "offset": 0,
                    "limit": false,
                    "context": get_context(extra_fields: ["pos_delivery_area_id"])

                ]
//                "context":  get_context()
            ]
            
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_customer_by_id"),header: header, param: param, completion: completion);
        
    }
    
    
    func get_customers( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
       let company_id = SharedManager.shared.posConfig().company_id
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.customer",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": self.getFieldsPosCustomer(),
                    "domain": [
//                        ["customer","=",true],
//                        ["pos_customer","=",true],
                        
                        fillter_date(),
                        "|",
                        [ "company_id","=",false],
                        [ "company_id","=",company_id!]
                  ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context(extra_fields: ["pos_delivery_area_id"])

                ]
//                "context": get_context()
            ]
            
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_customers"),header: header, param: param, completion: completion);
        
    }
    
}
