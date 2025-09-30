//
//  pos_order + sent_ip_message.swift
//  pos
//
//  Created by M-Wageh on 20/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
extension pos_order_class {
    func sent_order_via_ip(with ipMessageType: IP_MESSAGE_TYPES,excludeIp:String? = nil,withoutStart:Bool? = false){
        self.updateSentDate()
        var meesagesIP:[BodyMessageIpModel] = []
        let ipOrderFactor:IPOrderFactor = IPOrderFactor.shared
        ipOrderFactor.config(order: self)
        if SharedManager.shared.mwIPnetwork{
            if SharedManager.shared.appSetting().enable_add_kds_via_wifi {
                meesagesIP.append(contentsOf: ipOrderFactor.getOrderIPKDS(with:ipMessageType,excludeIp:excludeIp))
            }
            if SharedManager.shared.appSetting().enable_add_waiter_via_wifi || SharedManager.shared.posConfig().isWaiterTCP(){
                meesagesIP.append(contentsOf: ipOrderFactor.getOrderIPWaiter(with:ipMessageType,excludeIp:excludeIp))
            }
            meesagesIP.append(contentsOf: ipOrderFactor.getMessagesIPNotifier(with:ipMessageType,excludeIp:excludeIp))

        }
        if meesagesIP.count > 0 {
            if meesagesIP.count > 0 {
                ipOrderFactor.orderIp?.writeDateIP()
            }
            MWMessageQueueRun.shared.addToQueu(messages:meesagesIP)
            if !(withoutStart ?? false) {
                MWMessageQueueRun.shared.startMWMessageQueue()
            }

        }
    }
    func sent_returned_order_via_ip(returnedLines:[pos_order_line_class], noTries:Int = 0,excludeIp:String? = nil){
        let extra_product_id =  SharedManager.shared.posConfig().extra_product_id
        let filterReturnedLines = returnedLines.filter({$0.product_id != extra_product_id})
        if filterReturnedLines.count <= 0 {
            return
        }

        var meesagesIP:[BodyMessageIpModel] = []
        let ipOrderFactor:IPOrderFactor = IPOrderFactor.shared
        ipOrderFactor.config(order: self)
        meesagesIP.append(contentsOf: ipOrderFactor.getReturnOrderIPNotifier(returnedLines:returnedLines,excludeIp:excludeIp))
        if SharedManager.shared.appSetting().enable_add_kds_via_wifi{
            meesagesIP.append(contentsOf: ipOrderFactor.getReturnOrderIPKDS(returnedLines:returnedLines,excludeIp:excludeIp))
        }
        if SharedManager.shared.appSetting().enable_add_waiter_via_wifi{
            meesagesIP.append(contentsOf: ipOrderFactor.getReturnOrderIPWaiter(returnedLines:returnedLines,excludeIp:excludeIp))
        }
        if meesagesIP.count > 0 {
            if meesagesIP.count > 0 {
                ipOrderFactor.orderIp?.writeDateIP()
                self.updateSentDate()
            }
        MWMessageQueueRun.shared.addToQueu(messages:meesagesIP)
        MWMessageQueueRun.shared.startMWMessageQueue()

        }
    }
    func get_order_for_message_ip(forKDS:Bool = false) -> [String:Any]{
        if self.orderType == nil
        {
            let defalut_orderType = delivery_type_class.getDefault()
            if defalut_orderType != nil
            {
                self.orderType = defalut_orderType
            }
        }
        var dictionary_message_ip = self.toDictionary()
        if forKDS {
            return dictionary_message_ip
        }
        var listLines:[pos_order_line_class] = []
        
        fillPosOrderLines(list:&listLines, with :getWaiterOption())
        if let deliveryLine = self.get_delivery_line() {
            listLines.append(deliveryLine)
        }
        if let discountLine = self.get_discount_line() {
            listLines.append(discountLine)
        }
        if let service_charge_line = self.get_service_charge_line(){
            listLines.removeAll(where: {$0.product_id == service_charge_line.product_id })
        }

        
        dictionary_message_ip["pos_order_lines"] = listLines.map({
            if self.is_void {
                $0.is_void = true
            }
           return $0.toDictionary(with: true)
        })
        /*
        dictionary_message_ip["pos_order_lines"] = self.getAllLines(with: true).map({
            if self.is_void {
                $0.is_void = true
            }
           return $0.toDictionary(with: true)
        })
         */
        return dictionary_message_ip
    }
    
