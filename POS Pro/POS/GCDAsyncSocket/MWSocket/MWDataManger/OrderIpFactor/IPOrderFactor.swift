//
//  IPOrderFactor.swift
//  pos
//
//  Created by M-Wageh on 19/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
import AVFoundation
class IPOrderFactor{
    static let shared = IPOrderFactor()
    var offestPending = 0
     var limitPendingOrder = 199

    var orderIp:pos_order_class?
    private let messageKeys = MWConstantLocalNetwork.MessageKeys.self
    private init(){}
    func config(order:pos_order_class){
        self.orderIp = order
    }
    func increaseOffest(){
        self.offestPending += limitPendingOrder
        SharedManager.shared.printLog("increaseOffest =\(SharedManager.shared.posConfig().name)== \(offestPending) ====")

    }
    func resetOffest(){
        self.offestPending = 0
        SharedManager.shared.printLog("resetOffest ==\(SharedManager.shared.posConfig().name)= \(offestPending) ====")

    }
    func sentDeviceInfo(_ is_open_session:Bool? = nil) -> [BodyMessageIpModel] {
        var meesagesIP:[BodyMessageIpModel] = []
        let device = device_ip_info_class(fromDictionary: [:])
        device.is_online = true
        if let is_open_session = is_open_session {
            device.is_open_session = is_open_session
        }else{
            device.is_open_session = pos_session_class.getActiveSession() != nil
        }
        device.order_sequces = sequence_session_ip.shared.currentSeq
        let dic = device.toDictionary()
        let devicesTypes:[DEVICES_TYPES_ENUM] = SharedManager.shared.posConfig().isMasterTCP() ? [.WAITER,.SUB_CASHER] :[.MASTER]

        let allTargetDevices = socket_device_class.getDevices(for:devicesTypes,with: [.NONE, .ACTIVE]).map({socket_device_class(from: $0)})
        if allTargetDevices.count <= 0 {
            return []
        }
          allTargetDevices.forEach { socketDeviceDB in
              
              let messageIpData = BodyMessageIpModel(data: [[messageKeys.DEVICE_INFO: dic]],
                                                         ipMessageType: .SEND_DEVICE_INFO,
                                                         target: socketDeviceDB.type ?? .MASTER,
                                                         targetIp: socketDeviceDB.device_ip ?? "",noTries: 0)
                  meesagesIP.append(messageIpData)
              }
        return meesagesIP

    }
    func getSequenceResponse(for targetIP:String) -> BodyMessageIpModel? {
        var meesagesIP:BodyMessageIpModel? = nil
         let targetDevice = socket_device_class.getDevice(by: targetIP)
        meesagesIP = BodyMessageIpModel(data: [[messageKeys.REQUEST_SEQ:device_ip_info_class.getCurrentInfo()]],
                                                         ipMessageType: .REQUEST_SEQ,
                                           target: targetDevice?.type ?? .WAITER,
                                               targetIp: targetDevice?.device_ip ?? targetIP,noTries: 0)
        
        return meesagesIP
    }
    
