//
//  MWRunQueuePrinter.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
//MARK: - MWRunQueuePrinter
class MWRunQueuePrinter:NextQueueDelegate{
    private var mwPrintersQueueStuck:[MWPrintersQueue] = []
    private var currentMWPrintersQueue:MWPrintersQueue?
    private var status:MWQueue_Status = MWQueue_Status.NONE
    static let shared = MWRunQueuePrinter()
    private init(){}
    func isRunning()->Bool {
        return mwPrintersQueueStuck.count > 0 ||  status == .START
    }
    func checkExist(printer_error_id:Int?) -> Bool{
        var isExist = false
       for mwPrintersQueue in mwPrintersQueueStuck {
           for mwQueueForFiles in mwPrintersQueue.mwQueueForFilesStuck {
                for mwFileInQueue in mwQueueForFiles.FilesQueue {
                    if  printer_error_id == mwFileInQueue.printer_error_id {
                        isExist = true
                        if isExist{
                            break
                        }
                    }
                }
               
            }
           if isExist{
               break
           }
           if isExist{
               break
           }
        }
        return isExist
        
    }
    func sortPrinterQueue(){
        if !SharedManager.shared.appSetting().enable_enhance_printer_cyle {
            return
        }
        var newPrintersQueueStuck:[MWPrintersQueue] = []
        if self.mwPrintersQueueStuck.count > 1 {
            var allQueueFiles:[MWQueueForFiles] = []
            var allFiles:[MWFileInQueue] = []
            for queueFile in self.mwPrintersQueueStuck.map({$0.mwQueueForFilesStuck}) {
                allQueueFiles.append(contentsOf:queueFile)
            }
            for filePrinter in allQueueFiles.map({$0.FilesQueue}){
                allFiles.append(contentsOf: filePrinter)
            }
            let allResturantPrinter:[restaurant_printer_class] = allFiles.compactMap({$0.restaurantPrinter}).unique{$0.printer_ip}
            SharedManager.shared.printLog(allResturantPrinter)
            allResturantPrinter.forEach { resturantPrinter in
                let mwPrintersQueue = MWPrintersQueue(queuePriority: .HIGH)
                let mwQueueForFiles = MWQueueForFiles()
                var filesPrinter:[MWFileInQueue] = allFiles.filter({($0.restaurantPrinter?.printer_ip ) == resturantPrinter.printer_ip })
                filesPrinter.sort(by: {($0.restaurantPrinter?.sortNumber() ?? -1) > ($1.restaurantPrinter?.sortNumber() ?? -1)})
                mwQueueForFiles.addAll(filesPrinter)
                mwPrintersQueue.add(mwQueueForFiles)
                newPrintersQueueStuck.append(mwPrintersQueue)

            }
            if newPrintersQueueStuck.count > 0 {
                mwPrintersQueueStuck.removeAll()
                mwPrintersQueueStuck.append(contentsOf: newPrintersQueueStuck)
            }
            
        }
    }
    func addMWPrintersQueue(_ mwPrintersQueue:MWPrintersQueue,
                            printerIP:String){
        mwPrintersQueueStuck.append(mwPrintersQueue)
      
        /*
        //MARK: - Need to check
        var currentPrintersQueueStuck = self.mwPrintersQueueStuck
        if currentPrintersQueueStuck.count > 0 {
            //MARK: -
            
            /*
            var newPrintersQueueStuck: [MWPrintersQueue] = []
            while currentPrintersQueueStuck.count > 0 {
                if let firstPrintersQueueStuck = currentPrintersQueueStuck.first{
                    let splitResult = firstPrintersQueueStuck.splitPrinterStuck(for: printerIP)
                    if let originPrinterQueue = splitResult.originPrinterQueue{
                        newPrintersQueueStuck.append(originPrinterQueue )
                    }
                    if var splitPrinterQueue = splitResult.splitPrinterQueue{
                        splitPrinterQueue.addAll(firstPrintersQueueStuck.mwQueueForFilesStuck)
                        newPrintersQueueStuck.append(splitPrinterQueue )
                    }
                    currentPrintersQueueStuck.removeFirst()
                }
            }
            if newPrintersQueueStuck.count > 0{
                mwPrintersQueueStuck.removeAll()
                mwPrintersQueueStuck.append(contentsOf:newPrintersQueueStuck )
            }
            */
        }else{
            mwPrintersQueueStuck.append(mwPrintersQueue)
        }
        */
    }
    func checkIfNeedDiscount()->Bool{
        if self.mwPrintersQueueStuck.count >= 2{
            let currentIpPrinters = self.mwPrintersQueueStuck.map({$0.getIps()})
            if currentIpPrinters.count >= 2 {
                let workingIps = currentIpPrinters.first ?? []
                
            }
           
        }
        return true
    }
    func startMWQueue(){
        if SharedManager.shared.cannotPrintBill() && SharedManager.shared.cannotPrintKDS()   {
           return
        }
        if self.status == .START {
            return
        }
        if self.mwPrintersQueueStuck.count > 0 {
            self.sortPrinterQueue()
            self.status = MWQueue_Status.START
            self.sortQueue()
            self.currentMWPrintersQueue = self.mwPrintersQueueStuck.first
            self.currentMWPrintersQueue?.delegate = self
            self.currentMWPrintersQueue?.start()
        }else{
            self.clearQueue()
        }
    }
    func stopCurrent(with status:MWQueue_Status ){
        currentMWPrintersQueue?.stopCurrent(with: status)
        removeFirstQueue()
    }
    func stopAll(with status:MWQueue_Status ){
        mwPrintersQueueStuck.forEach { stuckQueue in
            stuckQueue.stopAll(with: status)
        }
        removeAllQueue()
    }
    func removeFirstQueue(){
        mwPrintersQueueStuck.first?.deAllocate()
        mwPrintersQueueStuck.removeFirst()
    }
    func removeAllQueue(){
        mwPrintersQueueStuck.forEach { mwPrinter in
            mwPrinter.deAllocate()
        }
        mwPrintersQueueStuck.removeAll()
        MWPrinterRetry.shared.finishRetryPrint()
    }
    
    
    func sortQueue(){
        mwPrintersQueueStuck = mwPrintersQueueStuck.sorted {$0.queuePriority.rawValue > $1.queuePriority.rawValue}
        
    }
    func clearQueue(){
        self.status = .NONE
        self.currentMWPrintersQueue?.deAllocate()
        self.currentMWPrintersQueue = nil
        MWPrinterSDK.shared.mwFileInQueue = nil
        MWPrinterSDK.shared.printerSDK = nil
    }
    func getCountFilesInQueue() -> Int{
        var count = 0
        for mwPrintersQueueStick in mwPrintersQueueStuck {
            count += mwPrintersQueueStick.mwQueueForFilesStuck.count
        }
        return count
    }
    func next(){
        if mwPrintersQueueStuck.count > 0{
            removeFirstQueue()
            if mwPrintersQueueStuck.count > 0{
                clearQueue()
                startMWQueue()
            }else{
                removeAllQueue()
                clearQueue()
            }
        }else{
            removeAllQueue()
            clearQueue()
        }
    }
    func retryPrintFailure(){
        
        
    }
}
