//
//  PinCodeVM.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/7/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

enum MasterOdooAuth:String{
    case url = "https://erp.dgtera.com"
    case dataBase = "erp"
}
class PinCodeVM {
    enum StatePinCode {
        case empty
        case loading
        case populated
        case error
    }
    var state: StatePinCode = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state, message, isSucess)
        }
    }
    var updateLoadingStatusClosure: ((StatePinCode, String?, Bool) -> Void)?
    private var message: String?
    private var isSucess: Bool = false
    var API:api?
    private var masterToken:String = ""
    private var pinCodeInfo:PinCodeInfoModel?
   
   
    //MARK:- get Pin code Info
    func getPinInfoFor(code:String){
        var pincode = code
        pincode = pincode.replacingOccurrences(of: "٠", with: "0")
        pincode = pincode.replacingOccurrences(of: "١", with: "1")
        pincode = pincode.replacingOccurrences(of: "٢", with: "2")
        pincode = pincode.replacingOccurrences(of: "٣", with: "3")
        pincode = pincode.replacingOccurrences(of: "٤", with: "4")
        pincode = pincode.replacingOccurrences(of: "٥", with: "5")
        pincode = pincode.replacingOccurrences(of: "٦", with: "6")
        pincode = pincode.replacingOccurrences(of: "٧", with: "7")
        pincode = pincode.replacingOccurrences(of: "٨", with: "8")
        pincode = pincode.replacingOccurrences(of: "٩", with: "9")

        if code.count == 12 {
            pincode.insert("-", at: pincode.index(pincode.startIndex, offsetBy: 3))
            pincode.insert("-", at: pincode.index(pincode.startIndex, offsetBy: 7))
            pincode.insert("-", at: pincode.index(pincode.startIndex, offsetBy: 11))
        }
        state = .loading
        setMasterOdooAuthValues()
        newLoginWith(){ [weak self] (result) in
            guard let self = self else { return }
            if result ?? false {
                self.hitPinInfoAPI(pincode:pincode)
            }else{
                self.state = .empty
            }
        }
    }
    private func callCompleteGetInfo(pinCodeInfo: PinCodeInfoModel?){
        self.pinCodeInfo = pinCodeInfo
        self.fetchPinCodeInfoSucess()

    }
    //MARK:- call Info For pinCode
    private func hitPinInfoAPI(pincode:String){
        guard let API = self.API else {
            return
        }
        let header:[String:String] = [
            "Cookie" :  masterToken
        ]
        API.get_values_by_pin(pincode,header: header) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dic)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let obj: Odoo_Base<PinCodeInfoModel> = try JSONDecoder().decode(Odoo_Base<PinCodeInfoModel>.self, from: data )
                        
                        if obj.result?.isValid() ?? false{
                                if let posID = obj.result?.pos_ID, let dataBaseName = obj.result?.database {
                                    self.callCompleteGetInfo(pinCodeInfo:obj.result)
                                    
                                    return
                                    
                                }
                            self.callCompleteGetInfo(pinCodeInfo:obj.result)
                        }else{
                            self.isSucess = false
                            self.message =  "Pin Code invalid"
                            self.state = .error
                        }
                    } catch {
                         SharedManager.shared.printLog(error)
                        self.isSucess = false
                        self.message =  "pleas, try again later"
                        self.state = .error
                    }
                }else{
                    self.isSucess = false
                    self.message =  "Pin Code invalid"
                    self.state = .error
                }
              

                return
            }else{
                self.isSucess = false
                self.message = results.message ?? ""
                self.state = .error
                
            }
        };
    }
    //MARK:- fetch PinCode Info Sucessfully
    private func fetchPinCodeInfoSucess(){
        guard let pinInfo =  self.pinCodeInfo else {
            return
        }
        saveConnectionInfo(info:pinInfo,odooCookie:nil)
        let username = pinInfo.username ?? ""
        let password =  pinInfo.password ?? ""
        self.loginWith(username, password,for: StatePinCode.populated)
    }
    //MARK:- New Login to master or client odoo Server
    func newLoginWith(for resultState:StatePinCode = .empty, completion:  ((_ isSucess: Bool?) -> Void)? = nil){
        self.newHitLoginAPI { (isLogin) in
            if(isLogin == true){
                if resultState == .populated {
                    self.hitLoadPOSAPI()
                }else{
                    if let completion = completion {
                        completion(true)
                    }else{
                        self.state = resultState
                    }
                }
            }else{
                if resultState == .populated {
                    self.state = .empty

                }else{
                    self.state = .error
                }
            }
        }
    }
    //MARK:- Login to master or client odoo Server
    func loginWith(_ name:String, _ password:String,for resultState:StatePinCode = .empty, completion:  ((_ isSucess: Bool?) -> Void)? = nil){
        self.hitLoginAPI( username :name , password : password,for: resultState){
            (isLogin) in
            if(isLogin == true){
                if resultState == .populated {
                    self.hitLoadPOSAPI()
                }else{
                    if let completion = completion {
                        completion(true)
                    }else{
                        self.state = resultState

                    }
                }
            }else{
                if resultState == .populated {
                    self.state = .empty

                }else{
                    self.state = .error

                }
            }
        }
        
    }
    private func newHitLoginAPI(for resultState:StatePinCode = .empty, completion:  ((_ isSucess: Bool?) -> Void)?) {
        guard let API = self.API else {
            return
        }
        API.callKeyAuthenticate { results in
            if results.success
            {
                let header = results.header  as NSDictionary
                let Cookie :String = header.object(forKey: "Set-Cookie") as? String ?? ""
                let result = results.response!["result"] as! NSDictionary

                if Cookie == ""
                {
                    self.isSucess = false
                    self.message = "Can't login , try later ."
                    completion?(false)
                    return
                }
                else
                {
                  
                    if resultState == StatePinCode.populated{
                        let company_id = result["company_id"] as? Int
                        if let user_context = result["user_context"] as? NSDictionary ,
                           let tz = user_context["tz"] as? String ,  let uid = user_context["uid"] as? Int {
                            api.set_tz(tz: tz)
                            api.set_uid(uid: "\(uid)")
                        }
                        self.saveConnectionInfo(info:nil,odooCookie:Cookie,companyId: company_id)
                    }else{
                        self.masterToken = Cookie
                    }
                    completion?(true)
                }
                return
            }else{
                self.isSucess = false
                self.message = results.message ?? ""
                completion?(false)
                self.state = .error
                
            }
        }
    }
    //MARK:- call Login API to master or client odoo Server
    private func hitLoginAPI( username :String , password : String,for resultState:StatePinCode = .empty, completion:  ((_ isSucess: Bool?) -> Void)?){
        guard let API = self.API else {
            return
        }
        API.authenticate(username: username, password: password) { (results) in
            if results.success
            {
                let header = results.header  as NSDictionary
                let Cookie :String = header.object(forKey: "Set-Cookie") as? String ?? ""
                let result = results.response!["result"] as! NSDictionary

                if Cookie == ""
                {
                    self.isSucess = false
                    self.message = "Can't login , try later ."
                    completion?(false)
                    return
                }
                else
                {
                  
                    if resultState == StatePinCode.populated{
                        let company_id = result["company_id"] as? Int
                        let domainUserId = result["user_id"] as? [Int]
                        if let user_context = result["user_context"] as? NSDictionary ,
                           let tz = user_context["tz"] as? String ,  let uid = user_context["uid"] as? Int {
                            api.set_tz(tz: tz)
                            api.set_uid(uid: "\(uid)")
                        }
                        api.set_domain_user_id(uid: domainUserId?.first ?? 0)
                        self.saveConnectionInfo(info:nil,odooCookie:Cookie,companyId: company_id)
                    }else{
                        self.masterToken = Cookie
                    }
                    completion?(true)
                }
                return
            }else{
                self.isSucess = false
                self.message = results.message ?? ""
                completion?(false)
                self.state = .error
                
            }
        };
    }
    //MARK:- call LoadPOS API from client odoo Server
    private func hitLoadPOSAPI(){
        guard let API = self.API else {
            return
        }
        if let pos_ID = Int(cash_data_class.get(key: "pinInfo_pos_ID") ?? "0") , pos_ID != 0{
            let domain:[Any] = [ ["id","=",pos_ID]]
            API.get_info_point_of_sale(domain) { (results) in
                //        API.get_point_of_sale() { (results) in
                
                if !results.success
                {
                    self.setMasterOdooAuthValues()
                    self.isSucess = false
                    self.message = results.message ?? ""
                    self.state = .error
                    return;
                }
                
                let response = results.response
                //            let header = results.header
                
                let list:[[String:Any]]  = response?["result"] as? [[String:Any]] ?? []
                
                pos_config_class.saveAll(arr: list)
                
                self.setPOSActive()
                FireBaseService.defualt.getFRSettingApp {
                    self.state = .populated
                }
            }
            
        }else{
            self.message = "Cannot detect default pos"
            self.state = .error

        }
        
    }
    //MARK:- set POS Active
    private func setPOSActive(){
        guard let pinInfo =  self.pinCodeInfo , let idPOS = pinInfo.pos_ID else {
            return
        }
        let item_pos = pos_config_class.getPos(posID:idPOS)
        item_pos.setActive()
        
    }
    
    //MARK:- set Master Odoo Auth Values
   private func setMasterOdooAuthValues(){
        api.set_Cookie(Cookie: masterToken)
        api.setDomain(url:  MasterOdooAuth.url.rawValue)
        api.setDatabase(url:  MasterOdooAuth.dataBase.rawValue)
    }
    //MARK:- save connection Info
    private func saveConnectionInfo(info:PinCodeInfoModel?,odooCookie:String?,companyId:Int? = nil, domainUserId: Int? = nil){
        if let pinInfo =  info  {
            cash_data_class.set(key: "pinInfo_pos_ID", value: "\(pinInfo.pos_ID ?? 0)")
            api.setDomain(url: pinInfo.url ?? "")
            api.setDatabase(url: pinInfo.database ?? "")
            api.saveItem(name: userLogin.username.rawValue , value:  pinInfo.username ?? "")
            api.saveItem(name: userLogin.password.rawValue , value: pinInfo.password ?? "")
            api.saveItem(name: userLogin.domain_user_id.rawValue , value: "\(pinInfo.domain_user_id ?? 0)")
            
        }
        if let token = odooCookie {
            api.set_Cookie(Cookie: token)
        }
        if let company_id = companyId{
            api.saveItem(name: userLogin.company_id.rawValue , value: "\(company_id )")
        }
    }
   
}

