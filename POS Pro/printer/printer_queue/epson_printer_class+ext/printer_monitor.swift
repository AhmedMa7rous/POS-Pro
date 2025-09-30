//
//  printer_monitor.swift
//  pos
//
//  Created by Khaled on 2/28/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

extension  epson_printer_class
{
    
    func checkStatusPrinter()
    {
        
        
        if self.printer == nil {
            return
        }
        
        
//        DispatchQueue.global(qos:  .background).async(execute: {
            DispatchQueue.global(qos:  DispatchQoS.QoSClass.default).async(execute: {

            //DispatchQoS.QoSClass.default
            self.printer!.setStatusChangeEventDelegate(self)
            
            var result: Int32 = EPOS2_SUCCESS.rawValue
            
            //            result = self.printer!.connect("TCP:" + self.IP!, timeout:Int(EPOS2_PARAM_DEFAULT))
            result = self.printer!.connect("TCP:" + self.IP!, timeout:Int(60 * 1000))
            
            
            if result == EPOS2_SUCCESS.rawValue
            {
                self.printer!.setInterval(3000)
                
                result =   self.printer?.startMonitor() ?? EPOS2_ERR_ILLEGAL.rawValue
                
                if result != EPOS2_SUCCESS.rawValue
                {
                    NSLog("printer : %@", "Can't connect.")
                    
                    self.is_printer_online = false
                    
                    NotificationCenter.default.post(name: Notification.Name("printer_status"), object: self)
                    
                    self.stop_monitor()
                    
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
                        printer_message_class.show("Check your printer connection." + self.printer_info())
                    }
                }else{
                    self.is_printer_online = true
                    NotificationCenter.default.post(name: Notification.Name("printer_status"), object: self)

                }
            }
            else
            {
                NotificationCenter.default.post(name: Notification.Name("printer_status"), object: self)
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
                    printer_message_class.show("Check your printer connection." + self.printer_info())
                }
            }
        }  )
    }
    
    func stop_monitor()
    {
        if printer == nil
        {
            return
        }
        
        printer!.stopMonitor()
        
        
        printer!.clearCommandBuffer()
        printer!.setReceiveEventDelegate(nil)
        printer!.setStatusChangeEventDelegate(nil)
        
        printer = nil
        self.state = .none
        
    }
    
    func onPtrStatusChange(_ printerObj: Epos2Printer!, eventType: Int32) {
        //        let eventStatus = Epos2StatusEvent(rawValue: eventType)
        
        if(eventType == EPOS2_EVENT_ONLINE.rawValue) {
            //            ...starting reconnection...
            NSLog("%@", " printer ONLINE")
            //            is_printer_online = true
            
            
            NotificationCenter.default.post(name: Notification.Name("printer_status"), object: self)
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(500)) {
                if self.is_printer_online == false{
                    //    printer_message_class.show("Printer ONLINE." + self.printer_info(),true)
                }
                self.is_printer_online = true
            }
            
        }
        if(eventType == EPOS2_EVENT_POWER_OFF.rawValue) {
            //            ...reconnection end...
            NSLog("%@", " printer OFFLINE")
            is_printer_online = false
            
            
            NotificationCenter.default.post(name: Notification.Name("printer_status"), object: self)
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(500)) {
                printer_message_class.show("Printer OFFLINE." + self.printer_info())
                
            }
            //            delegate?.printer_status(online: false)
            
        }
        
        stop_monitor()
        
    }
    
}
