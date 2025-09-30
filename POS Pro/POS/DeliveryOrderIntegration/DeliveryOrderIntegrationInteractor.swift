//
//  DeliveryOrderIntegrationInteractor.swift
//  pos
//
//  Created by M-Wageh on 28/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//
import Foundation
class DeliveryOrderIntegrationInteractor{
    static let shared:DeliveryOrderIntegrationInteractor = DeliveryOrderIntegrationInteractor()
    private init(){
        ordersTimeOutTasks = []
        API = SharedManager.shared.conAPI()
    }
    private var ordersTimeOutTasks: [DeliveryOrderWorkItem]?
    private var API:api?
    
    func runTaskForSetTimeOut(){
        let deliveryOrder = self.fetchDeliveryOrder().filter({$0.hasTimeOut()})
        if deliveryOrder.count > 0{
        addTimeOutTasks(for: deliveryOrder)
        }
    }
    func addTimeOutTasks(for orders:[pos_order_integration_class]){
        let needAddOrders = orders.filter { comingOrder in
            return !((ordersTimeOutTasks?.contains(where: {$0.order_integration.order_uid == comingOrder.order_uid})) ?? false)
        }
        let newDeliveryOrderWorkItem = needAddOrders.map({DeliveryOrderWorkItem($0)})
        ordersTimeOutTasks?.append(contentsOf: newDeliveryOrderWorkItem)
        startTask()

    }
    func removeOrderTimeOutTasks(for order:pos_order_integration_class){
        if let index = ordersTimeOutTasks?.firstIndex(where: { $0.order_integration.order_uid == order.order_uid}){
            stopTimeOutTask(at:index)
            if (ordersTimeOutTasks?.count ?? 0) > index {
                stopTimeOutTask(at:index)
                ordersTimeOutTasks?.remove(at: index)
            }
        }
    }
    private func stopTimeOutTask(at index:Int){
        ordersTimeOutTasks?[index].stopTask()
    }
    private func startTask(){
        ordersTimeOutTasks?.forEach { task in
            if !task.isStart {
                task.sartTimeOutTask()
            }
        }
    }
    
