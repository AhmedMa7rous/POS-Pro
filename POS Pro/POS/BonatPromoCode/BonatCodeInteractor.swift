//
//  BonatCodeInteractor.swift
//  pos
//
//  Created by M-Wageh on 02/07/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation

class BonatCodeInteractor{
    static let shared:BonatCodeInteractor = BonatCodeInteractor()
    var order:pos_order_class?

    private init(){
        
    }
    func isValid()->(result:Bool,mesg:String){
        if let order = order {
//            if (order.customer?.phone ?? "").isEmpty{
//                return (false, "Require customer mobile number".arabic("يجب تحديد رقم جوال العميل"))
//            }
            if (order.reward_bonat_code ?? "").isEmpty{
                return (false,"Require Bonat code".arabic("يجب ادخال كود بونات"))
            }
        }
        return (true,"")
    }
    func showErrorMessage(_ msg:String){
        SharedManager.shared.initalBannerNotification(title: "", message: msg , success: false, icon_name: "icon_error")
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
    }
    func checkRewardBonat(order:pos_order_class?,complete:@escaping (Bool)->Void){
        self.order = order
        if let order = order {
            let validator = self.isValid()
            if validator.result{
                SharedManager.shared.conAPI().hitCheckRewardBonatAPI(customer_mobile_number: order.customer?.phone, reward_code: order.reward_bonat_code ?? "") { result in
//                    SharedManager.shared.printLog(result.response?.toJSONString())
                    let code = result.response?["code"] as? Int ?? 1
                    if let data = result.response?["data"] as? [String:Any] {
                        let promo_bonat_class = promo_bonat_class(fromDictionary: data,order:order  )
                        promo_bonat_class.save()
                        complete(true)
                        return

                    }

                    if let error  = result.response?["errors"] as? String , !error.isEmpty{
                        self.showErrorMessage(error)
                        complete(false)
                        return

                    }
                    if let errors  = result.response?["errors"] as? [String] , errors.count > 0 {
                        self.showErrorMessage(errors.joined(separator: "/n"))
                        complete(false)
                        return


                    }
                }
            }else{
                showErrorMessage(validator.mesg)
                complete(false)

            }
        }
    }
    func redeemRewardBonat(order:pos_order_class?){
        self.order = order
        if let order = order {
            if let bonatPromo = promo_bonat_class.get(by:order.uid ?? "" , isVoid: false){
                SharedManager.shared.conAPI().hitCheckRedeemBonatAPI(promoBonat: bonatPromo) { result in
//                    SharedManager.shared.printLog(result.response?.toJSONString())
                    let code = result.response?["code"] as? Int ?? 1
                    if let data = result.response?["data"] as? [String:Any] {
                        bonatPromo.is_redeem = true
                        bonatPromo.save()
                    }
                    if let error  = result.response?["errors"] as? String , !error.isEmpty{
                        self.showErrorMessage(error)
                        return
                    }
                    if let errors  = result.response?["errors"] as? [String] , errors.count > 0 {
                        self.showErrorMessage(errors.joined(separator: "/n"))
                        return
                    }
                }
            }
        }
    }
}

extension api{
    
    func hitCheckRewardBonatAPI( customer_mobile_number:String?,reward_code:String, completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        let posConfig = SharedManager.shared.posConfig()
        var param: [String:Any]
        guard let url = URL(string:"\(posConfig.bonat_api_url ?? "")/dgtera/reward-check") else { return }
        if customer_mobile_number != nil {
            param = [
                "customer_mobile_number": customer_mobile_number!,
                "mobile_country_code": "SA",
                "reward_code": reward_code,
                "merchant_id":api.getDatabase()
            ]
        } else {
            param = [
                "reward_code": reward_code,
                "merchant_id":api.getDatabase()
            ]
        }
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Authorization" :  "Bearer \(posConfig.bonat_api_key ?? "")"
        ]
        callApi(url: url,keyForCash: getCashKey(key:"hitCheckRewardBonatAPI"),header: header, param: param, completion: completion);
        
    }
    func hitCheckRedeemBonatAPI(promoBonat:promo_bonat_class , completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        let posConfig = SharedManager.shared.posConfig()
        
        guard let url = URL(string:"\(posConfig.bonat_api_url ?? "")/dgtera/redeem") else { return }
        let param:[String:Any] = [
            "branch_id":"\(posConfig.branch_id ?? 0)",
            "date": promoBonat.updated_at ?? "",
            "customer_mobile_number": promoBonat.mobile_number ?? "",
            "mobile_country_code": "SA",
            "reward_code": promoBonat.promo_code ?? "",
            "merchant_id":api.getDatabase()
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Authorization" :  "Bearer \(posConfig.bonat_api_key ?? "")"
        ]
        callApi(url: url,keyForCash: getCashKey(key:"hitCheckRedeemBonatAPI"),header: header, param: param, completion: completion);
        
    }
    
}
class promo_bonat_class: NSObject {
    var dbClass:database_class?
    var id:Int?
    var is_percentage:Bool?
    var discount_amount:Double?
    var max_discount_amount:Double?
    var order_uid:String?
    var mobile_number:String?
    var promo_code:String?
    var is_void:Bool?
    var is_redeem:Bool?
    var updated_at:String?
    
