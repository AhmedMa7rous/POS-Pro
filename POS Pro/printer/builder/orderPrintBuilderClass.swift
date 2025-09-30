//
//  orderPrintClass.swift
//  pos
//
//  Created by khaled on 11/5/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class orderPrintBuilderClass {
    
    let    separator_x = " "
  
    
    var order:pos_order_class?
    var sub_Order:[pos_order_class?]?
    var order_html:String = ""
    var currency =  SharedManager.shared.getCurrencyName(true) 
    var isCopy:Bool = false
    var for_waiter:Bool = false
    var for_kds:Bool = false
    var for_insurance:Bool = false
    var enable_draft_mode:Bool = true

    var qr_print:Bool = false
    var qr_url:String = ""

    var hidePrice:Bool = false
    var hideFooter:Bool = false
    var hideHeader:Bool = false
    var hideCalories:Bool = false
    var hideComboDetails:Bool = false


    var hideLogo:Bool = false
    var hideVat:Bool = false
    var hideRef:Bool = false
    var hideNotPaid:Bool = true

    var showOrderReference:Bool = false


    var print_new_only:Bool = false
    var printerName:String = ""

    
    
   var custom_header:String?
    
//    var hr = "<div> ___________________________________</div>"
//      var hr = "<div> ---------------------------------------------------</div>"
   var hr = "<div> -------------------------------------------------------------------</div>"

    