    func getSequenceRequest() -> [BodyMessageIpModel] {
        let devicesTypes:[DEVICES_TYPES_ENUM] = SharedManager.shared.posConfig().isMasterTCP() ? [.WAITER,.SUB_CASHER] :[.MASTER]
        var meesagesIP:[BodyMessageIpModel] = []
        let allTargetDevices = socket_device_class.getDevices(for:devicesTypes,with: [.NONE, .ACTIVE]).map({socket_device_class(from: $0)})
        if allTargetDevices.count <= 0 {
            return []
        }
          allTargetDevices.forEach { socketDeviceDB in
              
              let messageIpData = BodyMessageIpModel(data: [[messageKeys.REQUEST_SEQ:"" ]],
                                                         ipMessageType: .REQUEST_SEQ,
                                                         target: socketDeviceDB.type ?? .MASTER,
                                                         targetIp: socketDeviceDB.device_ip ?? "",noTries: 0)
                  meesagesIP.append(messageIpData)
              }
        return meesagesIP
    }
    /*
    func getDeviceInfoResponse(for targetIP:String) -> BodyMessageIpModel? {
        var meesagesIP:BodyMessageIpModel? = nil
        if let targetDevice = socket_device_class.getDevice(by: targetIP){
               meesagesIP = BodyMessageIpModel(data: [[messageKeys.DEVICE_INFO:device_ip_info_class.getCurrentInfo()]],
                                                         ipMessageType: .DEVICE_INFO,
                                           target: targetDevice.type ?? .WAITER,
                                               targetIp: targetDevice.device_ip ?? "",noTries: 0)
        }
        return meesagesIP
    }
    
    func getDeviceInfoRequest() -> [BodyMessageIpModel] {
        let devicesTypes:[DEVICES_TYPES_ENUM] = SharedManager.shared.posConfig().isMasterTCP() ? [.WAITER,.SUB_CASHER] :[.MASTER]
        var meesagesIP:[BodyMessageIpModel] = []
        let allTargetDevices = socket_device_class.getDevices(for:devicesTypes,with: [.NONE, .ACTIVE]).map({socket_device_class(from: $0)})
        if allTargetDevices.count <= 0 {
            return []
        }
          allTargetDevices.forEach { socketDeviceDB in
              
              let messageIpData = BodyMessageIpModel(data: [[messageKeys.DEVICE_INFO:"" ]],
                                                         ipMessageType: .DEVICE_INFO,
                                                         target: socketDeviceDB.type ?? .MASTER,
                                                         targetIp: socketDeviceDB.device_ip ?? "",noTries: 0)
                  meesagesIP.append(messageIpData)
              }
        return meesagesIP
    }
    */
    
