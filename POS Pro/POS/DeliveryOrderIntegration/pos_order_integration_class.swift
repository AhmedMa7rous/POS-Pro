//
//  pos_order_integration_class.swift
//  pos
//
//  Created by M-Wageh on 02/10/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

enum INTEGRATION_STATUS:Int{
    case NONE = 0 , ACCEPT
}
class pos_order_integration_class: NSObject {
    var dbClass:database_class?
    
    var id:Int?
    var order_uid:String?
    var time_out_duration:Int?
    var receive_datetime:String?
    var write_datetime:String?
    var is_paid:Bool?
    var online_order_source : String?
    var force_payment_journal_id:Int?
    var amount_total:String?
    var order_status:orderMenuStatus = .none
    var pos_order:pos_order_class?{
        get{
            if let uid = self.order_uid {
                return pos_order_class.get(uid: uid)
            }
            return nil
        }
    }
    var accountJournal:account_journal_class?{
        get{
            if let accountJournalID = self.force_payment_journal_id {
                return account_journal_class.get(id:  accountJournalID)
            }
            return nil
        }
    }
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        order_uid = dictionary["order_uid"] as? String ?? ""
        time_out_duration = dictionary["time_out_duration"] as? Int
        receive_datetime = dictionary["receive_datetime"] as? String ?? ""
        online_order_source = dictionary["online_order_source"] as? String ?? ""
        force_payment_journal_id = dictionary["force_payment_journal_id"] as? Int
        amount_total = dictionary["amount_total"] as? String ?? ""
        
        order_status = orderMenuStatus.init(rawValue:  dictionary["order_status"] as? Int ?? 0)!
        write_datetime = dictionary["write_datetime"] as? String ?? ""
        is_paid = dictionary["is_paid"] as? Bool ?? false
        
        dbClass = database_class(table_name: "pos_order_integration", dictionary: self.toDictionary(),id: id!,id_key:"id")
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["order_uid"] = order_uid
        dictionary["time_out_duration"] = time_out_duration
        dictionary["receive_datetime"] = receive_datetime
        dictionary["online_order_source"] = online_order_source
        dictionary["force_payment_journal_id"] = force_payment_journal_id
        dictionary["order_status"] = order_status.rawValue
        dictionary["amount_total"] = amount_total
        dictionary["write_datetime"] = write_datetime
        dictionary["is_paid"] = is_paid
        
        return dictionary
        
    }
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id!
        dbClass?.insertId = false
        _ =  dbClass!.save()
    }
    
    
    static func getPending()-> [pos_order_integration_class]
    {
        
        let cls = pos_order_integration_class(fromDictionary: [:])
        let dicObjects =  cls.dbClass!.get_rows(whereSql: " where  order_status = 1"  )
        return dicObjects.map({ pos_order_integration_class(fromDictionary: $0)})
        
        
    }
    
    static func get(order_uid:String)-> pos_order_integration_class?
    {
        
        let cls = pos_order_integration_class(fromDictionary: [:])
        if let dicObject =  cls.dbClass!.get_row(whereSql: " where order_uid = '\(order_uid)' "  ) {
            return pos_order_integration_class(fromDictionary: dicObject)
        }
        return nil
        
    }
    static func initializeFrom(dic:[String:Any]) {
        let uid = dic["uid"] as? String ?? ""
        var pos_integration = pos_order_integration_class(fromDictionary: [:])
        if let exist_order =  pos_order_integration_class.get(order_uid: uid) {
            pos_integration = exist_order
        }
        pos_integration.order_uid = uid
        pos_integration.time_out_duration =  dic["timeout_duration"] as? Int
        pos_integration.receive_datetime = dic["receive_datetime"] as? String
        pos_integration.online_order_source = dic["online_order_source"] as? String
        pos_integration.amount_total = "\(dic["amount_total"] as? Double ?? 0.0)"
        pos_integration.order_status = .pendding
        pos_integration.is_paid = dic["is_paid"] as? Bool ?? false

        if let accountJournalId = dic["force_payment_journal_id"] as? Int
        {
            pos_integration.force_payment_journal_id = accountJournalId
            let account_journal_type = account_journal_class.get(id: accountJournalId)?.type ?? ""
            //TODO: - exclude is_paid in case delivert
            if pos_integration.online_order_source != "deliverect"{
                pos_integration.is_paid =  account_journal_type.lowercased().contains("bank")
            }
        }
        if let cancel_online_order:Bool = dic["cancel_online_order"] as? Bool , cancel_online_order{
            pos_integration.order_status = .cancelling
        }

        pos_integration.save()
    }
    func doPayment(){
        guard let account = self.accountJournal else {return}
        account.tendered =  self.amount_total ?? ""
        account.due =  account.tendered.toDouble()!
        if let order = self.pos_order {
            order.list_account_journal = [account]
            order.is_closed = true
            order.is_sync = false
            order.save(write_info: false, re_calc: false)
            let option = ordersListOpetions()
            option.parent_product = true
            let order_copy = order.copyOrder(option: option)
            order_copy.list_account_journal.append(contentsOf: order.list_account_journal)
            if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
                order_copy.printOrderByMWqueue()
                MWRunQueuePrinter.shared.startMWQueue()
            }else{
                SharedManager.shared.printOrder(order_copy,nil,openDeawer: false)
            }
            NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: order.uid,userInfo: nil)
        }
        
    }
    func hasTimeOut()->Bool{
           return (self.time_out_duration ?? 0) > 0
    }
}

extension pos_order_class {
    func addForceJournalByOwner(){
        if self.is_closed {
            if let accountJournalID = SharedManager.shared.posConfig().force_update_journal_id {
                if let account = account_journal_class.get(id:  accountJournalID){
                    account.tendered =  "\(self.amount_total)"
                    account.due =  account.tendered.toDouble()!
                    self.list_account_journal = [account]
                    self.save(write_info: false,re_calc: false)
                }
                
            }
        }
    }
}
