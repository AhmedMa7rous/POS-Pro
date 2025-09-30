//
//  MWInvoiceComposer.swift
//  pos
//
//  Created by M-Wageh on 06/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

class MWInvoiceComposer {
//    weak var objecPrinter: orderPrintBuilderClass?
    private  var pos: pos_config_class?
    private  var setting: settingClass?
    var for_kds:Bool
    var order:pos_order_class?
    var for_waiter:Bool
    var hideFooter:Bool
    var hideRef:Bool
    var hideLogo:Bool
    var hideExtraPrice:Bool

    var printerName:String
    var hideHeader:Bool
    var custom_header:String
    var hideVat:Bool
    var isCopy:Bool
    var hidePrice:Bool
    var currency:String
    var sub_Order:[pos_order_class?]?
    var qr_print:Bool
    var hideCalories:Bool
    var hideComboDetails:Bool
    var print_new_only:Bool
    var companyBill:res_company_class?
    var logoImage:String?
    var fileType:rowType?
    var hideNotPaid:Bool
    var for_insurance:Bool
    var return_name:String?
    var hidSimpleVatTitle:Bool?
    var hideCashierKDS:Bool
    var isKDSResend:Bool




    init(order:pos_order_class?,printerName:String, custom_header:String = "",fileType:rowType) {
        self.pos = SharedManager.shared.posConfig()
        self.setting = SharedManager.shared.appSetting()
        self.order = order
        self.printerName = printerName
        self.custom_header = custom_header

        self.for_kds = false
        hideCashierKDS = true
        isKDSResend = false
        self.for_waiter = false
        hideFooter = false // for kds = true
        hideRef = false // for kds = true
        hideLogo = false // for kds = true
        hideHeader = false // for kds = true
        hideVat = false // for kds = true
        isCopy = false // for history = true
        hidePrice = false // for target kds
        hideNotPaid = true
        for_insurance = false
        hideExtraPrice = false
        hidSimpleVatTitle = false
        companyBill =  pos?.company
        self.fileType = fileType
        if let brand_order = order?.brand , let currenCompany =  companyBill {
            companyBill =  res_company_class(from: brand_order , company: currenCompany)
        }
        if (companyBill?.currency_id ?? 0) != 0
        {
            currency =  companyBill?.currency_name ?? ""
        }else{
            currency = SharedManager.shared.getCurrencyName(true)
        }
        pos?.receipt_footer = SharedManager.shared.posConfig().receipt_footer?.replacingOccurrences(of: "\n", with: "<br />")
        sub_Order = []
        qr_print = SharedManager.shared.showQrCodeBill() //true //setting.qr_enable
        hideCalories = false // for kds = true
        hideComboDetails = !(setting?.enable_show_combo_details_invoice ?? true)
        print_new_only = false // for kds = true
        
        if  (order?.amount_total ?? 0) < 0.0
        {
            let option = ordersListOpetions()
            option.Closed = true
            option.orderID =   order?.parent_order_id
            option.parent_product = true
            
            sub_Order?.append(contentsOf: pos_order_helper_class.getOrders_status_sorted(options: option))
        }
        if SharedManager.shared.posConfig().cloud_kitchen.count > 0 {
            //getLogoPathStrringKitchenCloud
            logoImage = FileMangerHelper.shared.getLogoPathStrringKitchenCloud(for:order?.brand_id)
            
            //getLogoBase64KitchenCloud
           // logoImage = FileMangerHelper.shared.getLogoBase64KitchenCloud(for:order?.brand_id)   //getLogoBase64KitchenCloud(for:order?.brand_id )

           // logoImage = FileMangerHelper.shared.getLogoPathKitchenCloud(for:order?.brand_id)   //getLogoBase64KitchenCloud(for:order?.brand_id )
        }else{
            logoImage = FileMangerHelper.shared.getLogoPathString()

//            logoImage = FileMangerHelper.shared.getLogoPath()
        }
        if order?.parent_order_id != 0 {
                return_name = pos_order_class.get(order_id: order?.parent_order_id ?? 0)?.getBill_uidStatic() ?? ""
        }
    }
    deinit {
        pos = nil
        setting = nil
//        objecPrinter = nil
    }
    
    private var number:Int  = 1
   
    func setOptionForBill(){
        hideNotPaid = false
        qr_print = false //setting.qr_enable
        hidSimpleVatTitle = true
    }
    
