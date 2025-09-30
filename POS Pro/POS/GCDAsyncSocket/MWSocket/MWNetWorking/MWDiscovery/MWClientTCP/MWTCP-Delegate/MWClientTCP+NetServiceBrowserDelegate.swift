//
//  MWTCP+NetServiceBrowserDelegate.swift
//  pos
//
//  Created by M-Wageh on 16/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
// MARK: -
// MARK: MWTCP+NetServiceBrowserDelegate

extension MWClientTCP: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        addStateToLog("Unable to search as didNotSearch get error \(errorDict)")
        saveMessageLog()
        is_loading = false
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
       
            SharedManager.shared.printLog("NetServiceBrowser did find: [moreComing \(moreComing)] \(service)  service.hostName \( service.hostName ?? "---")  service.name\( service.name)")
            
            SharedManager.shared.printLog("moreComing ==\(moreComing)")
        MWLocalNetworking.sharedInstance.serviceTasks.append(service)
            self.addStateToLog("NetServiceBrowser did find: [moreComing \(moreComing)] \(service)  service.hostName \( service.hostName ?? "---")  service.name\( service.name)")
            if !moreComing{
                self.saveMessageLog()
            }
        self.runAppenServiceFromTasks()
          
            self.is_loading = false

    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        addStateToLog("Unable Search as NetServiceBrowser did stop search")
        saveMessageLog()
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        //TODO: - if waiter add only master pos and for KDS not need
        MWLocalNetworking.sharedInstance.checkAndRemove(service)
//        startDiscovery()
//        service.stop()
        SharedManager.shared.printLog("netServiceBrowser Service: domain\(service.domain) type\(service.type) name\(service.name) port\(service.port)")
        if service.name == MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME {
            MWMasterIP.shared.postMasterIpDeviceOffline()
        }

    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        SharedManager.shared.printLog("netServiceBrowser Service: domain\(domainString)")

    }
    func runAppenServiceFromTasks(){
         var serviceCashing: [NetService] = []
        serviceCashing.append(contentsOf:  MWLocalNetworking.sharedInstance.serviceTasks)
        MWLocalNetworking.sharedInstance.serviceTasks.removeAll()
        MWQueue.shared.mwTCPBrowser.async { 
           

            serviceCashing.forEach { service in
                let serviceName = service.name
                SharedManager.shared.printLog(" serviceName != MWConstantLocalNetwork.posHostServiceName \(serviceName != MWConstantLocalNetwork.posHostServiceName)")
                if serviceName != MWConstantLocalNetwork.posHostServiceName{
                    if !SharedManager.shared.posConfig().isMasterTCP(){
                        if (serviceName).lowercased() == MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME.lowercased() {
                            MWLocalNetworking.sharedInstance.checkAndAdd(service,sendInfo: true)
                            
                        }
                        //            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                       // MWMasterIP.shared.checkMasterStatus()
                        //            })
                    }else{
                        MWLocalNetworking.sharedInstance.checkAndAdd(service,sendInfo: true)
                    }
                }else{
                    //            browser.searchForServices(ofType: MWConstantLocalNetwork.typeLocalNetwork,
                    //                                      inDomain: MWConstantLocalNetwork.domainNetwork)
                    //            self.start()
                }
            }
        }
        
        
    }
}
