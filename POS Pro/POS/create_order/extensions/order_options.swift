//
//  order_options.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

typealias order_options = create_order
extension order_options: price_listVC_delegate,order_type_list_delegate,scrap_list_delegate,disconutOption_delegate,enterBalance_delegate,pinCode_delegate
{
    
   
    
//    @IBAction func btnMore_old(_ sender: Any)
//    {
//
//        if orderVc?.order.id == nil
//        {
//            return
//        }
//
//
//        let alert = UIAlertController(title: "More", message: "Pleas select action.", preferredStyle: .actionSheet)
//
//
//
//        let pos = SharedManager.shared.posConfig()
//
//        if  orderVc?.order.amount_total > 0
//        {
//            let price_list:[[String:Any]] = product_pricelist_class.getAll()  // api.get_last_cash_result(keyCash:"get_product_pricelist")
//
//            if price_list.count > 1
//            {
//                alert.addAction(UIAlertAction(title: "Price list" , style: .default, handler: { (action) in
//
//                    self.btnPriceList(sender)
//
//                }))
//            }
//
//            let ordertype_list:[[String:Any]] = delivery_type_class.getAll()  //api.get_last_cash_result(keyCash:"get_order_type")
//
//            if ordertype_list.count > 1
//            {
//                alert.addAction(UIAlertAction(title: "Order type" , style: .default, handler: { (action) in
//
//                    self.btnOrderTypeList(sender)
//
//                }))
//            }
//
//            if pos.allow_discount_program == true
//            {
//                alert.addAction(UIAlertAction(title: "Discount" , style: .default, handler: { (action) in
//
//                    self.btnDiscount(sender)
//
//                }))
//
//            }
//
//            let line_discount = self.orderVc?.order.get_discount_line()
//            if line_discount != nil
//            {
//                alert.addAction(UIAlertAction(title: "Cancel Discount" , style: .default, handler: { (action) in
//
//                    //                    self.orderVc?.order.discount_program_id = 0
//                    //                    self.orderVc?.order.discount = 0
//
//                    line_discount?.is_void = true
//                    _ =  line_discount?.save(write_info: true, updated_session_status: .last_update_from_local)
//                    //                    pos_order_line_class.delete_line(line_id: line_discount!.id)
//
//                    //                    self.orderVc?.order.discountProgram!.discount_product?.update_values()
//                    self.orderVc?.order.save(write_info: true, updated_session_status: .last_update_from_local, re_calc: true)
//                    self.reloadTableOrders(re_calc: false)
//
//                    alert.dismiss(animated: true, completion: nil)
//
//                }))
//            }
//
//
//
//            alert.addAction(UIAlertAction(title: "Scrap" , style: .default, handler: { (action) in
//
//                self.btnScrap(AnyClass.self)
//
//            }))
//
//        }
//
//        alert.addAction(UIAlertAction(title: "Add order note", style: .default, handler: { (action) in
//
//
//            self.add_note(product: nil)
//        }))
//
//
//        alert.addAction(UIAlertAction(title: "Print", style: .default, handler: { (action) in
//
//            self.print_res()
//        }))
//
//        alert.addAction(UIAlertAction(title: "void", style: .default, handler: { (action) in
//            self.orderVc?.order.is_void = true
//            self.orderVc?.order.save(write_info: true,updated_session_status: .last_update_from_local)
//            self.order_deleted(order_selected: self.orderVc?.order)
//
//        }))
//
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
//
//        }))
//
//
//        alert.popoverPresentationController?.permittedArrowDirections = .left //UIPopoverArrowDirection(rawValue: 0)
//        alert.popoverPresentationController?.sourceView = sender as? UIView
//        alert.popoverPresentationController?.sourceRect =  (sender as AnyObject).bounds
//
//
//
//        self.present(alert, animated: true, completion: nil)
//
//    }
    
