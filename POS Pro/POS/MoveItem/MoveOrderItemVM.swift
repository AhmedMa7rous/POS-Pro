//
//  MoveOrderItemVM.swift
//  pos
//
//  Created by M-Wageh on 07/06/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MoveItemModel{
    var movesLine:pos_order_line_class?
    var isSelected:Bool = false
    init(_ moveLine:pos_order_line_class) {
        self.movesLine = moveLine
    }
}
class OrginOrderMoveModel{
    var moveOrder:pos_order_class?
    var movesLines:[MoveItemModel]?
    var isExpanded:Bool = true
    init(_ moveOrder:pos_order_class,_ movesLines:[MoveItemModel]) {
//        moveOrder = pos_order_helper_class.creatNewOrder(isSave: false)
        self.moveOrder = moveOrder
        self.movesLines = movesLines
    }
    func didSelectOrder(_ moveOrder:pos_order_class){
        self.moveOrder = moveOrder
    }
    func appendMoveLine(_ moveLine:[MoveItemModel]){
        movesLines?.append(contentsOf: moveLine)
    }
    func saveMoveOrder(){
        if let moveOrder = self.moveOrder , (movesLines?.count ?? 0) > 0 {
                
//            var totalAmountOrder = moveOrder.amount_total
//            var totalTaxOrder = moveOrder.amount_tax
            var linesIDS:[Int] = []
            let posLines = movesLines?.compactMap({$0.movesLine}) ?? []
            for posLine in posLines{
                if posLine.id != 0{
                    linesIDS.append(posLine.id)
                }
                let addOns = posLine.selected_products_in_combo
                if addOns.count > 0{
                    addOns.forEach { addOnLine in
                        if addOnLine.id != 0{
                            linesIDS.append(addOnLine.id)
                        }

                    }
                }
                
            }
//            var linesUID:[String] = movesLines?.compactMap({$0.movesLine?.uid ?? ""}).filter({!$0.isEmpty}) ?? []
            
          /*
            movesLines?.forEach({ moveLine in
                if let posLine = moveLine.movesLine{
                    linesUID.append(posLine.uid)
//                        let linePriceInc = (posLine.price_subtotal_incl ?? 0)
//                        let linePriceSub = posLine.price_subtotal ?? 0
//                        let lineTax = linePriceInc - linePriceSub
//                        totalAmountOrder += linePriceInc
//                        totalTaxOrder += lineTax
                }

            })*/
            updateOrderId(for:linesIDS)
//            updateAmountAndTax(amount_total:totalAmountOrder,amount_tax:totalTaxOrder)
            
        }
    }
    func updateOrderId(for linesIDS:[Int]){
        if let moveOrder = self.moveOrder,let orderID = moveOrder.id{
            let idS = "(\(linesIDS.map({"\($0)"}).joined(separator: ",")))"
            let sql_move_lines = " select * from pos_order_line where id in \(idS) or parent_line_id in \(idS)"
            if let linesDic = moveOrder.dbClass?.get_rows(sql:sql_move_lines ) {
                let sql = "UPDATE pos_order_line  set \(self.getWriteInfo()), is_void  = 1 , void_status = \(void_status_enum.move_line.rawValue)  WHERE id in \(idS) "
                _ = moveOrder.dbClass?.runSqlStatament(sql: sql)
                var pivotIDS:[Int:Int] = [:]
                let posLines = linesDic.map({pos_order_line_class(fromDictionary: $0)})
                let posLinesAddons = posLines.filter({$0.parent_line_id != 0})
                let posLinesBasic = posLines.filter({$0.parent_line_id == 0})
                posLinesBasic.forEach { newLine in
                    let old_line_id = newLine.id
                    newLine.id = 0
                    newLine.uid = ""
                    newLine.order_id = orderID
                    let newLineID = newLine.save(write_info: true)
                    pivotIDS[old_line_id] = newLineID
                }
                posLinesAddons.forEach { addOn in
                    let old_parent_line_id = addOn.parent_line_id
                    addOn.id = 0
                    addOn.uid = ""
                    addOn.order_id = orderID
                    addOn.parent_line_id =  pivotIDS[old_parent_line_id] ?? 0
                    let _ = addOn.save(write_info: true)
                   
                }
            }
        }
    }
    func updateAmountAndTax(amount_total:Double,amount_tax:Double){
        if let moveOrder = self.moveOrder,let uid = moveOrder.uid{
            let sql = "UPDATE pos_order set amount_total = \(amount_total) and amount_tax = \(amount_tax) WHERE uid = '\(uid)'"
            _ = moveOrder.dbClass?.runSqlStatament(sql: sql)
        }
    }
    func getWriteInfo() -> String{
        let user = SharedManager.shared.activeUser()
        let write_user_id = user.id
        let write_user_name = user.name ?? ""
        
        let pos = SharedManager.shared.posConfig()
        let write_pos_id = pos.id
        let write_pos_name = (pos.name ?? "").replacingOccurrences(of: "'", with: "''")
        let write_pos_code = pos.code
        let write_date = baseClass.get_date_now_formate_datebase()
        
        let sql_write = "write_user_id = \(write_user_id), write_user_name = '\(write_user_name)', write_pos_id = \(write_pos_id), write_pos_name = '\(write_pos_name)', write_pos_code = '\(write_pos_code)' , write_date = '\(write_date)'   "
        
        return sql_write
    }
}
extension pos_order_class {
    
}