    //MARK: - fetchDeliveryOrder with spectic option
    private func fetchDeliveryOrder() -> [pos_order_integration_class]{
        return pos_order_integration_class.getPending()
    }
    func doCancel(for order:pos_order_integration_class){
        order.order_status = .cancelling
        order.save()
        self.removeOrderTimeOutTasks(for: order)
        self.updateStatus(integrateOrder: order, with: .cancelled) { result in
            if result ?? false {
                order.order_status = .cancelled
                order.save()
                if let posOrder = order.pos_order{
                    self.cancellingNotification(for:posOrder)
                }
            }
        }
    }
    func cancellingNotification(for posOrder:pos_order_class){
        SharedManager.shared.initalBannerNotification(title: "Order Cancelled".arabic("تم الغاء الطلب"), message: "Order #\(posOrder.sequence_number) has been cancelled".arabic("تم إلغاء الطلب رقم \(posOrder.sequence_number)"), success: true, icon_name: "icon_error")
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 6)
    }
    
    func doReturn(for order:pos_order_integration_class){
        if let posOrder = order.pos_order, (posOrder.is_closed ) {
            //MARK: - do Return for posOrder
            if let returnOrder = posOrder.getReturnOrderIntegration(){
               let line_discount = posOrder.get_discount_line()
                let delivery_line = posOrder.get_delivery_line()
                //TODO: - get id reson id incase deliverect
                returnOrder.return_reason_id = -1
//                returnOrder.loyalty_earned_point  =  -1  * posOrder.loyalty_earned_point
//                returnOrder.loyalty_earned_amount = -1 *  posOrder.loyalty_earned_amount

                returnOrder.delivery_amount = 0
                returnOrder.delivery_type_id = posOrder.delivery_type_id
                returnOrder.pos_multi_session_write_date = ""
                
                var total_subtotal_incl:Double = 0
                var total_subtotal :Double = 0
                if returnOrder.pos_order_lines.count == 0
                {
                    return
                }
                for item in posOrder.pos_order_lines {
                        item.id = 0
                        let totalQty =  item.last_qty
                        if item.max_qty_app == nil
                        {
                            item.max_qty_app = item.qty
                        }
                        
                        item.max_qty_app =  item.max_qty_app! * -1
                        item.qty =  item.qty * -1
                        item.price_subtotal  =    item.price_subtotal! * -1
                        item.price_subtotal_incl  =    item.price_subtotal_incl! * -1
                        
                        if line_discount?.product_id == item.product_id
                        {
                            item.price_unit  =    item.price_unit! * -1
                        }
                    
                        
                        total_subtotal_incl = total_subtotal_incl + item.price_subtotal_incl!
                        total_subtotal = total_subtotal + item.price_subtotal!
                        
                        item.write_info = true
                        item.printed = .none
                        item.pos_multi_session_write_date = ""
                        item.last_qty = 0
                        
                        if item.selected_products_in_combo.count > 0
                        {
                            for i in 0..<item.selected_products_in_combo.count
                            {
                                let combo_item = item.selected_products_in_combo[i]
                                var unitQty = 1.0
                                if totalQty > 0 {
                                 unitQty = (combo_item.qty / totalQty)
                                }
                                combo_item.qty =  abs( item.qty ) * unitQty  * -1
                                combo_item.id = 0
                                combo_item.price_subtotal  =    combo_item.price_subtotal! * -1
                                combo_item.price_subtotal_incl  =    combo_item.price_subtotal_incl! * -1
                                
                                total_subtotal_incl = total_subtotal_incl + combo_item.price_subtotal_incl!
                                total_subtotal = total_subtotal + combo_item.price_subtotal!

                                
                                combo_item.printed = .none
                                combo_item.pos_multi_session_write_date = ""
                                combo_item.last_qty = 0
                                
                                item.selected_products_in_combo[i] =  combo_item
                                
                            }
                        }
                        
                        
                        returnOrder.pos_order_lines.append(item)
                        
                        
                }
                
                
               
                
                // =========================================
                // Extra fees
                let pos = SharedManager.shared.posConfig()
                if  pos.extra_fees == true
                {
                    let line = pos_order_line_class.get(order_id:  posOrder.id!, product_id: pos.extra_product_id!)
                    if line != nil
                    {
                        var extra_amount = total_subtotal_incl
                        if delivery_line != nil
                        {
                            extra_amount = extra_amount - delivery_line!.price_subtotal_incl!
                        }
                        
                        extra_amount = ((extra_amount * Double( pos.extra_percentage!)) / 100 )
                        
                        line!.id = 0
                         line!.write_info = true
                        line!.printed = .none
                        line!.pos_multi_session_write_date = ""
                        line!.last_qty = 0
                        line!.custom_price =  extra_amount
                        line!.update_values()
                        
                        total_subtotal_incl += line!.price_subtotal_incl!
                        total_subtotal   += line!.price_subtotal!

                        returnOrder.pos_order_lines.append(line!)

                        
                    }
                }
                // =========================================
                
                returnOrder.amount_tax = total_subtotal_incl - total_subtotal
                returnOrder.amount_total = total_subtotal_incl
                returnOrder.amount_paid = total_subtotal_incl
                returnOrder.amount_return = total_subtotal_incl * -1
                posOrder.sent_returned_order_via_ip(returnedLines: returnOrder.pos_order_lines)
                var bankStatement = posOrder.get_bankStatement() ?? []
                
                posOrder.list_account_journal = []
                for cls in  bankStatement
                {
                    let account:account_journal_class = account_journal_class(fromDictionary: [:])
                    account.id = cls.account_Journal_id
                    
                    if bankStatement.count > 1
                    {
                        account.changes =  cls.changes! * -1
                        let tendered:Double = cls.tendered!.toDouble()!  * -1
                        account.tendered = tendered.toIntString()
                        account.due =  cls.due!  * -1
                        account.rest = cls.rest!  * -1
                    }
                    else
                    {
                        let total =   posOrder.amount_total
                        
                        account.tendered =  total.toIntString()
                        account.due =  total
                        account.rest = 0
                        account.changes =  0
                        
                    }
                    
                    posOrder.list_account_journal.append(account)
                    
                    
                }
                posOrder.is_closed = true
                posOrder.is_sync = false
                
                posOrder.save(write_info: true, updated_session_status: .last_update_from_local,re_calc: false )
            }
        }
    }
   
}
extension DeliveryOrderIntegrationInteractor{
    func updateStatus(integrateOrder:pos_order_integration_class? = nil,posOrder:pos_order_class? = nil,with status:orderMenuStatus,completion: @escaping (Bool?) -> Void){
        if status == .accepted || status == .rejected {
            var param:[String:Any] = [:]
            if let integrateOrder = integrateOrder {
                param = ["uid":integrateOrder.order_uid ?? "",
                        "status":"\(status.rawValue)"]
             
            }else{
                if let posOrder = posOrder {
                    param = ["uid":posOrder.uid ?? "",
                            "status":"\(status.rawValue)"]
                }
            }
             
            API?.hitUpdateOrderStatusAPI(param: param, completion: { result in
                if result.success
                {
                SharedManager.shared.printLog("\(result)")
                    self.successUpdateStatus(integrateOrder:integrateOrder,posOrder:posOrder,with:status)
                completion(true)
                }else{
                    if integrateOrder != nil{
                        SharedManager.shared.initalBannerNotification(title: "Error", message: "Error during update status order", success: false, icon_name: "icon_error")
                        SharedManager.shared.banner?.dismissesOnTap = true
                        SharedManager.shared.banner?.show(duration: 3.0)
                        completion(false)
                    }else{
                        self.successUpdateStatus(integrateOrder:integrateOrder,posOrder:posOrder,with:status)
                        completion(nil)
                    }



                }
            })
        }else{
            self.successUpdateStatus(integrateOrder:integrateOrder,posOrder:posOrder,with:status)
            completion(nil)
        }
    }
    private func successUpdateStatus( integrateOrder:pos_order_integration_class? = nil,posOrder:pos_order_class? = nil ,with status:orderMenuStatus){
        if let integrateOrder = integrateOrder {
            self.removeOrderTimeOutTasks(for: integrateOrder)
            pos_order_integration_class.setMenuStatus(with: status, for: integrateOrder.order_uid ?? "")
            pos_order_class.setMenuStatus(with: status, for: integrateOrder.order_uid ?? "")
        }else{
            if let posOrder = posOrder {
                pos_order_class.setMenuStatus(with: status, for: posOrder.uid ?? "")
            }
        }
    }
}
