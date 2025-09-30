//
//  MWDiscovery.swift
//  kds
//
//  Created by M-Wageh on 07/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import GeideaParsingLib

internal class MWDiscovery: NSObject {
//    private var mwLocalNetworking = DispatchQueue(label: "MWLocalNetworkingQueue", qos: .userInitiated,attributes: .concurrent)
        private var timeOutTask: DispatchWorkItem?

    private lazy var socketQueue: DispatchQueue = {
        DispatchQueue(label: "mw.network.socket.queue",qos: .background,attributes: .concurrent)
    }()
//    var count72003Error = 0

    private var mwSocket: GCDAsyncSocket?
    private var selectIpDevice: IPDeviceModel?
    private var selectService: NetService?
    private var hostSocket: GCDAsyncSocket?

    private let timeOutReadData:Double = -1 //15 // -1
    private let timeOutResolve:Double = -1 // 90 // 30

    private lazy var netServiceBrowser: NetServiceBrowser = {
//        let netServiceBrowser = NetServiceBrowser()
//        netServiceBrowser.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        return  NetServiceBrowser()
    }()
    
    private lazy var netService: NetService? = {
        // Create the listen socket
        let port_ip  = SharedManager.shared.appSetting().port_connection_ip
        mwSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
        do {
            try mwSocket?.accept(onPort: UInt16(port_ip))
        } catch let error {
            addStateToLog("Unable to Start peer btoadcast as ERROR: \(error) ")
            return nil
        }
        let port = mwSocket!.localPort
        return NetService(domain: MWConstantLocalNetwork.domainNetwork,
                          type: MWConstantLocalNetwork.typeLocalNetwork,
                          name: MWConstantLocalNetwork.posHostServiceName ,
                          port: Int32(port))
    }()
    var messages_ip_log:messages_ip_log_class?
    var is_loading:Bool = false
    func start(isHost:Bool?) {
        initializeMessageLog("Start Discovery local network with isHost \(isHost)")
        if let isHost = isHost {
            if isHost{
                startPeerBroadcast()
            }else{
                startDiscovery()
            }
        }else{
            startPeerBroadcast()
            startDiscovery()
        }
    }
    
    private func startPeerBroadcast() {
    
        messages_ip_log?.addStatus("Start peer btoadcast")
        netService?.delegate = self
        netService?.publish()
    }
    func stop(isHost:Bool?) {
        initializeMessageLog("Stop Discovery local network with isHost \(isHost)")
        if let isHost = isHost {
            if isHost{
            stopPeerBroadcast()
            }else{
            stopDiscovery()
            }
        }else{
            stopPeerBroadcast()
            stopDiscovery()
        }
    }
    private func stopPeerBroadcast() {
        messages_ip_log?.addStatus("Stop peer btoadcast")
        netService?.stop()
        netService?.delegate = nil
        netService = nil
    }
    private func stopDiscovery() {
        netServiceBrowser.stop()
        netServiceBrowser.delegate = nil
    }
    
