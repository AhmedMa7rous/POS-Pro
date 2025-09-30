//
//  epson_queue_class.swift
//  pos
//
//  Created by Khaled on 8/30/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

class epson_queue_class:epson_printer_delegate
{
    
    private let concurrentPrintQueue =
      DispatchQueue(
        label: "rabeh.pos.printQueue",
        attributes: .concurrent)
    
    
    var index_run = 0
    var is_run = false
    
    var all_ips:[Int] = []
    var current_print:epson_printer_class?
    var lst_printers: [[String:Any]] = []
    
    
    func stop()
    {
        is_run = false
    }
    
    func add_job_printer(id:Int,IP:String,printer_name:String,printer_type:String = "",order:pos_order_class,print_items_only:Bool = false,openDeawer:Bool = false,index:Int? = nil,master:Bool) {
        //MARK:- Create Job
        let formater = runner_print_class()
        formater.order = order
        //                formater.printer_info = printer_info
        var job:job_printer?
        if print_items_only
        {
            if !printer_type.isEmpty{
                job = formater.printOrder_items_only_html(openDeawer: openDeawer,printerName:printer_name,printer_type:printer_type )

            }else{
                job = formater.printOrder_items_only_html(openDeawer: openDeawer,printerName:printer_name )

            }
        }
        else
        {
             job = formater.print_order(openDeawer: openDeawer)
        }
        
        if let printer_epson =  SharedManager.shared.printers_pson_print[id] {
            if let job = job {
                job.order_id = order.id ?? 0
                if id == 0 {
                    printer_epson.addToQueue(job: job ,index:index)

                }else{
                    printer_epson.addToQueue(job: job ,index:nil)
                }
            }

        }else{
            let newPrinterForQueue =  epson_printer_class(IP: IP,printer_name: printer_name,printer_id: id)
            if let job = job {
                job.order_id = order.id ?? 0
                if id == 0 {
                    newPrinterForQueue.addToQueue(job: job ,index:index)

                }else{
                    newPrinterForQueue.addToQueue(job: job ,index:nil)
                }
            }
            
            SharedManager.shared.printers_pson_print[id] = newPrinterForQueue
        }
        
     
        
        
    }
    
    func run()
    {
        if  SharedManager.shared.epson_queue.is_run
        {
            return
        }
        
       lst_printers = restaurant_printer_class.getAll()
//        DispatchQueue.global(qos: .background).async(execute: {
        concurrentPrintQueue.async  {
            self.next_qeue()
        }
        
 //        }
//        )
        
        
        
    }
    
    func next_qeue()
    {
//        DispatchQueue.global(qos:DispatchQoS.QoSClass.default).async(execute: {
            
        self.all_ips = Array( SharedManager.shared.printers_pson_print.keys)
      
 
            if self.lst_printers.count > 0
            {
                if self.master_have_jobs()
                {
//                    let master_ip = settingClass.getSetting().ip

                    self.all_ips.removeAll { $0 == 0 }

                    self.all_ips.insert(0, at: 0)
                    self.index_run = 0
                }
            }

             
            if  self.all_ips.count > 0
            {
                let printerID = self.all_ips.first!
                self.run_print(printerID)
            }
            else
            {
                if self.if_job_exist_in_qeue()
                {
                    self.index_run = 0
                    self.next_qeue()
                }
                else
                {
                    if printer_error_class.reTryToPrintIsAvaliable(with: true)  {
                        self.index_run = 0
                        self.next_qeue()
                    }else{
                        self.index_run = 0
                        SharedManager.shared.epson_queue.is_run = false
                        printer_error_class.currentReTryPrintCount = 0
                    }
                }
                
            }
            
//        })
        
    }
    
    func run_print(_ printerID:Int)
    {
        if let printerInQueue = SharedManager.shared.printers_pson_print[printerID]{
        current_print = printerInQueue
        current_print?.delegate = self
        
        //        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            concurrentPrintQueue.async {
                self.current_print?.runPrinterQueue()
            }
        //        })
            if  SharedManager.shared.printers_pson_print[printerID] != nil {
                SharedManager.shared.epson_queue.is_run = true
            }else{
                SharedManager.shared.epson_queue.is_run = false
//                if arr_job.count == 0 {
//        //            PrintingNow = false
//                    self.state = .none
//                   SharedManager.shared.printLog("printer_Queue(\(IP ?? ""):" ,"no job to print ...")
//                    self.delegate?.queue_done(for:self.IP!,with:self.printer_id)
//                    return
//                }
//                self.index_run += 1
//                self.next_qeue()
            }
        }else{
            SharedManager.shared.epson_queue.is_run = false
            self.index_run += 1
            self.next_qeue()
        }
    }
    
    func queue_done(for IP:String,with id:Int)
    {
        SharedManager.shared.printers_pson_print[id]?.reset()
        SharedManager.shared.printers_pson_print[id] = nil
        self.index_run += 1
        self.next_qeue()
//        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(500)) {
//            self.index_run += 1
//            self.next_qeue()
//        }
    }
    
    func master_have_jobs() -> Bool
    {
//        let ip = settingClass.getSetting().ip
        let cls = SharedManager.shared.printers_pson_print[0]
        if cls == nil
        {
            return false
        }
        
        if (cls?.arr_job.count ?? 0)! > 0
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func if_job_exist_in_qeue() -> Bool
    {
        for (_,value) in SharedManager.shared.printers_pson_print
        {
            if value.arr_job.count > 0
            {
                return true
            }
        }
        
        return false
    }
    
    func get_numbers_inQueue() -> Int
    {
        var count = 0
        for (_,value) in SharedManager.shared.printers_pson_print
        {
             count += value.arr_job.count
        }
        
            return count
        
    }
    
}
