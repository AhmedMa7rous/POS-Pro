//
//  sequence_session_ip.swift
//  pos
//
//  Created by M-Wageh on 22/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class sequence_session_ip {
    static let shared = sequence_session_ip()
    private let messagesKeys = MWConstantLocalNetwork.MessageKeys.self
    private var mwSessionSequence = MWQueue.shared.mwSessionSequence
    private var isStartFetchSequence = false{
        didSet{
            if !isStartFetchSequence{
                if let completGetSeques = completGetSeques{
//                    if currentSeq != takenSeq{
//                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
                        completGetSeques(true)
                        self.completGetSeques = nil
                    })
                }
            }
        }
    }
    private var completGetSeques:((Bool)->Void)? = nil

//    var takenSeq = 0
     var currentSeq:Int = 0
//     var nextSeq:Int = 1

    private init(){
        currentSeq = Int(cash_data_class.get(key: "sequence_session_ip_current") ?? "0") ?? 0
//        nextSeq = Int(cash_data_class.get(key: "sequence_session_ip_next") ?? "1") ?? 1
    }
    func showLoading_old(){
        DispatchQueue.main.async {
            if let vc = AppDelegate.shared.window?.visibleViewController() {
                loadingClass.show(view: vc.view )
            }
        }
    }
    func hideLoading_old(){
        DispatchQueue.main.async {
            if let vc = AppDelegate.shared.window?.visibleViewController(){
                loadingClass.hide(view: vc.view )
            }
        }
    }
    func forceStop(){
        if self.isStartFetchSequence {
            if let completGetSeques = self.completGetSeques{
                DispatchQueue.main.async {
                    completGetSeques(false)
                }
            }
            self.completGetSeques = nil
//            self.isStartFetchSequence = false

        }
    }
    func getSequenceForNextOrder(for view:UIView, complete: @escaping ( (Bool)->Void)){
        self.isStartFetchSequence = true
        self.completGetSeques = complete

//        takenSeq = self.currentSeq
        if SharedManager.shared.posConfig().isMasterTCP(){
            self.shareIncreaseSequence()
            self.isStartFetchSequence = false
        }else{
//            let masterDevice = device_ip_info_class.getMasterStatus()
            if (MWMasterIP.shared.isOnLine()) {
                MWTCPRequest.shared.requestSequence()
//                self.showLoading()
            }else{
//                MWMasterIP.shared.postMasterIpDeviceOffline()
                self.completGetSeques = nil
                self.isStartFetchSequence = false
                complete(false)
            }
            /*
            if let nexSequenceMaster = masterDevice?.order_sequces,
               self.currentSeq > nexSequenceMaster {
                complete()
            }else{
                if (masterDevice?.is_online) ?? false {
                    self.isStartFetchSequence = true
                    self.completGetSeques = complete
                }else{
                    complete()
                }
            }*/
        }
        
       
    }
   
    func completeGetSequenceFromMaster() -> Int{
//        MWTCPRequest.shared.completeDeviceInf = nil
        self.completGetSeques = nil
        return self.currentSeq
//
//        if  self.currentSeq - previousSeq == 1 {
//            return previousSeq
//        }else{
//            return self.currentSeq
//        }
        
    }
    func shareIncreaseSequence(){
        increasIpSequence()
//        MWTCPRequest.shared.requestDeviceInfo()
//        MWTCPRequest.shared.completeDeviceInf = nil
//        MWTCPRequest.shared.completeDeviceInf = complete
    }
    func getSequenceSessionDic()->[String:Any]{
        return [messagesKeys.CURRENT_SEQ_SESSION:self.currentSeq]

//        return [messagesKeys.CURRENT_SEQ_SESSION:self.currentSeq,
//                messagesKeys.NEXT_SEQ_SESSION:self.nextSeq]
    }
    func updateSequenceSession(from dic:[String:Any]){
        if !SharedManager.shared.appSetting().enable_sync_order_sequence_wifi {
            return
        }
        let comingIP = dic[messagesKeys.IP_ADDRESS_KEY] as? String ?? ""
        if comingIP == MWConstantLocalNetwork.posHostServiceName{
            return
        }
//        let comingNextSeq = dic[messagesKeys.NEXT_SEQ_SESSION] as? Int ?? nextSeq
        let comingCurrentSeq = dic[messagesKeys.CURRENT_SEQ_SESSION] as? Int ?? currentSeq
        updateValue(comingCurrentSeq )

/*
        if self.nextSeq > comingNextSeq {
            // TODO: -  Sent update sequence
            /**
             
            [Failure Case] rest sequence and start from 1
             */
            SharedManager.shared.printLog("TODO: -  Sent update sequence self.nextSeq \(self.nextSeq) vs comingNextSeq \(comingNextSeq)")
            MWTCPRequest.shared.requestDeviceInfo()
            /*
            if comingCurrentSeq == 1 &&
                comingNextSeq == 2 &&
                comingIP == MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME && !SharedManager.shared.posConfig().isMasterTCP()  {
                        updateValue(comingCurrentSeq, comingNextSeq)
            }*/
        }else{
            updateValue(comingCurrentSeq, comingNextSeq )
        }
        */
        if self.isStartFetchSequence && self.completGetSeques != nil {
            self.isStartFetchSequence = false
        }
        
    }
    func updateValue(_ comingCurrentSeq:Int,_ comingNextSeq:Int? = nil){
        self.currentSeq = comingCurrentSeq
//        self.nextSeq = comingNextSeq
        SharedManager.shared.updateCashSessionSequence()
    }
    
    func resetSequenceSession(){
        // TODO: -  if master sent flag is rest true and wor
        if SharedManager.shared.appSetting().enable_sync_order_sequence_wifi{
            //if SharedManager.shared.posConfig().isMasterTCP() {
                self.currentSeq = 0
//                self.nextSeq = 1
                SharedManager.shared.updateCashSessionSequence()
           // }
        }
    }
   private func increasIpSequence(){
        self.currentSeq += 1
//        self.nextSeq = currentSeq + 1
        SharedManager.shared.updateCashSessionSequence()
    }
    func isStartSequence() -> Bool {
       // return isStartFetchSequence
        return MWMessageQueueRun.shared.checkTypeInQueu(.REQUEST_SEQ)
    }
  
}
