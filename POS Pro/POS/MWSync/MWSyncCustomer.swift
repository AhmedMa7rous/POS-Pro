//
//  MWSyncCustomer.swift
//  pos
//
//  Created by M-Wageh on 09/04/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MWSyncCustomer{
    static func hitSyncCustomerAPI(complete:@escaping (_ result:api.api_Results?) -> () ){
        var lastDate:String? = nil
        let nameCashKey =  "lastupdate" + "_" + "get_customers"
        if let last_sync_time  = Int64(cash_data_class.get(key:nameCashKey) ?? ""){
            let dt = Date(millis: last_sync_time)
            lastDate  = dt.toString(dateFormat: "yyyy-MM-dd HH:mm:ss" , UTC: true)
        }
        
        SharedManager.shared.conAPI().get_customers_last_sync(lastDate) { (result) in
            if (result.success ?? false){
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                SharedManager.shared.printLog(list.count)
                if list.count > 0 {
                    res_partner_class.syncComing(list.map({res_partner_class(fromDictionary: $0)}))
                }
                cash_data_class.set(key: nameCashKey, value: String(Date.currentDateTimeMillis()))
            }
            complete(result)
        }
    }
    static func checkAndFectchCustomer(by partner_id:Int,orderId:Int){
        MWQueue.shared.mwDriverLockQueue.async {
            if SharedManager.shared.posConfig().pos_type?.lowercased().contains("driver_screen") ?? false{
                if res_partner_class.get(partner_id: partner_id) == nil {
                    SharedManager.shared.conAPI().get_customers_last_sync(partner_id:partner_id) { (result) in
                        if (result.success ?? false){
                            let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                            SharedManager.shared.printLog(list.count)
                            if list.count > 0 {
                                if let newPartners = list.map({res_partner_class(fromDictionary: $0)}).first{
                                    newPartners.dbClass?.insertId = false
                                     newPartners.save(temp: false)
                                    pos_order_class.updatePartnerRow(for:orderId , with: newPartners.row_id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func hitCreatCustomerAPI(){
        
    }
}
extension pos_order_class {
    static func updatePartnerRow(for id:Int , with partnerId:Int){
        let sql = "update pos_order set  partner_row_id = \(partnerId) where id = \(id)  "
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                let error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
}
extension load_base_apis{
    func get_customers_last_sync()
    {
        let item_key = "get_customers" ;
       /* var lastDate:String? = nil
        if let last_sync_time  = Int64(self.localCash?.getTimelastupdate(item_key) ?? ""){
            let dt = Date(millis: last_sync_time)
            lastDate  = dt.toString(dateFormat: "yyyy-MM-dd hh:mm:ss" , UTC: true)
            SharedManager.shared.printLog(lastDate)
            
        }
        */
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        MWSyncCustomer.hitSyncCustomerAPI { result in
            let _ = self.handleUI(item_key: item_key, result: result)
            self.runQueue()
        }
        
        /*
        con!.get_customers_last_sync(lastDate) { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                SharedManager.shared.printLog(list.count)
                if list.count > 0 {
                    res_partner_class.syncComing(list.map({res_partner_class(fromDictionary: $0)}))
                }
                self.localCash?.setTimelastupdate(item_key)
            }
            
            self.runQueue()
            
        }
        */
    }
}
extension res_partner_class {
    static func syncComing(_ listPartner:[res_partner_class]){
        let deletedPartner = listPartner.filter({!$0.active})
        if deletedPartner.count > 0 {
            let deletedPartnerIDS = deletedPartner.map({$0.id})
            res_partner_class.setActive(with: false, for: deletedPartnerIDS)
        }
        let activePartners = listPartner.filter({$0.active})
        if activePartners.count > 0 {
            let activeIDS = Set(activePartners.map({$0.id}))
            let idsQuery = "( " + activeIDS.map({"\($0)"}).joined(separator:",") + " )"
            var existIds:Set<Int> = []
            var newPartners:[res_partner_class] = []
            var updatedPartners:[res_partner_class] = []
            
            //select ids in database
            let result = database_class(connect: .database).get_rows(sql: "SELECT id FROM res_partner  WHERE id in \(idsQuery)")
            if result.count > 0 {
                existIds = Set(result.map{ ( $0["id"] as! Int)})
                if existIds.count > 0{
                    if existIds.count != activeIDS.count {
                        let newIDS = activeIDS.symmetricDifference(existIds)
                        newPartners = activePartners.filter({ partner in
                            let idPartner = partner.id
                            return newIDS.contains(idPartner)
                        })
                        
                    }
                    updatedPartners = activePartners.filter({ partner in
                        let idPartner = partner.id
                        return existIds.contains(idPartner)
                    })
                    if newPartners.count > 0 {
                        res_partner_class.makeSave(for: newPartners)
                    }
                    if updatedPartners.count > 0 {
                        res_partner_class.makeUpdate(for:updatedPartners)
                    }
                    
                }else{
                    res_partner_class.makeSave(for: activePartners)
                }
            }else{
                res_partner_class.makeSave(for: activePartners)
            }
            
        }
    }
    
    static func makeUpdate(for partners:[res_partner_class]){
        partners.forEach { comingPartner in
            res_partner_class.updateDB(with:comingPartner)
        }
        
    }
    static func makeSave(for partners:[res_partner_class]){
        partners.forEach { partner in
            partner.dbClass?.insertId = false
            partner.save(temp: false)
        }
        
    }
    static func setActive(with active:Bool = false , for ids:[Int] ){
        let activeValue = active ? 1 : 0
        let idsQuery = "( " + ids.map({"\($0)"}).joined(separator:",") + " )"
        _ = database_class(connect: .database).runSqlStatament(sql: "UPDATE res_partner set active = \(activeValue) WHERE id in \(idsQuery)")
    }
    static func updateDB(with comingPartner :res_partner_class){
        if let partnerDB = res_partner_class.get(partner_id: comingPartner.id) {
            partnerDB.id = comingPartner.id
            partnerDB.barcode = comingPartner.barcode
            partnerDB.city = comingPartner.city
            partnerDB.email = comingPartner.email
            partnerDB.mobile = comingPartner.mobile
            partnerDB.name = comingPartner.name
            partnerDB.phone = comingPartner.phone
            partnerDB.street = comingPartner.street
            partnerDB.vat = comingPartner.vat
            partnerDB.__last_update = comingPartner.__last_update
            partnerDB.zip = comingPartner.zip
            partnerDB.image = comingPartner.image
            partnerDB.country_Id = comingPartner.country_Id
            partnerDB.country_name = comingPartner.country_name
            partnerDB.loyalty_amount_remaining = comingPartner.loyalty_amount_remaining
            partnerDB.loyalty_points_remaining = comingPartner.loyalty_points_remaining
            partnerDB.blacklist = comingPartner.blacklist
            partnerDB.website = comingPartner.website
            partnerDB.function = comingPartner.function
            partnerDB.street2 = comingPartner.street2
            partnerDB.building_no = comingPartner.building_no
            partnerDB.district = comingPartner.district
            partnerDB.additional_no = comingPartner.additional_no
            partnerDB.other_id = comingPartner.other_id
            partnerDB.active = comingPartner.active
            partnerDB.discount_program_id = comingPartner.discount_program_id
            partnerDB.property_product_pricelist_id = comingPartner.property_product_pricelist_id
            partnerDB.property_product_pricelist_name = comingPartner.property_product_pricelist_name
            partnerDB.save()
        }
    }
}
extension api {
    func getFieldsPosCustomer()->[String]{
    let fields =  [
            "id","name","street","city","state_id","country_id","vat","image","country_name",
            "phone","zip","mobile","email","barcode","write_date",
            "property_product_pricelist","__last_update","barcode","discount_program_id",
            "loyalty_points_remaining", "loyalty_amount_remaining" ,"blacklist","website","function","street2","building_no",
            "district","additional_no","other_id","parent_id","res_partner_id","parent_partner_id", "active"
        ]
        /*
        let fields =  [
              "id","name","street","city","state_id","country_id","vat",
              "phone","zip","mobile","email","write_date",
              "property_product_pricelist","__last_update",
              "street2",
              "parent_id","res_partner_id","parent_partner_id"
          ]*/
        return fields
    }
    func get_customers_last_sync(_ lastDate:String? = nil,partner_id:Int? = nil, completion: @escaping (_ result: api_Results) -> Void)  {
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let item_key = "get_customers" ;
        let company_id = SharedManager.shared.posConfig().company_id
        
        var domainParamter:[Any] = []
        if let lastDate = lastDate , !lastDate.isEmpty{
            domainParamter.append(["write_date",">", lastDate ])
            domainParamter.append("|")
            domainParamter.append(["active","=",true])
            domainParamter.append(["active","=",false])
        }else if let partner_id = partner_id {
            domainParamter.append(["id","=",partner_id])
        }else
        {
            domainParamter.append(fillter_date())
            domainParamter.append(["active","=",true])
        }
        
        
//        domainParamter.append(["customer","=",true])
//        domainParamter.append(["pos_customer","=",true])
        domainParamter.append("|")
        domainParamter.append(["company_id","=",false])
        domainParamter.append(["company_id","=",company_id!])
            //"!", ["child_ids", "!=", []],
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.customer",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": self.getFieldsPosCustomer(),
                    "domain": domainParamter,
                    "offset": 0,
                    "limit": false,
                    "context": get_context(extra_fields: ["pos_delivery_area_id"])
                    
                ]
                //                "context": get_context()
            ]
            
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: item_key),header: header, param: param, completion: completion);
        
    }
}