    static func selectPendingOrderUID(for session:pos_session_class? = pos_session_class.getActiveSession()) -> [String]{
        var sessionQuery = ""
        
        if let session = session  {
            let sessionID = session.id
            sessionQuery = " and po.session_id_local in (\(sessionID), -\(sessionID)) "
        }
        let sql = """
            select uid from pos_order po where po.is_closed = 0 \(sessionQuery)
        """
        
        let uidDic:[[String:Any]]  = database_class(connect: .database).get_rows(sql: sql) 
         return uidDic.compactMap({$0["uid"] as? String})
    }
    static func selectPendingOrder(for session:pos_session_class? = pos_session_class.getActiveSession(),excludeUid:[String],offsetPending:Int) -> [[String:Any]] {
        let limitPending = IPOrderFactor.shared.limitPendingOrder
        var sessionQuery = ""
        var excludeUidQuery = ""

        if excludeUid.count > 0 {
           //excludeUidQuery = "and po.uid not in ( " + excludeUid.map({"'\($0)'"}).joined(separator: ",") + " ) "
        }
        if let session = session  {
            sessionQuery = " and po.session_id_local = \(session.id) "
        }
        let sentIpDateQuery =  " and ( po.sent_ip_date not in ('null','') or po.recieve_date not in ('null','') ) "
        
        let sql = """
            select * from pos_order po where po.is_closed = 0 and po.is_void = 0  \(sessionQuery) \(excludeUidQuery) \(sentIpDateQuery) limit \(limitPending) offset \(offsetPending)
        """
        if excludeUid.count > 0 {
            excludeUidQuery = "and po.uid in ( " + excludeUid.map({"'\($0)'"}).joined(separator: ",") + " ) "
        }
        let sqlClosedOrder = """
            select * from pos_order po where po.is_closed = 1 and po.is_void = 0   \(sessionQuery) \(excludeUidQuery) \(sentIpDateQuery)
        """
        let sqlVoidOrder = """
            select * from pos_order po where po.is_void = 1 and  po.is_closed = 0 \(sessionQuery) \(excludeUidQuery) \(sentIpDateQuery)
        """
//        SharedManager.shared.printLog("pending sql =\(SharedManager.shared.posConfig().name)=== \(sql)")
        let dbConnect =  database_class(connect: .database)
        let pendingOrders = dbConnect.get_rows(sql: sql)
        let closedOrders = dbConnect.get_rows(sql: sqlClosedOrder)
        let voidOrders = dbConnect.get_rows(sql: sqlVoidOrder)
       return pendingOrders + closedOrders + voidOrders
    }
    func updateSentDate(){
        if let uid = self.uid , !uid.isEmpty {
            
            let dateTimeSent = baseClass.get_date_now_formate_datebase()
            self.sent_ip_date = dateTimeSent
//            self.save(write_info: false,write_date: false)
        let sql = """
            UPDATE pos_order SET sent_ip_date = '\(dateTimeSent)' where uid = '\(uid)'
        """
                let _ = database_class(connect: .database).runSqlStatament(sql: sql)
        }
        
    }
    func updatePreviousTable(with id:Int){
        if let uid = self.uid , !uid.isEmpty {
            
            self.previous_table_id = id
//            self.save(write_info: false,write_date: false)
        let sql = """
            UPDATE pos_order SET previous_table_id = \(id) where uid = '\(uid)'
        """
                let _ = database_class(connect: .database).runSqlStatament(sql: sql)
        }
        
    }
    func getMessagesIPKDS(with ipMessageType: IP_MESSAGE_TYPES,noTries:Int = 0, targetDeviceIp:String? = nil) -> [BodyMessageIpModel] {
        var meesagesIP:[BodyMessageIpModel] = []
        let orderDic = self.copyOrder(option: getKdsOption()).get_order_for_message_ip()
          //TODO: - need to make body for each kds according to order_type and category
        var allTargetDevices = socket_device_class.getDevices(for: [.KDS],with: [.NONE, .ACTIVE]).map({socket_device_class(from: $0)})
        if let targetDeviceIp = targetDeviceIp {
            allTargetDevices = allTargetDevices.filter({$0.device_ip == targetDeviceIp })
        }
          allTargetDevices.forEach { socketDeviceDB in
              if let orderDic = getOrderKDSDevice(for: socketDeviceDB) {
                  let messageIpData = BodyMessageIpModel(data: [orderDic.get_order_for_message_ip()], ipMessageType: ipMessageType, target: .KDS,targetIp: socketDeviceDB.device_ip ?? "",noTries: noTries)
                  meesagesIP.append(messageIpData)
              }
          }
        return meesagesIP
    }
    func getMessagesIPNotifier(with ipMessageType: IP_MESSAGE_TYPES,noTries:Int = 0, targetDeviceIp:String? = nil) -> [BodyMessageIpModel] {
        var meesagesIP:[BodyMessageIpModel] = []
        let orderDic = self.copyOrder(option: getKdsOption()).get_order_for_message_ip()
          //TODO: - need to make body for each kds according to order_type and category
        var allTargetDevices = socket_device_class.getDevices(for: [.NOTIFIER],with: [.NONE, .ACTIVE]).map({socket_device_class(from: $0)})
        if let targetDeviceIp = targetDeviceIp {
            allTargetDevices = allTargetDevices.filter({$0.device_ip == targetDeviceIp })
        }
          allTargetDevices.forEach { socketDeviceDB in
              if let orderDic = getOrderDevice(for: socketDeviceDB) {
                  let messageIpData = BodyMessageIpModel(data: [orderDic.get_order_for_message_ip()], ipMessageType: ipMessageType, target: .KDS,targetIp: socketDeviceDB.device_ip ?? "",noTries: noTries)
                  meesagesIP.append(messageIpData)
              }
          }
        return meesagesIP
    }
    fileprivate func getOrderKDSDevice(for device:socket_device_class)->pos_order_class?
    {
       
        let tempOrder = self.copyOrder(option: getKdsOption())
        let pos = SharedManager.shared.posConfig()
        if let extra_product_id =  pos.extra_product_id,  pos.extra_fees  {
            tempOrder.pos_order_lines.removeAll(where: {$0.product_id == extra_product_id})
        }
//        var lines_in_combo:[pos_order_line_class] = []
//        tempOrder.fore
//        if for_pool != nil
//        {
//            lines_in_combo = pos_order_line_class.get_all_lines_in_combo(order_id: order.id!, product_id: product_id,parent_line_id:line.id )
//        }
        let product_order_type_ids = device.get_order_type_ids()
        if product_order_type_ids.count > 0
        {
            if let type_order = self.orderType {
                if !product_order_type_ids.contains(type_order.id)
                {
                    return nil
                }
            }
        }
        
        let product_categories_ids = device.get_product_categories_ids()
        if product_categories_ids.count > 0
        {
            var products = get_products_to_kdsDevice(categories_ids: product_categories_ids )
            products = products.filter({!$0.isInsuranceLine()})
            if products.count > 0
            {
                tempOrder.pos_order_lines.removeAll()
                tempOrder.pos_order_lines.append(contentsOf: products)
                return tempOrder

            }
        }
        return nil
        
    }
    fileprivate func getOrderDevice(for device:socket_device_class)->pos_order_class?
    {
       
        let tempOrder = self.copyOrder(option: getKdsOption())
        let pos = SharedManager.shared.posConfig()
        if let extra_product_id =  pos.extra_product_id,  pos.extra_fees  {
            tempOrder.pos_order_lines.removeAll(where: {$0.product_id == extra_product_id})
        }
//        var lines_in_combo:[pos_order_line_class] = []
//        tempOrder.fore
//        if for_pool != nil
//        {
//            lines_in_combo = pos_order_line_class.get_all_lines_in_combo(order_id: order.id!, product_id: product_id,parent_line_id:line.id )
//        }
//        let product_order_type_ids = device.get_order_type_ids()
//        if product_order_type_ids.count > 0
//        {
//            if let type_order = self.orderType {
//                if !product_order_type_ids.contains(type_order.id)
//                {
//                    return nil
//                }
//            }
//        }
        
//        let product_categories_ids = device.get_product_categories_ids()
//        if product_categories_ids.count > 0
//        {
            var products = self.pos_order_lines
//            products = products.filter({!$0.isInsuranceLine()})
            if products.count > 0
            {
                tempOrder.pos_order_lines.removeAll()
                tempOrder.pos_order_lines.append(contentsOf: products)
                return tempOrder

            }
       // }
        return nil
        
    }
    fileprivate func get_products_to_kdsDevice(categories_ids:[Int]) -> [pos_order_line_class]
    {
        var list:[pos_order_line_class] = []
        for line in self.pos_order_lines
        {
                if line.product.pos_categ_id != 0
                {
                    let pos_categ_id = line.product.pos_categ_id  ?? 0
                    let filtered = categories_ids.filter { $0 == pos_categ_id }
                    if filtered.count > 0
                    {
                        list.append(line)
                    }
                }
            
            
        }
        return list
    }
    func getKdsOption() -> ordersListOpetions{
        let options = ordersListOpetions()
        options.uid = self.uid
        options.get_lines_void = true
        options.get_lines_void_from_ui = true
//        options.get_lines_promotion = false
        options.parent_product = true
        return options
    }
    func getWaiterOption() -> ordersListOpetions{
        let options = ordersListOpetions()
        options.uid = self.uid
        options.get_lines_void = true
        options.get_lines_void_from_ui = true
//        options.get_lines_promotion = false
        options.parent_product = true
        options.has_extra_product = true

        return options
    }
    func writeDateIP(){
        if let orderID = self.id{
            let writeDate = baseClass.get_date_now_formate_datebase()
            let sql_update_order = """
            update pos_order  set pos_multi_session_write_date = '\(writeDate)' where id = \(orderID)
            """
            let sql_update_lines = """
                    update pos_order_line  set pos_multi_session_write_date  = '\(writeDate)' WHERE  order_id = \(orderID)
                """
            DispatchQueue.global(qos: .background).async {
           let resultPOS =  self.dbClass?.runSqlStatament(sql: sql_update_order)
                SharedManager.shared.printLog(resultPOS)
                let resultLines = self.dbClass?.runSqlStatament(sql: sql_update_lines)
                SharedManager.shared.printLog(resultLines)

            }


        }
    }
}
