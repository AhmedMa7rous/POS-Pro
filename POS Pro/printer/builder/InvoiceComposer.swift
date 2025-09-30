//
//  InvoiceComposer.swift
//  pos
//
//  Created by  Mahmoud Wageh on 3/30/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import Foundation
import UIKit


class CustomPrintPageRenderer: UIPrintPageRenderer {
    
    let A4PageWidth: CGFloat = 595.2
    
    let A4PageHeight: CGFloat = 10841.8
    
    override init() {
        super.init()
        
        // Specify the frame of the A4 page.
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)
        
        // Set the page frame.
        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")
        
        // Set the horizontal and vertical insets (that's optional).
        self.setValue(NSValue(cgRect: pageFrame.insetBy(dx: 10.0, dy: 10.0)), forKey: "printableRect")
        self.headerHeight = 250.0
        self.footerHeight = 250.0
    }
    
    override func drawHeaderForPage(at pageIndex: Int, in headerRect: CGRect) {
        
    }
    
}

class InvoiceComposer {
    weak var objecPrinter: orderPrintBuilderClass?
    private  var pos: pos_config_class?
    private  var setting: settingClass?
    var companyBill:res_company_class?
    var currency:String

    init(_ object: orderPrintBuilderClass) {
        self.objecPrinter = nil
        self.pos = SharedManager.shared.posConfig()
        self.setting = SharedManager.shared.appSetting()
        self.objecPrinter = object
        objecPrinter!.enable_draft_mode = false
        if objecPrinter!.for_waiter {
            objecPrinter!.for_waiter = setting!.enable_draft_mode
            objecPrinter!.enable_draft_mode = true
            objecPrinter!.qr_print = true
        }
        companyBill =  pos!.company
        
//        if let brand_order = order?.brand , let currenCompany =  companyBill {
//            companyBill =  res_company_class(from: brand_order , company: currenCompany)
//        }
        if (companyBill?.currency_id ?? 0) != 0
        {
            currency =  companyBill?.currency_name ?? ""
        }else{
            currency = SharedManager.shared.getCurrencyName(true)
        }
        if let brand_order = objecPrinter!.order!.brand , let currenCompany =  companyBill {
            companyBill =  res_company_class(from: brand_order , company: currenCompany)
        }
    }
    deinit {
       SharedManager.shared.printLog("======InvoiceComposer==deinit====")
        pos = nil
        setting = nil
        objecPrinter = nil
    }
    
     var number:Int  = 1

    func renderInvoice() -> String! {
      
        guard  let _ = objecPrinter!.order else {
            return ""
        }
        updateData()
        
        var HTMLContent = HTMLTemplateGlobal.shared.getTemplateHtmlContent(self.objecPrinter!.for_kds ? .KDS : .BILL)
        // The logo image.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO#", with: renderLogo())
        // Oddo Header.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ODOO_HEADER#", with: renderOdooHeader())
        // order number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_NUMBER#", with: renderOrderNumber())
        // VAT number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#VAT_NUMBER#", with: renderVATNumber())
        //Full Reference number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#FULL_ORDER_NUMBER#", with: renderFullOrderNumber())
        // Reference Code number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_NUMBER#", with: "")

//        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_NUMBER#", with: renderRefCodeNumber())
        // CR number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CR_NUMBER#", with: renderCRNumber())
        // PRINTER NAME
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_NAME#", with: renderPrinterName())
        // POS name.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NUMBER#", with: renderPOS())
        // Cashier name.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CASHIER#", with: renderCashierName())
        // Customer name.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CUSTOMER#", with: renderCustomerName())
        // Customer VAT.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CUSTOMER_VAT#", with: renderCustomerVAT())
        // Table number .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#TABLE_NUMBER#", with: renderTableNumber())
        // Date Order .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#DATE_ORDER#", with: renderDateOrder())
        // Type Order .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_TYPE#", with: renderTypeOrder())
        // QTY ITEM PRICE .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY_ITEM_PRICE#", with: renderQtyItemPrice())
        // Items .
        if let order = self.objecPrinter?.order{
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: renderItems(item: order))
        }else{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: "")

        }
        // NOTES .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#NOTES#", with: renderNotesInvoice())
        // total price section .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE_SECTION#", with:renderPriceSection())
        HTMLContent = HTMLContent.replacingOccurrences(of: "#INSURANCE_SECTION#", with:renderInsuranceSection())

        // make Footer For .
        HTMLContent = makeFooterFor(HTMLContent)
        // QR .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#QR#", with: renderQR())
        // NOT_PAID
        HTMLContent = HTMLContent.replacingOccurrences(of: "#NOT_PAID#", with: renderNotPaid())
        
        return HTMLContent
    }
     @objc func renderInsuranceSection()->String{
         let currency = self.currency ?? ""
        if objecPrinter?.for_kds ?? false {
            return ""
        }
        if let pos_order = objecPrinter?.order ,let order_id = pos_order.id,let insurance_order = pos_insurance_order_class.getInsuranceOrder(order_id: order_id){
            if var HTMLContent = CashHtmlFiles.shared.insurance_section_items_html{
                HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY_ITEM_PRICE#", with: renderQtyItemPrice())
                HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: renderItems(item: insurance_order))
                //#COLSPAN_INSURANCE#
                if SharedManager.shared.appSetting().enable_show_unite_price_invoice {
                    HTMLContent = HTMLContent.replacingOccurrences(of: "#COLSPAN_INSURANCE#", with: "4")
                }else{
                    HTMLContent = HTMLContent.replacingOccurrences(of: "#COLSPAN_INSURANCE#", with: "2")
                }
                //PRICE_TOTAL
                HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE_TOTAL#", with: "\(insurance_order.amount_total.rounded_app())" + " \(SharedManager.shared.getCurrencySymbol())")

                return HTMLContent
            }

        }
        return ""
    }
     func updateData(){
        if (companyBill?.currency_id ?? 0) != 0
        {
            self.objecPrinter!.currency = companyBill?.currency_name ?? ""
        }
        //        if self.objecPrinter!.isCopy == true
        //        {
        //            pos!.receipt_header = String(format: "%@<br />%@", pos!.receipt_header! , "Copy receipt")
        //        }
        pos!.receipt_footer = pos!.receipt_footer?.replacingOccurrences(of: "\n", with: "<br />")
    }
    
}