    func setOptionForKDS(isResend:Bool){
        hideNotPaid = true
        self.for_kds = true
        self.isKDSResend = isResend
        hideCashierKDS = false
        hidePrice = true
        hideHeader = true
        hideFooter = true
        hideLogo = true
        hideRef = true
        hideVat = true
        hideCalories = true
        print_new_only = true
        qr_print = false //setting.qr_enable

    }
    func setOptionForTableView(hidLog:Bool = true ){
        hideNotPaid = true
        self.for_kds = false
        hidePrice = false
        hideHeader = true
        hideFooter = true
        hideLogo = hidLog
        hideRef = true
        hideVat = true
        hideCalories = true
        qr_print = false //setting.qr_enable
        hidSimpleVatTitle = true
        

    }
    func setOptionForHistory(hideLogo:Bool,for_insurance:Bool,hideExtraPrice:Bool = false){
        isCopy = true
        for_waiter = false
        self.hideLogo = hideLogo
        self.for_insurance = for_insurance
        self.hideExtraPrice = hideExtraPrice
    }
    func debugInvocie() -> String!{
        number += 1
        updateData()
        guard  let order = self.order else {
            return ""
        }
        let pathToInvoice = Bundle.main.path(forResource: "invoice_html", ofType:"html")
        do {
            var HTMLContent = try String(contentsOfFile: pathToInvoice!)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#FONT_SIZE#", with: "36")
            // The logo image.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO#", with: "")
            // Oddo Header.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ODOO_HEADER#", with: "")
            // order number.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_NUMBER#", with: renderOrderNumber())
            // VAT number.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VAT_NUMBER#", with: "")
            // Reference Code number.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_NUMBER#", with: "\(number)")
            // CR number.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CR_NUMBER#", with:"")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_NAME#", with: renderPrinterName())
            // POS name.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NUMBER#", with: "")
            // Cashier name.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CASHIER#", with:"")
            // Customer name.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CUSTOMER#", with: "")
            // Table number .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TABLE_NUMBER#", with: "")
            // Date Order .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DATE_ORDER#", with: "")
            // Type Order .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_TYPE#", with: "")
            // Items .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: "")
            // NOTES .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NOTES#", with: "")
            // total price section .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE_SECTION#", with:"")
            // make Footer For .
            //            HTMLContent = makeFooterFor(HTMLContent)
            // copy right .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#COPY_RIGHT#", with: "")
            // ref invoice .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_DATE#", with: "")
            // QR .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#QR#", with: renderQR(order: order))
            HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY_ITEM_PRICE#", with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#FOOTER#", with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NOT_PAID#", with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INSURANCE_SECTION#", with:"")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#FULL_ORDER_NUMBER#", with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CUSTOMER_VAT#", with: "")



            return HTMLContent
            
        } catch {
            SharedManager.shared.printLog("Unable to open html template")
        }
        return nil
    }
    func renderInvoice() -> String! {
     
       // return debugInvocie()
     
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
            // return debugInvocie()
        }
        guard  let order = self.order else {
            return ""
        }
        updateData()
        
        var HTMLContent = HTMLTemplateGlobal.shared.getTemplateHtmlContent(self.for_kds ? .KDS : .BILL)
        let rightMargin = setting?.margin_invoice_right_value ?? 25
        let leftMargin = setting?.margin_invoice_left_value ?? 35
        if rightMargin == 25 && leftMargin == 35{
            let widthValue = 960 - (rightMargin + leftMargin )
            HTMLContent = HTMLContent.replacingOccurrences(of: "#WIDTH_VALUE#", with: "width:\(widthValue)px;" )
        }else{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#WIDTH_VALUE#", with: "" )
        }
       
        HTMLContent = HTMLContent.replacingOccurrences(of: "#MARGIN_LEFT_VALUE#", with: "\(leftMargin)px" )
        HTMLContent = HTMLContent.replacingOccurrences(of: "#MARGIN_RIGHT_VALUE#", with: "\(rightMargin)px" )

//        HTMLContent = HTMLContent.replacingOccurrences(of: "#MARGIN_RIGHT_VALUE#", with: "30px" )

        // The logo image.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO#", with: renderLogo())
        // Oddo Header.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ODOO_HEADER#", with: renderOdooHeader())
        // order number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_NUMBER#", with: renderOrderNumber())
        HTMLContent = HTMLContent.replacingOccurrences(of: "<!--resentBackIdHint-->", with: renderResendKDS())

        // VAT number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#VAT_NUMBER#", with: renderVATNumber())
        //Full Reference number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#FULL_ORDER_NUMBER#", with: renderFullOrderNumber())
        HTMLContent = HTMLContent.replacingOccurrences(of: "#RETURN_ORDER_NUMBER#", with: renderReturnOrderNumber())

        // Reference Code number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_NUMBER#", with: "")

//        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_NUMBER#", with: renderRefCodeNumber())
        // CR number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CR_NUMBER#", with: renderCRNumber())
        // PRINTER NAME
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_NAME#", with: "")
//        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_NAME#", with: renderPrinterName())
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
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: renderItems(item: order))
        // NOTES .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#NOTES#", with: renderNotesInvoice())
        // total price section .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE_SECTION#", with:renderPriceSection())
        HTMLContent = HTMLContent.replacingOccurrences(of: "#INSURANCE_SECTION#", with:renderInsuranceSection())

        // make Footer For .
        HTMLContent = makeFooterFor(HTMLContent)
        // QR .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#QR#", with: renderQR(order:order ))
        // NOT_PAID
        HTMLContent = HTMLContent.replacingOccurrences(of: "#NOT_PAID#", with: renderNotPaid())
        
        return HTMLContent
      
    }
    @objc func renderInsuranceSection()->String{
        let currency = self.currency

       if self.for_kds {
           return ""
       }
        if let pos_order = self.order ,
           let order_id = pos_order.id,
           let insurance_order = pos_insurance_order_class.getInsuranceOrder(order_id: order_id) {
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
               HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE_TOTAL#", with: "\(insurance_order.amount_total.rounded_double(toPlaces: 2))" + " \(SharedManager.shared.getCurrencySymbol())")

               return HTMLContent
           }

       }
       return ""
   }
    func updateData(){
        if companyBill!.currency_id != 0
        {
            self.currency = companyBill!.currency_name
        }
        //        if self.isCopy == true
        //        {
        //            pos!.receipt_header = String(format: "%@<br />%@", pos!.receipt_header! , "Copy receipt")
        //        }
        pos!.receipt_footer = pos!.receipt_footer?.replacingOccurrences(of: "\n", with: "<br />")
    }
    
}


