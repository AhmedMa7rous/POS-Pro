//
//  customer.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
typealias customer = create_order
extension customer
{
    func checkCustomerSelected()
    {
        var isEnableSend:Bool? = nil;
        if customerVC?.selectedCustomer != nil
        {
 
            if orderVc?.order.id == nil
            {
                orderVc?.order = pos_order_helper_class.creatNewOrder()
                readOrder()
                
                reloadTableOrders()
            }else{
                self.orderVc?.order.void_delivery_area_line(orderVc?.order.customer)
            }

            
            if  customerVC?.selectedCustomer.property_product_pricelist_id != 0
            {
                let pricelist_id = customerVC?.selectedCustomer.property_product_pricelist_id ?? 0
                let pricelist = product_pricelist_class.get_pricelist(pricelist_id: pricelist_id)
                if pricelist != nil
                {
                    orderVc?.order.priceList = pricelist
                    orderVc?.priceList = pricelist
                    self.orderVc?.order.applyPriceList()
                }
            }
            
            if customerVC?.selectedCustomer.discount_program_id != 0
            {
                let disc = pos_discount_program_class.get(id: (customerVC?.selectedCustomer.discount_program_id)! )
                disconutOption_selected(disocunt: disc)
            }
            else
            {
                let discount_line = orderVc?.order.get_discount_line()
                if discount_line != nil
                {
                    let discount_program_id =  discount_line!.discount_program_id
                    if discount_program_id != 0
                    {
                        let is_restected =  pos_discount_program_class.get(id: discount_program_id)
                        
                        if is_restected.customer_restricted == true
                        {
                            cancel_discount()
                        }
                    }
                }
              
            }
            if let current_customer = orderVc?.order.customer,
               let new_customer = customerVC?.selectedCustomer {
            if current_customer.row_id != new_customer.row_id{
                orderVc?.order.customer = new_customer
                updateStatusMltisession()
                orderVc?.order.save(write_info: false)
                isEnableSend = (orderVc?.order.pos_order_lines.count ?? 0) > 0
            }
            }else{
                if  orderVc?.order.customer  == nil{
                    orderVc?.order.customer = customerVC?.selectedCustomer
                    updateStatusMltisession()
                    orderVc?.order.save(write_info: false)
                    isEnableSend = (orderVc?.order.pos_order_lines.count ?? 0) > 0
                }
                
            }
            if !(orderVc?.order.reward_bonat_code?.isEmpty ?? true){
                if let promoBonat = promo_bonat_class.get(by:orderVc?.order.uid ?? "" ){
                    promoBonat.promo_code = orderVc?.order.reward_bonat_code
                    promoBonat.mobile_number = customerVC?.selectedCustomer.phone
                    
                    promoBonat.update()
                }
                BonatCodeInteractor.shared.checkRewardBonat(order: self.orderVc?.order) { result in
                    if !result{
                        promo_bonat_class.void(for:self.orderVc?.order.uid ?? "" , isVoid: true)
                        self.cancel_discount()
                    }
                    self.reloadTableOrders(re_calc: true,reSave: true)
                    self.orderVc?.selected_section = -1
                   self.orderVc?.tableview.reloadData()

                }
            }
            let isDeliveryType = (orderVc?.order.orderType?.order_type ?? "") == "delivery"
            if isDeliveryType {

            if let pos_delivery_area_id = customerVC?.selectedCustomer.pos_delivery_area_id,
               let delivery_area = pos_delivery_area_class.getBy(id: pos_delivery_area_id){
                previousDeliveryAreaId = pos_delivery_area_id
                self.orderVc?.order.delivery_amount = delivery_area.delivery_amount
                if  let deliveryLine =  self.addDeliveryProductToOrder(delivery_product_id:delivery_area.delivery_product_id,delivery_amount:delivery_area.delivery_amount){
//                    orderVc?.order.pos_order_lines.removeAll(where: {$0.uid == deliveryLine.uid})
//                    orderVc?.order.section_ids.removeAll(where: {$0.uid == deliveryLine.uid})
//                    
//                    orderVc?.order.pos_order_lines.append(deliveryLine)
//                    orderVc?.order.section_ids.append(deliveryLine)
                    orderVc?.order.save(write_info: false,re_calc: true)
                    
                    readOrder()
                }


            } else if let delivery_area = pos_delivery_area_class.getBy(id: previousDeliveryAreaId){
                previousDeliveryAreaId = 0
                self.orderVc?.order.delivery_amount = 0
                if  let deliveryLine =  self.addDeliveryProductToOrder(delivery_product_id:delivery_area.delivery_product_id,delivery_amount:delivery_area.delivery_amount){
                    orderVc?.order.pos_order_lines.removeAll(where: {$0.uid == deliveryLine.uid})
                    orderVc?.order.section_ids.removeAll(where: {$0.uid == deliveryLine.uid})
                    
                    orderVc?.order.save(write_info: false,re_calc: true)
                    
                    readOrder()
                }
                
                
            }
        }
            reloadTableOrders(re_calc: false)
            
            
            //            btnSelectCustomer.setTitle(customerVC.selectedCustomer.name  , for: .normal)
            
            customerVC?.selectedCustomer = nil
            
            
            
        }
        
        
        setTitleInfo()
        setupCustomerLayout()
         set_table_layout()
        if let enable = isEnableSend {
            //enableSendBtn(isEnable:enable)
            if checIfOrderSendToMultisession() && enable {
                self.sendToKitchen(sender: self.newBannerHolderview.btn_send_kitchen)
                newBannerHolderview.setEnableSendKitchen(with: true)
             }
            
        }
        
    }
    func addDeliveryFees(for areaDelivery:res_partner_class?){
        if let pos_delivery_area_id = areaDelivery?.pos_delivery_area_id,
           let delivery_area = pos_delivery_area_class.getBy(id: pos_delivery_area_id){
            self.orderVc?.order.delivery_amount = delivery_area.delivery_amount
            if  let deliveryLine =  self.addDeliveryProductToOrder(delivery_product_id:delivery_area.delivery_product_id,delivery_amount:delivery_area.delivery_amount){
                orderVc?.order.pos_order_lines.removeAll(where: {$0.uid == deliveryLine.uid})
                orderVc?.order.section_ids.removeAll(where: {$0.uid == deliveryLine.uid})
                
                orderVc?.order.pos_order_lines.append(deliveryLine)
                orderVc?.order.section_ids.append(deliveryLine)
                orderVc?.order.save(write_info: false,re_calc: true)
                
            }
            
            
        }
    
    }
    func updateStatusMltisession(){
        if checIfOrderSendToMultisession() {
            if (orderVc?.order.pos_order_lines.count ?? 0) > 0{
                orderVc?.order.pos_order_lines.first?.pos_multi_session_status = .sending_update_to_server
            }
         }

      
    }
    func checIfOrderSendToMultisession() -> Bool{
        if let object =  self.orderVc?.order {
         if (!(object.pos_multi_session_write_date ?? "").isEmpty &&
                 object.is_closed == false )
             || object.create_pos_id != SharedManager.shared.posConfig().id {
            return true

            
         }
         }
        return false
    }
    func enableSendBtn(isEnable:Bool = false){
        DispatchQueue.main.async {
            self.newBannerHolderview.setEnableSendKitchen(with: isEnable)
    }
    }
        
