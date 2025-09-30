//
//  MWMessageQueue.swift
//  pos
//
//  Created by M-Wageh on 09/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension pos_order_class {
    func get_order_for_message_ip()->[String:Any]{
        if self.orderType == nil
        {
            let defalut_orderType = delivery_type_class.getDefault()
            if defalut_orderType != nil
            {
                self.orderType = defalut_orderType
            }
        }
        var dictionary_message_ip = self.toDictionary()
//        dictionary_message_ip["section_ids"] = self.section_ids.map({$0.toDictionary()})
//        dictionary_message_ip["sub_orders"] = self.sub_orders.map({$0.toDictionary()})
        dictionary_message_ip["pos_order_lines"] = self.pos_order_lines.map({$0.toDictionary(with: true)})
        return dictionary_message_ip
    }
    func getMessagesIPKDS(with ipMessageType: IP_MESSAGE_TYPES,noTries:Int = 0, targetDeviceIp:String? = nil) -> [BodyMessageIpModel] {
        var meesagesIP:[BodyMessageIpModel] = []
//        let orderDic = self.copyOrder(option: getKdsOption()).get_order_for_message_ip()
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
                  let messageIpData = BodyMessageIpModel(data: [orderDic.get_order_for_message_ip()], ipMessageType: ipMessageType, target: .NOTIFIER,targetIp: socketDeviceDB.device_ip ?? "",noTries: noTries)
                  meesagesIP.append(messageIpData)
              }
          }
        return meesagesIP
    }
    func sent_order_via_ip(with ipMessageType: IP_MESSAGE_TYPES,for targets:[DEVICES_TYPES_ENUM]){
        var meesagesIP:[BodyMessageIpModel] = []
        if targets.contains(.KDS) {
            meesagesIP.append(contentsOf: getMessagesIPKDS(with:ipMessageType))
        }
        if targets.contains(.NOTIFIER) {
            meesagesIP.append(contentsOf: getMessagesIPNotifier(with:ipMessageType))
        }
       
        if meesagesIP.count > 0 {
            MWMessageQueueRun.shared.addToQueu(messages:meesagesIP)
            MWMessageQueueRun.shared.startMWMessageQueue()
        }
    }
    func sent_returned_order_via_ip(returnedLines:[pos_order_line_class], for target:DEVICES_TYPES_ENUM, noTries:Int = 0){
        let extra_product_id =  SharedManager.shared.posConfig().extra_product_id
        let filterReturnedLines = returnedLines.filter({$0.product_id != extra_product_id})
        if filterReturnedLines.count <= 0 {
            return
        }
        
//        var orderDic = self.copyOrder(option: getKdsOption()).get_order_for_message_ip()
//        orderDic["pos_order_lines"] = returnedLines.map({$0.toDictionary()})
//        let messageIpData = BodyMessageIpModel(data: [orderDic], ipMessageType: .RETURNED_ORDER, target: target)
        let allTargetDevices = socket_device_class.getDevices(for: [target],with: [.NONE, .ACTIVE]).map({socket_device_class(from: $0)})
        var meesagesIP:[BodyMessageIpModel] = []

        allTargetDevices.forEach { socketDeviceDB in
            if let order = getOrderKDSDevice(for: socketDeviceDB) {
                var orderDic = order.get_order_for_message_ip()
//                var returnOrderDic:[[String:Any]?] = []
//                returnedLines.forEach { lineReturned in
//                    returnOrderDic.append( order.pos_order_lines.first(where: {$0.uid == lineReturned.uid})?.toDictionary(with: true))
//                }
                orderDic["pos_order_lines"] = filterReturnedLines.compactMap({$0}).map({$0.toDictionary(with: true)})
               // var orderDic = order.get_order_for_message_ip()
                //orderDic["pos_order_lines"] = returnedLines.map({$0.toDictionary()})

                let messageIpData = BodyMessageIpModel(data: [orderDic], ipMessageType: .RETURNED_ORDER, target: target,targetIp: socketDeviceDB.device_ip ?? "",noTries:noTries)
                meesagesIP.append(messageIpData)
            }
        }
//        MWMessageQueueRun.shared.addToQueu(message:messageIpData)
        if meesagesIP.count > 0 {
        MWMessageQueueRun.shared.addToQueu(messages:meesagesIP)
        MWMessageQueueRun.shared.startMWMessageQueue()
        }
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
}

