//
//  api+createAdjustment.swift
//  pos
//
//  Created by M-Wageh on 26/07/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension api {
  
    func hitCreateAdjustmentAPI(param:[String:Any] , completion: @escaping (_ result: api_Results) -> Void)  {
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
        callApi(url: url,keyForCash: getCashKey(key:"create_adjustment"),header: header, param: param, completion: completion);
        
    }
}
