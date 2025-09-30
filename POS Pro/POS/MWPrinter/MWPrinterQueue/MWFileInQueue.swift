//
//  MWFileInQueue.swift
//  pos
//
//  Created by M-Wageh on 06/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
//MARK: - MWFileInQueue JOB
 class MWFileInQueue {
    var html:String
//    var status:MWQueue_Status
    var restaurantPrinter:restaurant_printer_class?
    var openDrawer:Bool
    var delegate:NextQueueDelegate?
    var order:pos_order_class?
    var row_type : rowType?
    var time:Int64 = 0
    var image:UIImage?
     var printer_error_id:Int?
     var printer_error:printer_error_class?
     var isFromIp:Bool?

     deinit {
         SharedManager.shared.printLog("MWFileInQueue deinit")
     }
     
    init(html:String,
         image:UIImage? = nil,
         restaurantPrinter:restaurant_printer_class,
         order:pos_order_class? = nil,
         row_type : rowType,
         openDrawer:Bool,printer_error_id:Int? = nil,printer_error:printer_error_class? = nil,isFromIp:Bool? = false ) {
        
        self.html = html
        self.openDrawer = openDrawer
        self.restaurantPrinter = restaurantPrinter
        self.row_type = row_type
        self.time = baseClass.getTimeINMS()
        self.order = order
        self.image = image
        self.printer_error_id = printer_error_id
        self.printer_error = printer_error
        self.isFromIp = isFromIp

    }
     
    func deAllocate(){
        SharedManager.shared.printLog("deAllocate MWFileInQueue")

       
        image = nil
         order = nil
         self.html = ""
         delegate = nil
        restaurantPrinter = nil
        row_type = nil
        printer_error_id = nil
        
         
     }
    func start(){
//        SharedManager.shared.printLog("\(restaurantPrinter?.printer_ip)-\(restaurantPrinter?.name)-\(restaurantPrinter?.brand)-\(restaurantPrinter?.model)")
        MWPrinterSDK.shared.initalize(with: self)
        if MWPrinterSDK.shared.mwFileInQueue != nil{
            MWPrinterSDK.shared.runPrinter()
        }else{
            start()
        }
    }
    func stop(with status:MWQueue_Status){
      
        handlePrinterError(with:status )

        if self.row_type == .test {
            if let id = self.restaurantPrinter?.id{
                restaurant_printer_class.update(with: status == .DONE ? .SUCCESS : .FAIL, for: id)
                NotificationCenter.default.post(name: Notification.Name("test_printer_done"), object: nil)
            }
        }
 
        if case MWQueue_Status.DONE = status {
            setPrintedStatusForLines()
        }
        //TODO: - setting app [Enter second for handling print KDS recipt at same printer (default = 0, range 0:4)]
        //check value if greater thtan 0 do sleep with value
        if SharedManager.shared.appSetting().time_sleep_print_queue > 0 {
            Thread.sleep(forTimeInterval: SharedManager.shared.appSetting().time_sleep_print_queue)
        }
        if !SharedManager.shared.appSetting().enable_enhance_printer_cyle {
            delegate?.next()
        }
    }
     func goNext(){
         delegate?.next()
     }
     func setPrintedStatusForLines(){
         if self.row_type == .kds {
             if let tableID = self.order?.table_id {
                 self.order?.previous_table_id = tableID
                 self.order?.updatePreviousTable(with:tableID)
//                 self.order?.save(write_info: false,write_date: false)
             }
             /**
              
              self.order?.pos_order_lines.forEach({ line in
                  if let existLine = pos_order_line_class.get(uid: line.uid){
                      existLine.printed = .printed
                      if  existLine.pos_multi_session_status != .sended_update_to_server{
                          existLine.pos_multi_session_status = .sending_update_to_server
                      }
                      existLine.last_qty = existLine.qty
                      //}
                      existLine.save()

                  }else{
                      line.printed = .printed
                      line.last_qty = line.qty
                      if  line.pos_multi_session_status != .sended_update_to_server{
                          line.pos_multi_session_status = .sending_update_to_server
                      }
                      line.save()

                  }
                 

                  print("line pos_multi_session_status === \(line.pos_multi_session_status)")

              })
              */
             self.order?.pos_order_lines.forEach({ line in
                 line.printed = .printed
                 line.pos_multi_session_status = .sending_update_to_server                 
                 line.last_qty = line.qty
                 if let existLine = pos_order_line_class.get(uid: line.uid ){
                     existLine.printed = .printed
                     existLine.pos_multi_session_status = .sending_update_to_server
                     //if SharedManager.shared.mwIPnetwork {
                     existLine.last_qty = line.qty
                     //}
                     existLine.save()

                 }else{
                     //                 print("line pos_multi_session_status === \(line.pos_multi_session_status)")
                    
                     //}
                     line.save()
                 }
                 print("line pos_multi_session_status === \(line.pos_multi_session_status)")

             })
         }
     }
     func handlePrinterError(with status:MWQueue_Status){
         if let error_id = printer_error_id {
             MWQueue.shared.mwReTryPrintersQueue.async {
                 if status == .FAIL{
                     printer_error_class.setStatus(with: .NONE, for:error_id )
                 }else{
                     if status == .DONE{
                         self.setPrintedStatusForLines()
                         if let errorObject  = printer_error_class.getPrinterWith(idError: error_id){
                             errorObject.clearErrorFromDB()
                             errorObject.deletImage()
                         }
                     }
                 }
             }
         }
     }
     func getNextFile() -> MWFileInQueue?{
         return self.delegate?.getNextItem()
     }
}
