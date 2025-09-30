//
//  orderPrintClass.swift
//  pos
//
//  Created by khaled on 11/5/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

enum textStyle {
    case normal,bold,h1,h2,border
}



class orderPrintFormaterClass: NSObject {
    let p = printArabicClass()
    var order:pos_order_class!
    var sub_Order:[pos_order_class] = []
    
    let header_Formater = receiptFormater()
    let items_Formater = receiptFormater()
    let total_Formater = receiptFormater()
    let footer_Formater = receiptFormater()
    let dash_line  = "\n----------------------------------------"
    
    let attributedString = NSMutableAttributedString(string:"")
    
    var currency = "ريال"
    var isCopy:Bool = false
    
    
    
    
    init(withOrder:pos_order_class , subOrder:[pos_order_class]) {
        order = withOrder
        sub_Order = subOrder
        
        header_Formater.line_length = 50
        items_Formater.line_length = 40
        total_Formater.line_length = 20
        footer_Formater.line_length = 40
    }
    
    
    
    func addText(txt:String,style:textStyle ,center:Bool = false)
    {
        
        
        var attributes: [NSAttributedString.Key : Any] = [:] // [NSAttributedString.Key.paragraphStyle: paragraph]
        attributes[.foregroundColor] = UIColor.black
        attributes[.font] = UIFont.systemFont(ofSize: 20)
        
        
        if center == true
        {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            paragraph.baseWritingDirection = .leftToRight
            
            attributes[.paragraphStyle] = paragraph
        }
        else
        {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .left
            paragraph.baseWritingDirection = .leftToRight
            attributes[.paragraphStyle] = paragraph
            
        }
        
        if style == .h1 || style == .border
        {
            attributes[.font] = UIFont.boldSystemFont(ofSize: 28)
        }
        
        if style == .border
        {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            //            attributes[.strokeWidth] = -3.0
            //            attributes[.strokeColor] = UIColor.black
            //            attributes[.foregroundColor] = UIColor.red
            
        }
        
        
        attributedString.append(NSAttributedString(string:txt, attributes:attributes))
        
        //       attributedString.append(NSAttributedString(string:txt,
        //                                                  attributes: [
        //                                                    .font: UIFont.systemFont(ofSize: 24),
        //                                                     .foregroundColor: UIColor.black ,
        //
        //       ]))
        //        mas.append(NSAttributedString(string: "\n"))
        //        mas.append(NSAttributedString(string: "with Swift", attributes: [.font: UIFont.systemFont(ofSize: 20), .foregroundColor: UIColor.orange]))
    }
    
    func breakLine()
    {
        addText(txt: dash_line, style: .normal)
        //        attributedString.append(NSAttributedString(string:dash_line))
    }
    
    func normalLine()
    {
        attributedString.append(NSAttributedString(string:"\n"))
    }
    
    
    func printOrder() -> NSAttributedString
    {
        
        
        let pos = pos_config_class.getDefault()
        
        if pos.company().currency_id != 0
        {
            currency = pos.company().currency_name
        }
        
        
        //        pos.receipt_header = String(format: "%@\n%@", pos.receipt_header , pos.company?.vat ?? "")
        
        pos.receipt_header = pos.receipt_header!.replacingOccurrences(of: "<h3>", with: "")
        pos.receipt_header = pos.receipt_header!.replacingOccurrences(of: "</h3>", with: "")
        
        pos.receipt_header = pos.receipt_header!.replacingOccurrences(of: "<br/>", with: "")
        pos.receipt_footer = pos.receipt_footer!.replacingOccurrences(of: "<br/>", with: "")
        
        if isCopy == true
        {
            pos.receipt_header = String(format: "%@\n%@", pos.receipt_header! , "Copy receipt")
            
        }
        
        //        order_html = order_html.replacingOccurrences(of: "#logo", with:  pos.company!.logo )
        //        order_html = order_html.replacingOccurrences(of: "#header", with: pos.receipt_header)
        //        order_html = order_html.replacingOccurrences(of: "#footer", with: pos.receipt_footer)
        
        addText(txt: pos.receipt_header!, style: .h1 , center: true)
        //        addText(txt: pos.receipt_footer, style: .normal)
        
        
        printOrder_setHeader()
        //        printOrder_setOrders()
        //        printOrder_setTotal()
        
        //        print(order_html)
        return attributedString
    }
    
