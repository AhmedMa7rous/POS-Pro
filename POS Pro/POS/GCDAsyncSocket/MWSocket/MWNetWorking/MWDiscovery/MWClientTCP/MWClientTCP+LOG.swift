//
//  MWTCP+LOG.swift
//  pos
//
//  Created by M-Wageh on 16/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
//MARK: - MWTCP+log
extension MWClientTCP{
    func addStateToLog(_ state:String){
        //        mwLocalNetworking.async {
        if let selectIpDevice = self.selectIpDevice {
            selectIpDevice.setLogWith(state: "[MWClientTCP] " + state)
        }else{
            self.messages_ip_log?.addStatus(state)
        }
        //        }
    }
    
    func initializeMessageLog(_ state:String) {
        //  DispatchQueue.main.async {
        self.messages_ip_log = messages_ip_log_class(fromDictionary: [:])
        self.messages_ip_log?.addStatus("[MWClientTCP] " + state)
        self.messages_ip_log?.from_ip = MWConstantLocalNetwork.posHostServiceName
        self.messages_ip_log?.to_ip = ""
        self.messages_ip_log?.body =  ""
        self.messages_ip_log?.messageIdentifier =  ""
        self.messages_ip_log?.response = ""
        // }
    }
    func saveMessageLog() {
        if self.selectIpDevice == nil{
            //            mwLocalNetworking.async {
            //            self.messages_ip_log?.isFaluire = true
            self.messages_ip_log?.save()
            //            }
        }
    }
    func setLogIsSucces(_ isSuccess:Bool){
        if let selectIpDevice = self.selectIpDevice {
            selectIpDevice.messages_ip_log?.isFaluire = isSuccess
        }else{
            self.messages_ip_log?.isFaluire = isSuccess
        }
    }
    func getIsSuccess()-> Bool{
        if let selectIpDevice = self.selectIpDevice {
            return selectIpDevice.messages_ip_log?.isFaluire ?? false
        }else{
            return self.messages_ip_log?.isFaluire ?? false
        }
    }

}
