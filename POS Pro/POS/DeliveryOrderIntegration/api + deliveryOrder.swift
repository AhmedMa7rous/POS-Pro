//
//  api + deliveryOrder.swift
//  pos
//
//  Created by M-Wageh on 28/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension api {
  
    func hitUpdateOrderStatusAPI(param:[String:Any] , completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/online_order_status/update") else { return }
        let uid = param["uid"] as? String ?? "uid"
//        let param:[String:Any] = [
//            "jsonrpc": "2.0",
//            "method": "call",
//            "id": 1,
//            "params":  [
////                "model": "stock.inventory",
////                "method": "create",
//                 "args": [
//                    [
//                        param
//                    ]
//                 ],
//                "kwargs":  [
//                    "context": get_context()
//                ]
//            ]
//        ]
//
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"updateOrderStatus_\(uid)"),header: header, param: param, completion: completion);
        
    }
}