class MWMessageQueueRun:NextMessageQueueDelegate {
    static let shared = MWMessageQueueRun()
//    var mwMessagesQueue = DispatchQueue(label: "MWmessagesQueue", qos: .background,attributes: .concurrent)

    private var IPDevices:[IPDeviceModel]{
        get{
            return MWLocalNetworking.sharedInstance.getIpDevices()
        }
    }
    private var currentTargetIpDevices:[IPDeviceModel]?
    private var currentIpDevice:IPDeviceModel?
//    private var currentTarget:DEVICES_TYPES_ENUM?
    private var status:MWQueue_Status = MWQueue_Status.NONE
    private var tasksMessages:[messages_ip_queue_class] = []
    private var queueMessages:[messages_ip_queue_class] = []
//    private var failureMessages:[messages_ip_queue_class] = []
    private var timeOutTask: DispatchWorkItem?
    private lazy var timeOutInseconds = 90
    private var isRemoveTasksRunning:Bool = false
    private var isStarResendFaluireMessages:Bool = false
    private var isStarFillFaluireMessages:Bool = false
     var isStarDeletMessages:Bool = false


    private init(){
        currentTargetIpDevices = []

    }
    func next(with previousSuccess:Bool){
       // DispatchQueue.main.async {
        self.stopTimeOutTask()
//        if !previousSuccess {
//            self.saveFaliureMessages()
//        }
            self.removeCurrentTargetMessages()
            self.clearQueue()
            self.nextTargetDevice()
       // }
    }
    
