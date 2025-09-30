//
//  queue_printer.swift
//  pos
//
//  Created by Khaled on 2/28/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
enum QUEUE_ENUM{
    case STARTING
    case PRINTING_NOW
    case NO_JOBS
    case NEXT
}
enum QUEUE_ENUM_ERROR{
    case FAIL_STATE_NO_PRINTER_Found
    case FAIL_STATE_PRINTING_NOW
    case FAIL_INITIALIZE_STATE_NONE //initializePrinterObject
    case FAIL_INITIALIZE_PRINTER_NULL //initializePrinterObject

    case FAIL_CREATE_DATA_PRINTER_ADD  //  createReceiptData -> createReceiptData -> result != EPOS2_SUCCESS.rawValue add 
    case FAIL_CREATE_DATA_PRINTER_ADD_PULSE  //createReceiptData -> createReceiptData -> result != EPOS2_SUCCESS.rawValue open drawer
    case FAIL_CREATE_DATA_PRINTER_ADD_CUT //createReceiptData -> createReceiptData -> result != EPOS2_SUCCESS.rawValue addCut
    case FAIL_PRINTER_NULL //  printData -> printer == nil
    case FAIL_PRINTER_CONNECT //  printData -> connectPrinter == false
    case FAIL_STATUS_NUL // printData -> isPrintable -> statusPrinter == nil
    case FAIL_STATUS_CONNECTION // printData -> isPrintable -> status!.connection == EPOS2_FALSE
    case FAIL_STATUS_ONLINE // printData -> isPrintable -> status!.online == EPOS2_FALSE
    case FAIL_SEND_DATA //  printData -> sendData  != EPOS2_SUCCESS.rawValue
    case BEGIN_TRANSACTION

    func get_error_info() -> String {
        switch self {
        case .FAIL_STATE_NO_PRINTER_Found:
            return "Can't run printer Receipt Sequence as no printer Found"
        case .FAIL_STATE_PRINTING_NOW:
            return "Can't run printer Receipt Sequence as state is printingNow"
        case .FAIL_INITIALIZE_STATE_NONE:
            return  "Can't initialize Printer as state is none"
        case .FAIL_INITIALIZE_PRINTER_NULL:
            return  "Can't initialize Printer as printer is null"
        case .FAIL_CREATE_DATA_PRINTER_ADD:
            return "Can't create Receipt Data as can't add image to printer "
        case .FAIL_CREATE_DATA_PRINTER_ADD_PULSE:
            return "Can't create Receipt Data as can't open drawer "
        case .FAIL_CREATE_DATA_PRINTER_ADD_CUT:
            return "Can't create Receipt Data as can't add cut "
        case .FAIL_PRINTER_NULL:
            return  "Can't Print Receipt Data as printer is null"
        case .FAIL_PRINTER_CONNECT:
            return  "Can't Print Receipt Data as printer is not connect"
        case .FAIL_STATUS_NUL:
            return  "Can't Print Receipt Data as Epos2PrinterStatusInfo  is not null"
        case .FAIL_STATUS_CONNECTION:
            return  "Can't Print Receipt Data as Epos2PrinterStatusInfo is Not connected"
        case .FAIL_STATUS_ONLINE:
            return  "Can't Print Receipt Data as Epos2PrinterStatusInfo is Not online"
        case .FAIL_SEND_DATA:
            return  "Can't Print Receipt Data as fail sendData printer"
        case .BEGIN_TRANSACTION:
            return  "Can't Print Receipt Data as fail begin Transaction printer"

            
        }
    }
}
extension  epson_printer_class
{
    public func addToQueue(job:job_printer,index:Int? = nil)
    {
        if index == nil || arr_job.count == 0
        {
            arr_job.append(job)
            
        }
        else
        {
            arr_job.insert(job, at: index!)
        }
        
    }
    
    public  func runPrinterQueue()
    {
//       SharedManager.shared.printLog("DispatchQueue: \(DispatchQueue.currentLabel)")

        self.goRunQueue()

//        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
//            self.goRunQueue()
//        })
   
    }
    
    
    @objc private func goRunQueue()
    {
        
        if self.state == .printingNow
        {
           SharedManager.shared.printLog("printer_Queue(\(IP ?? ""): " + "printer already Printing ...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                
                self.runPrinterQueue()
            })
            
            
            return
        }
        
        
        if arr_job.count == 0 {
//            PrintingNow = false
            self.state = .none
           SharedManager.shared.printLog("printer_Queue(\(IP ?? ""):" + "no job to print ...")
            self.delegate?.queue_done(for:self.IP!,with:self.printer_id)
            return
        }
        
        
        index_job = 0
        
        current_job = arr_job[index_job]
        
       SharedManager.shared.printLog("printer_Queue(\(IP ?? ""): job \(index_job)/\(arr_job.count)"   )
        
        
        //       DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
        let status =    self.runPrinterReceiptSequence()
//        self.handel_print_status(is_ptint: status)
        //          })
        
        
        
        
    }
    
    func handel_print_status(is_ptint:Bool,savePrinterError:Bool = true)
    {
        if self.current_job?.row_type == .test {
            restaurant_printer_class.update(with: is_ptint ? .SUCCESS : .FAIL, for: self.printer_id)
            NotificationCenter.default.post(name: Notification.Name("test_printer_done"), object: nil)
        }
        self.handlePrinterErrorIf(is_ptint,savePrinterError)
        if arr_job.count != 0
        {
            current_job = nil
            arr_job.removeFirst()
           SharedManager.shared.printLog("printer_Queue(\(IP ?? ""): " + "try to print next job")
            if arr_job.count != 0
            {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                
                    self.runPrinterQueue()
               // })
                return
            }
        }
        else
        {
            finalizePrinterObject()
        }
        
       SharedManager.shared.printLog("printer_Queue(\(IP ?? ""): all done" )
       SharedManager.shared.printLog("printer_Queue(\(IP ?? ""): End")
        self.delegate?.queue_done(for:self.IP!,with:self.printer_id)

        
        //         disconnectPrinter()
        //
        //        self.delegate?.queue_done(IP: self.IP!)
        
        
    }
    
    
    func stop(savePrinterError:Bool = true)
    {
        MWHtmlConvertService.shared.resetService()
        printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
        printer_log?.save()
        
        self.state = .readyToPrint
//        PrintingNow = false
        self.handel_print_status(is_ptint: false,savePrinterError:savePrinterError)

    }
    func handlePrinterErrorIf(_ is_ptint:Bool, _ savePrinterError:Bool){
        if !is_ptint{
                if let job = self.current_job{
                    if savePrinterError {
                    var printer_error:printer_error_class?
                        printer_error = printer_error_class(job: job , epson_printer: self,id_lg: printer_log?.id)
                    printer_error?.save()
                    }else{
                        self.remove_error_printer_file()
                    }
            }

           
        }else{
            self.remove_error_printer_file()
        }
    }
    func remove_error_printer_file(){
        let orderID = self.current_job?.order_id ?? 0
        let printerIp = self.IP ?? ""
        let printerName = self.printer_name ?? ""
        DispatchQueue.main.async {
            printer_error_class.deletFile(orderID:"\(orderID)-\(printerIp)-\(printerName)" )
        }
    }
    
    
}
