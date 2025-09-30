//
//  HPRTInteractor.swift
//  pos
//
//  Created by M-Wageh on 29/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import PrinterSDK
import UIKit
extension HPRTInteractor:MWPrinterSDKProtocol{
    func connect(with ip: String, success: @escaping () -> Void, failure: @escaping (String) -> Void, receiveData: @escaping (Data?) -> Void) {
        self.connectPrinter(with:ip)
        self.initalizeHPRTHandler(success:success,
                                  failure:failure,
                                  receiveData:receiveData)
    }
    
    func statusPrinter(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
       
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
        guard let temp = image else { return }
        guard let zybImage = PDResetImage.scaleImageForWidth(image: temp, width: CGFloat(PaperSize)) else { return }
        guard let cgImage = zybImage.cgImage else { return }
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
        ptDispatcher?.disconnect()
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
class HPRTInteractor {
    static let shared = HPRTInteractor()
    private var hprtPrinter: PTPrinter?
    private var ptDispatcher:PTDispatcher?
    private init(){
        ptDispatcher = PTDispatcher.share()
    }
    
    func connectPrinter(with ip:String){
        hprtPrinter = PTPrinter.init()
        hprtPrinter?.ip = ip
        hprtPrinter?.module = .wiFi
        hprtPrinter?.port = "9100"
        if let hprtPrinter = self.hprtPrinter{
            ptDispatcher?.connect(hprtPrinter)
        }
    }
    func initalizeHPRTHandler(success:@escaping () -> Void,
                          failure:@escaping (String) -> Void,
                          receiveData:@escaping (Data?) -> Void){
        completeSucessHandler(success)
        completeFailureHandler(failure)
        completeRecieveData(receiveData)
        whenUnConnectHandler()
    }
    
    private func completeSucessHandler(_ success:@escaping () -> Void){
        ptDispatcher?.whenConnectSuccess(success)
    }
    private func completeFailureHandler(_ failure:@escaping (String) -> Void){
        ptDispatcher?.whenConnectFailureWithErrorBlock { (error) in
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
        ptDispatcher?.send(cmdData)
      
    }
    func initalizeCompeteSend(sendSuccess: @escaping () -> Void, sendFailure: @escaping (String) -> Void, sendProgressUpdate: ((Double?) -> Void)?, receiveData: ((Data?) -> Void)?, printSuccess: @escaping () -> Void){
        ptDispatcher?.whenSendFailure({
            sendFailure("Data send failed")
        })
        
        ptDispatcher?.whenSendProgressUpdate({progress in
            sendProgressUpdate?(Double(progress ?? 0))
        })
        
        ptDispatcher?.whenSendSuccess({ _,_ in
            sendSuccess()
            
//            UIAlertController.showConfirmView("Tips".localized, message: "Data sent successfully".localized + ",  " +  "Total data:".localized + "\($0/1000) kb,  " + "Total time:".localized + String.init(format: "%.1f s,  ", $1) + "Transmission rate:".localized + String.init(format: "%.1f kb/s", Double($0/1000)/$1), confirmHandle: nil)
        })
        
        ptDispatcher?.whenReceiveData({ (data) in
            SharedManager.shared.printLog("Print whenReceiveData",force: true)
            receiveData?(data)
            guard let data = data else {return}
            print(#line,data.hexString)
        })
        
        ptDispatcher?.whenESCPrintSuccess { _ in
            printSuccess()

        }
    }
    func whenUnConnectHandler(){
        ptDispatcher?.whenUnconnect { (_) in
            self.ptDispatcher?.sendSuccessBlock = nil
            self.ptDispatcher?.sendFailureBlock = nil
            self.ptDispatcher?.sendProgressBlock = nil
            self.ptDispatcher?.connectFailBlock = nil
            self.ptDispatcher?.connectSuccessBlock = nil
            self.ptDispatcher?.readRSSIBlock = nil
            self.ptDispatcher?.receiveDataBlock = nil
        }
    }
   
        
}
//Printer Status
struct PDPrinterCPCLStatusOptionSet : OptionSet,CustomStringConvertible {
    
    var rawValue: UInt8
    typealias RawValue = UInt8
    
    static let busy = PDPrinterCPCLStatusOptionSet.init(rawValue: 1<<0)
    static let paperEnd = PDPrinterCPCLStatusOptionSet.init(rawValue: 1<<1)
    static let openCover = PDPrinterCPCLStatusOptionSet.init(rawValue: 1<<2)
    static let lowVoltage = PDPrinterCPCLStatusOptionSet.init(rawValue: 1<<3)
    
    var description: String {
        
        var messages = [String]()
        if contains(.busy) {
            messages.append("Busy")
        }
        
        if contains(.paperEnd) {
            messages.append("Out of paper")
        }
        
        if contains(.openCover) {
            messages.append("Open")
        }
        
        if contains(.lowVoltage) {
            messages.append("Battery is Low")
        }
        
        if messages.count == 0 {
            messages.append("Ready")
        }
        return  messages.joined(separator: "--")
    }
}
class PDResetImage: NSObject {

    static func scaleSourceImage(image:UIImage, width:CGFloat, height:CGFloat) -> UIImage? {
        var rightValue = 0
        var leftValue = 0
        if (SharedManager.shared.appSetting().margin_invoice_right_value) != 25 {
            rightValue = Int((SharedManager.shared.appSetting().margin_invoice_right_value)/3)
        }
        if (SharedManager.shared.appSetting().margin_invoice_left_value) != 35 {
            leftValue = Int((SharedManager.shared.appSetting().margin_invoice_left_value)/3)
        }
        let drawWidth = CGFloat(ceil(width))
        let drawHeight = CGFloat(ceil(height))
        let size = CGSize(width: drawWidth, height: drawHeight)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .high
        context.setShouldAntialias(false)
        context.setAllowsAntialiasing(false)
        image.draw(in: CGRect.init(x: CGFloat(leftValue), y: 0, width: drawWidth - CGFloat(rightValue), height: drawHeight))
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaleImage
    }
    
    static func scaleImageForWidth(image:UIImage, width:CGFloat) -> UIImage? {
        
        let imageW = image.size.width
        let imageH = image.size.height
        var maxH : CGFloat = 0
//        if imageW > width {
//
//        }else {
//            return image
//        }
        maxH = CGFloat(Int(width * imageH / imageW))
        return self.scaleSourceImage(image: image, width: width, height: maxH)
    }
}
public extension Data {
    
    func removeZeroAtEnd() -> Data {
        if let index = self.firstIndex(of: 0) {
            if index == 0 {
                return Data()
            }else {
                return Data(self[0...index-1])
            }
        }
        return self
    }
    
    var hexString: String  {

        return hex.joined(separator: " ")
    }
    
    var rfid_hexString : String {
        return self.map({ String.init(format: "%02x", $0)}).joined(separator: "")
    }
    
    func read<T>(to type: T.Type, offset: Int = 0) -> T? {
        
        guard offset >= 0 else { return nil }
        let size = MemoryLayout<T>.stride
        if offset + size > count {
            return nil
        }
        let bytes = (self as NSData).bytes + offset
        let pointer = bytes.bindMemory(to: type, capacity: 1)
        return pointer.pointee
    }
    
    var hex: [String] {
        
        return self.map({String.init(format: "%02x", $0)})
    }
    
    // BOM:
    // 00 00 fe ff  utf32-BE
    // ff fe 00 00  utf32-LE
    // ef bb bf     utf8
    // fe ff        utf16-BE
    // ff fe        utf16-LE
    // without BOM  utf8
    var txt: String? {
        
        var content = self
        var encoding = String.Encoding.utf8
        if count >= 4 {
            switch (self[0], self[1], self[2], self[3]) {
            case (0x0, 0x0, 0xfe, 0xff):
                content.removeSubrange(0..<4)
                encoding = .utf32BigEndian
            case (0xff, 0xfe, 0x0, 0x0):
                content.removeSubrange(0..<4)
                encoding = .utf32LittleEndian
            case (0xef, 0xbb, 0xbf, _):
                content.removeSubrange(0..<3)
                encoding = .utf8
            case (0xfe, 0xff, _, _):
                content.removeSubrange(0..<2)
                encoding = .utf16BigEndian
            case (0xff, 0xfe, _, _):
                content.removeSubrange(0..<2)
                encoding = .utf16LittleEndian
            default:
                break
            }
        }else if count >= 2 {
            switch (self[0], self[1]) {
            case (0xef, 0xbb):
                if count >= 3 && self[2] == 0xbf {
                    content.removeSubrange(0..<3)
                }
            case (0xfe, 0xff):
                content.removeSubrange(0..<2)
                encoding = .utf16BigEndian
            case (0xff, 0xfe):
                content.removeSubrange(0..<2)
                encoding = .utf16LittleEndian
            default:
                break
            }
        }
        if let txt = String.init(data: content, encoding: encoding) {
            return txt
        }else {
            return nil
        }
    }
}