    func setupCustomerLayout()
    {
        if self.orderVc?.order.customer != nil
        {
            //            lblCustmerName.text = orderVc?.order.customer?.name ?? ""
            //            lblCustmoerPhone.text = orderVc?.order.customer?.phone ?? ""
            //
            //            let char = orderVc?.order.customer?.name.prefix(1) ?? ""
            //            lblcustomerFirstChar.text = String(char)
            //
            //            view_addCustomer.isHidden = true
            //            view_editCustomer.isHidden = false
            
            self.btnSelectCustomer.setTitle(self.orderVc?.order.customer?.name, for: .normal)
        }
        else
        {
            //            view_addCustomer.isHidden = false
            //            view_editCustomer.isHidden = true
            self.btnSelectCustomer.setTitle("Add Customer".arabic("إضافة عميل"), for: .normal)
        }
    }
    
    @IBAction func btnSelectCustomer(_ sender: Any) {
//        guard  rules.check_access_rule(rule_key.select_customer) else {
//            return
//        }
        if (self.orderVc?.order.orderType?.default_customer_id ?? 0) != 0 {
            return
        }
        
        if self.orderVc?.order.id == nil
         {
            if SharedManager.shared.appSetting().prevent_new_order_if_empty {
                if !pos_order_class.checkIfSessionHaveEmptyOrder() {
                    addNewOrder{
                        self.do_select_customer()
                    }
                    return
                } else {
                    SharedManager.shared.initalBannerNotification(title:  "Not Allowed".arabic("غير مسموح"), message: "Can't Add new order. current order is empty".arabic("لا يمكنك انشاء طلب جديد والطلب الحالي مازال فارغ"), success: false, icon_name: "icon_error")
                    SharedManager.shared.banner?.dismissesOnTap = true
                    SharedManager.shared.banner?.show(duration: 3)
                    return
                }
            } else {
                addNewOrder{
                    self.do_select_customer()
                }
                return
            }
        }else{
            completeBtnSelectCustomer(sender)
        }
        
      
        
        
    }
    func completeBtnSelectCustomer(_ sender: Any){
        if self.orderVc?.order.customer != nil
        {
            
            let alert = UIAlertController(title: "Customer".arabic("عميل"), message: "", preferredStyle: .actionSheet)
            alert.popoverPresentationController?.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
                alert.popoverPresentationController?.sourceView = sender as? UIView
                alert.popoverPresentationController?.sourceRect =  (sender as AnyObject).bounds
            
            
            alert.addAction(UIAlertAction(title: "Change customer".arabic("تغيير العميل") , style: .default, handler: { (action) in
                
                self.do_select_customer()
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel customer".arabic("الغاء") , style: .default, handler: { (action) in
                
                self.btnCancel_customer(AnyClass.self)
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            
            
            
            
            
            self .present(alert, animated: true, completion: nil)
        }
        else
        {
            self.do_select_customer()
            
        }
    }

    func do_select_customer(completePay:Bool = false)
    {
       
        
//        if orderVc?.order.customer != nil
//        {
//
//            btnCancel_customer(AnyClass.self)
//
//            return
//        }
        
        let storyboard = UIStoryboard(name: "customers", bundle: nil)
        self.customerVC = storyboard.instantiateViewController(withIdentifier: "new_customers_listVC") as? new_customers_listVC
        self.customerVC?.selectedCustomer = nil
//        self.customerVC?.modalPresentationStyle = .fullScreen
//        self.customerVC?.modalPresentationStyle = .overCurrentContext
//        self.customerVC?.modalTransitionStyle = .crossDissolve
        self.customerVC?.completionBlock = { customer in
            self.customerVC?.selectedCustomer = customer
            self.checkCustomerSelected()
            if completePay {
                self.completeOpenPaymentVC()
            }else{
                if self.payment_Vc != nil
                {
                    self.clear_right()
                }
            }
        }
        self.present(self.customerVC!, animated: true, completion: nil)
    }
    
    @IBAction func btnCancel_customer(_ sender: Any) {
        
        let cancelCustomer =  self.orderVc?.order.customer
        
        self.orderVc?.order.partner_id =  0
        self.orderVc?.order.partner_row_id =  0
        
        
       
        if let pricelist_pos = product_pricelist_class.getDefault(), orderVc?.order.priceList == pricelist_pos {
          
        self.orderVc?.order.priceList = pricelist_pos
        self.orderVc?.priceList = pricelist_pos
        self.orderVc?.order.applyPriceList()
        }
        self.orderVc?.order.void_delivery_area_line(cancelCustomer,voidState: nil)
       

        self.orderVc?.order.save(write_info: true,re_calc: true)
        
        self.customerVC?.selectedCustomer = nil
        if !(orderVc?.order.reward_bonat_code?.isEmpty ?? true){
            if let promoBonat = promo_bonat_class.get(by:orderVc?.order.uid ?? "" ){
                promoBonat.promo_code = orderVc?.order.reward_bonat_code
                promoBonat.mobile_number = ""
                promoBonat.is_void = true
                promoBonat.update()
            }
            self.cancel_discount()
        }
        reloadTableOrders(re_calc: true)

        
        setTitleInfo()
        setupCustomerLayout()
         set_table_layout()
            newBannerHolderview.setEnableSendKitchen(with: true)
        if  (self.payment_Vc != nil)  {
            self.clear_right()
        }

    }
}