    private func startDiscovery() {
        stopNetServiceBrowser()
        netServiceBrowser.delegate = self
        netServiceBrowser.searchForServices(ofType: MWConstantLocalNetwork.typeLocalNetwork,
                                            inDomain: MWConstantLocalNetwork.domainNetwork)
        is_loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            if self.is_loading {
                self.is_loading = false
            }
        })
    }
    private func stopNetServiceBrowser(){
        netServiceBrowser.stop()
        netServiceBrowser.delegate = nil

    }
    
    
    func serviceSelected(_ ipDevice: IPDeviceModel) {
        self.selectIpDevice = ipDevice
        let service = ipDevice.service
//        let messages = ipDevice.messages
//        ipDevice.setLogWith()
        self.selectService = service
        if  ipDevice.current_message != nil {
            addStateToLog("Start resolve service \(service.hostName ?? "") with name \(service.name) ")

            self.selectService?.delegate = self
            self.selectService?.resolve(withTimeout: timeOutResolve)
    //        self.connect(with: service)
        }else{
            messages_ip_log?.to_ip = service.hostName ?? ""
            addStateToLog("Empty Messages sent to \(service.hostName ?? "") with name \(service.name)")
            saveMessageLog()
            self.selectIpDevice?.nextQueue(previousSuccess: false)
        }
    }
    func addStateToLog(_ state:String){
//        mwLocalNetworking.async {
        if let selectIpDevice = self.selectIpDevice {
            selectIpDevice.setLogWith(state:state)
        }else{
            self.messages_ip_log?.addStatus(state)
        }
//        }
    }
   
    func initializeMessageLog(_ state:String) {
      //  DispatchQueue.main.async {
        self.messages_ip_log = messages_ip_log_class(fromDictionary: [:])
        self.messages_ip_log?.addStatus(state)
            self.messages_ip_log?.from_ip = MWConstantLocalNetwork.posHostServiceName
            self.messages_ip_log?.to_ip = ""
            self.messages_ip_log?.body =  ""
            self.messages_ip_log?.messageIdentifier =  ""
            self.messages_ip_log?.response = ""
   // }
    }
    func saveMessageLog() {
        if self.selectIpDevice == nil{
//            mwLocalNetworking.async {
//            self.messages_ip_log?.isFaluire = true
                self.messages_ip_log?.save()
//            }
        }
    }
   @discardableResult func connect(with service: NetService) -> Bool {
       mwSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
        // Copy Service Addresses
       var isJoined = false
       var startDate = Date()
       var endDate = Date()
       var timeOutValue = Int(endDate.timeIntervalSince(startDate))

        var addresses = service.addresses
//       let connectedAddress = mwSocket?.connectedAddress
       addStateToLog("Start Connecting to host \(service.hostName ?? "") with name \(service.name) and address count \(addresses?.count ?? 0)")

       if (addresses?.count ?? 0)  > 0 {
        if (!(mwSocket?.isConnected ?? false)) {
            // Connect
            while (!isJoined && addresses?.count != nil ) && timeOutValue <= 35 {
//                let address = addresses?[0]
//                if address != nil {
                if (addresses?.count ?? 0) > 0 {
                    if let address = addresses?.remove(at: 0) {
                    if let _ = try? mwSocket?.connect(toAddress: address) {
                        isJoined = true
                        addStateToLog("Socket connected to host \(service.hostName ?? "") with name \(service.name)")
                    } else {
                        addStateToLog("Unable to connect to address host \(service.hostName ?? "") with name \(service.name)")
                    }
                }
                }
                 endDate = Date()
                timeOutValue = Int(endDate.timeIntervalSince(startDate))

            }
        } else {
            addStateToLog("Already connected  to address with count less 0 host \(service.hostName ?? "") with name \(service.name)")
            isJoined = mwSocket?.isConnected ?? false
        }
       }else{
           addStateToLog("Unable to connect  to address with count less 0 host \(service.hostName ?? "") with name \(service.name)")
           isJoined = mwSocket?.isConnected ?? false
       }
//        self.netServiceCompletionBlock("NetService : \(String(describing: service)) connected.")
        return isJoined
    }
}

// MARK: -
// MARK: NetServiceBrowserDelegate

extension MWDiscovery: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        addStateToLog("Unable to search as didNotSearch get error \(errorDict)")
        saveMessageLog()
        is_loading = false
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        SharedManager.shared.printLog("moreComing ==\(moreComing)")
        addStateToLog("NetServiceBrowser did find: [moreComing \(moreComing)] \(service)  service.hostName \( service.hostName)  service.name\( service.name)")
        if !moreComing{
            saveMessageLog()
        }
        MWLocalNetworking.sharedInstance.checkAndAdd(service,sendInfo: true)
        is_loading = false
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        addStateToLog("Unable Search as NetServiceBrowser did stop search")
        saveMessageLog()
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        MWLocalNetworking.sharedInstance.checkAndRemove(service)
//        startDiscovery()
//        service.stop()
        SharedManager.shared.printLog("netServiceBrowser Service: domain\(service.domain) type\(service.type) name\(service.name) port\(service.port)")

    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        SharedManager.shared.printLog("netServiceBrowser Service: domain\(domainString)")

    }
}

// MARK: -
// MARK: GCDAsyncSocketDelegate

