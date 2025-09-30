//
//  CouponCodeInteractor.swift
//  pos
//
//  Created by Ahmed Mahrous on 03/09/2025.
//  Copyright © 2025 khaled. All rights reserved.
//

import Foundation

class CouponCodeInteractor {
    static let shared = CouponCodeInteractor()
    var order: pos_order_class?
    
    private init() {
        
    }
    
    func isValid() -> (result: Bool, messege: String) {
        if let order = order {
            if order.coupon_code.isEmpty{
                return (false,"Require Coupon code".arabic("يجب ادخال كود الكوبون"))
            }
        }
        return (true,"")
    }
    
    func showErrorMessage(_ messege:String){
        SharedManager.shared.initalBannerNotification(title: "", message: messege , success: false, icon_name: "icon_error")
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
    }
    
    func checkCouponReward(order:pos_order_class?, complete:@escaping (Bool)->Void) {
        self.order = order
        if let order = order {
            let validator = isValid()
            if validator.result {
                SharedManager.shared.conAPI().checkCouponAPI(couponCode: order.coupon_code) { result in
                    if let result = result.response?["result"] as? [[String:Any]] {
                        if result.isEmpty {
                            self.showErrorMessage("You entered wrong or expired coupon code".arabic(" هذا الكوبون خطأ أو قد انتهى"))
                            complete(false)
                            return
                        }
                        
                        if let existingCoupon = promo_coupon_class.get(by: order.uid ?? "") {
                            self.updateExistingCoupon(existingCoupon, with: result[0], order: order)
                        } else {
                            let newCoupon = promo_coupon_class(fromDictionary: result[0], order: order)
                            newCoupon.save()
                        }
                        self.order?.coupon_id = result[0]["id"] as? Int ?? 0
                        self.order?.save()
                        complete(true)
                        return
                    }
                }
            } else {
                showErrorMessage(validator.messege)
                complete(false)
            }
        }
    }
    
    func redeemCoupon(order: pos_order_class?, completion: @escaping (Bool)->Void) {
        self.order = order
        
        guard let order = order, let orderUID = order.uid else {
            completion(false)
            return
        }
        
        SharedManager.shared.conAPI().redeemCouponAPI(for: order.coupon_id, orderUID: orderUID) { result in
            if !result.success {
                self.showErrorMessage("Network error occurred".arabic("حدث خطأ في الشبكة"))
                completion(false)
                return
            }
            
            guard let response = result.response else {
                self.showErrorMessage("Invalid response from server".arabic("استجابة غير صحيحة من الخادم"))
                completion(false)
                return
            }
            
            if let resultValue = response["result"] as? Bool {
                if resultValue {
                    completion(true)
                } else {
                    self.showErrorMessage("You entered expired coupon code".arabic(" هذا الكوبون قد انتهى"))
                    completion(false)
                }
            } else {
                self.showErrorMessage("Invalid server response".arabic("استجابة خادم غير صحيحة"))
                completion(false)
            }
        }
    }
    
    private func updateExistingCoupon(_ existingCoupon: promo_coupon_class, with apiData: [String:Any], order: pos_order_class) {
        existingCoupon.name = apiData["name"] as? String
        existingCoupon.code = apiData["code"] as? String
        existingCoupon.active = apiData["active"] as? Bool ?? false
        existingCoupon.number_of_apply = apiData["number_of_apply"] as? Int
        existingCoupon.type = apiData["type"] as? String
        existingCoupon.amount = apiData["amount"] as? Double
        existingCoupon.min_order_amount = apiData["min_order_amount"] as? Double
        existingCoupon.expiry_date = apiData["expiry_date"] as? String
        existingCoupon.max_amount = apiData["max_amount"] as? Double
        existingCoupon.orders_count = apiData["orders_count"] as? Int
        existingCoupon.remaining_coupons_number = apiData["remaining_coupons_number"] as? Int
        existingCoupon.coupon_category_id = apiData["coupon_category_id"] as? Int
        existingCoupon.display_name = apiData["display_name"] as? String
        
        existingCoupon.dbClass?.dictionary = existingCoupon.toDictionary()
        existingCoupon.dbClass?.id = existingCoupon.id!
        existingCoupon.dbClass?.insertId = false
        _ = existingCoupon.dbClass?.save()
    }
}

extension api {
    func checkCouponAPI(couponCode: String, completion: @escaping (_ result: api_Results) -> Void) {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param: [String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
            "model": "dgt.pos.coupon",
            "method": "search_read",
            "args": [],
            "kwargs": [
                    "fields": [],
                    "domain": [
                        ["code", "=", "\(couponCode)"]
                    ],
                    "offset": 0,
                    "limit": 1
                ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash: getCashKey(key:"checkCouponAPI"),header: header, param: param, completion: completion)
    }
    
    func redeemCouponAPI(for couponID: Int, orderUID: String, completion: @escaping(_ result: api_Results) -> Void) {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        let param: [String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "dgt.pos.coupon",
                "method": "apply_coupon",
                "args": [couponID],
                "kwargs": ["order_ref": orderUID]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        print("Redeem Coupon API Request:")
        print("URL: \(url)")
        print("Headers: \(header)")
        if let jsonData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Body: \(jsonString)")
        }
        
        callApi(url: url,keyForCash: getCashKey(key:"redeemCouponAPI"),header: header, param: param, completion: completion)
    }
}

