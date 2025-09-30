//
//  File.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

typealias order_list_view = create_order
extension order_list_view:order_listVc_delegate
{
    
    
    func initViewOrderList()
      {
        if self.orderVc != nil
          {
              return
          }
          
          let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        self.orderVc = storyboard.instantiateViewController(withIdentifier: "order_listVc") as? order_listVc
          
          //        orderVc = order_listVc()
        self.orderVc?.delegate = self
        self.orderVc?.parent_vc = self
        self.orderVc?.parent_create_order = self
          
        self.orderVc?.view.frame = view_orderList.bounds
          
        self.view_orderList.addSubview(self.orderVc?.view ?? UIView())
      }
      
    func checkBadge()
    {
        DispatchQueue.main.async {
        let ActiveSession = pos_session_class.getActiveSession()
        
        let session_id = ActiveSession!.id
        
        let opetions = ordersListOpetions()
        opetions.Closed = false
        opetions.Sync = false
        opetions.void = false
        opetions.pickup_users_ids = [0]
        //        opetions.is_menu = false
        opetions.order_menu_status = [.accepted]
        
        opetions.sesssion_id = session_id
        opetions.parent_orderID = nil
        
        
        
        let count  = pos_order_helper_class.getOrders_status_sorted_count(options: opetions)
        if count == 0
        {
            self.newBannerHolderview.ordersBadgeHolderview.isHidden = true
        }
        else
        {
            self.newBannerHolderview.ordersBadgeHolderview.isHidden = false
            self.newBannerHolderview.lblOrderBadge.text = String(count)
            
        }
        
            self.checkBadgeMenu()
    }
    }
    
    func checkBadgeMenu()
    {
        let ActiveSession = pos_session_class.getActiveSession()
        
        let session_id = ActiveSession!.id
        
        let opetions = ordersListOpetions()
        opetions.Closed = false
        opetions.Sync = false
        opetions.void = false
        opetions.order_menu_status = [.pendding]
        opetions.order_integration = [ORDER_INTEGRATION.ONLINE,ORDER_INTEGRATION.DELIVERY]
        
        opetions.sesssion_id = session_id
        opetions.parent_orderID = nil
        
        
        let count = pos_order_helper_class.getOrders_status_sorted_count(options: opetions)
        
         if count == 0 {
             newBannerHolderview.menuOrderBadgeHolderview.isHidden = true
        }
        else
        {
            newBannerHolderview.menuOrderBadgeHolderview.isHidden = false
            newBannerHolderview.lblMenuBadge.text = String(count)
        }
        
        
    }
    
    func resetOrderView()
    {
        lblOrderID.text = "#"
        orderVc?.order = pos_order_class()
        orderVc?.resetVales()
        orderVc?.reload_footer()
        orderVc?.tableview.reloadData();
//        self.orderVc?.reloadTableOrders()
//        self.reloadTableOrders()
        orderVc?.refreshControl_tableview.endRefreshing()
        setupCustomerLayout()
        set_table_layout()
    }
    
    
    
    
    
    
    
