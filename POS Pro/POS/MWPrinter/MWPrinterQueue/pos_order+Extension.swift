//
//  pos_order+Extension.swift
//  pos
//
//  Created by M-Wageh on 06/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum Notes_Order_Types{
    case CHANGE_TABLE
    func getMessage(order_no:Int, from:String,to:String) -> (eng:String,arb:String){
        switch self{
        case .CHANGE_TABLE:
            let fromBold = "<b>\(from)</b>"
            let toBold = "<b>\(to)</b> "
            let noBold = "<b>\(order_no)</b>"

            let eng_msg = "Table order #\(noBold) had changed from \(fromBold) to \(toBold)"
            var arb_msg =  " تم تغير طاوله الطلب رقم"
            arb_msg += "\(noBold)"
            arb_msg += " من "
            arb_msg += " \(toBold) "
            arb_msg += " إلي "
            arb_msg += " \(fromBold) "


            let messages = [eng_msg," "," ",arb_msg]
            return (eng_msg,arb_msg) //messages.joined(separator: "<br\\> <br\\>") //eng_msg.arabic(arb_msg) //
        }
    }
}
extension pos_order_class{
    func noPrinterFound(fileType:rowType){
        let wifiName =  WiFi.shared.getWiFiName()
        let printer_log = printer_log_class(fromDictionary: [:])
        printer_log.id = 0
        printer_log.ip =  ""
        printer_log.printer_name = ""
        printer_log.start_at = printer_log.get_date_now_formate_datebase()
        printer_log.order_id = self.id ?? 0
        printer_log.row_type =  fileType
        printer_log.sequence = pos_order_helper_class.get_print_count(order_id:  self.id ?? 0)
        printer_log.html = ""
        printer_log.wifi_ssid = wifiName
        printer_log.add_message("Run printer Receipt Sequence")
        printer_log.add_message("Can't run printer Receipt Sequence as no printer Found")
        printer_log.save()
        printer_message_class.show(" printer_Queue empty ip: error No printer Found" ,false)


    }
    fileprivate func getNeedOpenDrawer() -> Bool{
        var openDrawer = true
        let setting = SharedManager.shared.appSetting()
        if setting.open_drawer_only_with_cash_payment_method == true
        {
        let is_paid_cash = self.list_account_journal.filter({$0.code == "CSH1"})
            if is_paid_cash.count == 0
            {
                openDrawer = false
            }
        }
        
        if self.amount_total == 0
        {
            openDrawer = false
        }
        return openDrawer
    }
    func printReturnOrderByMWqueue(){
        creatBillQueuePrinter(.return_order,openDrawer:getNeedOpenDrawer())
        self.creatKDSQueuePrinter(.return_order)

        pos_order_helper_class.increment_print_count(order_id: self.id!)

    }
    func printOrderByMWqueue(){
        creatBillQueuePrinter(.order,openDrawer:getNeedOpenDrawer())
        let posConfig = SharedManager.shared.posConfig()
        let isNotSamePOS = self.write_pos_id != posConfig.id
        if SharedManager.shared.mwIPnetwork && posConfig.isMasterTCP() && isNotSamePOS{
            MWRunQueuePrinter.shared.startMWQueue()

        }else{
            creatKDSQueuePrinter(.kds)
        }
        pos_order_helper_class.increment_print_count(order_id: self.id!)

    }
    func creatInsuranceQueuePrinter(){
        if SharedManager.shared.cannotPrintBill()  {
           return
        }
        creatInsuranceQueuePrinter(openDrawer:false)
        pos_order_helper_class.increment_print_count(order_id: self.id!)
    }
    func creatKDSQueuePrinter(_ fileType:rowType,isFromIp:Bool = false,isResend:Bool = false){
        if SharedManager.shared.cannotPrintKDS()  {
           return
        }
        let kdsPrinters = restaurant_printer_class.get(printer_type:DEVICES_TYPES_ENUM.KDS_PRINTER)
        if kdsPrinters.count <= 0 {
           // self.noPrinterFound(fileType: fileType)
        }else{
        for kdsPrinter in kdsPrinters {
            guard let orderTemp = self.getOrderKDS(for:kdsPrinter) else {
                if SharedManager.shared.mwIPnetwork{
                    if let table_id = table_id {
                        if let previous_table_id = previous_table_id {
                            if table_id != previous_table_id {
                               if let nameTable = restaurant_table_class.get(id: table_id )?.name,
                                  let previousNameTable = restaurant_table_class.get(id: previous_table_id )?.name{
                                   let noteMessage = Notes_Order_Types.CHANGE_TABLE.getMessage(order_no: self.sequence_number, from:previousNameTable , to:nameTable )
                                   self.createNote(note:noteMessage.eng,ar_note: noteMessage.arb, for:kdsPrinter )
                               }
                            }
                        }
                    }
                }
                continue
            }
            if let serviceProduct_id = orderTemp.orderType?.service_product_id{
                orderTemp.pos_order_lines.removeAll(where:{$0.product_id == serviceProduct_id} )
            }

            let inVoice = MWInvoiceComposer(order: orderTemp, printerName:kdsPrinter.name,fileType:fileType )
            inVoice.setOptionForKDS(isResend: isResend)
            let inVoiceHTML = inVoice.renderInvoice() ?? "cannot create invoice"
            SharedManager.shared.addToMWPrintersQueue(html: inVoiceHTML,
                                         with: kdsPrinter,
                                         order: orderTemp,
                                                      fileType: fileType, openDeawer: false, queuePriority: .MEDIUM,isFromIp:isFromIp)
            
//            let mwPrintersQueue = MWPrintersQueue(queuePriority: .MEDIUM)
//            let mwQueueForFiles = MWQueueForFiles()
//            let mwFileInQueue = MWFileInQueue(html: inVoiceHTML, restaurantPrinter: kdsPrinter,order:orderTemp,row_type: fileType,  openDrawer: false)
//            mwQueueForFiles.add(mwFileInQueue)
//            mwPrintersQueue.add(mwQueueForFiles)
//            MWRunQueuePrinter.shared.addMWPrintersQueue(mwPrintersQueue)
        }
        }
        
    }
    func creatInsuranceQueuePrinter(_ fileType:rowType = .insurance, openDrawer:Bool){
        let posPrinters = restaurant_printer_class.get(printer_type:DEVICES_TYPES_ENUM.POS_PRINTER)
        let copy_numbers = SharedManager.shared.appSetting().receipt_copy_number
        if posPrinters.count <= 0 {
            self.noPrinterFound(fileType: fileType)
        }else{
        for printerPOS in posPrinters {
            SharedManager.shared.setInsuranceComposer(order:  self)
            let inVoiceHTML =  SharedManager.shared.insuranceComposer?.renderInvoice() ?? "cannot create invoice"
            SharedManager.shared.addToMWPrintersQueue(html: inVoiceHTML,with: printerPOS,
                                                      fileType:fileType, openDeawer: false, queuePriority: .MEDIUM,numberCopies: copy_numbers)
          
        }
        }
    }
    
