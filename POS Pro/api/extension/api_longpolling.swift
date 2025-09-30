//
//  api_longpolling.swift
//  pos
//
//  Created by Khaled on 2/22/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

extension api {

    func longpolling_poll(pos_id:Int, last_id:Int , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/longpolling/poll") else { return }
        let database = SharedManager.shared.getNameDB() ?? "" // cash_data_class.get(key: "api_Database") ?? ""

        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "params": [
                "channels": [
                    "[\"\(database)\",\"pos.longpolling\",\"\(pos_id)\"]",
                    "[\"\(database)\",\"pos.multi_session\",\"\(pos_id)\"]"
                ],
                "last": last_id
            ],
            "id": 1
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"longpolling_poll"),header: header, param: param, completion: completion);
        
    }
    
    func get_run_id_poll( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let multi_session_id  = SharedManager.shared.posConfig().multi_session_id ?? 0

        
        let param:[String:Any] = [
              "jsonrpc": "2.0",
              "method": "call",
              "id": 1,
              "params": [
                "model": "pos.multi_session",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["id", "run_ID"],
                    "domain": [["id","=",multi_session_id]],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context":  get_context()
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"longpolling_run_id"),header: header, param: param, completion: completion);
        
    }
    func pos_multi_session_ping ( completion: @escaping (_ result: api_Results) -> Void)  {
             
             guard let url = URL(string:"\(domain)/pos_longpolling/update") else { return }
             
             let database = SharedManager.shared.getNameDB() ?? ""
             
          
      
    
          let pos = SharedManager.shared.posConfig()
           
          let pos_id  = pos.id
          
 
             let param:[String:Any] = [
                   "jsonrpc": "2.0",
                    "method": "call",
                    "params": [
                        "message": "PING",
                        "pos_id": pos_id,
                        "db_name": "\(database)"
                    ],
                    "id": 1
             ]
             
             let Cookie = api.get_Cookie()
             
             let header:[String:String] = [
                 "Cookie" :  Cookie
             ]
             
             callApi(url: url,keyForCash: getCashKey(key:"longpolling_ping"),header: header, param: param, completion: completion);
             
  }
    
    func pos_multi_session_sync_all(  poll:pos_multi_session_sync_class, uid:String? ,completion: @escaping (_ result: api_Results) -> Void)  {
           
           guard let url = URL(string:"\(domain)/pos_multi_session_sync/update") else { return }
           
           let database = SharedManager.shared.getNameDB() ?? ""
           
//          database = "primos.rabeh.io"
        
        
        // get only order with in last day
        let setting = SharedManager.shared.appSetting()
        let last_create_date = Date().add(days: -1 * Int(setting.multisession_get_last_create_order_days))?.toString(dateFormat: baseClass.date_fromate_satnder, UTC: false) ?? ""
        
    
  
        let pos = SharedManager.shared.posConfig()
           let multi_session_id  = pos.multi_session_id ?? 0
        let pos_id  = pos.id
        
        let user_id = SharedManager.shared.activeUser().id
        var message:[String:Any] =  [
    "action": "sync_all",
    "data": [
     "run_ID": poll.run_ID!,
        "pos_id": pos_id,
        "nonce": "l2uoaf"
    ],
    "immediate_rerendering": true,
    "session_id": 0,
    "login_number": 0,
    "last_create_date" : last_create_date
]
        if let uid = uid {
            message =  [
                "action": "sync_all",
                "uid":uid,
                "data": [
                 "run_ID": poll.run_ID!,
                    "pos_id": pos_id,
                    "nonce": "l2uoaf"
                ],
                "immediate_rerendering": true,
                "session_id": 0,
                "login_number": 0,
                "last_create_date" : last_create_date
            ]
        }

           let param:[String:Any] = [
                 "jsonrpc": "2.0",
               "method": "call",
               "params": [
                   "multi_session_id": multi_session_id,
                   "message":message,
                   "dbname": "\(database)",
                   "user_ID": user_id
               ],
               "id": 1
           ]
           
           let Cookie = api.get_Cookie()
           
           let header:[String:String] = [
               "Cookie" :  Cookie
           ]
           
           callApi(url: url,keyForCash: getCashKey(key:"longpolling_sync_all"),header: header, param: param, completion: completion);
           
       }
    
    func pos_multi_session_sync_update(order:pos_order_class ,  poll:pos_multi_session_sync_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/pos_multi_session_sync/update") else { return }
        
        let database = SharedManager.shared.getNameDB() ?? ""
        
     
 
        let data:[String:Any] = pos_order_builder_class.bulid_order_data(order: order, for_pool: poll)
        
        
        let multi_session_id  = SharedManager.shared.posConfig().multi_session_id ?? 0
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "params": [
                "multi_session_id": multi_session_id,
                "message": [
                    "action": "update_order",
                    "pos_config_id":SharedManager.shared.posConfig().id,
                    "data": data
                ],
                "dbname": database,
                "user_ID": order.user_id!,
                "user_id": SharedManager.shared.getCashDomainUserId()
            ],
            "id": 1
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"longpolling_update"),header: header, param: param, completion: completion);
        
    }
 
    func pos_multi_session_sync_remove(order:pos_order_class ,  poll:pos_multi_session_sync_class , completion: @escaping (_ result: api_Results) -> Void)  {
           
           guard let url = URL(string:"\(domain)/pos_multi_session_sync/update") else { return }
           
           let database = SharedManager.shared.getNameDB() ?? ""
            
           let multi_session_id  = SharedManager.shared.posConfig().multi_session_id ?? 0
           
           let param:[String:Any] = [
               "jsonrpc": "2.0",
               "method": "call",
               "params": [
                   "multi_session_id": multi_session_id,
                   "message": [
                       "action": "remove_order",
                       "pos_config_id":SharedManager.shared.posConfig().id,
                       "data": [
                        "uid": order.uid!,
                        "revision_ID": poll.revision_ID!,
                        "run_ID": poll.run_ID!,
                        "pos_id": order.pos_id!,
                        "nonce": poll.nonce()
                       ]
                   ],
                   "dbname": database,
                   "user_ID": order.user_id!
               ],
               "id": 1
           ]
           
           let Cookie = api.get_Cookie()
           
           let header:[String:String] = [
               "Cookie" :  Cookie
           ]
           
           callApi(url: url,keyForCash: getCashKey(key:"longpolling_remove"),header: header, param: param, completion: completion);
           
       }
    
    
    
}
