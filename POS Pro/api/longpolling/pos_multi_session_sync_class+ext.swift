//
//  pos_multi_session_sync_class+ext.swift
//  pos
//
//  Created by Khaled on 5/6/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

extension pos_multi_session_sync_class
{
    
    
    func check_poll()
    {
//        if mwIpPos {
//            return
//        }
        if is_running == true
        {
            print("is_running ==== \(is_running)")
            return
        }
        
        
        if get_run_id() == 0
        {
            return
        }
        
        
        
        
        
        if load_kds == false
        {
            let active_session = pos_session_class.getActiveSession()
            if active_session == nil
            {
                return
            }
        }
        
        
        
        
        is_running = true
        remove_old_pendding_orders()
        
        
        
        
        
        //        pos_order_helper_class.delete_old_order(older_than_date: baseClass.get_date_now_formate_datebase(),is_pendding: true)
        //         pos_order_helper_class.delete_all_order()
        //                pos_order_line_class.delete_all()
        //                return
        
        if last_id == nil || last_id == 0// in start app
        {
            //            if load_kds == true
            //            {
            //                // reset data
            //
            //                pos_order_helper_class.delete_old_order(older_than_date: baseClass.get_date_now_formate_datebase(),is_pendding: true)
            //                pos_order_line_class.delete_all()
            //
            //            }
            
            
            sync_all_running = true
            get_orders_sync_all_online()
            sync_all_running = false
            get_last_id()
            self.is_running = false
            
        }
        else
        {
            last_id =  pos_multi_session_sync_class.get_last_id()
            sync_all_running = false
 if !SharedManager.shared.appSetting().enable_retry_long_poll{
            poll_request()
        }
                    self.is_running = false

        }
        
        
        
        
        
    }
    
    func remove_old_pendding_orders()
    {
        
        if load_kds == true
        {
            let setting = SharedManager.shared.appSetting()
            if setting.clearPenddingOrders_every_hour != 0
            {
                
                let days = SharedManager.shared.appSetting().clearPenddingOrders_every_hour * -1
                
                let date_now:Date = Date().localDate()
                let minutes = Int( days  * 60 );
                let older_date = date_now.add(minutes: minutes)
                let older_date_str =  older_date?.toString(dateFormat:baseClass.date_formate_database) ?? ""
                
                pos_order_helper_class.delete_old_order(older_than_date: older_date_str,is_pendding: true)
                
            }
        }
        
        
    }
    
