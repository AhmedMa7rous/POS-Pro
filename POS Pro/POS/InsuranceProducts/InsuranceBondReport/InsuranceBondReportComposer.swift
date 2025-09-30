//
//  InsuranceBondReportComposer.swift
//  pos
//
//  Created by M-Wageh on 25/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

class pos_insurance_order_class : NSObject{
    var dbClass:database_class?
    
    var id:Int?
    var insurance_id:Int?
    var order_id:Int?
    
    
    init(fromDictionary dictionary: [String:Any] ){
        super.init()
        id = dictionary["id"] as? Int ?? 0
        insurance_id = dictionary["insurance_id"] as? Int ?? 0
        order_id = dictionary["order_id"] as? Int ?? 0
        dbClass = database_class(table_name: "pos_insurance_order", dictionary: self.toDictionary(),id: id!,id_key:"id")
    }
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["insurance_id"] = insurance_id
        dictionary["order_id"] = order_id
        
        return dictionary
    }
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        _ =  dbClass!.save()
    }
    static func saveWith(order_id:Int, insurance_id:Int){
        let pos_insurance_order = pos_insurance_order_class.init(fromDictionary: [:])
        pos_insurance_order.order_id = order_id
        pos_insurance_order.insurance_id = insurance_id
        pos_insurance_order.save()
    }
    static func getInsuranceOrder(order_id:Int) -> pos_order_class?{
        let sql = """
SELECT
    *
from
    pos_order po2
where
    po2.id in (
    SELECT
        pio.insurance_id
    from
        pos_insurance_order pio ,
        pos_order po
    WHERE
        pio.order_id = po.id
        and po.id = \(order_id))
"""
        let cls = pos_insurance_order_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        if arr.count > 0 ,  let orderDic = arr.first{
            return pos_order_class(fromDictionary: orderDic)

        }
        return nil
    }

}

