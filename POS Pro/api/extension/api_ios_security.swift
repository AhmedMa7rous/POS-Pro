//
//  api_ios_security.swift
//  pos
//
//  Created by Khaled on 1/24/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
 

extension api {

    func create_rules(  completion: @escaping (_ result: api_Results) -> Void)  {
        let rules_list = rules.list
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "ios.role",
                "method": "create_from_ios",
                "args" : [ rules_list ] ,
                "kwargs":[
                    "context": get_context()

                ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"create_rules"),header: header, param: param, completion: completion);
        
    }
    
    func get_rules(  completion: @escaping (_ result: api_Results) -> Void)  {
 
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "ios.role",
                "method": "search_read",
                "args" : [  ] ,
                "kwargs":[
                    "fields": ["id", "name", "key","other_lang_name" ,"description","default_value"],
                    "context": get_context()

                ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_rules"),header: header, param: param, completion: completion);
        
    }
    
    func get_groups(  completion: @escaping (_ result: api_Results) -> Void)  {
 
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "ios.group",
                "method": "search_read",
                "args" : [  ] ,
                "kwargs":[
                    "fields": ["id","name", "pos_user_ids","role_ids" ],
                    "context": get_context()

                ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_groups"),header: header, param: param, completion: completion);
        
    }
    
    
    
}
