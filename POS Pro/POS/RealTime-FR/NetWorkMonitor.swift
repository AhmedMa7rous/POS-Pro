//
//  NetWorkMonitor.swift
//  pos
//
//  Created by M-Wageh on 29/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import Network

class NetWorkMonitor {
    private let monitor:NWPathMonitor?
    private let queue_network: DispatchQueue
    static let shared:NetWorkMonitor = NetWorkMonitor()
    var netOn: Bool = true

    private init(){
        monitor = NWPathMonitor()
        queue_network = DispatchQueue(label: "NetworkQueue")
        monitor?.start(queue:queue_network )

    }
    func monitorNetwork(){
        monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                //internet is connect
                self.netOn = true
                MWQueue.shared.firebaseQueue.async {
//                DispatchQueue.global(qos: .background).async {
                    FireBaseService.defualt.updatePresenceStatus(.online)
                }
            }else{
                //no internet
                self.netOn = false
                MWQueue.shared.firebaseQueue.async {
//              DispatchQueue.global(qos: .background).async {
                    FireBaseService.defualt.updatePresenceStatus(.offline)
                }

            }
        }
    }
    func startMonitor(){
        monitorNetwork()
    }
    func cancelMonitor(){
        monitor?.cancel()
    }
    
}