    func getPendingOrders(for targetIP:String,excludUID:[String],offset:Int) -> BodyMessageIpModel? {
        let orderDic:[[String:Any]] = pos_order_class.selectPendingOrder(excludeUid:excludUID, offsetPending: offset).map({pos_order_class(fromDictionary: $0, options_order: getKdsOption()).get_order_for_message_ip()})
        if orderDic.count <= 0 {return nil}
        var meesagesIP:BodyMessageIpModel? = nil
        if let targetDevice = socket_device_class.getDevice(by: targetIP){
            
            meesagesIP = BodyMessageIpModel(data: orderDic,
                                                       ipMessageType: .RE_SEND_PENDING,
                                                   target: targetDevice.type ?? .WAITER,
                                                       targetIp: targetDevice.device_ip ?? "",noTries: 0)
        }
        return meesagesIP
    }
    func getUIDPendingOrders() -> [BodyMessageIpModel] {
        if pos_session_class.getActiveSession() == nil {
            return []
        }
        let devicesTypes:[DEVICES_TYPES_ENUM] = SharedManager.shared.posConfig().isMasterTCP() ? [.WAITER,.SUB_CASHER] :[.MASTER]

        let uidArray:[String] = pos_order_class.selectPendingOrderUID()
        var meesagesIP:[BodyMessageIpModel] = []
        let allTargetDevices = socket_device_class.getDevices(for:devicesTypes,with: [.NONE, .ACTIVE]).map({socket_device_class(from: $0)})
          allTargetDevices.forEach { socketDeviceDB in
              let messageIpData = BodyMessageIpModel(data: [[messageKeys.EXCLUD_UID:uidArray,messageKeys.OFF_SET_PENDING :offestPending]],
                                                         ipMessageType: .PENDING_ORDERS,
                                                     target: socketDeviceDB.type ?? .MASTER,
                                                         targetIp: socketDeviceDB.device_ip ?? "",noTries: 0)
                  meesagesIP.append(messageIpData)
              }
        return meesagesIP
    }
    
    
    func getOrderIPKDS(with ipMessageType: IP_MESSAGE_TYPES,noTries:Int = 0, targetDeviceIp:String? = nil,excludeIp:String? = nil) -> [BodyMessageIpModel] {
        var meesagesIP:[BodyMessageIpModel] = []
          //TODO: - need to make body for each kds according to order_type and category
        var allTargetDevices = socket_device_class.getDevices(for: [.KDS],with: [.NONE, .ACTIVE],excludeIP:excludeIp).map({socket_device_class(from: $0)})
        if let targetDeviceIp = targetDeviceIp {
            allTargetDevices = allTargetDevices.filter({$0.device_ip == targetDeviceIp })
        }
          allTargetDevices.forEach { socketDeviceDB in
              if let orderDic = getOrderKDSDevice(for: socketDeviceDB) {
                  var orderMessage = orderDic.get_order_for_message_ip(forKDS: true)
                  orderMessage["pos_order_lines"] = orderDic.pos_order_lines.map({$0.toDictionary(with: true)})
                  let messageIpData = BodyMessageIpModel(data: [orderMessage],
                                                         ipMessageType: ipMessageType,
                                                         target: .KDS,
                                                         targetIp: socketDeviceDB.device_ip ?? "",noTries: noTries)
                  meesagesIP.append(messageIpData)
              }
          }
        return meesagesIP
    }
    func getMessagesIPNotifier(with ipMessageType: IP_MESSAGE_TYPES,noTries:Int = 0, targetDeviceIp:String? = nil,excludeIp:String? = nil) -> [BodyMessageIpModel] {
        var meesagesIP:[BodyMessageIpModel] = []
//        let orderDic = self.copyOrder(option: getKdsOption()).get_order_for_message_ip()
          //TODO: - need to make body for each kds according to order_type and category
        var allTargetDevices = socket_device_class.getDevices(for: [.NOTIFIER],with: [.NONE, .ACTIVE],excludeIP:excludeIp).map({socket_device_class(from: $0)})
        if let targetDeviceIp = targetDeviceIp {
            allTargetDevices = allTargetDevices.filter({$0.device_ip == targetDeviceIp })
        }
          allTargetDevices.forEach { socketDeviceDB in
              if let orderDic = getOrderDevice(for: socketDeviceDB) {
                  let messageIpData = BodyMessageIpModel(data: [orderDic.get_order_for_message_ip()], ipMessageType: ipMessageType, target: .NOTIFIER,targetIp: socketDeviceDB.device_ip ?? "",noTries: noTries)
                  meesagesIP.append(messageIpData)
              }
          }
        return meesagesIP
    }
    func getOrderIPWaiter(with ipMessageType: IP_MESSAGE_TYPES,noTries:Int = 0, targetDeviceIp:String? = nil,excludeIp:String? = nil) -> [BodyMessageIpModel] {
        var meesagesIP:[BodyMessageIpModel] = []
        
        let deviceTypesTarget:[DEVICES_TYPES_ENUM] = SharedManager.shared.posConfig().isMasterTCP() ?  [.WAITER,.SUB_CASHER] : [.MASTER]
        var allTargetDevices = socket_device_class.getDevices(for: deviceTypesTarget ,with: [.NONE, .ACTIVE],excludeIP: excludeIp).map({socket_device_class(from: $0)})
        if let targetDeviceIp = targetDeviceIp {
            allTargetDevices = allTargetDevices.filter({$0.device_ip == targetDeviceIp })
        }
        if allTargetDevices.count > 0 {
            allTargetDevices.forEach { socketDeviceDB in
                if let orderObject = orderIp?.copyOrder(option: getWaiterOption()){
                    let messageIpData = BodyMessageIpModel(data: [orderObject.get_order_for_message_ip()],
                                                           ipMessageType: ipMessageType,
                                                           target: socketDeviceDB.type ?? .WAITER,
                                                           targetIp: socketDeviceDB.device_ip ?? "",
                                                           noTries: noTries)
                    meesagesIP.append(messageIpData)
                }
                
            }
        }
        return meesagesIP
    }
    func getReturnOrderIPKDS(returnedLines:[pos_order_line_class],noTries:Int = 0,excludeIp:String? = nil) -> [BodyMessageIpModel] {
        let allTargetDevices = socket_device_class.getDevices(for:[.KDS],with: [.NONE, .ACTIVE],excludeIP:excludeIp).map({socket_device_class(from: $0)})
        var meesagesIP:[BodyMessageIpModel] = []

        allTargetDevices.forEach { socketDeviceDB in
            if let order = getOrderKDSDevice(for: socketDeviceDB) {
                var orderDic = order.get_order_for_message_ip()
                orderDic["pos_order_lines"] = returnedLines.compactMap({$0}).map({$0.toDictionary(with: true)})
                let messageIpData = BodyMessageIpModel(data: [orderDic],
                                                       ipMessageType: .RETURNED_ORDER,
                                                       target: socketDeviceDB.type ?? .KDS,
                                                       targetIp: socketDeviceDB.device_ip ?? "",
                                                       noTries:noTries)
                meesagesIP.append(messageIpData)
            }
        }
    return meesagesIP
    }
    func getReturnOrderIPNotifier(returnedLines:[pos_order_line_class],noTries:Int = 0,excludeIp:String? = nil) -> [BodyMessageIpModel] {
        let allTargetDevices = socket_device_class.getDevices(for:[.NOTIFIER],with: [.NONE, .ACTIVE],excludeIP:excludeIp).map({socket_device_class(from: $0)})
        var meesagesIP:[BodyMessageIpModel] = []

        allTargetDevices.forEach { socketDeviceDB in
            if let order = getOrderDevice(for: socketDeviceDB) {
                var orderDic = order.get_order_for_message_ip()
                orderDic["pos_order_lines"] = returnedLines.compactMap({$0}).map({$0.toDictionary(with: true)})
                let messageIpData = BodyMessageIpModel(data: [orderDic],
                                                       ipMessageType: .RETURNED_ORDER,
                                                       target: socketDeviceDB.type ?? .KDS,
                                                       targetIp: socketDeviceDB.device_ip ?? "",
                                                       noTries:noTries)
                meesagesIP.append(messageIpData)
            }
        }
    return meesagesIP
    }
    func getReturnOrderIPWaiter(returnedLines:[pos_order_line_class],noTries:Int = 0,excludeIp:String? = nil) -> [BodyMessageIpModel] {
        let allTargetDevices = socket_device_class.getDevices(for:[.WAITER,.SUB_CASHER],with: [.NONE, .ACTIVE],excludeIP:excludeIp).map({socket_device_class(from: $0)})
        var meesagesIP:[BodyMessageIpModel] = []

        allTargetDevices.forEach { socketDeviceDB in
            if var orderDic = orderIp?.copyOrder(option: getKdsOption()).get_order_for_message_ip() {
                orderDic["pos_order_lines"] = returnedLines.compactMap({$0}).map({$0.toDictionary(with: true)})
                let messageIpData = BodyMessageIpModel(data: [orderDic],
                                                       ipMessageType: .RETURNED_ORDER,
                                                       target: socketDeviceDB.type ?? .KDS,
                                                       targetIp: socketDeviceDB.device_ip ?? "",
                                                       noTries:noTries)
                meesagesIP.append(messageIpData)
            }
            }
    return meesagesIP
    }
    fileprivate func getOrderDevice(for device:socket_device_class)->pos_order_class?
    {
       
        let tempOrder = orderIp?.copyOrder(option: getKdsOption())
        let pos = SharedManager.shared.posConfig()
        if let extra_product_id =  pos.extra_product_id,  pos.extra_fees  {
            tempOrder?.pos_order_lines.removeAll(where: {$0.product_id == extra_product_id})
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
        var products = orderIp?.pos_order_lines ?? []
//            products = products.filter({!$0.isInsuranceLine()})
            if products.count > 0
            {
                tempOrder?.pos_order_lines.removeAll()
                tempOrder?.pos_order_lines.append(contentsOf: products)
                return tempOrder

            }
       // }
        return nil
        
    }
    fileprivate func getOrderKDSDevice(for device:socket_device_class)->pos_order_class?
    {
        guard let tempOrder = orderIp?.copyOrder(option: getKdsOption()) else {return nil}
        let pos = SharedManager.shared.posConfig()
        if let extra_product_id =  pos.extra_product_id,  pos.extra_fees  {
            tempOrder.pos_order_lines.removeAll(where: {$0.product_id == extra_product_id})
        }
        let product_order_type_ids = device.get_order_type_ids()
        if product_order_type_ids.count > 0
        {
            if let type_order = orderIp?.orderType {
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
    fileprivate func get_products_to_kdsDevice(categories_ids:[Int]) -> [pos_order_line_class]
    {
        var list:[pos_order_line_class] = []
        for line in (orderIp?.pos_order_lines ?? [])
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
        options.uid = orderIp?.uid
        options.get_lines_void = true
        options.get_lines_void_from_ui = true
//        options.get_lines_promotion = false
        options.parent_product = true
        return options
    }
    func getWaiterOption() -> ordersListOpetions{
        let options = ordersListOpetions()
        options.uid = orderIp?.uid
        options.get_lines_void = true
//        options.get_lines_void_from_ui = true
//        options.get_lines_promotion = false
        options.parent_product = true
        options.has_extra_product = true
        return options
    }
}

