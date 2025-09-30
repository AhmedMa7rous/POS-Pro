//
//  payment.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
typealias payment = create_order
extension payment
{
  
    func close_old_session_to_allow_create_new_orders() -> Bool
           {
               let setting = settingClass.getSettingClass()
               let enable_auto_close = setting.close_old_session_to_allow_create_new_orders
               if enable_auto_close == true
               {
    
                   let last_session = pos_session_class.getActiveSession()
                   let start_session = last_session!.start_session!
   //                let start_session = "2022-04-27 23:01:18"
                   
                   let start_session_date = Date(strDate: start_session, formate: baseClass.date_formate_database, UTC: true)
       
   //                let time_now = Date(strDate: "2022-04-28 23:14:06", formate: baseClass.date_formate_database, UTC: true)
                   let time_now = Date()
                   
                  let left_days =  Date.daysBetween(start: start_session_date, end: time_now)
                   if left_days >= 1
                   {
                       return true
                   }
    
                   let bussines_day_str = start_session_date.toString(dateFormat: "yyyy-MM-dd", UTC: true)
                   let bussines_day = Date(strDate: bussines_day_str, formate: "yyyy-MM-dd", UTC: true)
                   
                   let time = setting.time_close_old_session_to_allow_create_new_orders
                   let minutes = Date.time_to_minutes(time: time, dateFormat: "hh:mm a")
                   
                   // local bussines_day
                   let new_bussines_day = bussines_day.add(minutes: minutes + 1440)
                   
                   // Convert to UTC
                   let new_bussines_day_str = new_bussines_day!.toString(dateFormat: baseClass.date_formate_database, UTC: true)
                   let bussines_day_utc = Date(strDate: new_bussines_day_str, formate: baseClass.date_formate_database, UTC: false)
    
   //                SharedManager.shared.printLog(time_now_local)
                   
   //                let time_now =  Date(strDate: "2021-11-12 05:42 PM" , formate:"yyyy-MM-dd hh:mm a", UTC: true)
                   
   //                SharedManager.shared.printLog(bussines_day)
   //                SharedManager.shared.printLog(new_bussines_day)

                   if bussines_day_utc <= time_now
                   {
                         
                       return true
       
                   }
       
               }
               
               return false
           }
        
    
    @IBAction func btnPayment(_ sender: Any)
      {
          if SharedManager.shared.newCombo{
              if let newComboVC = self.newComboVC{
                  if (newComboVC.mwComboVM?.isStateLoading() ?? false){
                      return
                  }
              }
          }
          if !MWMasterIP.shared.isOnLine(){
              self.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
              return
          }
          if let payment_Vc = self.payment_Vc{
              self.clear_right()
          }
          SharedManager.shared.updateLastActionDate()
        guard  !close_old_session_to_allow_create_new_orders() else {
            //"Please close session frist, to make new order."
            messages.showAlert(MWConstants.alert_close_time)
            return
        }
        
        
//        guard  rules.check_access_rule(rule_key.payment) else {
//            return
//        }
        
          rules.check_access_rule(rule_key.payment,for: self) {
              DispatchQueue.main.async {
                  self.completePayBtn(sender: sender )
              }
          }
          
          
      }
    func completePayBtn(sender: Any){
        if orderVc?.order.id == nil
        {
            return
        }
        if (orderVc?.order.pos_order_lines.filter({$0.is_void == false}).count ?? 0)  == 0
        {
            return
        }
        orderVc?.order.amount_return =  0
        orderVc?.order.amount_paid =  0
      
        let setting = SharedManager.shared.appSetting()
        
        if  (orderVc?.order.amount_total ?? 0) < 0
        {
          orderVc?.order.amount_return =  (orderVc?.order.amount_total)! * -1
          orderVc?.order.amount_paid =  (orderVc?.order.amount_total)!
            
            orderVc?.order.calcAll()
            orderVc?.order.save()
            
            
            openPayment()
        }
        else if orderVc?.order.order_integration == .DELIVERY {
            openPayment()

        }
        else if setting.enable_OrderType == .disable
        {
            if orderVc?.order.orderType == nil
            {
                let default_pricelist = product_pricelist_class.getDefault()
                if orderVc?.order.pricelist_id == default_pricelist!.id // no custom price list
                {
                    let defalut_orderType = delivery_type_class.getDefault()
                    if defalut_orderType != nil
                    {
                        getPriceList_In_OrderType(orderType: defalut_orderType)
                    }
                }
                
                
            }
            
            
            openPayment()
        }
        else
        {
            if orderVc?.order.orderType == nil
            {
              if let default_pricelist = product_pricelist_class.getDefault() {
                if orderVc?.order.pricelist_id == default_pricelist.id // no custom price list
                {
                    
                    let list:[[String:Any]] = delivery_type_class.getAll()
                    if list.count == 0
                    {
                        openPayment()
                    }
                    else
                    {
                        orderTypePayment = true
                        btnOrderTypeList(sender)
                    }
                }else{
                  openPayment()
                }
              }
                else
                {
                    openPayment()
                }
            }
            else
            {
              if setting.enable_OrderType == .InPayment
              {
                  orderTypePayment = true
                  btnOrderTypeList(sender)
              }
              else
              {
                  openPayment()
              }
                
            }
            
        }
        
    }
      
