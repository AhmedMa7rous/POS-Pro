//
//  api + app_setting.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/21/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
extension api {
    func hitSetSettingAPI(for name:String, with value:String,completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "ios.settings",
                "method": "set_setting",
                "args": [],
                "kwargs": [
                    "name" : name,
                    "value": value,
                    "pos_id":SharedManager.shared.posConfig().id
                ]
                ,
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_rules"),header: header, param: param, completion: completion);
        
    }
    func hitGetSettingAPI(completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "ios.settings",
                "method": "get_setting",
                "args": [],
                "kwargs": [
                    "pos_id":SharedManager.shared.posConfig().id
                ],
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_rules"),header: header, param: param, completion: completion);
        
    }
    
    func hitCreateGeneralSettingAPI(appSetting:[[String:Any]],completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "ios.settings",
                    "method": "create_setting",
                    "args": [],
                    "kwargs": [
                        "vals_list": appSetting
                    ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"create_setting"),header: header, param: param, completion: completion);
        
    }
}
