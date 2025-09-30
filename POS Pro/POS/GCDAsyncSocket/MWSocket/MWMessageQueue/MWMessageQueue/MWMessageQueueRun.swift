//
//  MWMessageQueueRun.swift
//  pos
//
//  Created by M-Wageh on 20/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
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
        if !SharedManager.shared.posConfig().isMasterTCP(){
            timeOutInseconds = 180
        }

    }
    func next(with previousSuccess:Bool){
        self.stopTimeOutTask()
            self.removeCurrentTargetMessages()
            self.clearQueue()
            self.nextTargetDevice()
    }
    
    func addToQueu(messages:[BodyMessageIpModel]? = nil,ipQueuMessages:[messages_ip_queue_class]? = nil)
    {
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
    }
    func checkTypeInQueu(_ typeMessage:IP_MESSAGE_TYPES) -> Bool{
//        if SharedManager.shared.appSetting().enable_sequence_at_master_only{
//            return false
//        }
       let isInTasks = self.tasksMessages.filter({$0.ipMessageType == typeMessage}).count > 0
        let isInQueu = self.queueMessages.filter({$0.ipMessageType == typeMessage}).count > 0
        return isInTasks || isInQueu
    }
    func removeTaskInQueu(_ typeMessage:IP_MESSAGE_TYPES){
        self.tasksMessages.removeAll(where:{$0.ipMessageType == typeMessage})
        self.queueMessages.removeAll(where:{$0.ipMessageType == typeMessage})
    }
    func forceAddToQueu(messages:[messages_ip_queue_class])
    {
            self.queueMessages.append(contentsOf: messages)
      
    }
  
    func reFillQueueMessages(){
        self.isRemoveTasksRunning = true
        let taskMessagess = messages_ip_queue_class.getAll(for: [QUEUE_IP_TYPES.TASK,QUEUE_IP_TYPES.QUEUE])
        messages_ip_queue_class.setQueueType(with: QUEUE_IP_TYPES.QUEUE, for: taskMessagess.map({$0.id}))
        self.queueMessages.append(contentsOf:taskMessagess)

        self.saveLogMessage(message: " Queue is Fill from tasks ", isFaluire: false)
        self.tasksMessages.removeAll()
            self.isRemoveTasksRunning = false

    }
    func needDiscovery(for ip:String){
        if self.status == .BACK_GROUND {
            return
        }
        self.status = .START_DISCOVERY
        self.saveLogMessage(message: " need Discovery devices before  Queue  ", isFaluire: false)
        var failMessaages = self.queueMessages.filter({$0.targetIp == ip})

        IP_MESSAGE_TYPES.appMessages().forEach { appMessageType in
            failMessaages.removeAll(where: {$0.ipMessageType == appMessageType})
        }
        
        self.appendToFailureMessages(failMessaages)
        self.queueMessages.removeAll(where:{$0.targetIp == ip})
        DispatchQueue.main.async(execute: {
            MWLocalNetworking.sharedInstance.mwClientTCP.stop()
            MWLocalNetworking.sharedInstance.mwClientTCP.start()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.setState(with: .NONE)
                self.startMWMessageQueue()
            })
        })
           

    }
    func setState(with comingStatus: MWQueue_Status){
        if self.status == .BACK_GROUND {
            if comingStatus == .FORE_GROUND{
                self.status = comingStatus
            }
        }else{
            self.status = comingStatus
        }
        if status == .FORE_GROUND {
            self.saveLogMessage(message: "App go to foreground  ", isFaluire: false)
        }
        if status == .BACK_GROUND {
            self.saveLogMessage(message: "App go to Background  ", isFaluire: false)
        }
    }
    func startMWMessageQueue(){
        if self.status == .FORE_GROUND {
            self.setState(with: .NONE)
            self.startMWMessageQueue()
            return
        }
        if self.status == .BACK_GROUND {
            return
        }
        MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.updateInfoTCP("start_queue")
        }
        self.saveLogMessage(message: " Queue is Starting ", isFaluire: false)
        if self.status == .NEED_DISCOVERY {
            self.needDiscovery(for: self.queueMessages.first?.targetIp ?? "")
            return
        }
    
        self.saveLogMessage(message: " Queue is Starting ", isFaluire: false)
        if self.status == .START_DISCOVERY {
            self.saveLogMessage(message: " Queue is START_DISCOVERY", isFaluire: false)
            return
        }
        if self.status == .START {
            self.saveLogMessage(message: " Queue is running", isFaluire: false)
            return
        }
        if self.status == .BACK_GROUND {
            return
        }
        if self.queueMessages.count <= 0 {
            if self.tasksMessages.count <= 0 {
            self.saveLogMessage(message: " tasksMessages is Empty", isFaluire: false)
                self.setState(with: .NONE)
                return
            }else{
                self.reFillQueueMessages()
                if self.queueMessages.count <= 0 {
                    self.setState(with:  .NONE)
                    MWQueue.shared.firebaseQueue.async {
                        FireBaseService.defualt.updateInfoTCP("end_queue")
                    }
                    return
                }
            }
        }
        if self.status == .START {
            self.saveLogMessage(message: " Queue is running", isFaluire: false)
            return
        }
        self.setState(with: .START)
        self.setNextTargetMessageAndDevices()
        if self.status == .NEED_DISCOVERY {
            self.needDiscovery(for: self.queueMessages.first?.targetIp ?? "")
            return
        }
        if self.status == .NEED_STOP {
            self.setState(with: .NONE)
            self.saveLogMessage(message: "Message Queue NEED_STOP ", isFaluire: false)
            self.nextTargetDevice()
            return
        }
        if (self.currentIpDevice == nil) {
            if self.status == .BACK_GROUND {
                return
            }
            self.setState(with: .NEED_DISCOVERY)
            if self.IPDevices.count <= 0 {
                self.saveLogMessage(message: "Unable to send message as IPDevices is Empty [Imposible] review ips", isFaluire: true)
                self.clearQueue()
                messages_ip_queue_class.setQueueType(with: .FALIURE, for: self.queueMessages.map({$0.id}))
                self.queueMessages.removeAll()
            }else{
                self.saveLogMessage(message: "Unable to send message as currentIpDevice is NULL", isFaluire: false)
                self.startMWMessageQueue()
            }
            return
        }
        if self.status == .BACK_GROUND {
            return
        }
        
            self.startCurrentDevice()
    }
    
   
    func getCountMessagesInQueue() -> Int{
        return queueMessages.count
    }
    
    func getCountFailureMessage(complete:@escaping (String)->()){
        MWQueue.shared.mwfillFailureQueueMessages.async {
            let count = messages_ip_queue_class.getCount(for: [.FALIURE],ipMessage: IP_MESSAGE_TYPES.workMessages())
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
        if self.status == .BACK_GROUND {
            return
        }
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
//                SharedManager.shared.printLog("targetIp ==== \(targetIp)")
            }
        }
        if ipNotFound.count > 0 {
            if (currentTargetIpDevices?.count ?? 0) <= 0 {
                self.setState(with: .NEED_DISCOVERY)
            }
//            self.status = .NEED_DISCOVERY
            //MWLocalNetworking.sharedInstance.mwClientTCP.reSearchForServices()
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
         MWQueue.shared.mwfillFailureQueueMessages.async {
             let messageDone = messages.filter({($0.ipMessageType?.isAppMessages() ?? false)})
             let messageFailure = messages.filter({!($0.ipMessageType?.isAppMessages() ?? false)})
             let messageDeviceInfo = messages.filter({($0.ipMessageType == .SEND_DEVICE_INFO)})
             let messageRequestSequ = messages.filter({($0.ipMessageType == .REQUEST_SEQ)})
             
             if messageFailure.count > 0 {
                 messages_ip_queue_class.setQueueType(with: .FALIURE, for: messageFailure.map({$0.id}))
             }
             if messageDone.count > 0 {
                 messages_ip_queue_class.delete(for: messageDone.map({$0.id}))
             }
             if messageDeviceInfo.count > 0 {
                 /*
                 messageDeviceInfo.forEach { messageIP in
                     device_ip_info_class.setOffline(for:messageIP.targetIp )
                 }
                 */
                 messages_ip_queue_class.delete(for: messageDeviceInfo.map({$0.id}))
             }
             if messageRequestSequ.count > 0 {
                 messageRequestSequ.forEach { messageIP in
                     device_ip_info_class.setOffline(for:messageIP.targetIp )
                 }
                 messages_ip_queue_class.delete(for: messageRequestSequ.map({$0.id}))
             }
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
        if self.status == .BACK_GROUND {
            return
        }
        self.currentIpDevice = currentTargetIpDevices?.first
        if let currentSocketDevice = self.currentIpDevice?.socket_device,
            (currentTargetIpDevices?.count ?? 0) > 0 {
            let current_message_devie = queueMessages.filter({$0.targetIp == (currentSocketDevice.device_ip ?? "")})
//            self.currentIpDevice?.appendMessages( current_message_devie)
            if let currentIpDevice = self.currentIpDevice, current_message_devie.count > 0{
                currentIpDevice.appendMessages( current_message_devie)
            }else{
                self.saveLogMessage(message: "Unable to set Next Target Device as current_message_devie = \(current_message_devie.count) currentSocketDevice =\(currentTargetIpDevices?.count ?? 0)  self.currentIpDevice?.socket_device = \(self.currentIpDevice?.socket_device.device_ip ?? "" )", isFaluire: true)
                self.setState(with: MWQueue_Status.NEED_STOP)

            }
        }
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
        self.setState(with: MWQueue_Status.START)
        if let ipDevice = self.currentIpDevice , ipDevice.isContaineMessage() {
            ipDevice.status = MWQueue_Status.START
            ipDevice.delegate = self
            ipDevice.startSendMessage()
            sartTimeOutTask()
        }else{
            saveLogMessage(message: "Unable to send message as currentIpDevice is empty or notContaine Messages",isFaluire: false)
            self.setState(with: MWQueue_Status.NONE)
            nextTargetDevice()
        }
    }
    private func clearQueue(){
        self.setState(with: .NONE)
        self.currentIpDevice = nil
    }
    
    private func saveLogMessage(message:String  , isFaluire:Bool ){
        if SharedManager.shared.appSetting().enable_reecod_all_ip_log && isFaluire == false{
            return
        }
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
//            MWLocalNetworking.sharedInstance.forceTimeOutDisConnect()
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
        info.append("IPDevices[socket_devices.device_ip]:\(IPDevices.map({$0.socket_device.device_ip ?? "" }) )")
        info.append("\r\n")

//        info.append("============= [failureMessages] ==============")
//        info.append("failureMessages[count]:\(failureMessages.count)")
//        info.append("failureMessages[targetIp]:\(failureMessages.map({$0.targetIp}))")
//        info.append("\r\n")

        info.append("============= [currentTargetIpDevices] ==============")
        info.append("currentTargetIpDevices[count]:\(currentTargetIpDevices?.count ?? 0)")
        info.append("currentTargetIpDevices[services.name]:\(currentTargetIpDevices?.map({$0.service.name }) ?? [])")
        info.append("currentTargetIpDevices[socket_devices.device_ip]:\(currentTargetIpDevices?.map({$0.socket_device.device_ip ?? "" }) ?? [])")
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

        if SharedManager.shared.mwIPnetwork {
            if  MWLocalNetworking.sharedInstance.mwClientTCP.is_loading {
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
                        let countTries:Int? = settingApp.enable_resent_failure_ip_kds_order_automatic ? settingApp.no_retry_sent_ip : 6
                        let noTriesLimit = messages_ip_queue_class.getCount(for: [.FALIURE], noTriesLimit: countTries)
                        if noTriesLimit > 0 {

//                    if messages_ip_queue_class.getCount(for: [.FALIURE], noTriesLimit: 3) > 0 {
                        
                    self.isStarResendFaluireMessages = true
                    var isFindRetryMessage = false
                        
//                    let retryMessages = messages_ip_queue_class.getFailureMessages3Times()
                            var retryMessages: [messages_ip_queue_class] = []
                        let queueMessages = messages_ip_queue_class.getFailureMessages3Times(state: QUEUE_IP_TYPES.QUEUE)
                            if queueMessages.count > 0 {
                                retryMessages.append(contentsOf: queueMessages)
                            }else{
                                retryMessages.append(contentsOf: messages_ip_queue_class.getFailureMessages3Times())
                            }
                    isFindRetryMessage = retryMessages.count > 0
                    if isFindRetryMessage && self.queueMessages.count <= 0{
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
   
    func updateIpQueueType(){
        MWQueue.shared.mwfillFailureQueueMessages.async {
            messages_ip_queue_class.updateMessageAppQueueType(for: [.TASK,.QUEUE], with: .DELETED)
            messages_ip_queue_class.updateQueueType(for: [.TASK,.QUEUE], with: .FALIURE)
        }
    }
    func removeQueueMessages(){
        self.queueMessages.removeAll()
        self.tasksMessages.removeAll()
    }
    func messageQueueIsRunning() -> Bool{
        return self.status == .START
    }
    
}
