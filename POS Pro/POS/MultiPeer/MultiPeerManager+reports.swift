//
//  MultiPeerManager+reports.swift
//  pos
//
//  Created by khaled on 02/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

extension MultiPeerManager{
    
    func requestSalesReport(_report:reportsList,forDay:String) -> Int
    {
        if mcSession.connectedPeers.count > 0 {
            do {
                var jsonData:Data?
                do {
                    var dic:[String:Any] = [:]
                    dic["type"] = "request"
                    dic["day"] = forDay
                    dic["request"] = _report.rawValue
                    jsonData = try JSONSerialization.data(withJSONObject:dic , options: .prettyPrinted)
                    
                } catch {
                    SharedManager.shared.printLog(error.localizedDescription)
                }
                try mcSession.send(jsonData!, toPeers: mcSession.connectedPeers, with: .reliable)
                
                return mcSession.connectedPeers.count
                
            } catch let error as NSError {
                SharedManager.shared.printLog(error.debugDescription)
                return 0
            }
        }
        
        return 0
    }
    
    func sendDataSalesReport(_report:reportsList,  forDay:String) {
       if masterPeerID == nil
       {
        return
       }
        
        if mcSession.connectedPeers.count > 0 {
            do {
                var jsonData:Data?
                do {
                    var dic:[String:Any] = [:]
                    dic["type"] = "receive"
                    dic["receive"] = _report.rawValue
                    dic["data"] = getDataForSalesReports(_report,forDay)
                    jsonData = try JSONSerialization.data(withJSONObject:dic , options: .prettyPrinted)
                    
                } catch {
                    SharedManager.shared.printLog(error.localizedDescription)
                }
                try mcSession.send(jsonData!, toPeers: [masterPeerID!], with: .reliable)
               SharedManager.shared.printLog("==> sendDataSalesReport")

                
            } catch let error as NSError {
                SharedManager.shared.printLog(error.debugDescription)
            }
        }
    }
    
    func getDataForSalesReports(_ _report:reportsList, _ forDay:String) -> [String:Any]
    {
       SharedManager.shared.printLog("==> getDataForSalesReports")
        
        let rpt = reportsBuilder().requestReport(_report: _report, forDay: forDay)
        
        if rpt == nil
        {
            return [:]
        }
        
        return rpt!.toDictionary()
    }
    
    
}