    override init(){
        super.init()
    }
    
    
    init(fromDictionary dictionary: [String:Any],order:pos_order_class?){
        super.init()
        id = dictionary["id"] as? Int ?? 0
        if let order = order{
            order_uid = order.uid
            mobile_number = order.customer?.phone
            promo_code = order.reward_bonat_code

        }else{
            order_uid = dictionary["order_uid"] as? String
            mobile_number = dictionary["mobile_number"] as? String
            promo_code = dictionary["promo_code"] as? String


        }
        updated_at = dictionary["updated_at"] as? String
        is_redeem = dictionary["is_redeem"] as? Bool ?? false
        is_void = dictionary["is_void"] as? Bool ?? false
        is_percentage = dictionary["is_percentage"] as? Bool ?? false
        discount_amount = dictionary["discount_amount"] as? Double
        max_discount_amount = dictionary["max_discount_amount"] as? Double
        dbClass = database_class(table_name: "promo_bonat", dictionary: self.toDictionary(),id: id!,id_key:"id")

    }
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["is_void"] = is_void
        dictionary["order_uid"] = order_uid
        dictionary["mobile_number"] = mobile_number
        dictionary["is_percentage"] = is_percentage
        dictionary["discount_amount"] = discount_amount
        dictionary["max_discount_amount"] = max_discount_amount
        dictionary["promo_code"] = promo_code
        dictionary["is_redeem"] = is_redeem
//        dictionary["updated_at"] = updated_at

        return dictionary
    }
    func update(){
        if let exist = promo_bonat_class.get(by: self.order_uid ?? "" ,isVoid:  nil){
                exist.promo_code = self.promo_code
                exist.is_void = self.is_void
                exist.mobile_number = self.mobile_number
                exist.is_percentage = self.is_percentage
                exist.discount_amount = self.discount_amount
                exist.max_discount_amount = self.max_discount_amount
                exist.promo_code = self.promo_code
                exist.save()
        }else{
            self.save()
        }
    }
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id!
        dbClass?.insertId = false
        _ =  dbClass!.save()
    }
    static func void(for uid:String,isVoid:Bool ){
        var sql = """
        update promo_bonat set is_void = \( isVoid ? 1 : 0)
        WHERE order_uid = '\(uid)'
"""        
        database_class(connect: .database).runSqlStatament(sql:sql)
    }
    static func get(by uid:String,isVoid:Bool? = false)->promo_bonat_class?{
        var sql = """
        select *  from promo_bonat
        WHERE order_uid = '\(uid)'
"""
        if let isVoid = isVoid {
            sql += " and is_void = \( isVoid ? 1 : 0) ;"
        }else{
            sql += " ;"

        }
        
        if let dicRow = database_class(connect: .database).get_row(sql:sql) {
            return promo_bonat_class(fromDictionary: dicRow, order: nil)
        }
        return nil
    }
    static func getPosPromotion(for uid:String) ->pos_promotion_class?{
        if let promoBonat = promo_bonat_class.get(by: uid,isVoid: false){
            var objc = pos_promotion_class(fromDictionary: [:])
            let isPrecentage = (promoBonat.is_percentage ?? false)
            objc.active = true
            objc.promotionType = isPrecentage ? promotion_types.Discount_percentage_on_Total_Amount : promotion_types.Discount_fixed_on_Total_Amount //"dicount_total"
            objc.max_discount = promoBonat.max_discount_amount ?? 0
            let valueDiscount = (promoBonat.discount_amount ?? 0)
            objc.total_discount = isPrecentage ? (valueDiscount ) : ((valueDiscount * -1))
            objc.display_name = "Bonate"
            objc.discount_product_id = SharedManager.shared.posConfig().discount_program_product_id ?? -1
            return objc
        }
        return nil
    }
}