extension MWInvoiceComposer {
    //#FONT_SIZE_BORDER#
    
    func renderFontSize() -> String {
        let fonSize = setting!.font_size_for_kitchen_invoice
        if self.for_kds {
            return "font-size:\(fonSize)px;"
        }
        return ""
    }
    func renderFontSizeBorder() -> String {
        if self.for_kds {
            
            let fonSize = setting!.font_size_for_kitchen_invoice + 30
            return "font-size:\(fonSize )px;"
        }
        return "font-size:\(60 )px;"
        
    }
    func renderFontSizeOrderType() -> String {
        if self.for_kds {
            
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
        
        guard  let order = self.order  else {
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
    private func renderPriceSection() -> String {
        if self.hidePrice == true
        {
            if  self.for_kds
            {
                return get_total_qty_forKDS()
            }
            
            return ""
        }
        
        guard  let order = self.order  else {
            return ""
        }
        
        let setting = SharedManager.shared.appSetting()
        let taxValue = SharedManager.shared.getTaxValueInvoice()

        
        let currency = self.currency
        let sub_Order = self.sub_Order
        var tax_all = order.amount_tax
        var total_all = order.amount_total
        //        let delivery_amount =  order.orderType?.delivery_amount ?? 0
        var extra_amount:Double = 0
        var product_extra:product_product_class?
        var line_extra:pos_order_line_class?
        if !self.hideExtraPrice{
            if  self.pos!.extra_fees == true // order.orderType?.order_type == "extra"
            {
                let line = pos_order_line_class.get(order_id:  order.id!, product_id: self.pos!.extra_product_id!)
                if line != nil
                {
                    extra_amount = line!.price_subtotal_incl!
                    line_extra = line
                    product_extra = line!.product
                }
                
                
                
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
            if item.parent_order_id == 0 {
                continue
            }
            tax_all = tax_all + item.amount_tax
            total_all = total_all + item.amount_total
            
        }
        var  Discount:String = ""
        var CHANGE:String = ""
        let TAX:String = baseClass.currencyFormate( tax_all) + " " + SharedManager.shared.getCurrencySymbol()
        let TOTAL:String = baseClass.currencyFormate( total_all) + " " + SharedManager.shared.getCurrencySymbol()
        let tax_Precentage =   " (\(taxValue) %) "//" (\(Double(round(10*(tax_all*100/total_all))/10)) %) "
        var SUB_TOTAL:String = baseClass.currencyFormate( total_all - tax_all) + " " + SharedManager.shared.getCurrencySymbol()
        
        var total_subtotal = total_all
        var  tax_extra:Double = 0
        
        if extra_amount > 0
        {
           // tax_extra = (tax_all / 2  )
            tax_extra = (line_extra?.price_subtotal_incl ?? 0)  - (line_extra?.price_subtotal ?? 0)
            total_subtotal = total_all - extra_amount  //- (tax_all / 2  )
            
            
            extra_amount = extra_amount   - tax_extra
            
        }
        
        
        
        
        let TOTAL_QTY = (sub_Order?.count ?? 0) <= 0 ? "-" :"\(sub_Order?.count ?? 0)"
        var discount_tax:Double = 0
        if (sub_Order?.count ?? 0) == 0
        {
            // DISCOUNT
            let line_discount = order.get_discount_line()
            if line_discount != nil
            {
                
                Discount = baseClass.currencyFormate(line_discount?.price_subtotal ?? 0 ) + " " + SharedManager.shared.getCurrencySymbol()
                discount_tax = abs(  line_discount!.price_subtotal_incl!) - abs( line_discount!.price_subtotal!)
                
                total_subtotal = total_subtotal + ((line_discount?.price_unit)! * -1 ) //-  (tax_all - discount_tax)
                
                
            }
        }
        
        
        // Delivery
        var delivery_amount  = 0.0
        var tips_amount  = 0.0
        var service_amount  = 0.0

        var line_delivery:pos_order_line_class? = nil
        var line_tips:pos_order_line_class? = nil
        var line_service:pos_order_line_class? = nil

        if let order_type =  order.orderType {
//            line_delivery = pos_order_line_class.get (order_id:  order.id!, product_id: order_type.delivery_product_id)
            if line_delivery?.is_void  ?? false{
                line_delivery = nil
            }
            line_tips = pos_order_line_class.get (order_id:  order.id!, product_id: order_type.tip_product_id)
            if line_tips?.is_void  ?? false{
                line_tips = nil
            }
            line_service = pos_order_line_class.get (order_id:  order.id!, product_id: order_type.service_product_id)
            if line_service?.is_void  ?? false{
                line_service = nil
            }

        }
        var tax_delivery:Double = 0
        var tax_tips:Double = 0
        var tax_service:Double = 0
        var service_name:String = "Service Charge w/o -  تكلفة الخدمة بدون ضريبة"

        if line_delivery != nil
        {
            tax_delivery = line_delivery!.price_subtotal_incl! - line_delivery!.price_subtotal!
            delivery_amount = line_delivery!.price_subtotal!
            
            total_subtotal = total_subtotal  - line_delivery!.price_subtotal_incl!  //- (tax_all - tax_delivery)
            
        }
        if line_tips != nil
        {
            tax_tips = line_tips!.price_subtotal_incl! - line_tips!.price_subtotal!
            tips_amount = line_tips!.price_subtotal!
            
            total_subtotal = total_subtotal  - line_tips!.price_subtotal_incl!  //- (tax_all - tax_delivery)
            
        }
        if line_service != nil
        {
            let productService = line_service!.product
            let service_name_ar  = productService?.name_ar ?? ""
            let service_name_en  = productService?.name ?? ""
            if service_name_en != service_name_ar {
                service_name = [service_name_en, service_name_ar].joined(separator: " - ")
            }else{
                service_name = service_name_en
            }
            tax_service = line_service!.price_subtotal_incl! - line_service!.price_subtotal!
            service_amount = line_service!.price_subtotal!
            
            total_subtotal = total_subtotal  - line_service!.price_subtotal_incl!  //- (tax_all - tax_delivery)
            
        }
        
        SUB_TOTAL = baseClass.currencyFormate( total_subtotal  - (tax_all + discount_tax - tax_delivery - tax_extra -  tax_service - tax_tips ) ) + " " + SharedManager.shared.getCurrencySymbol()
        
        
        
        
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
            
            
            // NO itmes .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NO_ITEMS#", with:  renderNoItems(Total_items_qty.toIntString(),show: setting.show_number_of_items_in_invoice,separator_top: setting.show_number_of_items_in_invoice))
            // DISCOUNT .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DISCOUNT#", with: renderPriceDiscount(Discount  ))
            // TOTAL_QTY .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SUB_TOTAL_PRICE#", with: renderSubTotal(SUB_TOTAL, qty:TOTAL_QTY) )
            // DELIVERY .
            let deliveryHtml = renderPriceDelivery(delivery_amount != 0 ? "\(delivery_amount)": "")
            let tipsHTML = renderPriceProductDelivery(tips_amount != 0 ? "\(tips_amount)": "" , productDeliveryName: "Tips  -  الإكراميات")
            
            let serviceChargeHTML = renderPriceProductDelivery(service_amount != 0 ? "\(baseClass.currencyFormate(   service_amount) + " " + SharedManager.shared.getCurrencySymbol())": "" , productDeliveryName: service_name)
            let deliveryPriceSection = [deliveryHtml,tipsHTML,serviceChargeHTML].filter({!$0.isEmpty}).joined(separator: "\n")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DELIVERY#", with:deliveryPriceSection )
            
            // EXTRA .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXTRA#", with: renderPriceEXTRA(extra_amount != 0 ? " \((extra_amount ).toIntString()) \(SharedManager.shared.getCurrencySymbol())": "",product_extra ))
            // Tax disount_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TAX_DISCOUNT#", with: renderPriceTaxDiscount(isTaxFree ? TAX : ""))
            // VAT_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VAT_PRICE#", with: renderPriceVat(TAX,tax_Precentage,tax_all))
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
    private func renderPriceJournal(_ price:String, key:String) -> String {
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
    private func renderPriceTaxDiscount(_ price:String) -> String {
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
    private func renderPriceDelivery(_ price:String) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_delivry", ofType:"html")
        else {
            return ""
        }
        
        var new_price = price
        if self.order!.is_return()
        {
            let currency = self.currency
            
            new_price = "0 " + SharedManager.shared.getCurrencySymbol()
        }
        
        
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            let title = (order?.amount_tax ?? 0) <= 0 ? "Delivery - التوصيل" : "Delivery w/o - التوصيل بدون ضريبة"
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TITLE#", with: title)

            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: new_price)
            return HTMLContent
        } catch {
             SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price delivry.
    private func renderPriceProductDelivery(_ price:String,productDeliveryName:String) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_product_delivery", ofType:"html")
        else {
            return ""
        }
        
        var new_price = price
        if self.order!.is_return()
        {
            let currency = self.currency
            
            new_price = "0 " + SharedManager.shared.getCurrencySymbol()
        }
        
        
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: new_price)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PRODUCT_DELIVERY_NAME#", with: productDeliveryName)

            return HTMLContent
        } catch {
             SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    
    //MARK:- price EXTRA.
    private func renderPriceEXTRA(_ price:String,_ product_extra:product_product_class?) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_extra", ofType:"html")
        else {
            return ""
        }
        
        var new_price = price
        if self.order!.is_return()
        {
            //            let currency = self.currency
            //
            //            new_price = "0 " + currency
            //return ""
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
    private func renderPriceVat(_ price:String,_ tax_Precentage:String,_ totalTax:Double) -> String {
        if for_waiter {
            return ""
        }
        if price.isEmpty  {
            return ""
        }
        if totalTax == 0{
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
    private func renderPriceTotal(_ price:String) -> String {
        if price.isEmpty  {
            return ""
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_total", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            let title = (order?.amount_tax ?? 0) <= 0 ? "Total - الإجمالي" :  "Total include Tax - الإجمالي شامل الضريبة"
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TITLE#", with: title)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
             SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price sub total.
    private func renderSubTotal(_ price:String, qty:String) -> String {
        if for_waiter  {
            return ""
        }
        if price.isEmpty || qty.isEmpty {
            return ""
        }
        if (order?.amount_tax ?? 0 ) <= 0 {
           // return "<hr>"
        }
        guard let pathPriceChange = Bundle.main.path(forResource: "price_subtotal", ofType:"html")
        else {
            return ""
        }
        
        var new_price = price
        if self.order!.is_return()
        {
            let extra_fees = SharedManager.shared.posConfig().extra_fees
            
            if self.order!.delivery_amount != 0 || self.order!.is_have_promotions() || extra_fees == true
            {
                let currency = self.currency
                
                new_price = "0 " + SharedManager.shared.getCurrencySymbol()
            }
            
        }
        
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            let title = (order?.amount_tax ?? 0 ) <= 0 ? "Subtotal - المجموع" : "Subtotal - المجموع بدون ضريبة "
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TITLE#", with: title)

            HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY#", with: qty)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: new_price)
            return HTMLContent
        } catch {
             SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- price return.
    private func renderPriceReturnPayment(_ currency:String) -> String {
        return ""
        
        var price = ""
        
        if self.order!.sub_orders.count != 0
        {
            var total_return =  0.0
            for ord in self.order!.sub_orders
            {
                total_return = total_return + ord.amount_return
            }
            price = total_return.toIntString() + SharedManager.shared.getCurrencySymbol()
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
    private func renderPricePayment(_ price:String) -> String {
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
    private func renderNoItems(_ price:String,show:Bool,separator_top:Bool) -> String {
        if price.isEmpty  {
            return ""
        }
        
        
        guard  self.order!.amount_total > 0   else {
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
    private func renderPriceDiscount(_ price:String) -> String {
        if price.isEmpty  {
            return ""
        }
        var name_discount_en = ""
        if SharedManager.shared.appSetting().enable_show_discount_name_invoice {
            name_discount_en = self.order?.get_discount_line()?.discount_display_name ?? ""
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
            let title = (order?.amount_tax ?? 0) <= 0 ? "Discount #NAME_ENG# - الخصم" : "Discount w/o #NAME_ENG# - الخصم بدون ضريبة"
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TITLE#", with: title)

            HTMLContent = HTMLContent.replacingOccurrences(of: "#NAME_ENG#", with: name_discount_en)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: price)
            return HTMLContent
        } catch {
             SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    //MARK:- Loyalty POINTS.
    private func renderLoyaltyPOINTS() -> String {
        if self.order!.partner_id == 0  {
            return ""
        }
        
        if self.setting!.show_loyalty_details_in_invoice == false
        {
            return ""
        }
        
        
        let free_points = self.order!.loyalty_points_remaining_partner + self.order!.loyalty_earned_point  - self.order!.loyalty_redeemed_point
        
        let free_amount = self.order!.loyalty_amount_remaining_partner + self.order!.loyalty_earned_amount  - self.order!.loyalty_redeemed_amount
        
        guard let pathPriceChange = Bundle.main.path(forResource: "loyalty", ofType:"html")
        else {
            return ""
        }
        do {
            var HTMLContent = try String(contentsOfFile: pathPriceChange)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#loyalty_points_remaining_partner#", with: self.order!.loyalty_points_remaining_partner.toIntString()  )
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#loyalty_earned_point#", with: self.order!.loyalty_earned_point.toIntString()  )
            HTMLContent = HTMLContent.replacingOccurrences(of: "#loyalty_redeem_point#", with: self.order!.loyalty_redeemed_point.toIntString()  )
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#free_points#", with: free_points.toIntString()  )
            HTMLContent = HTMLContent.replacingOccurrences(of: "#free_amount#", with: free_amount.toIntString() + " " + SharedManager.shared.getCurrencySymbol())
            
            return HTMLContent
        } catch {
             SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    
    //MARK:- price change.
    private func renderPriceChange(_ price:String) -> String {
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
    private func renderTypeOrder() -> String {
        var type: String = String(self.order!.orderType?.display_name  ?? "")
        let typeReference: String = String(self.order!.delivery_type_reference  ?? "")
        
        
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
    private func renderDriverName() -> String {
        if !(self.order!.orderType?.required_driver ?? false) {
            if (self.order!.orderType?.show_customer_info ?? false) {
                return renderCustDeliveryInfo()
            }
        }
        
        guard let driver = self.order!.driver , let name = driver.name, let code = driver.code else {
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
    private func renderCustDeliveryInfo() -> String {
        //        if !(self.order!.orderType?.show_customer_info ?? false) {
        //            return ""
        //        }
        guard let customer = self.order!.customer  else {
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
    private func renderQR(from value:String) -> String {
        if value.isEmpty {
            return ""
        }
        let qr_image = SharedManager.shared.qrCodeGenerator.base64Data(for: "\(value)")
        if var HTMLContent = CashHtmlFiles.shared.qr_html{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: qr_image)
            return HTMLContent
        }
        return ""

    }
    //MARK:- qr html.
    private func renderQR(order:pos_order_class) -> String {
        if (for_waiter ){
            if !setting!.enable_qr_for_draft_bill {
                //  return ""
            }
        }else{
            if (!qr_print){
                return ""
            }
        }
        
       
        
        let name = self.order!.name ?? ""
        if name.isEmpty {
            return ""
        }
        
        let companyName = companyBill!.name
        let tax_number = self.getVatNumber()
        let order_time_stamp = Date(strDate:self.order!.write_date ?? "", formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss'Z'", UTC: false)
        let totalVat = String(format: "%.2f", self.order!.amount_tax)
        let totalOrder = String(format: "%.2f", self.order!.amount_total)  //self.order!.amount_total
        var tvl_base64 = ""

        if setting?.enable_cloud_qr_code ?? false{
            let qrValue = self.order?.getCloudQRCodde() ?? ""
            if qrValue.isEmpty || qrValue.localizedLowercase == MWConstants.generate_qr_phase_1.lowercased(){
                tvl_base64 = self.generateLocalQr(order:order, companyName:companyName,tax_number:tax_number,order_time_stamp:order_time_stamp,totalVat:totalVat,totalOrder:totalOrder)
            }else {
                tvl_base64 = qrValue
            }
        }else{
            tvl_base64 = self.generateLocalQr(order:order, companyName:companyName,tax_number:tax_number,order_time_stamp:order_time_stamp,totalVat:totalVat,totalOrder:totalOrder)
           

        }
        if tvl_base64.isEmpty {
            return ""
        }
        
        //MARK: - generate QRCode For Invoice Tlv EnCoding
        let qr_image = SharedManager.shared.qrCodeGenerator.base64Data(for: "\(tvl_base64)")
        if var HTMLContent = CashHtmlFiles.shared.qr_html{
            var widthQR = 300
            if (SharedManager.shared.phase2InvoiceOffline ?? false) || (setting?.enable_cloud_qr_code ?? false){
                widthQR = 600
            }
            HTMLContent = HTMLContent.replacingOccurrences(of: "#WIDTH_IMAGE#", with: "\(widthQR)")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: qr_image)
            return HTMLContent
        }
        return ""
    }
    private func generateLocalQr(order:pos_order_class, companyName:String,tax_number:String,order_time_stamp:String,totalVat:String,totalOrder:String) -> String{
        if SharedManager.shared.phase2InvoiceOffline ?? false{
            if let saveInvoice = pos_e_invoice_class.getBy(order.uid ?? ""),let qrValueSaved = saveInvoice.qr_code_value, !qrValueSaved.isEmpty{
                return qrValueSaved
            }
        }
        var tvl_base64 = ""
        let invoiceTlvModel = InvoiceTlvModel()
        var e_invoice_pih = cash_data_class.get(key: "e_invoice_pih")
        if ((e_invoice_pih ?? "").isEmpty ?? true){
            e_invoice_pih = XMLInvoiceHelper.generateInvoiceXmlSha(xmlContent: "0").xmlSha
        }
        var unSginXmlContent = ""
        var unSginXmlWithQRContent = ""
        var xmlWithExt = ""
        var xmlSginHash = ""
        var ublExtensionsModel: UBLExtensionsModel? = nil

        //MARK: - Invoice Tlv inital
        invoiceTlvModel.sellerName = companyName
        invoiceTlvModel.vatNumber = tax_number
        invoiceTlvModel.timeStamp = order_time_stamp
        invoiceTlvModel.totalVat = totalVat
        invoiceTlvModel.totalWithVat = totalOrder
        if SharedManager.shared.phase2InvoiceOffline ?? false{
            invoiceTlvModel.totalVat = totalVat.replacingOccurrences(of: "-", with:"" )
            invoiceTlvModel.totalWithVat = totalOrder.replacingOccurrences(of: "-", with:"" )
            let x509PublicKey = MWX509Certificate.shared.getPublicKeyValue()
            let x509Signature = MWX509Certificate.shared.getSignatureValue()
            var xmlInVoiceModel = XMLInVoiceModel(order: order )
            let sginTime = xmlInVoiceModel.writedateStr + "T" + xmlInVoiceModel.writeTime
            let templateContent = XMLInvoiceHelper.getTemplate(model:xmlInVoiceModel,PIH: e_invoice_pih ?? "" )
            xmlWithExt = templateContent.teemplateWithEx
            unSginXmlWithQRContent = templateContent.teemplateWithQR

            let xmlHashUnsgin = XMLInvoiceHelper.generateInvoiceXmlSha(xmlContent: templateContent.template)
            unSginXmlContent = xmlHashUnsgin.canonicalizeXml
            if let unSginXmlHash = xmlHashUnsgin.xmlSha  {
                invoiceTlvModel.xmlInvoice = unSginXmlHash
                invoiceTlvModel.signature = (InvoiceSignature.shared.loadInvoiceSignature(hashInvoice:unSginXmlHash) ?? "")
                
                 ublExtensionsModel = UBLExtensionsModel(xml_content:unSginXmlContent , signature: invoiceTlvModel.signature, invoice_hash: unSginXmlHash,signing_time: sginTime)
                invoiceTlvModel.timeStamp = sginTime

                xmlWithExt = xmlWithExt.replacingOccurrences(of: "#UBLExtension_TEMPLATE#", with: UBLExtensionsHelper.getTemplate(ublExtensionsModel!) )
            }
                
            
            
            if let x509Signature = x509Signature{
                invoiceTlvModel.x509Signature = x509Signature
            }
            if let x509PublicKey = x509PublicKey{
                invoiceTlvModel.x509PublicKey = x509PublicKey
            }
            let tvl_hex: Data =  invoiceTlvModel.packageData()
            tvl_base64 =  tvl_hex.base64EncodedString(options: [])
            xmlWithExt = xmlWithExt.replacingOccurrences(of: "#Additional_Document_Reference_TEMPLATE#", with: AdditionalDocumentReferenceHelper.getTemplate(PIH: e_invoice_pih ?? "" , ICV: order.l10n_sa_chain_index ?? 1, QrCode: tvl_base64 ))
            let xmlSginHashObject =  XMLInvoiceHelper.generateInvoiceXmlSha(xmlContent: xmlWithExt)
            xmlSginHash = xmlSginHashObject.xmlSha ?? "" //xmlWithExt.mwsha256() // XMLInvoiceHelper.getSHA256(for: xmlWithExt ) ?? ""
            xmlWithExt = xmlSginHashObject.canonicalizeXml
        }else{
            //MARK:- Invoice Tlv EnCoding
            let tvl_hex: Data =  invoiceTlvModel.packageData()
            tvl_base64 =  tvl_hex.base64EncodedString(options: [])

        }
        if SharedManager.shared.phase2InvoiceOffline ?? false {
            pos_e_invoice_class(from: invoiceTlvModel, order,e_invoice_pih ?? "", tvl_base64,xmlWithExt,xmlSginHash,signedPropertiesHash: ublExtensionsModel?.signed_properties_hash ?? "",base64_content_unsgin:unSginXmlContent,signing_time: ublExtensionsModel?.signing_time ?? "").save()
            var e_invoice_curebt_hash  = invoiceTlvModel.xmlInvoice
            cash_data_class.set(key: "e_invoice_pih", value: e_invoice_curebt_hash)

            MWQueue.shared.firebaseQueue.async {
                FireBaseService.defualt.updateEinvoiceFRModel(pih:e_invoice_curebt_hash , order_uid: order.uid ?? "")
            }
        }
        return tvl_base64
    }
    
    //MARK:- copy right invocie.
    private func renderCopyRight() -> String {
        
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
    private func renderPrintedDateInvocie(date:String) -> String {
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
    private func renderNotesInvoice() -> String {
        let isKDS = self.for_kds
        if !setting!.show_invocie_notes && isKDS {
            return ""
        }
        var notes = self.order!.note
        notes = notes.replacingOccurrences(of: "\r\n", with: "<br/>")
        if notes.isEmpty {
            return ""
        }
        if var HTMLContent = CashHtmlFiles.shared.note_invoice{
            if SharedManager.shared.appSetting().enable_show_unite_price_invoice {
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
    private func renderDateOrder() -> String {
        let date = Date(strDate: self.order!.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: "yyyy/MM/dd hh:mm a", UTC: false)
        
        
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
    private func renderTableNumber() -> String {
        let number = self.order!.table_name ?? ""
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
    private func renderCustomerName() -> String {
        guard let customer  = self.order!.customer else {
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
    private func renderCustomerVAT() -> String {
        guard let customer  = self.order!.customer else {
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
    private func renderQtyItemPrice() -> String {
        let isKDS = self.for_kds
        if isKDS {
            return CashHtmlFiles.shared.qty_item_price_kds ?? ""
        }
        if setting?.enable_show_unite_price_invoice ?? false {
            return CashHtmlFiles.shared.qty_item_unite_price ?? ""
        }
        return CashHtmlFiles.shared.qty_item_price_pos ?? ""
    }
    //MARK:- Cashier NAME.
    private func renderCashierName() -> String {
        if self.for_kds {
            if hideCashierKDS {
                return ""
            }
        }
        let name = (self.order!.write_user_name ?? "").trunc(length: 15)
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
    func renderResendKDS()->String{
        if !self.for_kds {
            return ""
        }
        if !isKDSResend {
            return ""
        }
        guard let imageBase64 = #imageLiteral(resourceName: "send-back.png").toBase64() else {
            return ""
        }
        let resent_back_html = (CashHtmlFiles.shared.resend_try ?? "").replacingOccurrences(of:"#VALUE#",with: imageBase64)
        return resent_back_html
    }
    //MARK:- POS NAME.
    private func renderPOS() -> String {
        let POS = self.order!.write_pos_name ?? ""
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
    private func renderPrinterName() -> String {
        if !self.for_kds {
            return ""
        }
        let PrinterName = self.printerName
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
    private  func renderCRNumber() -> String {
        if self.for_kds {
            return ""
        }
        let CRNumber =  companyBill!.company_registry
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
    private  func renderRefCodeNumber() -> String {
        if (for_waiter ){
            return ""
        }
        if self.hideRef
        {
            return ""
        }
        let posWriteCode = self.order!.write_pos_code ?? "\(self.order!.write_pos_id ?? 0)"
        let orderNumber =  String(format: "%03d", self.order!.sequence_number)
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
    //MARK:- VAT Number.
    private  func renderVATNumber() -> String {
        if self.for_waiter  {
            return ""
        }
        if self.for_kds {
            return ""
        }
        if self.hideVat  {
            return ""
        }
        let VatNumber = self.getVatNumber()
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
    private func renderOrderNumber() -> String {
        var orderNumber = "Order #\(self.order!.sequence_number)"
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
                if for_kds {
                    fonSize = setting!.font_size_for_kitchen_invoice - 50
                    if fonSize < 10.0 {
                        fonSize = 10
                    }
                }
                let pos_creat_code = self.order!.create_pos_code ?? ""
                if pos_creat_code.isEmpty {
                    
                    orderNumber = "Order #\(self.order!.sequence_number) <span style=\"font-size: 30px;\">[Online]</span>"
                }else{
                    orderNumber = "Order #\(self.order!.sequence_number) <span style=\"font-size: 10px;\">[\(pos_creat_code)]</span>"
                }
                
            }
            
        }
        
        if var HTMLContent = CashHtmlFiles.shared.order_number{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: orderNumber)
            if self.isCopy == true
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

    private func renderFullOrderNumber() -> String {
        if self.for_kds{
            return ""
        }
//        let fullOrderNumber = self.order!.name!
        let fullOrderNumber = self.order!.getBill_uidStatic()
//        if self.objecPrinter!.showOrderReference
//        {
            return """
             <tr>
                 <td class="bold-title-left">Invoice #</td>
                 <td class="normal-title-center" style=" max-width: 480px;">\(fullOrderNumber)</td>
                 <td class="bold-title-right" style="width: 250px;"># الفاتورة</td>
             </tr>
             """
        //}
//        else
//        {
//            return ""
//        }
  
    }
    private func renderReturnOrderNumber() -> String {
        if let nameReturn = self.return_name{
            return """
             <tr>
                 <td class="bold-title-left">Reference #</td>
                 <td class="normal-title-center" style=" max-width: 480px;">\(nameReturn)</td>
                 <td class="bold-title-right" style="width: 250px;"># مرجعي</td>
             </tr>
             """
        }else{
            return ""
        }
    }
    
    //MARK:- The Oddo Header.
    private func renderOdooHeader() -> String {
        var header = ""
        //        if self.for_kds == false
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
        if  self.for_waiter
        {
            return header
            
        }
        if self.hideHeader
        {
//            if let odooHeader  = self.custom_header
//            {
                header = self.custom_header
                
//            }else{
//                header = ""
//            }
            
        }else{
            let posHeader = pos!.receipt_header!
            if self.for_waiter
            {
                header = posHeader + "<br />  Not paid"
            }
            
            if self.for_kds == false
            {
                if setting!.enable_simple_invoice_vat == true
                {
                    if (order?.amount_tax ?? 0) <= 0 {
                        header = posHeader + "</b>"

                    }else{
                        if hidSimpleVatTitle ?? false {
                            header = posHeader + "</b>"
                        }else{
                            header = posHeader + "<br />" + "<b>" + "فاتورة ضريبية مبسطة" + "</b>"
                        }
                    }
                }
                else
                {
                    if hidSimpleVatTitle ?? false {
                        header = posHeader + "</b>"
                    }else{
                        header = posHeader + "<br />" + "<b>" + "فاتورة ضريبية " + "</b>"
                    }
                    
                }
            }
        }
        
        if self.order!.parent_order_id != 0
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
    private func renderLogo() -> String {
        if (for_waiter ){
            return renderWaterMark()
        }
        if  self.hideLogo
        {
            return ""
        }
        let width = setting!.receipt_logo_width <= 0 ? 100 :  setting!.receipt_logo_width
       
        if ((logoImage ?? "").isEmpty) {
            return ""
        }
       
       
        if var HTMLContent = CashHtmlFiles.shared.logo_company {
            HTMLContent = HTMLContent.replacingOccurrences(of: "#WIDTH#", with: "\(width)")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: logoImage ?? "")
            return HTMLContent
        }
     
        return ""
    }
    //MARK:- The Oddo Footer.
    private func makeFooterFor(_ content:String) -> String {
        var contentHTML = content
        var footer = ""
        let print_count = pos_order_helper_class.get_print_count(order_id:  self.order!.id!)
        let printerName =   self.printerName
        if self.hideFooter || self.for_waiter
        //        if self.hideFooter
        {
            
            if !self.for_waiter{
                let datePrint =  "Printed at: " + Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: false)
                footer = "#Print: \(print_count) / \(printerName)" +  "<br/> \(datePrint)"
            }
            // copy right .
            contentHTML = contentHTML.replacingOccurrences(of: "#COPY_RIGHT#", with: "")
            // ref invoice .
            contentHTML = contentHTML.replacingOccurrences(of: "#REF_DATE#", with: "")
            
        }else{
            footer  = pos!.receipt_footer!
            
            if self.for_kds == false
            {
                // copy right .
                contentHTML = contentHTML.replacingOccurrences(of: "#COPY_RIGHT#", with: renderCopyRight())
            }
            if self.hideRef
            {
                // ref invoice .
                contentHTML = contentHTML.replacingOccurrences(of: "#REF_DATE#", with: "")
            }else{
                let createAtDate = Date(strDate: self.order!.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: "yyyy/MM/dd hh:mm a", UTC: false)
                var createAt =  "Opened at: \(createAtDate)"
                
                if self.order!.create_user_name != self.order!.write_user_name{
                    createAt += (" by " + (self.order!.create_user_name ?? "") )
                }
                
                //                let datePrint =  "Printed at: " + Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: false) + "<br />"
                contentHTML = contentHTML.replacingOccurrences(of: "#REF_DATE#", with: renderPrintedDateInvocie(date:   createAt) )
                /* if self.sub_Order.count > 0
                 {
                 var parent_orderID_server = self.sub_Order[0].name
                 if !parent_orderID_server!.isEmpty
                 {
                 parent_orderID_server = parent_orderID_server?.replacingOccurrences(of: "Order-", with: "")
                 //  footer = footer + "<br />" + "Ref Return  \(String(parent_orderID_server!)) "
                 }
                 }*/
                if self.for_kds == true
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
    private func renderWaterMark() -> String {
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
    private func renderNotPaid() -> String {
       
        if self.hideNotPaid {
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
    func getVatNumber() -> String{
        if (pos!.vat ?? "").isEmpty{
           return companyBill?.vat ?? ""
        }else{
            return pos!.vat ?? ""
        }
    }
}

