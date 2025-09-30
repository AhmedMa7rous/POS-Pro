//
//  MWTCP+NetServiceDelegate.swift
//  pos
//
//  Created by M-Wageh on 16/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
// MARK: -
// MARK: MWTCP+NetServiceDelegate
extension MWClientTCP: NetServiceDelegate {
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
            //            if !SharedManager.shared.posConfig().isMasterTCP(){
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                // MWMasterIP.shared.checkMasterStatus()
                
            })
            //            }
            //            count72003Error += 1
            //            if count72003Error <= 3 {
            //            self.selectService?.resolve(withTimeout: timeOutResolve)
            //                return
            //            }
        }
        if (errorDict["NSNetServicesErrorCode"] as? Int ) ?? 0 == -72007 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                //MWMasterIP.shared.checkMasterStatus()
                
            })            //Error TimeOut
            //  MWLocalNetworking.sharedInstance.checkAndRemove(sender)
            //            sender.stop()
            
        }
       // MWQueue.shared.mwTCPRequest.async {
            self.saveMessageLog()
            self.mwSocket?.disconnect()
            self.setLogIsSucces(false)
            self.clientDisconnectDone()
        //}
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        if !MWMessageQueueRun.shared.messageQueueIsRunning() {
            return
        }
        if !(SharedManager.shared.posConfig().isMasterTCP()){
            if sender.name != MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME{
                return
            }
        }
        addStateToLog("NetService did resolve: \(sender)")
        if connect(with: sender) {
            addStateToLog("Did Connect with Service: domain\(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")
        } else {
            addStateToLog("Unable to Connect with Service: domain\(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")
            setLogIsSucces(false)
            clientDisconnectDone()
        }
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
