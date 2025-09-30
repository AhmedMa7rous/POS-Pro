//
//  File.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
import UIKit
 
typealias navigation = create_order
extension navigation:menu_left_delegate,invoicesList_delegate,load_base_apis_delegate,invoicesListCollection_delegate
{
    //    func init_notificationCenter()
    //    {
    //
    //
    //        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_update_order"), object: nil)
    //        NotificationCenter.default.addObserver(self, selector: #selector( poll_remove_order(notification:)), name: Notification.Name("poll_remove_order"), object: nil)
    //
    //    }
    //
    //    func remove_notificationCenter() {
    //        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_update_order"), object: nil)
    //        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_remove_order"), object: nil)
    //
    //    }
    //
    //    @objc func poll_update_order(notification: Notification) {
    //
    //        checkBadgeOrder()
    //
    //        baseClass.playSound(soundName: "insight.mp3")
    //
    //    }
    //
    //    @objc func poll_remove_order(notification: Notification) {
    //        //             let uid = notification.object as? String ?? ""
    //
    //        checkBadgeOrder()
    //
    //        baseClass.playSound(soundName: "insight.mp3")
    //
    //
    //    }
    
    //    func initSlideBar()
    //    {
    ////        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    ////        appDelegate.MainView = self
    ////        if (appDelegate.settingTheSideMenu == false)
    ////        {
    ////            appDelegate.settingTheSideMenu = true
    ////
    ////
    ////        }
    //
    ////        printer_status(online:AppDelegate.shared.printer_monitor!.is_printer_online)
    //
    //
    //    }
    
    
    
    
    func checkBadgeOrder()
    {
        let option   = ordersListOpetions()
        option.Closed = true
        option.orderSyncType = .order
        option.Sync = false
        option.getCount = true
        option.write_pos_id = SharedManager.shared.posConfig().id
        option.order_menu_status = [.accepted]
        
        let count = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        
        
        //       let list = ordersListClass.getOrders_status_sorted(Closed: true, Sync: false)
    }
    
    func check_printer()
    {
        _ =  AppDelegate.shared.getDefaultPrinter()
        
        let printer = SharedManager.shared.printers_pson_print[0]
        if printer != nil
        {
            if printer!.initializePrinterObject()
            {
                printer!.checkStatusPrinter()
            }
        }
        
        //        _ = epos_printer.initializePrinterObject()
        //      epos_printer.checkStatusPrinter()
        
    }
    
    
    @objc func printer_status(notification: Notification )
    {
        let printer:epson_printer_class = notification.object as!  epson_printer_class
        
        DispatchQueue.main.async {
            
            if printer.is_printer_online == true
            {
                self.newBannerHolderview.printerBtn.isEnabled = true
                //            self.btnPrinter.setImage(#imageLiteral(resourceName: "MWprinter"), for: .normal)
            }
            else
            {
                self.newBannerHolderview.printerBtn.isEnabled = false
                //            self.btnPrinter.setImage(#imageLiteral(resourceName: "MWprinter_disable"), for: .normal)
            }
            
        }
    }
    @objc func need_to_sync(notification: Notification )
    {
        
        DispatchQueue.main.async {
            //ToDO:- cash flag need to sync
            //TODO:- change icon sync show alert need to sync
            
           // alter_database_enum.loadingApp.setIsDone(with: false)
           // self.sync(get_new: false)
            //            notifications_messages_class.alert(tile: "Sync", msg: "Need to sync", date: Date().toString(dateFormat: baseClass.date_time_fromate_short, UTC: false), icon_name: "icons8-food-100.png",success: true,update_exist: true,key: "force_sync")
            
            
        }
    }
    