class InsuranceBondReportComposer:InvoiceComposer {
    var order_builder:orderPrintBuilderClass?
//    override init(_ object: orderPrintBuilderClass) {
//        super.init(object)
//    }
     init(_ order: pos_order_class , printerName:String) {
        let order_print = orderPrintBuilderClass(withOrder: order,subOrder: [])
         super.init(order_print)
        order_print.hideFooter = true
        order_print.hideCalories = true
        order_print.for_insurance = true
        order_print.hideHeader = true
        order_print.hideLogo = false
        order_print.hidePrice = false
        order_print.hideFooter = false
        order_print.hideRef = false
        order_print.hideVat = false
        order_print.print_new_only = false
        order_print.printerName = printerName
         self.order_builder = order_print
         super.objecPrinter = order_print
    }
 
    
    override func renderInvoice() -> String! {
        
        guard let objecPrinter = order_builder,  let insuranceOrder = objecPrinter.order else {
            return ""
        }
        updateData()
        
        var HTMLContent = HTMLTemplateGlobal.shared.getTemplateHtmlContent(.INSURANCE)
        let rightMargin = SharedManager.shared.appSetting().margin_invoice_right_value
        let leftMargin = SharedManager.shared.appSetting().margin_invoice_left_value 
        if rightMargin == 25 && leftMargin == 35{
            let widthValue = 960 - (rightMargin + leftMargin )
            HTMLContent = HTMLContent.replacingOccurrences(of: "#WIDTH_VALUE#", with: "width:\(widthValue)px;" )
        }else{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#WIDTH_VALUE#", with: "" )
        }
       
        HTMLContent = HTMLContent.replacingOccurrences(of: "#MARGIN_LEFT_VALUE#", with: "\(leftMargin)px" )
        HTMLContent = HTMLContent.replacingOccurrences(of: "#MARGIN_RIGHT_VALUE#", with: "\(rightMargin)px" )
        // The logo image.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO#", with: renderLogo())
        // Oddo Header.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ODOO_HEADER#", with: renderOdooHeader())
        // order number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_NUMBER#", with: renderOrderNumber())
        // VAT number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#VAT_NUMBER#", with: "")
        //Full Reference number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#FULL_ORDER_NUMBER#", with: "")
        // Reference Code number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_NUMBER#", with: "")

//        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_NUMBER#", with: renderRefCodeNumber())
        // CR number.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CR_NUMBER#", with: "")
        // PRINTER NAME
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_NAME#", with: "")
        // POS name.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NUMBER#", with: renderPOS())
        // Cashier name.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CASHIER#", with: renderCashierName())
        // Customer name.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CUSTOMER#", with: renderCustomerName())
        // Customer VAT.
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CUSTOMER_VAT#", with: renderCustomerPhone())
        // Table number .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#TABLE_NUMBER#", with: "")
        // Date Order .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#DATE_ORDER#", with: renderDateOrder())
        // Type Order .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_TYPE#", with: renderTypeOrder())
        // QTY ITEM PRICE .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY_ITEM_PRICE#", with: renderQtyItemPrice())
        // Items .
        if let order = self.order_builder?.order{
        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: renderItems(item: order))
        }else{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: "")

        }
        // NOTES .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#NOTES#", with: renderNotesInvoice())
        // total price section .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE_SECTION#", with:renderPriceSection())
        HTMLContent = HTMLContent.replacingOccurrences(of: "#INSURANCE_SECTION#", with:"")

        // make Footer For .
        HTMLContent = makeFooterFor(HTMLContent)
        // QR .
        HTMLContent = HTMLContent.replacingOccurrences(of: "#QR#", with: "")
        // NOT_PAID
        HTMLContent = HTMLContent.replacingOccurrences(of: "#NOT_PAID#", with: "")
        
        return HTMLContent
    }
    func renderCustomerPhone() -> String{
        guard  let insuranceOrder = order_builder!.order else {
            return ""
        }

        let phone = insuranceOrder.customer?.phone ?? "-----"
        if var HTMLContent = CashHtmlFiles.shared.item_td_html{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EN_NAME#", with: "Cust.Phone")

            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: phone)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#AR_NAME#", with: "جوال العميل")

            return HTMLContent
        }
        return ""
    }
    override func renderNotesInvoice() -> String {
        let notes: String = SharedManager.shared.posConfig().insurance_product_delivery_note ?? ""

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
    override  func renderOdooHeader() -> String {
        let header =   "<h3>" + "Insurance Receipt - إيصال تأمين" + "</h3>"
        if var HTMLContent = CashHtmlFiles.shared.odoo_header{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: header)
            return HTMLContent
        }
       
        return ""
    }
    override func renderTypeOrder() -> String {
//        let header = SharedManager.shared.posConfig().insurance_product_delivery_note ?? ""
        var type = "A security deposit has been paid for the following items:-" + "</br>" + "تم دفع مبلغ تأمين مقابل الاصناف التالية :-"
//        var type: String = SharedManager.shared.posConfig().insurance_product_delivery_note ?? ""
        
        
        if type.isEmpty {
            return ""
        }
        
        if var HTMLContent = CashHtmlFiles.shared.order_type{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#FONT_SIZE_ORDER_TYPE#", with: renderFontSizeOrderType())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: type)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DIVER_NAME#", with: renderDriverName())
            return HTMLContent
        }
        return ""
    }
    override func renderOrderNumber() -> String {
        let insuranceNumber = "#\(self.order_builder!.order!.sequence_number)"

        if var HTMLContent = CashHtmlFiles.shared.order_number{
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: insuranceNumber)
            HTMLContent =  HTMLContent.replacingOccurrences(of: "#COPY#", with: "")

//            if  self.objecPrinter!.isCopy == true
//            {
//                HTMLContent =  HTMLContent.replacingOccurrences(of: "#COPY#", with:"<tr><td colspan=\"3\"class=\"bold-title-center\">Copy receipt      </td></tr>"  )
//            }else{
//                HTMLContent =  HTMLContent.replacingOccurrences(of: "#COPY#", with: "")
//            }
            return HTMLContent
      
        }
        return  ""

    }
    override func makeFooterFor(_ content: String) -> String {
        var contentHTML = content
        contentHTML = contentHTML.replacingOccurrences(of: "#COPY_RIGHT#", with: "")
        // ref invoice .
        contentHTML = contentHTML.replacingOccurrences(of: "#REF_DATE#", with: "")

        contentHTML = contentHTML.replacingOccurrences(of: "#COPY_RIGHT#", with: renderCopyRight())
        contentHTML = contentHTML.replacingOccurrences(of: "#REF_DATE#", with: "")
        contentHTML = contentHTML.replacingOccurrences(of: "#REF_DATE#", with: "" )
        let footer  = "" //pos!.receipt_footer!

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
    override func renderPriceSection() -> String {
        guard  let insuranceOrder = objecPrinter!.order else {
            return ""
        }

        if var HTMLContent = CashHtmlFiles.shared.price_section{
            
            
            // NO itmes .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NO_ITEMS#", with:  "")
            // DISCOUNT .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DISCOUNT#", with: "")
            // TOTAL_QTY .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SUB_TOTAL_PRICE#", with: "")
            // DELIVERY .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DELIVERY#", with: "")
            // EXTRA .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXTRA#", with: "")
            // Tax disount_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TAX_DISCOUNT#", with: "")
            // VAT_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VAT_PRICE#", with: "")
            // TOTAL_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTAL_PRICE#", with: renderPriceTotal("\(insuranceOrder.amount_total.rounded_app())"))
            // ACCOUNT_JOURNAL .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ACCOUNT_JOURNAL#", with: "")
            // CASH_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CASH_PRICE#", with: "")
            // CHANGE_PRICE .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CHANGE_PRICE#", with: "")
            // CUSTOMER LOYALTY POINTS .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Loyalty#", with:"")
            // CASH_PRICE_RETURN .
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CASH_PRICE_RETURN#", with:  "")
            
            
            
            return HTMLContent
            
        }
        return ""
        
    }
}

