//
//  api_promotion.swift
//  pos
//
//  Created by Khaled on 7/6/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

extension api {
    
    
    func  pos_conditions( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.conditions",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [
                    ],
                      "domain": [fillter_date() ],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "pos_conditions"),header: header, param: param, completion: completion);
        
    }
    
    
    func  pos_promotion( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.promotion",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [["active","=",true],fillter_date()],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "pos_promotion"),header: header, param: param, completion: completion);
        
    }
    
    
    func  day_week( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "day.week",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [fillter_date()],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "day_week"),header: header, param: param, completion: completion);
        
    }
    
    
    func  get_discount( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "get.discount",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [
                    ],
                    "domain": [fillter_date()],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_discount"),header: header, param: param, completion: completion);
        
    }
    
    
    func  quantity_discount( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "quantity.discount",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [
                    ],
                    "domain": [fillter_date()],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "quantity_discount"),header: header, param: param, completion: completion);
        
    }
    
    func  quantity_discount_amt( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "quantity.discount.amt",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [
                    ],
                    "domain": [fillter_date()],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "quantity_discount_amt"),header: header, param: param, completion: completion);
        
    }
    
    
    func  discount_multi_products( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "discount.multi.products",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [
                    ],
                    "domain": [fillter_date()],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "discount_multi_products"),header: header, param: param, completion: completion);
        
    }
    
    func  discount_multi_categories( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "discount.multi.categories",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [
                    ],
                    "domain": [fillter_date()],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "discount_multi_categories"),header: header, param: param, completion: completion);
        
    }
    
    func  discount_above_price( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "discount.above.price",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [
                    ],
                    "domain": [fillter_date()],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "discount_above_price"),header: header, param: param, completion: completion);
        
    }
    
}
