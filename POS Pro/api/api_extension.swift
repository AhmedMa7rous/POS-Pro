//
//  api_extension.swift
//  pos
//
//  Created by khaled on 8/6/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCrashlytics

enum error_code : Int {
    case invalidArgument  = 200
    case sessionExpired = 100
}

extension api {
   

    static func isAuth() -> Bool
    {
        let Cookie  :String =  api.get_Cookie()
         if (!Cookie.isEmpty)
         {
                return true
         }
       
        
        return false
    }
    
  static  func  get_Cookie() ->String  {
        
//    let Cookie:String?   = myuserdefaults.getitem("Cookie", prefix: "website") as? String ?? ""
    let Cookie:String?   = cash_data_class.get(key: "website_Cookie") ?? ""

    
    return Cookie!
  }
    static  func  get_tz_user() ->String  {
        return cash_data_class.get(key: "tz_user") ?? "Europe/Brussels"
    }
    static  func  get_uid_user() -> Int  {
        return Int(cash_data_class.get(key: "uid_user") ?? "1") ?? 1
    }
    
    static  func  set_Cookie(Cookie: String)  {
        
//       myuserdefaults.setitems("Cookie", setValue: Cookie, prefix: "website")
        cash_data_class.set(key: "website_Cookie", value: Cookie)
 
    }
    static  func  set_tz(tz: String)  {
        
        cash_data_class.set(key: "tz_user", value: tz)
 
    }
    static  func  set_uid(uid: String)  {
        cash_data_class.set(key: "uid_user", value: uid)
    }
    static  func  delete_tz()  {
        cash_data_class.remove(key: "tz_user")
    }
    static  func  delete_uid()  {
        cash_data_class.remove(key: "uid_user")
    }
    static  func  set_domain_user_id(uid: Int)  {
        cash_data_class.set(key: "user_id", value: String(uid))
    }
    static  func  delete_Cookie()  {
        
//        myuserdefaults.deleteitems("Cookie", prefix: "website")
        cash_data_class.remove(key: "website_Cookie")
        
    }
    
