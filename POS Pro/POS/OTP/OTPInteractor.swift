//
//  OTPInteractor.swift
//  pos
//
//  Created by M-Wageh on 01/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class OTPInteractor {
    static let shared = OTPInteractor()
    private init(){}
    
     func checkOtp(_ otp:String,completion: @escaping (_ result: Bool) -> Void){
         if otp.isEmpty {
             completion(false)
             return
         }
        SharedManager.shared.conAPI().hitValidateOTPAPI(for:otp) { result in
            if result.success
            {
                let response = result.response
                if let result:Bool  = response?["result"] as? Bool  {
                    completion(result)
                    return
                }
            }
            completion(false)
        }
    }
    
}
extension api {
    func hitValidateOTPAPI(for otp:String ,completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params":  [
                "model": "pos.config",
                "method": "validate_pos_otp",
                "args": [
                    [
                        SharedManager.shared.posConfig().id //  103   // pos config id
                                ]
                ],
                "kwargs": [
                    "otp": otp  // password
                ],
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"validate_OTP"),header: header, param: param, completion: completion);
        
    }
}
