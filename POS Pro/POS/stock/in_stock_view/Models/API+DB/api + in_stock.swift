//
//  api + in_stock.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/17/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
extension api {
    func hitAddOperationLineAPI(operationID:Int,param:[[Any]] , completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": operationID,
            "params":  [
                "model": "stock.picking",
                        "method": "write",
                 "args": [
                    operationID,
                    [
                        "move_lines":  param
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
        callApi(url: url,keyForCash: getCashKey(key:"get_create_operation"),header: header, param: param, completion: completion);
        
    }
    func hitCreateOperationAPI(param:[String:Any] , completion: @escaping (_ result: api_Results) -> Void)  {
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
                "model": "stock.picking",
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
        callApi(url: url,keyForCash: getCashKey(key:"get_create_operation"),header: header, param: param, completion: completion);
        
    }
    func hitGetSelectPickerAPI(for model:String,fields:[String] = [],  with Offset:Int , completion: @escaping (_ result: api_Results) -> Void)  {
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
                "model": model,
                    "method": "search_read",
                    "args": [],
                    "kwargs": [
                        "fields": fields,
                        "domain": [],
                        "context":  get_context(),
                        "offset": Offset,
                        "limit": 40
                    ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_\(model)"),header: header, param: param, completion: completion);
        
    }
    func hitGetAllStorableItemsAPI(with Offset:Int, limit:Int,categID:[Int]?,product_tmpl_id:Int? = nil , completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        var domainFilter:[Any] = [
            ["type", "=", "product"],
            ["active", "=", "true"]
        ]
        if let categID = categID,categID.count > 0 {
            domainFilter.append(["categ_id","in",categID])
        }
        if let product_tmpl_id = product_tmpl_id,product_tmpl_id >=  0 {
            domainFilter.append(["product_tmpl_id","in",[product_tmpl_id]])
        }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params":  [
                "model": "product.product",
                    "method": "search_read",
                    "args": [],
                    "kwargs": [
                    "fields": [
                        "id","display_name","name","tracking", "categ_id", "barcode", "default_code", "uom_id","uom_category_id", "product_tmpl_id","inv_uom_id","uom_po_id"
                        ],
                        "domain":domainFilter,
                        "offset": Offset,
                        "limit": limit,
                    "context":  get_context(display_default_code: true)

                    ],
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_all_storable_items"),header: header, param: param, completion: completion);
        
    }
    func hitUpdateQtyAndValidateAPI(for stockMoveID:Int,with productUpdated:[[String:Any]], completion: @escaping (_ result: api_Results) -> Void)  {
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
                "model": "stock.picking",
                       "method": "ios_update_validate",
                       "args": [
                        stockMoveID
                       ],
                       "kwargs": [
                           "values": productUpdated
                       ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"update_qty_and_validate"),header: header, param: param, completion: completion);
        
    }
    func hitCancelMovementInstockAPI(for stockMoveID:Int, completion: @escaping (_ result: api_Results) -> Void)  {
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
             
                "model": "stock.picking",
                    "method": "action_cancel",
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
        callApi(url: url,keyForCash: getCashKey(key:"cancel_movement_instock"),header: header, param: param, completion: completion);
        
    }
    func hitGetOperationLinesAPI(for Lines:[Int], completion: @escaping (_ result: api_Results) -> Void)  {
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
                "model": "stock.move",
                "method": "search_read",
                "args": [],
                "kwargs": [
                "fields": [
                    "product_id","product_uom_qty","product_uom","quantity_done","inv_uom_id"
                    ],
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
    func hitGetInOperationsAPI(for State:String,with Offset:Int, completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let pos_id = SharedManager.shared.posConfig().id
        var filter:[[Any]] = [["picking_type_id.code", "=", "incoming"]]
        if !State.isEmpty {
            filter.append(["state","in",[State]])
        }
        filter.append(["pos_config_id","=",pos_id])

        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "stock.picking",
                "method": "search_read",
                "args": [],
                "kwargs": [
                "fields": [
                    "id","name","scheduled_date","picking_type_id", "origin","location_id", "location_dest_id", "partner_id", "move_lines","state"
                    ],
                    "domain": filter,
                    //"order":"priority desc, scheduled_date asc, id desc",
                    "order":"create_date desc, id desc",
                    "offset": Offset,
                    "limit": 40,
                "context": get_context()
                ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_in_operations"),header: header, param: param, completion: completion);
        
    }
}