    func changeDriver(_ sender:UIView){
        if !MWMasterIP.shared.isOnLine(){
            messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
            return
        }
        let alert = UIAlertController(title: "Driver".arabic("السائق"), message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect =  sender.bounds
        
        
        alert.addAction(UIAlertAction(title: "Change driver".arabic("تغيير السائق") , style: .default, handler: { (action) in
            
            self.show_drives(sender)
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel driver".arabic("الغاء") , style: .default, handler: { (action) in
            
            self.cancel_driver()
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        self .present(alert, animated: true, completion: nil)
    }
    func cancel_driver()
    {
        if !MWMasterIP.shared.isOnLine(){
            messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
            return
        }
        self.orderVc?.order.driver =  nil
        self.orderVc?.order.driver_id = 0
        self.orderVc?.order.driver_row_id = 0
        self.orderVc?.order.save()
        setTitleInfo()
        newBannerHolderview.labelTable.textValue = "Driver".arabic("السائق")
        self.newBannerHolderview.tableImageView.image = UIImage(named: "driver-icon")
        if  (self.payment_Vc != nil)  && (self.orderVc?.order.isOrderTypeRequireDriver() ?? false) {
            self.clear_right()
        }
        newBannerHolderview.setEnableSendKitchen(with: true)
        
    }
    func show_drives(_ sender:UIView)
    {
        if !MWMasterIP.shared.isOnLine(){
            messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
            return
        }
        let vc = DriverListRouter.createModule(sender, selectDriver: self.orderVc?.order.driver)
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { driver in
            if (self.orderVc?.order.driver?.id ?? -1) != driver.id {
                self.clear_right()
            }
            self.orderVc?.order.driver = driver
            self.selectedDriver(driver)
        }
    }
    func selectedDriver(_ selectedDriver:pos_driver_class)
    {
        if !MWMasterIP.shared.isOnLine(){
            messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
            return
        }
        if orderVc?.order.id == nil {
            addNewOrder {
                self.completeSelectedDriver(selectedDriver)
            }
        }else{
            self.completeSelectedDriver(selectedDriver)
            
        }
        
    }
    func completeSelectedDriver (_ selectedDriver:pos_driver_class){
        orderVc?.order.driver =  selectedDriver
        orderVc?.order.driver_id = selectedDriver.id
        orderVc?.order.driver_row_id = selectedDriver.row_id
        
        newBannerHolderview.labelTable.textValue = orderVc?.order.driver?.name
        reload_create_order = false
        
        self.orderVc?.order.save()
    }
    
    func handleSelectTableFromActionIcon(tbl: restaurant_table_class){
        if !MWMasterIP.shared.isOnLine(){
            messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
            return
        }
        //Check if current order have table and have lines
        if self.orderVc?.order?.table_id == nil || self.orderVc?.order?.table_id == 0 {
            //current order not have table
            if (self.orderVc?.order?.pos_order_lines.count ?? 0) == 0  {
                //current order not have lines and not have table
                // save select table till add lines
                self.newBannerHolderview.labelTable.textValue = tbl.name
                self.orderVc?.selectedTableFomIcon = tbl
            }else{
                //current order have lines and not have table
                self.selectedTable(selectedTable: tbl)
            }
        }else{
            self.createNewOrder(sender: UIView())
            self.newBannerHolderview.labelTable.textValue = tbl.name
            self.orderVc?.selectedTableFomIcon = tbl
            return
        }
    }
    func openOptionTable(_ sender:UIView, checkMaster:Bool = true){
        
        if (orderVc?.order.id == 0 || orderVc?.order.id == nil) && (orderVc?.order.table_id == 0 || orderVc?.order.table_id == nil) {
            let casher = SharedManager.shared.activeUser()
            let accessNewOrder = true
            let accessBrowserTable = true 
            if accessNewOrder || accessBrowserTable {
                self.show_table(for: .browse_table_type)
            }
            return
        }else{
            if (orderVc?.order.table_id == 0 || orderVc?.order.table_id == nil) && orderVc?.order.id != nil {
               
                self.show_table(for: .browse_table_type)
                return
            }
        }
        /*
        if checkMaster{
            if !MWMasterIP.shared.isOnLine(){
                messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
                return
            }
        }
        */
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        optionMenu.view.tintColor =  #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)
        let colorSelect = #colorLiteral(red: 0.9988561273, green: 0.4232195616, blue: 0.2168394923, alpha: 1)
        let option1Title = "Browse tables".arabic("استعراض الطاولات")
        let option2Title = "New order".arabic("طلب جديد")
        let option3Title = "Change table".arabic("تغير الطاوله")
        let option4Title = "Cancel table".arabic("إلغاء الطاوله")
        let option1 = UIAlertAction(title: option1Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
          
            self.show_table(for: .browse_table_type)
        })
        
        let option2 = UIAlertAction(title: option2Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
           
            self.show_table(for: .new_order_table_type)
        })
        let option3 = UIAlertAction(title: option3Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            rules.check_access_rule(rule_key.change_table,for: self)  {
                self.show_table(for: .change_table_type)
                 }
            return
        })
        let option4 = UIAlertAction(title: option4Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
              rules.check_access_rule(rule_key.cancle_table,for:self)  {
                  self.cancel_table()

                 }
            return
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            SharedManager.shared.printLog("Cancelled")
        })
        
        optionMenu.addAction(option1)
        optionMenu.addAction(option2)
        optionMenu.addAction(option3)
        optionMenu.addAction(option4)
        /*
        /*
         if (orderVc?.order.id == 0 || orderVc?.order.id == nil) && (orderVc?.order.table_id == 0 || orderVc?.order.table_id == nil) {
             optionMenu.addAction(option1)
 //            optionMenu.addAction(option2)
         } else
         */
        if (orderVc?.order.id != 0 || orderVc?.order.id != nil) && (orderVc?.order.table_id != 0 || orderVc?.order.table_id != nil) && orderVc?.order?.total_items ?? 0 > 0 {
            optionMenu.addAction(option1)
            optionMenu.addAction(option2)
            optionMenu.addAction(option3)
            optionMenu.addAction(option4)
        } else {
            optionMenu.addAction(option1)
            optionMenu.addAction(option2)
            optionMenu.addAction(option3)
            optionMenu.addAction(option4)
        }
         */
        
        //        optionMenu.addAction(cancelAction)
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
        {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView =  sender
                currentPopoverpresentioncontroller.sourceRect =  sender.bounds
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up;
                self.present(optionMenu, animated: true, completion: nil)
            }
        }else{
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    func newTableOrder(_ fromActionIcon:Bool = false,table: restaurant_table_class){
        self.addNewOrder {
            let casher = SharedManager.shared.activeUser()
            table.setUserResponse(with:casher.id, name:casher.name ?? "")
            self.completeSelectedTable( table)
        }
    }
    func assginTable(_ fromActionIcon:Bool = false,table: restaurant_table_class){
        let casher = SharedManager.shared.activeUser()
        table.setUserResponse(with:casher.id, name:casher.name ?? "")

        if fromActionIcon {
            self.handleSelectTableFromActionIcon(tbl:table)
            
        } else {
            if (self.orderVc?.order?.pos_order_lines.count ?? 0) == 0  {
                self.newBannerHolderview.labelTable.textValue = table.name
                self.orderVc?.selectedTableFomIcon = table
            }else{
                self.selectedTable(selectedTable: table)
            }
        }
    }
    func show_table(for rule: rule_tables_key, fromActionIcon:Bool = false,checkMaster:Bool = true,changeTable:Bool = false)
    {
        if self.orderVc?.order.table_id != 0 && self.orderVc?.order.table_id != nil {
            self.auto_sent_to_kitchen()
        }
        
        if SharedManager.shared.appSetting().auto_arrange_table_default {
            let vc = TableManagementVC(nibName: "TableManagementVC", bundle: nil)
            vc.rule  = rule
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            vc.didSelect = { [weak self] table in
                if table.order_id == 0 {
                    switch rule {
                    case .browse_table_type:
//                        self?.showMessageAlert(message: "You can not browse empty tables or create new order !".arabic("لايمكنك استعراض طاولة فارغة او انشاء طلب جديد"))
                        if (self?.orderVc?.order ) == nil {
                            self?.newTableOrder(fromActionIcon,table:table)
                        }else{
                            if (self?.orderVc?.order.table_id ?? 0 ) == 0 {
                                self?.assginTable(fromActionIcon,table:table)
                            }else{
                                self?.newTableOrder(fromActionIcon,table:table)
                            }
                        }
                    case .new_order_table_type:
                        self?.newTableOrder(fromActionIcon,table:table)
                    case .change_table_type:
                        self?.assginTable(fromActionIcon,table:table)
                    case .cancle_table_type:
                        self?.cancel_table()
//                        self?.assginTable(fromActionIcon,table:table)
                   
                    }
                } else if rule == .change_table_type || rule == .new_order_table_type {
                    self?.showMessageAlert(message: "You can not change or select this table because it is busy right now !".arabic("لايمكنك التبديل او اخيار هذه الطاولة لانها مشغوله الان"))
                    return
                } else {
                    let opt:ordersListOpetions = ordersListOpetions()
                    opt.get_lines_void_from_ui = true
                    opt.parent_product = true
                    let order = pos_order_class.get(order_id: table.order_id,options_order:opt)
                    order?.calcAll()
                    order?.save(write_info:false,write_date:false)
                    self?.order_selected(order_selected: order!)
                    
                    if self?.orderVc?.order.orderType?.required_guest_number ?? false && self?.orderVc?.order.guests_number == nil {
                        self?.add_guests_number()
                    }
                }
            }
            
            vc.didSelectOrder = { selectOrder in
                let opt:ordersListOpetions = ordersListOpetions()
                opt.get_lines_void_from_ui = true
                opt.parent_product = true
                selectOrder.options = opt
                selectOrder.calcAll()
                //            selectOrder.get_products()
                self.order_selected(order_selected: selectOrder)
            }
            
        } else {
            let vc = posTableMangent(nibName: "posTableMangement", bundle: nil)
            vc.rule  = rule
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            vc.didSelect = { [weak self] table in
                if table.order_id == 0 {
                    switch rule {
                    case .browse_table_type:
                        if (self?.orderVc?.order ) == nil {
                            self?.newTableOrder(fromActionIcon,table:table)
                        }else{
                            if (self?.orderVc?.order.table_id ?? 0 ) == 0 {
                                self?.assginTable(fromActionIcon,table:table)
                            }else{
                                self?.newTableOrder(fromActionIcon,table:table)
                            }
                        }

//                        self?.showMessageAlert(message: "You can not browse empty tables or create new order !".arabic("لايمكنك استعراض طاولة فارغة او انشاء طلب جديد"))
//                        return
                    case .new_order_table_type:
                        self?.newTableOrder(fromActionIcon,table:table)
                    case .change_table_type:
                        self?.assginTable(fromActionIcon,table:table)
                    case .cancle_table_type:
                        self?.cancel_table()

                    
                    }
                } else if rule == .change_table_type || rule == .new_order_table_type {
                    self?.showMessageAlert(message: "You can not change or select this table because it is busy right now !".arabic("لايمكنك التبديل او اخيار هذه الطاولة لانها مشغوله الان"))
                    return
                } else {
                    let opt:ordersListOpetions = ordersListOpetions()
                    opt.get_lines_void_from_ui = true
                    opt.parent_product = true
                    let order = pos_order_class.get(order_id: table.order_id,options_order:opt)
                    order?.calcAll()
                    order?.save(write_info:false,write_date:false)
                    self?.order_selected(order_selected: order!)
                    
                    if self?.orderVc?.order.orderType?.required_guest_number ?? false && self?.orderVc?.order.guests_number == nil {
                        self?.add_guests_number()
                    }
                }
            }
            
            vc.didSelectOrder = { selectOrder in
                let opt:ordersListOpetions = ordersListOpetions()
                opt.get_lines_void_from_ui = true
                opt.parent_product = true
                selectOrder.options = opt
                selectOrder.calcAll()
                //            selectOrder.get_products()
                self.order_selected(order_selected: selectOrder)
                
            }
        }
    }
    
    func cancel_table()
    {
        /*
        if !MWMasterIP.shared.isOnLine(){
            messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
            return
        }
         */
        orderVc?.order.table_id = 0
        orderVc?.order.floor_name = ""
        orderVc?.order.table_name =  ""
        
        orderVc?.order.save(write_info: true,  write_date: false, updated_session_status: .last_update_from_local, re_calc: false)
        
        self.newBannerHolderview.labelTable.textValue = "Tables".arabic("طاولات")
        self.newBannerHolderview.tableImageView.image = UIImage(named: "table-icon")
        self.newBannerHolderview.btn_table.tag = 0
        newBannerHolderview.setEnableSendKitchen(with: true)
        //        failureSendBtn.isHidden = true
        
        
    }
    func set_table_layout()
    {
        if  orderVc?.order.driver != nil {
            set_driver_layout()
            return
        }
        if  (orderVc?.order.orderType?.required_driver ?? false)  {
            set_driver_layout()
            return
        }
        self.newBannerHolderview.btn_table.tag = 0
        if (orderVc?.order.table_name ?? "").isEmpty
        {
            self.newBannerHolderview.labelTable.textValue = "Tables".arabic("طاولات")
            self.newBannerHolderview.tableImageView.image = UIImage(named: "table-icon")
        }
        else
        {
            self.newBannerHolderview.labelTable.textValue = orderVc?.order.table_name
        }
    }
    
    func set_driver_layout()
    {
        self.newBannerHolderview.btn_table.tag = 1
        if (orderVc?.order.driver == nil)
        {
            self.newBannerHolderview.labelTable.textValue = "Driver".arabic("السائق")
            self.newBannerHolderview.tableImageView.image = UIImage(named: "driver-icon")
            
            
        }
        else
        {
            self.newBannerHolderview.labelTable.textValue = orderVc?.order.driver?.name ?? ""
            if self.orderVc?.order?.checISSendToMultisession() ?? false{
                self.orderVc?.order.save(write_info: true,
                                         write_date: false,
                                         updated_session_status: .sending_update_to_server,
                                         kitchenStatus:.send)
            }else{
                self.orderVc?.order.save(write_info: true,write_date: false)
            }
            
        }
    }
    func selectedTable(selectedTable:restaurant_table_class)
    {
        if !MWMasterIP.shared.isOnLine(){
            if !SharedManager.shared.appSetting().enable_sequence_at_master_only {
                messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
                return
            }
        }
        if orderVc?.order.id == nil {
            addNewOrder {
                self.completeSelectedTable( selectedTable)
            }
        }else{
            self.completeSelectedTable( selectedTable)
        }
        
        
        
    }
    func completeSelectedTable(_ selectedTable:restaurant_table_class)
    {
        orderVc?.order.calcAll()
        orderVc?.order.floor_name =  selectedTable.floor_name
        orderVc?.order.table_name = selectedTable.name ?? ""
        orderVc?.order.table_id = selectedTable.id
        
        orderVc?.order.table_control_by_user_id = selectedTable.create_user_id
        orderVc?.order.table_control_by_user_name = selectedTable.create_user_name


        self.newBannerHolderview.labelTable.textValue = orderVc?.order.table_name
        reload_create_order = false
        if self.orderVc?.order?.checISSendToMultisession() ?? false{
            self.orderVc?.order.save(write_info: true,
                                     write_date: false,
                                     updated_session_status: .sending_update_to_server,
                                     kitchenStatus:.send)
        }else{
            self.orderVc?.order.save(write_info: true,
                                     write_date: false)
        }
        
        
        //            orderVc?.order.save(write_info: false)
        
        newBannerHolderview.setEnableSendKitchen(with: true)
        //        failureSendBtn.isHidden = true
    }
    
    @IBAction func unwindToHomeViewController(segue: UIStoryboardSegue) {
        if let source = segue.source as? TableManagementViewController {
            if orderVc?.order.id == nil {
                addNewOrder {
                    self.completeUnwindToHomeViewController(source)
                }
            }else{
                completeUnwindToHomeViewController(source)
            }
        }
    }

    func completeUnwindToHomeViewController(_ source: TableManagementViewController){
        orderVc?.order.floor_name = source.selectedTable?.floor_name
        orderVc?.order.table_name = source.selectedTable?.name ?? ""
        
       /// btn_table.setTitle(orderVc?.order.table_name, for: .normal)
        
        reload_create_order = false
        if self.orderVc?.order?.checISSendToMultisession() ?? false{
            self.orderVc?.order.save(write_info: false,updated_session_status: .sending_update_to_server,kitchenStatus:.send)
            
        }else{
            self.orderVc?.order.save(write_info: false)
        }
        
        //            orderVc?.order.save(write_info: false)
        
        newBannerHolderview.setEnableSendKitchen(with: true)
        //            failureSendBtn.isHidden = true
    }
    
    func check_kitchen()
    {
        var multi_session_enable = true
        let multi_session_id = SharedManager.shared.posConfig().multi_session_id  ?? 0
        if multi_session_id == 0
        {
            multi_session_enable = false
        }
        
        var kds_printers_enable = true
        if !SharedManager.shared.mwIPnetwork {
            let lst_printers = restaurant_printer_class.getAll()
            if lst_printers.count  == 0
            {
                kds_printers_enable = false
            }
        }
        
        if multi_session_enable == false
            && kds_printers_enable == false
            && !SharedManager.shared.mwIPnetwork
        {
            newBannerHolderview.sendToKitchenHolderView.isHidden = true
        }
        
        
        guard let _ = orderVc?.order.id else {
            newBannerHolderview.setEnableSendKitchen(with: false)
            
            return
        }
        
        if orderVc?.order.get_order_status() == .changed
        {
            newBannerHolderview.setEnableSendKitchen(with: true)
            //            failureSendBtn.isHidden = true
        }
        else
        {
            if (orderVc?.order.pos_order_lines.filter({($0.pos_multi_session_write_date ?? "").isEmpty}).count) ?? 0 > 0 {
                newBannerHolderview.setEnableSendKitchen(with: true)
            }else{
                newBannerHolderview.setEnableSendKitchen(with: false)
            }
        }
    }
    
    
    func pageCurl_fromRight()
    {
        UIView.animate(withDuration: 1.0, animations: {
            let animation = CATransition()
            animation.duration = 1.0
            animation.startProgress = 0.0
            animation.endProgress = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.type = CATransitionType(rawValue: "pageCurl")
            animation.subtype = CATransitionSubtype(rawValue: "fromRight")
            animation.isRemovedOnCompletion = false
            animation.fillMode = CAMediaTimingFillMode(rawValue: "extended")
            self.view.layer.add(animation, forKey: "pageFlipAnimation")
            //            self.animatedUIView.addSubview(tempUIView)
        })
    }
    func  pageCurl_fromLeft()
    {
        UIView.animate(withDuration: 1.0, animations: {
            let animation = CATransition()
            animation.duration = 1.0
            animation.startProgress = 0.0
            animation.endProgress = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.type = CATransitionType(rawValue: "pageCurl")
            animation.subtype = CATransitionSubtype(rawValue: "fromLeft")
            animation.isRemovedOnCompletion = false
            animation.fillMode = CAMediaTimingFillMode(rawValue: "extended")
            self.view.layer.add(animation, forKey: "pageFlipAnimation")
            //            self.animatedUIView.addSubview(tempUIView)
        })
    }
    func callCreatNewOrder(lastOrderID:Int? = nil,_ complete:()->Void){
        self.orderVc?.order = pos_order_helper_class.creatNewOrder(lastOrderID:lastOrderID)
        if let order_type = orderVc?.order.orderType {
            getPriceList_In_OrderType(orderType:order_type)
        }
        complete()
    }
    func showLoading(){
        DispatchQueue.main.async {
            loadingClass.show(view: self.view )
        }
    }
    func hideLoading(){
        DispatchQueue.main.async {
            loadingClass.hide(view: self.view )
        }
    }
    func initalNewOrder(complete:@escaping()->Void){
        if !MWMasterIP.shared.isOnLine(){
            messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
            return
        }
        if SharedManager.shared.appSetting().enable_sync_order_sequence_wifi{
            
            if SharedManager.shared.isSequenceAtMasterOnly() {
                self.callCreatNewOrder(complete)
                return
            }
           
            if !(SharedManager.shared.posConfig().isMasterTCP() ){
                self.showLoading()
            }
            sequence_session_ip.shared.getSequenceForNextOrder(for: self.view)  { result in
                if !(SharedManager.shared.posConfig().isMasterTCP() ){
                    //TODO: - check if there is order with current sequence
                    if result && SharedManager.shared.checkIfSequenceTakeBefore(){
                        self.initalNewOrder(complete:complete)
                        return
                    }
                    self.hideLoading()
                }
                if result {
                    self.callCreatNewOrder(complete)
                }else{
                    messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
                    return
                    
                }
            }
        }else{
            if SharedManager.shared.appSetting().enable_sequence_orders_over_wifi {
                if let seqNum = SharedManager.shared.getSequenceFromMultipeer() {
                    self.callCreatNewOrder(lastOrderID:seqNum,complete)
                    SharedManager.shared.sendNewSeqToPeers(nextSeq:self.orderVc?.order.sequence_number ?? 1)
                }else{
                    self.callCreatNewOrder(complete)
                }
            }else{
                self.callCreatNewOrder(complete)
            }
        }
        
    }
    func addNewOrder(complete:(@escaping()->()))
    {
        WaringToast.shared.handleShowAlertWaring(complete: nil)
        LicenseInteractor.shared.handleShowAlertLicense(for: [.NEW_ORDER], complete: nil)
        
        //        LicenseInteractor.shared.licenseCanAccess(for: .NEW_ORDER)
        if self.countProductsNeedToAdded > 0 &&  self.orderVc?.order.id != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20), execute:{ self.addNewOrder(complete:complete) })
            return
        }
        LicenseInteractor.shared.licenseCanAccess(for: [.NEW_ORDER])
        MWMasterIP.shared.showLocalNetWorkPermissionNotification()
        if sequence_session_ip.shared.isStartSequence(){
            return
        }
        //        isStartAddNewOrder = true
