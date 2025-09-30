//
//  NewSplitOrderVM.swift
//  pos
//
//  Created by M-Wageh on 23/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class NewSplitOrderVM{
    enum OrderStatusEnum:Int{
        case CURRENT,NEW
    }
    enum SplitOrderState{
        case populated, doneSplit,openChangeTable(_ status:OrderStatusEnum)
    }
    var currentOrder:pos_order_class
    var newOrder:pos_order_class
    var state: SplitOrderState = .populated {
        didSet {
            self.updateStatusClosure?(state)
        }
    }
    var updateStatusClosure: ((SplitOrderState) -> Void)?
    
    init(currentOrder:pos_order_class) {
        self.currentOrder = currentOrder
        self.newOrder = pos_order_helper_class.creatNewOrder(isSave: false)
    }
    func getNumerRows(for status:OrderStatusEnum) -> Int{
        switch status {
        case .CURRENT:
            return currentOrder.pos_order_lines.count
        case .NEW:
            return newOrder.pos_order_lines.count
        }
    }
    
    func getProductLine(at index:Int , for status:OrderStatusEnum) -> pos_order_line_class{
        switch status {
        case .CURRENT:
            return currentOrder.pos_order_lines[index]
        case .NEW:
            return newOrder.pos_order_lines[index]
        }
    }
    
    func reloadData(){
        self.state = .populated
    }
    func moveItem(at index:Int,from status:OrderStatusEnum ){
        switch status {
        case .CURRENT:
            handleQtyForMoveItem(from: currentOrder, to: newOrder,at:index ,with:status )
        case .NEW:
            handleQtyForMoveItem(from: newOrder, to: currentOrder,at:index,with:status )
        }
        reloadData()
    }
    func handleQtyForMoveItem(from moveOrder: pos_order_class, to new_order: pos_order_class, at index: Int, with status: OrderStatusEnum) {
        guard moveOrder.pos_order_lines.indices.contains(index) else {
            // Ensure the index is within bounds
            return
        }

        let moveLine = moveOrder.pos_order_lines[index]

        if let existIndex = new_order.pos_order_lines.firstIndex(where: { $0.id == moveLine.id }) {
            // If the line already exists in the destination order, update its quantity
            new_order.pos_order_lines[existIndex].qty += 1
            
            var selecAddOn:[pos_order_line_class] = []
            if moveLine.is_combo_line ?? false {
                let addons = moveLine.selected_products_in_combo
                for addOn in addons {
                    let newAddOn = pos_order_line_class(fromDictionary: addOn.toDictionary())
//                    newAddOn.qty = 1
                    selecAddOn.append(newAddOn)

                }
                new_order.pos_order_lines[existIndex].selected_products_in_combo = selecAddOn
            }
            
        } else {
            // If the line does not exist in the destination order, add it with quantity 1
            let newLine = pos_order_line_class(fromDictionary: moveLine.toDictionary())
            newLine.qty = 1
            var selecAddOn:[pos_order_line_class] = []
            if moveLine.is_combo_line ?? false {
                let addons = moveLine.selected_products_in_combo
                for addOn in addons {
                    let newAddOn = pos_order_line_class(fromDictionary: addOn.toDictionary())
//                    newAddOn.qty = 1
                    selecAddOn.append(newAddOn)

                }
            }
            newLine.selected_products_in_combo = selecAddOn
            new_order.pos_order_lines.append(newLine)
        }

        // Update the original order line in the moveOrder
        moveOrder.pos_order_lines[index].qty -= 1

        // If the quantity becomes zero, remove the line from the original order
        if moveOrder.pos_order_lines[index].qty == 0 {
            moveOrder.pos_order_lines.remove(at: index)
        }
    }
    //changeTable
    func changeTable(for status:OrderStatusEnum ){
        self.state = .openChangeTable(status)
    }
    func didSelectTable(for status:OrderStatusEnum , with table:restaurant_table_class){
        switch status {
        case .NEW:
            newOrder.table_id = table.id
            newOrder.table_name = table.name
            newOrder.floor_name = table.floor_name
        case .CURRENT:
            return
        }
    }
    func getTableName(for status:OrderStatusEnum ) -> String{
        switch status {
        case .CURRENT:
            return ["Current Table".arabic("الطاوله الحاليه"),(currentOrder.table_name ?? "")].filter({!$0.isEmpty}).joined(separator: ":- ")
        case .NEW:
            return ["New Table".arabic("الطاوله الجديده"),(newOrder.table_name ?? "")].filter({!$0.isEmpty}).joined(separator: ":- ")
        }
    }
    func moveAll(from status:OrderStatusEnum){
        switch status {
        case .CURRENT:
            newOrder.pos_order_lines.append(contentsOf: currentOrder.pos_order_lines)
            currentOrder.pos_order_lines.removeAll()
        case .NEW:
            currentOrder.pos_order_lines.append(contentsOf: newOrder.pos_order_lines)
            newOrder.pos_order_lines.removeAll()
        }
        reloadData()
    }
    private func updateCurrentOrder(from splitLine: pos_order_line_class, last_line:pos_order_line_class)-> pos_order_line_class{
        let diff_qty = last_line.qty - splitLine.qty
        if diff_qty == 0
        {
            last_line.void_status = .split_order
            last_line.is_void = true
        }
        last_line.qty = diff_qty
        if last_line.selected_products_in_combo.count > 0 {
            for p in last_line.selected_products_in_combo
            {
                p.qty = p.qty - splitLine.qty
                if p.qty < 0
                {
                    p.qty = 1
                }
                p.update_values()
            }
        }
        last_line.update_values()
        return last_line
    }
    private func updateExtraFeesLine(splitLine: pos_order_line_class){
        let pos = SharedManager.shared.posConfig()
        if let extra_product_id =  pos.extra_product_id,
           pos.extra_fees {
            if splitLine.product.allow_extra_fees ?? false {
                guard let line = pos_order_line_class.get(order_id: splitLine.order_id , product_id: extra_product_id)else{return}
                //                line.custom_price -= splitLine.price_subtotal_incl
                
                
            }
        }
        
    }
    
    
    private func getNewLineOrder(from splitLine: pos_order_line_class, with id:Int) -> pos_order_line_class{
        let new_line = pos_order_line_class(fromDictionary: splitLine.toDictionary())
        new_line.id = 0
        new_line.order_id = id
        new_line.write_info = true
//        new_line.printed = .none
        new_line.printed = splitLine.printed

        new_line.pos_multi_session_write_date = ""
        new_line.last_qty = 0
        new_line.uid =  baseClass.getTimeINMS()

        if splitLine.selected_products_in_combo.count > 0 {
            for p in splitLine.selected_products_in_combo
            {
                let compo_line = pos_order_line_class(fromDictionary: p.toDictionary())
                compo_line.id = 0
                compo_line.order_id = id
                compo_line.parent_line_id = 0
                compo_line.qty = splitLine.qty
                compo_line.uid =  baseClass.getTimeINMS()
                compo_line.update_values()
                new_line.selected_products_in_combo.append(compo_line)
                
            }
        }
        new_line.update_values()
        return new_line
    }
    
    func doSplit(with sequence:Int? = nil){
        if self.newOrder.pos_order_lines.count > 0 {
           
            let order_new = pos_order_helper_class.creatNewOrder()
            if let sequence = sequence{
                order_new.sequence_number = sequence
            }
            order_new.table_id = self.newOrder.table_id
            order_new.table_name = self.newOrder.table_name
            order_new.floor_name = self.newOrder.floor_name
            var currentOrderPassed:pos_order_class? = nil
            if let id = order_new.id{
                self.newOrder.pos_order_lines.forEach { splitLine in
                    if let currentOrderUID = self.currentOrder.uid {
                        if let currentOrderSaved = pos_order_class.get(uid: currentOrderUID){
                            if let index =  currentOrderSaved.pos_order_lines.firstIndex(where: {$0.id == splitLine.id}){
                                var last_line = currentOrderSaved.pos_order_lines[index]
                                last_line = self.updateCurrentOrder(from: splitLine, last_line: last_line)
                                if last_line.is_combo_line ?? false {
                                    
                                }
                                splitLine.printed = last_line.printed
                                currentOrderSaved.pos_order_lines[index] = last_line
                                currentOrderSaved.save(write_info: true, write_date: true, updated_session_status: .last_update_from_local,   re_calc: true)
                                currentOrderPassed = currentOrderSaved
                            }
                        }
                    }
                    order_new.pos_order_lines.append(self.getNewLineOrder(from:splitLine,with: id))
                }
                order_new.save(write_info: true, write_date: true, updated_session_status: .last_update_from_local,re_calc: true )
                self.sentToIP(currentOrderSaved : currentOrderPassed, order_new:order_new)
                self.newOrder = order_new
                self.state = .doneSplit

            }
        }
        
        
    }
    func sentToIP(currentOrderSaved : pos_order_class?, order_new:pos_order_class){
        if SharedManager.shared.mwIPnetwork {
            if let currentOrderUID = self.currentOrder.uid ,let currentOrderSaved = pos_order_class.get(uid: currentOrderUID ){
                if currentOrderSaved.checISSendToMultisession(){
                    DispatchQueue.main.async {
                        currentOrderSaved.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
                        currentOrderSaved.save_and_send_to_kitchen(with:.SPLIT_ORDER, for: [.KDS,.NOTIFIER])
                        DispatchQueue.main.async {
                            order_new.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
                            order_new.save_and_send_to_kitchen(with:.SPLIT_ORDER, for: [.KDS,.NOTIFIER])
                            
                        }
                    }
                    
                }
            }
        }
    }
}

class NewSplitOrderRouter {
    
    weak var viewController: NewSplitOrderVC?
    
    static func createModule(order:pos_order_class) -> NewSplitOrderVC {
        let vc:NewSplitOrderVC = NewSplitOrderVC()
        let newSplitOrderVM = NewSplitOrderVM(currentOrder:order)
        let router = NewSplitOrderRouter()
        router.viewController = vc
        vc.newSplitOrderVM = newSplitOrderVM
        vc.newSplitOrderRouter = router
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
    
    func goBack( completion: (() -> Void)? = nil){
        viewController?.dismiss(animated: true, completion: completion)
    }
    
    
}
