//
//  MWComingOrderStack.swift
//  pos
//
//  Created by M-Wageh on 20/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MWComingOrderStack{
    static let shared = MWComingOrderStack()
    private var mwComingOrderTask:[MWComingOrderQueu] = []
    private var mwPrinterTask:[MWComingOrderQueu] = []

    private var mwComingOrderQueu:[MWComingOrderQueu] = []
    var isStart:Bool = false {
        didSet{
            if !isStart{
                startSend()
            }
        }
    }
    private init(){
        
    }
    
    func startSend(){
        if isStart {
            SharedManager.shared.printLog("isStart === \(isStart)")
            return
            
        }
        if mwComingOrderTask.count <= 0 {
            SharedManager.shared.printLog("mwComingOrderTask.count === \(mwComingOrderTask.count)")

            return
            
        }
        isStart = true
            
            self.setPrinterTask(from:self.mwComingOrderTask)
            self.mwComingOrderQueu.append(contentsOf: self.mwComingOrderTask)
            self.mwComingOrderTask.removeAll()
            //: -
            //: -
            var meesagesIP:[BodyMessageIpModel] = []
            
            self.mwComingOrderQueu.forEach { mwComingOrderItem  in
                if let bodyMessage = self.getBodyMessage(for:mwComingOrderItem ){
                    meesagesIP.append(contentsOf:bodyMessage)
                }
                
            }
//            self.runPrinterFromIP()
            
            if meesagesIP.count > 0 {
                //DispatchQueue.main.asyncAfter(deadline: .now() , execute: {
                    MWMessageQueueRun.shared.addToQueu(messages:meesagesIP)
                    MWMessageQueueRun.shared.startMWMessageQueue()
               // })
            }
            self.mwComingOrderQueu.removeAll()
            self.runPrinterFromIP()
            self.isStart = false
        
        
    }
    
    func runPrinterFromIP(){
        if  self.mwPrinterTask.count <= 0{
            return
        }
        var milsecand =  10
        self.mwPrinterTask.forEach { mwComingOrderItem in
            let isFromSubCashier = mwComingOrderItem.isFromSubCashier()
            if isFromSubCashier {
                milsecand = 500
            }
            self.addToPrinter(from: mwComingOrderItem,isFromSubCashier: isFromSubCashier)
        }
        self.mwPrinterTask.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milsecand), execute: {
            MWRunQueuePrinter.shared.startMWQueue()
        })
    }
    func addToPrinter(from mwComingOrderItem:MWComingOrderQueu,isFromSubCashier:Bool){
        self.mwPrinterTask.forEach { mwComingOrderItem  in
            
        }
        if [IP_MESSAGE_TYPES.PAYIED_ORDER].contains(mwComingOrderItem.ipMessage){
            if !isFromSubCashier{
                self.makeBillPrint(for:mwComingOrderItem)
            }else{
                self.makeKDSPrint(for:mwComingOrderItem,isSubCashier: true)
            }
        }else if [IP_MESSAGE_TYPES.RETURNED_ORDER].contains(mwComingOrderItem.ipMessage){
            if !isFromSubCashier{
                self.makeReturnPrint(for:mwComingOrderItem)
            }else{
                self.makeKDSPrint(for:mwComingOrderItem)
            }
        }else{
            self.makeKDSPrint(for:mwComingOrderItem)
        }
      
    }
    func makeBillPrint(for mwComingOrderItem:MWComingOrderQueu ){
        self.incrementPrint(order_id:mwComingOrderItem.comingOrder?.id)

        InsuranceOrderBuilder.shared.setup(InsuranceOrderBuilder.Config(currentOrder:mwComingOrderItem.comingOrder,accountJournalList:mwComingOrderItem.comingOrder?.get_account_journal()))
        
        let order_insurance = InsuranceOrderBuilder.shared.getInsuranceAsNewOrder()
        
        if let insurance_order = order_insurance {
                insurance_order.creatInsuranceQueuePrinter()

        }
            
            mwComingOrderItem.comingOrder?.printOrderByMWqueue()


    }
    func makeReturnPrint(for mwComingOrderItem:MWComingOrderQueu ){
        self.incrementPrint(order_id:mwComingOrderItem.comingOrder?.id)

            mwComingOrderItem.comingOrder?.printReturnOrderByMWqueue()


        
    }
    func makeKDSPrint(for mwComingOrderItem:MWComingOrderQueu,isSubCashier:Bool = false){
        if isSubCashier {
            if [IP_MESSAGE_TYPES.NEW_ORDER,.ChANGED_ORDER,.PAYIED_ORDER,.VOID_ORDER].contains(mwComingOrderItem.ipMessage){
                self.incrementPrint(order_id:mwComingOrderItem.comingOrder?.id)

                    mwComingOrderItem.comingOrder?.creatKDSQueuePrinter(.kds,isFromIp: true)

            }

        }else{
            if [IP_MESSAGE_TYPES.NEW_ORDER,.ChANGED_ORDER,.VOID_ORDER].contains(mwComingOrderItem.ipMessage){
                self.incrementPrint(order_id:mwComingOrderItem.comingOrder?.id)

                    mwComingOrderItem.comingOrder?.creatKDSQueuePrinter(.kds,isFromIp: true)

            }

        }
    }
    func incrementPrint(order_id:Int?){
        if let orderID = order_id{
            DispatchQueue.global(qos: .background).async {
                pos_order_helper_class.increment_print_count(order_id:orderID )
            }
        }
    }
    
   
    func setPrinterTask(from tasksComing:[MWComingOrderQueu])  {
        var uniqueTasks = [MWComingOrderQueu]()
        for task in tasksComing {
            if !uniqueTasks.contains(where: {$0.comingOrderUID == task.comingOrderUID && $0.excludIP == task.excludIP && $0.ipMessage == task.ipMessage}) {
                uniqueTasks.append(task)
            }
        }
        mwPrinterTask = []
        mwPrinterTask.removeAll()
        mwPrinterTask.append(contentsOf:uniqueTasks )
    }
    func append(_ items:[MWComingOrderQueu]){
        mwComingOrderTask.append(contentsOf: items)
    }
    private func getBodyMessage(for mwComingOrderItem: MWComingOrderQueu) -> [BodyMessageIpModel]?{
        guard let comingOrder = mwComingOrderItem.comingOrder else {
            return nil }
        var meesagesIP:[BodyMessageIpModel] = []

        let ipOrderFactor:IPOrderFactor = IPOrderFactor.shared
        ipOrderFactor.config(order:comingOrder )
        let ipMessage = mwComingOrderItem.ipMessage
        let excludIP = mwComingOrderItem.excludIP
        
        if SharedManager.shared.appSetting().enable_add_kds_via_wifi{
            if ipMessage != .RETURNED_ORDER {
                meesagesIP.append(contentsOf:  ipOrderFactor.getOrderIPKDS(with:ipMessage,excludeIp:excludIP))
            }else{
                // TODO: - sentReturn order
                SharedManager.shared.printLog(" // TODO: - sentReturn order")
            }
        }
        if SharedManager.shared.appSetting().enable_add_waiter_via_wifi{
            if ipMessage != .RETURNED_ORDER {
                meesagesIP.append(contentsOf:ipOrderFactor.getOrderIPWaiter(with:ipMessage,excludeIp:excludIP))
            }
        }
        return meesagesIP
    }
    
    
}
