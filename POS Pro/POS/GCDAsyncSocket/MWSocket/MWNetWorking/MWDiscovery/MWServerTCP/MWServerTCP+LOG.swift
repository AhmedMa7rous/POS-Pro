//
//  MWServerTCP+LOG.swift
//  pos
//
//  Created by M-Wageh on 18/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
//MARK: - MWTCP+log
extension MWServerTCP{
    func addStateToLog(_ state:String){
        self.messages_ip_log?.addStatus("[SERVER TCP] " + state)
    }
    
    func initializeMessageLog(_ state:String) {
        //  DispatchQueue.main.async {
        self.messages_ip_log = messages_ip_log_class(fromDictionary: [:])
        self.messages_ip_log?.addStatus("[SERVER TCP] " + state)
        self.messages_ip_log?.from_ip = MWConstantLocalNetwork.posHostServiceName
        self.messages_ip_log?.to_ip = ""
        self.messages_ip_log?.body =  ""
        self.messages_ip_log?.messageIdentifier =  ""
        self.messages_ip_log?.response = ""
        // }
    }
    func saveMessageLog() {
        self.messages_ip_log?.save()
    }

}