/**
 
 HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO#", with: renderLogo())
 //  COMPANY.
 HTMLContent = HTMLContent.replacingOccurrences(of: "#COMPANY#", with: pos?.company_name ?? "")
 // POS.
 HTMLContent = HTMLContent.replacingOccurrences(of: "#POS#", with: pos?.name ?? "")
 // PHONE_CUSTOMER.
 HTMLContent = HTMLContent.replacingOccurrences(of: "#PHONE_CUSTOMER#", with: insuranceOrder.customer?.phone ?? "")
 //NUMBER Insurance.
 HTMLContent = HTMLContent.replacingOccurrences(of: "#NUMBER#", with: "#" + insuranceOrder.sequence_number_full)
 // CUSTOMER_NAME.
 HTMLContent = HTMLContent.replacingOccurrences(of: "#CUSTOMER_NAME#", with: insuranceOrder.customer?.name ?? "")

//        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_NUMBER#", with: renderRefCodeNumber())
 // NOTE_ODOO.
 HTMLContent = HTMLContent.replacingOccurrences(of: "#NOTE_ODOO#", with: pos?.insurance_product_delivery_note ?? "")
 // QTY_ITEM_PRICE .
 HTMLContent = HTMLContent.replacingOccurrences(of: "#QTY_ITEM_PRICE#", with: renderQtyItemPrice())
 // ITEMS .
 HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: renderItems(item: insuranceOrder))
 // total PRICE_SECTION
 HTMLContent = HTMLContent.replacingOccurrences(of: "#PRICE_TOTAL#", with:"\(insuranceOrder.amount_total.rounded_app())" )
 
 let dateTimeString = insuranceOrder.create_date ?? ""
 let dateString = Date(strDate: dateTimeString,
                       formate: baseClass.date_formate_database,UTC: true).toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)
 
 let timeString = Date(strDate: dateTimeString,
                       formate: baseClass.date_formate_database,
                       UTC: true).toString(dateFormat: baseClass.date_fromate_time, UTC: false)

 // DATE
 HTMLContent = HTMLContent.replacingOccurrences(of: "#DATE#", with: dateString)
 // TIME.
 HTMLContent = HTMLContent.replacingOccurrences(of: "#TIME#", with: timeString)
 // COPY_BY  .
 HTMLContent = HTMLContent.replacingOccurrences(of: "#COPY_BY#", with: renderCopyRight())
 */
