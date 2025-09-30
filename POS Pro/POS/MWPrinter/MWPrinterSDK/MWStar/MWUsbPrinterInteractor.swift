//
//  MWStarPrinter.swift
//  pos
//
//  Created by DGTERA on 30/05/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
import StarIO10

enum MWUsbPrinterState {
    case NONE,Loading,Populate,Selected(restaurant_printer_class),Error(String)
}

class MWUsbPrinterInteractor: NSObject, StarDeviceDiscoveryManagerDelegate, PrinterDelegate, DrawerDelegate, InputDeviceDelegate, DisplayDelegate {

    //MARK: - Properties
    static let shared = MWUsbPrinterInteractor()
    private var printer: StarPrinter? = nil
    private var manager: StarDeviceDiscoveryManager? = nil
    private var interfaceTypeArray: [InterfaceType] = [InterfaceType.usb]
    private var selectedInterface: InterfaceType = InterfaceType.usb
    private var imageReceipt:UIImage?
    private var openDrawer:Bool = false
    private var sendSuccess: ( () -> Void)?
    private var sendFailure: ((String) -> Void)?
    var printerIdentifier: String?
    var updateLoadingStatusClosure: (() -> Void)?
    var state: MWUsbPrinterState = .NONE{
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    
    private override init() {
        super.init()
    }
    
    //MARK: - Support Functions
    
    func getFoundDevices() -> [restaurant_printer_class] {
        guard let printerIdentifier = printerIdentifier else { return [] }
        return [restaurant_printer_class.intilize(from: printerIdentifier)]
    }
    
    func discoverPrinter() {
        manager?.stopDiscovery()
        
        do {
            try manager = StarDeviceDiscoveryManagerFactory.create(interfaceTypes: interfaceTypeArray)
            
            manager?.discoveryTime = 500
            
            manager?.delegate = self
            
            try manager?.startDiscovery()
        } catch let error {
            SharedManager.shared.printLog("Discovery Error: \(error)")
        }
        
    }
    
    private func connectPrinter(with ip: String, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        var starConnectionSettings = StarConnectionSettings(interfaceType: selectedInterface, identifier: ip)
        if let printerIdentifier = printerIdentifier {
            starConnectionSettings = StarConnectionSettings(interfaceType: selectedInterface, identifier: printerIdentifier)
        }
        
        printer = StarPrinter(starConnectionSettings)
        printer?.printerDelegate = self
        printer?.drawerDelegate = self
        printer?.inputDeviceDelegate = self
        printer?.displayDelegate = self
        startMonitor(success: success, failure: failure)
    }
    
    private func getPrinterStatus(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        if printer == nil {
            failure("Star Printer not found")
        } else {
            guard let printer = printer else { return }
            Task {
                do {
//                    try await printer.open()
//                    defer {
//                        Task {
//                            await printer.close()
//                        }
//                    }
                    
                    let status = try await printer.getStatus()
                    SharedManager.shared.printLog("""
                        Has Error: \(status.hasError)
                        Paper Empty: \(status.paperEmpty)
                        Paper Near Empty: \(status.paperNearEmpty)
                        Cover Open: \(status.coverOpen)
                        Drawer Open Close Signal: \(status.drawerOpenCloseSignal)
                        """)
                    success()
                } catch let error {
                    SharedManager.shared.printLog("Status Error: \(error)")
                    failure(error.localizedDescription)
                }
            }
        }
    }
    
    func createReceiptData(imageData: UIImage?, openDrawer: Bool = false) {
        self.openDrawer = openDrawer
        imageReceipt = imageData
        if imageData != nil {
             var size : CGSize = imageReceipt!.size
             let width: CGFloat = 580
             let ratio =  size.width /  size.height
             let newHeight = width / ratio
             size.width = width
             size.height = newHeight
            imageReceipt = imageReceipt?.ResizeImage(targetSize:size)
         }
    }
    
    func sendReceipt() {
        guard let imageReceipt = self.imageReceipt else {
            sendFailure?("Receipt is NULL ")
            return
        }
        let size: CGSize = imageReceipt.size
        let builder = StarXpandCommand.StarXpandCommandBuilder()
        if openDrawer {
            _ = builder.addDocument(StarXpandCommand.DocumentBuilder()
                .addDrawer(StarXpandCommand.DrawerBuilder()
                    .actionOpen(StarXpandCommand.Drawer.OpenParameter())
                )
                .addPrinter(StarXpandCommand.PrinterBuilder()
                    .actionPrintImage(StarXpandCommand.Printer.ImageParameter(image: imageReceipt, width: Int(size.width)))
                    .styleInternationalCharacter(.usa)
                    .styleCharacterSpace(0)
                    .styleAlignment(.center)
                    .actionFeedLine(1)
                    .actionCut(StarXpandCommand.Printer.CutType.partial)
                )
            )
        } else {
            _ = builder.addDocument(StarXpandCommand.DocumentBuilder()
                .addPrinter(StarXpandCommand.PrinterBuilder()
                    .actionPrintImage(StarXpandCommand.Printer.ImageParameter(image: imageReceipt, width: Int(size.width)))
                    .styleInternationalCharacter(.usa)
                    .styleCharacterSpace(0)
                    .styleAlignment(.center)
                    .actionFeedLine(1)
                    .actionCut(StarXpandCommand.Printer.CutType.partial)
                )
            )
        }
        
        let command = builder.getCommands()
        
        Task {
            do {
//                await printer?.close()
//                try await printer?.open()
//                defer {
//                    Task {
//                        await printer?.close()
//                    }
//                }
                
                try await printer?.print(command: command)
                sendSuccess?()
                SharedManager.shared.printLog("Print Success")
            } catch let error {
                SharedManager.shared.printLog("Print Error: \(error)")
                sendFailure?(error.localizedDescription)
            }
        }
    }
    
    private func startMonitor(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        Task {
            do {
                try await self.printer?.open()
                success()
                SharedManager.shared.printLog("star connection success")
            } catch let error {
                SharedManager.shared.printLog("Star Error: \(error)")
                failure(error.localizedDescription)
                await self.printer?.close()
            }
        }
    }
    
    private func stopMonitoring() {
        Task {
            await self.printer?.close()
        }
    }
    
    //MARK: - Protocols Functions
    func manager(_ manager: StarDeviceDiscoveryManager, didFind printer: StarPrinter) {
        DispatchQueue.main.async {
            switch printer.connectionSettings.interfaceType {
            case .usb:
                self.printerIdentifier = printer.connectionSettings.identifier
            default:
                break
            }
        }
        SharedManager.shared.printLog("Found printer: \(printer.connectionSettings.identifier).")
    }
    
    func managerDidFinishDiscovery(_ manager: StarDeviceDiscoveryManager) {
        SharedManager.shared.printLog("Discovery finished.")
    }
    
    func printerIsReady(_ printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Printer: Ready")
    }
    
    func printerDidHaveError(_ printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Printer: Error")
    }
    
    func printerIsPaperReady(_ printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Printer: Paper Ready")
    }
    
    func printerIsPaperNearEmpty(_ printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Printer: Paper Near Empty")
    }
    
    func printerIsPaperEmpty(_ printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Printer: Paper Empty")
    }
    
    func printerIsCoverOpen(_ printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Printer: Cover Opened")
    }
    
    func printerIsCoverClose(_ printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Printer: Cover Closed")
    }
    
    func printer(_ printer: StarIO10.StarPrinter, communicationErrorDidOccur error: any Error) {
        SharedManager.shared.printLog("Printer: Communication Error \"\(error)\"")
       
    }
    
    func drawer(printer: StarIO10.StarPrinter, communicationErrorDidOccur error: any Error) {
        SharedManager.shared.printLog("Drawer: Communication Error \"\(error)\"")
    }
    
    func drawer(printer: StarIO10.StarPrinter, didSwitch openCloseSignal: Bool) {
        SharedManager.shared.printLog("Drawer: Open Close Signal Switched: \(openCloseSignal)")
    }
    
    func inputDevice(printer: StarIO10.StarPrinter, communicationErrorDidOccur error: any Error) {
        SharedManager.shared.printLog("Input Device: Communication Error \"\(error)\"")
    }
    
    func inputDeviceDidConnect(printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Input Device: Connected")
    }
    
    func inputDeviceDidDisconnect(printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Input Device: Disconnected")
    }
    
    func inputDevice(printer: StarIO10.StarPrinter, didReceive data: Data) {
        SharedManager.shared.printLog("Input Device: DataReceived \(NSData(data: data))")
    }
    
    func display(printer: StarIO10.StarPrinter, communicationErrorDidOccur error: any Error) {
        SharedManager.shared.printLog("Display: Communication Error \"\(error)\"")
    }
    
    func displayDidConnect(printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Display: Connected")
    }
    
    func displayDidDisconnect(printer: StarIO10.StarPrinter) {
        SharedManager.shared.printLog("Display: Disconnected")
    }
    
}

extension MWUsbPrinterInteractor: MWPrinterSDKProtocol {
    func connect(with ip: String, success: @escaping () -> Void, failure: @escaping (String) -> Void, receiveData: @escaping (Data?) -> Void) {
        if ip.isEmpty {
            discoverPrinter()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.connectPrinter(with: ip, success: success, failure: failure)
        }
    }
    
    func statusPrinter(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        getPrinterStatus(success: success, failure: failure)
    }
    
    func startPrint(image: UIImage?, openDrawer: Bool, sendFailure: ((String) -> Void)?) {
        createReceiptData(imageData: image, openDrawer: openDrawer)
    }
    
    func handlerSendToPrinter(sendSuccess: @escaping () -> Void, sendFailure: @escaping (String) -> Void, sendProgressUpdate: ((Double?) -> Void)?, receiveData: ((Data?) -> Void)?, printSuccess: @escaping () -> Void) {
        self.sendSuccess = sendSuccess
        self.sendFailure = sendFailure

        sendReceipt()
    }
    
    func disConnect() {
        self.imageReceipt = nil
        self.openDrawer = false
        self.sendFailure = nil
        self.sendSuccess = nil
        stopMonitoring()
    }
    
    func openDrawer(completeHandler: @escaping (Bool) -> Void) {
        guard let printer = self.printer else{return}
        
    }
    
    
}

extension restaurant_printer_class {
    static func intilize(from usbPort: String ) -> restaurant_printer_class{
        var starPrinter = restaurant_printer_class(fromDictionary: [:])
        starPrinter.name = "Star"
        starPrinter.printer_ip = usbPort
        return starPrinter
    }
}
