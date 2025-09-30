//
//  MWQueue.shared.swift
//  pos
//
//  Created by M-Wageh on 11/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class MWQueue {
    static let shared = MWQueue()
    lazy var mwMessageSocketQueue: DispatchQueue = {
        DispatchQueue(label: "mw.messages.socket.queue",qos: .background,attributes: .concurrent)
    }()
    let timeOutDeliveryOrderQueue = DispatchQueue(label: "MW-TimeOutDeliveryOrderQueue", qos: .background)
    let printerMacAddressThread = DispatchQueue(label: "MW-printerMacAddressThread", qos: .background)
    let mwForceResentQueue = DispatchQueue(label: "mw.forceResent.item",qos: .background,attributes: .concurrent)
    let mwfillFailureQueueMessages = DispatchQueue(label: "mw.fillFailure.QueueMessages",qos: .background,attributes: .concurrent)
    let mwPrintersQueue = DispatchQueue(label: "mw.printersQueue.run",qos: .background,attributes: .concurrent)
    let firebaseQueue = DispatchQueue.main //DispatchQueue(label: "mw.fireBase.threadQueue", qos: .background, attributes: .concurrent)
    let mwReTryPrintersQueue = DispatchQueue(label: "mw.retryPrinter.run",qos: .background,attributes: .concurrent)
    let mwClientArrayQueue = DispatchQueue(label: "mw.client.arrayQueue", attributes: .concurrent)
    let mwTCPRequest = DispatchQueue(label: "mw.tcp.request", qos: .background,attributes: .concurrent)
    let mwSessionSequence = DispatchQueue(label: "mw.tcp.session.sequence", qos: .background,attributes: .concurrent)
    let mwUpdateStatusDevice = DispatchQueue(label: "mw.tcp.update.status",qos: .background, attributes: .concurrent)
    let mwTCPStartSession = DispatchQueue(label: "mw.tcp.start.session",qos: .background, attributes: .concurrent)
    let mwTCPEndSession = DispatchQueue(label: "mw.tcp.end.session",qos: .background, attributes: .concurrent)
    let mwForceExcuteQueryQueue = DispatchQueue(label: "mw.forceExcute.query",qos: .background,attributes: .concurrent)
    let mwDriverLockQueue = DispatchQueue(label: "mw.driverLock.customer",qos: .background,attributes: .concurrent)
    let mwTCPBrowser = DispatchQueue(label: "mw.tcp.browser", qos: .background,attributes: .concurrent)
    let mwBluetooth = DispatchQueue(label: "mw.bluetooth.run",qos: .background,attributes: .concurrent)
    let mwCloudQRQueue = DispatchQueue(label: "mw.cloudQr.run",qos: .background,attributes: .concurrent)

    let mwMaintanceExcute = DispatchQueue(label: "mw.maintance.excute",qos: .background,attributes: .concurrent)
    let mwReTryPollQueue = DispatchQueue(label: "mw.retry.poll",qos: .background,attributes: .concurrent)

    //    let printersQueueOperation = OperationQueue()


//    private var multisessionTask: DispatchWorkItem?
//
//    private init(){
//
//    }
//     let multisessionQueue = DispatchQueue(label: "MW-MultisessionThreadQueue", qos: .background)
//     let firebaseQueue = DispatchQueue(label: "MW-FireBaseThreadQueue", qos: .background)
//     let syncOrdersQueue = DispatchQueue(label: "MW-SyncOrdersThreadQueue", qos: .background)
//
//
//    func sartMultisessionTask(){
//        multisessionTask = DispatchWorkItem {
//            AppDelegate.shared.run_poll_now()
//            self.multisessionQueue.asyncAfter(deadline: .now() + 3, execute: self.multisessionTask!)
//
//               }
//        multisessionQueue.asyncAfter(deadline: .now() + 3, execute: multisessionTask!)
//    }

}