extension MWDiscovery: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        addStateToLog("Socket did connect to host \(host) on port \(port)")
        joinConnectToHost(sock)
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        addStateToLog("Socket did accept new socket \(newSocket.connectedHost)")
        mwSocketAccept(newSocket)
        // Wait for a message
        newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        addStateToLog("Socket did read data with tag \(tag)")
        joinReadData(from: sock, data:data)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if let error = err{
            addStateToLog("Unable Socket did disconnect with error \(error.localizedDescription )")
        joinDisConnect(sock,withError:err?.localizedDescription ?? "Empty error")
            saveMessageLog()
        }
        self.disconnectDone()
    }
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        addStateToLog("Socket did write data with tag \(tag)")
        joinWriteData(to: sock)

    }
}

// MARK: -
// MARK: NetServiceDelegate
extension MWDiscovery: NetServiceDelegate {
    // Client
    
    func netServiceWillResolve(_ sender: NetService) {
        SharedManager.shared.printLog("netServiceBrowser Service: domain\(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")
        addStateToLog("netServiceBrowser Service: domain\(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")


    }
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        addStateToLog("Unable resolve NetService did not resolve: with error \(errorDict)")
        if (errorDict["NSNetServicesErrorCode"] as? Int ) ?? 0 == -72003 {
            SharedManager.shared.printLog("========")
            SharedManager.shared.printLog("Unable resolve NetService did not resolve: with error \(errorDict)")
//            count72003Error += 1
//            if count72003Error <= 3 {
//            self.selectService?.resolve(withTimeout: timeOutResolve)
//                return
//            }
        }
        if (errorDict["NSNetServicesErrorCode"] as? Int ) ?? 0 == -72007 {
            //Error TimeOut
          //  MWLocalNetworking.sharedInstance.checkAndRemove(sender)
//            sender.stop()

        }
        saveMessageLog()
        mwSocket?.disconnect()
        setLogIsSucces(false)
        disconnectDone()

    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        addStateToLog("NetService did resolve: \(sender)")
        if connect(with: sender) {
            addStateToLog("Did Connect with Service: domain\(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")
        } else {
            addStateToLog("Unable to Connect with Service: domain\(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")
            setLogIsSucces(false)
            disconnectDone()
        }
        saveMessageLog()
  
    }
    
    // Host
    func netServiceDidPublish(_ sender: NetService) {
        addStateToLog("Bonjour Service Published: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))")
        saveMessageLog()
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        addStateToLog("Unable to publish Bonjour Service domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name))\n\(errorDict)")
        saveMessageLog()
    }
    func netServiceDidStop(_ sender: NetService) {
        SharedManager.shared.printLog("===== [netServiceDidStop] Service: domain === \(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")
        /*
        MWLocalNetworking.sharedInstance.checkAndRemove(sender)
//        sender.stop() // inifinty LOOP
        addStateToLog("Unable resolve NetService Did Stop")
        saveMessageLog()
        mwSocket?.disconnect()
        setLogIsSucces(false)
        disconnectDone()
        startDiscovery()
        */
    }
}

extension MWDiscovery {
    func setLogIsSucces(_ isSuccess:Bool){
        if let selectIpDevice = self.selectIpDevice {
            selectIpDevice.messages_ip_log?.isFaluire = isSuccess
        }else{
            self.messages_ip_log?.isFaluire = isSuccess
        }
    }
    private func getIsSuccess()-> Bool{
        if let selectIpDevice = self.selectIpDevice {
            return selectIpDevice.messages_ip_log?.isFaluire ?? false
        }else{
           return self.messages_ip_log?.isFaluire ?? false
        }
    }
    
