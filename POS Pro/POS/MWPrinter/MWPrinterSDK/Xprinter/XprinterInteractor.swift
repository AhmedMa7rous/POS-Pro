//
//  XprinterInteractor.swift
//  pos
//
//  Created by M-Wageh on 23/01/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
import PrinterSDK
import UIKit
extension XprinterInteractor:MWPrinterSDKProtocol{
    func connect(with ip: String, success: @escaping () -> Void, failure: @escaping (String) -> Void, receiveData: @escaping (Data?) -> Void) {
        self.isStartConnect = true

        self.connectPrinter(with:ip)
        self.initalizeHPRTHandler(success:success,
                                  failure:failure,
                                  receiveData:receiveData)
    }
    
    func statusPrinter(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        if (self.isStartConnect ?? false){
            self.statusPrinter(success: success, failure: failure)
            return
        }
        if self.isConnectSuccess ?? false{
//            self.failureHandler = nil
            success()
            return
        }
        getPrinterStatus(success:success,failure:failure)

    }
    
    func handlerSendToPrinter(sendSuccess: @escaping () -> Void,
                              sendFailure: @escaping (String) -> Void,
                              sendProgressUpdate: ((Double?) -> Void)?,
                              receiveData: ((Data?) -> Void)?,
                              printSuccess: @escaping () -> Void) {
        initalizeCompeteSend(sendSuccess:sendSuccess,sendFailure:sendFailure,sendProgressUpdate:sendProgressUpdate,receiveData:receiveData,printSuccess:printSuccess)

    }
    func startPrint(image: UIImage?,openDrawer:Bool,sendFailure: ((String) -> Void)? ) {
        let PaperSize = [384,576,640,832,2360,3540][1]
        let imageMode = PTBitmapMode.binary
        let imagePressMode = PTBitmapCompressMode.none
        guard let temp = image else {
            sendFailure?("temp error")
            return
        }
        guard let zybImage = PDResetImage.scaleImageForWidth(image: temp, width: CGFloat(PaperSize)) else {
            sendFailure?("zyb error")
            return
        }
        guard let cgImage = zybImage.cgImage else {
            sendFailure?("cg error")
            return
        }
        var cmdData = Data()
        let cmd = PTCommandESC.init()
        cmd.initializePrinter()
        cmd.appendRasterImage(cgImage, mode: imageMode, compress: imagePressMode, package: false)
        cmd.setFullCutWithDistance(100)
        //open cashdrawer
        if openDrawer{ cmd.kickCashdrawer(0) }

        cmdData.append(cmd.getCommandData())
        competeHandlerPrinter(cmdData:cmdData)

   }
    func disConnect() {
        self.isConnectSuccess = false
        self.failureHandler = nil

        ptDispatcher?.disconnect()
        self.removePrinterHandler()

    }
    func openDrawer(completeHandler: @escaping (Bool) -> Void){
        var cmdData = Data()
        let cmd = PTCommandESC.init()
        cmd.initializePrinter()
        cmd.kickCashdrawer(0)
        cmdData.append(cmd.getCommandData())
        competeHandlerPrinter(cmdData:cmdData)
        completeHandler(true)
    }
}
class XprinterInteractor {
    static let shared = XprinterInteractor()
    private var hprtPrinter: PTPrinter?
    private var ptDispatcher:PTDispatcher?
    private var failureHandler:( (String) -> Void)?
//    private var isConnect:Bool?
    var isStartConnect:Bool?
    var isConnectSuccess:Bool?

    private init(){
        ptDispatcher = PTDispatcher.share()
    }
    // == Main
    // === 192 Main
    func connectPrinter(with ip:String){
        hprtPrinter = PTPrinter.init()
        hprtPrinter?.ip = ip
        hprtPrinter?.module = .wiFi
        hprtPrinter?.port = "9100"
        if let hprtPrinter = self.hprtPrinter{
                self.ptDispatcher?.connect(hprtPrinter)
        }
    }
    func initalizeHPRTHandler(success:@escaping () -> Void,
                          failure:@escaping (String) -> Void,
                          receiveData:@escaping (Data?) -> Void){
        self.failureHandler = failure
        completeSucessHandler(success)
        completeFailureHandler(failure)
        completeRecieveData(receiveData)
        whenUnConnectHandler()
    }
    
