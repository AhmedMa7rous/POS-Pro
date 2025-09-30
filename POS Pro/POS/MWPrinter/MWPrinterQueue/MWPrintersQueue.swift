//
//  MWPrintersQueue.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
//MARK: - MWPrintersQueue
class MWPrintersQueue:NextQueueDelegate{
    //    var status:MWQueue_Status
    var mwQueueForFilesStuck:[MWQueueForFiles]
    var queuePriority:QUEUE_PRIORITY
    private var currentMWQueueForFiles:MWQueueForFiles?
    var delegate:NextQueueDelegate?
    
    init(queuePriority:QUEUE_PRIORITY) {
        self.queuePriority = queuePriority
        self.mwQueueForFilesStuck = []
        //        status = .NONE
    }
    func getIps() -> [String]{
        let printerTarges = (self.mwQueueForFilesStuck).map({$0.getTargetPrinters()}).first
        return  printerTarges?.compactMap({$0?.printer_ip}) ?? []
    }
    func splitPrinterStuck(for ip:String) -> (splitPrinterQueue:MWPrintersQueue?,originPrinterQueue:MWPrintersQueue?){
        var splitMWPrintersQueue:MWPrintersQueue? = nil
        var orginMWPrintersQueue:MWPrintersQueue? = nil
        var splitFilesStuck:[MWQueueForFiles] = []
        var orginFilesStuck:[MWQueueForFiles] = self.mwQueueForFilesStuck
        mwQueueForFilesStuck.forEach { mwQueueForFiles in
            let splitResult  = mwQueueForFiles.splitFilesStuck(for: ip)
            if let splitQueueFiles = splitResult.splitQueueFiles{
                splitFilesStuck.append(splitQueueFiles )
            }
            if let originQueueFiles = splitResult.originQueueFiles{
                orginFilesStuck.append(originQueueFiles )
            }
        }
        if splitFilesStuck.count > 0 {
            splitMWPrintersQueue = MWPrintersQueue(queuePriority: self.queuePriority)
            splitMWPrintersQueue?.addAll(splitFilesStuck)
        }
        if orginFilesStuck.count > 0 {
            orginMWPrintersQueue = MWPrintersQueue(queuePriority: self.queuePriority)
            orginMWPrintersQueue?.addAll(splitFilesStuck)
        }
        
        return(splitMWPrintersQueue,orginMWPrintersQueue)
    }
    func deAllocate(){
        mwQueueForFilesStuck.forEach { mwQueueForFiles in
            mwQueueForFiles.deAllocate()
        }
        mwQueueForFilesStuck.removeAll()
        currentMWQueueForFiles = nil
        delegate = nil
    }
    func addAll(_ mwQueueForFiles:[MWQueueForFiles]){
        mwQueueForFilesStuck.append(contentsOf: mwQueueForFiles)
    }
    func add(_ mwQueueForFiles:MWQueueForFiles){
        mwQueueForFilesStuck.append(mwQueueForFiles)
    }

    func start(){
//        if case MWQueue_Status.START = status {
//            return
//        }
        MWQueue.shared.mwPrintersQueue.async {
//        DispatchQueue.global(qos: .background).async {
            if self.mwQueueForFilesStuck.count > 0 {
//            status = .START
                self.currentMWQueueForFiles = self.mwQueueForFilesStuck.first
                self.currentMWQueueForFiles?.delegate = self
                self.currentMWQueueForFiles?.start()
        }
        }
    }
    func stopCurrent(with status:MWQueue_Status ){
        currentMWQueueForFiles?.stopCurrent(with:status)
    }
    func stopAll(with status:MWQueue_Status ){
        mwQueueForFilesStuck.forEach { stuckQueue in
            stuckQueue.stopAll(with: status)
        }
    }
    func next(){
//        status = .NONE

        if mwQueueForFilesStuck.count > 0{
            if mwQueueForFilesStuck.count == 1 {
                mwQueueForFilesStuck.first?.deAllocate()
                mwQueueForFilesStuck.removeAll()
                delegate?.next()
            }else{
            mwQueueForFilesStuck.first?.deAllocate()
            mwQueueForFilesStuck.remove(at: 0)
            if mwQueueForFilesStuck.count > 0{
                start()
            }else{
                delegate?.next()
            }
                
            }
        }else{
            delegate?.next()
        }
            
    }
}
