//
//  MWLocalNetworking.swift
//  kds
//
//  Created by M-Wageh on 07/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public class MWLocalNetworking {
    public static let sharedInstance = MWLocalNetworking()
//    let discovery = MWDiscovery()
    let mwClientTCP = MWClientTCP()
    let mwServerTCP = MWServerTCP()

    private var hostAfterTask: DispatchWorkItem?
    var activeDevices:[socket_device_class] {
        get{
            return socket_device_class.getActiveNotPrintersDevices()
        }
    }
    private var mwLocalNetworking = DispatchQueue(label: "MWLocalNetworkingQueue", qos: .userInitiated,attributes: .concurrent)
    var serviceTasks:[NetService] = []

    var serviceFound:[NetService] = []
    var connectedSockets: [GCDAsyncSocket] = []
    var isJion:Bool{
        get{
            return !SharedManager.shared.posConfig().isMasterTCP()
        }
    }
//    var IPDevices:[IPDeviceModel] = []

    private init() { }

    public func startAutoJoinOrHost() {
       // mwLocalNetworking.async {
        MockData.appendMockServicesForLocalNetWork()
        self.mwServerTCP.start()
        self.mwClientTCP.start()
        self.doRequest()
        
      //  }
    }
    func doRequest(){
        MWQueue.shared.mwTCPRequest.asyncAfter(deadline:.now() + .milliseconds(800) , execute: {
            MWTCPRequest.shared.requestAll()
        })
    }
    public func stopAutoJoinOrHost() {
       // mwLocalNetworking.async {
        self.mwServerTCP.stop()
            self.mwClientTCP.stop()

      //  }
    }
    func startSession(){
        MWQueue.shared.mwTCPStartSession.async {
            MaintenanceInteractor.shared.clearMessageip()
            if !SharedManager.shared.posConfig().isMasterTCP(){
                let ipV4 = MWConstantLocalNetwork.getIPV4Address()
                if !ipV4.isEmpty && ipV4.verifyIP() {
                    device_ip_info_class.resetDevicesInfo()
                    socket_device_class.saveMasterSockectDevice(status: SharedManager.shared.mwIPnetwork)
                    if  let activeSession = pos_session_class.getActiveSession() {
                        SharedManager.shared.printLog("activeSession === \(activeSession.id)")
                        MWLocalNetworking.sharedInstance.startAutoJoinOrHost()
                        MWMessageQueueRun.shared.updateIpQueueType()
                    }
                }else{
                    self.startSession()
                    return
                }
            }
            sequence_session_ip.shared.resetSequenceSession()
            MWTCPRequest.shared.requestAll(isOpen: true)
        }
    }
    func endSession(){
        if SharedManager.shared.mwIPnetwork{
            MWQueue.shared.mwTCPEndSession.async {
                if SharedManager.shared.posConfig().isMasterTCP(){
                    sequence_session_ip.shared.resetSequenceSession()
                    MWTCPRequest.shared.sentDeviceInfo(false)
                }else{
                    //                MWTCPRequest.shared.requestDeviceInfo()
                    MWTCPRequest.shared.sentDeviceInfo(false)
                    AppDelegate.shared.stopSockectIP()
                }
                
                
            }
        }
    }
}

class MockData{
    static func appendMockServicesForLocalNetWork(){
#if DEBUG
      //  MWLocalNetworking.sharedInstance.serviceFound.append(contentsOf: MockData.mockServicesArray())
#endif

    }
    static func mockServicesArray()->[NetService]{
        let mock_ips = ["192.168.5.15", "192.168.5.40", "192.168.5.40", "192.168.5.4", "192.168.5.19", "192.168.5.16"]
        var mock_service:[NetService] = []
        mock_ips.forEach { mockIp in
            mock_service.append(  NetService(domain: MWConstantLocalNetwork.domainNetwork,
                                           type: MWConstantLocalNetwork.typeLocalNetwork,
                                           name: mockIp ,
                                           port: Int32(2020))
                                  )
        }
        return mock_service
    }
}
