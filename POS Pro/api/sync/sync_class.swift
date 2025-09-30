//
//  syncClass.swift
//  pos
//
//  Created by khaled on 9/23/19.
//  Copyright © 2019 khaled. All rights reserved.
//
/*
 
 
 
 */
import UIKit



class sync_class: NSObject  {
    
    let con_sync = SharedManager.shared.conAPI()
    var startSync:Bool = false
    
    
    var last_session_onServer:pos_session_class? = nil
    var last_session_offline:pos_session_class? = nil
    var is_start_create_pos_product_void:Bool = false
    var is_start_sync_order:Bool = false

    public static func setLastTimeSync()
    {
        let time :Int64 = baseClass.getTimeINMS() //ClassDate.getTimeINMS()!.toInt()!
        
        cash_data_class.set(key: "syncClass_LastTimeSync", value: String(time))
        //        myuserdefaults.setitems("LastTimeSync", setValue: String(time), prefix: "syncClass")
    }
    
    public static func getLastTimeSync() -> String
    {
        //        return myuserdefaults.getitem("LastTimeSync", prefix: "syncClass") as? String ?? ""
        return cash_data_class.get(key: "syncClass_LastTimeSync") ?? ""
    }
    
    public static func setLastTimeSyncSuccess()
    {
        let time :Int64 = baseClass.getTimeINMS() //ClassDate.getTimeINMS()!.toInt()!
        cash_data_class.set(key: "syncClass_LastTimeSyncSuccess", value: String(time))
        
        //        myuserdefaults.setitems("LastTimeSyncSuccess", setValue: String(time), prefix: "syncClass")
    }
    
    public static func getLastTimeSyncSuccess() -> String
    {
        return cash_data_class.get(key: "syncClass_LastTimeSyncSuccess") ?? ""
        //        return myuserdefaults.getitem("LastTimeSyncSuccess", prefix: "syncClass") as? String ?? ""
    }
    
    //    func add_log_message(msg:String)
    //    {
    //        logClass.set(key: "sync ==>", value: msg , prefix: "sync")
    //    }
    
    @objc public func syncOrders()
    {
        
        //         return
        
        
        if SharedManager.shared.appSetting().enable_testMode
        {
            return
        }
        
        if startSync == false
        {
            startSync = true
            sync_class.setLastTimeSync()
            if  NetworkConnection.isConnectedToNetwork() == false   {
                //                add_log_message(msg: "No internet connection")
                self.stop_sync()
                return
            }
            // depand on server_status = 0,1
            last_session_offline =  pos_session_class.get_last_session_offline()
            // session == nil server is up to date
            if last_session_offline != nil
            {
                handleSyncLastSessionNotNull()
            }
            else
            {
                handleSyncLastSessionNull()
            }
            
        }
        
    }
    
    func handleSyncLastSessionNull(){
        // get last session online
        last_session_onServer = get_last_session_onServer()
        if last_session_onServer != nil {
            //chec is_open = 1 and server=2
            last_session_offline = find_session_on_local(start_date: last_session_onServer!.start_session!)
            if (last_session_offline?.isOpen ?? false) && (last_session_offline?.server_status == .closed)
            {
                self.start_session()
                
            }else{
                
                last_session_offline = nil
                self.stop_sync()
            }
            
        }else{
            last_session_offline = nil
            self.stop_sync()
        }
    }
    
