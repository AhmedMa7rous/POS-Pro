//
//  orderPrintClass.swift
//  pos
//
//  Created by khaled on 11/5/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class scrapPrintBuilderClass: NSObject {
 
    var order:pos_order_class!
 
    var order_html:String = ""
    var currency = SharedManager.shared.getCurrencySymbol()
 

   var custom_header:String?
    
    var hr = "<div> ___________________________________</div>"
    init(withOrder:pos_order_class ) {
        order = withOrder
 
    }
    
    
    func printOrder_html() -> String
    {
        
        order_html = baseClass.get_file_html(filename: "scrap",showCopyRight: true)
        
        printOrder_setHeader()
        printOrder_setProducts()
 
        
        SharedManager.shared.printLog(order_html)
        return order_html
    }
    
    func printOrder_setHeader()
    {
        
        
        let rows_header:NSMutableString = NSMutableString()
      rows_header.append(" <tr style=\"text-align: left\"><td >POS Name - نقطه البيع </td> <td >  &nbsp;: &nbsp; </td><td> \(String(  order.pos?.name ?? "")) </td> </tr>")
        rows_header.append(" <tr style=\"text-align: left\"><td >Cashier - الكاشير </td> <td > &nbsp; : &nbsp; </td><td> \(String(  order.cashier?.name ?? "")) </td> </tr>")
        
            let dt = Date(strDate:  order.create_date!, formate: baseClass.date_fromate_server ,UTC: true).toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
        
        rows_header.append(" <tr style=\"text-align: left\"><td >Date - التاريخ </td> <td >  &nbsp;: &nbsp; </td><td> \( dt) </td> </tr>")
        
//        rows_header.append(" <tr><td valign=\"top\">Reason</td><td valign=\"top\"> &nbsp;: &nbsp;</td><td></td></tr>")
        rows_header.append(" <tr><td valign=\"top\">Reason</td><td valign=\"top\"> &nbsp;: &nbsp;</td> ")

        if order.pos_order_lines.count > 0
        {
            let reason = order.pos_order_lines[0].scrap_reason
//            rows_header.append(" <tr> <td colspan=\"3\" style=\"max-width: 700px\">\(reason)</td></tr>")
            rows_header.append("  <td  >\(reason)</td>  ")

        }
       rows_header.append(" </tr>")

        
        
        order_html = order_html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
    
    
    
    func printOrder_setProducts()
    {
        
        let rows_orders:NSMutableString = NSMutableString()
        
        rows_orders.append(addProduct(orderObj: order))
        
    
        let note = order.note
        if !note.isEmpty
         {
          rows_orders.append(" <tr  ><td colspan='3'> \(note) </td>   </tr>")
        }
        
         
        order_html = order_html.replacingOccurrences(of: "#rows_order", with: String(rows_orders))
        
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
            
          
           let note = line.note ?? ""
            if !note.isEmpty
             {
                name = String(format: "%@ <br /> %@", name , note)
             }
        
            rows_orders.append("""
                <tr>
                <td valign=\"top\"> \(qty)  </td>
                <td valign=\"top\"> &nbsp;X&nbsp;  </td>
                <td valign=\"top\">\(name) <br /> <br /> </td>
                </tr>
                """)
            
          
 
       
        }
        
        return String( rows_orders)
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
