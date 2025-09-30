//
//  api_loyalty.swift
//  pos
//
//  Created by khaled on 17/07/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

 
extension api {

    func load_loyalty_config_settings(company_id:Int  , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }

        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "params": [
                "model": "res.company",
                 "method": "load_loyalty_config_settings",
                "args": [], // company id
                "kwargs": [
                 
                    "context": get_context()

                ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"load_loyalty_config_settings"),header: header, param: param, completion: completion);
        
    }
}