    func callApi( url:URL ,keyForCash:String, header :  [String:String]  , param:[String:Any] ,is_create_from_ui:Bool = false ,completion: @escaping (_ result: api_Results) -> Void)
    {
        let keyCash = String(format: "%@_%@", "callApi",keyForCash)
        
        var cash = false
        if userCash == .useCash
        {
              cash = true
        }
        
        let checkInternet = NetworkConnection.isConnectedToNetwork()
//
//        if checkInternet == false {
//            if userCash == .useCash
//            {
//                cash = true
//
//            }
//        }
        
        
        let rows = AppDelegate.shared.localCash?.getLastData(url: url.absoluteString,keydata:keyCash , UseCash: cash,checkInternet: checkInternet)
        
        if (rows != nil)
        {
            let dictionary = rows!["dictionary"] as! [String : Any]
            let header = rows!["header"] as? [String : String]  ?? [:]
           
            
            DispatchQueue.main.async {
                completion(api_Results(response: dictionary  , header: header , httpStatusCode : 200 , request: param , url: url.absoluteString,isCashed: true))
            }
            
            return
        }
        else if (rows == nil && checkInternet == false)
        {
            let dictionary:[String : Any]  = [:]
            let header:[String : String] = [:]
            
            DispatchQueue.main.async {
                completion(api_Results(response: dictionary   , header: header , httpStatusCode : 500 , request: param , url: url.absoluteString,isCashed: true))
            }
            
            return
        }
        
        
        var header_pass = header
        header_pass["Content-Type"] = "application/json"
       rest.requestHttpHeaders.set(params: header_pass)
     
        
//        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        
        
        rest.httpBodyParameters.set(params: param)
        
        #if DEBUG
        SharedManager.shared.printLog("--------------------------")
        SharedManager.shared.printLog( rest.requestHttpHeaders.allValues().jsonString() ?? "")

    SharedManager.shared.printLog("")
         SharedManager.shared.printLog("--------------------------")
        SharedManager.shared.printLog(url  )
       SharedManager.shared.printLog("")
        SharedManager.shared.printLog( rest.httpBodyParameters.allValues().jsonString() ?? "")
         SharedManager.shared.printLog("--------------------------")
        #endif
        
     
        rest.makeRequest(toURL: url, withHttpMethod: .post ,timeout:timeout) { (results) in
            
            // error in request http
            if results.error != nil
            {
                let error_str = results.error?.localizedDescription ?? "error_str"
                SharedManager.shared.printLog(error_str)
                
                var dictionary:[String:String] = [:]
                dictionary["error"] = error_str
                
                
                if keyForCash.lowercased().contains("updateorderstatus"){
                    self.recordError(url: url.absoluteString, param: param, res: error_str)
                }
                
                self.saveLog(key: keyForCash, url: url.absoluteString, header: header, param: param, res: results.error?.localizedDescription ?? "error",response_time: results.response_time!)

                self.handelResponseInError(cash: cash, url: url, keyCash: keyCash, header: header, param: param, dictionary:dictionary, headers_response:   [:], completion: completion)
                
                return
            }
            
            guard let response = results.response else { return }
            guard let data = results.data else { return }
    
            let str = String(decoding: data, as: UTF8.self)
            if !is_create_from_ui{
            self.saveLog(key: keyForCash, url: url.absoluteString, header: header, param: param, res: str,response_time: results.response_time!)
            }
            
  
            let dictionary = self.StringToDictionary(str: str);

            SharedManager.shared.session_expired = false

            if response.httpStatusCode == 200 {
                
                if dictionary["error"] == nil
                {
                    var  temp :[String :Any]=[:]
                    temp["dictionary"] = dictionary
                    temp["header"] = response.headers.allValues()
                    
                    AppDelegate.shared.localCash?.saveData(url: url.absoluteString, keydata: keyCash, dictionary: temp)
                    
                    DispatchQueue.main.async {
                        completion(api_Results(response: dictionary  , header: response.headers.allValues(),  httpStatusCode : response.httpStatusCode , request: param , url: url.absoluteString,isCashed: false))
                    }
                }
                else
                {
                    let error = dictionary["error"] as? [String :Any] ?? [:]
                    let message = error["message"] as? String ?? ""
                     if message == "Odoo Session Expired"
                     {
                        AppDelegate.shared.auto_Login()
                        SharedManager.shared.session_expired = true
//                        return
                     }
                    
                    SharedManager.shared.printLog(str)
                    
                    self.recordError(url: url.absoluteString, param: param, res: str)
                    
            
                    
                    self.handelResponseInError(cash: cash, url: url, keyCash: keyCash, header: header, param: param, dictionary: dictionary, headers_response:   response.headers.allValues(), completion: completion)
                    
                }
          
            }
            else
            {
                SharedManager.shared.printLog(str)
          
                          
//                self.saveLog(key: keyForCash, url: url.absoluteString, header: header, param: param, res: str ,response_time: results.response_time!)
                
                self.recordError(url: url.absoluteString, param: param ,  res: str)

               self.handelResponseInError(cash: cash, url: url, keyCash: keyCash, header: header, param: param, dictionary: dictionary, headers_response:   response.headers.allValues(), completion: completion)
//
//                let rows =  appdlg().localCash?.getSavedLastData(url.absoluteString,keydata:keyCash )
//
//                if (rows != nil)
//                {
//                    let dictionary = rows!["dictionary"]
//                    let header = rows!["header"]
//
//                    DispatchQueue.main.async {
//                        completion(api_Results(response: dictionary as! [String : Any]  , header: header as! [String : String] , httpStatusCode : 200 , request: param , url: url.absoluteString))
//                    }
//
//
//                }
//                else
//                {
//                    DispatchQueue.main.async {
//                        completion(api_Results(response: dictionary  , header: response.headers.allValues() ,  httpStatusCode :500,request: param , url: url.absoluteString))
//                    }
//                }
                
             
            }
        }
    }
    
    
    func handelResponseInError(cash:Bool,url:URL,keyCash:String,header :  [String:String]  , param:[String:Any] ,dictionary:[String:Any],headers_response:[String:String], completion: @escaping (_ result: api_Results) -> Void)
    {
        var rows:[String : Any]? = nil
        
        if cash == true
        {
            rows =  AppDelegate.shared.localCash?.getSavedLastData(url: url.absoluteString,keydata:keyCash )
        }
        
        
        if (rows != nil)
        {
            let dictionary = rows!["dictionary"] as? [String : Any]  ?? [:]
            let header = rows!["header"] as? [String : String]  ?? [:]
             
            DispatchQueue.main.async {
                completion(api_Results(response: dictionary   , header: header  , httpStatusCode : 200 , request: param , url: url.absoluteString,isCashed: true))
            }
            
        }
        else
        {
            DispatchQueue.main.async {
                completion(api_Results(response: dictionary  , header: headers_response ,  httpStatusCode :500,request: param , url: url.absoluteString,isCashed: false))
            }
        }
    }
    
