//
//  MultiPeerManagerDelegate.swift
//  pos
//
//  Created by khaled on 02/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension MultiPeerManager: MCSessionDelegate, MCBrowserViewControllerDelegate,MCAdvertiserAssistantDelegate,MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate{
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        return invitationHandler(true,mcSession)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        addOrderToLogst(log: "lostPeer: \(peerID.displayName)",peerID: "Connected peers \(mcSession.connectedPeers)")

        browserOrder(browser, lostPeer: peerID)
        browserReport(browser, lostPeer: peerID)
        
     }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        addOrderToLogst(log: "foundPeer: \(peerID.displayName)",peerID: "Connected peers \(mcSession.connectedPeers)")

        browserOrder(browser, foundPeer: peerID, withDiscoveryInfo: info)
        browserReport(browser, foundPeer: peerID, withDiscoveryInfo: info)
        DispatchQueue.main.async {
            browser.invitePeer(peerID, to: self.mcSession, withContext: nil, timeout: 100)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            addOrderToLogst(log: "Connected: \(peerID.displayName)",peerID: "Connected peers \(session.connectedPeers)")
            sendNewSeqToPeers()
            sendPosInfo()
            
        case MCSessionState.connecting:
            addOrderToLogst(log: "Connecting: \(peerID.displayName)",peerID: "Connected peers \(session.connectedPeers)")
        case MCSessionState.notConnected:
            addOrderToLogst(log: "Not Connected: \(peerID.displayName)",peerID: "Connected peers \(session.connectedPeers)")
        @unknown default:
            addOrderToLogst(log: "unknown: \(state)",peerID: "Connected peers \(session.connectedPeers)")
        }
        
         sessionOrder(session, peer: peerID, didChange: state)
        sessionReport(session, peer: peerID, didChange: state)
  
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
       sessionOrder(session,didReceive: data,fromPeer: peerID)
        sessionReport(session,didReceive: data,fromPeer: peerID)

    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    }
  
    

}
