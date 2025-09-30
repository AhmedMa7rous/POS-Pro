//
//  api.swift
//  pos
//
//  Created by khaled on 8/6/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

enum cashStatus
{
    case  useCash, useCash_with_internet , useCash_with_No_internet,
    stopCash, stopCash_with_internet ,stopCash_with_No_internet
}



enum userLogin: String
{
    case username,password,company_id, domain_user_id
}

class api {
    
    //    let domain = getDomain()
    
    var domain:String {
        get{
            return api.getDomain()
        }
    }
    
    var userCash:cashStatus = .useCash
    var timeout: TimeInterval = 0
    
    var lastUpdate:String?
    
 
    
    let rest = RestManager()
    
    
    static func setDomain(url:String)
    {
        
        SharedManager.shared.domain_url = url
        
        cash_data_class.set(key: "domain_domain", value: url)
        //        myuserdefaults.setitems("domain", setValue: url, prefix: "domain")
       SharedManager.shared.printLog("My url")
        SharedManager.shared.printLog(url)
    }
    
    
    static func getDomain() -> String
    {
        var url = defaultDomain  // "http://213.52.130.74" //"http://www.gofekra.com"
        
        if SharedManager.shared.domain_url == nil
        {
            
            //            let vv = myuserdefaults.getitem("domain", prefix: "domain")
            let vv = cash_data_class.get(key: "domain_domain")
            
            let v = vv ?? ""
            //        let test = v
            if v.isEmpty == false
            {
                url = String(v)
            }
            SharedManager.shared.domain_url = url
            
            
        }
        else
        {
            url = SharedManager.shared.domain_url!
        }
        
        
        if url.lowercased().last == "/"
        {
            url.removeLast()
        }
        
        return url
    }
    
    static func saveItem(name:String ,value:String)
    {
        
        cash_data_class.set(key: "api_\(name)", value: value)
        //        myuserdefaults.setitems(name, setValue: value, prefix: "api")
    }
    
    static func getItem(name:String) -> String
    {
        var url = ""
        
        //        let v = myuserdefaults.getitem(name, prefix: "api") as? String ?? ""
        let v = cash_data_class.get(key: "api_\(name)") ?? ""
        
        if v.isEmpty == false
        {
            url = String(v)
        }
        
        return url
    }
    
    
    static func setDatabase(url:String)
    {
        cash_data_class.set(key: "api_Database", value: url)
        //        myuserdefaults.setitems("Database", setValue: url, prefix: "api")
    }
    
    
    static func getDatabase() -> String
    {
        var url = "erp" //"demo"
        
        //        let v = myuserdefaults.getitem("Database", prefix: "api") as? String ?? ""
        let v = SharedManager.shared.getNameDB() ?? ""
        
        if v.isEmpty == false
        {
            url = String(v)
        }
        
        return url
    }
    