    func saveLog(key:String,url:String  , header:[String:Any] , param:[String:Any], res:String,response_time:Int64)
    {
        DispatchQueue.main.async {
            var key = key
            if key.lowercased().contains( "updateorderstatus"){
                if res.contains("\"id\": null"){
                    key = "updateOrderStatus"
                }
            }

            var log = logClass.get(key: key, prefix: "con_log")

        log.key = key
        log.prefix =  "con_log"
        
        if log.key == key
        {
            log.req_count = log.req_count + 1
        }
        
        let setting = SharedManager.shared.appSetting()
        if key.contains("longpolling_")
        {
            if setting.enable_record_all_log_multisession
            {
                log.id = 0
               
            }
        }
        else
        {
            if setting.enable_record_all_log
            {
                log.id = 0
               
            }
        }
        
        
        let newID :Int64   =  baseClass.getTimeINMS() // ClassDate.getTimeINMS()!.toInt()!

        var dic:[String:Any] = [:]
        dic["url"] = url
        dic["header"] = header
        dic["param"] = param
        dic["res"] = res
        dic["key"] = key
        dic["time"] = newID
        dic["response_time"] = response_time
        
        log.data = dic.jsonString()
        log.save()
        }
//        logClass.set(key: key, value: dic, prefix: "con_log")
//          logDB.setitems(key, setValue: dic, prefix: "con_log"  )
//        logDB.setitems(String(newID), setValue: dic, prefix: "con_log"  )
        
    }
    
    func recordError(url:String  , param:[String:Any], res:String)
    {
        //    Crashlytics.sharedInstance().setObjectValue("api error 1", forKey: "test")
        
        
        let error = NSError(domain: url, code: 5000, userInfo:
            [
                "response" :  res ,
                "param" : param ,
                "url" : url
//                NSLocalizedDescriptionKey : "Object does not exist"
                //            , NSLocalizedFailureReasonErrorKey : "he response returned a 404."
                //            , NSLocalizedRecoverySuggestionErrorKey : "Does this page exist?"
                
            ]
        )
        
        Crashlytics.crashlytics().record(error: error)

//        Crashlytics.sharedInstance().recordError(error)
    }
    
    
    public struct api_Results {
        var  url:String = ""
        
        var response: [String: Any]?
        var header: [String: String] = [:]
        var request: [String: Any]?
        
        var success: Bool! = false
        var code: error_code?
        var message: String?
        var isCashed:Bool?

        var data_error: [String :Any]?
        static func getFailOffline() -> api_Results{
            var resultApi = api_Results(response: [:], header: [:], httpStatusCode: -1, request: [:], url: "", isCashed: false)
            resultApi.success = false
            resultApi.message = "Please check your internet connection".arabic("يرجي التحقق من الاتصال بالانترنت")
            return resultApi
        }
        init(  response: [String: Any], header: [String: String] , httpStatusCode :  Int , request: [String: Any] ,url:String,isCashed:Bool) {
            
            self.url = url
            self.response = response
            self.header = header
            self.request = request
            self.isCashed = isCashed
            
           
            if self.response?["error"] == nil && httpStatusCode == 200
            {
                success = true
            }
            else
            {
                let error =  self.response!["error"] as? [String : Any] ?? [:]
                data_error =   error["data"] as? [String : Any] ?? [:]

                let errorcode = error["code"] as? Int ?? 0
                message =    data_error?["message"] as? String  ?? "undefine error"

                if (errorcode == error_code.sessionExpired.rawValue)
                {
                    code = error_code.sessionExpired
                }
                
                
            }
        }
        
        func toString() -> String
        {
             var log_message: [String] = []
            
            log_message.append(self.url)
            log_message.append(self.header.jsonString() as String? ?? "")
             log_message.append(self.request?.jsonString() as String? ?? "")
            log_message.append(self.response?.jsonString() as String? ?? "")
            
            var txt:String = ""
            for i in log_message
            {
                txt = txt + "\n----------------------------------\n" + i
            }
            
            return txt
        }
        
        
    }
    
    
    public func StringToDictionary(str : String) -> Dictionary<String, Any>
    {
        let jsonData = str.data(using: .utf8)!
        var dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
        
        if dic == nil
        {
            dic = [:]
        }
        
        return dic as! Dictionary<String, Any>
    }
    
    
}


