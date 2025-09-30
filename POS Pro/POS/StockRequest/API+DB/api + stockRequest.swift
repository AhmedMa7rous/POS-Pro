//
//  api + stockRequest.swift
//  pos
//
//  Created by M-Wageh on 19/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension api {
func hitCreateStockRequestAPI(param:[String:Any] , completion: @escaping (_ result: api_Results) -> Void)  {
    if !NetworkConnection.isConnectedToNetwork()
    {
        completion(api_Results.getFailOffline())
        return
    }
    guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
    let param:[String:Any] = [
        "jsonrpc": "2.0",
        "method": "call",
        "id": 1,
        "params":  [
            "model": "stock.request.order",
            "method": "create",
             "args": [
                [
                    param
                ]
             ],
            "kwargs":  [
                "context": get_context()
            ]
        ]
    ]
    
    let Cookie = api.get_Cookie()
    
    let header:[String:String] = [
        "Cookie" :  Cookie
    ]
    callApi(url: url,keyForCash: getCashKey(key:"create_stock_request_order"),header: header, param: param, completion: completion);
    
}
    func hitGetStockRequestOrderAPI(with Offset:Int = 0, completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        let pos_id = SharedManager.shared.posConfig().id
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "stock.request.order",
                "method": "search_read",
                "args": [],
                "kwargs": [
                "fields": [
                    "id","name","expected_date","location_id", "warehouse_id", "stock_request_ids","state"
                    ],
                    "domain": [["pos_config_id","=",pos_id]],
                    "order":"create_date desc, id desc",
                    "offset": Offset,
                    "limit": false,
                "context": get_context(display_default_code: true)
                ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_stock_request_order"),header: header, param: param, completion: completion);
        
    }
    func hitGetStockRequestOrderDetailsAPI(for order_id:Int, completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        let pos_id = SharedManager.shared.posConfig().id
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "stock.request",
                "method": "search_read",
                "args": [],
                "kwargs": [
                "fields": ["id","display_name","order_id","product_id","expected_date","picking_policy","product_uom_qty","qty_in_progress","qty_done","product_uom_id"],
                    "domain": [["order_id","=",order_id]],
                    "order":"expected_date asc, id desc",
                    "offset": 0,
                    "limit": false,
                "context": get_context(display_default_code: true)
                ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_stock_request_order_details"),header: header, param: param, completion: completion);
        
    }
}
