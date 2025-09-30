//
//  reportsHtml.swift
//  pos
//
//  Created by khaled on 03/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class reportsHtml: NSObject {

    var value_dirction_style = "right"
    let style_right = "body,table,tr,td {  direction: rtl;   text-align: right; }"
    
    
    private var rpt:salesReportSummary!
    
    init(_ _rpt:salesReportSummary) {
        rpt = _rpt
        
    }
    
    func openHtml() ->String
    {
        return """
        <!DOCTYPE html>
        <html lang="en">
        
        <head>
            <meta charset="UTF-8">
            <title></title>
            
            <style>
              @font-face { font-family: '#font'; src: url('#font.ttf'); }
              @font-face { font-family: '#font-Regular'; src: url('#font-Regular.ttf'); }
        
            #total   {
                    border: 1px solid black;
                    border-collapse: collapse;
                  
                }
        
                #total td {
                    border: 1px solid black;
                    border-collapse: collapse;
                    text-align: center;
                    font-size: 30px;
                }
                #total th {
                    border: 1px solid black;
                    border-collapse: collapse;
                    text-align: center;
                    font-size: 40px;
                }
              
            </style>
        </head>
        
        <body  >
        <div style="width: 900px;font-size:45px;text-align: center;line-height: 1.2;margin-left: 25px;margin-right: 25px;margin-bottom: 150px; font-family:#font;border: 4px solid black;">
        """
        
    }
    
    
    func closeHtml() -> String
    {
        return """
             </div>
            </body>
            </html>
            
            """
    }
    
     func title(_ report:reportsList) -> String
    {
        var str = ""
        
        if report == .salesReport
        {
            str = "Sales report".arabic("تقرير عمليات ")
        }
        
        
        let html = " <div style=\"width: 100%;margin-top: -60px\">  <h2 style=\" border: 4px solid black;  \"> \(str) </h2>  </div>"
        
        return html
    }
    
    func titleTotal() -> String
   {
       
       
       let html = " <div style=\"width: 100%;margin: auto\"> <h2 style=\" border: 4px solid black;  \"> Total Report </h2>  </div>"
       
       return html
   }
   
    
    
    func separator() -> String
    {
        return """
            <br />    <br />
            
            """
    }
    //MARK: - Style
    func openTable() -> String
    {
        return "<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">"

    }
    
    func addToTable(_ row:String) -> String
    {
        
        return " <tr><td> \(row) </td></tr>"
    }
    func closeTable() -> String
    {
       return "</table>"

    }
    
    
    //MARK: - info

    func reportInfo() -> String
    {
 
        let rows :NSMutableString = NSMutableString()

        

 
        rows.append(" <table style=\"width: 100%;text-align: left\">")
        rows.append(" <tr><td>\("POS Name".arabic("نقطة البيع"))</td><td>: </td><td> \(rpt.posName!)</td></tr>")
        rows.append(" <tr><td>\("Business day".arabic("اليوم"))</td><td>: </td><td> \(rpt.businessDate! )</td></tr>")
//        rows.append(" <tr><td>\("From".arabic("من"))</td><td>: </td><td> \(rpt.startDate! )</td></tr>")
//        rows.append(" <tr><td>\("To".arabic("الى"))</td><td>: </td><td> \(rpt.endDate! )</td></tr>")
        rows.append("</table>")
        
        return String(rows)

    }
    
    func reportInfoDate() -> String
    {
 
        let rows :NSMutableString = NSMutableString()

        

 
        rows.append(" <table style=\"width: 100%;text-align: center\">")
//        rows.append(" <tr><td>\("POS Name".arabic("نقطة البيع"))</td><td>: </td><td> \(rpt.posName!)</td></tr>")
        rows.append(" <tr><td>\("Business day".arabic("اليوم"))</td><td>: </td><td> \(rpt.businessDate! )</td></tr>")
//        rows.append(" <tr><td>\("From".arabic("من"))</td><td>: </td><td> \(rpt.startDate! )</td></tr>")
//        rows.append(" <tr><td>\("To".arabic("الى"))</td><td>: </td><td> \(rpt.endDate! )</td></tr>")
        rows.append("</table>")
        
        return String(rows)

    }
    
    func reportTotalTable(_ rptSummary:salesReportSummary) -> String
    {
 
        let rows :NSMutableString = NSMutableString()

         
        rows.append(" <table id=\"total\" style=\"width: 100%;text-align: center; \">")
        rows.append(" <tr> <th>POS Name</th> <th>Orders Count</th> <th>Total Sales</th> </tr>")
        
        var total_orders = 0
        var total_price = 0.0
        
        for rpt in rptSummary.subReports
        {
            total_orders = total_orders + rpt.ordersCount
            total_price = total_price + rpt.price_subtotal_incl

            rows.append(" <tr> <th> \(rpt.posName! )</th> <th>\(rpt.ordersCount)</th> <th> \(rpt.price_subtotal_incl)</th> </tr>")
        }
        
        rows.append(" <tr> <th> Total Sales </th> <th>\(total_orders)</th> <th> \(total_price)</th> </tr>")


        rows.append("</table>")
        
        return String(rows)

    }
    
    
    func sessionInfo() -> String
    {
 
        let rows :NSMutableString = NSMutableString()

         
        rows.append("<table style=\"width: 98%;text-align: left;border: 4px solid black;padding: 10px;margin-top: 20px;\">")
        rows.append("<tr><td style=\"width: 30%\">  <b>  Shift </b> </td> <td>  :  </td><td>  \( rpt.sessionID! )</b> </td></tr>")
        rows.append("<tr><td style=\"width: 30%\">  <b>  Employee </b> </td> <td>  :  </td><td>  \(rpt.cashierName ?? "" )</b> </td></tr>")
        rows.append("<tr><td >   <b> Opened at </b> </td> <td>  :  </td><td> <b> \(rpt.startDate! )</b> </td></tr>")
        rows.append("<tr><td >   <b> Closed at </b> </td> <td>  :  </td><td><b>  \(rpt.endDate!) </b></td></tr>")
        rows.append("<tr><td >   <b> Orders # </b> </td> <td>  :  </td><td><b>  \(rpt.ordersCount ) </b></td></tr>")
        rows.append("</table>")
        
        return String(rows)

    }
    
    
    //MARK: - Total payment

    func paymentMethod() -> String
    {
 
        let rows :NSMutableString = NSMutableString()

    
        rows.append(" <table style=\"width: 100%;text-align: left\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> Payment </u> </h3>  </td>    </tr>")

        let sortedKeys = rpt.total_bankStatment.sorted {$0.key < $1.key}
        
        for (name, map) in sortedKeys {

             let total =  map["total"] as? Double ?? 0
            
            rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
        }
        
        let total_payment = rpt.allPayments + rpt.totalCash
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> \("Total Payment".arabic("اجمالي النقدية")) </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(total_payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
      
       
        
        rows.append("</table>")
        
        return String(rows)
    }
    
    func totalPaymentSummary() -> String
    {
 
 
        
    
        
        let sortedKeys = rpt.total_bankStatment_summery.sorted {$0.key < $1.key}
        let rows :NSMutableString = NSMutableString()
        
        var all_Payment = 0.0
        var currect_cash = 0.0
        
        
        rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black;padding-right: 20px; padding-left: 20px\">")
        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> ملخص الدفع </u> </h3>  </td>    </tr>")
        } else {
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> Payment summary </u> </h3>  </td>    </tr>")
        }
        
        
        
        for (name, total) in sortedKeys {
            if name == "cash"
            {
                currect_cash = currect_cash + total
                
            }
            else
            {
                all_Payment =  all_Payment + total
                
                //                header .addLine(title: name, val:String(format: "%@", total.toIntString()), alignMode: .titleLeft_valRight)
                rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
            }
        }
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> \("Payment summary".arabic("ملخص الدفع"))</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        
 
        
        rows.append("</table>")
        return String(rows)
    }
    
    
    func totalPaymentSummarySummary() -> String
    {
 
        
        let sortedKeys = rpt.total_bankStatment_summery.sorted {$0.key < $1.key}
        let rows :NSMutableString = NSMutableString()
        
        var all_Payment = 0.0
        var currect_cash = 0.0
        
        rows.append("   <div> <h3 style=\"line-height: 0%;text-align: left\"> <u> \("Payment summary".arabic("ملخص الدفع")) </u> </h3> </div>")

        rows.append("<table style=\"width: 100%;text-align: center;border: 4px solid black;  \">")
      
        
        
        
        for (name, total) in sortedKeys {
            if name == "cash"
            {
                currect_cash = currect_cash + total
                
            }
            else
            {
                all_Payment =  all_Payment + total
                if total > 0
                {
                    //                header .addLine(title: name, val:String(format: "%@", total.toIntString()), alignMode: .titleLeft_valRight)
                    rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:center;\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
                }
                

            }
        }
        
//        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> \("Payment summary".arabic("ملخص الدفع"))</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
//
 
        
        rows.append("</table>")
        return String(rows)
    }
    
    //MARK: - Total Deleivery type

    
    func totalDeliveryType() -> String
     {
        if conditions.is_order_type_enabled() == false
        {
            return ""
        }
        
 
 
        let sortedKeys = rpt.total_deliveryType.sorted {$0.key < $1.key}
         let rows :NSMutableString = NSMutableString()
         
         var all_Payment = 0.0
         
         
         
        rows.append(" <table style=\"width: 100%;text-align: left\">")

        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> "+"Order Type ".arabic(" نوع الطلب")+" </u> </h3>  </td>    </tr>")

        
        
         
         for (name, value) in sortedKeys {
             
             let total = value["total"] as? Double ?? 0
             let count = value["count"] as? Double ?? 0
             //            let bankStatement = value["bankStatement"] as? String ?? ""
             
             all_Payment =  all_Payment + total
             
            let title = count.toIntString() + " - " + name

             rows.append("<tr> <td style=\"width: 75%;\">  \(title)  </td>  <td ></td> <td style=\"text-align:\(value_dirction_style);width: 25\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
         }
        
 
         
         
         rows.append("</table>")
         return String(rows)
     }
    
    func totalDeliveryTypeSummary() -> String
     {
        if conditions.is_order_type_enabled() == false
        {
            return ""
        }
        
 
 
        let sortedKeys = rpt.total_deliveryType_summery.sorted {$0.key < $1.key}
         let rows :NSMutableString = NSMutableString()
         
         var all_Payment = 0.0
         
         
         
         rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
        
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> "+"Order Type summary".arabic("ملخص نوع الطلب")+" </u> </h3>  </td>    </tr>")

        
        
         
         for (name, value) in sortedKeys {
             
             let total = value["total"] as? Double ?? 0
             let count = value["count"] as? Double ?? 0
             //            let bankStatement = value["bankStatement"] as? String ?? ""
             
             all_Payment =  all_Payment + total
             
            let title = count.toIntString() + " - " + name

             rows.append("<tr> <td style=\"width: 75%;\">  \(title)  </td>  <td ></td> <td style=\"text-align:\(value_dirction_style);width: 25\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
         }
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>"+"Order Type summary".arabic("ملخص نوع الطلب")+"</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")

         
         
         rows.append("</table>")
         return String(rows)
     }
    
    func totalDeliveryTypeSummarySummary() -> String
     {
        if conditions.is_order_type_enabled() == false
        {
            return ""
        }
        
 
 
        let sortedKeys = rpt.total_deliveryType_summery.sorted {$0.key < $1.key}
         let rows :NSMutableString = NSMutableString()
         
         var all_Payment = 0.0
         
         
         rows.append("   <div> <h3 style=\"line-height: 0%;text-align: left\"> <u> \("Order Type summary".arabic("ملخص نوع الطلب")) </u> </h3> </div>")

         rows.append("<table style=\"width: 100%;text-align: center;border: 4px solid black;  \">")
         
      
        
         
         for (name, value) in sortedKeys {
             
             let total = value["total"] as? Double ?? 0
             let count = value["count"] as? Double ?? 0
             //            let bankStatement = value["bankStatement"] as? String ?? ""
             
             all_Payment =  all_Payment + total
             
             if total > 0
             {
                 let title = count.toIntString() + " - " + name

                  rows.append("<tr> <td style=\"width: 75%;\">  \(title)  </td>  <td ></td> <td style=\"text-align:center;width: 25\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
             }
      
         }
        
//        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>"+"Order Type summary".arabic("ملخص نوع الطلب")+"</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")

         
         
         rows.append("</table>")
         return String(rows)
     }
    
    //MARK: - Total Delivery Type AccountJournal
 
    func totalDeliveryTypeAccountJournal() -> String
    {
 
        let rows :NSMutableString = NSMutableString()

    
        rows.append(" <table style=\"width: 100%;text-align: left\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> Order Type </u> </h3>  </td>    </tr>")

        let sortedKeys = rpt.total_deliveryType_accountJournal.sorted {$0.key < $1.key}
        
        for (name, value) in sortedKeys {
            let total = value["total"] as? Double ?? 0
            let count = value["count"] as? Double ?? 0
  
            let title = count.toIntString() + " - " + name
            
             rows.append("<tr> <td style = \"width:75%;\">   \(title)  </td>  <td  >  </td> <td style=\"text-align:\(value_dirction_style);width:25%;\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
           
            
        }
       
        
        rows.append("</table>")
        
        return String(rows)
    }
    
    func totalDeliveryTypeAccountJournalSummary() -> String
     {
        
 
 
        let sortedKeys = rpt.total_deliveryType_accountJournal_summery.sorted {$0.key < $1.key}
         let rows :NSMutableString = NSMutableString()
         
         var all_Payment = 0.0
         
         
         
         rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
        
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\" > <u> "+"payment - Order Type summary".arabic("الدفع - ملخص نوع الطلب")+" </u> </h3>  </td>    </tr>")

         
         for (name, value) in sortedKeys {
             
             let total = value["total"] as? Double ?? 0
             let count = value["count"] as? Double ?? 0
             //            let bankStatement = value["bankStatement"] as? String ?? ""
             
             all_Payment =  all_Payment + total
             
            let title = count.toIntString() + " - " + name

             rows.append("<tr> <td style=\"width: 75%;\">  \(title)  </td>  <td ></td> <td style=\"text-align:\(value_dirction_style);width: 25\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
         }
        
        rows.append("<tr> <td> <h5  > <u> \("payment - Order Type summary".arabic(" الدفع - ملخص نوع الطلب ")) </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align: \(value_dirction_style)\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")

         
         
         rows.append("</table>")
         return String(rows)
     }
    
    //MARK: - Total Cash
    
    func totalCash() -> String
    {
        let rows :NSMutableString = NSMutableString()
        rows.append(" <table style=\"width: 100%;text-align: left\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> Total </u> </h3>  </td>    </tr>")

        rows.append("<tr> <td> Opening Balance  </td>  <td>  </td> <td style=\"text-align:\(value_dirction_style);\">   \(rpt.startBalance.rounded_formated_str(max_len: 12)) </td> </tr>")
        rows.append("<tr> <td> Cash sales  </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(rpt.totalCash.rounded_formated_str(max_len: 12)) </td> </tr>")
       
        
        
        rows.append("</table>")
        return String(rows)

    }
    
    
    func totalCashOnly() -> String
    {
        let rows :NSMutableString = NSMutableString()
        rows.append(" <table style=\"width: 100%;text-align: left\">")
         
        
        
         rows.append("<tr> <td> <h3 style=\"line-height: 0%\"> Total Cash </h3>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h3 style=\"line-\(value_dirction_style): 0%\">  \(rpt.totalCash.rounded_formated_str(max_len: 12))  </h3>  </td> </tr>")
        rows.append("<tr> <td colspan=\"3\"> <hr  style=\"border: 2px dashed black;\">   </td></tr>")
         
        
        rows.append("</table>")
        return String(rows)

    }
    
    
    func cashBox() -> String
    {
        let rows :NSMutableString = NSMutableString()
        rows.append(" <table style=\"width: 100%;text-align: left\">")
        
        

        if  rpt.dif_total_cashbox_In   > 0
        {
            rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> Total </u> </h3>  </td>    </tr>")

            rows.append("<tr> <td> Cash in </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(rpt.dif_total_cashbox_In.toIntString()) </td> </tr>")
        }
        
        if  rpt.dif_total_cashbox_out  > 0
        {
            rows.append("<tr> <td> Cash out  </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(rpt.dif_total_cashbox_out.toIntString()) </td> </tr>")
        }
        
        
        rows.append("<tr> <td colspan=\"3\"> <hr  style=\"border: 2px dashed black;\">   </td></tr>")
        rows.append("<tr> <td> <h3 style=\"line-height: 0%\"> Total Cash </h3>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h3 style=\"line-\(value_dirction_style): 0%\">  \(rpt.totalCash.rounded_formated_str(max_len: 12))  </h3>  </td> </tr>")
        rows.append("<tr> <td colspan=\"3\"> <hr  style=\"border: 2px dashed black;\">   </td></tr>")
        
        rows.append("<tr> <td> Closed Balance  </td>  <td>  </td> <td style=\"text-align:\(value_dirction_style);\">   \((rpt.endBalance ).rounded_formated_str(max_len: 12)) </td> </tr>")
        
        
        let balance_difference =  (rpt.endBalance ) - rpt.totalCash
        if balance_difference != 0
        {
            rows.append("<tr > <td style=\"border: 2px solid red;\"> Difference Balance  </td>  <td >  </td> <td style=\"text-align:right;border: 2px solid red;\">   \(balance_difference.rounded_formated_str(max_len: 12)) </td> </tr>")
        }
        
        
        rows.append("</table>")
        return String(rows)

    }
    
    
    
    func total_order_tax_html(price_subtotal_incl:Double,price_subtotal:Double,amount_tax:Double, hideTitle:Bool = false , withBorder:Bool = false ) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        if withBorder
        {
            rows.append("<table style=\"width: 100%;text-align: left; border: 4px solid black; \">")

        }
        else
        {
            rows.append(" <table style=\"width: 100%;text-align: left\">")

        }

      if !hideTitle
        {
          rows.append("<tr>  <td colspan=\"3\">   <h3  style=\"line-height: 0%\"> <u> \("Sales summary".arabic("الاجمالي")) </u> </h3>  </td>    </tr>")

      }
        
        rows.append("<tr> <td > \("Total w\\o Tax".arabic("المجموع بدون الضريبة "))   </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   price_subtotal.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> \("Tax".arabic("الضريبة"))  </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(  amount_tax.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> \("Total with tax".arabic(" المجموع بالضريبة"))   </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   price_subtotal_incl.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
 
    
            rows.append("</table>")

     
        
        return String(rows)
    }
    
    
    func total_statistics_html (total_void:Double,total_return:Double,total_discount:Double ,total_delete:Double,total_reject:Double,total_product_return:Double,total_insurances_return:Double) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
      
            rows.append(" <table style=\"width: 100%;text-align: left\">")

   
        

        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> ملخص اليوم </u> </h3>  </td>    </tr>")
            
            rows.append("<tr> <td>\(MWConstants.cancel_products_title)</td>  <td> </td> <td style=\"text-align:right;\">   \(   total_void.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr ><td colspan=\"3\" style=\"font-size: 20px\">\(MWConstants.cancel_products_dec)</td></tr>")

            
            rows.append("<tr> <td>\(MWConstants.void_products_title)</td>  <td> </td> <td style=\"text-align:right;\">   \(   total_delete.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr ><td colspan=\"3\" style=\"font-size: 20px\">\(MWConstants.void_products_desc)</td></tr>")

//            rows.append("<tr> <td> المرتجعات _old </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> \(MWConstants.return_products_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_product_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> \(MWConstants.return_insurance_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_insurances_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> الطلبات المرفوضة  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_reject.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr> <td> الخصومات </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_discount.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
        } else {
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> Day summary </u> </h3>  </td>    </tr>")
        
            rows.append("<tr> <td>\(MWConstants.cancel_products_title)</td>  <td> </td> <td style=\"text-align:right;\">   \(   total_void.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr ><td colspan=\"3\" style=\"font-size: 20px\">\(MWConstants.cancel_products_dec)</td></tr>")

            
            rows.append("<tr> <td>\(MWConstants.void_products_title)</td>  <td> </td> <td style=\"text-align:right;\">   \(   total_delete.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr ><td colspan=\"3\" style=\"font-size: 20px\">\(MWConstants.void_products_desc)</td></tr>")
            
//        rows.append("<tr> <td> Return products _old </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> \(MWConstants.return_products_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_product_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> \(MWConstants.return_insurance_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_insurances_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        
        rows.append("<tr> <td> Rejected orders  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_reject.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> Discount </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_discount.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        }
        
       
            rows.append("</table>")

     
        return String(rows)
    }

}