      func doPayment()
      {
        if self.orderTypePayment == false
          {
              return
          }
          
        self.orderTypePayment = false
          
        if  self.orderVc?.order.pos_order_lines.count == 0
          {
              printer_message_class.show("Please add product.")
              return
          }
          
          openPayment()
          
          
      }
    
    private func showAskCustomerAlert(){
          let message_warring = "Order type require choose customer".arabic("نوع الطلب يتطلب اختيار عميل")
        let alert = UIAlertController(title: "Attention!".arabic("تنبيه!"), message: message_warring,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue...".arabic("استمرار..."), style: .default, handler: { (action) in
            self.completeOpenPaymentVC()
        }))
        alert.addAction(UIAlertAction(title: "Choose Customer...".arabic("اختيار العميل..."), style: .default, handler: { (action) in
            
            self.do_select_customer(completePay: true)

        }))
        self.present(alert, animated: true, completion: nil)
    }
    private func showRequireCustomerAlert(){
          let message_warring = "Order type require choose customer".arabic("نوع الطلب يتطلب اختيار عميل")
        let alert = UIAlertController(title: "Attention!".arabic("تنبيه!"), message: message_warring,preferredStyle: .alert)
       
        alert.addAction(UIAlertAction(title: "Choose Customer...".arabic("اختيار العميل..."), style: .default, handler: { (action) in
            self.do_select_customer(completePay: true)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
      
      func openPayment()
      {
          let validationSelectCustomer = orderVc?.order.validationSelectCustomer() ?? (true,"")
          if !validationSelectCustomer.0 {
              let options_for_require_customer = SharedManager.shared.appSetting().options_for_require_customer
              switch options_for_require_customer {
              case .REQUIRE:
                  self.do_select_customer(completePay: true)
//                  messages.showAlert(validationSelectCustomer.1)
//                  self.showRequireCustomerAlert()
                  return
              case .NONE:
                  self.completeOpenPaymentVC()
              case .ASK:
                  self.do_select_customer(completePay: true)
//                  self.showAskCustomerAlert()
                  return
              }
              
          }
          
          self.completeOpenPaymentVC()
        
      }
    func completeOpenPaymentVC(){
//        guard let orderUid = self.orderVc?.order.uid else { return }
        let validationSelectDriver = orderVc?.order.validationSelectDriver() ?? (true,"")
        if !validationSelectDriver.0 {
            messages.showAlert(validationSelectDriver.1)
            return
        }
        //        if payment_Vc == nil
        //        {
        clear_right()

        let storyboard = UIStoryboard(name: "payment", bundle: nil)
      self.payment_Vc = storyboard.instantiateViewController(withIdentifier: "paymentVc") as? paymentVc
        //        }
      self.payment_Vc.parent_vc = self
      self.payment_Vc.clearHome = false
        self.payment_Vc.orderVc!.order =  self.orderVc?.order

//        self.payment_Vc.orderUid =  orderUid
        
        let activeSession = pos_session_class.getActiveSession()
      self.payment_Vc.orderVc!.order.session_id_local = activeSession!.id
        
      if  self.payment_Vc != nil
        {
          self.payment_Vc.viewDidLoad()
        }
      self.payment_Vc.view.frame = right_view.bounds
      right_view.addSubview( self.payment_Vc.view)
//        blurView(view: left_view)
//          self.navigationController?.pushViewController(payment_Vc, animated: true)
    }
    
     func remove_payment()
     {
         self.checkBadge()
        self.payment_Vc?.view.removeFromSuperview()
        self.payment_Vc = nil
        categories_top.btn_home(AnyClass.self)
    }
      
    
}
