//
//  StockRequestOrderModel.swift
//  pos
//
//  Created by M-Wageh on 19/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class StockRequestOrderModel {
    var picking_policy:String?
    var pos_config_id: Int?
    var company_id: Int?
    var expected_date:String?
    var stock_request_ids:[[Any]] = []
    func toDictionary() -> [String:Any]?{
        guard let picking_policy = picking_policy,
              let pos_config_id = pos_config_id,
              let company_id = company_id,
              let expected_date = expected_date
              else { return nil }
        return [
            "picking_policy": picking_policy,
            "pos_config_id": pos_config_id,
            "company_id": company_id,
            "expected_date": expected_date,
            "stock_request_ids":stock_request_ids
        ]
    }
    init(with items: [StorableItemModel],expectedDate:String){
        let posID = SharedManager.shared.posConfig().id
        let compangID = SharedManager.shared.posConfig().company_id
        picking_policy = "direct"
        pos_config_id = posID
        company_id = compangID
        expected_date = expectedDate
        
        stock_request_ids.removeAll()
        items.forEach { (item) in
            let param = [
                "expected_date": expectedDate,
                "pos_config_id" : posID,
                "product_id": item.id ?? 0,
                "product_uom_qty": item.qty,
                "product_uom_id": Int(item.select_uom_id.first ?? "0") ?? 0
            ] as [String : Any]
            stock_request_ids.append([0,0,param])
    }
    }
    
}

/**
 {
   "jsonrpc": "2.0",
   "method": "call",
   "id": 1,
   "params": {
     "model": "stock.request.order",
     "method": "create",
     "args": [
             [
                 {
                     "picking_policy" : "direct",
                     "pos_config_id" : 18,
                     "company_id": 1,
                     "expected_date": "2022-05-17 16:07:10",
                     "stock_request_ids": [
                     [
                         0,0,
                         {
                             "pos_config_id" : 18,
                             "product_id" : 27,
                             "product_uom_id" : 46,
                             "product_uom_qty" : 5,
                             "expected_date": "2022-05-17 16:07:10"
                         }
                     ],[
                         0,0,
                         {
                             "pos_config_id" : 18,
                             "product_id" : 27,
                             "product_uom_id" : 46,
                             "product_uom_qty" : 5,
                             "expected_date": "2022-05-17 16:07:10"
                         }
                     ]
                     ]
                 }
             ]
             ],
     "kwargs": {},
     "context":  {
         "lang": "en_US",
         "tz": "Europe/Brussels",
         "uid": 1
     }
   }
 }
 
 */
