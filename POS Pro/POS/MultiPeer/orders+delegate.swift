//
//  orders+delegate.swift
//  pos
//
//  Created by khaled on 02/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension MultiPeerManager
{

func browserOrder(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
}

 
func browserOrder(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
 }

func sessionOrder(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
   
}

func sessionOrder(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    var isOrder = true

        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
            
            if let dict = dic ,let seq = dict["sequenseNumber"] as? Int {
                if seq > sequenseNumber {
                    sequenseNumber = seq
                }else if seq < sequenseNumber{
                    sendNewSeqToPeers()
                }
                else
                {
                    isOrder = false
                }
            }
            else
            {
                isOrder = false
            }
            
        } catch{
             SharedManager.shared.printLog(error)
            isOrder = false
        }
    
    if isOrder
    {
        addOrderToLogst(log: "didReceive data from : \(peerID.displayName)",peerID: "Connected peers \(session.connectedPeers)")
        delegete?.sendData(data: data)
    }

}

  
    func addOrderToLogst(log:String,peerID:String = ""){
        MultiPeerLog.set(log: log, note: peerID)
    }
    
}