    private func disconnectDone(){
        let previousSuccess = self.getIsSuccess()
       
            self.addStateToLog("disconnectDone so start next ip-device in queue")
        
            self.saveMessageLog()
//        isJoined = false
        self.selectService?.delegate = nil
        self.selectService?.stop()
        self.mwSocket?.disconnect()
        self.selectService = nil
        self.mwSocket = nil
        self.selectIpDevice?.nextQueue(previousSuccess:previousSuccess)

//        if let selectIpDevice = self.selectIpDevice , !previousSuccess{
//           // MWLocalNetworking.sharedInstance.removeService(for:selectIpDevice)
//        }
        

        
    }
    private func mwSocketAccept(_ newSocket: GCDAsyncSocket){
//        isJoined = true
        if let mwSocket = mwSocket , let currentMessage = self.selectIpDevice?.current_message?.getBodyMessage(){
            MWDataManger.shared.writeMessages(currentMessage, for: mwSocket)
        }
        hostSocket = newSocket
        newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutReadData, tag:  0)
    }
   private func joinReadData(from sock: GCDAsyncSocket,  data: Data){
       if let respons = MWDataManger.shared.serlizatioinResponse(data: data) as? ResponseMessageIpModel{
           MaintenanceInteractor.shared.updateSequence(with:respons.seq,is_closed: respons.closedByMaster , for: respons.uid)
           addStateToLog("joinReadData respons")
          
           self.selectIpDevice?.setLogWith(response:respons)
           if let device_info_dic = respons.reciever as? [String:Any]{
               let recieveInfo = MessageIpInfoModel(dict:device_info_dic)
               let macAddress = recieveInfo.macAddress
               self.selectIpDevice?.socket_device.updateMacAddress(with:macAddress)

           }

          
           if let nextMessage = self.selectIpDevice?.nextMessage()?.getBodyMessage(),let mwSocket = mwSocket {
               MWDataManger.shared.writeMessages(nextMessage, for: mwSocket)
           }else{
               //if respons.code == .success {
               setLogIsSucces(true)
                sock.disconnect()
                   return
              // }
           }
          
       }else if let body = MWDataManger.shared.serlizatioinResponse(data: data) as? BodyMessageIpModel {
           addStateToLog("joinReadData body")
            let responseModel = ResponseMessageIpModel(message: "", code: .success, target: .KDS,responeNewOrder: nil)
           addStateToLog("joinReadData write responseModel")

           if let mwSocket = mwSocket{
               MWDataManger.shared.writeMessages( responseModel, for: mwSocket)
               setLogIsSucces(true)
           }

           return
       }else{
            let str = String(decoding: data, as: UTF8.self)
           let astr = "Join did read \(str) with host port: \(sock.connectedPort)"
           addStateToLog(astr)
           
       }
       addStateToLog("joinReadData sock.readData")

       sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutReadData, tag: 0)
    }
    
    private func joinWriteData(to sock: GCDAsyncSocket){
        addStateToLog("Write Data to Socket \(sock.connectedHost) \(sock.connectedPort)")
    }

    private func joinConnectToHost(_ newSocket: GCDAsyncSocket){
        if let mwSocket = mwSocket{
//            MWDataManger.shared.writeMWSockectData(with: "hi from pos", for: mwSocket, isHost: false)
            if let message = self.selectIpDevice?.current_message?.getBodyMessage() {
                MWDataManger.shared.writeMessages(message, for: mwSocket)
            }
        }
        mwSocket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag:  0)
    }
    
    private func joinDisConnect(_ sock: GCDAsyncSocket, withError err: String){
        addStateToLog("Unable Socket Did Disconnect with Error \(String(describing: err)) with User Info \(err).")
            sock.disconnect()
//        setLogIsSucces(false)
    }
//    func stopTimeOutTask(){
//        self.addStateToLog("Stop time out task ")
//        timeOutTask?.cancel()
//        timeOutTask = nil
//    }
//    func sartTimeOutTask(){
//        addStateToLog("Start Time out Task ")
//        if timeOutTask == nil {
//            initalizeTimeOutTask()
//        }
//        socketQueue.asyncAfter(deadline: .now() + .seconds(30), execute: timeOutTask!)
//    }
//
//    func initalizeTimeOutTask(){
//        timeOutTask = DispatchWorkItem {
//            self.addStateToLog("Unable Socket Did Disconnect with Error Time out Task")
//            self.hostSocket?.disconnect()
//            self.hostSocket = nil
//            self.disconnectDone(previousSuccess:false)
//            }
//    }
    func forceTimeOutDisConnect(){
        self.addStateToLog("Unable Socket Did Disconnect with Error Time out Task [Force time out]")
        self.hostSocket?.disconnect()
        self.hostSocket = nil
        setLogIsSucces(false)
        if let serviceTimeOut = self.selectService {
//        MWLocalNetworking.sharedInstance.checkAndRemove(serviceTimeOut)
//        startDiscovery()
//        serviceTimeOut.stop()

        }
        self.disconnectDone()
    }
    
}


