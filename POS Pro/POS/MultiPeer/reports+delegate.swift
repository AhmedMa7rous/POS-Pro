//
//  reportsDelegate.swift
//  pos
//
//  Created by khaled on 02/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import Foundation
import MultipeerConnectivity

extension MultiPeerManager
{
func browserReport(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {

}

 
func browserReport(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
 
}

func sessionReport(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
   
}

func sessionReport(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

 
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
            
            let type = dic?["type"] as? String
            if type == "request"
            {

                let request = dic?["request"] as? String
               SharedManager.shared.printLog("==> request " + request!)

                masterPeerID = peerID

                let day = dic?["day"] as! String

                let _reportType = reportsList.init(rawValue: request!)
                sendDataSalesReport(_report: _reportType! , forDay: day)
                 
            }
            else if type == "receive"
            {
               SharedManager.shared.printLog("==> receive " )

                let data = dic?["data"] as?  [String:Any] ?? [:]
 
                NotificationCenter.default.post(name: Notification.Name("requestReport"), object: data)

            
            }
            
           
            
            
        } catch{
             SharedManager.shared.printLog(error)
         }
     
}
    
    
    
}
