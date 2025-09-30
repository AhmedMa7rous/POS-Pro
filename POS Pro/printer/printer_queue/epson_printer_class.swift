//
//  Epos2Class.swift
//  pos
//
//  Created by khaled on 7/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation
import UIKit

enum job_printer_type {
    case txt , image
}
class job_printer
{
    var type:job_printer_type?
    var image:UIImage?
    var openDeawer:Bool = false
    
    var header :String = ""
    var items :String = ""
    var total :String = ""
    var footer :String = ""
    var html :String = ""
    
    var is_printed:Bool = false
    var try_print:Int = 0
    var time:Int64 = 0
    
    var order_id:Int = 0
    var row_type : rowType?
    var error :String = ""
    deinit {
       SharedManager.shared.printLog("======job_printer==deinit====")
         header  = ""
         items  = ""
         total  = ""
         footer  = ""
         html  = ""
         error  = ""
    }


}

protocol epson_printer_delegate {
    func queue_done(for IP:String,with id:Int)
    
}
 
class epson_printer_class:NSObject ,Epos2PtrReceiveDelegate ,Epos2PtrStatusChangeDelegate
{
    
    enum printer_state {
        case none
        case initializePrinter
        case printingNow
        case readyToPrint
        func desc() -> String{
            return "\(self)"
        }

   
    }
    
    
    var delegate:epson_printer_delegate?
    
    var is_printer_online:Bool = false
    
    var printer: Epos2Printer?
    var valuePrinterSeries: Epos2PrinterSeries
    var valuePrinterModel: Epos2ModelLang
    var state:printer_state = .none
//    var  PrintingNow :Bool? = false
    
    
    var  printer_id:Int = 0
    var IP:String?
    var printer_name:String?
    var arr_job:[job_printer] = []
    var  index_job:Int = 0
    
    var current_job:job_printer?
    var printer_log:printer_log_class?
    
    var tag:String = ""
    
    //    var timer:Timer?
    
    init(IP:String?,printer_name:String = "" ,printer_id:Int = 0)
    {
     
        self.printer_id = printer_id
        self.IP = IP
        self.printer_name = printer_name
        self.valuePrinterSeries = EPOS2_TM_T20
        self.valuePrinterModel = EPOS2_MODEL_ANK
        
        //        Epos2Log.setLogSettings(EPOS2_PERIOD_PERMANENT.rawValue, output: EPOS2_OUTPUT_STORAGE.rawValue, ipAddress:  self.IP , port: 0, logSize: 50, logLevel: EPOS2_LOGLEVEL_LOW.rawValue)
        let result = Epos2Log.setLogSettings(EPOS2_PERIOD_TEMPORARY.rawValue, output: EPOS2_OUTPUT_STORAGE.rawValue, ipAddress:nil, port:0, logSize:1, logLevel:EPOS2_LOGLEVEL_LOW.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
           SharedManager.shared.printLog("Can't set Epos2Log.setLogSettings")
        }
        
        
        
    }
    func setJobArrayWith(_ jobs:[job_printer]){
        self.arr_job.removeAll()
        self.arr_job.append(contentsOf: jobs)
    }
  
    func reset() {
         delegate = nil
         is_printer_online = false
         printer = nil
//         valuePrinterSeries =
//         valuePrinterModel =
         state = .none
    //    var  PrintingNow :Bool? = false
        
        
          printer_id = 0
         IP = nil
         printer_name = nil
         arr_job = []
          index_job = 0
         current_job = nil
         printer_log = nil
         tag = ""
        
    }
  
 
    

    
}