    func send_note_via_kds_printers(){
        if let order = self.orderVc?.order {
           let vc = SentNoteViaPrintersVC.createModule(order.pos_order_lines)
           self.present(vc, animated: true, completion: nil)
        }
    }
    func completeMoveItems(){
        DispatchQueue.main.async {
//            self.orderVc?.order.calcAll()
            self.orderVc?.refreshOrder(sender:nil)
        }
    }
    func add_guests_number(){
        let sender = self.newBannerHolderview.btn_more
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        getBalance = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew
        getBalance.modalPresentationStyle = .popover
        getBalance.preferredContentSize = CGSize(width: 400, height: 715)
        
        getBalance.key = "guests_number"
        getBalance.title_vc = LanguageManager.text("Add guests number", ar:"إضافة عدد الضيوف")
        getBalance.disable = false
        if let guestNumber = self.orderVc?.order.guests_number {
            getBalance.initValue = "\(guestNumber)"
        }
        
        let popover = getBalance.popoverPresentationController!
      
        popover.permittedArrowDirections = .left
//        popover.sourceView = sender
//        popover.sourceRect =  (sender as AnyObject).bounds
        
        popover.sourceView = self.btnSelectOrderType
        popover.sourceRect =  self.btnSelectOrderType.bounds
        
        
        self.present(getBalance, animated: true, completion: nil)
        
        getBalance.didSelect = {    key,value in
            self.orderVc?.order.guests_number = value.toInt()
//            DispatchQueue.global(qos: .background).async {
            self.orderVc?.order.save(write_info: true,updated_session_status: .last_update_from_local, re_calc: true)
            self.newBannerHolderview.setEnableSendKitchen(with: true)
//        }
        }
    }
    func completMoveOrderMethod(){
        DispatchQueue.main.async {
    guard let order = self.orderVc?.order else {return}
            let vc = MoveOrderItemVC.createModule(order,completeMoveItems: self.completeMoveItems)
    vc.modalPresentationStyle = .fullScreen
//        vc.preferredContentSize = CGSize(width: 900, height: 700)
    self.present(vc, animated: true, completion: nil)
        }
    }
    func move_items_method(){
        rules.check_access_rule(rule_key.move_order,for: self){
            if let order = self.orderVc?.order {
                if  order.is_send_toKDS() || order.isSendToMultisession()
                {
                    rules.check_access_rule(rule_key.edit_after_sent_to_kitchen,for: self){
                        DispatchQueue.main.async {
                            self.completMoveOrderMethod()
                            return
                        }
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                self.completMoveOrderMethod()
            }
        }
    }
    func split_order_method()
    {
        rules.check_access_rule(rule_key.split_order,for: self){
            if let order = self.orderVc?.order {
                if  order.is_send_toKDS() || order.isSendToMultisession()
                {
                    rules.check_access_rule(rule_key.edit_after_sent_to_kitchen,for: self){
                        DispatchQueue.main.async {
                            self.completSplitOrderMethod()
                            return
                        }
                    }
                    
                    return

                }
            }
            DispatchQueue.main.async {
                self.completSplitOrderMethod()
            }
        }

    }
    func completSplitOrderMethod(){
        let return_order = self.orderVc?.order

        
        let line_discount = return_order!.get_discount_line()
        let have_promotion = return_order!.is_have_promotions()
        
        if (line_discount != nil || have_promotion)
        {
       
            messages.showAlert("Can't split invoice have discount or promotion.".arabic("لا يمكن تقسيم الفاتورة بسبب وجود خصم على الفاتورة"))
            return
        }
        

        let option = ordersListOpetions()
        option.parent_product = true
        if let copyOrder =  return_order?.copyOrder(option: option){
            let newSplitVC:NewSplitOrderVC = NewSplitOrderRouter.createModule( order: copyOrder )
            newSplitVC.complete  = {  [weak self] order_new in

                guard let self = self else {
                    return
                }
                self.re_read_order()
                if self.checIfOrderSendToMultisession()  {
                    self.updateStatusMltisession()
                    self.sendToKitchen(sender: self.newBannerHolderview.btn_send_kitchen)
                 }
    //            self.splitOrder.doSplit(order: order )
    //            order_new.is_closed = false
    //            order_new.is_sync = false
    //
    //            order_new.save(write_info: true, updated_session_status: .last_update_from_local,re_calc: true )
                DispatchQueue.main.async {
                    self.reloadTableOrders(re_calc: true)
                }
                 
                
            }
            self.present(newSplitVC, animated: true, completion: nil)
        }
    }
    /*
    func split_order_method()
    {
        rules.check_access_rule(rule_key.split_order,for: self){
            DispatchQueue.main.async {
                self.completSplitOrderMethod()
            }
        }
      
      
        /*
        splitOrder = split_order()
        splitOrder.parent_vc = self
        splitOrder.order = return_order?.copyOrder(option: option)
     
        
        
        splitOrder.modalPresentationStyle = .overFullScreen
        
        splitOrder.didSelect  = {  order_new in
            if self.checIfOrderSendToMultisession()  {
                self.updateStatusMltisession()
                self.btn_to_kitchen( self.btn_send_kitchen)
             }
//            self.splitOrder.doSplit(order: order )
//            order_new.is_closed = false
//            order_new.is_sync = false
//
//            order_new.save(write_info: true, updated_session_status: .last_update_from_local,re_calc: true )
            DispatchQueue.main.async {
                self.orderVc?.reloadTableOrders(re_calc: true)
            }
             
            
        }
        
        self.present(splitOrder, animated: true, completion: nil)
*/
    }
    */
    func void_order()
    {
        if self.orderVc?.order.id == 0 ||
            self.orderVc?.order.id == nil ||
            self.orderVc?.order.pos_order_lines.count == 0 {
            return
        }
        let alert = UIAlertController(title: "Void".arabic("حذف"), message: "Are you sure to void ?".arabic("هل انت متأكد من الحذف؟"), preferredStyle: .alert)
        
        let action_void = UIAlertAction(title: "Void".arabic("حذف") , style: .default, handler: { (action) in
            guard let order_vc = self.orderVc else {return}
            if order_vc.order.isSendToMultisession() && (order_vc.order.id == 0 || order_vc.order.id == nil) {
                return
            }
            SharedManager.shared.premission_for_void_order(order: order_vc.order, vc: self) { [weak self] in
                DispatchQueue.main.async {
                    
                guard let self = self else {return}
                    let options = self.pendding_options()
                    self.orderVc?.order = pos_order_class.get(uid: self.orderVc?.order?.uid ?? "", options_order: options)
                    if (self.orderVc?.order.checISSendToMultisession()) ?? false{
                        if !MWMasterIP.shared.checkMasterStatus(){
                            return
                        }
                    }
            self.orderVc?.order.is_void = true
//            var count_send_to_kitchen = 0
            var posOrderLines:[pos_order_line_class] = []

             self.orderVc?.order.getAllLines().forEach { line in
                let is_line_void_and_printed = (line.is_void ?? false) && (line.printed == .printed)
                 if !is_line_void_and_printed {
                     line.is_void = true
                     line.write_info = true
                     line.printed = .none
                 }

                if line.is_combo_line!
                {
                    if line.selected_products_in_combo.count > 0
                    {
                        for combo_line in line.selected_products_in_combo
                        {
                            // if line void and printed -> not set printed with none
                            let is_combo_line_void_and_printed = (combo_line.is_void ?? false) && (combo_line.printed == .printed)
                            if !is_combo_line_void_and_printed{
                            combo_line.is_void = true
                            combo_line.write_info = true
                            combo_line.printed = .none
                            }

                        }
                    }
                }
//                if (line.pos_multi_session_status?.rawValue ?? 0 ) >= 2 {
//                    count_send_to_kitchen += 1
//                }
                 posOrderLines.append(line)
             }
                self.orderVc?.order.pos_order_lines.removeAll()
                self.orderVc?.order.pos_order_lines.append(contentsOf: posOrderLines)
            if  self.orderVc?.order.void_status == .before_sent_to_kitchen{
//            if !self.checIfOrderSendToMultisession() {
                //Save local
                self.orderVc?.order.save(write_info: true)
            }else{
                // save local and sent to ms
                self.orderVc?.order.save(write_info: true,updated_session_status: .sending_update_to_server,kitchenStatus:.send)
                
//                self.orderVc?.order.sendToKDS(isDeleted: true,printAll: true,reRead: false)
                self.orderVc?.order.save_and_send_to_kitchen(printAll: true, isDeleted: true,reRead: false,
                                               with: IP_MESSAGE_TYPES.VOID_ORDER,
                                                             for: [DEVICES_TYPES_ENUM.KDS,.NOTIFIER])
                if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
                    self.orderVc?.order.creatKDSQueuePrinter(.kds)
                    MWRunQueuePrinter.shared.startMWQueue()
                }else{
                self.otherPrinter?.printToAvaliblePrinters(Order: self.orderVc?.order)
                SharedManager.shared.epson_queue.run()
                }
                 if SharedManager.shared.appSetting().enable_force_longPolling_multisession {
                AppDelegate.shared.run_poll_send_local_updates()
                }
            }
            self.order_deleted(order_selected: order_vc.order)
            }
            }
        })
                     
        alert.addAction(action_void)

        alert.addAction(UIAlertAction(title: "Cancel".arabic("الغاء") , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func cancel_discount()
    {
        self.newBannerHolderview.labelDiscount.text = "Discount".arabic("خصم")
        let line_discount = self.orderVc?.order.get_discount_line()
        if line_discount != nil
        {
            line_discount?.discount_program_id = 0
            line_discount?.is_void = true
            _ =  line_discount?.save(write_info: true, updated_session_status: .last_update_from_local)
            //                    pos_order_line_class.delete_line(line_id: line_discount!.id)
            
            //                    self.orderVc?.order.discountProgram!.discount_product?.update_values()
            self.orderVc?.order.save(write_info: false, updated_session_status: .last_update_from_local, re_calc: true)
            self.reloadTableOrders(re_calc: false)
            self.newBannerHolderview.labelDiscount.text = "Discount".arabic("خصم")
        }
        
    }
    func cancel_service_charge(productID:Int,voidStatus:void_status_enum? = nil)
    {
        if var line_servce_charge = self.orderVc?.order.get_service_charge_line(for: productID){
            line_servce_charge.is_void = true
            if let voidStatus = voidStatus {
                line_servce_charge.void_status = voidStatus
            }
            _ =  line_servce_charge.save(write_info: true, updated_session_status: .last_update_from_local)
        }
        if let indexLine = self.orderVc?.order.pos_order_lines.firstIndex(where: {$0.product_id == productID }){
            self.self.orderVc?.order.pos_order_lines[indexLine].is_void = true
            if let voidStatus = voidStatus {
                self.self.orderVc?.order.pos_order_lines[indexLine].void_status = voidStatus
            }
            self.self.orderVc?.order.pos_order_lines[indexLine].save(write_info: true)
        }
    }
    
    func print_res()
    {
       
        rules.check_access_rule(rule_key.print_bill,for: self) {
            DispatchQueue.main.async {
                self.completePrintRES( )
            }
        }
        let printer_status_vc = DGTERA.printer_status()
        printer_status_vc.modalPresentationStyle = .overCurrentContext
        
        self.present(printer_status_vc, animated: true, completion: nil)
        
    }
    func completePrintRES(){
        //MARK:- To Avoid print void line for bill non_void_line_order
        let option = ordersListOpetions()
        option.parent_product = true
         let non_void_line_order = orderVc!.order.copyOrder(option: option)
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            if let orderID = self.orderVc?.order.id {
                DispatchQueue.global(qos: .background).async {
                    pos_order_helper_class.increment_print_count(order_id: orderID)
                    non_void_line_order.creatBillQueuePrinter(.bill, openDrawer: false)
                    self.orderVc?.order.creatKDSQueuePrinter(.kds)
                    MWRunQueuePrinter.shared.startMWQueue()
                    
                    self.orderVc?.order.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
                    
                    var ip_message_type: IP_MESSAGE_TYPES = .NEW_ORDER
                    if self.orderVc?.order.checISSendToMultisession() ?? false {
                        ip_message_type = .ChANGED_ORDER
                    }
                    self.orderVc?.order.save_and_send_to_kitchen(with:ip_message_type, for: [.KDS,.NOTIFIER]) 
                    DispatchQueue.main.async {
                        self.newBannerHolderview.setEnableSendKitchen(with: false)
                        self.clear_right()
                        self.orderVc?.order.reloadOrder(with: self.pendding_options())
                        self.orderVc?.tableview.reloadData()
                    }
                }
            }
        }else{

        let order_print = orderPrintBuilderClass(withOrder: non_void_line_order,subOrder: [])
            order_print.hideNotPaid = false
//        order_print.for_waiter = true
        let setting = SharedManager.shared.appSetting()
        order_print.qr_print = true //setting.qr_enable
        order_print.qr_url = setting.qr_url

        let html = order_print.printOrder_html()
        
        
        DispatchQueue.global(qos: .background).async {
            
            runner_print_class.runPrinterReceipt_image(  html: html , openDeawer: false,row_type: rowType.bill,order_id: non_void_line_order.id ?? 0)
        }
        }
    }
    
    
    func show_scrap()
    {
//        guard  rules.check_access_rule(rule_key.scrap) else {
//            return
//        }
        rules.check_access_rule(rule_key.scrap,for: self) {
            DispatchQueue.main.async {
                self.completeScrap( )
            }
        }
        
    }
    func completeScrap(){
        if orderVc?.order.pos_order_lines.count == 0
        {
            printer_message_class.show("Please add product.".arabic("اضف منتج"))
            return
        }
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "scrap_list") as! scrap_list
        
        vc.orderVc.order = orderVc?.order
        vc.delegate = self
        
        let activeSession = pos_session_class.getActiveSession()
        vc.orderVc.order.session_id_local = activeSession!.id
        
        //        vc.preferredContentSize = CGSize(width: 800, height: 700)
        
        
        //        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .overFullScreen
        
        
        //        let popover = vc.popoverPresentationController!
        //        //        popover.delegate = self
        //        popover.permittedArrowDirections = .down //UIPopoverArrowDirection(rawValue: 0)
        //        popover.sourceView = sender as? UIView
        //        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func btnScrap(_ sender: Any)
    {
        show_scrap()
    }
    
    func disconutOption_selected(disocunt:pos_discount_program_class)
    {
        pop_up?.close()
        cancel_discount()

        let productDiscount = pos_discount_program_class.get_discount_product()
        if  productDiscount != nil
        {
            if disocunt.dicount_type == "fixed" && disocunt.amount > (orderVc?.order.amount_total)!
            {
                printer_message_class.show_in_view("Discout is higher than bill value".arabic("الخصم اعلى من قيمه الفاتوره"), view: self.view)
                
            }
            else if  disocunt.dicount_type == "fixed" && disocunt.amount < (orderVc?.order.amount_total)!
            {
                add_discount(value: -1 * disocunt.amount  , is_fixed: true, product_discount: (productDiscount?.product)! ,discount_display_name: disocunt.display_name,disocunt: disocunt)
                reloadTableOrders(re_calc: false)
                didApplyDiscount()
            }
            else if  disocunt.dicount_type == "percentage"
            {
                add_discount(value: -1 * disocunt.amount  , is_fixed: false, product_discount: (productDiscount?.product)! ,discount_display_name: disocunt.display_name,disocunt: disocunt)
                reloadTableOrders(re_calc: false)
                didApplyDiscount()
            }
            else
            {
                
                
                //                disocunt.discount_product = productDiscount
                
                //                orderVc?.order.discountProgram = disocunt
                //                orderVc?.order.discountProgram!.discount_product?.update_values()
                //                orderVc?.order.save()
                //                reloadTableOrders(re_calc: false)
            }
            
        }
        
    }
    func didApplyDiscount() {
        self.newBannerHolderview.labelDiscount.text = "Cancel Discount".arabic("إلغاء الخصم")
    }
    func add_discount( value:Double,is_fixed:Bool ,product_discount:product_product_class , discount_display_name:String,disocunt:pos_discount_program_class?)
    {
        let line_discount = pos_order_line_class.get_or_create(order_id: (orderVc?.order.id!)!, product: product_discount)
        line_discount.product = product_discount
        line_discount.order_id = (orderVc?.order.id!)!
        
        
        if is_fixed
        {
            if disocunt != nil
            {
                line_discount.discount_program_id = disocunt!.id

            }
            
            line_discount.discount_display_name = discount_display_name
            line_discount.discount = value * -1
            line_discount.discount_type = .fixed
            line_discount.custom_price = value
            line_discount.price_unit = value
            
            line_discount.update_values_discount_line()
            
        }
        else
        {
            let discount_value = orderVc?.order.get_discount_percentage_value(percentage_value: value)
            
            if disocunt != nil
            {
                line_discount.discount_program_id = disocunt!.id

            }

            line_discount.custom_price = discount_value?.price_subtotal_incl
            line_discount.price_unit = discount_value?.price_subtotal_incl
            line_discount.discount_display_name = discount_display_name
            line_discount.discount_type = .percentage
            line_discount.discount = value * -1
            line_discount.update_values_discount_line()
            
            line_discount.price_subtotal = discount_value!.price_subtotal * -1
            
            
           
        }
        
        
        _ =  line_discount.save(write_info: true, updated_session_status: .last_update_from_local)
        
        orderVc?.order.save(write_info: true, updated_session_status: .last_update_from_local, re_calc: true)
        
        
    }
    
//    func get_discount_percentage_value( percentage_value:Double) -> (price_subtotal:Double,price_subtotal_incl:Double)
//    {
//        var total_price_subtotal_incl:Double  = 0
//        var total_price_subtotal:Double  = 0
//
//
//        for line in orderVc?.order.pos_order_lines
//        {
//            let price_subtotal_incl = line.price_subtotal_incl
//
//            let percentage_subtotal_incl = (price_subtotal_incl! * percentage_value) / 100
//            total_price_subtotal_incl = total_price_subtotal_incl + percentage_subtotal_incl
//
//            let price_subtotal  = line.price_subtotal
//            let percentage_subtotal = (price_subtotal! * percentage_value) / 100
//            total_price_subtotal = total_price_subtotal + percentage_subtotal
//
//            if line.is_combo_line!
//            {
//                for sub_line in line.selected_products_in_combo
//                {
//                    let price_subtotal_incl = sub_line.price_subtotal_incl
//                    let sub_percentage = (price_subtotal_incl! * percentage_value) / 100
//                    total_price_subtotal_incl = total_price_subtotal_incl + sub_percentage
//
//
//                    let price_subtotal = sub_line.price_subtotal
//                    let sub_percentage2 = (price_subtotal! * percentage_value) / 100
//                    total_price_subtotal = total_price_subtotal + sub_percentage2
//
//                }
//            }
//        }
//
//        return (total_price_subtotal,total_price_subtotal_incl )
//    }
    
    func show_discount()
    {
        let pos = SharedManager.shared.posConfig()

          rules.check_access_rule(rule_key.discount,for: self)  {
              self.show_discount_actionSheet()
            /*
            if  !pos.pin_code.isEmpty {
                get_pin(title: "Please enter pin code .".arabic("من فضلك ادخل الرقم السرى"))
                return
            }else{
                guard rules.check_access_rule(rule_key.discount) else {
                    return
                }
            }
            */
        }
        
        
     
    }
    
     func get_pin(title:String)
    {
        let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "pinCode") as! pinCode
        controller.delegate = self
        controller.mode_get_only = true
        controller.title_vc = title
       self.present(controller, animated: true, completion: nil)
    }
    
    func closeWith(pincode:String)
    {
        let pos = SharedManager.shared.posConfig()
        SharedManager.shared.printLog(pos.pin_code)
        if pos.pin_code == pincode
        {
            show_discount_actionSheet()
        }
        else
        {
        
            messages.showAlert("invalid pin code".arabic("الرقم السرى خطأ"))

            
        }
        
    }
    func show_discount_actionSheet()
    {
        let alert = UIAlertController(title: "Discount".arabic("خصم"), message: "Pleas select action.".arabic("اختار نوع الخصم"), preferredStyle: .alert)
        
        
        let arr_discount = pos_discount_program_class.getAll()  // api.get_last_cash_result(keyCash: "get_discount_program")
        if arr_discount.count > 0
        {
            
            
            let action_fixed = UIAlertAction(title: "Fixed".arabic("ثابت") , style: .default, handler: { (action) in
                
                self.show_discount_fixed()
                alert.dismiss(animated: true, completion: nil)
                
                
            })
            //fixedـdiscount
            if  user.canAccess(for: .discount) == false
            {
               // action_fixed.titleTextColor = UIColor.gray
            }
         
            
            alert.addAction(action_fixed)
            
            let action_Percentage = UIAlertAction(title: "Percentage".arabic("نسبه") , style: .default, handler: { (action) in
                
                
                self.show_discount_percentage()
                
                alert.dismiss(animated: true, completion: nil)
                
            })
            //percentageـdiscount
            if   user.canAccess(for: .discount) == false
            {
              //  action_Percentage.titleTextColor = UIColor.gray
            }
            
            alert.addAction(action_Percentage)
        }
        
        
        let action_Custom = UIAlertAction(title: "Custom".arabic("خاص") , style: .default, handler: { (action) in
            
            
            self.show_discount_custome()
            
            alert.dismiss(animated: true, completion: nil)
            
        })
            
        if  user.canAccess(for: .customـdiscount) == false
        {
            //action_Custom.titleTextColor = UIColor.gray
        }
        
        alert.addAction(action_Custom)
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel".arabic("الغاء") , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func show_discount_fixed()
    {
        //fixedـdiscount
//        guard  rules.check_access_rule(rule_key.discount) else {
//            return
//        }
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        self.disconut_Option = storyboard.instantiateViewController(withIdentifier: "disconutOption") as? disconutOption
        self.disconut_Option.dicountType = .fixed
        self.disconut_Option.delegate = self
        self.disconut_Option.modalPresentationStyle = .popover
        self.disconut_Option.getDisconutOption()

//        let popover =  self.disconut_Option.popoverPresentationController!
//        //        popover.delegate = self
//        //            popover.permittedArrowDirections = .down //UIPopoverArrowDirection(rawValue: 0)
//        popover.sourceView = self.btn_more
//        popover.sourceRect =  (self.btn_more as AnyObject).bounds
//        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//
//
//        self.present( self.disconut_Option, animated: true, completion: nil)
        
        pop_up  = options_listVC(nibName: "options_popup", bundle: nil)
        pop_up?.hideClearBtnFlag = true
        pop_up!.modalPresentationStyle = .overFullScreen
        pop_up!.modalTransitionStyle = .crossDissolve
        pop_up!.parent_viewController = disconut_Option
        pop_up!.title = "Select discount fixed".arabic("خصم ثابت")
        
        options_listVC.show_option(list:pop_up!,viewController: self, sender: newBannerHolderview.discountBtn!   )
        
        
    }
    
    
    func show_discount_percentage()
    {
        //percentageـdiscount
//        guard  rules.check_access_rule(rule_key.discount) else {
//            return
//        }
        
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        self.disconut_Option = storyboard.instantiateViewController(withIdentifier: "disconutOption") as? disconutOption
        self.disconut_Option.dicountType = .percentage
        self.disconut_Option.delegate = self
        self.disconut_Option.modalPresentationStyle = .popover
        self.disconut_Option.getDisconutOption()
        
//        let popover = self.disconut_Option.popoverPresentationController!
//        //        popover.delegate = self
//        //            popover.permittedArrowDirections = .down //UIPopoverArrowDirection(rawValue: 0)
//        popover.sourceView = self.btn_more
//        popover.sourceRect =  (self.btn_more as AnyObject).bounds
//        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//
//
//        self.present(self.disconut_Option, animated: true, completion: nil)
        
        
        pop_up  = options_listVC(nibName: "options_popup", bundle: nil)
        pop_up?.hideClearBtnFlag = true
        pop_up!.modalPresentationStyle = .overFullScreen
        pop_up!.modalTransitionStyle = .crossDissolve
        pop_up!.parent_viewController = disconut_Option
        pop_up!.list_count = disconut_Option.list_items.count
        pop_up!.title = "Select discount percentage".arabic("خصم نسبه")
        
        options_listVC.show_option(list:pop_up!,viewController: self, sender: newBannerHolderview.discountBtn!   )
        
    }
    
    func show_discount_custome()
    {
//        guard  rules.check_access_rule(rule_key.customـdiscount) else {
//            return
//        }
        
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        self.getBalance = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew
        self.getBalance.modalPresentationStyle = .popover
        //        invoices_List.delegate = self
        self.getBalance.preferredContentSize = CGSize(width: 400, height: 715)
        self.getBalance.delegate = self
        self.getBalance.key = "custom_discount"
        
        let popover = self.getBalance.popoverPresentationController!
        //        popover.delegate = self
        //            popover.permittedArrowDirections = .left //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = self.newBannerHolderview.discountBtn
        popover.sourceRect =  (self.newBannerHolderview.discountBtn as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(self.getBalance, animated: true, completion: nil)
    }
    
    
    
    func newBalance(key:String,value:String)
    {
        if key == "order_type_reference"
        {
            
            orderVc?.order.delivery_type_reference = value
            if checIfOrderSendToMultisession() {
                self.orderVc?.order.save(write_info: true, updated_session_status: .sending_update_to_server, re_calc: false)
            }else{
                self.orderVc?.order.save(write_info: false , re_calc: false)
            }
            self.checkTotalDiscount()
            return
        }
        else if (key == "Promotion code")
        {
            return
        }
        
        
        let productDiscount = pos_discount_program_class.get_discount_product()
        if  productDiscount != nil
        {
            if  value.toDouble() ?? 0 > (orderVc?.order.amount_total)!
            {
                printer_message_class.show_in_view("Discout is higvher than bill value".arabic("الخصم اعلى من قيمه الفاتوره"), view: self.view)
                
            }
            else
            {
                
                //                let currency = productDiscount!.product.currency_name ?? ""
                
                //                let disocunt =  pos_discount_program_class()
                ////                disocunt.discount_product = productDiscount
                //                disocunt.name = value + " " + currency
                //                disocunt.amount = value.toDouble() ?? 0
                //                disocunt.dicount_type = "fixed"
                //
                //
                //                orderVc?.order.discount_program_id = 0
                //                orderVc?.order.discount = -1 * (value.toDouble() ?? 0)
                //                orderVc?.order.discountProgram!.discount_product?.update_values()
                cancel_discount()
                
                add_discount(value: -1 * (value.toDouble() ?? 0), is_fixed: true, product_discount: (productDiscount?.product)!,discount_display_name:productDiscount!.discount_display_name! ,disocunt: nil)
                
                reloadTableOrders(re_calc: false)
                self.didApplyDiscount()
            }
            
            
        }
    }
    
    
    func show_price_list()
    {
//        guard  rules.check_access_rule(rule_key.pricelist) else {
//            return
//        }
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        priceListVC = storyboard.instantiateViewController(withIdentifier: "price_listVC") as? price_listVC
        priceListVC.modalPresentationStyle = .popover
        priceListVC.delegate = self
        
        //         let popover = priceListVC.popoverPresentationController!
        //         //        popover.delegate = self
        //         popover.permittedArrowDirections = .left //UIPopoverArrowDirection(rawValue: 0)
        //        popover.sourceView = btn_more
        //         popover.sourceRect =  (btn_more as AnyObject).bounds
        //         //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        //
        //
        //         self.present(priceListVC, animated: true, completion: nil)
        
        pop_up  = options_listVC(nibName: "options_popup", bundle: nil)
        pop_up?.hideClearBtnFlag = true
        pop_up!.modalPresentationStyle = .overFullScreen
        pop_up!.modalTransitionStyle = .crossDissolve
        pop_up!.parent_viewController = priceListVC
        pop_up!.title = "Select Price list".arabic("قائمه الاسعار")
        
        options_listVC.show_option(list:pop_up!,viewController: self, sender: newBannerHolderview.btn_more!   )
        
        
    }
    
    @IBAction func btnPriceList(_ sender: Any) {
        
        
        show_price_list()
        
    }
    
    func priceListSelected()
    {
        pop_up?.close()
        
        if priceListVC.selectedItem != nil
        {
            orderVc?.order.priceList = priceListVC.selectedItem
            orderVc?.priceList = priceListVC.selectedItem
            orderVc?.order.applyPriceList()
            orderVc?.order.save()
            
            //            let text =  priceListVC.selectedItem
            //            lblinfo.text = "Price list :" +  priceListVC.selectedItem.name!
            
            setTitleInfo()
            
            orderVc?.tableview.reloadData()
//            self.orderVc?.reloadTableOrders()
//            self.reloadTableOrders()
            collection.reloadData()
            
            reloadTableOrders(re_calc: false)
            
            priceListVC.selectedItem = nil
        }
        
        menu_left.closeMenu()
        
    }
    
    
    func show_order_type()
    {
        btnOrderTypeList(AnyClass.self)
    }
    
    func open_order_type(category_id:Int? = nil)
    {
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        orderTypeVC = storyboard.instantiateViewController(withIdentifier: "order_type_list") as? order_type_list
        orderTypeVC.modalPresentationStyle = .popover
        orderTypeVC.delegate = self
        orderTypeVC.category_id = category_id
        
        let popover = orderTypeVC.popoverPresentationController!
        //        popover.delegate = self
        popover.permittedArrowDirections = .any //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = newBannerHolderview.btn_more
        popover.sourceRect =  (newBannerHolderview.btn_more as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(orderTypeVC, animated: true, completion: nil)
        
    }
    @IBAction func btnOrderTypeList(_ sender: Any) {
        if self.payment_Vc != nil
        {
            self.clear_right()
        }
        
        let arr: [[String:Any]] =   delivery_type_category_class.getAllHaveDelivery(deleted: false)
//        if arr.count == 0
//        {
//            self.open_order_type()
//            return
//
//        }
        
        
        let list = options_listVC(nibName: "options_popup", bundle: nil)
        list.hideClearBtnFlag = true
        list.modalPresentationStyle = .overFullScreen
        list.modalTransitionStyle = .crossDissolve
        list.title = "Order type category".arabic("نوع الطلب")
        
        let other: [[String:Any]] =   delivery_type_class.get_delivery_not_have_category(deleted: false)
        for item in other
        {
            var dic = item
            
            dic[options_listVC.title_prefex] =    (dic["display_name"] as? String ?? "")
            dic["is_category"] = "no"
            list.list_items.append(dic)
            
        }
        
        for item in arr
        {
            var dic = item
            
            dic[options_listVC.title_prefex] =   (dic["display_name"] as? String ?? "")
            dic[options_listVC.cell_style] = options_listVC.style_arrow
            dic["is_category"] = "yes"
            
            list.list_items.append(dic)
            
        }
        
        
        
        
        list.didSelect = { [weak self] data in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("change_order_type"), object: data)
            }
            let is_category = data["is_category"] as? String ?? ""
            if is_category == "yes"
            {
                let cls = delivery_type_category_class(fromDictionary: data)
                
                self!.open_order_type(category_id: cls.id)
            }
            else
            {
                if self?.payment_Vc != nil
                {
                    self?.clear_right()
                }
                let order_type_id = data["id"] as? Int ?? 0
                let orderTypeSelected = delivery_type_class.get(id: order_type_id)
                self!.orderTypeVC.selectedItem = orderTypeSelected
                self!.order_typeSelected()
            }
            
        }
        
        
        list.clear = {
            
            
        }
        
        options_listVC.show_option(list:list,viewController: self, sender: btnSelectOrderType   )
        
        
        
        
    }
    
    func order_typeSelected()
    {
        let currentServiceChargeProduct = orderVc?.order.orderType?.service_product_id ?? 0
        let isCurrentDeliveryType = (orderVc?.order.orderType?.order_type ?? "") == "delivery"
        let currentDeliveryID = orderVc?.order.orderType?.delivery_product_id

        if orderTypeVC.selectedItem?.id == orderVc?.order.orderType?.id
        {
            if orderTypeVC.selectedItem.require_info
            {
                if  ((self.orderVc?.order.delivery_type_reference?.isEmpty) ?? false){
                    order_type_reference()
                    return
                }else{
                    checkDefaultCustomer()
                    doPayment()
                    return

                }
            }
            else
            {
                self.orderVc?.order.delivery_type_reference = ""
                checkDefaultCustomer()
                doPayment()
                return

            }
            doPayment()
            return
        }
        
        newBannerHolderview.setEnableSendKitchen(with: true)
//        failureSendBtn.isHidden = true

        
        if orderTypeVC.selectedItem != nil
        {
            NSLog("\n\n\n\n\n\n%@" , orderTypeVC.selectedItem.name )
            
            
            if orderVc?.order.id == nil
            {
                if SharedManager.shared.appSetting().prevent_new_order_if_empty {
                    if !pos_order_class.checkIfSessionHaveEmptyOrder() {
                        orderVc?.order = pos_order_helper_class.creatNewOrder()
                        readOrder()
                        reloadTableOrders()
                    } else {
                        SharedManager.shared.initalBannerNotification(title:  "Not Allowed".arabic("غير مسموح"), message: "Can't Add new order. current order is empty".arabic("لا يمكنك انشاء طلب جديد والطلب الحالي مازال فارغ"), success: false, icon_name: "icon_error")
                        SharedManager.shared.banner?.dismissesOnTap = true
                        SharedManager.shared.banner?.show(duration: 3)
                        return
                    }
                } else {
                    orderVc?.order = pos_order_helper_class.creatNewOrder()
                    readOrder()
                    reloadTableOrders()
                }
            }
            
            
            if orderTypeVC.selectedItem.id == 0
            {
                orderVc?.order.orderType = nil
                orderVc?.order.priceList = nil
                self.orderVc?.priceList = nil
                
                self.lblinfo.text = ""
                //                    btnSelectOrderType.setTitle("Order type", for: .normal)
                
                orderVc?.order.save(write_date:false,re_calc: true)
                orderVc?.tableview.reloadData()
//                self.orderVc?.reloadTableOrders()
                self.reloadTableOrders()
                collection.reloadData()
                reloadTableOrders(re_calc: false)
                orderTypeVC.selectedItem = nil
                
                
                
            }
            else
            {
                
                if orderTypeVC.selectedItem.require_info
                {
                    
                    order_type_reference()
                }
                else
                {
                    self.orderVc?.order.delivery_type_reference = ""
                }
                
                self.orderVc?.order = promotionSelectHelper.deletePromotionInOrder(order: self.orderVc!.order, delivery_type: orderTypeVC.selectedItem)

                
                getPriceList_In_OrderType(orderType: orderTypeVC.selectedItem)
                
           
//                if let order_vc = self.orderVc{
//                for line in  order_vc.order.pos_order_lines {
//                     handle_promotion(line: line)
//                }
//
//                }
                
            }
            
            
            
        }
        
        NSLog("\n\n\n\n\n\n%@" , self.orderVc?.order.orderType?.name ?? "")
        if self.orderVc?.order.orderType?.required_driver ?? false{
            if self.newBannerHolderview.btn_table.tag != 1 {
                self.newBannerHolderview.btn_table.tag = 1
                self.newBannerHolderview.labelTable.textValue = "Driver".arabic("السائق")
                self.newBannerHolderview.tableImageView.image = UIImage(named: "driver-icon")

                
                self.orderVc?.order.table_id = 0
                self.orderVc?.order.table_name = ""
                self.orderVc?.order.floor_name = ""
                if checIfOrderSendToMultisession() {
                    self.orderVc?.order.save(write_info: true,   updated_session_status: .sending_update_to_server , re_calc: false)
                }else{
                    self.orderVc?.order.save(write_info: false, re_calc: false)
                }
            }
        }else{
            if let tableName = self.orderVc?.order.table_name, !tableName.isEmpty {
                self.newBannerHolderview.labelTable.textValue = tableName
                self.newBannerHolderview.tableImageView.image = UIImage(named: "table-icon")
            }else{
                self.newBannerHolderview.btn_table.tag = 0
                self.newBannerHolderview.labelTable.textValue = "Table".arabic("الطاولة")
                self.newBannerHolderview.tableImageView.image = UIImage(named: "table-icon")
            }
            
            self.orderVc?.order.driver_id = 0
            if checIfOrderSendToMultisession() {
                self.orderVc?.order.save(write_info: true,   updated_session_status: .sending_update_to_server, re_calc: false)
            }else{
                self.orderVc?.order.save(write_info: false , re_calc: false)
            }


        }
        if currentServiceChargeProduct != 0 && (self.orderVc?.order.orderType?.service_product_id ?? 0) != currentServiceChargeProduct {
            self.cancel_service_charge(productID: currentServiceChargeProduct)
        }
        if isCurrentDeliveryType && ((self.orderVc?.order.orderType?.order_type ?? "") != "delivery") {
            if let pos_delivery_area_id = self.orderVc?.order.customer?.pos_delivery_area_id,
               let delivery_area = pos_delivery_area_class.getBy(id: pos_delivery_area_id){
                self.cancel_service_charge(productID: delivery_area.delivery_product_id)
                self.orderVc?.delegate?.reloadOrders(line: nil)
        }
            if let develiveryProductId = currentDeliveryID{
                self.cancel_service_charge(productID: develiveryProductId)
                self.orderVc?.delegate?.reloadOrders(line: nil)

            }

        }
        checkDefaultCustomer()
        doPayment()
        
        setTitleInfo()
    }
    
    func checkDefaultCustomer(){
        if let defaultCustomerID =   (self.orderVc?.order.orderType?.default_customer_id ) , defaultCustomerID != 0 {
            let defaultCustomer = res_partner_class.getResPartner(partner_id: defaultCustomerID)
            self.customerVC?.selectedCustomer = defaultCustomer
            self.checkCustomerSelected()
        }
    }
    
    func order_type_reference()
    {
        
        DispatchQueue.main.async {
            
            let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
            self.getBalance = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew
            self.getBalance.modalPresentationStyle = .popover
            //        invoices_List.delegate = self
            
            self.getBalance.delegate = self
            self.getBalance.key = "order_type_reference"
            self.getBalance.title_vc = "Order type reference".arabic("رقم نوع الطلب")
            
            self.getBalance.disable = false
            
            let popover = self.getBalance.popoverPresentationController!
            //        popover.delegate = self
            popover.permittedArrowDirections = .left //UIPopoverArrowDirection(rawValue: 0)
            popover.sourceView = self.btnSelectOrderType //self.newBannerHolderview.btn_more
            popover.sourceRect =  self.btnSelectOrderType.bounds //(self.newBannerHolderview.btn_more as AnyObject).bounds
            //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            
            self.present(self.getBalance, animated: true, completion: nil)
            
        }
        
        
    }
    
    
    func restLastSelectedOrderType(orderType: delivery_type_class!)
    {
    
//        guard let delivery_type_id = self.orderVc?.order.delivery_type_id else {return}
//
//        if delivery_type_id == orderType.id
//        {
//            return
//        }
        
//        let delivery_product  = delivery_type_class.getDeliveryProduct(for: orderType.id)
        let isDeliveryType = (orderType?.order_type ?? "") == "delivery"
        if !isDeliveryType {
            self.orderVc?.order.void_delivery_area_line(orderVc?.order.customer,voidState: .cancel_delivery)
        }else{
            if let customerOrder = self.orderVc?.order.customer , customerOrder.pos_delivery_area_id != 0 {
                self.addDeliveryFees(for:customerOrder)
            }
        }

        let delivery_product  = delivery_type_class.getDeliveryProduct(for: nil)
//        if delivery_type_id == delivery_product.id
//        {
            let d_product = pos_order_line_class.get(order_id: (self.orderVc?.order.id!)!, product_id:delivery_product.delivery_product_id)
             if d_product != nil
             {
                d_product!.is_void = true
                _ = d_product!.save()
             }
             
//        }
        
    }
    
    func getPriceList_In_OrderType(orderType: delivery_type_class!)
    {
        restLastSelectedOrderType(orderType: orderType)
        
        let pricelist_id:Int = orderType.pricelist_id
        let get_product_pricelist_arr:[[String:Any]] = product_pricelist_class.getAll() //  api.get_last_cash_result(keyCash: "get_product_pricelist")
        if  get_product_pricelist_arr.count > 0
        {
            
            for item:[String:Any] in get_product_pricelist_arr
            {
                let id = item["id"] as? Int ?? 0
                if id == pricelist_id
                {
                    self.orderVc?.order.priceList = product_pricelist_class(fromDictionary: item)
                    self.orderVc?.priceList = self.orderVc?.order.priceList
                    self.orderVc?.order.applyPriceList()

                    self.lblinfo.text = "Price list :".arabic("قائمه الاسعار") +  (self.orderVc?.order.priceList?.name ?? "")
                }
            }
            
            self.orderVc?.order.orderType = orderType
            self.checkDefaultCustomer()

//            let pos = SharedManager.shared.posConfig()
            let isCustHaveDelivery = (self.orderVc?.order.customer?.pos_delivery_area_id ?? 0) != 0
            if self.orderVc?.order.orderType!.order_type == "delivery" && !isCustHaveDelivery
            {
                self.orderVc?.order.delivery_amount = orderType.delivery_amount

                let delivery_type  = delivery_type_class.getDeliveryProduct(for:self.orderVc?.order.orderType?.id)
                 
                if delivery_type.id != 0
                {
                    self.addDeliveryProductToOrder(delivery_product_id:delivery_type.delivery_product_id,delivery_amount:delivery_type.delivery_amount)
                   /*
                    let product = product_product_class.get(id: delivery_product.delivery_product_id)
                    if product != nil
                    {
                        
                        self.orderVc?.order.orderType!.delivery_product_id = delivery_product.delivery_product_id
                        
                        var d_product = pos_order_line_class.get (order_id: (self.orderVc?.order.id!)!, product_id:product!.id)
                        if d_product == nil
                        {
                            d_product = pos_order_line_class.create(order_id: (self.orderVc?.order.id!)!, product: product!)
                        }
                        d_product?.custom_price = delivery_product.delivery_amount
                        d_product!.product_id = product?.id
                        d_product!.is_void = false
                        d_product!.update_values()
                        _ = d_product!.save()
                        
                    }
                    */
                     
                }
            }
//            else if pos.extra_fees == true // self.orderVc?.order.orderType!.order_type == "extra"
//            {
////                let extra_product  = delivery_type_class.getExtraProduct()
//
//                if pos.extra_product_id != 0
//                {
//
//                    let product = product_product_class.get(id:  pos.extra_product_id!)
//                if product != nil
//                {
//
////                    self.orderVc?.order.orderType!.extra_product_id = pos.extra_product_id!
//
//                    var d_product = pos_order_line_class.get (order_id: self.orderVc?.order.id!, product_id:product!.id)
//                    if d_product == nil
//                    {
//                        d_product = pos_order_line_class.create(order_id: self.orderVc?.order.id!, product: product!)
//                    }
//
//                    d_product!.product_id = pos.extra_product_id!
//                    d_product!.is_void = false
//                    d_product!.update_values()
//                    _ = d_product!.save()
//
//
//
//                }
//            }
//            }
            
            self.orderVc?.order.save(write_info: false, updated_session_status: .last_update_from_local, re_calc: true)
            self.orderVc?.tableview.reloadData()
//            self.orderVc?.reloadTableOrders()
//            self.reloadTableOrders()
            self.collection.reloadData()
            self.checkTotalDiscount()
            reloadTableOrders(re_calc: false)
            self.orderTypeVC.selectedItem = nil
        }
    }
    
  @discardableResult func addDeliveryProductToOrder(delivery_product_id:Int,delivery_amount:Double) -> pos_order_line_class?{
      if delivery_amount <= 0 {
          return nil
      }
            let product = product_product_class.get(id: delivery_product_id)
            if product != nil
            {
                
                self.orderVc?.order.orderType!.delivery_product_id = delivery_product_id
                
                var d_product = pos_order_line_class.get (order_id: (self.orderVc?.order.id!)!, product_id:product!.id)
                if d_product == nil
                {
                    d_product = pos_order_line_class.create(order_id: (self.orderVc?.order.id!)!, product: product!)
                }
                d_product?.custom_price = delivery_amount
                d_product!.product_id = delivery_product_id
                d_product!.is_void = false
                d_product!.update_values()
                _ = d_product!.save()
                return d_product
                
            }
      return nil
    }
    
}
