//
//  pos_insurance_class.swift
//  pos
//
//  Created by M-Wageh on 26/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

class InsuranceOrderBuilder {
    private var currentOrder:pos_order_class?
    private var accountJournalList:[account_journal_class]?
    static let shared = InsuranceOrderBuilder()
    struct Config {
         var currentOrder:pos_order_class?
         var accountJournalList:[account_journal_class]?
        }
    func setup(_ config:Config){
        guard let currentOrder = config.currentOrder,  let accountJournalList = config.accountJournalList else { fatalError("Error - you must call setup before accessing InsuranceOrderBuilder.shared")
               }
        self.currentOrder = currentOrder
        self.accountJournalList = accountJournalList
    }
    private init() {
       
    }
    func reset(){
        currentOrder = nil
        accountJournalList = nil
    }
    func getInsuranceAsNewOrder() -> pos_order_class?{
        guard let currentOrder = self.currentOrder,let accountJournalList = self.accountJournalList else{return nil}
        if !currentOrder.containeInsuranceLines()
        {return nil}
        let order_new = pos_order_helper_class.creatNewOrder()
        if let _ = order_new.id{
            
            order_new.partner_id = currentOrder.partner_id
            order_new.customer = currentOrder.customer
            order_new.delivery_type_id = currentOrder.delivery_type_id
            order_new.delivery_type_reference = currentOrder.delivery_type_reference
            order_new.table_id = currentOrder.table_id
            order_new.table_name = currentOrder.table_name
            order_new.driver_id = currentOrder.driver_id

            splitLines(for:currentOrder, and:order_new)
            if order_new.pos_order_lines.count <= 0 {
                return nil
            }
            order_new.save(write_info: true, write_date: true, updated_session_status: .insurance_order,re_calc: true )
            
            splitBankJournal(for:currentOrder , and:order_new,with: accountJournalList )

            order_new.is_closed = true
            order_new.amount_paid = order_new.amount_total
            order_new.save(re_calc: true )

            currentOrder.save(re_calc: true )
            if let order_id = currentOrder.id, let insurance_id = order_new.id{
                pos_insurance_order_class.saveWith(order_id:order_id, insurance_id:insurance_id)
            }
            self.reset()
            return order_new
        }
        self.reset()
        return nil
    }
    private func getAccountJournal(for currentOrder:pos_order_class , and splitOrder:pos_order_class,with accountJournalList:[account_journal_class] ) -> ([account_journal_class],[account_journal_class]){
         var account_journal_order:account_journal_class? = nil
         var account_journal_split:account_journal_class? = nil

         if let account_journal = accountJournalList.first {
             account_journal_order =  account_journal_class(fromDictionary: account_journal.toDictionary())
             account_journal_split =  account_journal_class(fromDictionary: account_journal.toDictionary())
             
             account_journal_split?.changes = 0
             account_journal_split?.due = splitOrder.amount_total
             account_journal_split?.tendered = "\(splitOrder.amount_total)"
             
             account_journal_order?.changes = account_journal.changes
             account_journal_order?.due = (account_journal.due ) - (account_journal_split?.due ?? 0)
             /**
                   
                [Tendered] may be account_journal.tendered = zero
              */
             var tenderJournal = Double(account_journal.tendered ) ?? 0
             if tenderJournal <= 0 {
                 tenderJournal = account_journal.due
             }
             let tenderedDouble = abs(tenderJournal - (Double(account_journal_split?.tendered ?? "0") ?? 0))
             account_journal_order?.tendered =  "\(tenderedDouble.rounded_app())"
         }
         if let account_journal_split = account_journal_split,let account_journal_order = account_journal_order {
            return ([account_journal_order],[account_journal_split])
         }
         return ([],[])

     }
    private func splitBankJournal(for currentOrder:pos_order_class , and splitOrder:pos_order_class,with accountJournalList:[account_journal_class] ){
        let account_journal = getAccountJournal(for:currentOrder , and :splitOrder, with :accountJournalList  )
       
        splitOrder.list_account_journal.removeAll()
        splitOrder.list_account_journal = account_journal.1
       
       currentOrder.list_account_journal.removeAll()
       currentOrder.list_account_journal = account_journal.0
       
        splitOrder.save_bankStatement()
       currentOrder.save_bankStatement()
    }
    private  func splitLines(for currentOrder:pos_order_class, and splitOrder:pos_order_class) {
        var insurancesLines:[pos_order_line_class] = []
        let order_id = splitOrder.id!
        // MARK: - LOOP  insurance Lines
            if let currentOrderUID = currentOrder.uid {
                let ordersListOpetions = ordersListOpetions()
                ordersListOpetions.parent_product = true
                ordersListOpetions.get_lines_void_from_ui = true
                if let currentOrderSaved = pos_order_class.get(uid: currentOrderUID,options_order: ordersListOpetions){
                    let insuranceLines =  currentOrderSaved.pos_order_lines.filter({$0.isInsuranceLine() && !($0.is_void ?? false)})
                    insuranceLines.forEach { insuranceLine in
                        let splitInsuranceLine =  self.getNewLineOrder(from:insuranceLine,with: order_id)
                        SharedManager.shared.printLog("splitInsuranceLine qty 1= \(splitInsuranceLine.qty)")
                        splitInsuranceLine.printed = .none
                        for (index,productLine) in currentOrderSaved.pos_order_lines.enumerated(){
                            if productLine.product_id == splitInsuranceLine.product_id {
                           
//                        if let index =  currentOrderSaved.pos_order_lines.firstIndex(where: {$0.product_id == splitInsuranceLine.product_id}) {
                            
                            var last_line = currentOrderSaved.pos_order_lines[index]
                            SharedManager.shared.printLog(last_line.qty)
                            
                            splitInsuranceLine.qty = last_line.qty
                            splitInsuranceLine.last_qty = 0
                            
                            SharedManager.shared.printLog("last_line qty 1= \(last_line.qty)")
                            last_line = self.updateCurrentOrder(from: insuranceLine, last_line: last_line)
                            SharedManager.shared.printLog("last_line qty 2= \(last_line.qty)")
                            
                            last_line.price_unit = -1 * (last_line.price_unit ?? 0)
                            last_line.price_subtotal =  -1 * (last_line.price_subtotal ?? 0)
                            last_line.price_subtotal_incl =  -1 * (last_line.price_subtotal_incl ?? 0)
                            SharedManager.shared.printLog("last_line qty 3= \(last_line.qty) === last_line price_unit 3= \(last_line.price_unit) === last_line price_subtotal 3= \(last_line.price_subtotal) === last_line price_subtotal_incl 3= \(last_line.price_subtotal_incl)")
                            //MARK: - CRASH : - with setting hid void before
                            currentOrder.pos_order_lines[index] = last_line
                            //                        currentOrder.save(re_calc: true)
                        }
                    }
                        SharedManager.shared.printLog("splitInsuranceLine qty 2= \(splitInsuranceLine.qty)")

                    insurancesLines.append(splitInsuranceLine)
                }
            }
        }
        splitOrder.pos_order_lines.append(contentsOf: insurancesLines)
    }
    private func getNewLineOrder(from splitLine: pos_order_line_class, with id:Int) -> pos_order_line_class{
        let new_line = pos_order_line_class(fromDictionary: splitLine.toDictionary())
        new_line.id = 0
        new_line.void_status =  void_status_enum.none
        new_line.is_void = false
        new_line.order_id = id
        new_line.write_info = true
        new_line.printed = .none
        new_line.pos_multi_session_write_date = ""
        new_line.last_qty = 0
        new_line.qty = splitLine.qty
        if splitLine.selected_products_in_combo.count > 0 {
            for p in splitLine.selected_products_in_combo
            {
                let compo_line = pos_order_line_class(fromDictionary: p.toDictionary())
                compo_line.id = 0
                compo_line.order_id = id
                compo_line.parent_line_id = 0
                compo_line.qty = splitLine.qty
                compo_line.update_values()
                new_line.selected_products_in_combo.append(compo_line)
                
            }
        }
        new_line.update_values()
        return new_line
    }
    private func updateCurrentOrder(from splitLine: pos_order_line_class, last_line:pos_order_line_class)-> pos_order_line_class{
        let diff_qty = splitLine.qty - splitLine.qty
        if diff_qty == 0
        {
            last_line.void_status = .insurance_order
            last_line.is_void = true
        }
        last_line.qty = diff_qty
        if last_line.selected_products_in_combo.count > 0 {
            for p in last_line.selected_products_in_combo
            {
                p.qty = p.qty - splitLine.qty
                if p.qty < 0
                {
                    p.qty = 1
                }
                p.update_values()
            }
        }
        last_line.update_values()
        return last_line
    }
}


