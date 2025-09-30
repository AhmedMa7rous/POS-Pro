//
//  MWPrinterRetry.swift
//  pos
//
//  Created by M-Wageh on 14/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MWPrinterRetry {
    enum MWPrinterRetryStatus:Int {
        case NONE = 0,FILL_DATA,STARTING
    }
    private var printerErrorData: [printer_error_class] = []
    var isSartReTryPrint:MWPrinterRetryStatus = .NONE

    static let shared = MWPrinterRetry()
    private init(){
        
    }
    func runRetryPrinter(){
        //            MaintenanceInteractor.shared.getLastContextImageErrorOrder()
        if cannotStartRetyPrint() {return}
        MWQueue.shared.mwReTryPrintersQueue.async {
            self.reloadPrinterErrorData()
            if self.printerErrorData.count <= 0 {return}
            self.increaseNoTriesAndRePrintingStatus()
            self.startTryReprint()
        }
    }
    
     func finishRetryPrint(){
         self.isSartReTryPrint  = .NONE
    }
    private func cannotStartRetyPrint() -> Bool {
        let appSetting =  SharedManager.shared.appSetting()

        let isNotHaveMinutsFailReport = !appSetting.enable_reconnect_with_printer_automatic //appSetting.mw_minuts_fail_report <= 0
        let isNotHaveTriesNumber = false //appSetting.tries_non_priinted_number <= 0
        let isPrinterQueueRunning = MWRunQueuePrinter.shared.isRunning()
        
        
//        let isNotHaveErrorPrinter = printerErrorData.count <= 0
        let isNotSupportMultiBrand = !SharedManager.shared.appSetting().enable_support_multi_printer_brands
        let isStatusNotNone = isSartReTryPrint != .NONE
        return isNotHaveMinutsFailReport || isNotSupportMultiBrand || isStatusNotNone || isNotHaveTriesNumber || isPrinterQueueRunning
    }
    private func reloadPrinterErrorData(){
        let appSetting =  SharedManager.shared.appSetting()
        let isAutomaticReprinter = appSetting.enable_reconnect_with_printer_automatic //appSetting.mw_minuts_fail_report <= 0
        if !isAutomaticReprinter {
           return
        }
        self.isSartReTryPrint  = .FILL_DATA
        self.printerErrorData.removeAll()
        var sql = "where IP IS NOT NULL and IP != ''"
        let minuts = isAutomaticReprinter ? 30 : appSetting.mw_minuts_fail_report
        let noTriesFromSetting = isAutomaticReprinter ? 20 : -1 //appSetting.tries_non_priinted_number
        if minuts > 0 {
            sql += " And updated_at >= Datetime('now', '-\(minuts) minutes')"
        }
        sql += " And rePrinting_status in (0)"
        if noTriesFromSetting > 0 {
            sql += " And no_tries <= \(noTriesFromSetting)"
        }

        let errorPrinterArray = printer_error_class.getAllObject(sql: sql)
        if errorPrinterArray.count <= 0 {
            self.finishRetryPrint()
            return
        }
        self.printerErrorData.append(contentsOf: errorPrinterArray )
//        appendErrorPrinter(errorPrinterArray)
    }
    private func appendErrorPrinter(_ errorPrinterArray:[printer_error_class]){
        let comingError = Set(errorPrinterArray)
        let existError = Set(printerErrorData)
        let different = comingError.subtracting(existError)
        self.printerErrorData.append(contentsOf: different )

    }
    private func startTryReprint(){
            self.printerErrorData.forEach { item in
                item.rePrinting_status = .PRINTING_BY_APP
                item.addToErrorImageMWQueue()
            }
            MWRunQueuePrinter.shared.startMWQueue()
    }
    private func increaseNoTriesAndRePrintingStatus(){
        let idsString = "( " + self.printerErrorData.map({"\($0.id)"}).joined(separator: ",") + " )"
        let sql = " UPDATE printer_error SET rePrinting_status = 1 , no_tries = no_tries + 1 WHERE id IN \(idsString) "
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.printer_log_db!.inDatabase { (db:FMDatabase) in
            
            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                let error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
        
    }
}
extension printer_error_class{
    static func == (lhs: printer_error_class, rhs: printer_error_class) -> Bool {
        return lhs.id == rhs.id
    }
}
