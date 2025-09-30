//
//  MWTCP.swift
//  pos
//
//  Created by M-Wageh on 16/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

internal class MWClientTCP: NSObject {
    //    private var mwLocalNetworking = DispatchQueue(label: "MWLocalNetworkingQueue", qos: .userInitiated,attributes: .concurrent)
    private var timeOutTask: DispatchWorkItem?
    
    var socketQueue: DispatchQueue = {
        DispatchQueue(label: "mw.network.client.tcp",qos: .background,attributes: .concurrent)
    }()
    //    var count72003Error = 0
    
    var selectIpDevice: IPDeviceModel?
    var selectService: NetService?
    var hostSocket: GCDAsyncSocket?
    var mwSocket: GCDAsyncSocket?

    let timeOutReadData:Double = -1 //15 // -1
    var timeOutResolve:Double {
        get{
            if SharedManager.shared.posConfig().isWaiterTCP(){
                return 10
            }else{
                return -1
            }
        }
    } //-1 // 90 // 30
    let timeOutStopReadData:Double = 0.005

    private var netServiceBrowser: NetServiceBrowser?
    /*= {
        //        let netServiceBrowser = NetServiceBrowser()
        //        netServiceBrowser.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        return  NetServiceBrowser()
    }()*/

    var messages_ip_log:messages_ip_log_class?
    var is_loading:Bool = false
    
    func start() {
        initializeMessageLog("Start Client local network ")
        netServiceBrowser = NetServiceBrowser()
        startDiscovery()
    }
    
    func stop() {
        initializeMessageLog("Stop Client local network ")
        stopDiscovery()
    }
    func reSearchForServices(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.stop()
            self.start()

        })
          //  self.netServiceBrowser?.searchForServices(ofType: MWConstantLocalNetwork.typeLocalNetwork,
           //                                       inDomain: MWConstantLocalNetwork.domainNetwork)
    }
    
}

extension MWClientTCP{
  
  
    private func stopDiscovery() {
        netServiceBrowser?.delegate = nil
        netServiceBrowser?.stop()
    }
    
    private func startDiscovery() {
        stopNetServiceBrowser()
        netServiceBrowser?.delegate = self
        netServiceBrowser?.searchForServices(ofType: MWConstantLocalNetwork.typeLocalNetwork,
                                            inDomain: MWConstantLocalNetwork.domainNetwork)
        is_loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            if self.is_loading {
                self.is_loading = false
            }
        })
    }
    func reSearch()
    {
        netServiceBrowser?.searchForServices(ofType: MWConstantLocalNetwork.typeLocalNetwork,
                                            inDomain: MWConstantLocalNetwork.domainNetwork)

    }
    private func stopNetServiceBrowser(){
        netServiceBrowser?.stop()
        netServiceBrowser?.delegate = nil
        
    }
}

