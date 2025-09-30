//
//  invoiceTaxClass.swift
//  pos
//
//  Created by khaled on 20/12/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class invoiceTaxClass: NSObject {
    
    static func getPdf(order:pos_order_class) -> String
    {
        let pathToInvoice = Bundle.main.path(forResource: "invoiceTax", ofType:"html")
        do {
            var HTMLContent = try String(contentsOfFile: pathToInvoice!)
            let pos = SharedManager.shared.posConfig()
            let company = pos.company
            let logoImage = FileMangerHelper.shared.getLogoBase64()
            
            //            var discount_tax:Double = 0
            var  Discount:String = ""
            
            // DISCOUNT
            let line_discount = order.get_discount_line()
            if line_discount != nil
            {
                
                Discount = baseClass.currencyFormate(line_discount?.price_subtotal ?? 0 )
                //                    discount_tax = abs(  line_discount!.price_subtotal_incl!) - abs( line_discount!.price_subtotal!)
                
            }
            else
            {
                HTMLContent = HTMLContent.replacingOccurrences(of: """
                                            <tr>
                                                <td class="text-left"> Discount </td>
                                                <td class="text-right"> الخصم
                                                </td>
                                                <td class="text-center">#discount #CURRENCY#</td>
                                            </tr>
                    """, with:  "")
                
            }
            
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#logo", with: logoImage)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#companyName", with: company?.name ?? "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#vatNo", with: company?.vat ?? "")
            
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#cashier", with: order.cashier?.name ?? "")
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#invoiceNo", with: order.name!)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#invoiceDate", with: order.create_date!)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#paid", with: order.amount_paid.toIntString())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#due", with:  order.amount_return.toIntString())
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TotalWithOutTax", with:  ( order.amount_total -   order.amount_tax).toIntString())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#discount", with:  Discount )
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TotalWithTax", with:  ( order.amount_total -   order.amount_tax).toIntString())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Tax", with:  order.amount_tax.toIntString())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#Total", with:  order.amount_total.toIntString())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ADRESS#", with:  SharedManager.shared.getClientCountry())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CURRENCY#", with:  SharedManager.shared.getCurrencyName())
            if let orderType = order.orderType {
                let pathToOrderTypeA4 = Bundle.main.path(forResource: "ORDER_TYPE_A4", ofType:"html") ?? ""
                var orderTypeHTML = try String(contentsOfFile: pathToOrderTypeA4)
                var orderType = orderType.display_name
                if let refOrder =  order.delivery_type_reference ,!refOrder.isEmpty {
                    orderType += " [\(refOrder)] "
                }
                orderTypeHTML = orderTypeHTML.replacingOccurrences(of: "#ORDER_TYPE#", with:  orderType)
                HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_TYPE_A4#", with:  orderTypeHTML)
                
                
            }else{
                HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_TYPE_A4#", with:  "")
                
            }
            let pathToinvoiceRow = Bundle.main.path(forResource: "invoiceRow", ofType:"html") ?? ""
            
            
            let clsTax:account_tax_class! = account_tax_class.get(company_id: pos.company_id!)
            
            
            var rows = ""
            for row in order.pos_order_lines
            {
                var invoiceRow = try String(contentsOfFile: pathToinvoiceRow)
                invoiceRow = invoiceRow.replacingOccurrences(of: "#name", with:  row.product.name)
                //#NOTE#
                invoiceRow = invoiceRow.replacingOccurrences(of: "#NOTE#", with:  row.note ?? "")
                invoiceRow = invoiceRow.replacingOccurrences(of: "#priceUnit", with:  row.price_unit!.toIntString())
                invoiceRow = invoiceRow.replacingOccurrences(of: "#qty", with:  row.qty.toIntString())
                invoiceRow = invoiceRow.replacingOccurrences(of: "#UOM#", with:  row.product.uom_name ?? "PC")
                invoiceRow = invoiceRow.replacingOccurrences(of: "#CURRENCY#", with:  SharedManager.shared.getCurrencyName())
                invoiceRow = invoiceRow.replacingOccurrences(of: "#taxPrecentage", with:  clsTax.name)
                invoiceRow = invoiceRow.replacingOccurrences(of: "#amountTax", with:  (row.price_subtotal_incl! - row.price_subtotal!).toIntString() )
                invoiceRow = invoiceRow.replacingOccurrences(of: "#total", with:  row.price_subtotal_incl!.toIntString())
                
                rows = rows + invoiceRow
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#invoiceRow", with:  rows)
            if !(order.note ).isEmpty{
                let pathToOrderNotesA4 = Bundle.main.path(forResource: "NOTES_ORDER_A4", ofType:"html") ?? ""
                var orderNoteHTML = try String(contentsOfFile: pathToOrderNotesA4)
                
                orderNoteHTML = orderNoteHTML.replacingOccurrences(of: "#NOTES_ORDER#", with:  order.note )
                HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_NOTES#", with:  orderNoteHTML)
                
            }else{
                HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDER_NOTES#", with:  "")
                
            }
            
            if let driver = order.driver
            {
                let pathToDriverInfoA4 = Bundle.main.path(forResource: "DRIVER_INFO_A4", ofType:"html") ?? ""
                var driverInfoHTML = try String(contentsOfFile: pathToDriverInfoA4)
                driverInfoHTML = driverInfoHTML.replacingOccurrences(of: "#NAME_DRIVER#", with:  driver.name ?? "")
                HTMLContent = HTMLContent.replacingOccurrences(of: "#DRIVER_INFO_A4#", with:  driverInfoHTML)
                
                
            }else{
                HTMLContent = HTMLContent.replacingOccurrences(of: "#DRIVER_INFO_A4#", with:  "")
                
            }
            if(order.partner_row_id != 0)
            {
                let pathToCustomerRow = Bundle.main.path(forResource: "customerRow", ofType:"html") ?? ""
                var customerRow = try String(contentsOfFile: pathToCustomerRow)
                
                let addCustomersRows  = NSMutableString()
                
                let client = res_partner_class.get(row_id: order.partner_row_id)
                addCustomersRows.append(addCustomerRow(title: "Name", tilteAR: "الاسم", value: client?.name ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Building No", tilteAR: "رقم المبنى", value: client?.building_no ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Street", tilteAR: "اسم الشارع", value: client?.street ?? ""))
                addCustomersRows.append(addCustomerRow(title: "", tilteAR: "", value: client?.street2 ?? ""))
                addCustomersRows.append(addCustomerRow(title: "District", tilteAR: "الحى", value: client?.district ?? ""))
                addCustomersRows.append(addCustomerRow(title: "City", tilteAR: "المدينة", value: client?.city ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Country", tilteAR: "البلد", value: client?.country_name ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Postal Code", tilteAR: "الرمز البريدى", value: client?.zip ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Additional no", tilteAR: "الرقم الاضافى للعنوان", value: client?.additional_no ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Cust.VAT ", tilteAR: " رقم ضريبة العميل", value: client?.vat ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Other ID", tilteAR: "معرف اخر", value: client?.other_id ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Job Position", tilteAR: "المنصب الوظيفي", value: client?.function ?? ""))
                
                addCustomersRows.append(addCustomerRow(title: "Phone", tilteAR: "الهاتف", value: client?.phone ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Mobile Number", tilteAR: "الجوال", value: client?.mobile ?? ""))
                addCustomersRows.append(addCustomerRow(title: "Website", tilteAR: "الموقع الالكترونى", value: client?.website ?? ""))
                
                customerRow = customerRow.replacingOccurrences(of: "#rows", with: String( addCustomersRows))
                //                customerRow = customerRow.replacingOccurrences(of: "#clientName", with:  client?.name ?? "")
                //                customerRow = customerRow.replacingOccurrences(of: "#clientPhone", with:  client?.phone ?? "")
                //
                //                if !client!.vat.isEmpty
                //                {
                //                    customerRow = customerRow.replacingOccurrences(of: "#clientVat", with:  client?.vat ?? "")
                //                }
                //                else
                //                {
                //                    customerRow = customerRow.replacingOccurrences(of: "Cust.VAT", with:  client?.vat ?? "")
                //                    customerRow = customerRow.replacingOccurrences(of: "#clientVat", with:  client?.vat ?? "")
                //                    customerRow = customerRow.replacingOccurrences(of: "رقم ضريبة العميل ", with:  client?.vat ?? "")
                //
                //
                //                }
                
                HTMLContent = HTMLContent.replacingOccurrences(of: "#customerRow", with:  customerRow)
                
                
            }
            else
            {
                HTMLContent = HTMLContent.replacingOccurrences(of: "#customerRow", with:  "")
                
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#QR", with:  renderQR(order: order))
            
            SharedManager.shared.printLog(HTMLContent)
            return HTMLContent ;
            
        }
        catch {
            SharedManager.shared.printLog("Unable to open html template")
        }
        
        return "";
        
    }
    
    static func addCustomerRow(title:String , tilteAR:String , value:String) -> String
    {
        if value.isEmpty
        {
            return ""
        }
        
        let row = """
               <tr>
                   <td class="text-left"> <strong> \(title)</strong> </td>
                   <td class="text-center">\(value)</td>
                   <td class="text-right"><strong> \(tilteAR) </strong></td>
               </tr>
        """
        
        return row
    }
    
    
    
    //MARK:- qr html.
    static func renderQR(order:pos_order_class) -> String {
        
        let pos = SharedManager.shared.posConfig()
        
        let companyName = pos.company.name
        let tax_number = pos.getVatNumber() //company().vat
        let order_time_stamp = Date(strDate: order.write_date ?? "", formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss'Z'", UTC: false)
        let totalVat = String(format: "%.2f",  order.amount_tax)
        let totalOrder = String(format: "%.2f", order.amount_total)  //objecPrinter.order.amount_total
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
        let qr_image = UIImage.generateQRCode(from: "\(tvl_base64)")?.toBase64() ?? ""
        
        do {
            var HTMLContent = "<img style='width:100px;height: 100px;' src='data:image/png;base64,#VALUE#'  />"
            HTMLContent = HTMLContent.replacingOccurrences(of: "#VALUE#", with: qr_image)
            return HTMLContent
        } catch {
            SharedManager.shared.printLog("Unable to open html template")
        }
        return ""
    }
    
    
    
    
    
    
    
}
