//
//  MultiPeerManager+orders.swift
//  pos
//
//  Created by khaled on 02/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

extension MultiPeerManager{
    
    func sendNewSeqToPeers() {
        if (sequenseNumber == 0)
         {
            return
        }
 
 
        if mcSession.connectedPeers.count > 0 {
            do {
                var jsonData:Data?
                do {
                    var dic:[String:Any] = [:]
                    dic["sequenseNumber"] = sequenseNumber
                    jsonData = try JSONSerialization.data(withJSONObject:dic , options: .prettyPrinted)
                    
                } catch {
                    SharedManager.shared.printLog(error.localizedDescription)
                }
                try mcSession.send(jsonData!, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch let error as NSError {
                SharedManager.shared.printLog(error.debugDescription)
            }
        }
    }
    
}