    private func completeSucessHandler(_ success:@escaping () -> Void){
        ptDispatcher?.whenConnectSuccess({
            self.isStartConnect =  false
            self.isConnectSuccess = true
            
            success()
        }
            )
    }
    private func completeFailureHandler(_ failure:@escaping (String) -> Void){
        ptDispatcher?.whenConnectFailureWithErrorBlock { (error) in
            self.isStartConnect =  false
            self.isConnectSuccess = false

            var errorStr: String?
            switch error {
                case .streamTimeout:
                    errorStr = "Connection timeout"
                case .streamEmpty:
                    errorStr = "Connection Error"
                case .streamOccured:
                    errorStr = "Connection Error"
                default:
                    break
            }
            if let temp = errorStr {
               // SVProgressHUD.showError(withStatus: temp)
                
            }
            failure(errorStr ?? "\(error.rawValue)")

        }
    }
    private func completeRecieveData(_ receiveDataHandler:@escaping (Data?) -> Void){
        ptDispatcher?.whenReceiveData({ (receiveData) in
            receiveDataHandler(receiveData)
        })
    }
    private func getPrinterStatus(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        
        let esc = PTCommandESC.init()
        esc.getPrinterStatus()
        ptDispatcher?.send(esc.getCommandData())
        ptDispatcher?.whenSendSuccess { _, _ in
            success()
        }
        ptDispatcher?.whenReceiveData({ (data) in
            guard let tempData = data else { return }
            let byte = [UInt8](tempData)
            var status = ""
//            if tempData.count == 1 {
//                guard let statusData = tempData.read(to: UInt8.self) else { return }
//                let message = PDPrinterCPCLStatusOptionSet.init(rawValue: statusData).description
//                status += "\(message) "
//            }
            if byte[0] & 4 == 4 {
                status += "Cover opened "
            }
//            else {
//                status += "Cover closed "
//            }
            if byte.count > 1 {
                if byte[1] & 96 == 96 {
                    status += "Out of paper "
                }
            }
//            else {
//                status += "Paper remaining "
//            }
            if status != "" {
                failure("Error status \(status)")

            }
//            PDAppWindow.rootViewController!.bk_presentWarningAlertController(title: "Tips".localized, message: status, style: .default)
        })
        
    }
     
   
    func competeHandlerPrinter(cmdData:Data){
       // Thread.sleep(forTimeInterval: 0.001)
        ptDispatcher?.send(cmdData)
      
    }
    func initalizeCompeteSend(sendSuccess: @escaping () -> Void, sendFailure: @escaping (String) -> Void, sendProgressUpdate: ((Double?) -> Void)?, receiveData: ((Data?) -> Void)?, printSuccess: @escaping () -> Void){
        ptDispatcher?.whenSendFailure({
            sendFailure("Data send failed")
        })
        
        ptDispatcher?.whenSendProgressUpdate({progress in
            sendProgressUpdate?(Double(progress ?? 0))
        })
        
        ptDispatcher?.whenSendSuccess({ int64,double in
            Thread.sleep(forTimeInterval: 0.002)
            sendSuccess()
            
//            UIAlertController.showConfirmView("Tips".localized, message: "Data sent successfully".localized + ",  " +  "Total data:".localized + "\($0/1000) kb,  " + "Total time:".localized + String.init(format: "%.1f s,  ", $1) + "Transmission rate:".localized + String.init(format: "%.1f kb/s", Double($0/1000)/$1), confirmHandle: nil)
        })
        
        ptDispatcher?.whenReceiveData({ (data) in
            SharedManager.shared.printLog("Print whenReceiveData")
            receiveData?(data)
            guard let data = data else {return}
            print(#line,data.hexString)
        })
        
        ptDispatcher?.whenESCPrintSuccess { _ in
            Thread.sleep(forTimeInterval: 0.002)
            printSuccess()

        }
        ptDispatcher?.whenUpdatePrintState({ (state) in
            
            if state == PTPrintState.success{
                printSuccess()
            }else{
                sendFailure("UpdatePrintState error \(state)")
            }

        })
     
            
    }
    func whenUnConnectHandler(){
        ptDispatcher?.whenUnconnect { (_) in
            self.failureHandler?("unconnect error")
        }
    }
    func removePrinterHandler(){
        self.ptDispatcher?.sendSuccessBlock = nil
        self.ptDispatcher?.sendFailureBlock = nil
        self.ptDispatcher?.sendProgressBlock = nil
        self.ptDispatcher?.connectFailBlock = nil
        self.ptDispatcher?.connectSuccessBlock = nil
        self.ptDispatcher?.readRSSIBlock = nil
        self.ptDispatcher?.receiveDataBlock = nil
    }
        
}
