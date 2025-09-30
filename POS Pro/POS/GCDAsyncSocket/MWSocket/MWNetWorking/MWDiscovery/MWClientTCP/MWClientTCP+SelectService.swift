//
//  MWTCP+SelectService.swift
//  pos
//
//  Created by M-Wageh on 16/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
//MARK: - MWTCP+SelectService

extension MWClientTCP{
    func serviceSelected(_ ipDevice: IPDeviceModel) {
        self.selectIpDevice = ipDevice
        let service = ipDevice.service
        //        let messages = ipDevice.messages
        //        ipDevice.setLogWith()
        self.selectService = service
        if  ipDevice.current_message != nil {
            addStateToLog("Start resolve service \(service.hostName ?? "") with name \(service.name) ")
            //DispatchQueue.main.async {
            self.selectService?.delegate = self
                self.selectService?.resolve(withTimeout: self.timeOutResolve)
       // }
            //        self.connect(with: service)
        }else{
            messages_ip_log?.to_ip = service.hostName ?? ""
            addStateToLog("Empty Messages sent to \(service.hostName ?? "") with name \(service.name)")
            saveMessageLog()
            self.selectIpDevice?.nextQueue(previousSuccess: false)
        }
    }
    @discardableResult func connect(with service: NetService) -> Bool {
        mwSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
        // Copy Service Addresses
        var isJoined = false
        let startDate = Date()
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
                        if let address = addresses?.first {
//                        if let address = addresses?.remove(at: 0) {
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
