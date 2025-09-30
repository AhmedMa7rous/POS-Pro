//
//  MWServerTCP.swift
//  pos
//
//  Created by M-Wageh on 18/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
internal class MWServerTCP: NSObject {
    var socketQueue: DispatchQueue = {
        DispatchQueue(label: "mw.network.server.tcp",qos: .background,attributes: .concurrent)
    }()
    var mwServerTCPSocket: GCDAsyncSocket?
//    var selectService: NetService?
    
    let timeOutReadData:Double = -1 //15 // -1
    let timeOutResolve:Double = -1 // 90 // 30
    let timeOutStopReadData:Double = 0.005

    private  var netService: NetService?

    var messages_ip_log:messages_ip_log_class?
    var isPublished:Bool = false
    var isStarWorking:Bool = false
    func start() {
        isStarWorking = false
        initializeMessageLog("Start server local network ")
        startPeerBroadcast()
    }
    
    func stop() {
        initializeMessageLog("Stop server local network ")
        stopPeerBroadcast()
    }
    func intilizeService(){
        // Create the listen socket
        var port_host = UInt16(SharedManager.shared.appSetting().port_connection_ip)
        if port_host <= 0 {
            port_host = 9090
        }
        mwServerTCPSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
        do {
            try mwServerTCPSocket?.accept(onPort: 0 )
        } catch let error {
            addStateToLog("Unable to Start peer btoadcast as ERROR: \(error) ")
            netService = nil
        }
        let port = mwServerTCPSocket!.localPort
        netService = NetService(domain: MWConstantLocalNetwork.domainNetwork,
                          type: MWConstantLocalNetwork.typeLocalNetwork,
                          name: MWConstantLocalNetwork.posHostServiceName ,
                          port: Int32(port))

    }
    
}

extension MWServerTCP{
  
    private func startPeerBroadcast() {
        let ipV4 = MWConstantLocalNetwork.iPAddress
        if !ipV4.isEmpty && ipV4.verifyIP() {
        messages_ip_log?.addStatus("Start peer btoadcast")
            if !self.isPublished {
                DispatchQueue.main.async {
                    self.intilizeService()
                    self.netService?.delegate = self
                    self.netService?.publish()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        if !self.isPublished{
                            self.startPeerBroadcast()
                        }else{
                            self.isStarWorking = true
                        }
                    }
                }
            }else{
                isStarWorking = true
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.startPeerBroadcast()
            }
        }
    }

    private func stopPeerBroadcast() {
        messages_ip_log?.addStatus("Stop peer btoadcast")
        MWLocalNetworking.sharedInstance.connectedSockets.forEach { connectSocket in
            connectSocket.disconnect()
        }
        mwServerTCPSocket?.delegate = nil
        mwServerTCPSocket?.disconnect()
        mwServerTCPSocket = GCDAsyncSocket()

        mwServerTCPSocket = nil
        
//        netService?.delegate = nil
//        netService?.stopMonitoring()
        netService?.stop()
//        netService?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        netService = nil
        isPublished = false
    }
   
}