    func get_context(display_default_code:Bool = false,extra_fields: [String]? = nil) -> [String:Any] {
        var context: [String:Any] = [:]
        if  LanguageManager.currentLang() == .ar {
            context = [
//                "context":  [
                    "display_default_code": display_default_code,
                    "lang": "ar_001",
                    "tz":  api.get_tz_user(),
                    "uid": api.get_uid_user(),
                    "false_name_ar":true
//                ]
                
            ]
        }
        else
        {
            context = [
//                "context":  [
                    "display_default_code": display_default_code,
                    "lang": "en_US",
                    "tz":  api.get_tz_user(),
                    "uid": api.get_uid_user(),
                    "false_name_ar":true
//                ]
                
            ]
        }
        
        if let extra_fields = extra_fields {
            context["extra_fields"] = extra_fields
        }
        return context
    }
    func callKeyAuthenticate(completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string: "\(domain)/web/session/api_key_authenticate") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "api_key": "gKMFln1avBnYapGmD0cWNTub0MypgPFWRJGmLRbTxe2V8sCMIp0YrYBTYtWGKBmd3DXWAQMobQqtReqb0TZsdg",
                "db": "erp"
            ]
        ]
        let header:[String:String] = [:]
        
        callApi(url: url,keyForCash: getCashKey(key: "key_authenticate") ,header: header, param: param, completion: completion);
    }
    func authenticate( username :String , password : String, dbName:String = "" , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/session/authenticate") else { return }
        SharedManager.shared.updateDBName()
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params":[
                "login": "\(username)",
                "password": "\(password)",
                "db": dbName == "" ? "\(api.getDatabase())" : dbName,
                "context": get_context()
            ]
            
        ]
        
        let header:[String:String] = [:]
        
        callApi(url: url,keyForCash: getCashKey(key: "authenticate") ,header: header, param: param, completion: completion);
        
    }
    
    func get_countries( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        //        var category = ["pos_categ_id", "=", 2] as [Any]
        //        category = ["","",""]
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "res.country",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["id","name", "vat_label","__last_update"],
                    "domain": [fillter_date() ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
            
            
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_countries"),header: header, param: param, completion: completion);
        
    }
    

    
  
    
    func get_drivers( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let company_id = SharedManager.shared.posConfig().company_id

        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.driver",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [
                        "id","name","code","driver_cost"
                    ],
                    "domain": [ fillter_date(),"|",[ "company_id","=",false] ,[ "company_id","=",company_id!] ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
            
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_drivers"),header: header, param: param, completion: completion);
        
    }
    
   
    
    
    func get_session_info( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/session/get_session_info") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": []
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_session_info"),header: header, param: param, completion: completion);
        
    }
    //get_pos_delivery_area
    func get_pos_delivery_area_api( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let filterDomain:[Any] = [fillter_date()]

        let pos = SharedManager.shared.posConfig()
        let fields = ["id","name","delivery_product_id","delivery_amount","display_name","active","__last_update"]
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model" : "pos.delivery.area",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "domain": filterDomain,
                    "fields": fields,
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key: "get_pos_delivery_area"),header: header, param: param, completion: completion);
        
    }
    func get_pos_users( posID :Int , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        var filterDomain:[Any] = [fillter_date()]
        filterDomain.append(["pos_security_pin","!=", false ])
        filterDomain.append(["ios_group_ids","!=", false ])

//        filterDomain.append("|")
//        filterDomain.append(["pos_config_ids", "=", false])
        filterDomain.append(["pos_config_ids", "in",posID ])
//        filterDomain.append("|")
//        filterDomain.append(["active", "=",false ])
//        filterDomain.append(["active", "=",1 ])

        let pos = SharedManager.shared.posConfig()
        let fields:[String] = []
        /*
        var fields = ["id","name", "partner_id", "login", "email",
                      "pos_security_pin","barcode","pos_user_type",
                      "image","pos_config_ids","active","__last_update","company_id"]

        if let _ = pos.brand_id {
            fields.append("brand_ids")
        }
         */

        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model" : "pos.user",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "domain": filterDomain,
                    "fields": fields,
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key: "get_pos_users"),header: header, param: param, completion: completion);
        
    }
    
    func change_pin_code( userid:Int,new_pin :String , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.users",
                "method": "write",
                "args": [
                    userid,
                    [
                        "pos_security_pin": new_pin
                    ]
                ],
                "kwargs": [
                    "context": get_context()
                ]
//                "context":  get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key: "change_pin_code"),header: header, param: param, completion: completion);
        
    }
    
    func get_pos_session_info( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.session",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["id", "journal_ids","name","user_id","config_id","start_at","stop_at","sequence_number","login_number"],
                    "domain": [["state","=","opened"]],
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
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_pos_session_info"),header: header, param: param, completion: completion);
        
    }
    
    func get_last_session( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let pos = SharedManager.shared.posConfig()
        var domain = [["config_id","=", pos.id]]
        if SharedManager.shared.appSetting().use_app_return  {
            domain = [["config_id","=", pos.id],["rescue","=",false]]

        }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.session",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["id", "journal_ids","name","user_id","config_id","start_at","stop_at","sequence_number","login_number", "statement_ids"],
                    "domain": domain ,
                    "order": "id desc",
                    "offset": 0,
                    "limit": 1,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_last_session"),header: header, param: param, completion: completion);
        
    }
    
    
    func get_start_cash_amount(   completion: @escaping (_ result: api_Results) -> Void)  {
        
        let pos = SharedManager.shared.posConfig()
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.config",
                "method": "ios_get_cash_start_balance",
                "args": [pos.id],
                "kwargs":[
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key: "get_start_cash_amount"),header: header, param: param, completion: completion);
        
    }
    
    func create_pos_cash_box(session_id:Int, cashbox :cashbox_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.session",
                "method": "action_pos_cashbox",
                "args": [
                    [session_id],
                    cashbox.cashbox_in_out,
                    cashbox.cashbox_reason,
                    cashbox.cashbox_amount
                ],
                "kwargs": [
                    "context": get_context()

                ]
//                "context" : get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key: "create_pos_cash_box"),header: header, param: param, completion: completion);
        
    }
    
    
    func create_pos_multi_cashbox( order :pos_order_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        
        var lst_cash:[[String:Any]] = []
        let sessionID_server = order.session_id_server
        
        for dic in order.session!.cashbox_list {
            let cash = cashbox_class(fromDictionary: dic as! [String : Any])
            
            let temp = ["session_id":sessionID_server!,"cash_type":  cash.cashbox_in_out,  "reason": cash.cashbox_reason,  "amount":  cash.cashbox_amount] as [String : Any]
            
            lst_cash.append(temp)
            
        }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.session",
                "method": "action_pos_multi_cashbox",
                "args": [
                    lst_cash
                ],
                "kwargs":[
                    "context": get_context()

                ]
//                "context":  get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key: "create_pos_cash_box"),header: header, param: param, completion: completion);
        
    }
    
    
    func get_product_pricelist_item( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }

        var domainParamter:[Any]  = [fillter_date() ]
        let cloudKitchenIDs = SharedManager.shared.posConfig().cloud_kitchen
        if cloudKitchenIDs.count <= 0{
            if let brandID = SharedManager.shared.posConfig().brand_id,brandID != 0 {
                domainParamter =  ["&",fillter_date(),"|",["product_tmpl_id.brand_id","=",brandID],["product_tmpl_id.brand_id","=",false]]
            }
        }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.pricelist.item",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": domainParamter ,
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
        
        
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_product_pricelist_item"),header: header, param: param, completion: completion);
        
    }
    
    static func getCashKey_static(key:String) -> String {
            // log every request
//        let time_now = Date().toString(dateFormat: baseClass.date_formate_database, UTC: true).replacingOccurrences(of: " ", with: "_")
//        return String(format: "%@_%@_%@_%@", api.getDomain() , api.getDatabase() , key,time_now)
        
        // log only last request
        return String(format: "%@_%@_%@", api.getDomain() , api.getDatabase() , key)
    }
    
    func getCashKey(key:String) -> String {
        
        return api.getCashKey_static(key: key)
//        return String(format: "%@_%@_%@", api.getDomain() , api.getDatabase() , key)
        
    }
    
 
    
    func get_product_pricelist( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.pricelist",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [fillter_date() ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_product_pricelist"),header: header, param: param, completion: completion);
        
    }
    
    func get_account_tax( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "account.tax",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [fillter_date() ],
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
        
        callApi(url: url,keyForCash: getCashKey(key:"get_account_tax"),header: header, param: param, completion: completion);
        
    }
    
    
    func get_product_category( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.category",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [],
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
        
        callApi(url: url,keyForCash: getCashKey(key:"get_product_gategory"),header: header, param: param, completion: completion);
        
    }
    
    func get_bank_statements_deprecated( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "account.bank.statement",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["account_id","currency_id","journal_id","state","name","user_id","pos_session_id"],
                    "domain": [["state", "=", "open"]],
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
        
        callApi(url: url,keyForCash: getCashKey(key:"get_bank_statements"),header: header, param: param, completion: completion);
        
    }
    
    func get_account_Journals(journal_ids:[Any] , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "account.journal",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["id","display_name",  "type", "sequence","code", "payment_type", "stc_account_code", "stc_username", "stc_password","stc_test_account_code", "stc_test_username", "stc_test_password","__last_update","image_small"],
                    "domain": [["id", "in", journal_ids],fillter_date() ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_account_Journals"),header: header, param: param, completion: completion);
        
    }
    
    func get_irـtranslation(  completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }

        let param:[String:Any] = [
 
            "jsonrpc": "2.0",
              "method": "call",
              "id": 1,
              "params": [
                "model": "ir.translation",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields" : [ ],
                    "domain": [["name","=","pos.category,name"]],
                    "offset": 0,
                    "limit": false
                ]
              ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_irـtranslation"),header: header, param: param, completion: completion);
        
    }
    
    
    func fillter_date() -> [Any]
    {
//           return ["write_date",">",  "1790-1-1 00:00:00" ]
        return ["write_date",">", self.lastUpdate ?? "1790-1-1 00:00:00" ]
    }
    
    
    func get_pos_category( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        var fillter: [Any] = []
        let pos = SharedManager.shared.posConfig()
        let exclude_pos_categ_ids = pos.exclude_pos_categ_ids
        if exclude_pos_categ_ids.count > 0 {
            fillter.append(["id", "not in", exclude_pos_categ_ids])
        }
        if let id_brand = pos.brand_id, id_brand != 0 {
//            fillter.append(["brand_id", "in", [id_brand]])
            fillter.append(contentsOf:["|",[ "brand_id","=",false] ,[ "brand_id","=",id_brand]])
        }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.category",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["id","name","image","__last_update","sequence","display_name","invisible_in_ui","parent_id","child_id","company_id"],
                    "domain": fillter,
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
        
        callApi(url: url,keyForCash: getCashKey(key:"get_pos_category"),header: header, param: param, completion: completion);
        
    }
    
    func get_databases( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/database/list") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params":[]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_databases"),header: header, param: param, completion: completion);
        
    }
    
    func get_point_of_sale_old( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        /*
         ["name","fb_token","pos_type","exclude_product_ids","available_floors_ids","exclude_pos_categ_ids", "journal_ids", "enable_delivery", "delivery_method_ids", "delivery_method_id", "journal_type_ids", "stock_location_id", "pos_scrap","receipt_header","receipt_footer","company_id","pos_security_pin","groups_id","barcode","pricelist_id","available_pricelist_ids","delivery_method_ids","delivery_method_id","currency_id","allow_discount_program", "available_discount_program_ids", "discount_program_product_id","printer_ids", "allow_free_tax",
                    "pos_promotion", "is_table_management", "floor_ids","product_restriction_type", "product_tmpl_ids", "cash_control","__last_update","multi_session_id","iface_start_categ_id","code","company_id","allow_pin_code", "pin_code","multi_session_accept_incoming_orders","extra_fees","extra_product_id","extra_percentage","logo","brand_id"]
         **/
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.config",
                "method": "search_read",
                "args": [],
                "kwargs": [
 
                    "fields": [],
 
 
                    "domain": [],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_point_of_sale"),header: header, param: param, completion: completion);
        
    }

    func get_point_of_sale(at branchID:Int? = nil, completion: @escaping (_ result: api_Results) -> Void)  {
        var paramterDomain:[Any] = []
        if let branchID = branchID , branchID != 0 {
            paramterDomain = [["brand_id","=",branchID]]
        }
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.config",
                "method": "search_read",
                "args": [],
                "kwargs": [
 
                    "fields": [
                        "id",
                        "name"
                    ],
 
 
                    "domain": paramterDomain,
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_point_of_sale_at_branch"),header: header, param: param, completion: completion);
        
    }
    
    func get_info_point_of_sale(_ domainParamter:[Any], completion: @escaping (_ result: api_Results) -> Void)  {
            guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
            
            let param:[String:Any] = [
                "jsonrpc": "2.0",
                "method": "call",
                "id": 1,
                "params": [
                    "model": "pos.config",
                    "method": "search_read",
                    "args": [],
                    "kwargs": [
                        
                        "fields": [],
                        
                        
                        "domain": domainParamter,
                        "offset": 0,
                        "limit": false,
                        "context": get_context()
                        
                    ]
                    //                "context": get_context()
                ]
            ]
            
            let Cookie = api.get_Cookie()
            
            let header:[String:String] = [
                "Cookie" :  Cookie
            ]
            
            callApi(url: url,keyForCash: getCashKey(key:"get_info_point_of_sale"),header: header, param: param, completion: completion);
    }
    
    func get_currencies( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "res.currency",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["id","name","symbol","position","rounding","rate","__last_update"],
                    "domain": [fillter_date() ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_currencies"),header: header, param: param, completion: completion);
        
    }
    
    func get_discount_program( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.discount.program",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [fillter_date(),  "|",
                               ["pos_config_ids","=",false],
                               ["pos_config_ids","in", SharedManager.shared.posConfig().id] ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_discount_program"),header: header, param: param, completion: completion);
        
    }
    
    
    func get_pos_product_notes( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model" : "pos.product_notes",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [fillter_date() ],
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
        
        callApi(url: url,keyForCash: getCashKey(key:"get_pos_product_notes"),header: header, param: param, completion: completion);
        
    }
    
    func get_companies( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        var fields = ["id","logo", "currency_id", "email", "website", "company_registry", "vat", "name", "phone", "partner_id" , "country_id", "tax_calculation_rounding_method","__last_update","account_sale_tax_id",
                      "street","state_id","city","zip"
                     
                     ]
        if SharedManager.shared.phase2InvoiceOffline ?? false{
            fields.append(contentsOf: ["l10n_sa_edi_building_number","l10n_sa_edi_plot_identification","l10n_sa_private_key","l10n_sa_additional_identification_scheme","l10n_sa_additional_identification_number"])
        }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "res.company",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields":  fields,
                    "domain": [fillter_date() ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_companies"),header: header, param: param, completion: completion);
        
    }
    func get_brands( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let pos_config = SharedManager.shared.posConfig()
//        let pos_id = pos_config.id
        var avaliable_brand_ids:[Int] = []

        if let pos_brand_id = pos_config.brand_id{
            avaliable_brand_ids.append(pos_brand_id)
        }
        if pos_config.cloud_kitchen.count > 0 {
            let pos_cloud_kitchen = pos_config.cloud_kitchen
            avaliable_brand_ids.append(contentsOf: pos_cloud_kitchen)
        }
        
//        if Array(Set(avaliable_brand_ids)).count <= 0 {
//            return
//        }

        let fillter = [["id","in",Array(Set(avaliable_brand_ids))]]
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "res.brand",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields":  [],
                    "domain": fillter,
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_brands"),header: header, param: param, completion: completion);
        
    }
    
    func create_pos_session(session:pos_session_class, completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let userid = session.cashierID!
        let posid = session.posID!
        let amount = session.start_Balance
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.session",
                "method": "ios_pos_session_open",
                "args": [
                    [
                        "pos_user_id": userid,
                        "user_id": SharedManager.shared.getCashDomainUserId(),
                        "start_at": session.start_session!,
                        "config_id": posid,
                        "amount": amount,
                        "balance": "start"
                        
                    ]
                ],
                "kwargs": [
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"create_pos_session"),header: header, param: param, completion: completion);
        
    }
    
    func close_pos_session(session:pos_session_class , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.session",
                "method": "ios_pos_session_close",
                "args": [
                    session.server_session_id,
                    [
                        "user_id": SharedManager.shared.getCashDomainUserId(),
                        "end_at": session.end_session!,
                        "amount": session.end_Balance ,
                        "balance": "end"
                    ]
                ],
                "kwargs": [
                    "context": get_context()

                ]
            ]
        ]
        
//        let param:[String:Any] = [
//            "jsonrpc": "2.0",
//            "method": "call",
//            "id": 1,
//            "params": [
//                "model": "pos.session",
//                "method": "ios_test_timeout",
//                "args": [
//                    session.server_session_id
//                ],
//                "kwargs": [
//                    "context": get_context()
//
//                ]
//            ]
//        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"close_pos_session"),header: header, param: param, completion: completion);
        
    }
    
    
    
    func get_product_combo_prices( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.combo.price",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [fillter_date() ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()
                ],
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_product_combo_prices"),header: header, param: param, completion: completion);
        
    }
    
    func get_order_type( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "delivery.type",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [fillter_date() ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()
                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        param.jsonString()
        
        callApi(url: url,keyForCash: getCashKey(key:"get_order_type"),header: header, param: param, completion: completion);
        
    }
    
    func get_delivery_type_category( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
          "jsonrpc": "2.0",
           "method": "call",
           "id": 1,
           "params": [
             "model": "delivery.type.category",
             "method": "search_read",
             "args": [],
             "kwargs": [
                 "fields": [],
                 "domain": [],
                 "offset": 0,
                 "limit": false,
                "context": get_context()

             ]
//             "context": get_context()
           ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_delivery_type_category"),header: header, param: param, completion: completion);
        
    }

    
    
    func get_scrap_reason( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "scrap.reason",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["id","name", "description","__last_update"],
                    "domain": [fillter_date() ],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_scrap_reason"),header: header, param: param, completion: completion);
        
    }
    
    func get_stock_by_location(loc_id:Int , completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.session",
                "method": "ios_process_stock_audit_report",
                "args": [],
                "kwargs": [
                    "loc_id": loc_id,
                    "context": get_context()
                ]
//                "context": get_context()
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"get_stock_by_location"),header: header, param: param, completion: completion);
        
    }
    
    func get_ios_get_summary_reports(from_date:String ,to_date:String ,pos_config_ids:[Int] , completion: @escaping (_ result: api_Results) -> Void)  {
           
           guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
           
           let param:[String:Any] = [
               "jsonrpc": "2.0",
               "method": "call",
               "id": 1,
               "params": [
                 "model": "pos.config",
                 "method": "ios_get_summary_reports",
                 "args":[],
                 "kwargs": [
                     "from_date": from_date ,
                     "to_date": to_date,
                     "pos_config_ids": pos_config_ids,
                    "context": get_context()

                 ]
//                 "context": get_context()
               ]
           ]
           
           let Cookie = api.get_Cookie()
           
           let header:[String:String] = [
               "Cookie" :  Cookie
           ]
           
           callApi(url: url,keyForCash: getCashKey(key:"get_stock_by_location"),header: header, param: param, completion: completion);
           
       }
    
    
    func  create_POS_Scrap(order:pos_order_class ,completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        var lines: [Any] = []
        
        let orderID = order.name
        let sessionID_server =    order.session_id_server!
        let user = SharedManager.shared.activeUser()

        for line in order.pos_order_lines {
            
            
            let product_id  = line.product_id!
            let uom_id  = line.product.uom_id!
            let qty = line.qty
            let reason = line.scrap_reason
            
            let combo_row = [
                "product_id":product_id,
                "uom_id": uom_id,
                "qty": qty,
                "reason": reason,
                "pos_user_id": user.id
                
                ] as [String : Any]  
            
            lines.append(combo_row)
            
            
        }
        
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.session",
                "method": "action_pos_scrap",
                "args": [
                    [sessionID_server],
                    lines
                ],
                "kwargs": [
                    "context": get_context()

                ]
//                "context":  get_context()
            ]
            
        ]
        
        SharedManager.shared.printLog(param.jsonString() ?? "")
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "create_POS_Scrap_\(orderID!)"),header: header, param: param, completion: completion);
        
    }
    

    
    func stc_MobilePaymentAuthorize(STC:STC_Class,  completion: @escaping (_ result: api_Results) -> Void)  {
        
        
        let is_productions = SharedManager.shared.appSetting().is_STC_productions
        var url_str = "https://b2btest.stcpay.com.sa/B2B.MerchantWebApi/Merchant/v3/MobilePaymentAuthorize"
        if is_productions == true
        {
            url_str = "https://b2b.stcpay.com.sa/B2B.Merchant.WebApi/Merchant/v3/MobilePaymentAuthorize"
        }
        
        guard let url = URL(string:url_str) else { return }
        
        
        
        
        let param:[String:Any] = [
            "MobilePaymentAuthorizeRequestMessage": [
                "BranchID": "1",
                "TellerID": "1",
                "DeviceID":  STC.MobileNo,
                "RefNum": STC.RefNum,
                "BillNumber": STC.BillNumber,
                "MobileNo": STC.MobileNo,
                "Amount": STC.amount,
                "MerchantNote": "",
                "ExpiryPeriodType": 0,
                "ExpiryPeriod": 0
            ]
        ]
        
        
        var header:[String:String] = [:]
        if is_productions == true
        {
            let pos = SharedManager.shared.posConfig()
            
            header  = [
                "X-ClientCode" : pos.accountJournals_STC()!.stc_account_code ,
                "X-UserName" :  pos.accountJournals_STC()!.stc_username,
                "X-Password" :   pos.accountJournals_STC()!.stc_password,
                "Content-Type" : "application/json"
            ]
        }
            
        else
        {
//            header  = [
//                "X-ClientCode" : "61263756001" ,
//                "X-UserName" : "@nm@RT3$tU$3R",
//                "X-Password" : "@Nm@RT3$tP@$$w0rd",
//                "Content-Type" : "application/json"
//            ]
            
            let pos = SharedManager.shared.posConfig()
            
            header  = [
                "X-ClientCode" : pos.accountJournals_STC()!.stc_test_account_code ,
                "X-UserName" :  pos.accountJournals_STC()!.stc_test_username,
                "X-Password" :   pos.accountJournals_STC()!.stc_test_password,
                "Content-Type" : "application/json"
            ]
            
            
        }
        
        
        
        let key = "MobilePaymentAuthorize_" + STC.RefNum
        
        callApi(url: url,keyForCash:key,header: header, param: param, completion: completion);
        
    }
    
    
    func stc_OnlinePaymentAuthorize(STC:STC_Class,  completion: @escaping (_ result: api_Results) -> Void)  {
        
        let is_productions = SharedManager.shared.appSetting().is_STC_productions
        var url_str = "https://b2btest.stcpay.com.sa/B2B.MerchantWebApi/Merchant/v3/OnlinePaymentAuthorize"
        if is_productions == true
        {
            url_str = "https://b2b.stcpay.com.sa/B2B.Merchant.WebApi/Merchant/v3/OnlinePaymentAuthorize"
        }
        
        guard let url = URL(string:url_str) else { return }
        
        
        let param:[String:Any] = [
            "OnlinePaymentAuthorizeRequestMessage": [
                "BranchID": "1",
                "TellerID": "1",
                "DeviceID": "1",
                "RefNum": STC.RefNum,
                "BillNumber": STC.BillNumber,
                //                        "MobileNo": STC.MobileNo,
                "Amount": STC.amount,
                "MerchantNote": "",
                "ExpiryPeriodType": 0,
                "ExpiryPeriod": 0
            ]
        ]
        
        
        var header:[String:String] = [:]
        if is_productions == true
        {
            let pos = SharedManager.shared.posConfig()
            
            header  = [
                "X-ClientCode" : pos.accountJournals_STC()!.stc_account_code ,
                "X-UserName" :  pos.accountJournals_STC()!.stc_username,
                "X-Password" :   pos.accountJournals_STC()!.stc_password,
                "Content-Type" : "application/json"
            ]
        }
            
        else
        {
//            header  = [
//                "X-ClientCode" : "61263756001" ,
//                "X-UserName" : "@nm@RT3$tU$3R",
//                "X-Password" : "@Nm@RT3$tP@$$w0rd",
//                "Content-Type" : "application/json"
//            ]

            let pos = SharedManager.shared.posConfig()
            
            header  = [
                "X-ClientCode" : pos.accountJournals_STC()!.stc_test_account_code ,
                "X-UserName" :  pos.accountJournals_STC()!.stc_test_username,
                "X-Password" :   pos.accountJournals_STC()!.stc_test_password,
                "Content-Type" : "application/json"
            ]
            
        }
        
        let key = "OnlinePaymentAuthorize_" + STC.RefNum

        callApi(url: url,keyForCash:key,header: header, param: param, completion: completion);
        
    }
    
    
    func stc_PaymentInquiry(STC:STC_Class,  completion: @escaping (_ result: api_Results) -> Void)  {
        
        let is_productions = SharedManager.shared.appSetting().is_STC_productions
        var url_str = "https://b2btest.stcpay.com.sa/B2B.MerchantWebApi/Merchant/v3/PaymentInquiry"
        if is_productions == true
        {
            url_str = "https://b2b.stcpay.com.sa/B2B.Merchant.WebApi/Merchant/v3/PaymentInquiry"
        }
        
        
        guard let url = URL(string:url_str) else { return }
        
        
        let param:[String:Any] = [
            "PaymentInquiryRequestMessage": [
                "RefNum": STC.RefNum
            ]
        ]
        
        
        var header:[String:String] = [:]
        if is_productions == true
        {
            let pos = SharedManager.shared.posConfig()
            
            header  = [
                "X-ClientCode" : pos.accountJournals_STC()!.stc_account_code ,
                "X-UserName" :  pos.accountJournals_STC()!.stc_username,
                "X-Password" :   pos.accountJournals_STC()!.stc_password,
                "Content-Type" : "application/json"
            ]
        }
            
        else
        {
//            header  = [
//                "X-ClientCode" : "61263756001" ,
//                "X-UserName" : "@nm@RT3$tU$3R",
//                "X-Password" : "@Nm@RT3$tP@$$w0rd",
//                "Content-Type" : "application/json"
//            ]

            let pos = SharedManager.shared.posConfig()
            
            header  = [
                "X-ClientCode" : pos.accountJournals_STC()!.stc_test_account_code ,
                "X-UserName" :  pos.accountJournals_STC()!.stc_test_username,
                "X-Password" :   pos.accountJournals_STC()!.stc_test_password,
                "Content-Type" : "application/json"
            ]
            
        }
        
        let key = "PaymentInquiry_" + STC.RefNum

        callApi(url: url,keyForCash:key,header: header, param: param, completion: completion);
        
    }
    
    func stc_CancelPaymentAuthorize(STC:STC_Class,  completion: @escaping (_ result: api_Results) -> Void)  {
        
        let is_productions = SharedManager.shared.appSetting().is_STC_productions
        var url_str = "https://b2btest.stcpay.com.sa/B2B.MerchantWebApi/Merchant/v3/CancelPaymentAuthorize"
        if is_productions == true
        {
            url_str = "https://b2b.stcpay.com.sa/B2B.Merchant.WebApi/Merchant/v3/CancelPaymentAuthorize"
        }
        
        
        guard let url = URL(string:url_str) else { return }
        
        if STC.AuthorizationReference.isEmpty
        {
            return
        }
        
        let param:[String:Any] = [
            "CancelPaymentAuthorizeRequestMessage": [
                "AuthorizationReference": STC.AuthorizationReference
            ]
        ]
        
        
        var header:[String:String] = [:]
        if is_productions == true
        {
            let pos = SharedManager.shared.posConfig()
            
            header  = [
                "X-ClientCode" : pos.accountJournals_STC()!.stc_account_code ,
                "X-UserName" :  pos.accountJournals_STC()!.stc_username,
                "X-Password" :   pos.accountJournals_STC()!.stc_password,
                "Content-Type" : "application/json"
            ]
        }
            
        else
        {
//            header  = [
//                "X-ClientCode" : "61263756001" ,
//                "X-UserName" : "@nm@RT3$tU$3R",
//                "X-Password" : "@Nm@RT3$tP@$$w0rd",
//                "Content-Type" : "application/json"
//            ]
            

            let pos = SharedManager.shared.posConfig()
            
            header  = [
                "X-ClientCode" : pos.accountJournals_STC()!.stc_test_account_code ,
                "X-UserName" :  pos.accountJournals_STC()!.stc_test_username,
                "X-Password" :   pos.accountJournals_STC()!.stc_test_password,
                "Content-Type" : "application/json"
            ]
            
        }
        
        let key = "CancelPaymentAuthorize_" + STC.RefNum

        
        callApi(url: url,keyForCash:key,header: header, param: param, completion: completion);
        
    }
    
    
  
    func  create_POS_Order(order:pos_order_class ,completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
          let to_invoice = false
        let orderID:String! =  order.name
        let data = pos_order_builder_class.bulid_order_data(order: order,for_pool: nil)
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.order",
                "method": "create_from_ui",
                "args": [
                    [
                        [
                            "id": orderID!,
                            "to_invoice": to_invoice,
//                            "loyalty_earned_point": order.loyalty_earned_point,
//                            "loyalty_earned_amount": order.loyalty_earned_amount,
//                            "loyalty_redeemed_point": order.loyalty_redeemed_point,
//                            "loyalty_redeemed_amount": order.loyalty_redeemed_amount,
                            "data": data                        ]
                    ]
                ],
                "kwargs": [
                    "context": get_context()

                ]
//                "context": get_context()
            ]
            
        ]
        