    func set_total_ui()
    {
       
        let total = baseClass.currencyFormate((orderVc?.order.amount_total)! )
        let currency = SharedManager.shared.getCurrencyName()
        if currency.lowercased().contains("sar"){
            lbl_total_price.attributedText = SharedManager.shared.getRiayalSymbol(total: total )
        }else{
            lbl_total_price.text = total  + " " + currency

        }
        
        
        if orderVc?.order.amount_total == 0
        {
            let has_return = orderVc?.order.pos_order_lines.filter({$0.price_subtotal! < 0.0}) ?? []
            if has_return.count > 0
              {
                btnPayment.isEnabled = true

            }
            else if (orderVc?.order.pos_order_lines.count ?? 0) > 0
            {
                btnPayment.isEnabled = true
            }
            else
              {
                btnPayment.isEnabled = false

            }
        }
        else
        {
            btnPayment.isEnabled = true

        }
        
        let setting = SharedManager.shared.appSetting()
        btnPayment.isHidden = !setting.enable_payment
        if (SharedManager.shared.posConfig().pos_type?.lowercased().contains("waiter") ?? false){
//            btnPayment.isHidden = true
            btnPayment.isEnabled = false
            btnPayment.alpha = 0.5
        } else {
            btnPayment.isEnabled = true
            btnPayment.alpha = 1
        }

        
        //        btnPayment.setTitle(String(format: "Payment (%@)", total), for: .normal)
        
    }
    
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        readOrder()
        reloadTableOrders()
        
    }
    
    
    func re_read_order()
    {
  
         
     reloadOrders(line: nil)
        self.orderVc?.reload_footer()

     }
    
    func reloadTableOrders()
    {
        if orderVc?.order.pos_order_lines.count == 0 {
            
            orderVc?.order.total_items = 0
            orderVc?.order.amount_total = 0
            
        }
        
    //    self.orderVc?.orderReloadForUI()

        orderVc?.reload_tableview()
        
        
        
        
        set_total_ui()
        
        
   
            self.orderVc?.reload_footer()
    
        
  
    
        
     }
    
    func checkTotalDiscount()
    {
        SharedManager.shared.check_total.order = orderVc?.order
        SharedManager.shared.check_total.check()
        orderVc?.order = SharedManager.shared.check_total.order
        
     }
    
    func reloadTableOrders(re_calc:Bool = false,reSave:Bool = false)
    {
        if orderVc?.order.pos_order_lines.count == 0 {
            
            orderVc?.order.total_items = 0
            orderVc?.order.amount_total = 0
            
        }
        
        
        
        if re_calc == true
        {
            
            if reSave
            {
                orderVc?.order.save(write_info: true, updated_session_status: .last_update_from_local, re_calc: true)
            }
            else
            {
                orderVc?.order.calcAll()

            }
        }
        
        checkTotalDiscount()
        reloadTableOrders()
//        orderVc?.reload_tableview()

        
        
        set_total_ui()
        
        
   

            self.orderVc?.reload_footer()

        self.check_kitchen()
        
 /*
        let peer = SharedManager.shared.multipeerSession()
        if peer != nil
        {
 
           let json = peer!.message?.build(order: orderVc!.order)
            peer!.send(json)
        }
*/
    }
    
    
    @objc func readOrder()   {
        
        if orderVc?.order.id == nil
        {
            resetOrderView()
            
            return
        }
        
        
        DispatchQueue.main.async {
            self.setTitleInfo()
            self.checkBadge()
            if self.orderVc?.order?.orderType?.required_guest_number ?? false && self.orderVc?.order.table_name != nil
                && self.orderVc?.order?.table_name?.isEmpty == false && self.orderVc?.order.guests_number == nil {
                self.add_guests_number()
            }
    }
        
        if (orderVc?.order.sequence_number ?? 0) <= 0
        {
            lblOrderID.text = "#"
        }
        else
        {
//            let pos = SharedManager.shared.posConfig()
//
//            if orderVc?.order.sequence_number_server != 0
//            {
//                lblOrderID.text = String(format: "#%d-%d",pos.id, orderVc?.order.sequence_number_server)
//            }
//            else
//            {
//                lblOrderID.text = String(format: "#%d-%d", pos.id,orderVc?.order.sequence_number)
//            }
            
            lblOrderID.text = "#\(orderVc?.order.sequence_number ?? 0)"//sequence_number_full //String(format: "#%d-%d", pos.id,orderVc?.order.sequence_number)

        }
        
        
        list_order_products  =  orderVc?.order.pos_order_lines
        
        //        btnSelectCustomer.setTitle(orderVc?.order.customer?.name ?? "Select  Customer", for: .normal)
        
        
        setupCustomerLayout()
         set_table_layout()
        check_kitchen()
        
        
        
    }
    
   
    
    func setTitleInfo()
    {
        lblinfo.text =  ""
        lbl_time.textValue = ""
        if orderVc?.order.priceList != nil
        {
            if let def = product_pricelist_class.getDefault(){
            if def.id != orderVc?.order.pricelist_id
            {
                lblinfo.text = "Price list : " +  (orderVc?.order.priceList!.name ?? "")
            }
            }
            
        }
        else
        {
            lblinfo.text = ""
        }
        
        if orderVc?.order.create_date != nil
        {
//            let dt = Date(strDate: orderVc?.order.create_date!, formate: baseClass.date_fromate_server ).toString(dateFormat:"yyyy-MM-dd / hh:mm a", UTC: false)
            let dt = Date(strDate: (orderVc?.order.create_date!)!, formate: baseClass.date_formate_database, UTC:   true).toString(dateFormat:"hh:mm a", UTC: false)
//            lbl_time.text = String(format: "%@"  , dt )
            lbl_time.textValue = String(format: "%@"  , dt )

//            lbl_orderType.text = String(format: "%@"  , orderVc?.order.orderType?.display_name ?? "")
            self.btnSelectOrderType.setTitle(orderVc?.order.orderType?.display_name ?? "", for: .normal)

            //            lblinfo.text = String(format: "%@\nDate : %@", lblinfo.text ?? "" , baseClass.getDateFormate(date: orderVc?.order.create_date!,formate:baseClass.date_fromate_server))
        }
        
        
        if let name_table = orderVc?.order.table_name
        {
            if !(name_table.isEmpty)
            {
                lblinfo.text =   String(format: "%@\n Table : %@", lblinfo.text ?? "" , name_table)
                
            }
            
        }
        
        
        if  let name_customer = orderVc?.order.customer
        {
            lblinfo.text =   String(format: "%@\n Customer : %@", lblinfo.text ?? "" , name_customer)
        }
        
        if let name_driver = orderVc?.order.driver
        {
            lblinfo.text =   String(format: "%@\n Driver : %@", lblinfo.text ?? "" , name_driver)
        }
        
        
        
        
        set_total_ui()
        
    }
    
}