    func printOrder_setHeader()
    {
        let pos = pos_config_class.getDefault()
        
        let rows_header:NSMutableString = NSMutableString()
        rows_header.append("<html><head>  <meta charset=\"UTF-8\"> </head> <body  ><table>")
        
        rows_header.append("<tr >  <td colspan=\"3\" style=\"text-align: center\">  <center> <h2 style=\" border: 6px solid black;padding: 10px;width: 500px\">  Order #\(String(  order.sequence_number_full)) </h2>  </center> </td> </tr>")
        //        rows_header.append(" <tr><td >Invoice </td> <td > : </td><td> \(String(  order.invoiceID)) </td> </tr>")
        rows_header.append(" <tr><td >VAT - الرقم الضريبى </td> <td > : </td><td> \(pos.company().vat ) </td> </tr>")
        rows_header.append(" <tr><td >Cashier - الكاشير </td> <td > : </td><td> \(String(  order.cashier?.name ?? "")) </td> </tr>")
        if order.customer != nil {
            rows_header.append(" <tr><td >Customer - العميل </td> <td > : </td><td> \(String( order.customer?.name ?? "-")) </td> </tr>")
        }
        if order.orderType != nil
        {
            rows_header.append(" <tr><td >Order type - نوع الطلب </td> <td > : </td><td> \(String( order.orderType?.display_name ?? "-")) </td> </tr>")
        }
        rows_header.append(" <tr><td >POS Name - نقطه البيع </td> <td > : </td><td> \(String(  order.pos?.name ?? "")) </td> </tr>")
        rows_header.append(" <tr><td >Date - التاريخ </td> <td > : </td><td> \(String( Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)  )) </td> </tr>")
        rows_header.append(" <tr><td >Ref - الرقم المرجعى </td> <td > : </td><td> \(String( order.name!)) </td> </tr>")
        
        if sub_Order.count > 0
        {
            let parent_orderID_server = sub_Order[0].name
            if !parent_orderID_server!.isEmpty
            {
                rows_header.append(" <tr><td >Ref Return - الرقم المرجعى للمرتجع</td> <td > : </td><td> \(String(parent_orderID_server!)) </td> </tr>")
                
            }
        }
        rows_header.append("</table> </body></html>")
        
        let att = String( rows_header)
        attributedString.append(att.htmlToAttributedString(font: nil))
    }
    
