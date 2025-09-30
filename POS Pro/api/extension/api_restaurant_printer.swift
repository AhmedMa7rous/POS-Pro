//
//  api_restaurant_printer.swift
//  pos
//
//  Created by khaled on 22/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//


import Foundation

extension api {
    
    func get_pos_printers(printer_ids:[Int] , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        var filter:[Any] = [fillter_date()]
        if printer_ids.count > 0 {
            filter.append("|")
            filter.append(["id", "in", printer_ids])
        }
        let available_in_pos = SharedManager.shared.posConfig().id 
        filter.append(["available_in_pos","in",[available_in_pos]])

     
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "restaurant.printer",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": filter,
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
        
        callApi(url: url,keyForCash: getCashKey(key:"get_pos_printers"),header: header, param: param, completion: completion);
        
    }

    
    func create_restaurant_printer( printer:restaurant_printer_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw/restaurant.printer/create") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "restaurant.printer",
                "method": "create",
                "args": [[
                    "name": printer.name,
                    "printer_type": "iot",
                    "printer_ip": printer.printer_ip,
                    "epson_printer_ip": false,
                    "company_id": printer.company_id,
                    "proxy_ip": false,
                    "mac_address":  printer.mac_address ?? "",
                    "product_categories_ids": [  [  6,  false,  printer.product_categories_ids ] ],
                    "order_type_ids": [   [ 6,  false, printer.order_type_ids  ]  ],
                    "config_ids": [  [   6,  false, printer.config_ids  ]  ],
                    "connection_type": printer.connectionType?.getConnectionTypeForAPI() ?? "wifi"
                ]],
                "kwargs":[
                    "context": get_context()
 
                ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"restaurant_printer"),header: header, param: param, completion: completion);
        
    }
    func new_create_restaurant_printer( printer:restaurant_printer_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw/restaurant.printer/create") else { return }
        let pos_id = SharedManager.shared.posConfig().id
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "restaurant.printer",
                "method": "create",
                "args": [[
                    "model":printer.model ?? "",
                    "type":printer.type.valueForAPI(),
                    "available_in_pos":pos_id,
                    "brand":printer.brand ?? "",
                    "name": printer.name,
                    "printer_ip": printer.printer_ip,
                    "company_id": printer.company_id,
                    "mac_address":  printer.mac_address ?? "",
                    "connection_type": printer.connectionType?.getConnectionTypeForAPI() ?? "wifi",

                    "product_categories_ids": [  [  6,  false,  printer.product_categories_ids ] ],
                    "order_type_ids": [   [ 6,  false, printer.order_type_ids  ]  ]
                ]],
                "kwargs":[
                    "context": get_context()
 
                ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"new_create_restaurant_printer"),header: header, param: param, completion: completion);
        
    }
    func new_write_restaurant_printer( printer:restaurant_printer_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw/restaurant.printer/write") else { return }
        let printerID = (printer.server_id ?? 0) == 0 ? printer.id : printer.server_id
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "restaurant.printer",
                "method": "write",
                "args": [
                    [  printerID ],
                    [
                        "name": printer.name,
                        "printer_ip": printer.printer_ip,
                        "brand": printer.brand ?? "",
                        "model": printer.model ?? "",
                        "type" : printer.type.valueForAPI(),
                        "mac_address":  printer.mac_address ?? "",
                        "connection_type": printer.connectionType?.getConnectionTypeForAPI() ?? "wifi",

                        "product_categories_ids": [  [  6,  false,  printer.product_categories_ids ] ],
                        "order_type_ids": [   [ 6,  false, printer.order_type_ids  ]  ],
                    ]
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
        
        callApi(url: url,keyForCash: getCashKey(key:"new_write_restaurant_printer"),header: header, param: param, completion: completion);
        
    }
    func new_delete_restaurant_printer( printer:restaurant_printer_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw/restaurant.printer/unlink") else { return }
        let printerID = (printer.server_id ?? 0) == 0 ? printer.id : printer.server_id

        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "restaurant.printer",
                "method": "unlink",
                "args": [
                    [  printerID ]
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
        
        callApi(url: url,keyForCash: getCashKey(key:"restaurant_printer"),header: header, param: param, completion: completion);
        
    }
    
    func write_restaurant_printer( printer:restaurant_printer_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw/restaurant.printer/write") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "restaurant.printer",
                "method": "write",
                "args": [
                    [  printer.id ],
                    [
                        "printer_ip": printer.printer_ip,
                        "mac_address":  printer.mac_address ?? "",
                        "product_categories_ids": [  [  6,  false,  printer.product_categories_ids ] ],
                        "connection_type": printer.connectionType?.getConnectionTypeForAPI() ?? "wifi",

                        "order_type_ids": [   [ 6,  false, printer.order_type_ids  ]  ],
                        "config_ids": [  [   6,  false, printer.config_ids  ]  ]
                    ]
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
        
        callApi(url: url,keyForCash: getCashKey(key:"restaurant_printer"),header: header, param: param, completion: completion);
        
    }
    
    func delete_restaurant_printer( printer:restaurant_printer_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw/restaurant.printer/unlink") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "restaurant.printer",
                "method": "unlink",
                "args": [
                    [  printer.id ]
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
        
        callApi(url: url,keyForCash: getCashKey(key:"restaurant_printer"),header: header, param: param, completion: completion);
        
    }
    
}
