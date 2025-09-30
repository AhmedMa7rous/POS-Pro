//
//  Epos2monitorClass.swift
//  pos
//
//  Created by Khaled on 2/27/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class Epos2monitorClass:NSObject ,Epos2PtrStatusChangeDelegate
{
    
    let valuePrinterSeries: Epos2PrinterSeries =  EPOS2_TM_T20
    let valuePrinterModel: Epos2ModelLang = EPOS2_MODEL_ANK
    
    var ip:String?
    var printer: Epos2Printer?
    
    var is_printer_online:Bool = false

    func start(_ip:String?)
    {
   
        self.ip = _ip
      
        
 
        printer = Epos2Printer(printerSeries: valuePrinterSeries.rawValue,
                               lang: valuePrinterModel.rawValue)
        printer!.setStatusChangeEventDelegate(self)

        var result: Int32 = EPOS2_SUCCESS.rawValue

        result = printer!.connect("TCP:" + _ip!, timeout:Int(EPOS2_PARAM_DEFAULT))
        printer?.setInterval(3000)

        result =  printer!.startMonitor()

        if result != EPOS2_SUCCESS.rawValue
        {
            NSLog("printer : %@", "Can't connect.")

        }
        
     
    }
    
    
    func onPtrStatusChange(_ printerObj: Epos2Printer!, eventType: Int32) {
//        let eventStatus = Epos2StatusEvent(rawValue: eventType)

        if(eventType == EPOS2_EVENT_ONLINE.rawValue) {
//            ...starting reconnection...
            NSLog("%@", " printer ONLINE")
            is_printer_online = true
            NotificationCenter.default.post(name: Notification.Name("printer_status"), object: true)
 
        }
        if(eventType == EPOS2_EVENT_POWER_OFF.rawValue) {
//            ...reconnection end...
            NSLog("%@", " printer OFFLINE")
            is_printer_online = false

            NotificationCenter.default.post(name: Notification.Name("printer_status"), object: false)
 

        }
    }
    
}