//    var invoiceComposer:InvoiceComposer?

   convenience init(withOrder:pos_order_class , subOrder:[pos_order_class]) {
    self.init()
    self.order = withOrder
    self.sub_Order = subOrder
    }
    deinit {
       SharedManager.shared.printLog("======orderPrintBuilderClass==deinit====")
        SharedManager.shared.resetInvoiceComposer()
        order = nil
        sub_Order?.removeAll()
        sub_Order = nil
    }
    

    func printOrder_html() -> String
    {
        let setting =  SharedManager.shared.appSetting()
        self.enable_draft_mode = setting.enable_draft_mode
        self.hideComboDetails = !setting.enable_show_combo_details_invoice

        if setting.new_invocie_report {
            if self.for_insurance {
                guard let order = self.order else {return "" }
                SharedManager.shared.setInsuranceComposer(order: order)
                return  SharedManager.shared.insuranceComposer?.renderInvoice() ?? ""
            }else{
                SharedManager.shared.setInvoiceComposer(orderPrintBuilder: self)
                return  SharedManager.shared.invoiceComposer?.renderInvoice() ?? ""
            }
        }
        guard let order = self.order else {return "" }

        order_html = baseClass.get_file_html(filename: "order",showCopyRight: false,isCopy:isCopy)
        order_html = order_html.replacingOccurrences(of: "#font", with: app_font_name_printer + "-Regular")
        
        if qr_print
        {
            let qr_txt = (qr_url ) + "\n" + (order.name ?? "")
            let qr_image = UIImage.generateQRCode(from: qr_txt)?.toBase64() ?? ""
            
            let qr_html = """
                    <table style="width: 100%;text-align: center;height: 200px; ">  <tr> <td>  <img style="width:200px;height: 200px;" src="data:image/png;base64, \(qr_image )"  /> </td> </tr>  </table>
                    """
            
            order_html  = order_html.replacingOccurrences(of: "#QR", with: "\(qr_html)")
        }
        else
        {
            order_html  = order_html.replacingOccurrences(of: "#QR", with: "")

        }

        let pos = SharedManager.shared.posConfig()
        
        if pos.company.currency_id != 0
        {
            currency = pos.company.currency_name
        }
        
        if for_kds == false
        {
        let setting = SharedManager.shared.appSetting()
        if setting.receipt_custom_header == false
        {
          
                order_html = order_html.replacingOccurrences(of: "#header", with: "<table style=\"width: 100%;text-align: center;margin-top:-100px\">  <tr> <td>  <h2>#header</h2> </td> </tr>  </table>")

          
            
        }
        else
        {
             order_html = order_html.replacingOccurrences(of: "#header", with: "<table style=\"width: 100%;text-align: center;margin-top:-100px\">  <tr> <td>  <br>#header</br> </td> </tr>  </table>")

        }
        }

        //        pos.receipt_header = String(format: "%@\n%@", pos.receipt_header , pos.company?.vat ?? "")
        
        
        //        pos.receipt_header = pos.receipt_header.replacingOccurrences(of: "\n", with: "<br/>")
        //        pos.receipt_footer = pos.receipt_footer.replacingOccurrences(of: "\n", with: "<br/>")
        
        if isCopy == true
        {
            pos.receipt_header = String(format: "%@<br />%@", pos.receipt_header! , "Copy receipt")
            
        }
        
      

 
        if hideLogo == false
        {
//            let logo = """
//            <table style="width: 100%;height:300px;text-align: center">  <tr> <td>  <img style="width:300px;text-align: center" src="data:image/png;base64, \(pos.company.logo)"  /> </td> </tr>  </table>
//            """
        
            let setting = SharedManager.shared.appSetting()
              let  width = setting.receipt_logo_width

              let logo = """
                      <table style="width: 100%;text-align: center; ">  <tr> <td>  <img style="width:\(width)%;text-align: center;margin:20px" src="data:image/png;base64, \(pos.company.logo)"  /> </td> </tr>  </table>
                      """
           
              order_html = order_html.replacingOccurrences(of: "#logo", with: logo)
        }
        else
        {
            order_html = order_html.replacingOccurrences(of: "#logo", with:  "" )
        }
      
        if hideHeader == true
        {
            if custom_header != nil
            {
                 order_html = order_html.replacingOccurrences(of: "#header", with: "<table style=\"width: 100%;text-align: center;margin-top:-100px\">  <tr> <td>  \(custom_header!) </td> </tr>  </table>")
            }
            else
            {
                order_html = order_html.replacingOccurrences(of: "#header", with: "")

            }

        }
        else
        {
            var header = pos.receipt_header!
            
            if for_waiter
            {
                header = header + "<br />  Not paid"
            }
            
//            order_html = order_html.replacingOccurrences(of: "#header", with: header)
            if for_kds == false
            {
                order_html = order_html.replacingOccurrences(of: "#header", with: "<table style=\"width: 100%;text-align: center;margin-top:0px\">  <tr> <td>  \(header) </td> </tr>  </table>")
            }

        }
        
        let print_count = pos_order_helper_class.get_print_count(order_id: order.id!)

        if hideFooter == true
        {
            
            let footer = "<table style=\"width: 100%;text-align: center;font-size:35px\"> <tr><td>  #Print: \(print_count) / \(printerName) </td></tr></table>"

            order_html = order_html.replacingOccurrences(of: "#footer", with: footer)
            order_html = order_html.replacingOccurrences(of: "#lineFooter", with: "")
 
        }
        else
        {
            var receipt_footer = pos.receipt_footer!
            receipt_footer = receipt_footer.replacingOccurrences(of: "\n", with: "<br />")
                   
            if for_kds == false
            {
                receipt_footer =  receipt_footer + "<br />" + "  <p style=\"font-size:30px;text-align: center;\"  > Powered by DGTERA </p>"

            }
            
            if hideRef == false
            {
                receipt_footer = receipt_footer + "<br />" + "<div style=\"font-size:30px;text-align: right\">  <span>\(String( order.uid!)) </span> </div>"
                
                if (sub_Order?.count ?? 0) > 0
                {
        //            let parent_orderID_server = sub_Order[0].name
                    var parent_orderID_server = sub_Order?[0]?.name

                    if !parent_orderID_server!.isEmpty
                    {
                        parent_orderID_server = parent_orderID_server?.replacingOccurrences(of: "Order-", with: "")
                        receipt_footer = receipt_footer + "<br />" + "<div style=\"font-size:30px;text-align: right\"> <span> Ref Return  </span>   <span> \(String(parent_orderID_server!)) </span> </div>"

                        
                    }
                }
                 
            }
            
            var footer = "<table style=\"width: 100%;text-align: center\"> <tr><td> \( receipt_footer)   </td></tr></table>"
            
            if for_kds == true
            {
                footer = "<table style=\"width: 100%;text-align: center\"> <tr><td> \( receipt_footer) <br />#Print: \(print_count) </td></tr></table>"
            }
             
            
            order_html = order_html.replacingOccurrences(of: "#footer", with: footer)
            order_html = order_html.replacingOccurrences(of: "#lineFooter", with: "<div>\(hr)</div>")
//         order_html = order_html.replacingOccurrences(of: "#lineFooter", with: "<div> </div>")

        }
        
        if hidePrice == true
        {
       

//            order_html = order_html.replacingOccurrences(of: "#priceString", with: "&nbsp")
            order_html = order_html.replacingOccurrences(of: "#lineTotal", with: "")

        }
        else
        {
            order_html = order_html.replacingOccurrences(of: "#lineTotal", with: "<div> \(hr) </div>")
//            order_html = order_html.replacingOccurrences(of: "#priceString", with: "Price <br/> السعر")

        }
        
//        var header_row = """
//                        <tr >  <td colspan="5">   <div>\(hr) </div>  </td>  </tr>
//                    <tr >
//                       <td  >Qty <br /> الكميه</td>
//                       <td style="width: 30px"> </td>
//                        <td >Item <br /> الصنف </td>
//                        <td style="width: 30px"> </td>
//                        <td >&nbsp &nbsp</td>
//
//                    </tr>
//                   <tr >  <td colspan="5">   <div>\(hr) </div>  </td>  </tr>
//
//        """
        var header_row = """
                        <tr >  <td colspan="5">   \(hr)   </td>  </tr>
                    <tr >
                        <td colspan="5"  valign="bottom"> <span> Qty - الكميه </span>  <span> &nbsp&nbsp&nbsp&nbsp  </span>  <span> Item - الصنف </span> </td>
                        
                    </tr>
                   <tr >  <td colspan="5">   \(hr)   </td>  </tr>

        """
        if for_kds == true
        {
            header_row = ""
        }
        
        order_html = order_html.replacingOccurrences(of: "#table_row", with: header_row)
        
        
        if for_kds == false
        {
            printOrder_setHeader()

        }
        else
        {
            printOrder_setHeader_kds()
        }
        
        printOrder_setOrders()
        printOrder_setTotal()
        
//         SharedManager.shared.printLog(order_html)
        return order_html
    }
    
    func printOrder_setHeader_kds()
    {
        guard let order = self.order else {return  }

        let rows_header:NSMutableString = NSMutableString()
        
        rows_header.append("<tr >  <td colspan=\"3\" style=\"text-align: center\">  <center> <h2 style=\" border: 6px solid black;padding: 10px;width: 500px;margin-top:-10px\">  Order #\(    order.sequence_number ) </h2>  </center> </td> </tr>")
 
        let pos_code =  order.write_pos_name ?? ""
        
        let dt = Date(strDate:  order.create_date!, formate: baseClass.date_formate_database ,UTC: true).toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
 
        rows_header.append(" <tr style=\"text-align: left\"><td   style=\"width: 450px;vertical-align: top\"> \(pos_code) / \(String(  order.write_pos_name ?? "")) </td> <td valign =\"top\"> : </td><td valign =\"top\" style=\"max-width: 450px;  word-wrap: break-word;valign=top;text-align: right\"> \(dt) </td> </tr>")
 
        var orderType_display_name = ""
        if order.orderType != nil
        {
            orderType_display_name = order.orderType?.display_name ?? ""
            
            if !(order.delivery_type_reference ?? "").isEmpty &&  order.orderType != nil
            {
                orderType_display_name =  (order.delivery_type_reference ?? "" )  + " - " + (orderType_display_name )
          
            }
            
        }
        
      
        
        
        if !(order.table_name ?? "").isEmpty && order.orderType == nil
        {
              rows_header.append(" <tr style=\"text-align: left\"> <td   style=\"width: 450px;vertical-align: top\">Table -  رقم الطاولة</td> <td valign =\"top\"> : </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top\"> \(String( order.table_name!)) </td> </tr>")
        }
        else if !(order.table_name ?? "").isEmpty && order.orderType != nil
        {
            rows_header.append(" <tr  > <td   style=\"width: 450px;vertical-align: top;text-align: left\"> \(String( orderType_display_name )) </td> <td valign =\"top\"> : </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top;text-align: right\"> \(String( order.table_name!)) </td> </tr>")
        }
        else  if order.orderType != nil && (order.table_name ?? "").isEmpty
        {
            rows_header.append(" <tr style=\"text-align:  center \">  <td colspan=\"3\" style=\"max-width: 450px;  word-wrap: break-word;valign=top\"> \(String( orderType_display_name  )) </td> </tr>")
        }
        
      
        
        rows_header.append( " <tr>  <td colspan=\"3\"> \(hr)</td> </tr>")
        

 
        order_html = order_html.replacingOccurrences(of: "#rows_header", with: String(rows_header))

    }
    func printOrder_setHeader()
    {
        guard let order = self.order else {return  }

        let pos = SharedManager.shared.posConfig()
        
        let rows_header:NSMutableString = NSMutableString()
        
        rows_header.append("<tr >  <td colspan=\"3\" style=\"text-align: center\">  <center> <h2 style=\" border: 6px solid black;padding: 10px;width: 500px;margin-top:-10px\">  Order #\(    order.sequence_number ) </h2>  </center> </td> </tr>")
        //        rows_header.append(" <tr><td >Invoice </td> <td > : </td><td> \(String(  order.invoiceID)) </td> </tr>")
        
       
        
        let pos_code =  order.write_pos_name ?? ""//pos_config_class.getPos(posID: order.write_pos_id!).code.uppercased()
//        if pos_code.isEmpty
//        {
//            pos_code = String( order.write_pos_id!)
//
//        }

          let date = Date(strDate:  order.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: "yyyy/MM/dd", UTC: false)
          let time = Date(strDate:  order.create_date!, formate: baseClass.date_formate_database ,UTC: true).toString(dateFormat: "hh:mm a", UTC: false)

//        rows_header.append(" <tr style=\"text-align: left\"><td colspan=\"3\"  style=\"width: 450px;vertical-align: top\">  \(pos_code) / \(String( order.write_pos_id!))  -  \(String(  order.cashier?.name ?? ""))  </td>   </tr>")
//
//
//        rows_header.append(" <tr style=\"text-align: left\"><td   style=\"width: 450px;vertical-align: top\">Date - التاريخ </td> <td valign =\"top\"> : </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top\"> \( dt) </td> </tr>")
//
//        if order.orderType != nil
//        {
//            rows_header.append(" <tr style=\"text-align: left\"><td   style=\"width: 450px;vertical-align: top\">Order type - نوع الطلب </td> <td valign =\"top\"> : </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top\"> \(String( order.orderType?.display_name ?? "-")) </td> </tr>")
//        }
        
        rows_header.append(" <tr style=\"text-align: left\"><td  style=\"width: 450px;vertical-align: top\">  \(String( order.orderType?.display_name ?? "-"))  </td> <td valign =\"top\">   </td> <td style=\"text-align: right\" >\(date)</td> </tr>")
        
        rows_header.append(" <tr style=\"text-align: left\"><td  style=\"width: 450px;vertical-align: top\"> \(pos_code)  / \(String(  order.write_user_name ?? ""))  </td> <td valign =\"top\">   </td> <td style=\"text-align: right\">\(time)</td> </tr>")
        
        if order.customer != nil {
            rows_header.append(" <tr style=\"text-align: left\"><td   style=\"width: 450px;vertical-align: top\">Customer - العميل </td> <td valign =\"top\">  </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top;text-align: right\"> \(String( order.customer?.name ?? "-")) </td> </tr>")
        }
        
      
//        rows_header.append(" <tr style=\"text-align: left\"><td colspan=\"3\" style=\"width: 450px;vertical-align: top\">POS Name - نقطه البيع </td> <td valign =\"top\"> : </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top\"> \(String(  order.write_pos_name ?? "")) </td> </tr>")
//
        
 
        
//        if hideRef == false
//        {
//              rows_header.append(" <tr style=\"text-align: left\"> <td colspan=\"3\" style=\"width: 450px;vertical-align: top\">Ref - الرقم المرجعى </td> <td valign =\"top\"> : </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top\"> \(String( order.name!)) </td> </tr>")
//        }
   
        if hideVat == false
        {
            rows_header.append(" <tr style=\"text-align: left;\"><td   style=\"width: 450px;vertical-align: top\" >VAT - الرقم الضريبى </td> <td valign =\"top\">  </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top;text-align: right\"> \(pos.getVatNumber() ) </td> </tr>")
        }
        
        if !pos.company.company_registry.isEmpty {
        rows_header.append(" <tr style=\"text-align: left;\"><td   style=\"width: 450px;vertical-align: top\" >CR - السجل التجاري </td> <td valign =\"top\">  </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top;text-align: right\"> \(pos.company.company_registry ) </td> </tr>")
        }
        
        if !(order.table_name ?? "").isEmpty
        {
              rows_header.append(" <tr style=\"text-align: left\"> <td   style=\"width: 450px;vertical-align: top\">Table -  رقم الطاولة</td> <td valign =\"top\">  </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top;text-align: right\"> \(String( order.table_name!)) </td> </tr>")
        }
        
//        if sub_Order?.count > 0
//        {
////            let parent_orderID_server = sub_Order[0].name
//            let parent_orderID_server = sub_Order[0].name
//
//            if !parent_orderID_server!.isEmpty
//            {
//                rows_header.append(" <tr style=\"text-align: left\"><td   style=\"width: 450px;vertical-align: top\">Ref Return - الرقم المرجعى للمرتجع</td> <td valign =\"top\"> : </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top;text-align: right\"> \(String(parent_orderID_server!)) </td> </tr>")
//
//            }
//        }
    
        if !(order.delivery_type_reference ?? "" ).isEmpty
        {
           rows_header.append(" <tr style=\"text-align: left\"> <td   style=\"width: 450px;vertical-align: top\"> Order type reference </td> <td valign =\"top\">  </td><td style=\"max-width: 450px;  word-wrap: break-word;valign=top;text-align: right\"> \(String( order.delivery_type_reference!)) </td> </tr>")
        }
        
        order_html = order_html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
    
    func printOrder_setTotal()
    {
        guard let order = self.order else {return  }

        
        if hidePrice == true
        {
            
            order_html = order_html.replacingOccurrences(of: "#rows_total", with: "")

             return
        }
        
        var tax_all = order.amount_tax
        var total_all = order.amount_total
        let delivery_amount =  order.orderType?.delivery_amount ?? 0


        for item in (sub_Order ?? [])
        {
            guard let item = item else {
                continue
            }
            tax_all = tax_all + item.amount_tax
            total_all = total_all + item.amount_total
        }
        
//        total_all = total_all + delivery_amount
        
        //        let SUBTOTAL:String = baseClass.currencyFormate( order.subTotal()) + " " + currency
        let TAX:String = baseClass.currencyFormate( tax_all) + " " + SharedManager.shared.getCurrencySymbol()
        let TOTAL:String = baseClass.currencyFormate( total_all) + " " + SharedManager.shared.getCurrencySymbol()
        //        let CASH:String =  baseClass.currencyFormate( order.amount_paid) + " " + currency
        
        
        let rows_total:NSMutableString = NSMutableString()
        //        rows_total.append(" <tr><td >SUBTOTAL </td> <td style='text-align: right'> \(SUBTOTAL) </td> </tr>")
        rows_total.append("<table style=\"width: 100%;text-align: left\">")
        
        if sub_Order?.count == 0
        {
//            if order.discount_program_id != nil {
            let line_discount = order.get_discount_line()
                if line_discount != nil
                {
                    let Discount:String = baseClass.currencyFormate(line_discount?.price_unit ?? 0) + " " + SharedManager.shared.getCurrencySymbol()

                    rows_total.append(" <tr style=\"text-align: left;height:100px\"><td colspan=\"4\">DISCOUNT - الخصم </td> <td style='text-align: right'> \(Discount) </td> </tr>")
                }
//            }
        }
        
        
        
        rows_total.append(" <tr style=\"text-align: left\"><td colspan=\"4\"> <h3> TOTAL - الاجمالى </h3> </td> <td style='text-align: right'>    <h2>  \(TOTAL) </h2></td> </tr>")
        
        if delivery_amount != 0
        {
             rows_total.append(" <tr style=\"text-align: left;height:100px\"><td colspan=\"4\"> Delivery - التوصيل  <br/><br/></td> <td style='text-align: right'> \(delivery_amount) <br/><br/> </td> </tr>")

        }
        
        rows_total.append(" <tr style=\"text-align: left;height:100px\"><td colspan=\"4\">TAX - الضريبه  </td> <td style='text-align: right'> \(TAX)   </td> </tr>")
        
        let isTaxFree = SharedManager.shared.posConfig().allow_free_tax
        if isTaxFree == true
         {
                rows_total.append(" <tr style=\"text-align: left;height:100px\"><td colspan=\"4\">TAX Disc - خصم الضريبه  </td> <td style='text-align: right'> - \(TAX)   </td> </tr>")
        }
        
//        if sub_Order?.count == 0
//        {
            for item in order.get_account_journal()
            {
                
                rows_total.append(" <tr style=\"text-align: left;height:100px\"><td colspan=\"4\"> \(item.display_name) </td> <td style='text-align: right'> \(item.tendered.toDouble()!) </td> </tr>")
                
            }
            
            
            if order.amount_return != 0
            {
                let CHANGE:String = baseClass.currencyFormate(  order.amount_return) + " " + SharedManager.shared.getCurrencySymbol()
                rows_total.append(" <tr style=\"text-align: left;height:100px\"><td colspan=\"4\">CHANGE - الباقى </td> <td style='text-align: right'> \(CHANGE) </td> </tr>")
            }
//        }
        
        rows_total.append(" </table>")
        order_html = order_html.replacingOccurrences(of: "#rows_total", with: String(rows_total))
        
    }
    
    func printOrder_setOrders()
    {
        guard let order = self.order else {return  }

        let rows_orders:NSMutableString = NSMutableString()
        
        rows_orders.append(addProduct(orderObj: order))
        
    
        let note = order.note
        if !note.isEmpty
         {
         rows_orders.append(" <tr  ><td colspan='5'> \(note) </td>   </tr>")
        }
        
        for item in (sub_Order ?? [])
        {
            guard let item = item else {
                continue
            }
            rows_orders.append(" <tr >  <td colspan=\"5\">  \(hr) </td>  </tr>")
            
            rows_orders.append(addProduct(orderObj: item,is_return: true))
            
            if !item.note.isEmpty
             {
               rows_orders.append(" <tr  ><td colspan='5'> \(item.note) </td>   </tr>")
             }
            
        }
        
    
             
        
//        let note = get_notes(notes: order.notes)
        
       
        
        order_html = order_html.replacingOccurrences(of: "#rows_order", with: String(rows_orders))
        
    }
    
    func addProduct(orderObj:pos_order_class,is_return: Bool = false) -> String
    {
        let rows_orders:NSMutableString = NSMutableString()
        
        for line in  orderObj.pos_order_lines
        {
            
            var qty_new = line.qty

            if print_new_only == true
            {
                if line.printed == .printed
                {
                    continue
                }
       
                
             
                if abs(line.qty - line.last_qty) != 0 && line.qty > 0
                {
                  
                    qty_new =   line.qty - line.last_qty
 

                }
                
            }
            
            let product:product_product_class! = product_product_class.get(id: line.product_id!) //line.product!
 
              var  name = String(format: "%@ - %@", product.name , product.name_ar)
 
            
//            if !product.attribute_names.isEmpty
//            {
//                name = String(format: "%@ - %@", name, product.attribute_names)
//
//            }
            
            if (line.pos_multi_session_write_date ?? "") != "" && line.qty > 0 && line.last_qty > 0  && for_kds == true
            {
                name = String(format: "*** Updated - %@", name )
 
            }
            else if line.qty < 0 && for_kds == true
            {
                name = String(format: "*** Updated - %@", name )
            }
            
            if line.qty > 1 && for_kds == false
            {
                name = String(format: "%@ (%@ \(SharedManager.shared.getCurrencySymbol()) / pcs)", name , line.price_unit!.toIntString())

            }
            
            if hideCalories == false
            {
                if line.product.calories != 0
                {
                    name = String(format: "%@ - Calories ( %@ ) ", name , line.product.calories.toIntString())
                }
            }
            
            
            var note = line.note ?? ""
            if !note.isEmpty
             {
                note = note.replacingOccurrences(of: "\n", with: " ")
                name = String(format: "%@ <br /> %@", name , note)
             }
            
            let price:String = baseClass.currencyFormate(line.price_subtotal_incl! )  + "&nbsp&nbsp" //+  currency
            
            var line_break = "<br />  "
            if line.selected_products_in_combo.count > 0
            {
                line_break = ""
            }
            else if line.discount != 0
            {
                line_break = ""

            }
            
            var row_pirce = ""
            if hidePrice == false
            {
                row_pirce = "<td style='text-align: right;white-space: nowrap;' valign=\"top\"> \(price) </td>"
            }
            else
            {
                row_pirce = "<td style='text-align: right;white-space: nowrap;' valign=\"top\"> &nbsp </td>"

            }
            var return_style = ""
             
            if ( is_return && for_kds == true) || (line.qty < 0 && for_kds == true)
            {
 
                name = name.replacingOccurrences(of: "*** Updated -", with: "")
                name = String(format: "*** Return - %@", name )

            }
 
            // ======================================================================
            // void cases
            if line.is_void!
            {
                return_style = "style=\"text-decoration-line: line-through;\""
                
                name = name.replacingOccurrences(of: "*** Updated -", with: "")
                name = String(format: "*** Void - %@", name )

            }
            
            if qty_new < 0
            {
                return_style = "style=\"text-decoration-line: line-through;\""

                name = name.replacingOccurrences(of: "*** Updated -", with: "")
                name = String(format: "*** Void - %@", name )
                
                qty_new =  qty_new * -1
            }
            // ======================================================================

            
            if line.discount == 0
            {
                rows_orders.append("""
                    <tr>
                    <td style='text-align: center;white-space: nowrap;width:100px' valign=\"top\">\(qty_new.toIntString())<b>\(separator_x)</b></td>
                    <td> </td>
                    <td valign=\"top\" \(return_style)>\(name) \(line_break)</td>
                    <td> </td>
                     \(row_pirce)
                    </tr>
                    """)
             }
  
            rows_orders.append(String (printOrder_setOrdersCombo(product: line,is_return: is_return)  ))
        }
        
        return String( rows_orders)
    }
    
    
    func printOrder_setOrdersCombo(product:pos_order_line_class,is_return: Bool = false) -> NSMutableString
    {
        let rows_combo:NSMutableString = NSMutableString()
        
        
        if product.selected_products_in_combo.count > 0 {
            
            
            var total_calories = 0.0
            for p in product.selected_products_in_combo
            {
//                let dic = item as? [String:Any]
//                let p = productProductClass(fromDictionary: dic!)
                var qty = p.qty.toIntString()

                if print_new_only == true
                {
                    if p.is_void == false
                    {
                        qty = abs(p.qty - p.last_qty).toIntString()
                    }
                    else
                    {
                        qty = p.last_qty.toIntString()
                    }
                }
                
                
                var line_notes:String = ""
                if !(p.note ?? "").isEmpty
                 {
                    line_notes = "<br/><br/>"
                       line_notes = String(format: "%@-%@",  line_notes  , p.note!.replacingOccurrences(of: "\n", with: " - "))
                 }
                
                let name = String(format: "%@ - %@", p.product.name , p.product.name_ar)

//                var name = p.product.title
//                            if !p.product.name_ar.isEmpty
//                            {
//                                name = String(format: "%@ - %@",p.product.title , p.product.name_ar )
//                            }
                
                
                if p.default_product_combo == false
                {
                    
            
                    if hideCalories == false
                    {
                        if p.product.calories != 0
                                        {
                                            total_calories = total_calories +  p.product.calories
                                            //                    name = String(format: "%@ - Calories ( %@ ) ", name , p.calories.toIntString())
                                        }
                    }
                
                    
                    var return_style = ""
//                    if is_return
//                    {
//                        return_style = ";text-decoration-line: line-through;"
//                    }
//
                    if p.is_void == true
                  {
                      return_style = "text-decoration-line: line-through;"

                  }
                    
                    if p.extra_price !=  0 &&  hidePrice == false
                    {
//
//                        rows_combo.append("""
//                            <tr  >
//                            <td> </td>
//                            <td colspan=\"3\" style=\"font-size:42px;\" valign=\"top\">
//                            <div style=\"margin-bottom: 20px\" >
//                            <span >   \(p.qty.toIntString()) <b> X </b> </span> <span>  \(name) </span> <span> (+\(p.extra_price!.toIntString()) SAR) </span> \(line_notes)
//                            </div>
//                            </td>
//                            <td ></td>
//                            </tr>
//                            """)
                        
                        
                        rows_combo.append("""
                            <tr  >
                            <td> </td>
                            <td colspan=\"3\" style=\"font-size:42px;\(return_style)\" valign=\"top\">
                            <div style=\"margin-bottom: 20px\" >
                            <span >   \(qty) <b>\(separator_x)</b> </span> <span>  \(name) </span>  \(line_notes)
                            </div>
                            </td>
                            <td style='text-align: right;white-space: nowrap;' valign=\"top\">\(p.price_subtotal_incl!.toIntString() + "&nbsp&nbsp")</td>
                            </tr>
                            """)
                        
                    }
                    else
                    {
                        rows_combo.append("""
                            <tr  >
                            <td> </td>
                            <td colspan=\"3\" style=\"font-size:42px;\(return_style)\" valign=\"top\">
                            <div style=\"margin-bottom: 20px\" >
                            <span >   \(qty) <b>\(separator_x)</b> </span>
                            \(name) \(line_notes) </div>
                            </td>
                            <td   ></td>
                            </tr>
                            """)
                    }
                }
                else
                {
                    if !(p.note ?? "").isEmpty
                    {
                        rows_combo.append("""
                                                 <tr  >
                                                 <td> </td>
                                                 <td colspan=\"3\" style=\"font-size:42px;\" valign=\"top\">
                                                 <div style=\"margin-bottom: 20px\" >
                                                 <span >   \(qty) <b>\(separator_x)</b> </span>
                                                 \(name) \(line_notes) </div>
                                                 </td>
                                                 <td   ></td>
                                                 </tr>
                                                 """)
                    }
                }
                
             
            }
            
            if hideCalories == false
            {
                if total_calories != 0
                 {
                     rows_combo.append("""
                         <tr  >
                         <td> </td>
                         <td colspan=\"3\" style=\"font-size:42px;\" valign=\"top\">
                         <div style=\"margin-bottom: 20px\" >
                         <span > Calories  \(total_calories.toIntString()) Cal   </span>
                         </div>
                         </td>
                         <td   ></td>
                         </tr>
                         """)
                 }
            }
 
            
            
        }
        
        return rows_combo
    }
    
//    func printOrder_Formate() -> (header:String,items:String,total:String,footer:String)
//    {
//
//        let pos = SharedManager.shared.posConfig()
//
//
//        p.initArabic()
//
//        var currency = "ريال"
//        currency = p.getString(txt: currency)
//
//        let SUBTOTAL:String = ""//baseClass.currencyFormate( order.subTotal()) + " " + currency
//        let TAX:String = baseClass.currencyFormate( order.amount_tax) + " " + currency
//
//        let TOTAL:String = baseClass.currencyFormate( order.amount_total) + " " + currency
//        let CASH:String =  baseClass.currencyFormate( order.amount_paid) + " " + currency
//        let CHANGE:String = baseClass.currencyFormate(  order.amount_return) + " " + currency
//
//        let pos_name = order.pos?.name ?? ""
//
//        let header = receiptFormater()
//        let items = receiptFormater()
//        let total = receiptFormater()
//        let footer = receiptFormater()
//
//        let dash_line  = "----------------------------------------"
//        let dash_line2 = "________________________________________"
//
//        header.line_length = 40
//
//        items.line_length = 40
//        //        items.val_length = get_max_length_price(currency: currency)
//
//        total.line_length = 20
//        footer.line_length = 40
//
//
//        //        header .addLine(title: "Phone   : ", val: "+1 555 123 8069", alignMode:   .none)
//        header .addLine(title:  p.getString(txt: pos.receipt_header!), val: "" , alignMode: .center)
//        header .addLine(title: "Invoice : ", val: String(  order.sequence_number_full), alignMode: .none)
//        header .addLine(title: "Cashier : ", val:  p.getString(txt:order.cashier?.name ?? "" ), alignMode: .none)
//
//        if order.customer != nil {
//            header .addLine(title: "Customer: ", val:  p.getString(txt:order.customer?.name ?? "-"), alignMode: .none) }
//
//        header .addLine(title: "POS Name: ", val: p.getString(txt:pos_name) , alignMode: .none)
//        //        header .addLine(title:  "", val: "", alignMode: .none)
//
//        header .addLine(title: "Date    : ", val:  Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false), alignMode: .none)
//        header .addLine(title: "Order   : ", val:  order.name!, alignMode: .none)
//        header .addLine(title: "", val: "", alignMode: .none)
//
//        header .addLine(title: dash_line, val: "", alignMode: .none)
//
//        header .addLine(title: "QTy Item Name", val: "Price", alignMode: .titleLeft_valRight)
//        header .addLine(title: dash_line, val: "", alignMode: .none)
//        header .addLine(title: "", val: "", alignMode: .none)
//
//
//        get_products_SharedManager.shared.printLog(items: items , currency: currency)
//
//
//
//        items .addLine(title: dash_line, val: "", alignMode: .none)
//
//        items .addLine(title: "SUBTOTAL", val: SUBTOTAL , alignMode: .titleLeft_valRight)
//        items .addLine(title: "TAX", val:TAX , alignMode: .titleLeft_valRight)
//
//
//      let line_discount = order.get_discount_line()
//        if line_discount != nil
//        {
//                let Discount:String = baseClass.currencyFormate(line_discount?.price_unit ?? 0) + " " + currency
//
//                items .addLine(title: "Discount", val: Discount , alignMode: .titleLeft_valRight)
//            }
//
//
//        //        total .addLine(title: "", val: "", alignMode: .none)
//
//        total .addLine(title: "", val: "", alignMode: .none)
//
//        total .addLine(title: "TOTAL", val: TOTAL, alignMode: .titleLeft_valRight)
//        footer .addLine(title: "CASH",  val:CASH, alignMode: .titleLeft_valRight)
//        footer .addLine(title: "CHANGE",  val:CHANGE , alignMode: .titleLeft_valRight)
//
//
////        let order_note = get_notes(notes: order.notes)
//         let order_note = order.note
//        if !order_note.isEmpty
//        {
//            footer .addLine(title: p.getString(txt:order_note), val: "", alignMode: .titleLeft_valRight)
//        }
//
//
//        footer .addLine(title: dash_line2, val: "", alignMode: .none)
//        //        footer .addLine(title:  p.getString(txt:  "الاسعار - شامله ضريبة القيمه المضافه"), val: "", alignMode: .center)
//        footer .addLine(title:  p.getString(txt: pos.receipt_footer!), val: "", alignMode: .center)
//
//        //        footer .addLine(title: "Thanks", val: "", alignMode: .center)
//        //        footer .addLine(title: "Powered By Rabeh", val: "", alignMode: .center)
//
//        return (header.receipt,items.receipt,total.receipt,footer.receipt)
//    }
//
//
//    func get_products_SharedManager.shared.printLog( items:receiptFormater,currency:String)
//    {
//        for line in  order.pos_order_lines
//        {
//
//            let qty = line.qty
//            var name = line.product.title
//
//            if name.isArabic
//            {
//                name = p.getString(txt: name)
//            }
//
//            let item = String(format: "%@ %@", qty.toIntString() , name )
//            let price:String = baseClass.currencyFormate(line.product.lst_price ) + " " +  currency
//
//            items .addLine(title: item ,  val:price , alignMode: .titleLeft_valRight)
//
////            let note = get_notes(notes: obj_product.notes)
//            let note = line.note ?? ""
//            if !note.isEmpty
//            {
//                items .addLine(title: note, val: "", alignMode: .titleLeft_valRight)
//            }
//
//
//            get_combo_SharedManager.shared.printLog(product: line.product, items: items)
//
//        }
//    }
//
//    func get_combo_SharedManager.shared.printLog(product:product_product_class, items:receiptFormater)
//    {
//        if product.list_product_in_combo.count > 0 {
//
//            var line:String = ""
//            for item in product.list_product_in_combo
//            {
//                let dic = item as? [String:Any]
//                let p = pos_order_line_class(fromDictionary: dic!)
//
//
//
//                if line == ""
//                {
//                    line = String(format: "-> %@ %@",    p.qty.toIntString() , p.product.title)
//
//                }
//                else
//                {
//                    line = String(format: "-> %@ %@",  p.qty.toIntString() , p.product.title)
//
//                }
//
//                if p.extra_price !=  0
//                {
//                    line = String(format:"%@ (Extra price %@)", line , p.extra_price!.toIntString())
//                }
//
//                items .addLine(title: line, val: "", alignMode: .none)
//
//            }
//
//
//
//
//        }
//    }
    
    func get_notes(notes:[Int:[String : Any]] )-> String
    {
        var lines:String = ""
        for (_,val) in notes
        {
            
            let cls = pos_product_notes_class(fromDictionary: val)
            
            if lines.isEmpty
            {
                lines = String(format: "%@",   cls.display_name)
            }
            else
            {
                lines = String(format: "%@,%@", lines , cls.display_name)
                
            }
            
        }
        
        return lines
    }
    
}
