//
//  MultiPeerManager.swift
//  pos
//
//  Created by Mohamed Magdy on 12/5/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultiPeerManagerDelegate{
    func sendData(data:Data)
}



class MultiPeerManager:NSObject  {
    
    // set if admin request reports
    var masterPeerID: MCPeerID?
    var message:peerMessage?
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!
    
    var delegete:MultiPeerManagerDelegate?
    var serviceType = "hws-kb"
 
    var sequenseNumber = pos_order_class(fromDictionary: [:]).generateInviceID(session_id: pos_session_class.getActiveSession()?.id)
 
    override init() {
        super.init()
    }
    
    func multiPeerSession(){
//        if mwIpPos {
//            return
//        }
         let name = SharedManager.shared.posConfig().id
        ProcessInfo.processInfo.hostName
        peerID = MCPeerID(displayName:"\(name)-POS")
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: mcSession)
        mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        mcSession.delegate = self
        mcAdvertiserAssistant.delegate = self
        mcNearbyServiceAdvertiser.delegate = self
        mcNearbyServiceAdvertiser.startAdvertisingPeer()
        
        //Browsing
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        
    }
    
    
//    func send(_ message: String) {
////      let chatMessage = PeerMessage(displayName: peerID.displayName, body: message)
////      messages.append(chatMessage)
//      guard
//        let session = mcSession,
//        let data = message.data(using: .utf8),
//        !session.connectedPeers.isEmpty
//      else { return }
//
//      do {
//        try mcSession.send(data, toPeers: session.connectedPeers, with: .reliable)
//      } catch {
//        SharedManager.shared.printLog(error.localizedDescription)
//      }
//    }
    
    func send(_ json:String?) {
 
         if (json == nil)
        {
             return
         }
        
//        let json = message?.data.toJSONString() ?? ""
        
      guard
        let session = mcSession,
        let data = json!.data(using: .utf8),
        !session.connectedPeers.isEmpty
      else {
          return
          
      }

//      do {
        try? mcSession.send(data, toPeers: session.connectedPeers, with: .reliable)
//      } catch {
//        SharedManager.shared.printLog(error.localizedDescription)
//      }
        
    }
    
    
    func sendPosInfo() {
        
    message = peerMessage()
    let json =  message!.build(pos: SharedManager.shared.posConfig())
    send(json)
        
    }
    
}



