//
//  pos_multi_session_updates.swift
//  pos
//
//  Created by Khaled on 5/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class pos_multi_session_updates: NSObject {
    
    var cls_pos_multi_session:pos_multi_session_sync_class!
    
     var is_running:Bool = false

    
    func send_local_changes(force:Bool = false)
    {
//        if mwIpPos {
//            return
//        }
        if SharedManager.shared.appSetting().enable_add_waiter_via_wifi{
            return
        }
        
        if AppDelegate.shared.load_kds == true
        {
            return
        }
        else
        {
             // update order when exist active session
            let active_session = pos_session_class.getActiveSession()
            if active_session == nil
            {
                return
            }
        }
        
        
        if SharedManager.shared.poll?.last_id == nil
        {
            return
        }
        
        if !force {
        if is_running == true
        {
            return
        }
        }
        
        is_running = true
        
        let opetions = ordersListOpetions()
        opetions.get_lines_void = true
        opetions.parent_product = true
        opetions.pos_multi_session_status = .sending_update_to_server
        opetions.orderSyncType = .all
        opetions.LIMIT = 10

        // get only order with in last day
        let setting = SharedManager.shared.appSetting()
        opetions.write_date  = Date().add(days: -1 * Int(setting.multisession_get_last_create_order_days))?.toString(dateFormat: baseClass.date_formate_database, UTC: false) ?? ""
 
        
        let arr = pos_order_helper_class.getOrders_status_sorted(options: opetions)
        for order in arr
        {
            if SharedManager.shared.poll?.last_id == nil
            {
                break
            }
            
            if order.is_closed == true
            {
                if check_all_lines_kitchen_status_done(order: order)
                {
                    delete_order_in_server(order: order)
                }
                else
                {
                    update_order_in_server(order: order)

                }
            }
            else if order.is_void == false
            {
                update_order_in_server(order: order)
            }
                
            else
            {
                delete_order_in_server(order: order)
                
            }
        }
        
          is_running = false
        
    }
    
    func check_all_lines_kitchen_status_done(order:pos_order_class) -> Bool
    {
        var all_done = true
        for line in order.pos_order_lines {
            if line.kitchen_status != .done
            {
                all_done = false
            }
        }
        
        return all_done
    }
    
    func delete_order_in_server(order:pos_order_class)
    {
        let cls_poll = pos_multi_session_sync_class.get(uid: order.uid!)
        if cls_poll.id == 0
        {
            // can't send to server because no revision_ID in pos_multi_session_sync table
//            pos_order_line_class.update_order_status(order_id: order.id!, status: .last_update_from_local)
            cls_poll.revision_ID = -1
            cls_poll.run_ID = cls_pos_multi_session.run_ID
            cls_poll.message_ID = Int(Date().timeIntervalSinceNow)
            cls_poll.new_order = true
            cls_poll.order_on_server = false
            cls_poll.name = order.name
            cls_poll.uid = order.uid
            cls_poll.save()

          //  return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        
        let con = SharedManager.shared.conAPI()
        con.userCash = .stopCash
        con.timeout = 60
        
        con.pos_multi_session_sync_remove(order: order, poll: cls_poll) { (result) in
             let rows = result.response!["result"] as?  [String:Any]  ?? [:]
         
                        let action = rows["action"] as? String ?? ""
            
                         if action == "revision_error"
                        {
                             DispatchQueue.global(qos: .background).async {
                                 let logClass = logClass(fromDictionary: [:])
                                 logClass.data = "[error] Can't revision_error loging polling /n \(order.uid)"
                                 logClass.key = "[revision_error] revision_error "
                                 logClass.prefix = "error"
                                 logClass.save()
                                 
                                 if  let data_rows = rows["data"] as?  [String:Any], let orders = data_rows["orders"] as?  [[String:Any]] {
                                     
                                     //MARK: - order exist in server but in another revision
                                     DispatchQueue.global(qos: .background).async {
                                         //Wain
                                         pos_order_class.remove_pending_orders(uid: order.uid)
                                         for item in orders
                                         {
                                             SharedManager.shared.poll?.handle_action(last_id:cls_poll.last_id ?? 0,message: item)
                                         }
                                         pos_order_line_class.update_order_status(order_id: order.id!, status: .sended_update_to_server)
                                         
                                     }
                                 }else{
                                     DispatchQueue.global(qos: .background).async {
                                         
                                         SharedManager.shared.poll?.get_orders_sync_all_online(uid:order.uid,last_id: cls_poll.last_id ?? 0){
                                             DispatchQueue.global(qos: .background).async {
                                                 pos_order_line_class.update_order_status(order_id: order.id!, status: .sended_update_to_server)
                                             }
                                         }
                                     }
                                 }
                             }
                      }
                        else
                        {
                            cls_poll.revision_ID = rows["revision_ID"] as? Int ?? 0
                            cls_poll.run_ID = rows["run_ID"] as? Int ?? 0
                            cls_poll.save()
                            
                            pos_order_line_class.update_order_status(order_id: order.id!, status: .sended_update_to_server)
                            
                        }
                     
            

            semaphore.signal()
            
        }
        
        semaphore.wait()
    }
    
    func update_order_in_server(order:pos_order_class)
    {
        let cls_poll = pos_multi_session_sync_class.get(uid: order.uid!)
        
        if cls_poll.id == 0
        {
            // new Order
            cls_poll.revision_ID = 1
            cls_poll.run_ID = cls_pos_multi_session.run_ID
            cls_poll.message_ID = 1
            cls_poll.new_order = true
            cls_poll.order_on_server = false
            cls_poll.name = order.name
            cls_poll.uid = order.uid
            cls_poll.save()
        }
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let con = SharedManager.shared.conAPI()
        con.userCash = .stopCash
        con.timeout = 60
        
        con.pos_multi_session_sync_update(order: order, poll: cls_poll) { (result) in
            let rows = result.response!["result"] as?  [String:Any]  ?? [:]
            let action = rows["action"] as? String ?? ""
            if action == "update_revision_ID"
            {
                cls_poll.revision_ID = rows["revision_ID"] as? Int ?? 0
                cls_poll.run_ID = rows["run_ID"] as? Int ?? 0
                cls_poll.save()
                
                pos_order_line_class.update_order_status(order_id: order.id!, status: .sended_update_to_server)
                
            }
            else if action == "revision_error"
            {
                if  let data_rows = rows["data"] as?  [String:Any], let orders = data_rows["orders"] as?  [[String:Any]] {

                //MARK: - order exist in server but in another revision
                    DispatchQueue.global(qos: .background).async {
                        //Wain
                        pos_order_class.remove_pending_orders(uid: order.uid)
                        for item in orders
                        {
                            SharedManager.shared.poll?.handle_action(last_id:cls_poll.last_id ?? 0,message: item)
                        }
                            pos_order_line_class.update_order_status(order_id: order.id!, status: .sended_update_to_server)
                    }
                }else{
                    DispatchQueue.global(qos: .background).async {
                        
                        SharedManager.shared.poll?.get_orders_sync_all_online(uid:order.uid,last_id: cls_poll.last_id ?? 0){
                            DispatchQueue.global(qos: .background).async {
                                pos_order_line_class.update_order_status(order_id: order.id!, status: .sended_update_to_server)
                            }
                        }
                    }
                }


            }
            
            semaphore.signal()
            
        }
        
        semaphore.wait()
        if order.write_pos_id != SharedManager.shared.posConfig().id{
        var userInfo:[String:Any]? = nil
        if  order.is_closed  == true{
            userInfo = [:]
            userInfo?["isPaid"] = order.is_closed
        }
        let isMenu =   order.order_integration == .DELIVERY ||  order.order_integration == .ONLINE
        if isMenu == true{
            userInfo = [:]
            userInfo?["is_menu"] = isMenu
        }
      //  NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: order.uid!,userInfo:userInfo )
        }
    }
    
    
    
}
