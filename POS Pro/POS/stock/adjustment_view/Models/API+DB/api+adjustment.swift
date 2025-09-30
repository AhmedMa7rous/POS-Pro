//
//  api+adjustment.swift
//  pos
//
//  Created by M-Wageh on 01/09/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
extension api {
    func hitAddLinesToAdjustmentAPI(for stockMoveID:Int,with productUpdated:[[Any]], completion: @escaping (_ result: api_Results) -> Void)  {
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
                
                "model": "stock.inventory.line",
                    "method": "create",
                       "args": productUpdated,
                       "kwargs": [
                           "context": get_context(display_default_code: true)
                       ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"Add_Lines_To_Adjustment"),header: header, param: param, completion: completion);
        
    }
    func hitStartInventoryAPI(for stockMoveID:Int, completion: @escaping (_ result: api_Results) -> Void)  {
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
                
                "model": "stock.inventory",
                  "method": "action_start",
                       "args": [[
                        stockMoveID
                        ]
                       ],
                "kwargs": [
                    "context": get_context()
                ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"start_Stock_Inventory"),header: header, param: param, completion: completion);
        
    }
    func hitCancelInventoryAPI(for stockMoveID:Int, completion: @escaping (_ result: api_Results) -> Void)  {
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
                
                "model": "stock.inventory",
                    "method": "action_cancel_draft",
                       "args": [[
                        stockMoveID
                        ]
                       ],
                "kwargs": [
                    "context": get_context()
                ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"Cancel_Stock_Inventory"),header: header, param: param, completion: completion);
        
    }
    func hitUpdateQtyAndValidateInventoryAPI(for stockMoveID:Int,with productUpdated:[[String:Any]], completion: @escaping (_ result: api_Results) -> Void)  {
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
                
                "model": "stock.inventory",
                   "method": "ios_update_validate",
                       "args": [[
                        stockMoveID
                        ]
                       ],
                       "kwargs": [
                           "lines" : productUpdated,
                           "context": get_context()
                       ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"update_qty_and_validate"),header: header, param: param, completion: completion);
        
    }
    func hitInventoryLinesAPI(for id:Int, completion: @escaping (_ result: api_Results) -> Void)  {
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
                "model": "stock.inventory.line",
                   "method": "search_read",
                "args": [],
                "kwargs": [
                "fields": ["product_id","product_uom_id","location_id","prod_lot_id","theoretical_qty","product_qty","product_qty_uom","uom_id"],
                    "domain": [["inventory_id", "=", id]],
                "context": get_context(display_default_code: true)
                ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_operation_lines"),header: header, param: param, completion: completion);
        
    }
    func hitInventoryLinesAPI(for Lines:[Int], completion: @escaping (_ result: api_Results) -> Void)  {
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
                "model": "stock.inventory.line",
                   "method": "search_read",
                "args": [],
                "kwargs": [
                "fields": ["product_id","product_uom_id","location_id","prod_lot_id","theoretical_qty","product_qty"],
                    "domain": [["id", "in", Lines]],
                "context": get_context(display_default_code: true)
                ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_operation_lines"),header: header, param: param, completion: completion);
        
    }

func hitGetInventoryAPI(for state:String?,with Offset:Int, completion: @escaping (_ result: api_Results) -> Void)  {
    if !NetworkConnection.isConnectedToNetwork()
    {
        completion(api_Results.getFailOffline())
        return
    }
    guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
    guard let  stock_location_id = pos_config_class.getDefault().stock_location_id else {return}
    var domainParam:[Any] = []
    domainParam.append(["location_ids", "=", stock_location_id])
    if let state = state , !state.isEmpty{
        domainParam.append(["state","in",[state]])
    }
    let param:[String:Any] = [
        "jsonrpc": "2.0",
        "method": "call",
        "id": 1,
        "params": [
            "model": "stock.inventory",
               "method": "search_read",
            "args": [],
            "kwargs": [
            "fields": [
                "id", "name", "display_name", "date","line_ids", "move_ids", "state", "location_ids",
                "product_ids", "select_by", "category_ids","create_uid", "create_date",
                "write_uid","write_date", "__last_update","sequence"
                ],
                "domain":domainParam,
                "order":"date desc, id desc",
                "offset": Offset,
                "limit": 40,
            "context": get_context(display_default_code: true)
            ]
          ]
    ]
    
    let Cookie = api.get_Cookie()
    
    let header:[String:String] = [
        "Cookie" :  Cookie
    ]
    callApi(url: url,keyForCash: getCashKey(key:"get_inventory"),header: header, param: param, completion: completion);
    
}
}