extension restaurant_printer_class {
    static  func get(printer_type:String) -> restaurant_printer_class? {
        var cls = restaurant_printer_class(fromDictionary: [:])
        let row:[String:Any]?   = cls.dbClass!.get_row(whereSql: "where printer_type = '\(printer_type)'") ?? [:]
        if let row = row
        {
            cls = restaurant_printer_class(fromDictionary: row)
            return cls
        }
        return nil
        
    }
    @discardableResult static func installInsurancePrinter2()  -> restaurant_printer_class?{
        let product_categories_ids = pos_category_class.getAll().map({ ($0["id"] as? Int) }).compactMap({$0})
        if product_categories_ids.count == 0 {
            return nil
        }
        var insurance_printer = restaurant_printer_class(fromDictionary: [:])
        
        if let ins_printer =  restaurant_printer_class.get(printer_type:"insurance") {
            insurance_printer = ins_printer
        }
        let setting = settingClass.getSetting()
        let printer_ip = setting.ip
        let printer_name = setting.name ?? "insurance_printer"
        if (printer_ip.isEmpty){
            return nil
        }
        //pos_category_class
        let order_types = delivery_type_class.getAll().map({ ($0["id"] as? Int) }).compactMap({$0})
        
        insurance_printer.name = printer_name
        
        if order_types.count > 0{
            insurance_printer.order_type_ids = order_types
        }
        
        insurance_printer.company_id = SharedManager.shared.posConfig().company_id ?? 0
        insurance_printer.printer_type = "insurance"
        insurance_printer.proxy_ip = printer_ip
        insurance_printer.printer_ip = printer_ip
        insurance_printer.epson_printer_ip = printer_ip
        insurance_printer.product_categories_ids = product_categories_ids
        insurance_printer.save()
        
        return insurance_printer
    }
    static func getInsurancePrinter() -> restaurant_printer_class?{
        if let ins_printer =  restaurant_printer_class.get(printer_type:"insurance") {
            return ins_printer
        }
        return restaurant_printer_class.installInsurancePrinter2()
    }
    
}
extension pos_order_line_class{
    func isInsuranceLine() -> Bool{
       return self.product.insurance_product
    }
}
extension pos_order_class{
    private func validationInsuranceOrder() -> (Bool,String){
        if containeInsuranceLines() {
            return ((self.customer != nil) ,"You Must enter Customer as your order contains insurance products".arabic("يجب عليك إدخال العميل لأن طلبك يحتوي على منتجات تأمين"))
        }
        return (true, "")
    }
    func containeInsuranceLines()->Bool{
        if self.pos_order_lines.count > 0 {
            return self.pos_order_lines.filter({$0.isInsuranceLine() && $0.is_void == false}).count > 0
        }
        return false
    }
    func isOrderTypeRequireCustomer()->Bool{
        self.orderType?.require_customer ?? false
    }
    func isOrderTypeRequireDriver()->Bool{
        self.orderType?.required_driver ?? false
    }
   private func validationOrderTypeRequireCustomer() -> (Bool,String){
            if isOrderTypeRequireCustomer() {
                return ((self.customer != nil) ,"You Must enter Customer as your order type require that".arabic("يجب عليك إدخال العميل لأن نوع طلبك يتطلب ذلك   "))
            }
        return (true, "")
    }
    private func validationOrderTypeRequireDriver() -> (Bool,String){
             if isOrderTypeRequireDriver() {
                 return ((self.driver != nil) ,"You Must enter Driver as your order type require that".arabic("يجب عليك إدخال السائق لأن نوع طلبك يتطلب ذلك   "))
             }
         return (true, "")
     }
    func validationSelectCustomer(forSentToKitchen:Bool = false) -> (Bool,String){
        if self.customer == nil {
            let isSupportZtka = SharedManager.shared.posConfig().isSupportEvoice()
            let validateInsuranceOrder = self.validationInsuranceOrder()
            let validateRequireCustomer = self.validationOrderTypeRequireCustomer()
            if !forSentToKitchen {
            if !validateInsuranceOrder.0 {
                return validateInsuranceOrder
            }
            }
            if !validateRequireCustomer.0 {
                return validateRequireCustomer
            }
            if isSupportZtka {
                // return ((self.customer != nil) ,"You Must enter Customer as zatca require that".arabic("يجب عليك إدخال العميل لأن ه هيئه الذكاه والدخل  يتطلب ذلك   "))
            }
        }
        return (true, "")

    }
    func validationSelectDriver(forSentToKitchen:Bool = false) -> (Bool,String){
        if self.driver == nil {
            let validateRequireDriver = self.validationOrderTypeRequireDriver()
            if !validateRequireDriver.0 {
                return validateRequireDriver
            }
        }
        return (true, "")

    }

}