    func creatBillQueuePrinter(_ fileType:rowType, openDrawer:Bool? = nil){
         if SharedManager.shared.cannotPrintBill()  {
           return
         }
        var open_drawer = openDrawer
        if  openDrawer == nil {
            open_drawer = getNeedOpenDrawer()
        }
        guard let open_drawer = open_drawer else { return  }
        if SharedManager.shared.appSetting().enable_cloud_qr_code{
            if let qrValue = self.getCloudQRCodde(){
               if qrValue.isEmpty{
                    pos_order_qr_code_class.save(from: self,fileType:fileType,openDrawer: open_drawer )
                    return
               }else{
                   
               }
            }else{
                pos_order_qr_code_class.save(from: self,fileType:fileType,openDrawer: open_drawer )
                return
            }
        }
        let posPrinters = restaurant_printer_class.get(printer_type:DEVICES_TYPES_ENUM.POS_PRINTER)
        let copy_numbers = SharedManager.shared.appSetting().receipt_copy_number
        if posPrinters.count <= 0 {
            self.noPrinterFound(fileType: fileType)
        }else{
        for printerPOS in posPrinters {
            
            let inVoice = MWInvoiceComposer(order: self, printerName:printerPOS.name,fileType:fileType )
            if fileType == .bill{
                inVoice.setOptionForBill()
            }
            let inVoiceHTML = inVoice.renderInvoice() ?? "cannot create invoice"
            SharedManager.shared.addToMWPrintersQueue(html: inVoiceHTML,
                                                      with: printerPOS,
                                                      order:self,
                                                      fileType:fileType,
                                                      openDeawer: open_drawer,
                                                      queuePriority: .MEDIUM,numberCopies: copy_numbers)
            /*
            let mwPrintersQueue = MWPrintersQueue(queuePriority: .HIGH)
            let mwQueueForFiles = MWQueueForFiles()
            let inVoiceHTML = MWInvoiceComposer(order: self, printerName:printerPOS.name ).renderInvoice() ?? "cannot create invoice"
            let mwFileInQueue = MWFileInQueue(html: inVoiceHTML, restaurantPrinter: printerPOS,row_type: fileType, openDrawer: openDrawer)
            let copy_numbers = SharedManager.shared.appSetting().receipt_copy_number
            for _ in 1...copy_numbers{
                mwQueueForFiles.add(mwFileInQueue)
            }
            mwPrintersQueue.add(mwQueueForFiles)
            MWRunQueuePrinter.shared.addMWPrintersQueue(mwPrintersQueue)
             */
        }
        }
    }
    func creatCopyBillQueuePrinter(_ fileType:rowType,hideLogo: Bool,isBill:Bool = false){
        let posPrinters = restaurant_printer_class.get(printer_type:DEVICES_TYPES_ENUM.POS_PRINTER)
        for printerPOS in posPrinters {
            let mwPrintersQueue = MWPrintersQueue(queuePriority: .HIGH)
            let mwQueueForFiles = MWQueueForFiles()
            let inVoice = MWInvoiceComposer(order: self, printerName:printerPOS.name,fileType:fileType)
            if fileType == .order_table{
                inVoice.setOptionForTableView(hidLog:hideLogo )
            }else{
            inVoice.setOptionForHistory(hideLogo: hideLogo, for_insurance: self.containeInsuranceLines() )
            if isBill {
                inVoice.setOptionForBill()
            }
            }
            let inVoiceHTML = inVoice.renderInvoice() ?? "cannot create invoice"
            let mwFileInQueue = MWFileInQueue(html: inVoiceHTML, restaurantPrinter: printerPOS,row_type: fileType, openDrawer: false)
            mwQueueForFiles.add(mwFileInQueue)
            mwPrintersQueue.add(mwQueueForFiles)
            MWRunQueuePrinter.shared.addMWPrintersQueue(mwPrintersQueue,printerIP:printerPOS.printer_ip )
        }
    }
    func createNote(note:String?,ar_note:String?, for selectedPrinter:restaurant_printer_class ){
        if pos_order_lines.count > 0 {
            if var noteTxt = note , !noteTxt.isEmpty{
                let product_order_type_ids = selectedPrinter.get_order_type_ids()
                if product_order_type_ids.count > 0
                {
                    if let delivery_type_id = delivery_type_id {
                        if !product_order_type_ids.contains(delivery_type_id){ return }
                    }else{ return}
                }
                let product_categories_ids = selectedPrinter.get_product_categories_ids()
                if product_categories_ids.count > 0
                {
                    let posCategoriesIDS = pos_order_lines.compactMap({$0.pos_categ_id})
                    let containsCommonElement = posCategoriesIDS.contains { element in product_categories_ids.contains(element) }
                    if !containsCommonElement{  return }
                }
                noteTxt = noteTxt.replacingOccurrences(of: "\n", with:"<br/>")
                var HTMLContent = HTMLTemplateGlobal.shared.getTemplateHtmlContent(.NOTE_PRINTER)
                let datePrint =  "Printed at: " + Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: false)
                
                HTMLContent = HTMLContent.replacingOccurrences(of: "#HEADER_NOTE#", with:"طلب من نقطه البيع")
                HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NAME#", with:SharedManager.shared.posConfig().name ?? "")
                HTMLContent = HTMLContent.replacingOccurrences(of: "#CASHIER_NAME#", with:SharedManager.shared.activeUser().name ?? "")
                HTMLContent = HTMLContent.replacingOccurrences(of: "#NOTE#", with:noteTxt)
                HTMLContent = HTMLContent.replacingOccurrences(of: "#ar_NOTE#", with:ar_note ?? "")
                HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINT_DATE#", with:datePrint)
                var noteHtml = HTMLContent
                noteHtml = noteHtml.replacingOccurrences(of: "#PRINTER_NAME#", with:selectedPrinter.display_name)
                SharedManager.shared.addToMWPrintersQueue(html: noteHtml,
                                                                  with: selectedPrinter,
                                                                  fileType: .note_printer,
                                                                  openDeawer: false, queuePriority: .LOW)
                
            }
        }
    }
    func getInvoiceHTML(_ fileType:rowType,hideLogo: Bool,isResend:Bool = false)->String{
        let inVoice = MWInvoiceComposer(order: self, printerName:"",fileType:fileType)
        if fileType == .bill {
            inVoice.setOptionForBill()
        }
        if fileType == .history {
            inVoice.setOptionForHistory(hideLogo: hideLogo, for_insurance: self.containeInsuranceLines() )
        }
        if fileType == .history_void {
            inVoice.setOptionForHistory( hideLogo: hideLogo, for_insurance: self.containeInsuranceLines(),hideExtraPrice: true )
        }
        if fileType == .kds {
            inVoice.setOptionForKDS(isResend:isResend )
        }
        let inVoiceHTML = inVoice.renderInvoice() ?? "cannot create invoice"
        return inVoiceHTML

    }
    fileprivate func getOrderKDS(for printerQueue:restaurant_printer_class)->pos_order_class?
    {
        if !check_if_order_have_lines_need_to_print(){
            return nil
        }
        let tempOrder = self.copyOrder()
        let product_order_type_ids = printerQueue.get_order_type_ids()
        if product_order_type_ids.count > 0
        {
            if let type_order = self.orderType {
                if !product_order_type_ids.contains(type_order.id)
                {
                    return nil
                }
            }
        }
        
        let product_categories_ids = printerQueue.get_product_categories_ids()
        if product_categories_ids.count > 0
        {
            let products = get_products_toPrint(categories_ids: product_categories_ids )
            if products.count > 0
            {
                tempOrder.pos_order_lines.removeAll()
                tempOrder.pos_order_lines.append(contentsOf: products)
                return tempOrder

            }
        }
        return nil
        
    }
    
    fileprivate func get_products_toPrint(categories_ids:[Int]) -> [pos_order_line_class]
    {
        var list:[pos_order_line_class] = []
        for line in self.pos_order_lines
        {
            if line.isVoidFromUI(){
                if line.void_status == .before_sent_to_kitchen {
                    continue
                }
            }
            let printedStatus = line.getPrintedStatus()
            if (line.qty != line.last_qty || line.is_void == true) && printedStatus != .printed {
                if line.product.pos_categ_id != 0
                {
                    let pos_categ_id = line.product.pos_categ_id  ?? 0
                    let filtered = categories_ids.filter { $0 == pos_categ_id }
                    if filtered.count > 0
                    {
                        list.append(line)
                    }
                }
            }
            
        }
        return list
    }
    fileprivate func check_if_order_have_lines_need_to_print() -> Bool{
        // get non-printed lines
        var linesToPrint = self.pos_order_lines
        if let serviceProduct_id = self.orderType?.service_product_id{
            linesToPrint.removeAll(where: {$0.product_id == serviceProduct_id})
        }
        let  non_printed_lines_arr = linesToPrint.filter {$0.printed != .printed}
        // check if non-printed lines > 0
        if non_printed_lines_arr.count > 0 {
            let same_qty_lines_arr = non_printed_lines_arr.filter {$0.qty == $0.last_qty && $0.is_void == false}
            if same_qty_lines_arr.count == non_printed_lines_arr.count {
                self.pos_order_lines.forEach({ line in
                    line.printed = .printed
                })
                self.save()
                return false
            }
            
        }else{
            if non_printed_lines_arr.count == 0 {
                return false
            }
        }
        return true
    }
}
extension pos_order_line_class {
    func getPrintedStatus() -> ptint_status_enum{
        if SharedManager.shared.mwIPnetwork{
            let sql = "select printed from pos_order_line where uid = '\(self.uid)' "
            let printedStatus:[String:Any] = database_class(connect: .database).get_row(sql: sql) ?? [:]
            
            return ptint_status_enum(rawValue: (printedStatus["printed"] as? Int ?? 0)) ?? self.printed
        }
        return self.printed
    }
}