    func printOrder_setHeader_old()
    {
        let pos = pos_config_class.getDefault()
        
        normalLine()
        normalLine()
        
        addText(txt: "Order #\(String(  order.sequence_number_full))", style: .border ,center:  true)
        normalLine()
        normalLine()
        
        
        
        addText(txt:"الرقم الضريبى - VAT           : \(pos.company().vat )"  , style: .normal) ;    normalLine()
        addText(txt:"الكاشير - Cashier               : \(order.cashier?.name  ?? "")"  , style: .normal) ;    normalLine()
        
        
        if order.customer != nil {
            addText(txt: "العميل - Customer        : \(order.customer?.name  ?? "")"  , style: .normal) ;    normalLine()
            
        }
        if order.orderType != nil
        {
            addText(txt: "نوع الطلب - Order type   : \(order.orderType?.display_name  ?? "")"  , style: .normal) ;    normalLine()
            
            
        }
        
        addText(txt: "نقطه البيع - POS Name   : \(order.pos?.name  ?? "")"  , style: .normal) ;    normalLine()
        addText(txt: "التاريخ - Date                     : \(Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false) )"  , style: .normal) ;    normalLine()
        addText(txt: "الرقم المرجعى - Ref           : \(order.name!  )"  , style: .normal) ;    normalLine()
        
        
        
        
        
        
        if sub_Order.count > 0
        {
            
            let parent_orderID_server = sub_Order[0].name
            
            if !parent_orderID_server!.isEmpty
            {
                addText(txt: "الرقم المرجعى للمرتجع - Ref Return : \(order.name!  )"  , style: .normal) ;    normalLine()
                
            }
        }
        
        addText(txt:header_Formater.receipt ,style: .normal)
        breakLine()
        
        //        let rows_header:NSMutableString = NSMutableString()
        //        rows_header.append("<tr >  <td colspan=\"3\" style=\"text-align: center\">  <center> <h2 style=\" border: 6px solid black;padding: 10px;width: 500px\">  Order #\(String(  order.invoiceID)) </h2>  </center> </td> </tr>")
        //         rows_header.append(" <tr><td > VAT - الرقم الضريبى </td> <td > : </td><td> \(pos.company?.vat ?? "") </td> </tr>")
        //        rows_header.append(" <tr><td >Cashier - الكاشير </td> <td > : </td><td> \(String(  order.cashier?.name ?? "")) </td> </tr>")
        //        if order.customer != nil {
        //            rows_header.append(" <tr><td >Customer - العميل </td> <td > : </td><td> \(String( order.customer?.name ?? "-")) </td> </tr>")
        //        }
        //        if order.orderType != nil
        //        {
        //            rows_header.append(" <tr><td >Order type - نوع الطلب </td> <td > : </td><td> \(String( order.orderType?.display_name ?? "-")) </td> </tr>")
        //        }
        //        rows_header.append(" <tr><td >POS Name - نقطه البيع </td> <td > : </td><td> \(String(  order.pos?.name ?? "")) </td> </tr>")
        //        rows_header.append(" <tr><td >Date - التاريخ </td> <td > : </td><td> \(String(  baseClass.getDateFormate())) </td> </tr>")
        //        rows_header.append(" <tr><td >Ref - الرقم المرجعى </td> <td > : </td><td> \(String( order.orderID_server)) </td> </tr>")
        //
        //        if sub_Order.count > 0
        //        {
        //            let parent_orderID_server = sub_Order[0].orderID_server
        //            if !parent_orderID_server.isEmpty
        //            {
        //                rows_header.append(" <tr><td > Ref Return - الرقم المرجعى للمرتجع </td> <td > : </td><td> \(String(parent_orderID_server)) </td> </tr>")
        //
        //            }
        //        }
        //
        //
        //        order_html = order_html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
    
    func printOrder_setTotal()
    {
        var tax_all = order.amount_tax
        var total_all = order.amount_total
        let delivery_amount =  order.orderType?.delivery_amount ?? 0
        
        
        for item in sub_Order
        {
            tax_all = tax_all + item.amount_tax
            total_all = total_all + item.amount_total
        }
        
        total_all = total_all + delivery_amount
        
        //        let SUBTOTAL:String = baseClass.currencyFormate( order.subTotal()) + " " + currency
        let TAX:String = baseClass.currencyFormate( tax_all) + " " + currency
        let TOTAL:String = baseClass.currencyFormate( total_all) + " " + currency
        //        let CASH:String =  baseClass.currencyFormate( order.amount_paid) + " " + currency
        
        
        //        let rows_total:NSMutableString = NSMutableString()
        //        rows_total.append(" <tr><td >SUBTOTAL </td> <td style='text-align: right'> \(SUBTOTAL) </td> </tr>")
        
        if sub_Order.count == 0
        {
            let line_discount = order.get_discount_line()
            if line_discount != nil
            {
                
                
                //            if order.discountProgram!.discount_product != nil
                //            {
                let Discount:String = baseClass.currencyFormate(line_discount?.price_unit ?? 0) + " " + currency
                
                addText(txt: "DISCOUNT - الخصم : \(Discount)", style: .normal)
                //                rows_total.append(" <tr><td > DISCOUNT - الخصم </td> <td style='text-align: right'> \(Discount) </td> </tr>")
                //            }
            }
        }
        
        
        total_Formater.addLine(title: " TOTAL - الاجمالى ", val: TOTAL, alignMode: .titleLeft_valRight)
        
        addText(txt: total_Formater.receipt, style: .h2)
        //        rows_total.append(" <tr><td > <h2> TOTAL - الاجمالى </h2> </td> <td style='text-align: right'>    <h2>  \(TOTAL) </h2></td> </tr>")
        
        if delivery_amount != 0
        {
            footer_Formater.addLine(title: "Delivery - التوصيل", val: delivery_amount.toIntString() , alignMode: .titleLeft_valRight)
            
            //             rows_total.append(" <tr><td > Delivery - التوصيل  <br/><br/></td> <td style='text-align: right'> \(delivery_amount) <br/><br/> </td> </tr>")
            
        }
        
        footer_Formater.addLine(title:"TAX - الضريبه " ,val:TAX ,alignMode: .titleLeft_valRight)
        
        //        rows_total.append(" <tr><td >TAX - الضريبه  <br/><br/></td> <td style='text-align: right'> \(TAX) <br/><br/> </td> </tr>")
        
        if sub_Order.count == 0
        {
            for item in order.list_account_journal
            {
                footer_Formater.addLine(title:item.display_name ,val: item.tendered ,alignMode: .titleLeft_valRight)
                
                //                rows_total.append(" <tr><td > \(item.display_name) </td> <td style='text-align: right'> \(item.tendered.toDouble()!) </td> </tr>")
                
            }
            
            
            if order.amount_return != 0
            {
                let CHANGE:String = baseClass.currencyFormate(  order.amount_return) + " " + currency
                
                footer_Formater.addLine(title:"CHANGE - الباقى " ,val: CHANGE ,alignMode: .titleLeft_valRight)
                
                //                rows_total.append(" <tr><td >CHANGE - الباقى </td> <td style='text-align: right'> \(CHANGE) </td> </tr>")
            }
        }
        
        addText(txt: footer_Formater.receipt, style: .normal)
        
        //        order_html = order_html.replacingOccurrences(of: "#rows_total", with: String(rows_total))
        
    }
    
    func printOrder_setOrders()
    {
        
        let rows_orders:NSMutableString = NSMutableString()
        
        rows_orders.append(addProduct(orderObj: order))
        
        for item in sub_Order
        {
            //            rows_orders.append(" <tr >  <td colspan=\"5\">  <hr  style=\"border: 2px dashed black;\"></td>  </tr>")
            breakLine()
            
            rows_orders.append(addProduct(orderObj: item))
            
        }
        
        addText(txt: String( rows_orders), style: .normal)
        
        
        //        let note = get_notes(notes: order.notes)
        let note = order.note
        if !note.isEmpty
        {
            addText(txt: note, style: .normal)
            
            //            rows_orders.append(" <tr  ><td colspan='5'> \(note) </td>   </tr>")
        }
        
        //        order_html = order_html.replacingOccurrences(of: "#rows_order", with: String(rows_orders))
        
    }
    
    func addProduct(orderObj:pos_order_class) -> String
    {
        let rows_orders:NSMutableString = NSMutableString()
        
        for line in  orderObj.pos_order_lines
        {
            
            let qty = line.qty.toIntString()
            var name = line.product.title
            if !line.product.name_ar.isEmpty
            {
                name = String(format: "%@ - %@", line.product.title , line.product.name_ar)
            }
            
            if line.product.calories != 0
            {
                name = String(format: "%@ - Calories ( %@ ) ", name , line.product.calories.toIntString())
            }
            
            let price:String = baseClass.currencyFormate(line.price_unit!  ) + " " +  currency
            
            var line_break = "/n "
            if line.product.list_product_in_combo.count > 0
            {
                line_break = ""
            }
            
            items_Formater.addLine(title: "\(qty) X \(name) \(line_break)", val: price, alignMode: .titleLeft_valRight)
            
            //            rows_orders.append("""
            //                <tr>
            //                <td valign=\"top\"> \(qty) <b>X </b></td>
            //                <td> </td>
            //                <td valign=\"top\">\(name) \(line_break)</td>
            //                <td> </td>
            //                <td style='text-align: right;white-space: nowrap;' valign=\"top\"> \(price) </td>
            //                </tr>
            //                """)
            
            //            let note = get_notes(notes: obj_product.notes)
            let note = line.note ?? ""
            if !note.isEmpty
            {
                items_Formater.addLine(title: note, val: "", alignMode: .none)
                //                rows_orders.append(" <tr  ><td colspan='5'> \(note) </td>   </tr>")
            }
            
            rows_orders.append(String (printOrder_setOrdersCombo(product: line.product)  ))
        }
        
        
        return String( rows_orders)
    }
    
    
    func printOrder_setOrdersCombo(product:product_product_class) -> NSMutableString
    {
        let rows_combo:NSMutableString = NSMutableString()
        
        
        if product.list_product_in_combo.count > 0 {
            
            
            var total_calories = 0.0
            for p in product.list_product_in_combo
            {
                //                let dic = item as? [String:Any]
                //                let p = productProductClass(fromDictionary: dic!)
                if p.default_product_combo == false
                {
                    
                    var name = p.product.title
                    if !p.product.name_ar.isEmpty
                    {
                        name = String(format: "%@ - %@", p.product.name_ar, p.product.title )
                    }
                    
                    if p.product.calories != 0
                    {
                        total_calories = total_calories +  p.product.calories
                        //                    name = String(format: "%@ - Calories ( %@ ) ", name , p.calories.toIntString())
                    }
                    
                    
                    if p.extra_price !=  0
                    {
                        
                        rows_combo.append("""
                            <tr  >
                            <td> </td>
                            <td colspan=\"3\" style=\"font-size:42px;\" valign=\"top\">
                            <div style=\"margin-bottom: 20px\" >
                            <span >   \(p.qty .toIntString()) <b> X </b> </span> <span>  \(name) </span> <span> (+\(p.extra_price!.toIntString()) SAR) </span>
                            </div>
                            </td>
                            <td   ></td>
                            </tr>
                            """)
                        
                    }
                    else
                    {
                        rows_combo.append("""
                            <tr  >
                            <td> </td>
                            <td colspan=\"3\" style=\"font-size:42px;\" valign=\"top\">
                            <div style=\"margin-bottom: 20px\" >
                            <span >   \(p.qty.toIntString()) <b> X </b> </span>
                            \(name)  </div>
                            </td>
                            <td   ></td>
                            </tr>
                            """)
                    }
                }
            }
            
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
        
        return rows_combo
    }
    
    func printOrder_Formate() -> (header:String,items:String,total:String,footer:String)
    {
        
        let pos = pos_config_class.getDefault()
        
        
        p.initArabic()
        
        var currency = "ريال"
        currency = p.getString(txt: currency)
        
        let SUBTOTAL:String = ""//baseClass.currencyFormate( order.subTotal()) + " " + currency
        let TAX:String = baseClass.currencyFormate( order.amount_tax) + " " + currency
        
        let TOTAL:String = baseClass.currencyFormate( order.amount_total) + " " + currency
        let CASH:String =  baseClass.currencyFormate( order.amount_paid) + " " + currency
        let CHANGE:String = baseClass.currencyFormate(  order.amount_return) + " " + currency
        
        let pos_name = order.pos?.name ?? ""
        
        let header = receiptFormater()
        let items = receiptFormater()
        let total = receiptFormater()
        let footer = receiptFormater()
        
        let dash_line  = "----------------------------------------"
        let dash_line2 = "________________________________________"
        
        header.line_length = 40
        
        items.line_length = 40
        //        items.val_length = get_max_length_price(currency: currency)
        
        total.line_length = 20
        footer.line_length = 40
        
        
        //        header .addLine(title: "Phone   : ", val: "+1 555 123 8069", alignMode:   .none)
        header .addLine(title:  p.getString(txt: pos.receipt_header!), val: "" , alignMode: .center)
        header .addLine(title: "Invoice : ", val: String(  order.sequence_number_full), alignMode: .none)
        header .addLine(title: "Cashier : ", val:  p.getString(txt:order.cashier?.name ?? "" ), alignMode: .none)
        
        if order.customer != nil {
            header .addLine(title: "Customer: ", val:  p.getString(txt:order.customer?.name ?? "-"), alignMode: .none) }
        
        header .addLine(title: "POS Name: ", val: p.getString(txt:pos_name) , alignMode: .none)
        //        header .addLine(title:  "", val: "", alignMode: .none)
        
        header .addLine(title: "Date    : ", val:   Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false), alignMode: .none)
        header .addLine(title: "Order   : ", val:  order.name!, alignMode: .none)
        header .addLine(title: "", val: "", alignMode: .none)
        
        header .addLine(title: dash_line, val: "", alignMode: .none)
        
        header .addLine(title: "QTy Item Name", val: "Price", alignMode: .titleLeft_valRight)
        header .addLine(title: dash_line, val: "", alignMode: .none)
        header .addLine(title: "", val: "", alignMode: .none)
        
        
        get_products_print(items: items , currency: currency)
        
        
        
        items .addLine(title: dash_line, val: "", alignMode: .none)
        
        items .addLine(title: "SUBTOTAL", val: SUBTOTAL , alignMode: .titleLeft_valRight)
        items .addLine(title: "TAX", val:TAX , alignMode: .titleLeft_valRight)
        
        
        let line_discount = order.get_discount_line()
        if line_discount != nil
        {
            let Discount:String = baseClass.currencyFormate(line_discount?.price_unit ?? 0) + " " + currency
            
            items .addLine(title: "Discount", val: Discount , alignMode: .titleLeft_valRight)
        }
        
        
        //        total .addLine(title: "", val: "", alignMode: .none)
        
        total .addLine(title: "", val: "", alignMode: .none)
        
        total .addLine(title: "TOTAL", val: TOTAL, alignMode: .titleLeft_valRight)
        footer .addLine(title: "CASH",  val:CASH, alignMode: .titleLeft_valRight)
        footer .addLine(title: "CHANGE",  val:CHANGE , alignMode: .titleLeft_valRight)
        
        
        //        let order_note = get_notes(notes: order.notes)
        let order_note = order.note
        if !order_note.isEmpty
        {
            footer .addLine(title: p.getString(txt:order_note), val: "", alignMode: .titleLeft_valRight)
        }
        
        
        footer .addLine(title: dash_line2, val: "", alignMode: .none)
        //        footer .addLine(title:  p.getString(txt:  "الاسعار - شامله ضريبة القيمه المضافه"), val: "", alignMode: .center)
        footer .addLine(title:  p.getString(txt: pos.receipt_footer!), val: "", alignMode: .center)
        
        //        footer .addLine(title: "Thanks", val: "", alignMode: .center)
        //        footer .addLine(title: "Powered By Rabeh", val: "", alignMode: .center)
        
        return (header.receipt,items.receipt,total.receipt,footer.receipt)
    }
    
    
    func get_products_print( items:receiptFormater,currency:String)
    {
        for line in  order.pos_order_lines
        {
            
            let qty = line.qty
            var name = line.product.title
            
            if name.isArabic
            {
                name = p.getString(txt: name)
            }
            
            let item = String(format: "%@ %@", qty.toIntString() , name )
            let price:String = baseClass.currencyFormate(line.product.lst_price ) + " " +  currency
            
            items .addLine(title: item ,  val:price , alignMode: .titleLeft_valRight)
            
            //            let note = get_notes(notes: obj_product.notes)
            let note = line.note ?? ""
            if !note.isEmpty
            {
                items .addLine(title: note, val: "", alignMode: .titleLeft_valRight)
            }
            
            
            get_combo_print(product: line.product, items: items)
            
        }
    }
    
    func get_combo_print(product:product_product_class, items:receiptFormater)
    {
        if product.list_product_in_combo.count > 0 {
            
            var line:String = ""
            for item in product.list_product_in_combo
            {
                let dic = item as? [String:Any]
                let p = pos_order_line_class(fromDictionary: dic!)
                
                
                if line == ""
                {
                    line = String(format: "-> %@ %@",    p.qty.toIntString() , p.product.title)
                    
                }
                else
                {
                    line = String(format: "-> %@ %@",  p.qty.toIntString() , p.product.title)
                    
                }
                
                if p.extra_price !=  0
                {
                    line = String(format:"%@ (Extra price %@)", line , p.extra_price!.toIntString())
                }
                
                items .addLine(title: line, val: "", alignMode: .none)
                
            }
            
            
            
            
        }
    }
    
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