class MoveOrderItemVM{
    enum MoveOrderState{
        case loading,saveMovement,openChangeTable,reloadTables
    }
    private var orginOrderMove:OrginOrderMoveModel?
    private var moveOrderList:[OrginOrderMoveModel]?

    var updateStatusClosure: ((MoveOrderState) -> Void)?
    var state: MoveOrderState = .reloadTables {
        didSet {
            self.updateStatusClosure?(state)
        }
    }
    
    init(order:pos_order_class) {
        self.orginOrderMove = OrginOrderMoveModel(order,order.pos_order_lines.map({MoveItemModel($0)}))
        moveOrderList = []
    }
    func getCountOrder()->Int{
        return moveOrderList?.count ?? 0
    }
    func getCountLine(for tag:Int,in section:Int)->Int{
        if tag == 1{
            return moveOrderList?[section].movesLines?.count ?? 0
        }
        return orginOrderMove?.movesLines?.count ?? 0
    }
    func getIsExpanded(for tag:Int,in section:Int)->Bool?{
        if tag == 1{
            return moveOrderList?[section].isExpanded
        }
        return true
    }
    func getLine(at indexPath:IndexPath,for tag:Int) -> MoveItemModel?{
        if tag == 1{
            return moveOrderList?[indexPath.section].movesLines?[indexPath.row]
        }
        return orginOrderMove?.movesLines?[indexPath.row]

    }
    func togleExpanded(_ section:Int){
        moveOrderList?[section].isExpanded = !(moveOrderList?[section].isExpanded ?? true)
        self.state = .reloadTables
    }
    func togleSelected(at indexPath:IndexPath,for tag:Int){
        self.getLine(at: indexPath, for: tag)?.isSelected = !(self.getLine(at: indexPath, for: tag)?.isSelected ?? false)
        self.state = .reloadTables
    }
    func selectAll(tag:Int){
        let isSelect = tag == 0
        self.orginOrderMove?.movesLines?.forEach({ moveItem in
            moveItem.isSelected = isSelect
        })
        self.state = .reloadTables

    }
    func getOrginOrderMoveModel(_ section:Int) -> OrginOrderMoveModel?{
        return moveOrderList?[section]
    }
    func checkValidateMove()->Bool{
        if (self.orginOrderMove?.movesLines?.filter({$0.isSelected}).count ?? 0) <= 0{
            SharedManager.shared.initalBannerNotification(title: "Empty Items".arabic("العناصر فارغه"), message: "You should chose items from order".arabic("يجب اختيار العناصر من طلب"), success: false, icon_name: "icon_error")
            SharedManager.shared.banner?.dismissesOnTap = true
            SharedManager.shared.banner?.show(duration: 3)
            return false
        }

        return true
    }
    func moveSelectedItem(to order:pos_order_class){
        if let selctedMoveItem = self.orginOrderMove?.movesLines?.filter({$0.isSelected}){
            if let indexExsit = self.moveOrderList?.firstIndex(where: {$0.moveOrder?.uid ?? "" == order.uid ?? ""}){
                self.moveOrderList?[indexExsit].appendMoveLine(selctedMoveItem)
                
            }else{
                let moveOrder = OrginOrderMoveModel(order,selctedMoveItem)
                self.moveOrderList?.append(moveOrder)
            }
            selctedMoveItem.forEach { moveItemModel in
                self.orginOrderMove?.movesLines?.removeAll(where: {($0.movesLine?.uid ?? "" ) == (moveItemModel.movesLine?.uid ?? "")})
            }
            
        }
        self.state = .reloadTables
    }
    func saveMoveItems(){
        self.state = .loading
        var orderIDS:[Int] = []
        if (self.moveOrderList?.count ?? 0) > 0 {
            if let orderOriginId = self.orginOrderMove?.moveOrder?.id {
                orderIDS.append( orderOriginId )
            }
            self.moveOrderList?.forEach({ originOrder in
                if let orderMoveId = originOrder.moveOrder?.id {
                    orderIDS.append(orderMoveId)
                }
                originOrder.saveMoveOrder()
            })
            //Re-Calc Order By ID
            let opetions = ordersListOpetions()
            opetions.get_lines_void = true
            opetions.parent_product = true
//            opetions.printed = false
            opetions.get_lines_void_from_ui = true
            orderIDS.forEach { orderID in
                if let orderDB =  pos_order_class.get(order_id: orderID,options_order: opetions){
                    if orderDB.pos_order_lines.compactMap({$0.is_void == false}).count <= 0 {
                        if let serviceLine = orderDB.get_service_charge_line(){
                            serviceLine.is_void = true
                            serviceLine.void_status = .move_line
                            serviceLine.save(write_info: true, updated_session_status: .sending_update_to_server)
                        }
                        if let deliveryLine = orderDB.get_delivery_line(){
                            deliveryLine.is_void = true
                            deliveryLine.void_status = .move_line
                            deliveryLine.save(write_info: true, updated_session_status: .sending_update_to_server)
                        }
                        if let discountLine = orderDB.get_discount_line(){
                            discountLine.is_void = true
                            discountLine.void_status = .move_line
                            discountLine.save(write_info: true, updated_session_status: .sending_update_to_server)
                        }
                        if let extraLine = orderDB.is_have_extra_fees(){
                            extraLine.is_void = true
                            extraLine.void_status = .move_line
                            extraLine.save(write_info: true, updated_session_status: .sending_update_to_server)
                        }
                    }
                    if orderDB.checISSendToMultisession(){
                        orderDB.save(write_info: true,
                                                write_date: false,
                                                updated_session_status: .sending_update_to_server,
                                                kitchenStatus:.send,re_calc: true)
                        sentToIP(currentOrderSaved : orderDB)
                    }else{
                        orderDB.save(write_info: true,write_date: false,re_calc: true)
                    }
                    orderDB.get_products()
                   
                }
            }
            AppDelegate.shared.run_poll_send_local_updates(force: true)
        }
        self.state = .saveMovement

    }
    func sentToIP(currentOrderSaved : pos_order_class?){
        if SharedManager.shared.mwIPnetwork {
            if let currentOrderUID = currentOrderSaved?.uid ,let currentOrderSaved = pos_order_class.get(uid: currentOrderUID ){
                if currentOrderSaved.checISSendToMultisession(){
                    DispatchQueue.main.async {
                        currentOrderSaved.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
                        currentOrderSaved.save_and_send_to_kitchen(with:.MOVE_ORDER, for: [.KDS,.NOTIFIER])
                       
                    }
                    
                }
            }
        }
    }
}