    func get_run_id() -> Int?
    {
        if run_ID != 0
        {
            return run_ID
        }
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        con.get_run_id_poll { (result) in
            let rows = result.response!["result"] as? [[String:Any]] ?? []
            if rows.count > 0
            {
                let dic = rows[0]
                self.run_ID = dic["run_ID"] as? Int
                if let id_run = self.run_ID{
                    cash_data_class.set(key: "cash_run_ID", value:  "\(id_run)")
                }

            }
            
            semaphore.signal()
            
        }
        
        semaphore.wait()
        
        
        return run_ID
    }
    
    
    func get_orders_sync_all_online(uid:String? = nil,last_id:Int = 0,complete: (()->())? = nil)
    {
        
        if SharedManager.shared.appSetting().enable_add_waiter_via_wifi{
            return
        }
        let semaphore = DispatchSemaphore(value: 0)
        
        let cls_poll = pos_multi_session_sync_class()
        cls_poll.run_ID = run_ID
        
        con.userCash = .stopCash
        con.timeout = con_timeout
        con.pos_multi_session_sync_all(poll: cls_poll,uid:uid ) { (result) in
            
            let rows = result.response!["result"] as?  [String:Any]  ?? [:]
            if  let data_rows = rows["data"] as?  [String:Any], let orders = data_rows["orders"] as?  [[String:Any]] {
                let ordersData = orders.compactMap({$0["data"] as? [String:Any]})

            //Wain
            //    DispatchQueue.global(qos: .background).async {
                    
                    pos_multi_session_sync_class.clear()
//                    pos_order_class.remove_pending_orders(uid: uid)
//                    SharedManager.shared.removeAllUid()
                    let sortOrders = ordersData.sorted { order1, order2 in
                       if let seq1 = order1["sequence_multisession"] as? Int,
                          let seq2 = order2["sequence_multisession"] as? Int{
                          return seq1 > seq2
                       }
                        return true
                    }
                    pos_multi_session_sync_class.clear()
                    let allUID = sortOrders.compactMap({$0["uid"] as? String})
                    for uidCome in allUID {
                        if !SharedManager.shared.checkUidRead(uidCome){
                            pos_order_class.remove_pending_orders(uid: uidCome)
                        }
                    }
                    if allUID.count > 0 {
                        pos_order_class.remove_pending_orders_not_in(uids: allUID)
                    }
                    if let uid = uid {
                        pos_order_class.remove_pending_orders(uid: uid)
                    }
//                    SharedManager.shared.removeAllUid()
                    NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: nil,userInfo: [:])
                    var count = 0
                    for item in orders
                    {
                        if let dataItem = item["data"] as? [String:Any], let uid = dataItem["uid"] as? String{
                            if !SharedManager.shared.checkUidRead(uid){
                                self.handle_action(last_id:last_id,message: item)
                            }
                        }

//                        self.handle_action(last_id:last_id,message: item)
                    }
             //   }
            }
            complete?()

            semaphore.signal()
            
        }
        semaphore.wait()
    }
    
    func ping()
    {
        let semaphore = DispatchSemaphore(value: 0)
        
        con.userCash = .stopCash
        con.timeout = con_timeout
        con.pos_multi_session_ping() { (result) in
            
            
            semaphore.signal()
            
        }
        semaphore.wait()
    }
    
    func get_last_id()
    {
        ping()
        poll_request()
    }
    
    func poll_request()  {
        if (cash_data_class.get(key: "is_first_lanuch") ?? "").isEmpty || ((cash_data_class.get(key: "is_first_lanuch") ?? "") == "1"){
            return
        }
        let semaphore = DispatchSemaphore(value: 0)
        
        con.userCash = .stopCash
        con.timeout = 45
        con.longpolling_poll(pos_id: pos_id, last_id: last_id ?? 0) { (result) in
           // FireBaseService.defualt.updateForceLongPolling()
            let rows = result.response!["result"] as? [[String:Any]] ?? []
            
            self.list_exist_message_id.removeAll()
               
                for item in rows
                {
                    
                    let  id = item["id"] as? Int ?? 0
                    let message = item["message"] as? [String:Any]
                    
                    
                    if message == nil
                    {
                        let msg = item["message"] as? String ?? ""
                        if msg == "PONG"
                        {
                            self.last_id = id
                            
                            pos_multi_session_sync_class.save_last_id(last_id: id)
                        }
                    }
                    else
                    {
                        if self.last_id != nil
                        {
                            self.last_id = id
                            pos_multi_session_sync_class.save_last_id(last_id: id)
                            
                            self.handle_action(last_id:id,message: message!)
                        }
                        
                        
                    }
                    
                    
                    
                    
                }
            if SharedManager.shared.appSetting().enable_retry_long_poll{
                let error = (result.response!["error"] as? String)
                if error != "The request timed out."{
                    MWQueue.shared.mwReTryPollQueue.asyncAfter(deadline: .now() + .seconds(self.scandWait), execute: {
                        self.scandWait += 1
                        self.poll_request()
                    })
                }else{
                    MWQueue.shared.mwReTryPollQueue.async {
                        self.scandWait = 1
                        self.poll_request()
                    }
                }
            }
            
            semaphore.signal()
            
        }
        semaphore.wait()
    }
    
    func is_duplicate_message(data:[String:Any]) -> Bool
    {
        
        let message_ID =  data["message_ID"] as? Int ?? 0
        if message_ID != 0
        {
            let logClass = logClass(fromDictionary: [:])
            
            if list_exist_message_id.contains(message_ID)
            {
                logClass.data = "[error] Can't pasrs data as duplicate_message loging polling /n \(data.toJSONString() ?? "")"
                logClass.key = "[\(message_ID)] duplicate_message "
                logClass.prefix = "error"
                logClass.save()
               
                if SharedManager.shared.appSetting().enable_check_duplicate_message_ids {
                    return true
                }
            }
        }
        
        
        list_exist_message_id.append(message_ID)
        
        return false
    }
    
    func handle_action(last_id:Int,message:[String:Any],with notify:Bool = true)
    {
        if !message.isEmpty
        {
            let action = message["action"] as? String ?? ""
            let data = message["data"] as? [String:Any] ?? [:]
            
            if action == "sync_all"
            {
                self.handle_sync_all(id:last_id,data: data)
            }
            else if action == "update_order"
            {
                
                self.handle_update_order(id:last_id,data: data)
                
            }
            else if action == "remove_order"
            {
                self.handle_remove_order(id:last_id,data: data)
                
            }
            
        }
    }
    
    func handle_sync_all(id:Int,data: [String:Any])
    {
        let orders = data["orders"] as? [[String:Any]] ?? []
        for order in orders
        {
            
            handle_action(last_id: id,   message: order)
            
            
        }
        
        
    }
    
    func handle_update_order(id:Int,data: [String:Any],with notify:Bool = true)
    {
        
        
        
        
        let uid = data["uid"] as? String ?? ""
        let cls = pos_multi_session_sync_class.get(uid: uid)
        //        let cls = pos_multi_session_sync_class(fromDictionary: [:])
        
        if  !uid.isEmpty
        {
            cls.uid = uid
            cls.last_id = id
            cls.name = data["name"] as? String ?? ""
            cls.action = "update_order"
            cls.revision_ID = data["revision_ID"] as? Int ?? 0
            cls.run_ID = data["run_ID"] as? Int ?? 0
            cls.pos_id = data["pos_id"] as? Int ?? 0
            cls.message_ID = data["message_ID"] as? Int ?? 0
            cls.order_on_server = data["order_on_server"] as? Bool ?? false
            cls.new_order = data["new_order"] as? Bool ?? false
            
            cls.data = data.jsonString()
            cls.save()
            
            
            
            if check_is_send_to_kds(data: data) == false
            {
                return
            }
            
            
            
            if is_duplicate_message(data: data)
            {
                return
            }
            
            let pos_config = SharedManager.shared.posConfig()
            if pos_config.multi_session_accept_incoming_orders == false
            {
                self.handle_update_accept_incoming_orders(data)
                return
            }
            
            
            
            
            
            //            if load_kds == true
            //            {
            read_order(data: data,with: notify)
            //            }
        }
        
        
    }
    
    private func handle_update_accept_incoming_orders(_ data:[String:Any]){
        let pos_config = SharedManager.shared.posConfig()
        let ms_info = data["ms_info"] as? [String:Any] ?? [:]
        let created = ms_info["created"] as? [String:Any] ?? [:]
        if !created.isEmpty
        {
//            let user = created["user"] as? [String:Any] ?? [:]
//            let user_id = user["id"] as? Int ?? 0
            let pos = created["pos"] as? [String:Any] ?? [:]
            let created_pos_id = pos["id"] as? Int ?? 0
//            let chasher = SharedManager.shared.activeUser()
            if ( created_pos_id == pos_config.id ){
                read_order(data: data)
            }
        }
        return
    }
    
    func check_is_send_to_kds(data:[String:Any]) -> Bool
    {
        if load_kds == false
        {
            return true
        }
        
        let lines = data["lines"] as? [Any] ?? []
        if lines.count == 0 // empty order
        {
            return true
        }
        
        for item in lines
        {
            let row = item as? [Any] ?? []
            
            if row.count == 3
            {
                let dic = row[2] as? [String:Any] ?? [:]
                let kitchen_status = kitchen_status_enum.init(rawValue:  dic["kitchen_status"] as? Int ?? 0)!
                
                if kitchen_status == .send
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    func handle_remove_order(id:Int,data: [String:Any])
    {
        if is_duplicate_message(data: data)
        {
            return
        }
        
        let uid = data["uid"] as? String ?? ""
        let cls = pos_multi_session_sync_class.get(uid: uid)
        if  !uid.isEmpty
        {
            cls.uid = uid
            cls.last_id = id
            cls.action = "remove_order"
            cls.revision_ID = data["revision_ID"] as? Int ?? 0
            cls.run_ID = data["run_ID"] as? Int ?? 0
            cls.pos_id = data["pos_id"] as? Int ?? 0
            cls.message_ID = data["message_ID"] as? Int ?? 0
            cls.data = data.jsonString()
            cls.save()
            
            
            let pos_config = SharedManager.shared.posConfig()
            if pos_config.multi_session_accept_incoming_orders == false
            {
                return
            }
            
            
            let opetions = ordersListOpetions()
            opetions.Closed = false
            opetions.Sync = false
            opetions.void = false
            opetions.uid = uid
            
            let arr = pos_order_helper_class.getOrders_status_sorted(options: opetions)
            if arr.count > 0
            {
                let order = arr[0]
                
                if order.write_user_id != SharedManager.shared.activeUser().id
                {
                    // last change from server
                    
                    pos_order_helper_class.delete_order(order_id: order.id!)
                }
                else
                {
                    // last change from local
                    order.is_void = true
                    order.save()
                }
                
                
                
            }
            
            NotificationCenter.default.post(name: Notification.Name("poll_remove_order"), object: uid)
            
            
        }
        
    }
    
    func create_new_order(data:[String:Any],needSave:Bool = true) -> pos_order_class
    {
        let orderNew:pos_order_class = pos_order_class(fromDictionary: [:])
        
        var activeSession_id = 0
        if load_kds == false
        {
            if let sequence_multisession = data["sequence_multisession"] as? Int {
                orderNew.sequence_number = sequence_multisession
            }else{
                if let online_sequence_number = data["online_sequence_number"] as? Int {
//                    orderNew.sequence_number = online_sequence_number
                    orderNew.delivery_type_reference = "\(online_sequence_number)"
                    let invoiceID = orderNew.generateInviceID(session_id: pos_session_class.getActiveSession()?.id ?? 1 )
                    if SharedManager.shared.appSetting().enable_sequence_orders_over_wifi {
                        if let seqNum = SharedManager.shared.getSequenceFromMultipeer() {
                            if  seqNum > invoiceID {
                                orderNew.sequence_number  =  seqNum
                            }else{
                                orderNew.sequence_number  =  invoiceID
                            }
                            SharedManager.shared.sendNewSeqToPeers(nextSeq: orderNew.sequence_number)
                        }else{
                            orderNew.sequence_number  =  invoiceID
                        }
                    }else{
                        orderNew.sequence_number  =  invoiceID
                    }
                    
                }else{
                    orderNew.sequence_number = data["sequence_number"] as? Int ?? 0
                }
            }
            /*
            activeSession_id = pos_session_class.getActiveSession()?.id ?? 0
            let invoiceID = orderNew.generateInviceID(session_id: pos_session_class.getActiveSession()?.id ?? 1 )
            orderNew.sequence_number = invoiceID
            if SharedManager.shared.appSetting().enable_sequence_orders_over_wifi {
                if let seqNum = SharedManager.shared.getSequenceFromMultipeer() {
                    if  seqNum > invoiceID {
                        orderNew.sequence_number  =  seqNum
                    }else{
                        orderNew.sequence_number  =  invoiceID
                    }
                    SharedManager.shared.sendNewSeqToPeers(nextSeq: orderNew.sequence_number)
                }
            }
             */
        }
        else
        {
            //sequence_multisession
//            orderNew.sequence_number = data["sequence_number"] as? Int ?? 0
            if let sequence_multisession = data["sequence_multisession"] as? Int {
                orderNew.sequence_number = sequence_multisession
            }else{
                if let online_sequence_number = data["online_sequence_number"] as? Int {
//                    orderNew.sequence_number = online_sequence_number
                    orderNew.delivery_type_reference = "\(online_sequence_number)"
                    let invoiceID = orderNew.generateInviceID(session_id: pos_session_class.getActiveSession()?.id ?? 1 )
                    if SharedManager.shared.appSetting().enable_sequence_orders_over_wifi {
                        if let seqNum = SharedManager.shared.getSequenceFromMultipeer() {
                            if  seqNum > invoiceID {
                                orderNew.sequence_number  =  seqNum
                            }else{
                                orderNew.sequence_number  =  invoiceID
                            }
                            SharedManager.shared.sendNewSeqToPeers(nextSeq: orderNew.sequence_number)
                        }else{
                            orderNew.sequence_number  =  invoiceID
                        }
                    }else{
                        orderNew.sequence_number  =  invoiceID
                    }
                    
                }else{
                    orderNew.sequence_number = data["sequence_number"] as? Int ?? 0
                }
            }
        }
        
        orderNew.is_closed = false
        orderNew.is_sync = false
        orderNew.session_id_local = activeSession_id
        orderNew.user_id = data["user_id"] as? Int ?? 0
        orderNew.pricelist_id = data["pricelist_id"] as? Int ?? 0
        if let custmerID = data["pos_customer_id"] as? Int{
            orderNew.partner_id = custmerID
        }else{
            orderNew.partner_id = data["partner_id"] as? Int ?? 0
        }
        if let driver_id = data["driver_id"] as? Int , driver_id != 0{
            orderNew.driver_id = driver_id
        }
        
        orderNew.pos_id = data["pos_id"] as? Int ?? 0
        orderNew.company_id = SharedManager.shared.posConfig().company_id
        orderNew.delivery_type_id = data["delivery_method_id"] as? Int ?? 0
        
        orderNew.pos_order_lines = []
        
        orderNew.create_date =   data["create_date"] as? String ?? ""
        orderNew.write_date =  data["write_date"] as? String ?? ""
        orderNew.brand_id = data["brand_id"] as? Int ?? 0
        if orderNew.create_date!.isEmpty
        {
            orderNew.create_date =  baseClass.get_date_now_formate_datebase()
        }
        
        //        if orderNew.write_date!.isEmpty
        //        {
        //                 orderNew.write_date =  baseClass.get_date_now_formate_datebase()
        //         }
        //
        
        orderNew.name = data["name"] as? String ?? ""
        orderNew.uid = data["uid"] as? String ?? ""
        orderNew.bill_uid = data["bill_uid"] as? String ?? ""
        orderNew.pickup_user_id = data["pickup_user_id"] as? Int ?? 0
        orderNew.need_print_bill = data["need_print_bill"] as? Bool ?? false
        orderNew.force_update_order_owner = data["force_update_order_owner"] as? Bool ?? false

        if needSave {
        orderNew.save()
        }
        
        return orderNew
    }
    
    func check_partner(data:[String:Any])
    {
        let  partner :[String:Any] = data["partner"] as? [String:Any] ?? [:]
        let phone = partner["phone"] as? String ?? ""
        let customer = res_partner_class.get(phone: phone)
        if customer == nil
        {
            let new_customer = res_partner_class(fromDictionary: [:])
            new_customer.id = data["partner_id"] as? Int ?? 0
            new_customer.name = partner["name"] as? String ?? ""
            new_customer.phone = partner["phone"] as? String ?? ""
            new_customer.street = partner["street"] as? String ?? ""
            new_customer.city = partner["city"] as? String ?? ""
            new_customer.zip = partner["zip"] as? String ?? ""
            new_customer.email = partner["email"] as? String ?? ""
            new_customer.save()
            
        }
    }
    func read_order(data:[String:Any],with notify:Bool = true)
    {
        
        
        let ms_info = data["ms_info"] as? [String:Any] ?? [:]
        let changed = ms_info["changed"] as? [String:Any] ?? [:]
        let pos = changed["pos"] as? [String:Any] ?? [:]
        let changed_pos_id = pos["id"] as? Int ?? 0
        let is_menu:Bool = data["is_menu"] as? Bool ?? false
        let is_delivery_order_integration:Bool = data["is_online_order"] as? Bool ?? false
        let cancel_online_order:Bool = data["cancel_online_order"] as? Bool ?? false
let isKDSOnly = data["kds_only"] as? Bool ?? false
        
        let isNeedToPrint = data["need_print_bill"] as? Bool ?? false
        let isForceUpdateByOWner = data["force_update_order_owner"] as? Bool ?? false
        

        let uid = data["uid"] as? String ?? ""
        let platform_name = data["platform_name"] as? String ?? ""
        if SharedManager.shared.checkUidRead(uid){
//            read_order(data:data)
            return
        }
        SharedManager.shared.addUidRead(uid)

        let opetions = ordersListOpetions()
        //        opetions.Closed = false
        //        opetions.Syncl = false
        opetions.uid = uid
        
        let arr = pos_order_helper_class.getOrders_status_sorted(options: opetions)
        var order:pos_order_class!
        
        var is_new_order = false
        if arr.count == 0
        {
            // create New Order on local
            order = create_new_order(data: data)
            order.write_date = ""
            is_new_order = true
        }
        else
        {
            order = arr[0]
            order.orderTypeCashing = nil
            
            if load_kds == false
            {
                //                if order.sequence_number_server == 0
                //                  {
                //                        order.sequence_number_server = data["sequence_number"] as? Int ?? 0
                //                     order.save(write_info: false, updated_session_status: .last_update_from_local )
                //
                //                     // just update sequence_number
                //                     return
                //                   }
            }
            
        }
        order.force_update_order_owner = isForceUpdateByOWner
        if  order.order_integration  == .NONE ||  order.order_integration  == .POS  {
        order.order_integration = is_delivery_order_integration ? .DELIVERY : is_menu ? .ONLINE : .POS
            
        }

        
        
        if  order.order_integration == .POS
        {
            
                if changed_pos_id == SharedManager.shared.posConfig().id
                {
                    if (order.session_id_local == -1) {
                        let activeSession_id = pos_session_class.getActiveSession()?.id ?? 0
                        order.session_id_local = activeSession_id
                        order.save(write_info: false,re_calc: false)
                        SharedManager.shared.removeUidRead(uid)

                        return
                    }else if let preparation_time =   data["kds_preparation_total_time"] as? Int {
                        order.kds_preparation_total_time = preparation_time
                        order.save(write_info: false,re_calc: false)

                    }
                    if !(SharedManager.shared.appSetting().enable_force_update_by_owner && (order.force_update_order_owner ?? false)) {
                        let activeSession_id = pos_session_class.getActiveSession()?.id ?? 0
                        order.session_id_local = activeSession_id
                        order.save(write_info: false,re_calc: false)
                        SharedManager.shared.removeUidRead(uid)

                        return
                    }
                }
         
        }
        else
        {
            if cancel_online_order {
                if let posOrderIntegration = order.pos_order_integration {
                    DeliveryOrderIntegrationInteractor.shared.doCancel(for: posOrderIntegration)
                    SharedManager.shared.removeUidRead(uid)

                    return
                }
                
            }
            if  changed_pos_id == SharedManager.shared.posConfig().id  && order.order_menu_status != .none
            {
                if (order.session_id_local == -1) {
                    let activeSession_id = pos_session_class.getActiveSession()?.id ?? 0
                    order.session_id_local = activeSession_id
                    order.save(write_info: false,re_calc: false)
                    SharedManager.shared.removeUidRead(uid)

                    return
                }
                if !(SharedManager.shared.appSetting().enable_force_update_by_owner && (order.force_update_order_owner ?? false)) {
                    SharedManager.shared.removeUidRead(uid)

                    return
                }
            }
            
            check_partner(data: data)
        }
        if SharedManager.shared.appSetting().enable_force_update_by_owner {
            if !(order.force_update_order_owner ?? false){
                if order.is_closed == true && !is_new_order
                {
                    SharedManager.shared.removeUidRead(uid)

                    return
                }
            }
        }else{
            if order.is_closed == true && !is_new_order
            {
                SharedManager.shared.removeUidRead(uid)

                return
            }
        }
        //       let server_write_date = data["write_date"] as? String ?? ""
        if order.order_integration == .DELIVERY {
            if order.order_menu_status != .pendding  && order.order_menu_status != .none {
                SharedManager.shared.removeUidRead(uid)

                 return
             }
            order.platform_name = platform_name
            pos_order_integration_class.initializeFrom(dic:data )
        }
        if let brandID = data["brand_id"] as? Int{
            order.brand_id = brandID
        }
        if let qrCodeOffline = data["qr_code_value_offline"] as? String {
            var dictionary_e_invoice:[String:Any] = [:]
            dictionary_e_invoice["order_uid"] = data["uid"] as? String ?? (order.uid ?? "")
            dictionary_e_invoice["qr_code_value"] = qrCodeOffline
            pos_e_invoice_class(fromDictionary: dictionary_e_invoice).save()
        }
        order.name = data["name"] as? String ?? (order.name  ?? "")
        order.uid = data["uid"] as? String ?? (order.uid ?? "")
        order.bill_uid = data["bill_uid"] as? String ?? (order.bill_uid ?? "")
        order.driver_id = data["driver_id"] as? Int ?? 0 //?? (order.table_id ?? 0)


        //        if sync_all_running == false
        //        {
        // update time changes
        //            order.write_date =  baseClass.get_date_now_formate_datebase()
        //        }
        //[BUG] cancel table from multisession
        order.guests_number = data["guests_number"] as? Int
        order.table_id = data["table_id"] as? Int ?? 0 //?? (order.table_id ?? 0)
        order.table_name = data["table_name"] as? String ?? "" //??  (order.table_name ?? "")
        order.floor_name = data["floor_name"] as? String ?? "" //?? (order.floor_name ?? "")
        order.delivery_type_reference = data["delivery_type_reference"] as? String ?? "" //??  ( order.delivery_type_reference ?? "")
        
        
        order.note = data["note"] as? String ?? (order.note )
        order.amount_paid = data["amount_paid"] as? Double ?? (order.amount_paid )
        order.amount_total = data["amount_total"] as? Double ?? (order.amount_total  )
        order.amount_tax = data["amount_tax"] as? Double ?? (order.amount_tax  )
        order.amount_return = data["amount_return"] as? Double ?? (order.amount_return )
        
        order.pricelist_id = data["pricelist_id"] as? Int ?? (order.pricelist_id ?? 0)
        //[BUG] cancel customer from multisession
        if let custmerID = data["pos_customer_id"] as? Int, custmerID != 0{
            order.partner_id = custmerID
        }else{
             if let partnerID = data["partner_id"] as? Int , partnerID != 0{
                order.partner_id = partnerID
        }else{
            let partnerRowID =  data["partner_row_id"] as? Int  ?? 0
            if partnerRowID == 0 {
                order.partner_row_id = partnerRowID
                order.partner_id = 0
            }
        }
        }
        order.user_id = data["user_id"] as? Int ?? (order.user_id ?? 0)
     
        if  order.pickup_user_id == 0{
            order.pickup_user_id = data["pickup_user_id"] as? Int ?? 0
        }else{
            if SharedManager.shared.posConfig().pos_type?.lowercased().contains("driver_screen") ?? false{
                order.pickup_user_id = data["pickup_user_id"] as? Int ?? 0
            }
        }
      
        order.pickup_write_date = data["pickup_write_date"] as? String
        order.pickup_write_user_id = data["pickup_write_user_id"] as? Int

//        order.sequence_number = data["sequence_number"] as? Int ?? 0
        if let sequence_multisession = data["sequence_multisession"] as? Int {
            order.sequence_number = sequence_multisession
        }else{
            if let online_sequence_number = data["online_sequence_number"] as? Int{
                if order.order_integration == .ONLINE {
                order.delivery_type_reference = "\(online_sequence_number)"
                }
                /*
                let invoiceID = order.generateInviceID(session_id: pos_session_class.getActiveSession()?.id ?? 1 )
                if SharedManager.shared.appSetting().enable_sequence_orders_over_wifi {
                    if let seqNum = SharedManager.shared.getSequenceFromMultipeer() {
                        if  seqNum > invoiceID {
                            order.sequence_number  =  seqNum
                        }else{
                            order.sequence_number  =  invoiceID
                        }
                        SharedManager.shared.sendNewSeqToPeers()
                    }else{
                        order.sequence_number  =  invoiceID
                    }
                }else{
                    order.sequence_number  =  invoiceID
                }
                */
                
            }else{
                order.sequence_number = data["sequence_number"] as? Int ?? (order.sequence_number  )
            }
        }

        order.delivery_type_id = data["delivery_method_id"] as? Int ?? (order.delivery_type_id ?? 0)
        if load_kds == false
        {
            let activeSession_id = pos_session_class.getActiveSession()?.id ?? 0
            order.session_id_local = activeSession_id
        }
        order.is_closed = data["is_closed"] as? Bool ?? (order.is_closed  )
        order.is_sync = data["is_sync"] as? Bool ?? (order.is_sync )
        order.is_void = data["is_void"] as? Bool ?? (order.is_void )
        order.order_sync_type = orderSyncType.init(rawValue: ( data["order_sync_type"] as? Int ?? (order.order_sync_type.rawValue )))!
        order.kds_preparation_total_time = data["kds_preparation_total_time"] as? Int ?? (order.kds_preparation_total_time ?? 0)

        
        
        
//        let channel_menu = data["is_menu"] as? Bool ?? false
        if  SharedManager.shared.appSetting().enable_recieve_update_order_online {
            if order.order_integration == .ONLINE
            {
                if order.order_menu_status != .accepted{
                    order.order_menu_status = .pendding
                }
            }
            if  order.order_integration == .DELIVERY
            {
                order.order_menu_status = .pendding
            }}else{
                if order.order_integration == .ONLINE || order.order_integration == .DELIVERY
                {
                    order.order_menu_status = .pendding
                }
            }
        
        
        order.create_date = data["create_date"] as? String ?? ( order.create_date ?? "")
        
        if is_new_order == false
        {
            order.write_date = data["write_date"] as? String ?? ( order.write_date ?? "")
        }
        
        
        let created = ms_info["created"] as? [String:Any] ?? [:]
        
        if !created.isEmpty
        {
            let user = created["user"] as? [String:Any] ?? [:]
            let user_id = user["id"] as? Int ?? 0
            if user_id != 0
            {
                order.create_user_id = user_id
                order.create_user_name = user["name"] as?  String ?? ""
            }
            
            
            let pos = created["pos"] as? [String:Any] ?? [:]
            let created_pos_id = pos["id"] as? Int ?? 0
            if created_pos_id != 0
            {
                order.create_pos_id = created_pos_id
                order.create_pos_name = pos["name"] as?  String ?? ( order.create_pos_name ?? "")
                order.create_pos_code = pos["code"] as?  String ?? ( order.create_pos_code  ?? "")
                
            }
            
            
        }
        
        
        if !changed.isEmpty
        {
            let user = changed["user"] as? [String:Any] ?? [:]
            let user_id = user["id"] as? Int ?? 0
            if user_id != 0
            {
                order.write_user_id = user_id
                order.write_user_name = user["name"] as?  String ?? (order.write_user_name ?? "")
            }
            
            
            
            if changed_pos_id != 0
            {
                order.write_pos_id = changed_pos_id
                order.write_pos_name = pos["name"] as?  String ?? (order.write_pos_name ?? "")
                order.write_pos_code = pos["code"] as?  String ?? (order.write_pos_code ?? "")
                
            }
            
        }
        
        
        let lines = data["lines"] as? [Any] ?? []
        let products = read_products(lines: lines,order_id:order.id!,is_new_order: is_new_order)
        var voidLines = data["void_uid_lines"] as? [String] ?? []
        voidLines.forEach { lineUid in
            order.pos_order_lines.removeAll (where:{
                if  $0.uid == lineUid {
                    return true
                }else{
                    if $0.is_combo_line ?? false{
                        $0.selected_products_in_combo.removeAll { comboLine in
                            comboLine.uid == lineUid
                        }
                    }
                    return false
                }
            })
        }
        
        products.arr.forEach { lineProduct in
            order.pos_order_lines.removeAll(where: {$0.uid == lineProduct.uid })
        }
        order.pos_order_lines.append(contentsOf: products.arr)
        if let delviry = checkDeliveryAreaFees(order: order){
            order.pos_order_lines.removeAll(where: {$0.product_id == delviry.product_id})
            order.pos_order_lines.append(delviry)
        }
        let is_with_ms_write_date = order.is_closed
        if order.pos_order_lines.count == 0
        {
            pos_order_line_class.void_all( order_id: order.id!,order_uid: order.uid ?? "" ,void_status: void_status_enum.update_from_multi_session, with_ms_write_date: is_with_ms_write_date)
            
        }
        else
        {
            var ids = products.ids
            if voidLines.count > 0 {
                pos_order_line_class.void_all_include(uids: voidLines.map({"'\($0)'"}).joined(separator: ","), order_id: order.id!,order_uid: order.uid ?? "" ,void_status: void_status_enum.update_from_multi_session,with_ms_write_date: is_with_ms_write_date)
               
            }
            if ids != ""
            {
                
                //            pos_order_line_class.void_all_execlude(products: ids, order_id: order.id!, parent_product_id: 0,pos_multi_session_status: .last_update_from_local,parent_line_id:0 )
                pos_order_line_class.void_all_execlude(uids: ids, order_id: order.id!,order_uid: order.uid ?? "" ,void_status: void_status_enum.update_from_multi_session,with_ms_write_date: is_with_ms_write_date)
            }
        }
        order.amount_total = 0
        if isKDSOnly {
            order.session_id_local = -2
            order.order_menu_status = .none
        }
//        order.pos_order_lines.forEach { posLine in
//            posLine.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
//            posLine.save()
//        }
        
        order.save(write_info: false,re_calc: true)
        if isForceUpdateByOWner{
            order?.addForceJournalByOwner()
        }
        SharedManager.shared.removeUidRead(uid)
        if let partnerId = order.partner_id {
            MWSyncCustomer.checkAndFectchCustomer(by: partnerId,orderId: order.id ?? 0)
        }
        let is_printed =   data["is_printed"] as? Int ?? 1
        pos_order_helper_class.set_order_is_printed(order_id: order.id!, printed: is_printed)
        
        let print_count =  data["print_count"] as? Int ?? 0
        pos_order_helper_class.set_print_count(order_id: order.id!, count: print_count)
        var userInfo:[String:Any]? = nil
        if let isClosed =  data["is_closed"] as? Bool , isClosed == true{
            userInfo = [:]
            userInfo?["isPaid"] = isClosed
        }
        if (order.order_integration == .DELIVERY ||  order.order_integration == .ONLINE) {
            userInfo = [:]
            userInfo?["is_menu"] = true
            userInfo?["is_kds_only"] = isKDSOnly

        }
        if !(order.reward_bonat_code ?? "").isEmpty{
            BonatCodeInteractor.shared.checkRewardBonat(order:order) { result in
                
            }
        }
        DeliveryOrderIntegrationInteractor.shared.runTaskForSetTimeOut()
        if isKDSOnly {
            //MARK:- Send Order To Kitchen
            if SharedManager.shared.appSetting().enable_add_kds_via_wifi {
                order.session_id_local = pos_session_class.getActiveSession()?.id ?? 1
//                order.sent_order_via_ip(with: .NEW_ORDER, for: [.KDS,.NOTIFIER])
                order.sent_order_via_ip(with: IP_MESSAGE_TYPES.NEW_ORDER)
            }
        }else{
            if (SharedManager.shared.appSetting().enable_force_update_by_owner && (order.need_print_bill ?? false)) {
                order.creatBillQueuePrinter(.order,openDrawer:false)
                pos_order_helper_class.increment_print_count(order_id: order.id!)
                MWRunQueuePrinter.shared.startMWQueue()
            }
            if notify{
                NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: uid,userInfo: userInfo)
            }
        }
        
    }
    
    
    //    func skip_lines_in_kitchen(lines:[Any])-> Bool
    //    {
    //
    //        for item in lines
    //                {
    //                    let row = item as? [Any] ?? []
    //
    //                    if row.count == 3
    //                    {
    //
    //
    //                                let dic = row[2] as? [String:Any] ?? [:]
    //
    //                               let kitchen_status = kitchen_status_enum.init(rawValue:  dic["kitchen_status"] as? Int ?? 0)!
    //
    //                                if kitchen_status == .done
    //                                {
    //                                    return true
    //                                }
    //
    //                    }
    //
    //                }
    //
    //        return false
    //    }
    

    func checkDeliveryAreaFees(order:pos_order_class) -> pos_order_line_class?{
        let isDeliveryType = (order.orderType?.order_type ?? "") == "delivery"
        if isDeliveryType {
            if let pos_delivery_area_id = order.customer?.pos_delivery_area_id,
           let delivery_area = pos_delivery_area_class.getBy(id: pos_delivery_area_id){
                let delivery_amount = delivery_area.delivery_amount
                let delivery_product_id = delivery_area.delivery_product_id
                order.delivery_amount = delivery_amount
                
                let product = product_product_class.get(id: delivery_product_id)
                if product != nil
                {
                    
                    order.orderType?.delivery_product_id = delivery_product_id
                    
                    var d_product = pos_order_line_class.get (order_id: order.id ?? 0, product_id:product!.id)
                    if d_product == nil
                    {
                        d_product = pos_order_line_class.create(order_id: order.id ?? 0, product: product!)
                    }
                    d_product?.custom_price = delivery_amount
                    d_product!.product_id = delivery_product_id
                    d_product!.is_void = false
                    d_product!.update_values()
                    return d_product
                    
                }
                        
            
        }
    }
        return nil
    }
    func read_products(lines:[Any],order_id:Int,parent_product_id:Int = 0,is_new_order:Bool) -> (arr:[pos_order_line_class],ids:String )
    {
        
        
        var arr_products:[pos_order_line_class] = []
        var all_ids = ""
        for item in lines
        {
            let row = item as? [Any] ?? []
            
            if row.count == 3
            {
                let dic = row[2] as? [String:Any] ?? [:]
                
                let order_line = read_product(dic: dic,order_id: order_id,is_new_order: is_new_order)
                order_line.parent_product_id = parent_product_id
                
                //if load_kds == true
                //{
                let combo_ext_line_info = dic["combo_ext_line_info"] as? [Any]  ?? []
                if combo_ext_line_info.count > 0
                {
                    order_line.is_combo_line = true
                    
                    
                    let combo_row =  read_products(lines: combo_ext_line_info, order_id: order_id,parent_product_id: order_line.product_id!,is_new_order: is_new_order)
                    order_line.selected_products_in_combo.append(contentsOf: combo_row.arr)
                    
                    if all_ids.isEmpty
                    {
                        all_ids =  combo_row.ids
                        
                    }
                    else
                    {
                        all_ids =  String(format: "%@,%@", all_ids , combo_row.ids)
                        
                    }
                    
                }
                // }
                
                
                if order_line.is_void == true //&& order_line.pos_multi_session_status == updated_status_enum.last_update_from_local
                {
                    // line delete local  and return from api
                   SharedManager.shared.printLog("test")
                    
                }
                else
                {
                    all_ids =  String(format: "%@,'%@'", all_ids , order_line.uid)
                    
                    if load_kds == true
                    {
                        //                        if order_line.kitchen_status == .send
                        //                        {
                        arr_products.append(order_line)
                        //                        }
                    }
                    else
                    {
                        arr_products.append(order_line)
                    }
                    
                    
                }
                
                
                
                if order_line.product_id == 0
                {
                    assert(0 == 0 ,"must not be happen")
                    
                }
                
                
                
                
                //                 for combo in combo_ext_line_info
                //                 {
                //                    let rows_combo = combo as? [Any] ?? []
                //
                //                    let dic = rows_combo[2] as? [String:Any] ?? [:]
                //
                //                    let combo_line = read_product(dic: dic,order_id: order_id)
                //
                //                 }
                
                
            }
            else
            {
                assert( 0 == 0 ,"must not be happen")
                
                
            }
            
            
        }
        
        if all_ids.starts(with: ",")
        {
            all_ids.removeFirst()
        }
        
        return (arr_products ,all_ids)
    }
    
    func check_if_line_changed(line_local:pos_order_line_class,line_on_server:pos_order_line_class) -> Bool
    {
        let is_changed:Bool = false
        
        if !line_local.write_date!.isEmpty
        {
            let def_date =  baseClass.compareTwoDate(line_local.write_date!, dt2_new: line_on_server.write_date!, formate: baseClass.date_formate_database)
            if def_date < 0   // last update on local
            {
                return false
            }
            else if def_date > 0 // last update on server
            {
                return true
            }
        }
        
        
        
        //        if line_local.qty != line_on_server.qty
        //        {
        //            is_changed =  true
        //        }
        //
        //        if line_local.price_unit != line_on_server.price_unit
        //        {
        //            is_changed =  true
        //        }
        //
        //
        //        if line_local.price_subtotal != line_on_server.price_subtotal
        //        {
        //            is_changed =  true
        //        }
        //
        //        if line_local.price_subtotal_incl != line_on_server.price_subtotal_incl
        //        {
        //            is_changed =  true
        //        }
        //
        //        if line_local.discount != line_on_server.discount
        //        {
        //            is_changed =  true
        //        }
        //
        //        if line_local.note != line_on_server.note
        //        {
        //            is_changed =  true
        //        }
        //
        //        if load_kds == false
        //        {
        //            if line_local.kitchen_status != line_on_server.kitchen_status
        //            {
        //                is_changed =  true
        //            }
        //        }
        
        
        
        
        return is_changed
    }
    func read_product(dic:[String:Any],order_id:Int,is_new_order:Bool)-> pos_order_line_class
    {
        //        let  jsonString =  dic.jsonString() ?? "".replacingOccurrences(of: "\n", with: "")
        
        //        SharedManager.shared.printLog(jsonString)
        
        var isExist = true
        let uid = dic["uid"] as? String ?? ""
        
        
        var line = pos_order_line_class.get(uid: uid)
        if line == nil {
            isExist = false
            line = pos_order_line_class(fromDictionary: [:])
        }
        guard let line = line else {return pos_order_line_class(fromDictionary: [:]) }
        //pos_order_line_class.get(order_id: order_id, product_id: product_id) ?? pos_order_line_class(fromDictionary: [:])
        
        //        let line_on_server = pos_order_line_class(fromDictionary: dic)
        //
        //        if check_if_line_changed(line_local: line, line_on_server: line_on_server) == false
        //        {
        //
        //            return line
        //        }
        
        line.uid = uid
        
      
            line.pos_multi_session_write_date = dic["pos_multi_session_write_date"] as? String ?? ""
            if (line.pos_multi_session_write_date ?? "").isEmpty
            {
                line.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
            }
        if is_new_order == false
        {
            line.write_date = dic["write_date"] as? String ?? ""
            if line.write_date!.isEmpty
            {
                line.write_date = baseClass.get_date_now_formate_datebase()
            }
        }
        
        
        if line.create_date!.isEmpty
        {
            line.create_date = baseClass.get_date_now_formate_datebase()
        }
        
        
        
        let product_id = dic["product_id"] as? Int ?? 0
        let ms_info = dic["ms_info"] as? [String:Any] ?? [:]
        let changed = ms_info["changed"] as? [String:Any] ?? [:]
        let pos = changed["pos"] as? [String:Any] ?? [:]
        let changed_pos_id = pos["id"] as? Int ?? 0
        
        //        if changed_pos_id == pos_id
        //        {
        //            if line.product_id == 0
        //                    {
        //                                          assert(0 == 0 ,"must not be happen")
        //
        //                    }
        //
        //            return line
        //        }
        
        
        
        line.order_id = order_id
        line.product_id = product_id
        line.qty = dic["qty"] as? Double ?? 0
        line.price_unit = dic["price_unit"] as? Double ?? 0
        line.price_subtotal = dic["price_subtotal"] as? Double ?? 0
        line.price_subtotal_incl = dic["price_subtotal_incl"] as? Double ?? 0
        line.discount = dic["discount"] as? Double ?? 0
        line.pos_promotion_id = dic["pos_promotion_id"] as? Int ?? 0
        line.pos_conditions_id = dic["pos_conditions_id"] as? Int ?? 0
        line.discount_display_name = dic["discount_display_name"] as? String ?? ""
        line.discount_type = discountType.init(rawValue:  dic["discount_type"] as? String ?? "") ?? discountType.percentage
        line.discount_program_id = dic["discount_program_id"] as? Int ?? 0

        
        line.note = dic["note"] as? String ?? ""
        line.auto_select_num = dic["auto_select_num"] as? Int ?? 0
        line.combo_id = dic["combo_id"] as? Int ?? 0
        line.extra_price = dic["extra_price"] as? Double ?? 0
        line.is_void = dic["is_void"] as? Bool ?? false
        line.parent_line_id = dic["parent_line_id"] as? Int ?? 0
        line.last_qty = dic["last_qty"] as? Double ?? 0
        line.printed =  ptint_status_enum.init(rawValue:  dic["printed"] as? Int ?? 0)!
        line.pos_multi_session_write_date = dic["pos_multi_session_write_date"] as? String ?? ""
        line.product_tmpl_id = dic["product_tmpl_id"] as? Int ?? 0
        line.kds_preparation_item_time = dic["kds_preparation_item_time"] as? Int ?? 0

        
        
        
        line.kitchen_status = kitchen_status_enum.init(rawValue:  dic["kitchen_status"] as? Int ?? 0)!
        line.discount_extra_fees = dic["discount_extra_fees"] as? Double ?? 0
        line.is_combo_line = dic["is_combo_line"] as? Bool ?? false

        //        if load_kds == true
        //        {
        //            if line.kitchen_status != .none
        //            {
        //                line.kitchen_status = .send
        //
        //            }
        //        }
        //        else
        //        {
        //            line.kitchen_status = kitchen_status_enum.init(rawValue:  dic["kitchen_status"] as? Int ?? 0)!
        //
        //        }
        
        if line.pos_multi_session_status  != .last_update_from_local
        {
            line.pos_multi_session_status = .last_update_from_server
            
        }
        
        let created = ms_info["created"] as? [String:Any] ?? [:]
        
        if !created.isEmpty
        {
            let user = created["user"] as? [String:Any] ?? [:]
            let user_id = user["id"] as? Int ?? 0
            if user_id != 0
            {
                line.create_user_id = user_id
                line.create_user_name = user["name"] as?  String ?? ""
            }
            
            
            let pos = created["pos"] as? [String:Any] ?? [:]
            let pos_id = pos["id"] as? Int ?? 0
            if pos_id != 0
            {
                line.create_pos_id = pos_id
                line.create_pos_name = pos["name"] as?  String ?? ""
                line.create_pos_code = pos["code"] as?  String ?? ""
                
            }
            
            
        }
        
        
        if !changed.isEmpty
        {
            let user = changed["user"] as? [String:Any] ?? [:]
            let user_id = user["id"] as? Int ?? 0
            if user_id != 0
            {
                line.write_user_id = user_id
                line.write_user_name = user["name"] as?  String ?? ""
            }
            
            
            
            if changed_pos_id != 0
            {
                line.write_pos_id = changed_pos_id
                line.write_pos_name = pos["name"] as?  String ?? ""
                line.write_pos_code = pos["code"] as?  String ?? ""
                
            }
            
        }
        
        
        if line.qty == 0
        {
            line.is_void = true
        }
        
        if line.product_id == 0
        {
            assert(0 == 0 ,"must not be happen")
            
        }
        
//        _ = line.save(write_info: false)
        
        
        
        return line
    }
    
    
}