//        SharedManager.shared.printLog(param.jsonString() ?? "")
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: orderID),header: header, param: param,is_create_from_ui: !SharedManager.shared.appSetting().enable_log_sync_success_orders, completion: completion);
        
    }
    
    
    
    func restaurant_floor( completion: @escaping (_ result: api_Results) -> Void)  {
         guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        var fillter: [[Any]] = []

        let pos = SharedManager.shared.posConfig()
        let available_floors_ids = pos.available_floors_ids
        
        if available_floors_ids.count > 0 {
            fillter.append(["id", "in", available_floors_ids])
        }
         let param:[String:Any] = [
             "jsonrpc": "2.0",
             "method": "call",
             "id": 1,
             "params": [
                 "model": "restaurant.floor",
                 "method": "search_read",
                 "args": [],
                 "kwargs": [
                     "fields": ["table_ids", "pos_config_id", "name"],
                     "domain": fillter,
                     "offset": 0,
                     "limit": false,
                    "context": get_context()

                 ]
//                 "context": get_context()
             ]
         ]
         
         //let Cookie = api.get_Cookie()
         
         let header:[String:String] = [
             "Cookie" :  api.get_Cookie()
         ]
         
         callApi(url: url, keyForCash: getCashKey(key:"restaurant_floor"), header: header, param: param, completion: completion);
     }
     
     func restaurant_table( completion: @escaping (_ result: api_Results) -> Void)  {
         guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
         
         let param:[String:Any] = [
             "jsonrpc": "2.0",
             "method": "call",
             "id": 1,
             "params": [
                 "model": "restaurant.table",
                 "method": "search_read",
                 "args": [],
                 "kwargs": [
                     "fields": [],
                     "domain": [],
                     "offset": 0,
                     "limit": false,
                    "context": get_context()

                 ]
//                 "context": get_context()
             ]
         ]
         
         let header:[String:String] = [
             "Cookie" :  api.get_Cookie()
         ]
         
         callApi(url: url, keyForCash: getCashKey(key:"restaurant_table"), header: header, param: param, completion: completion);
     }
   
    func restaurant_table_update(table:restaurant_table_class, completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "restaurant.table",
                "method": "write",
                "args": [
                    [
                        table.id
                             ],
                             [
                                 "position_h": table.position_h,
                                 "position_v": table.position_v
                             ]
                ],
                "kwargs": [
                    :
                ],
               
             ]
        ]
        
        let header:[String:String] = [
            "Cookie" :  api.get_Cookie()
        ]
        
        callApi(url: url, keyForCash: getCashKey(key:"restaurant_table_update"), header: header, param: param, completion: completion);
    }
    
    func get_pos_return_reason( completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param:[String:Any] = [
            
            "jsonrpc": "2.0",
              "method": "call",
              "id": 1,
              "params": [
                "model": "pos.return.reason",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": [],
                    "domain": [],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
//                "context": get_context()
              ]
            
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_pos_return_reason"),header: header, param: param, completion: completion);
        
    }
    
    func get_values_by_pin( _ pinCode :String,header:[String:String], completion: @escaping (_ result: api_Results) -> Void)  {
//       let domainMaster = "https://erp.dgtera.com"
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
//        guard let url = URL(string:"\(domainMaster)/web/dataset/call_kw") else { return }

        let param:[String:Any] =
        [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "dgt.ios.admin",
                "method": "get_values_by_pin",
                "args": [
                    pinCode
                ],
                "kwargs":[
                    "context":[]
                ]
                
            ]
        ]
        
        let header:[String:String] = header
        
        callApi(url: url,keyForCash: getCashKey(key: "get_values_by_pin") ,header: header, param: param, completion: completion);
        
    }
    func pinCodeAuth( username :String , password : String, dbName:String , completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/web/session/authenticate") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params":[
                "login": username,
                "password": password,
                "db": dbName,
                "context": get_context()
            ]
            
        ]
        
        let header:[String:String] = [:]
        
        callApi(url: url,keyForCash: getCashKey(key: "authenticate") ,header: header, param: param, completion: completion);
        
    }
    
    
    
}