extension InvoiceComposer {
    //#FONT_SIZE_BORDER#
    
    func renderFontSize() -> String {
        let fonSize = setting!.font_size_for_kitchen_invoice
        if self.objecPrinter!.for_kds {
            return "font-size:\(fonSize)px;"
        }
        return ""
    }
    func renderFontSizeBorder() -> String {
        if self.objecPrinter!.for_kds {
            
            let fonSize = setting!.font_size_for_kitchen_invoice + 30
            return "font-size:\(fonSize )px;"
        }
        return "font-size:\(60 )px;"
        
    }
    func renderFontSizeOrderType() -> String {
        if self.objecPrinter!.for_kds {
            
            let fonSize = setting!.font_size_for_kitchen_invoice + 10
            return "font-size:\(fonSize )px;"
        }
        return "font-size:\(40 )px;"
        
    }
    
    
    func get_total_qty_forKDS() -> String
    {
        if setting!.show_number_of_items_in_invoice == false
        {
            return ""
        }
        
        guard  let order = self.objecPrinter!.order  else {
            return ""
        }
        
        var Total_items_qty = 0.0
        
        for item in order.pos_order_lines
        {
            Total_items_qty += item.qty - item.last_qty
            if item.is_combo_line!
            {
                for combo_item in item.selected_products_in_combo
                {
                    if combo_item.extra_price! > 0
                    {
                        Total_items_qty += combo_item.qty - combo_item.last_qty
                    }
                    
                }
            }
            
        }
        
        
        
        return renderNoItems(Total_items_qty.toIntString(),show: true,separator_top: false) //+ separator_top
    }
    
    
    //MARK:- price section.
    @objc func renderPriceSection() -> String {
        if self.objecPrinter!.hidePrice == true
        {
            if  self.objecPrinter!.for_kds
            {
                return get_total_qty_forKDS()
            }
            
            return ""
        }
        
        guard  let order = self.objecPrinter!.order  else {
            return ""
        }
        
        let setting = SharedManager.shared.appSetting()
        
        
        let currency = self.objecPrinter!.currency
        let sub_Order = self.objecPrinter!.sub_Order
        var tax_all = order.amount_tax
        var total_all = order.amount_total
        //        let delivery_amount =  order.orderType?.delivery_amount ?? 0
        var extra_amount:Double = 0
        var product_extra:product_product_class?
        
        if  self.pos!.extra_fees == true // order.orderType?.order_type == "extra"
        {
            let line = pos_order_line_class.get(order_id:  order.id!, product_id: self.pos!.extra_product_id!)
            if line != nil
            {
                extra_amount = line!.price_subtotal!
                
                product_extra = line!.product
            }
            
            
            
        }
        
        
        let isTaxFree = SharedManager.shared.posConfig().allow_free_tax
        let rowsItems:NSMutableString = NSMutableString()
        var Total_items_qty = 0.0
        
        for item in order.pos_order_lines
        {
            Total_items_qty += item.qty
            if item.is_combo_line!
            {
                for combo_item in item.selected_products_in_combo
                {
                    //                    if combo_item.extra_price! > 0
                    //                    {
                    Total_items_qty += combo_item.qty
                    //                    }
                    
                }
            }
            
        }
        for item in ( sub_Order ?? [])
        {
            guard let item = item else {
                continue
            }
            tax_all = tax_all + item.amount_tax
            total_all = total_all + item.amount_total
            
        }
        var  Discount:String = ""
        var CHANGE:String = ""
        let TAX:String = baseClass.currencyFormate( tax_all) + " " + SharedManager.shared.getCurrencySymbol()
        let TOTAL:String = baseClass.currencyFormate( total_all) + " " + SharedManager.shared.getCurrencySymbol()
        let tax_Precentage =   " (15 %) "//" (\(Double(round(10*(tax_all*100/total_all))/10)) %) "
        var SUB_TOTAL:String = baseClass.currencyFormate( total_all - tax_all) + " " + SharedManager.shared.getCurrencySymbol()
        
        var total_subtotal = total_all
//        var  tax_extra:Double = 0
//
//        if extra_amount > 0
//        {
//            tax_extra = (tax_all / 2  )
//            total_subtotal = total_all - extra_amount  //- (tax_all / 2  )
//
//
//            extra_amount = extra_amount   - tax_extra
//
//        }
//
        
        
        
        let TOTAL_QTY = (sub_Order?.count ?? 0) <= 0 ? "-" :"\(sub_Order?.count ?? 0)"
        var discount_tax:Double = 0
        var discount_price_subtotal:Double = 0
        if (sub_Order?.count ?? 0) == 0
        {
            // DISCOUNT
            let line_discount = order.get_discount_line()
            if line_discount != nil
            {
                discount_price_subtotal = abs( line_discount!.price_subtotal ?? 0)
                Discount = baseClass.currencyFormate(line_discount?.price_unit ?? 0 ) + " " + SharedManager.shared.getCurrencySymbol()
                discount_tax = abs(  line_discount!.price_subtotal_incl!) - abs( line_discount!.price_subtotal!)
                
//                total_subtotal = total_subtotal + ((line_discount?.price_unit)! * -1 ) //-  (tax_all - discount_tax)
//                total_subtotal = total_subtotal + ((line_discount?.price_subtotal_incl)! * -1 )
                
            }
        }
        
        
        // Delivery
        var delivery_amount  = 0.0
        var line_delivery:pos_order_line_class? = nil
        if let order_type =  order.orderType {
            line_delivery = pos_order_line_class.get (order_id:  order.id!, product_id: order_type.delivery_product_id)
            if line_delivery?.is_void  ?? false{
                line_delivery = nil
            }
        }
//        var tax_delivery:Double = 0
        
        if line_delivery != nil
        {
//            tax_delivery = line_delivery!.price_subtotal_incl! - line_delivery!.price_subtotal!
            delivery_amount = line_delivery!.price_subtotal!
            
//            total_subtotal = total_subtotal  - line_delivery!.price_subtotal_incl!  //- (tax_all - tax_delivery)
            
        }
        
        // Extra
        let pos = SharedManager.shared.posConfig()
        let extra_line = pos_order_line_class.get(order_id:  order.id!, product_id: pos.extra_product_id!)

        
//        SUB_TOTAL = baseClass.currencyFormate( total_subtotal  - (tax_all + discount_tax - tax_delivery - tax_extra ) ) + " " + currency
        SUB_TOTAL = baseClass.currencyFormate( total_subtotal  - tax_all + discount_price_subtotal - delivery_amount - (extra_line?.price_subtotal ?? 0)  ) + " " + SharedManager.shared.getCurrencySymbol()

        
        
        
        for item in order.get_account_journal()
        {
            if let tendered = item.tendered.toDouble(){
                rowsItems.append(renderPriceJournal("\(tendered.toIntString()) " + SharedManager.shared.getCurrencySymbol(), key: "Payment - \(item.display_name)"))
            }
        }
        
        if order.amount_return != 0
        {
            CHANGE = baseClass.currencyFormate(  order.amount_return) + " " + SharedManager.shared.getCurrencySymbol()
        }
        
        if var HTMLContent = CashHtmlFiles.shared.price_section{
            
            let discount = baseClass.currencyFormate(discount_price_subtotal  * -1 ) + " " + SharedManager.shared.getCurrencySymbol()
            let delivery_amount_Str = baseClass.currencyFormate(delivery_amount  ) + " " + SharedManager.shared.getCurrencySymbol()

            // NO itmes .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NO_ITEMS#", with:  renderNoItems(Total_items_qty.toIntString(),show: setting.show_number_of_items_in_invoice,separator_top: setting.show_number_of_items_in_invoice))
            // DISCOUNT .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DISCOUNT#", with: renderPriceDiscount( discount_price_subtotal != 0 ? discount : "" ))
            // TOTAL_QTY .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SUB_TOTAL_PRICE#", with: renderSubTotal(SUB_TOTAL, qty:TOTAL_QTY) )
            // DELIVERY .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DELIVERY#", with: renderPriceDelivery( delivery_amount != 0 ? delivery_amount_Str : ""))
            // EXTRA .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXTRA#", with: renderPriceEXTRA(extra_amount != 0 ? "\((extra_amount ).toIntString()) \(SharedManager.shared.getCurrencySymbol())": "",product_extra ))
            // Tax disount_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TAX_DISCOUNT#", with: renderPriceTaxDiscount(isTaxFree ? TAX : ""))
            // VAT_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VAT_PRICE#", with: renderPriceVat(TAX,tax_Precentage))
            // TOTAL_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTAL_PRICE#", with: renderPriceTotal(TOTAL))
            // ACCOUNT_JOURNAL .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ACCOUNT_JOURNAL#", with: String(rowsItems))
            // CASH_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CASH_PRICE#", with:  renderPricePayment(""))
            // CHANGE_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CHANGE_PRICE#", with: renderPriceChange(CHANGE))
            // CUSTOMER LOYALTY POINTS .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Loyalty#", with: renderLoyaltyPOINTS())
            // CASH_PRICE_RETURN .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CASH_PRICE_RETURN#", with:  renderPriceReturnPayment(SharedManager.shared.getCurrencySymbol()))
            
            
            
            return HTMLContent
            
        }
        return ""
    }
    //MARK:- price journal .
    @objc func renderPriceJournal(_ price:String, key:String) -> String {
        if price.isEmpty || key.isEmpty {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_account_journal", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#KEY#", with: key)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price tax discount.
    @objc func renderPriceTaxDiscount(_ price:String) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_tax_discount", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price delivry.
    @objc func renderPriceDelivery(_ price:String) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_delivry", ofType:"html")
        else {
            return ""
        }
        
        var new_price = price
        if self.objecPrinter!.order!.is_return()
        {
            let currency = self.objecPrinter!.currency
            
            new_price = "0 " + SharedManager.shared.getCurrencySymbol()
        }
        
        
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: new_price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    
    //MARK:- price EXTRA.
    @objc func renderPriceEXTRA(_ price:String,_ product_extra:product_product_class?) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_extra", ofType:"html")
        else {
            return ""
        }
        
        var new_price = price
        if self.objecPrinter!.order!.is_return()
        {
            //            let currency = self.objecPrinter!.currency
            //
            //            new_price = "0 " + currency
            return ""
        }
        
        
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#name#", with: product_extra!.name)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#namear#", with: product_extra!.name_ar)
            
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price vat.
    @objc func renderPriceVat(_ price:String,_ tax_Precentage:String) -> String {
        if objecPrinter!.for_waiter {
            return ""
        }
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_vat", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PRECENTAGE#", with: tax_Precentage)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price total.
    @objc func renderPriceTotal(_ price:String) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_total", ofType:"html")
        else {
            return ""
        }
        let title =  "Total - الإجمالي"

        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TITLE#", with: title)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price sub total.
    @objc func renderSubTotal(_ price:String, qty:String) -> String {
        if objecPrinter!.for_waiter  {
            return ""
        }
        if price.isEmpty || qty.isEmpty {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_subtotal", ofType:"html")
        else {
            return ""
        }
        
        var new_price = price
        if self.objecPrinter!.order!.is_return()
        {
            let extra_fees = SharedManager.shared.posConfig().extra_fees
            
            if self.objecPrinter!.order!.delivery_amount != 0 || self.objecPrinter!.order!.is_have_promotions() || extra_fees == true
            {
                let currency = self.objecPrinter!.currency
                
                new_price = "0 " + SharedManager.shared.getCurrencySymbol()
            }
            
        }
        
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY#", with: qty)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: new_price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price return.
    @objc func renderPriceReturnPayment(_ currency:String) -> String {
        return ""
        
        var price = ""
        
        if self.objecPrinter!.order!.sub_orders.count != 0
        {
            var total_return =  0.0
            for ord in self.objecPrinter!.order!.sub_orders
            {
                total_return = total_return + ord.amount_return
            }
            price = total_return.toIntString() + currency
        }
        
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_return", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price payment.
    @objc func renderPricePayment(_ price:String) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_payment", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- No items.
    @objc func renderNoItems(_ price:String,show:Bool,separator_top:Bool) -> String {
        if price.isEmpty  {
            return ""
        }
        
        
        guard  self.objecPrinter!.order!.amount_total > 0   else {
            return ""
        }
        
        if show == false
        {
            return ""
        }
        
        guard let pathPriceChange = Bundle.main.path(forResource: "no_items", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            
            if separator_top
            {
                HTMLContent = HTMLContent.replacingOccurrences(of: "#class#", with: "class = \"top border\"")
            }
            else{
                HTMLContent = HTMLContent.replacingOccurrences(of: "#class#", with: "")
            }
            
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price discount.
    @objc func renderPriceDiscount(_ price:String) -> String {
        if price.isEmpty  {
            return ""
        }
        //<span style=\"font-size: 10px;\">[\(pos_creat_code)]</span>
        var name_discount_en = ""
        if SharedManager.shared.appSetting().enable_show_discount_name_invoice {
            name_discount_en = self.objecPrinter?.order?.get_discount_line()?.discount_display_name ?? ""
            if !name_discount_en.isEmpty {
                name_discount_en = " <span style=\"font-size: 25px;\">[\(name_discount_en)]</span> "
            }
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_discount", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NAME_ENG#", with: name_discount_en)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- Loyalty POINTS.
    @objc func renderLoyaltyPOINTS() -> String {
        if self.objecPrinter!.order!.partner_id == 0  {
            return ""
        }
        
        if self.setting!.show_loyalty_details_in_invoice == false
        {
            return ""
        }
        
        
        let free_points = self.objecPrinter!.order!.loyalty_points_remaining_partner + self.objecPrinter!.order!.loyalty_earned_point  - self.objecPrinter!.order!.loyalty_redeemed_point
        
        let free_amount = self.objecPrinter!.order!.loyalty_amount_remaining_partner + self.objecPrinter!.order!.loyalty_earned_amount  - self.objecPrinter!.order!.loyalty_redeemed_amount
        
        guard let pathPriceChange = Bundle.main.path(forResource: "loyalty", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#loyalty_points_remaining_partner#", with: self.objecPrinter!.order!.loyalty_points_remaining_partner.toIntString()  )
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#loyalty_earned_point#", with: self.objecPrinter!.order!.loyalty_earned_point.toIntString()  )
            HTMLContent = HTMLContent.replacingOccurrences(of: "#loyalty_redeem_point#", with: self.objecPrinter!.order!.loyalty_redeemed_point.toIntString()  )
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#free_points#", with: free_points.toIntString()  )
            HTMLContent = HTMLContent.replacingOccurrences(of: "#free_amount#", with: free_amount.toIntString() + " " + SharedManager.shared.getCurrencySymbol())
            
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    
    //MARK:- price change.
    @objc func renderPriceChange(_ price:String) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_change", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    
    //MARK:- type order.
    @objc func renderTypeOrder() -> String {
        var type: String = String(self.objecPrinter!.order!.orderType?.display_name  ?? "")
        let typeReference: String = String(self.objecPrinter!.order!.delivery_type_reference  ?? "")
        
        if self.objecPrinter!.order!.order_integration == .DELIVERY {
            type = (self.objecPrinter!.order!.pos_order_integration?.online_order_source ?? "")
            if let platFormName = self.objecPrinter!.order!.platform_name , !platFormName.isEmpty{
                type = platFormName
            }
        }
        if type.isEmpty {
            return ""
        }
        if !(typeReference).isEmpty {
            type =   type + " ( #\(typeReference) )"
            
        }
        
        if var HTMLContent = CashHtmlFiles.shared.order_type{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#FONT_SIZE_ORDER_TYPE#", with: renderFontSizeOrderType())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: type)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DIVER_NAME#", with: renderDriverName())
            return HTMLContent
        }
        return ""
    }
    //MARK:- driver name.
    @objc func renderDriverName() -> String {
        if !(self.objecPrinter!.order!.orderType?.required_driver ?? false) {
            if (self.objecPrinter!.order!.orderType?.show_customer_info ?? false) {
                return renderCustDeliveryInfo()
            }
        }
        
        guard let driver = self.objecPrinter!.order!.driver , let name = driver.name, let code = driver.code else {
            return ""
        }
        
        
        guard let pathOrderType = Bundle.main.path(forResource: "driver_name", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathOrderType)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NAME#", with: name)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CODE#", with: code)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CUST_DELIVERY_INFO#", with: renderCustDeliveryInfo())
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- driver name.
    @objc func renderCustDeliveryInfo() -> String {
        //        if !(self.objecPrinter!.order!.orderType?.show_customer_info ?? false) {
        //            return ""
        //        }
        guard let customer = self.objecPrinter!.order!.customer  else {
            return ""
        }
        let mobile = customer.phone
        let address = String( format: "%@ , %@, %@" ,customer.street ,customer.city ,customer.country_name)
        
        
        guard let pathOrderType = Bundle.main.path(forResource: "cust_delivery_info", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathOrderType)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#MOBILE#", with: mobile)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ADDRESS#", with: address)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- qr html.
    private func renderQR() -> String {
        
        if (objecPrinter!.for_waiter ){
            if !setting!.enable_qr_for_draft_bill {
                //  return ""
            }
        }else{
            if (!objecPrinter!.qr_print){
                return ""
            }
        }
        
        let name = objecPrinter!.order!.name ?? ""
        if name.isEmpty {
            return ""
        }
        
        let companyName = companyBill?.name ?? ""
        let tax_number = self.getVatNumber() //company().vat
        let order_time_stamp = Date(strDate:objecPrinter!.order!.write_date ?? "", formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss'Z'", UTC: false)
        let totalVat = String(format: "%.2f", objecPrinter!.order!.amount_tax)
        let totalOrder = String(format: "%.2f", objecPrinter!.order!.amount_total)  //objecPrinter!.order!.amount_total
        //MARK:- Invoice Tlv inital
        let InvoiceTlvModel = InvoiceTlvModel()
        InvoiceTlvModel.sellerName = companyName
        InvoiceTlvModel.vatNumber = tax_number
        InvoiceTlvModel.timeStamp = order_time_stamp
        InvoiceTlvModel.totalVat = totalVat
        InvoiceTlvModel.totalWithVat = totalOrder
        //MARK:- Invoice Tlv EnCoding
        let tvl_hex: Data =  InvoiceTlvModel.packageData()
        let tvl_base64 =  tvl_hex.base64EncodedString(options: [])
        //MARK:- generate QRCode For Invoice Tlv EnCoding
        let qr_image = SharedManager.shared.qrCodeGenerator.base64Data(for: "\(tvl_base64)")
        if var HTMLContent = CashHtmlFiles.shared.qr_html{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: qr_image)
            return HTMLContent
        }
        return ""
    }
    
    //MARK:- copy right invocie.
    @objc func renderCopyRight() -> String {
        
        guard let pathNoteInvoice = Bundle.main.path(forResource: "copy_right", ofType:"html")
        else {
            return ""
        }
        do {
            let HTMLContent = try String(contentsOfFile: pathNoteInvoice)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- Printed Date invocie.
    @objc func renderPrintedDateInvocie(date:String) -> String {
        if   date.isEmpty {
            return ""
        }
        guard let pathNoteInvoice = Bundle.main.path(forResource: "ref_date", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathNoteInvoice)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINT_DATE#", with: date)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- notes invocie.
    @objc func renderNotesInvoice() -> String {
        let isKDS = self.objecPrinter!.for_kds
        if !setting!.show_invocie_notes && isKDS {
            return ""
        }
        var notes = self.objecPrinter!.order!.note
        notes = notes.replacingOccurrences(of: "\r\n", with: "<br/>")
        if notes.isEmpty {
            return ""
        }
        
        if var HTMLContent = CashHtmlFiles.shared.note_invoice{
            if setting?.enable_show_unite_price_invoice ?? false {
                if let HTMLUnitePriceContent = CashHtmlFiles.shared.note_invoice_unite_price{
                    HTMLContent = HTMLUnitePriceContent
                }
            }
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: notes)
            return HTMLContent
        }
        return ""
    }
    //MARK:- Date order.
    @objc func renderDateOrder() -> String {
        let date = Date(strDate: self.objecPrinter!.order!.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: "yyyy/MM/dd hh:mm a", UTC: false)
        
        
        if date.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.date_invoice{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: date)
            return HTMLContent
        }
        return ""
    }
    //MARK:- Table number.
    @objc func renderTableNumber() -> String {
        let number = self.objecPrinter!.order!.table_name ?? ""
        if number.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.table_number{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: number)
            return HTMLContent
        } 
        return ""
    }
    //MARK:- Custom NAME.
    @objc func renderCustomerName() -> String {
        guard let customer  = self.objecPrinter!.order!.customer else {
            return ""
        }
        let name = customer.name
        if name.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.customer_name{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: name)
            return HTMLContent
        }
        return ""
    }
    //MARK:- Custom VAT.
    @objc func renderCustomerVAT() -> String {
        guard let customer  = self.objecPrinter!.order!.customer else {
            return ""
        }
        let name = customer.vat
        if name.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.customer_vat{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: name)
            return HTMLContent
        }
        return ""
    }
    //MARK:- QTY Item Price .
    @objc func renderQtyItemPrice() -> String {
        let isKDS = self.objecPrinter!.for_kds
        if isKDS {
            return CashHtmlFiles.shared.qty_item_price_kds ?? ""
        }
        if setting?.enable_show_unite_price_invoice ?? false {
            return CashHtmlFiles.shared.qty_item_unite_price ?? ""
        }
        return CashHtmlFiles.shared.qty_item_price_pos ?? ""
    }
    //MARK:- Cashier NAME.
    @objc func renderCashierName() -> String {
        if objecPrinter?.for_kds ?? false {
            return ""
        }
        let name = (self.objecPrinter!.order!.write_user_name ?? "").trunc(length: 15)
        if name.isEmpty {
            return ""
        }
        guard     let pathToCashierName = Bundle.main.path(forResource: "cashier_name", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathToCashierName)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: name)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- POS NAME.
    @objc func renderPOS() -> String {
        let POS = self.objecPrinter!.order!.write_pos_name ?? ""
        if POS.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.POS_name{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: POS)
            return HTMLContent
        }
        return ""
    }
    //MARK:- printer Name
    @objc func renderPrinterName() -> String {
        if !self.objecPrinter!.for_kds {
            return ""
        }
        let PrinterName = self.objecPrinter!.printerName
        if PrinterName.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.PRINTER_NAME{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: PrinterName)
            return HTMLContent
        }
        return ""
    }
    //MARK:- CR Number.
    @objc  func renderCRNumber() -> String {
        if self.objecPrinter!.for_kds {
            return ""
        }
        let CRNumber =  companyBill?.company_registry ?? ""
        if CRNumber.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.CR_number{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: CRNumber)
            return HTMLContent
        }
        return ""
    }
    //MARK:- Reference Cod Number.
    @objc  func renderRefCodeNumber() -> String {
        if (objecPrinter!.for_waiter ){
            return ""
        }
        if self.objecPrinter!.hideRef
        {
            return ""
        }
        let posWriteCode = self.objecPrinter!.order!.write_pos_code ?? "\(self.objecPrinter!.order!.write_pos_id ?? 0)"
        let orderNumber =  String(format: "%03d", self.objecPrinter!.order!.sequence_number)
        let dateOrder =  Date().toString(dateFormat: "yy MM dd", UTC: false)
        let refCode = ( posWriteCode + dateOrder + "-" + orderNumber).replacingOccurrences(of: " ", with: "")
        if refCode.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.ref_number{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: refCode)
            return HTMLContent
        }
        return ""
    }
    func getVatNumber() -> String{
        if (pos!.vat ?? "").isEmpty{
           return companyBill?.vat ?? ""
        }else{
            return pos!.vat ?? ""
        }
    }
    //MARK:- VAT Number.
    @objc  func renderVATNumber() -> String {
        if self.objecPrinter!.for_waiter  {
            return ""
        }
        if self.objecPrinter!.for_kds {
            return ""
        }
        if self.objecPrinter!.hideVat  {
            return ""
        }
        let VatNumber = self.getVatNumber() //company().vat
        if VatNumber.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.vat_number{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: VatNumber)
            return HTMLContent
        }
        return ""
    }
    //MARK:- Order Number.
    @objc func renderOrderNumber() -> String {
        var orderNumber = "Order #\(self.objecPrinter!.order!.sequence_number)"
        if orderNumber.isEmpty {
            return ""
        }
        if setting!.enable_enter_sessiion_sequence_order {
            var multi_session_enable = true
            let multi_session_id = SharedManager.shared.posConfig().multi_session_id  ?? 0
            if multi_session_id == 0
            {
                multi_session_enable = false
            }
            if multi_session_enable {
                var fonSize:Double = 10.0
                if objecPrinter!.for_kds {
                    fonSize = setting!.font_size_for_kitchen_invoice - 50
                    if fonSize < 10.0 {
                        fonSize = 10
                    }
                }
                let pos_creat_code = self.objecPrinter!.order!.create_pos_code ?? ""
                if pos_creat_code.isEmpty {
                    
                    orderNumber = "Order #\(self.objecPrinter!.order!.sequence_number) <span style=\"font-size: 30px;\">[Online]</span>"
                }else{
                    orderNumber = "Order #\(self.objecPrinter!.order!.sequence_number) <span style=\"font-size: 10px;\">[\(pos_creat_code)]</span>"
                }
                
            }
            
        }
        
        if var HTMLContent = CashHtmlFiles.shared.order_number{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: orderNumber)
            if self.objecPrinter!.isCopy == true
            {
                HTMLContent =  HTMLContent.replacingOccurrences(of: "#COPY#", with:"<tr><td colspan=\"3\"class=\"bold-title-center\">Copy receipt      </td></tr>"  )
            }else{
                HTMLContent =  HTMLContent.replacingOccurrences(of: "#COPY#", with: "")
            }
            return HTMLContent
      
        }
        return ""
    }
    //MARK:- The Full Order Number.

    @objc func renderFullOrderNumber() -> String {
        if self.objecPrinter!.for_kds {
            return ""
        }
//        if self.objecPrinter!.showOrderReference
//        {
            return """
             <tr>
                 <td class="bold-title-left style="width: 250px;">Invoice #</td>
                 <td class="normal-title-center" style=" max-width: 480px;">\(self.objecPrinter!.order!.uid!)</td>
                 <td class="bold-title-right" style="width: 250px;"># الفاتورة</td>
             </tr>
             """
        //}
//        else
//        {
//            return ""
//        }
  
    }
    
    //MARK:- The Oddo Header.
    @objc func renderOdooHeader() -> String {
        var header = ""
        //        if self.objecPrinter!.for_kds == false
        //        {
        //            if setting!.receipt_custom_header == false
        //            {
        //                header = "#header"
        //            }
        //            else
        //            {
        //                header = "#header"
        //            }
        //
        //        }
        if  self.objecPrinter!.for_waiter
        {
            return header
            
        }
        if self.objecPrinter!.hideHeader
        {
            if let odooHeader  = self.objecPrinter!.custom_header
            {
                header = odooHeader
                
            }else{
                header = ""
            }
            
        }else{
            let posHeader = pos!.receipt_header!
            if self.objecPrinter!.for_waiter
            {
                header = posHeader + "<br />  Not paid"
            }
            
            if self.objecPrinter!.for_kds == false
            {
                if setting!.enable_simple_invoice_vat == true
                {
                    header = posHeader + "<br />" + "<b>" + "فاتورة ضريبية مبسطة" + "</b>"
                }
                else
                {
                    header = posHeader + "<br />" + "<b>" + "فاتورة ضريبية " + "</b>"
                    
                }
            }
        }
        
        if self.objecPrinter!.order!.parent_order_id != 0
        {
            header = header + "<br />" + "<b>" +  "اشعار دائن" + "</b>"
        }
        if header.isEmpty {
            return ""
        }
       
        if var HTMLContent = CashHtmlFiles.shared.odoo_header{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: header)
            return HTMLContent
        }
       
        return ""
    }
    //MARK:- The logo image.
    @objc func renderLogo() -> String {
        if (objecPrinter!.for_waiter ){
            return renderWaterMark()
        }
        if  self.objecPrinter!.hideLogo
        {
            return ""
        }
        
        let width = setting!.receipt_logo_width <= 0 ? 100 :  setting!.receipt_logo_width
//        let logoImage = FileMangerHelper.shared.getLogoBase64()
//
//        if (logoImage.isEmpty) {
//            return ""
//        }
        var logoPath = ""
        if SharedManager.shared.posConfig().cloud_kitchen.count > 0 {
            logoPath = FileMangerHelper.shared.getLogoPathStrringKitchenCloud(for: objecPrinter?.order?.brand_id) //getLogoBase64KitchenCloud(for:objecPrinter?.order?.brand_id )

        }else{
            logoPath = FileMangerHelper.shared.getLogoPathString()
        }
        
//        var logoPath = FileMangerHelper.shared.getLogoPath()

        if (logoPath.isEmpty) {
            return ""
        }
//        logoPath = "file://" + logoPath
       
        if var HTMLContent = CashHtmlFiles.shared.logo_company {
            HTMLContent = HTMLContent.replacingOccurrences(of: "#WIDTH#", with: "\(width)")
//            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: logoImage)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with:  logoPath)

            return HTMLContent
        }
     
        return ""
    }
    //MARK:- The Oddo Footer.
    @objc func makeFooterFor(_ content:String) -> String {
        var contentHTML = content
        var footer = ""
        let print_count = pos_order_helper_class.get_print_count(order_id:  self.objecPrinter!.order!.id!)
        let printerName =   self.objecPrinter!.printerName
        if self.objecPrinter!.hideFooter || self.objecPrinter!.for_waiter
        //        if self.objecPrinter!.hideFooter
        {
            
            if !self.objecPrinter!.for_waiter{
                let datePrint =  "Printed at: " + Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: false)
                footer = "#Print: \(print_count) / \(printerName)" +  "<br/> \(datePrint)"
            }
            // copy right .
            contentHTML = contentHTML.replacingOccurrences(of: "#COPY_RIGHT#", with: "")
            // ref invoice .
            contentHTML = contentHTML.replacingOccurrences(of: "#REF_DATE#", with: "")
            
        }else{
            footer  = pos!.receipt_footer!
            
            if self.objecPrinter!.for_kds == false
            {
                // copy right .
                contentHTML = contentHTML.replacingOccurrences(of: "#COPY_RIGHT#", with: renderCopyRight())
            }
            if self.objecPrinter!.hideRef
            {
                // ref invoice .
                contentHTML = contentHTML.replacingOccurrences(of: "#REF_DATE#", with: "")
            }else{
                let createAtDate = Date(strDate: self.objecPrinter!.order!.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: "yyyy/MM/dd hh:mm a", UTC: false)
                var createAt =  "Opened at: \(createAtDate)"
                
                if self.objecPrinter!.order!.create_user_name != self.objecPrinter!.order!.write_user_name{
                    createAt += (" by " + (self.objecPrinter!.order!.create_user_name ?? "") )
                }
                
                //                let datePrint =  "Printed at: " + Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: false) + "<br />"
                contentHTML = contentHTML.replacingOccurrences(of: "#REF_DATE#", with: renderPrintedDateInvocie(date:   createAt) )
                /* if self.objecPrinter!.sub_Order.count > 0
                 {
                 var parent_orderID_server = self.objecPrinter!.sub_Order[0].name
                 if !parent_orderID_server!.isEmpty
                 {
                 parent_orderID_server = parent_orderID_server?.replacingOccurrences(of: "Order-", with: "")
                 //  footer = footer + "<br />" + "Ref Return  \(String(parent_orderID_server!)) "
                 }
                 }*/
                if self.objecPrinter!.for_kds == true
                {
                    footer = footer + "<br/>#Print: \(print_count)"
                }
            }
            
        }
        
        guard let pathOdooHeader = Bundle.main.path(forResource: "odoo_header", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathOdooHeader)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: footer)
            contentHTML = contentHTML.replacingOccurrences(of: "#FOOTER#", with: HTMLContent)
            return contentHTML
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- render WaterMark
    @objc func renderWaterMark() -> String {
        //        if  !objecPrinter!.enable_draft_mode {
        //            return ""
        //        }
        guard let image = #imageLiteral(resourceName: "draft2.png").toBase64() else {
            return ""
        }
        
        
        guard let pathLogoCompany = Bundle.main.path(forResource: "darft_html", ofType:"html") else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathLogoCompany)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: image)
            
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- render Not-Paid
    @objc func renderNotPaid() -> String {
       
        if objecPrinter!.hideNotPaid {
            return ""
        }
        guard let pathLogoCompany = Bundle.main.path(forResource: "not_paid", ofType:"html") else {
            return ""
        }
        do {
            let HTMLContent = try String(contentsOfFile: pathLogoCompany)
            return HTMLContent
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
}