//        if self.countProductsNeedToAdded > 0 &&  self.orderVc?.order.id != nil {
//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute:{
//                //                self.isStartAddNewOrder = false
//                self.addNewOrder(complete:complete)
//
//            })
//            return
//        }
        self.initalNewOrder {
            //        get_order_pendding()
            self.showLastOrder()
            self.readOrder()
            self.reloadTableOrders()
            
            self.orderVc?.reload_tableview()
            
            self.clear_right()
            
            
            if SharedManager.shared.appSetting().enable_OrderType == .InAddOrder
            {
                self.show_order_type()
            }
            
            
            self.newBannerHolderview.labelPromotionCode.text = ""
            self.newBannerHolderview.iconPromotion.isHighlighted = false
            complete()
        }
        
    }
        func addNewOrderCompletion(){
            addNewOrder {
                self.pageCurl_fromRight()
                self.orderVc?.selectedTableFomIcon = nil
            }
        }
        
        @IBAction func btnDashBoard(_ sender: Any) {
            
            AppDelegate.shared.loadDashboard()
            
        }
        
        func clear_right()  {
            if comboList != nil
            {
                comboList.view.removeFromSuperview()
                self.comboList = nil
            }
            if payment_Vc != nil
            {
                payment_Vc.view.removeFromSuperview()
                self.payment_Vc = nil
            }
            if self.getPromotionCode != nil {
                self.getPromotionCode = nil
            }
            
            for subUIView in right_view.subviews as [UIView] {
                if subUIView.tag != 1000
                {
                    subUIView.removeFromSuperview()
                }
            }
            //        self.orderVc?.reloadTableOrders()
            //        self.reloadTableOrders()
            
            
            
//            checkTotalDiscount()
            self.reloadTableOrders(re_calc: true )

        }
    }