    func addToQueu(messages:[BodyMessageIpModel]? = nil,ipQueuMessages:[messages_ip_queue_class]? = nil)
    {
//        mwMessagesQueue.async {
        if !isRemoveTasksRunning {
            if let ipQueuMessages = ipQueuMessages {
                tasksMessages.append(contentsOf: ipQueuMessages)
            }
            if let messages = messages {
               let ipQueueMessages = messages_ip_queue_class.save(from: messages)
                self.tasksMessages.append(contentsOf: ipQueueMessages)

            }
        }else{
             DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5)) {
                self.addToQueu(messages:messages)
            }
        }
      //  }
    }
    func forceAddToQueu(messages:[messages_ip_queue_class])
    {
            self.queueMessages.append(contentsOf: messages)
      
    }
    /*
    func adjustFailure(messages:[messages_ip_queue_class]){
        messages.forEach { message in
            self.failureMessages.removeAll(where: {$0.id == message.id})
        }

    }
     */
    func reFillQueueMessages(){
        self.isRemoveTasksRunning = true
        let taskMessagess = messages_ip_queue_class.getAll(for: [QUEUE_IP_TYPES.TASK,QUEUE_IP_TYPES.QUEUE])
        messages_ip_queue_class.setQueueType(with: QUEUE_IP_TYPES.QUEUE, for: taskMessagess.map({$0.id}))
//        self.adjustFailure(messages: taskMessagess)
        self.queueMessages.append(contentsOf:taskMessagess)

//        self.queueMessages.append(contentsOf:tasksMessages)
        self.saveLogMessage(message: " Queue is Fill from tasks ", isFaluire: false)
        self.tasksMessages.removeAll()
        //DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.isRemoveTasksRunning = false
      //  }

    }
    func needDiscovery(){
        self.saveLogMessage(message: " need Discovery devices before  Queue  ", isFaluire: false)

            MWLocalNetworking.sharedInstance.stopAutoJoinOrHost()
            MWLocalNetworking.sharedInstance.startAutoJoinOrHost()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                self.status = .NONE
                self.startMWMessageQueue()
            })

    }
    func startMWMessageQueue(){
        
        self.saveLogMessage(message: " Queue is Starting ", isFaluire: false)
        if self.status == .NEED_DISCOVERY {
            self.needDiscovery()
            return
        }
        if self.status == .START {
            self.saveLogMessage(message: " Queue is running", isFaluire: false)
            return
        }
        
        if self.queueMessages.count == 0 {
            if self.tasksMessages.count == 0 {
            self.saveLogMessage(message: " tasksMessages is Empty", isFaluire: false)
                return
            }else{
                self.reFillQueueMessages()
            }
        }
            self.setNextTargetMessageAndDevices()
      
        if self.status == .NEED_DISCOVERY {
            self.needDiscovery()
            return
        }
        if self.status == .NEED_STOP {
            self.status = .NONE
            self.saveLogMessage(message: "Message Queue NEED_STOP ", isFaluire: false)
            self.nextTargetDevice()
            return
        }
        if (self.currentIpDevice == nil) {
            if self.IPDevices.count <= 0 {
                self.saveLogMessage(message: "Unable to send message as IPDevices is Empty [Imposible] review ips", isFaluire: true)
//                self.saveFaliureMessages()
                self.status = .NEED_DISCOVERY
                self.clearQueue()
                messages_ip_queue_class.setQueueType(with: .FALIURE, for: self.queueMessages.map({$0.id}))
                self.queueMessages.removeAll()
               // MWLocalNetworking.sharedInstance.startAutoJoinOrHost()
            }else{
                self.saveLogMessage(message: "Unable to send message as currentIpDevice is NULL", isFaluire: false)
//                self.saveFaliureMessages()
//                if self.queueMessages.count > 0 {
//                    self.queueMessages.removeFirst()
//                }
                self.status = .NEED_DISCOVERY
                self.startMWMessageQueue()
            }
            return
        }
       
        
            self.startCurrentDevice()
    }
    
   
    func getCountMessagesInQueue() -> Int{
        return queueMessages.count
    }
    
    func getCountFailureMessage(complete:@escaping (String)->()){
        MWQueue.shared.mwfillFailureQueueMessages.async {
           let count = messages_ip_queue_class.getCount(for: [.FALIURE])
            if count > 100 {
                complete( "+99")
            }else{
                if count <= 0 {
                    complete("")
                }else{
                complete("\(count)")
                }
            }

        }
    }
    
    private func setNextTargetMessageAndDevices(){
        currentTargetIpDevices?.removeAll()
        let target_messages_ips = self.queueMessages.map({$0.targetIp})
        var ipNotFound:[String] = []
        for targetIp in target_messages_ips {
            let targetDevices = self.IPDevices.filter({($0.socket_device.device_ip ?? "") == targetIp})
            if targetDevices.count > 0 {
                currentTargetIpDevices?.append(contentsOf:targetDevices)
                setNextTagetDevice()
                break
            }else{
                ipNotFound.append(targetIp)
                print("targetIp ==== \(targetIp)")
            }
        }
        if ipNotFound.count > 0 {
            self.status = .NEED_DISCOVERY
            saveFaliureMessages(ipNotFound: ipNotFound)
        }

    }
  private func removeCurrentTargetMessages(){
      if let currentSocketDevice = self.currentIpDevice?.socket_device {
          if let deviceIp = currentSocketDevice.device_ip {
              queueMessages = queueMessages.filter({$0.targetIp != deviceIp})
              currentTargetIpDevices = currentTargetIpDevices?.filter({($0.socket_device.device_ip ?? "") != deviceIp})
          }else  if let target = currentSocketDevice.type {
              queueMessages = queueMessages.filter({$0.target != target})
              currentTargetIpDevices = currentTargetIpDevices?.filter({($0.socket_device.type ??  DEVICES_TYPES_ENUM.KDS) != target})

          }
        }
    }
     func appendToFailureMessages(_ messages:[messages_ip_queue_class]){
         /*
             messages.forEach { ipMessage in
                 failureMessages.removeAll(where: {$0.id == ipMessage.id})
                 ipMessage.noTries += 1
                 failureMessages.append(ipMessage)
             }
         */
         MWQueue.shared.mwfillFailureQueueMessages.async {
         messages_ip_queue_class.setQueueType(with: .FALIURE, for: messages.map({$0.id}))
//         self.failureMessages = self.failureMessages.reversed()
        SharedManager.shared.updateMessagesIpBadge(afterSecand: 1)
     }
    }
    private func saveFaliureMessages(ipNotFound:[String]? = nil){
        if let ipNotFound = ipNotFound {
            var errorMessages:[messages_ip_queue_class] = []
            ipNotFound.forEach { ip in
                errorMessages.append(contentsOf:  queueMessages.filter({$0.targetIp == ip}) )
                queueMessages.removeAll(where: {$0.targetIp == ip})
            }
            appendToFailureMessages(errorMessages)

        }else{
            if let currentSocketDevice = self.currentIpDevice?.socket_device  {
                let coming_message = Set(queueMessages.filter({$0.targetIp == (currentSocketDevice.device_ip ?? "")}))
                appendToFailureMessages(Array(coming_message))
            }else{
                appendToFailureMessages(queueMessages)
            }
        }
        SharedManager.shared.updateMessagesIpBadge(afterSecand: 1)


      }
    private func setNextTagetDevice(){
        self.currentIpDevice = currentTargetIpDevices?.first
        if let currentSocketDevice = self.currentIpDevice?.socket_device,
            (currentTargetIpDevices?.count ?? 0) > 0 {
            let current_message_devie = queueMessages.filter({$0.targetIp == (currentSocketDevice.device_ip ?? "")})
//            current_message_devie.forEach({$0.targetSocketDevice = self.currentIpDevice?.socket_device.device_ip})
            if let currentIpDevice = self.currentIpDevice, current_message_devie.count > 0{
                currentIpDevice.appendMessages( current_message_devie)
            }else{
                self.saveLogMessage(message: "Unable to set Next Target Device as current_message_devie = \(current_message_devie.count) currentSocketDevice =\(currentTargetIpDevices?.count ?? 0)  self.currentIpDevice?.socket_device = \(self.currentIpDevice?.socket_device.device_ip ?? "" )", isFaluire: true)
                self.status = MWQueue_Status.NEED_STOP

            }
        }
        
        
        /*else{
            self.saveLogMessage(message: "set Next Target Device currentSocketDevice =\(currentTargetIpDevices?.count ?? 0)  self.currentIpDevice?.socket_device = \(self.currentIpDevice?.socket_device.device_ip ?? "" )", isFaluire: false)
            self.status = MWQueue_Status.NEED_STOP

        }
        */
         
    }
    private func nextTargetDevice(){
        if (currentTargetIpDevices?.count ?? 0) > 0 {
            currentTargetIpDevices?.removeFirst()
        }
        setNextTagetDevice()
       
        if self.currentIpDevice == nil {           
            removeCurrentTargetMessages()
            startMWMessageQueue()
        }else{
            startCurrentDevice()
        }
    }
    
    private func startCurrentDevice(){
        self.status = MWQueue_Status.START
        if let ipDevice = self.currentIpDevice , ipDevice.isContaineMessage() {
            ipDevice.status = MWQueue_Status.START
            ipDevice.delegate = self
            ipDevice.startSendMessage()
            sartTimeOutTask()
        }else{
            saveLogMessage(message: "Unable to send message as currentIpDevice is empty or notContaine Messages",isFaluire: false)
            self.status = MWQueue_Status.NONE
            nextTargetDevice()
        }
    }
    private func clearQueue(){
        self.status = .NONE
        self.currentIpDevice = nil
    }
    
    private func saveLogMessage(message:String  , isFaluire:Bool ){
        let messages_ip_log = messages_ip_log_class(fromDictionary: [:])
        messages_ip_log.from_ip = MWConstantLocalNetwork.iPAddress
        messages_ip_log.to_ip = self.queueMessages.first?.targetIp ?? ""
        messages_ip_log.body = json(from: self.queueMessages.map({$0.toDictionary().jsonString() ?? ""}))  ?? ""
        messages_ip_log.response = ""
        messages_ip_log.messageIdentifier = self.queueMessages.map({$0.messageIdentifier}).joined(separator: ", ")
        messages_ip_log.isFaluire = isFaluire
        messages_ip_log.addStatus(message)
        messages_ip_log.addStatus(self.getInformationQueue())
        messages_ip_log.save()
    }
    func stopTimeOutTask(){
        self.currentIpDevice?.messages_ip_log?.addStatus("Stop time out task [Message Queue]")
        timeOutTask?.cancel()
        timeOutTask = nil
    }
     func sartTimeOutTask(){
        self.currentIpDevice?.messages_ip_log?.addStatus("Start Time out Task [Message Queue]")
        if timeOutTask == nil {
            initalizeTimeOutTask()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeOutInseconds), execute: timeOutTask!)
    }
    
    private func initalizeTimeOutTask(){
        timeOutTask = DispatchWorkItem {
            self.stopTimeOutTask()
            MWLocalNetworking.sharedInstance.forceTimeOutDisConnect()
            }
    }
    
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func getInformationQueue()->String {
        var info:[String] = []
        //tasksMessages
        info.append("============= [tasksMessages] ==============")
        info.append("tasksMessages[count]:\(tasksMessages.count)")
        info.append("tasksMessages[targetIp]:\(tasksMessages.map({$0.targetIp}))")
        info.append("tasksMessages[status]:\(status)")
        info.append("\r\n")
        
        info.append("============= [queueMessages] ==============")
        info.append("queueMessages[count]:\(queueMessages.count)")
        info.append("queueMessages[targetIp]:\(queueMessages.map({$0.targetIp}))")
        info.append("queueMessages[status]:\(status)")
        info.append("\r\n")
        
        info.append("============= [serviceFound] ==============")
        info.append("serviceFound[count]:\(MWLocalNetworking.sharedInstance.serviceFound.count )")
        info.append("serviceFound[services.name]:\(MWLocalNetworking.sharedInstance.serviceFound.map({$0.name }) )")
        info.append("\r\n")

        info.append("============= [IPDevices] ==============")
        info.append("IPDevices[count]:\(IPDevices.count )")
        info.append("IPDevices[services.name]:\(IPDevices.map({$0.service.name }) )")
        info.append("IPDevices[socket_devices.device_ip]:\(IPDevices.map({$0.socket_device.device_ip }) )")
        info.append("\r\n")

//        info.append("============= [failureMessages] ==============")
//        info.append("failureMessages[count]:\(failureMessages.count)")
//        info.append("failureMessages[targetIp]:\(failureMessages.map({$0.targetIp}))")
//        info.append("\r\n")

        info.append("============= [currentTargetIpDevices] ==============")
        info.append("currentTargetIpDevices[count]:\(currentTargetIpDevices?.count ?? 0)")
        info.append("currentTargetIpDevices[services.name]:\(currentTargetIpDevices?.map({$0.service.name }) ?? [])")
        info.append("currentTargetIpDevices[socket_devices.device_ip]:\(currentTargetIpDevices?.map({$0.socket_device.device_ip }) ?? [])")
        info.append("\r\n")

        info.append("============= [currentIpDevice] ==============")
        info.append("currentIpDevice[service.name]:\(currentIpDevice?.service.name ?? "")")
        info.append("currentIpDevice[socket_device.device_ip]:\(currentIpDevice?.socket_device.device_ip ?? "")")
        info.append("\r\n")

        info.append("============= Date: [\(Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: true))] ==============")

        return info.joined(separator: "\r\n")
    }
    
    func resendFaluireMessages(){
        MWQueue.shared.mwfillFailureQueueMessages.sync {
        let settingApp = SharedManager.shared.appSetting()
        if settingApp.enable_add_kds_via_wifi {
            if  MWLocalNetworking.sharedInstance.discovery.is_loading {
                return
            }
            if self.isStarFillFaluireMessages {
                return
            }
            if self.isStarDeletMessages {
                return
            }
            
            if self.status.canRetry()
            {
                if self.queueMessages.count == 0 &&
                    self.tasksMessages.count == 0 &&
                    !self.isRemoveTasksRunning &&
                    !self.isStarResendFaluireMessages {
                    MWQueue.shared.mwForceResentQueue.async {
                        let countTries:Int? = settingApp.enable_resent_failure_ip_kds_order_automatic ? nil : 6
                        let noTriesLimit = messages_ip_queue_class.getCount(for: [.FALIURE], noTriesLimit: countTries)
                    if noTriesLimit > 0 {

//                    if self.failureMessages.count > 0 {

                        
                    self.isStarResendFaluireMessages = true
                    var isFindRetryMessage = false
                        var retryMessages: [messages_ip_queue_class] = []
                    let queueMessages = messages_ip_queue_class.getFailureMessages3Times(state: QUEUE_IP_TYPES.QUEUE)
                        if queueMessages.count > 0 {
                            retryMessages.append(contentsOf: queueMessages)
                        }else{
                            retryMessages.append(contentsOf: messages_ip_queue_class.getFailureMessages3Times())
                        }

//                    self.fillFailureQueueMessages()
//                    let retryMessages = self.failureMessages.filter{$0.noTries <= 3 }
                    isFindRetryMessage = retryMessages.count > 0
                    if isFindRetryMessage && self.queueMessages.count <= 0{
//                        self.adjustFailure(messages: retryMessages)
                        self.forceAddToQueu(messages: retryMessages )
                        SharedManager.shared.updateMessagesIpBadge {
                            MWQueue.shared.mwfillFailureQueueMessages.sync {
                                self.startMWMessageQueue()
                            }
                        }
                    }
                    self.isStarResendFaluireMessages = false
                }else{
//                    self.fillFailureQueueMessages()
                }
                }
            }
        }
        }
        }
    }
    /*
    func fillFailureQueueMessages(){
        if self.queueMessages.count == 0 &&
            self.tasksMessages.count == 0 &&
            !self.isStarFillFaluireMessages {
    self.isStarFillFaluireMessages = true
           
    MWQueue.shared.mwfillFailureQueueMessages.async {
       let failureMessagesDB = messages_ip_queue_class.getFailureMessages3Times()
        if failureMessagesDB.count > 0 {
            var failureNeedAppend:[messages_ip_queue_class] = []
            failureMessagesDB.forEach { failureDb in
                self.failureMessages.removeAll(where: {$0.id == failureDb.id})
                failureNeedAppend.append(failureDb)
            }
            if failureNeedAppend.count > 0 {
                self.failureMessages.append(contentsOf: failureNeedAppend )
            }
        }
        self.isStarFillFaluireMessages = false

    }
        }
    }*/
    func updateIpQueueType(){
        MWQueue.shared.mwfillFailureQueueMessages.async {
            messages_ip_queue_class.updateQueueType(for: [.TASK,.QUEUE], with: .FALIURE)
        }
    }
    func removeQueueMessages(){
        self.queueMessages.removeAll()
        self.tasksMessages.removeAll()
    }
    
}
/*
class FaluireIpMessageModel{
    var noTries:Int = 0
    var messageIdentifier:String = ""
    var messagesUIDS:[String] = []
    var messageBody:BodyMessageIpModel?
    
    var ipMessageType: IP_MESSAGE_TYPES?
//    var logID:Int?
    var target:DEVICES_TYPES_ENUM?
    var targetIp:String = ""
    init(from messageBody:BodyMessageIpModel) {
        self.messageBody = messageBody
        self.messageIdentifier = messageBody.getIdentifier()
        self.messagesUIDS = messageBody.getOrderUid() ?? []
        self.ipMessageType = messageBody.ipMessageType
        self.target = messageBody.target
        self.noTries = messageBody.noTries + 1
        self.messageBody?.noTries = (self.messageBody?.noTries ?? -1) + 1
        self.targetIp = messageBody.targetIp
    }
    
    func getMessageIpBody() -> [BodyMessageIpModel]{
        var meesagesIP:[BodyMessageIpModel] = []
        if let ipMessageType = ipMessageType , let target = target, target == DEVICES_TYPES_ENUM.KDS {
            let bodyOrders = messagesUIDS.map({ pos_order_class.get(uid: $0)})
            if ipMessageType != .RETURNED_ORDER , target == .KDS   {
                bodyOrders.forEach { bodyOrder in
                    meesagesIP.append(contentsOf:  bodyOrder?.getMessagesIPKDS(with:ipMessageType,noTries:noTries,targetDeviceIp:  self.targetIp)  ?? [])
                }
            }else{
                if let messageBody = messageBody {
                meesagesIP.append(messageBody)
                }
            }
        }
        return meesagesIP
    }
    
}
*/

