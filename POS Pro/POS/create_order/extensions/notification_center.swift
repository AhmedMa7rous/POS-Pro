//
//  notification_center.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

typealias notification_center = create_order
extension notification_center
{
    
    func init_notificationCenter()
    {
        
//        let Epos_printer = AppDelegate.shared.getDefaultPrinter()
//
 
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.printer_status(notification:)), name: Notification.Name("printer_status"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( poll_remove_order(notification:)), name: Notification.Name("poll_remove_order"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.need_to_sync(notification:)), name: Notification.Name("need_to_sync"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector( reload_badge_menu(notification:)), name: Notification.Name("time_out_integration_order"), object: nil)


        NotificationCenter.default.addObserver(self, selector: #selector(self.controlFailureMessageNotification(notification:)), name: Notification.Name("show_hide_faliure_kds_message"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector( update_pos_multisession_status(notification:)), name: Notification.Name("update_pos_multisession_status"), object: nil)
       
        
        NotificationCenter.default.addObserver(self, selector: #selector( update_qty_avaliable(notification:)), name: Notification.Name("update_qty_avaliable"), object: nil)


        
    }
    
    func remove_notificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("printer_status"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_remove_order"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("need_to_sync"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("show_hide_faliure_kds_message"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("time_out_integration_order"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("update_pos_multisession_status"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("update_qty_avaliable"), object: nil)


        SharedManager.shared.reset_order_void_id()
        
    }
  
    @objc func update_pos_multisession_status(notification: Notification) {
        DispatchQueue.main.async {
            if let info = notification.userInfo{

                if let order_id = info["order_id"] as? Int,let pos_multi_session_status = info["pos_multi_session_status"] as? Int  {
                    if self.orderVc?.order.id == order_id {
                        self.orderVc?.order.pos_order_lines.forEach({ order_line in
                            order_line.pos_multi_session_status = updated_status_enum(rawValue: pos_multi_session_status)
                            if order_line.is_combo_line ?? false {
                                order_line.selected_products_in_combo.forEach { comboLine in
                                    comboLine.pos_multi_session_status = updated_status_enum(rawValue: pos_multi_session_status)
                                }
                            }
                        })
                    }
                }
               
            }
        }
    }
    @objc func reload_badge_menu(notification: Notification) {
        DispatchQueue.main.async {
            self.checkBadgeMenu()
        }
    }
    
  
    @objc func poll_update_order(notification: Notification) {
        
        DispatchQueue.main.async {
            
            
            if self.enable_sound_notification == true
            {
                var isPaidOrder = false
                if let info = notification.userInfo{
                    if let isPaid = info["isPaid"] as? Bool {
                        isPaidOrder = isPaid
                    }
                }
                if !isPaidOrder{
                    baseClass.playSound(soundName: "insight.mp3")
                }

            }
            
            self.checkBadge()
       
            
            self.animate_lbl_badge()
            
            
            let uid = notification.object as? String ?? ""
            
            //            if self.list_order_created.count == 0
            //            {
            //
            //            self.showLastOrder()
            //                return
            //            }
            
           if self.orderVc == nil
            {
            return
            }
            
            if self.orderVc?.order == nil
            {
                return
            }
            
            
            if self.orderVc?.order.uid == uid
            {
                if self.payment_Vc != nil
                {
                    self.payment_Vc.view.removeFromSuperview()
                    self.payment_Vc = nil
                }
                let option = self.pendding_options()
                option.uid = uid
                
                let arr = pos_order_helper_class.getOrders_status_sorted(options:option)
                if arr.count > 0
                {
                    let firstOrder = arr[0]
                    //if SharedManager.shared.mwIPnetwork {
                        firstOrder.calcAll()
                    //}
                    self.orderVc?.order = firstOrder
                    if SharedManager.shared.isSequenceAtMasterOnly(){
                        if (firstOrder.sequence_number ) <= 0
                        {
                            self.lblOrderID.text = "#"
                        }
                        else
                        {
                            self.lblOrderID.text = "#\(firstOrder.sequence_number)"
                        }
                    }
//                    self.orderVc?.order.calcAll()
                    self.setupCustomerLayout()
                    self.readOrder()
                    self.reloadTableOrders()
                    self.orderVc?.reload_tableview()
                    if let order_vc = self.orderVc{
                    self.save_notification(order_vc.order)
                    }
                }
                else
                {
                   // self.showLastOrder()
                    self.reset_view_order()
                }
                
            }
            else
            {
                let option = self.pendding_options()
                option.uid = uid
                
                if let info = notification.userInfo{
                    if let is_menu = info["is_menu"] as? Bool , is_menu == true{
                        if  SharedManager.shared.appSetting().enable_recieve_update_order_online {
                            option.write_pos_id = nil
                            option.order_menu_status = [.pendding,.accepted]
                        }else{
                            option.order_menu_status = [.pendding]
                        }
                    }
                }

                let arr = pos_order_helper_class.getOrders_status_sorted(options:option)
                if arr.count > 0
                {
                    self.save_notification(arr[0])

                    
                }
            }
            
            
            
            
            
        }
        DispatchQueue.global(qos: .background).async {
            let line_discount = self.orderVc?.order.get_discount_line()
            DispatchQueue.main.async {
                if line_discount != nil
                {
                    self.newBannerHolderview.labelDiscount.text = "Cancel Discount".arabic("إلغاء الخصم")
                } else {
                    self.newBannerHolderview.labelDiscount.text = "Discount".arabic("خصم")
                }
            }
        }
        
    }
    
    func save_notification(_ order:pos_order_class)
    {
        
        if  order.order_menu_status == .pendding
        {
            DispatchQueue.main.async {

            if SharedManager.shared.appSetting().enable_play_sound_order_menu {
                
                baseClass.playSound(soundName: "ring_tone.mp3",numberOfLoops: 2)
            }
                var titleNotification = ""
                if (order.order_integration) == .DELIVERY  {
                    if let platFormName = order.platform_name , !platFormName.isEmpty{
                        titleNotification = platFormName
                    }else{
                        titleNotification = ((order.pos_order_integration?.online_order_source) ?? "JAHEZ")
                    }
                }else{
                    titleNotification =   "Menu"
                }
                DeliveryOrderIntegrationInteractor.shared.runTaskForSetTimeOut()
            notifications_messages_class.alert(tile: titleNotification, msg: "New order \(order.sequence_number ?? 0) - total : \(order.amount_total.toIntString()) ", date: Date().toString(dateFormat: baseClass.date_time_fromate_short, UTC: false), icon_name: "MWicons8-food-100",success: true,update_exist: true,key: order.uid ?? "")
            
            if SharedManager.shared.appSetting().enable_auto_accept_order_menu {
                if !order.checkIsOrderAcceptedBefor() {
                    self.print_send_accept_order(order)
                }
            }
            }
        }else{
            if order.order_integration == .DELIVERY && order.order_menu_status == .accepted{
                    if let integrationOrder = order.pos_order_integration{
                        if integrationOrder.is_paid ?? false && !order.is_closed && !order.is_sync{
                            if !SharedManager.shared.appSetting().enable_stop_paied_intergrate_order{
                                integrationOrder.doPayment()
                                self.doAcceptOrder(order,true)
                            }else{
                                self.doAcceptOrder(order)
                            }
                        }
                    }
                    
            }else{
                if order.order_integration == .ONLINE && order.order_menu_status == .accepted{
                    self.doAcceptOrder(order)
                }
            }
            DispatchQueue.main.async {
                if !SharedManager.shared.appSetting().enable_play_sound_while_auto_accept_order_menu {
                    baseClass.stopSound()
                }
            }
           
        }
        
        
    }
    func print_send_accept_order(_ order:pos_order_class){
//        if order.order_integration == .DELIVERY {
//            if let integrationOrder = order.pos_order_integration{
        var orderIntegration:pos_order_integration_class? =  order.order_integration == .DELIVERY ? order.pos_order_integration : nil
        var posOrder:pos_order_class? =  order.order_integration != .DELIVERY ? order : nil
        DeliveryOrderIntegrationInteractor.shared.updateStatus(integrateOrder:orderIntegration ,posOrder:posOrder , with: .accepted) { result in
            if result ?? false {
                if let orderIntegration = orderIntegration{
                    pos_order_integration_class.setMenuStatus(with: .accepted, for: order.uid ?? "")
                    var isClosed = false
                    if orderIntegration.is_paid ?? false{
                     if !SharedManager.shared.appSetting().enable_stop_paied_intergrate_order{
                        orderIntegration.doPayment()
                        isClosed = true
                         }
                    }
                    self.doAcceptOrder(order,isClosed)

                }else{
                    self.doAcceptOrder(order)
                }
            }else{
                if let orderIntegration = orderIntegration{
                    //TODO: - record error and play sound to accept mannule
                    baseClass.playSound(soundName: "ring_tone.mp3",numberOfLoops: 2)
                }

            }
        }
//            }
//        }else{
//            self.doAcceptOrder(order)
//        }
        
    }
    func doAcceptOrder(_ order:pos_order_class,_ isClosed:Bool = false){
        order.order_menu_status = .accepted
        order.pos_order_lines.forEach { line in
            line.write_date = baseClass.get_date_now_formate_datebase()
        }
        order.pos_multi_session_write_date = ""
        order.is_closed = isClosed
        order.save(write_info: true,  re_calc: false)
        guard let orderID = order.id else{
            return
        }
        //MARK:- Print Order
        if !isClosed {
            pos_order_helper_class.increment_print_count(order_id:orderID)
            if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
                order.creatKDSQueuePrinter(.kds)
                MWRunQueuePrinter.shared.startMWQueue()
            }else{
                let other_printers = printersNetworkAvalibleClass()
                let ord =  other_printers.prepear_order(order: order ,reReadOrder: true)
                other_printers.printToAvaliblePrinters(Order: ord)
                SharedManager.shared.epson_queue.run()
            }
        }
        //MARK:- Send Order To Kitchen
        order.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
        order.save_and_send_to_kitchen(forceSend:true,with:.NEW_ORDER,for: [.KDS,.NOTIFIER])
        DispatchQueue.main.async {
            if !SharedManager.shared.appSetting().enable_play_sound_while_auto_accept_order_menu {
                baseClass.stopSound()
            }
        }
    }
    
    @objc func poll_remove_order(notification: Notification) {
        DispatchQueue.main.async {
            
            if self.enable_sound_notification == true
            {
                baseClass.playSound(soundName: "insight.mp3")

            }
            
            self.checkBadge()
            
            self.animate_lbl_badge()
            
            let uid = notification.object as? String ?? ""
            
            if self.orderVc?.order.uid == uid
            {
               // self.showLastOrder()
                self.reset_view_order()
            }
        }
        
    }
    
    func animate_lbl_badge()  {
        /*
        if !SharedManager.shared.mwIPnetwork{
            newBannerHolderview.ordersBadgeHolderview.transform = CGAffineTransform(scaleX: 2, y: 2)
            
            UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
                self.newBannerHolderview.ordersBadgeHolderview.transform = CGAffineTransform.identity
            }, completion: nil)
        }
         */
    }
    func check_enable_sound()
    {
 
/**
 Stop Sound notification
 */
        /*
        let is_enable = cash_data_class.get(key: "enable_sound") ?? "1"
        if is_enable == "0" || is_enable.isEmpty
        {
            self.btn_enable_sound.isSelected = true
            self.enable_sound_notification = false
        }
        else
        {
            self.btn_enable_sound.isSelected = false
            self.enable_sound_notification = true
        }
         */
        
    }
    
    
    @objc func update_qty_avaliable(notification: Notification) {
        
        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }

    
}