    func handleSyncLastSessionNotNull(){
        // get last session online
        last_session_onServer = get_last_session_onServer()
        if last_session_onServer != nil
        {
            let map_session_local_server = find_session_on_local(start_date: last_session_onServer!.start_session!)
            
            if map_session_local_server != nil
            {
                let orders = pos_order_class.get_not_sync_orders(for: map_session_local_server!)
                if orders.count <= 0 {
                    if map_session_local_server?.isOpen == false && (last_session_onServer?.end_session?.isEmpty ?? true) {
                        force_end_session_server()
                    }
                }
                
                // session closed on local and still open on server
                if map_session_local_server?.server_status  == .closed && last_session_onServer?.end_session == ""
                {
                    map_session_local_server?.server_session_id = last_session_onServer!.server_session_id
                    map_session_local_server?.server_session_name = last_session_onServer!.server_session_name
                    map_session_local_server?.server_status = .open
                    map_session_local_server?.appendLog("session closed on local and still open on server")
                    
                    map_session_local_server?.saveSession()
                    
                    //                            add_log_message(msg: "session closed on local and still open on server")
                    
                    self.stop_sync()
                    return
                }
                
            }
            
            
            check_session()
        }
        else
        {
            
            // (3B) it's first time to start app and no any session created
            
            if is_first_session() == true
            {
                start_session()
            }
            
            
            self.stop_sync()
        }
        
    }
    
    
    func find_session_on_local(start_date:String) -> pos_session_class? {
        
        let options = posSessionOptions()
        options.start_session = start_date
        
        let arr: [pos_session_class] =    pos_session_class.get_pos_sessions(options: options)
        if arr.count > 0
        {
            return arr[0]
        }
        
        
        return nil
        
        //        return pos_session_class.getSession(dateTime: start_date)
    }
    
    
    func start_sync()
    {
        startSync = true
        
        
        
    }
    
    
    func stop_sync()
    {
        let not_sync_resturant_printers = restaurant_printer_class.getAllNotSync()
        if not_sync_resturant_printers.count > 0 {
            not_sync_resturant_printers.forEach { printerDic in
              _ = send_not_synced_restaurant_printer(printer:restaurant_printer_class(fromDictionary: printerDic) )

            }
        }
        
        MWQueue.shared.firebaseQueue.async {
//        DispatchQueue.global(qos: .background).async {
        FireBaseService.defualt.updateInfoPOS()
            FireBaseService.defualt.updateInfoTCP("stop_sync")
            FireBaseService.defualt.setLastChainIndexFromFR()

        }
        startSync = false
        
        //        logClass.set(key: "stop_at", value: Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false), prefix: "sync")
        
        
    }
    
    
    func check_status_local_session()
    {
        if last_session_offline?.end_session?.isEmpty == false
        {
            if get_pending_count() == 0
            {
                end_session_server()
            }
        }
        else if last_session_offline?.isOpen == false && last_session_offline?.end_session?.isEmpty == true
        {
            last_session_offline?.end_session = last_session_offline?.start_session
            last_session_offline?.saveSession()
            
            stop_sync()
        }
    }
    
    
    func get_pending_count() -> Int
    {
        let option   = ordersListOpetions()
        option.Closed = true
        option.orderSyncType = .all
        option.Sync = false
        option.getCount = true
        option.sesssion_id = last_session_offline!.id
        option.write_pos_id = SharedManager.shared.posConfig().id
        
        let count = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        
        return count
    }
    
    
    
    
    func check_session()
    {
        let def_date = baseClass.compareTwoDate(last_session_onServer!.start_session!, dt2_new: last_session_offline!.start_session!, formate: baseClass.date_fromate_satnder)
        
        if def_date == 0 // Case (3A)
        {
            if last_session_onServer?.end_session != "" // (3A1) session closed on server and open on ipad (that not impossible)
            {
                if last_session_offline?.end_session == last_session_onServer?.end_session  // 3A2
                {
                    self.last_session_offline?.set_server_status_session(with: .closed)
                    last_session_offline?.saveSession()
                    
                }
                else
                {
                    report_Issue_NP(message: "(3A1) session closed on server and open on ipad (that not impossible)")
                    //                    add_log_message(msg: "(3A1) session closed on server and open on ipad (that not impossible)")
                    let orders = pos_order_class.get_not_sync_orders(for:last_session_offline!)
                    if (orders.count <= 0) && ( pos_session_class.getActiveSession()?.id !=  last_session_offline?.id )  {
                        last_session_offline?.isOpen = false
                        self.last_session_offline?.set_server_status_session(with: .closed)
                        if (last_session_offline?.end_session?.isEmpty ?? true) {
                            last_session_offline?.end_session = last_session_offline?.end_session
                        }
                        last_session_offline?.saveSession()
                    }else{
                        // reopen agian on server as mohammed requested
                        start_session()
                    }
                }
                
                stop_sync()
            }
            else  // (3A3)
            {
                //                if last_session_offline?.server_session_id  == 0
                //                {
                last_session_offline?.server_session_id = last_session_onServer!.server_session_id
                last_session_offline?.server_session_name = last_session_onServer!.server_session_name
                last_session_offline?.saveSession()
                
                //                }
                send_to_server()
                check_status_local_session()
                stop_sync()
            }
            
        }
        else if def_date > 0 // (3C) it's another session is open
        {
            if last_session_onServer?.end_session != "" // (3C1) session on server is closed
            {
                start_session()
                
            }
            
            else  // 3C2
            {
                send_to_server()
                check_status_local_session()
                
            }
            
            stop_sync()
            
            
        }
        else if def_date < 0 // that means session on local order than session on server (NP)
        {
            if last_session_onServer?.end_session == "" //            report_Issue_NP(message: "that means session on local order than session on server (NP)")
            {
                force_end_session_server()
                
            }
            else
            {
                // session on server is closed
                start_session()
                
                
            }
            
            stop_sync()
        }
        else
        {
            stop_sync()
        }
        
    }
    
    
    func get_last_session_onServer() -> pos_session_class? {
        
        var session_server:pos_session_class? = nil
        
        con_sync.userCash = .stopCash
        con_sync.timeout = 0
        let semaphore = DispatchSemaphore(value: 0)
        con_sync.get_last_session { (result) in
            
            if (result.success)
            {
                let response = result.response?["result"] as? [[String:Any]] ?? []
                if response.count > 0
                {
                    let lastSession = response[0]
                    
                    session_server = pos_session_class()
                    session_server?.server_session_id = lastSession["id"] as? Int ?? 0
                    session_server?.server_session_name = lastSession["name"] as? String ?? ""
                    session_server?.start_session = lastSession["start_at"] as? String ?? ""
                    session_server?.end_session = lastSession["stop_at"] as? String ?? ""
                    
                }
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return session_server
    }
    
    func is_first_session() -> Bool {
        
        var is_frist = false
        
        con_sync.userCash = .stopCash
        con_sync.timeout = 0
        let semaphore = DispatchSemaphore(value: 0)
        con_sync.get_last_session { (result) in
            
            if (result.success)
            {
                let response = result.response?["result"] as? [[String:Any]] ?? []
                if response.count == 0
                {
                    is_frist = true
                }
                
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return is_frist
    }
    
    
    func start_session()
    {
        //        add_log_message(msg: "try to start session")
        last_session_offline =  pos_session_class.get_last_session_offline()

        let semaphore = DispatchSemaphore(value: 0)
        
        con_sync.userCash = .stopCash
        con_sync.timeout = 0
        con_sync.create_pos_session(session:last_session_offline!) { (result_con) in
            
            
            self.last_session_offline!.appendLog("Start session \n \(result_con.toString())")
            
            
            
            
            
            if (result_con.success)
            {
                
                let response = result_con.response
                var session_id : Int = 0
                var session_name : String = ""
                
                let result_int = response!["result"] as?  [String:Any]
                if result_int != nil
                {
                    session_id = result_int!["session_id"] as? Int ?? 0
                    session_name = result_int!["name"] as? String ?? ""
                    
                }
                
                
                
                if session_id != 0
                {
                    
                    
                    
                    self.last_session_offline!.server_session_id = session_id
                    self.last_session_offline!.server_session_name = session_name
                    self.last_session_offline!.server_status = .open
                    //                    self.last_session_offline!.save()
                    
                    
                }
                else
                {
                    self.can_not_create_session(message: result_con.message  ?? "")
                    
                }
                
            }
            else
            {
                self.can_not_create_session(message: result_con.message  ?? "")
                
            }
            
            
            self.last_session_offline!.saveSession()
            
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    func end_session_server()
    {
        //        add_log_message(msg: "try to end session")
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        con_sync.userCash = .stopCash
        con_sync.timeout = 1200
       SharedManager.shared.printLog("Start at :\(Date())" )
        con_sync.close_pos_session(session:last_session_offline!) { (result_con) in
           SharedManager.shared.printLog("End at :\(Date())" )
            
            self.last_session_offline!.appendLog("End session \n \(result_con.toString())")
            
            //            self.last_session_offline!.appendLog("End session")
            //            self.last_session_offline!.appendLog(result_con.url)
            //            self.last_session_offline!.appendLog(result_con.header.jsonString() as String? ?? "")
            //            self.last_session_offline!.appendLog(result_con.request?.jsonString() as String? ?? "")
            //            self.last_session_offline!.appendLog(result_con.response?.jsonString() as String? ?? "")
            
            if (result_con.success)
            {
                let response = result_con.response
                let result = response!["result"] as? [String:Any] ?? [:]
                let session_id = result["session_id"] as? Int ?? 0
                
                if session_id == 0
                {
                    self.can_not_create_session(message: result_con.message ?? "")
                }
                else
                {
                    if self.last_session_offline!.server_session_id == session_id
                    {
                        self.last_session_offline?.set_server_status_session(with: .closed)
                        //                         self.last_session_offline!.save()
                    }
                    
                }
                
            }
            
            self.last_session_offline!.saveSession()
            
            
            semaphore.signal()
        }
        semaphore.wait()
        
        stop_sync()
        
    }
    
    func force_end_session_server()
    {
        //        add_log_message(msg: "force close session")
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        con_sync.userCash = .stopCash
        con_sync.timeout = 1200
        last_session_onServer!.end_session = baseClass.get_date_now_formate_satnder()   //ClassDate.getNow()
        
        con_sync.close_pos_session(session:last_session_onServer!) { (result_con) in
            
            self.last_session_offline?.appendLog("force end session on server not exist in app \n \(result_con.toString())")
            
            
            //            self.last_session_onServer!.appendLog("force end session on server not exist in app")
            //            self.last_session_onServer!.appendLog(result_con.url)
            //            self.last_session_onServer!.appendLog(result_con.header.jsonString() as String? ?? "")
            //            self.last_session_onServer!.appendLog(result_con.request?.jsonString() as String? ?? "")
            //            self.last_session_onServer!.appendLog(result_con.response?.jsonString() as String? ?? "")
            
            
            self.last_session_offline?.saveSession()
            
            if (result_con.success)
            {
                //                   let response = result_con.response
                //                   let result = response!["result"] as? [String:Any] ?? [:]
                //                   let session_id = result["session_id"] as? Int ?? 0
                //
                //                   if session_id == 0
                //                   {
                //                       self.can_not_create_session(message: result_con.message!)
                //                   }
                //                   else
                //                   {
                //                       self.last_session_offline!.server_status = .closed
                //                          self.last_session_offline!.save()
                //                   }
                
            }
            
            semaphore.signal()
        }
        semaphore.wait()
        
        stop_sync()
    }
    
    func send_to_server()
    {
        
        
        send_pending_customers()
        send_orders()
        send_updated_table_postion()
    }
    
    func send_updated_table_postion()
    {
        let arr = restaurant_table_class.getUpdatedPostion()
        for item in arr
        {
            let table = restaurant_table_class(fromDictionary: item)
            let success = send_update_postion(table: table)
            if success
            {
                table.update_postion = false
                table.save()
            }
      
        }
    }
    
    func send_update_postion(table:restaurant_table_class) -> Bool
    {
        
        var success: Bool = false
        
        let semaphore = DispatchSemaphore(value: 0)
        con_sync.timeout = 0
        con_sync.restaurant_table_update(table: table) { (Results) in
            
            if Results.success == true
            {
                
                let result = Results.response!["result"]
                if result != nil
                {
                    success = result as? Bool ?? false
                    
                }
                
            }
            
            semaphore.signal()
            
        }
        semaphore.wait()
        
        return success;
    }
    
    func send_pending_customers()
    {
        //        add_log_message(msg: "try to send customers to server")
        
        let arr = res_partner_class.get_pendding()
        for item in arr
        {
            let id_server = add_new_customer(customer: item)
            item.id = id_server
            item.save()
            item.updateParentWithIdServer()
        }
        
    }
    
    //    func send_pending()
    //    {
    
    
    //        let option = pendingOpetions()
    //        option.is_synced = false
    //
    //        let count =  pendingClass.get_status_sorted_count(options: option)
    //
    //        for i in 0...count
    //        {
    //            option.LIMIT = [i,1]
    //            let arr:[[String: Any]] = pendingClass.get_status_sorted(options: option)
    //            if arr.count > 0
    //            {
    //                let item = arr[0]
    //                let key = item["pending_key"] as? String ?? ""
    //                if key == "customer"
    //                {
    //                    let id_server = item["pending_id_server"] as? String
    //                    if id_server == nil
    //                    {
    //
    //                        let temp_customer = res_partner_class(fromDictionary:item)
    //
    //                        checkCustomer_forPending(customer: temp_customer)
    //
    //                    }
    //                }
    //            }
    //        }
    
    //    }
    
    func send_orders()
    {
        //        add_log_message(msg: "try to send orders to server")
        
        var try_send_orders = true
        
        while try_send_orders == true {
            
            autoreleasepool{
                if let local_session = pos_session_class.getSession(day: last_session_onServer?.start_session! ?? "")
                {
                    
                    let orders = pos_order_class.get_not_sync_orders(for: local_session)
                    if orders.count > 0
                    {
                        SharedManager.shared.printLog( orders.count )
                        
                        var success: Bool! = false
                        
                        let order = orders[0]
                        order.session_id_server = last_session_onServer?.server_session_id
                        
                        if order.order_sync_type == .scrap
                        {
                            success =  sendOrder_Scrap(order: order)
                        }
                        else  if order.order_sync_type == .cash_in_out
                        {
                            success =  sendOrder_cash_in_out(order: order)
                        }
                        else
                        {
                            success =  sendOrder_normal(order: order)
                            
                            if order.loyalty_earned_point != 0 || order.loyalty_redeemed_amount != 0
                            {
                                // get updated customer values
                                let parent_id = order.customer?.parent_id ?? 0

                                get_customer_loyalty_values( order.partner_id!,parent_id:parent_id)
                            }
                            
                        }
                        self.hit_create_pos_product_void(in: local_session, for: [order])
                        
                        if success == false
                        {
                            try_send_orders = false
                            stop_sync()
                        }
                        
                        
                    }
                    else
                    {
                        let orders = pos_order_class.get_not_closed_orders(for: local_session)
                        if orders.count > 0 {
                            self.hit_create_pos_product_void(in: local_session, for: orders)
                        }
                        try_send_orders = false
                        
                    }
                }else{
                    // "this session not exist in local"
                    try_send_orders = false
                    force_end_session_server()
                    
                }
            }
        }
    }
    
    func syncVoidProductsMaanule(){
        let ids:[Int] = []
        for id in ids{
            SharedManager.shared.printLog(id)
            if let local_session = pos_session_class.getSession(sessionID: id){
            let orders = pos_order_class.get_not_closed_orders_mannule(for: local_session )
            if orders.count > 0 {
                self.hit_create_pos_product_void(in: local_session, for: orders)
            }
            }

            
        }

    }
    
    func get_customer_loyalty_values(_ partner_id:Int,parent_id:Int)
    {
        
        let semaphore = DispatchSemaphore(value: 0)
        con_sync.timeout = 0
        con_sync.userCash = .stopCash
        con_sync.get_customer_by_id(id: partner_id) { (results) in
            let response = results.response
            
            let  result  = response!["result"] as? [[String:Any]]
            if result != nil
            {
                if result!.count > 0
                {
                    let temp = result![0]
                    let customer = res_partner_class(fromDictionary: temp)
                    let get_local = res_partner_class.get(partner_id: customer.id)
                    if get_local != nil
                    {
                        customer.row_id = get_local!.row_id
                        customer.row_parent_id = get_local!.row_parent_id
                        customer.parent_name = get_local!.parent_name
                        customer.parent_id = parent_id
                    }
                    
                    customer.save()
                    
                }
            }
            
            semaphore.signal()
            
        }
        semaphore.wait()
        
    }
    
    
    
    func report_Issue_NP(message:String)
    {
        //        add_log_message(msg: message)
        last_session_offline?.appendLog(message)
        last_session_offline?.saveSession()
        //        last_session_offline!.log_message = String(format: "%@\nNP:%@", last_session_offline!.log_message , message)
    }
    
    func can_not_create_session(message:String)
    {
        last_session_offline?.appendLog(message)
        last_session_offline?.saveSession()
        //        last_session_offline!.log_message = String(format: "%@\n%@", last_session_offline!.log_message , message)
    }
    
    
}

typealias orders_func_sync = sync_class
extension orders_func_sync
{
    func sendOrder_cash_in_out(order:pos_order_class    ) -> Bool
    {
        var success: Bool! = false
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        con_sync.userCash = .stopCash
        con_sync.timeout = 0
        con_sync.create_pos_multi_cashbox(order: order)  { (results) in
            
            //            success = results.success
            
            
            let response = results.response
            
            
            let  result  = response!["result"]
            if result != nil
            {
                success =  true
                
                let  sessionID = order.session?.id
                let session =  pos_session_class.getSession(sessionID: sessionID!)
                session!.server_session_id = order.session!.server_session_id
                session!.server_session_name = order.session!.server_session_name
                session!.saveSession()
                
                order.is_sync = true
                
                order.url = results.url
                order.header = results.header
                order.request = results.request ?? [:]
                order.response = results.response ?? [:]
                order.save()
                order.saveLog()
                
                sync_class.setLastTimeSyncSuccess()
                
            }
            
            semaphore.signal()
            
        }
        
        semaphore.wait()
        
        return success
        
    }
    
    
    func sendOrder_normal(order:pos_order_class,is_start_sync:Bool = false ) -> Bool
    {
        
        if SharedManager.shared.appSetting().enable_cloud_qr_code {
            if is_start_sync_order {
                return false
            }
            if (pos_order_class.get(uid: order.uid ?? "")?.is_sync) ?? false{
                return true
            }
        }
        
        SharedManager.shared.printLog("sendOrder_normal === \(Date())")
        is_start_sync_order = is_start_sync
        
        let new_order = checkCustomer_forOrder(Order: order)
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var success: Bool! = false
        con_sync.timeout = 0
        con_sync.userCash = .stopCash
        if SharedManager.shared.phase2InvoiceOffline ?? false {
            let posEinvoice = pos_e_invoice_class.getBy(order.uid ?? "")
            if posEinvoice == nil{
                // return false
            }
        }
        if  new_order.get_account_journal().count <= 0 {
            new_order.is_closed = false
            new_order.is_void = true
            new_order.void_status = .none_account_journal
            new_order.save(write_info: false,  re_calc: false)
            return true
        }
        
        con_sync.create_POS_Order(order: new_order) { (results) in
            SharedManager.shared.printLog("create_POS_Order === \(results.success)")
            
            
            //            success = results.success
            let response = results.response
            
            
            let  result  = response!["result"]
            
            if result != nil
            {
                success =  true
                //                if result.count > 0
                //                {
                new_order.is_sync = true
                sync_class.setLastTimeSyncSuccess()
                //                }
            }
            
            
            new_order.url = results.url
            new_order.header = results.header
            new_order.request = results.request ?? [:]
            new_order.response = results.response ?? [:]
            new_order.save(write_info: false,  re_calc: false)
            QrCodeInteractor.shared.printBill(for:new_order,after_hit_api: true )
            new_order.saveLog()
            self.is_start_sync_order = false

            semaphore.signal()
        }
        
        semaphore.wait()
        
        return success
    }
    
    
    func sendOrder_Scrap(order:pos_order_class    ) -> Bool
    {
        var success: Bool! = false
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        con_sync.timeout = 0
        con_sync.userCash = .stopCash
        con_sync.create_POS_Scrap(order: order) { (results) in
            //            success = results.success
            
            let response = results.response
            
            
            let  result  = response!["result"] as? [String:Any] ?? [:]
            let scraps = result["scraps"] as? [Int] ?? []
//            if scraps.count > 0
//            {
                success =  true
                
                sync_class.setLastTimeSyncSuccess()
                
                order.is_sync = true
                
                
                order.url = results.url
                order.header = results.header
                order.request = results.request ?? [:]
                order.response = results.response ?? [:]
                order.save()
                order.saveLog()
//            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return success
        
    }
    
    
    func checkCustomer_forOrder(Order:pos_order_class) -> pos_order_class
    {
        var server_id = 0
        if Order.customer != nil
        {
            
            if Order.customer?.id == 0
            {
                server_id = Order.partner_id ?? 0 // checkUserExist_local(customer: Order.customer!)
                if server_id == 0
                {
                    //                    server_id = checkUserExist_online(customer: Order.customer!)
                    //                    if server_id == 0
                    //                    {
                    server_id =  add_new_customer(customer: Order.customer!)
                    //                    }
                }
                
                if server_id != 0
                {
                    Order.customer?.id =  server_id
                    Order.save()
                    Order.customer?.save()
                    
                    //                    updateUserInApp(customer: Order.customer!)
                }
                else
                {
                    Order.customer = nil
                }
                
            }
            
        }
        
        
        return Order
    }
    //
    //    func checkCustomer_forPending(customer:res_partner_class)
    //    {
    //        var server_id = customer.id
    //
    ////        server_id = checkUserExist_online(customer:  customer )
    //        if server_id == 0
    //        {
    //
    //            server_id =  add_new_customer(customer: customer)
    //            customer.id = server_id
    //        }
    //        else
    //        {
    //            customer.id = server_id
    //        }
    //
    //            updateUserInApp(customer: customer)
    //
    //
    //
    //
    //    }
    //
    //    func checkUserExist_local(customer:res_partner_class) -> Int
    //    {
    //        var id_user: Int = 0
    //
    //        let option = pendingOpetions()
    //        option.id =  customer.pending_id
    //
    //        let list:[[String: Any]] = pendingClass.get_status_sorted(options: option)
    //        if list.count > 0
    //        {
    //            id_user = list[0]["pending_id_server"] as? Int ?? 0
    //        }
    //
    //        return id_user
    //    }
    
    func checkUserExist_online(customer:res_partner_class) -> Int
    {
        
        var id_user: Int = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        con_sync.timeout = 0
        con_sync.userCash = .stopCash
        con_sync.get_customer_by_phone(phone: customer.phone) { (results) in
            let response = results.response
            
            let  result  = response!["result"] as? [[String:Any]]
            if result != nil
            {
                if result!.count > 0
                {
                    let temp = result![0]
                    id_user = temp["id"] as? Int ?? 0
                    
                }
            }
            
            semaphore.signal()
            
        }
        semaphore.wait()
        
        return id_user;
    }
    func hit_create_pos_product_void(in session:pos_session_class,for orders:[pos_order_class]){
        if is_start_create_pos_product_void {return}
        is_start_create_pos_product_void = true
        let id_orders = orders.flatMap(){$0.id}
        let products_void = pos_order_line_class.get_void_lines(in: session, for: id_orders)
        if products_void.count <= 0{
            pos_order_line_class.set_sync_void_lines(in: session, for: id_orders)
            is_start_create_pos_product_void = false
            return}
        let semaphore = DispatchSemaphore(value: 0)
        con_sync.timeout = 0
        con_sync.create_pos_product_void(products: products_void) { (Results) in
            
            if Results.success == true
            {
                pos_order_line_class.set_sync_void_lines(in: session, for: id_orders)

                
            }
            self.is_start_create_pos_product_void = false
            semaphore.signal()
            
        }
        semaphore.wait()
        
        
    }
    func add_new_customer(customer:res_partner_class) -> Int
    {
        
        var id_user: Int = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        con_sync.timeout = 0
        con_sync.create_customer(customer: customer) { (Results) in
            
            if Results.success == true
            {
                
                let id = Results.response!["result"]
                if id != nil
                {
                    id_user = id as? Int ?? 0
                    
                }
                
            }
            
            semaphore.signal()
            
        }
        semaphore.wait()
        
        return id_user;
    }
    
    
    //
    //    func updateUserInApp(customer:res_partner_class)
    //    {
    ////        //TODO : check this
    ////        let pending = pendingClass(with_id: customer.pending_id)
    ////        if pending.id != nil
    ////        {
    ////            pending.id_server = customer.id
    ////
    ////            pending.save()
    ////
    //////            var list = api.get_last_cash_result(keyCash: "customers_list")
    //////            list.append(customer.toDictionary())
    //////            api.save_last_cash_result(dictionary: list as! [[String : Any]], keyCash: "customers_list")
    ////        }
    ////
    //
    //
    //    }
    
    func send_not_synced_restaurant_printer(printer:restaurant_printer_class) -> Bool
    {
        
        var success: Bool = false
        
        let semaphore = DispatchSemaphore(value: 0)
        con_sync.timeout = 0
        con_sync.new_create_restaurant_printer(printer: printer) { (Results) in
            
            if Results.success == true
            {
                let id = Results.response!["result"] as?  Int ?? 0
                if id != 0
                {
                    printer.server_id = id
                    printer.save()

                }
                
            }
            
            semaphore.signal()
            
        }
        semaphore.wait()
        
        return success;
    }
    
    
}