enum QUEUE_IP_TYPES:Int{
    case TASK = 1 , QUEUE,FALIURE,DELETED
}

class messages_ip_queue_class: NSObject {
    
    static var  date_formate_database:String = "yyyy-MM-dd HH:mm:ss"
    var id : Int = 0
    var queue_ip_type : QUEUE_IP_TYPES?
    var message:String? //BodyMessageIpModel
    
    var ipMessageType: IP_MESSAGE_TYPES?
    var target:DEVICES_TYPES_ENUM?
    var targetIp:String = ""
    var messageIdentifier:String = ""
    var noTries:Int = -1
    var messagesUIDS:String = ""
//    var logID:Int?

    var dbClass:database_class?
    
    override init() {
        dbClass = database_class(connect: .meesage_ip_log)
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        queue_ip_type = QUEUE_IP_TYPES(rawValue:  dictionary["queue_ip_type"] as? Int ?? 1)
        message = dictionary["message"] as? String ?? ""
        
        if let ipMessageTypeInt = dictionary["ipMessageType"] as? Int  {
            ipMessageType = IP_MESSAGE_TYPES(rawValue:ipMessageTypeInt)
        }
        if let targetString  =  dictionary["target"] as? String {
            target = DEVICES_TYPES_ENUM(rawValue: targetString)
        }
        targetIp = dictionary["targetIp"] as? String ?? ""
        messageIdentifier = dictionary["messageIdentifier"] as? String ?? ""
        noTries = dictionary["noTries"] as? Int ?? -1
        messagesUIDS = dictionary["messagesUIDS"] as? String ?? ""
//        logID = dictionary["logID"] as? String ?? ""

        
        
        dbClass = database_class(table_name: "messages_ip_queue", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .meesage_ip_log)
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        dictionary["queue_ip_type"] = queue_ip_type?.rawValue
        dictionary["message"] = message
        dictionary["ipMessageType"] = ipMessageType?.rawValue ?? ""
        dictionary["target"] = target?.rawValue ?? ""
        dictionary["targetIp"] = targetIp
        dictionary["messageIdentifier"] = messageIdentifier
        dictionary["noTries"] = noTries
        dictionary["messagesUIDS"] = messagesUIDS
//        dictionary["logID"] = logID

        return dictionary
    }
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        self.id =  dbClass!.save()
    }
    
    func getBodyMessage() -> BodyMessageIpModel?{
        var bodyMessage:BodyMessageIpModel? = nil
        if let message = self.message{
        let messageData = Data(message.utf8)
        do {
            bodyMessage = try BodyMessageIpModel(jsonData: messageData)
        } catch let error {
            SharedManager.shared.printLog("ERROR: Couldnt create Message from data \(error.localizedDescription)")
        }
        }
        return bodyMessage
    }
    static func getAll() ->  [[String:Any]] {
        
        let cls = messages_ip_queue_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    static func getFailureMessages3Times(state:QUEUE_IP_TYPES = .FALIURE) ->  [messages_ip_queue_class] {
        let countTries:Int? = SharedManager.shared.appSetting().enable_resent_failure_ip_kds_order_automatic ? nil : 6

        let cls = messages_ip_queue_class(fromDictionary: [:])
        var numTriesQuery = ""
        if let countTries = countTries {
            numTriesQuery = "and noTries <= \(countTries)"
        }
        let sql = "WHERE  queue_ip_type in (\(state.rawValue))  \(numTriesQuery) order by noTries ASC  limit 6"
        let arr  = cls.dbClass!.get_rows(whereSql: sql )
        return arr.map({messages_ip_queue_class(fromDictionary: $0)})
        
    }
    static func setQueueType(with type:QUEUE_IP_TYPES, for ids:[Int] ){
        print("setQueueType == with \(type) ==== for \(ids)")
        MWQueue.shared.mwMessageSocketQueue.async {
            var incrementTriesQuery = ""
        if type == .FALIURE {
            incrementTriesQuery = " , noTries = noTries + 1  "
        }
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: " UPDATE messages_ip_queue SET queue_ip_type = \(type.rawValue)  \(incrementTriesQuery) WHERE id in ( \(ids.map({"\($0)"}).joined(separator: ", ")) ) ")
        }

    }
    static func setQueueType(with type:QUEUE_IP_TYPES ){
        print("setQueueType == with \(type) ====")
        MWQueue.shared.mwMessageSocketQueue.async {
            var incrementTriesQuery = ""
        if type == .FALIURE {
            incrementTriesQuery = " , noTries = noTries + 1  "
        }
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: " UPDATE messages_ip_queue SET queue_ip_type = \(type.rawValue)  \(incrementTriesQuery) ")
        }

    }
    static func updateQueueType(for types:[QUEUE_IP_TYPES], with type:QUEUE_IP_TYPES ){
        MWQueue.shared.mwMessageSocketQueue.async {
            var incrementTriesQuery = ""
        if type == .FALIURE {
            incrementTriesQuery = " , noTries = noTries + 1  "
        }
            let exsitTypes = "(" + types.map({"\($0.rawValue)"}).joined(separator: ",") + ")"
            let existTypeIds = "SELECT id from messages_ip_queue WHERE queue_ip_type in \(exsitTypes)"
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: " UPDATE messages_ip_queue SET queue_ip_type = \(type.rawValue)  \(incrementTriesQuery) WHERE id in ( \(existTypeIds) ) ")
        }

    }
    static func delete(for ids:[Int])   {
        print("delete == \(ids)")
        MWMessageQueueRun.shared.isStarDeletMessages = true
        MWQueue.shared.mwMessageSocketQueue.async {
            
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: "delete from messages_ip_queue WHERE id in ( \(ids.map({"\($0)"}).joined(separator: ", ")) ) ")
            MWMessageQueueRun.shared.isStarDeletMessages = false

        }
    }
    
    
    
    static func deleteAll()   {
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: "delete from messages_ip_queue")
    }
    
    static func deleteBefore(hour:Int = 9){
        let sql = """
                    DELETE from messages_ip_queue WHERE updated_at <= date('now','-\(hour) hour');
        """
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: sql)

    }
    func get_date_now_formate_datebase() -> String {
        
        return Date().toString(dateFormat: messages_ip_queue_class.date_formate_database, UTC: true)
        
    }

    static func save(from bodyMessages:[BodyMessageIpModel]) -> [messages_ip_queue_class]
    {
        var ipQueueMessages:[messages_ip_queue_class] = []
        bodyMessages.forEach { messageObject in
            var dictionary: [String:Any] = [:]
            dictionary["message"] = messageObject.toDict().jsonString() ?? ""
//            dictionary["queue_ip_type"] = queue_ip_type?.rawValue
//            dictionary["message"] = message
            dictionary["ipMessageType"] = messageObject.ipMessageType.rawValue
            dictionary["target"] = messageObject.target.rawValue
            dictionary["targetIp"] = messageObject.targetIp
            dictionary["messageIdentifier"] = messageObject.getIdentifier()
//            dictionary["noTries"] = messageObject.noTries
            dictionary["messagesUIDS"] =  messageObject.getOrderUid()?.joined(separator: ",") ?? ""

            let ipQueue = messages_ip_queue_class(fromDictionary: dictionary)
            ipQueue.save()
            ipQueueMessages.append(ipQueue)
            print("ipQueue === \(ipQueue.id)")
        }
        return ipQueueMessages
    }
    static func getAll(for queueTypes:[QUEUE_IP_TYPES]) ->  [messages_ip_queue_class] {
        
        let cls = messages_ip_queue_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " WHERE queue_ip_type in (\(queueTypes.map({"\($0.rawValue)"}).joined(separator:", "))) limit 50")
        return arr.map({messages_ip_queue_class(fromDictionary: $0)})
        
    }
    static func getCount(for queueTypes:[QUEUE_IP_TYPES],noTriesLimit:Int? = nil) ->  Int {
        let cls = messages_ip_queue_class(fromDictionary: [:])
        var noTriesQuery = ""
        if let noTriesLimit = noTriesLimit {
            noTriesQuery = " and noTries <= \(noTriesLimit)  "
        }
        let count:[String:Any]  = database_class(connect: .meesage_ip_log).get_row(sql: "select count(*) as cnt from messages_ip_queue  WHERE queue_ip_type in (\(queueTypes.map({"\($0.rawValue)"}).joined(separator:", "))) \(noTriesQuery)") ?? [:]
        return (count["cnt"] as? Int ?? 0)

    }
    
    static func vacuum_database()
    {
        let sql = "vacuum"
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.message_ip_log_db!.inDatabase { (db:FMDatabase) in
            
            let success = db.executeUpdate(sql  , withArgumentsIn: [] )
            
            if !success
            {
                let error = db.lastErrorMessage()
                SharedManager.shared.printLog("database Error : \(error)" )
            }
            
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
    
}


