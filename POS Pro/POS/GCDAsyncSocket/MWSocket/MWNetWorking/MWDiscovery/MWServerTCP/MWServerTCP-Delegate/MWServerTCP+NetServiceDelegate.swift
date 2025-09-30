//
//  MWServerTCP+NetServiceDelegate.swift
//  pos
//
//  Created by M-Wageh on 18/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
// MARK: -
// MARK: MWTCP+NetServiceDelegate
extension MWServerTCP: NetServiceDelegate {
    func netServiceDidPublish(_ sender: NetService) {
        self.isPublished = true
        addStateToLog("Bonjour Service Published: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port))")
        saveMessageLog()
        MWQueue.shared.firebaseQueue.async {
        FireBaseService.defualt.updateInfoTCP("did_publish")
        }
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        if (errorDict["NSNetServicesErrorCode"] as? Int ) ?? 0 == -72001 {
            self.isPublished = true
            addStateToLog("Publish Bonjour Service domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name))\n\(errorDict)")
            saveMessageLog()

        }else{
            self.isPublished = false
            addStateToLog("Unable to publish Bonjour Service domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name))\n\(errorDict)")
            saveMessageLog()
        }
       /*
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            MWLocalNetworking.sharedInstance.stopAutoJoinOrHost()
//            AppDelegate.shared.startSockectIP()
        })
        */
    }
    func netServiceDidStop(_ sender: NetService) {
        self.isPublished = false
        SharedManager.shared.printLog("===== [netServiceDidStop] Service: domain === \(sender.domain) type\(sender.type) name\(sender.name) port\(sender.port)")
     
    }
}
