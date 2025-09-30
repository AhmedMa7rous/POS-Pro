//
//  stock_report.swift
//  pos
//
//  Created by Khaled on 3/28/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
import WebKit

class stock_report: ReportViewController {
    @IBOutlet weak var container: UIView!
    var webView: WKWebView!
       @IBOutlet weak  var indc: UIActivityIndicatorView?

   


    override func viewDidLoad() {
        super.viewDidLoad()

        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame:container.bounds, configuration: webConfiguration)
        //        webView.uiDelegate = self
        webView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        //        webView.frame = container.bounds
        container.addSubview(webView)
        
        getSTock()
    }
    
    func getSTock()
    {
         
        let pos = SharedManager.shared.posConfig()
        if pos.stock_location_id  != nil
        {
               indc?.startAnimating()
            
//            let id = pos.stock_location_id[0] as? Int ?? 0
            
            con.userCash = .stopCash
            con.get_stock_by_location(loc_id:pos.stock_location_id!) { (result) in
                if (result.success)
                {
                 

                    let stocks = result.response?["result"] as? [String:[String:Any]] ?? [:]
                    var rows:String = ""
                    
                    for (code,value) in stocks
                    {
                        let name = value["name"] as? String ?? ""
                        var qty_available = value["qty_available"] as? String ?? ""
                        qty_available = qty_available.toDouble()?.rounded_formated_str()   ?? ""

                        let product_uom = value["product_uom"] as? String ?? ""

                        rows = rows + "<tr>" + "<td>" + code + "</td>" + "<td>" + name + "</td>" + "<td style=\"text-align:right\" >" + qty_available + "</td>" + "<td>" + product_uom + "</td></tr>"
                    }
                    
                    self.loadReport(rows: rows)
                }else
                {
                    printer_message_class.show("Check your internet connection.", vc: self)
                }
                
                self.indc?.stopAnimating()
             }
        }
        
  
    }
    
    func loadReport(rows:String)
    {
        var html = baseClass.get_file_html(filename: "stock",showCopyRight: true)
        html = printOrder_setHeader(html: html)
        html = html.replacingOccurrences(of: "#rows", with: rows)
        
        html = html.replacingOccurrences(of: "#font", with: app_font_name_printer + "-Regular")

//        SharedManager.shared.printLog(html)
        self.webView.loadHTMLString( html, baseURL:  Bundle.main.bundleURL)

    }

  func printOrder_setHeader(html: String) -> String {
          let rows_header:NSMutableString = NSMutableString()
           
          let pos = SharedManager.shared.posConfig()
     let date = Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)  //ClassDate.getNow(ClassDate.satnderFromate_12H() , timeZone: NSTimeZone.local )
          
         
          
    
    rows_header.append(" <tr><td>"+"POS Name".arabic("نقطة البيع")+"</td><td>: </td><td> \(pos.name!)</td></tr>")
    rows_header.append(" <tr><td>"+"Date".arabic("التاريخ")+"</td><td>: </td><td> \(date )</td></tr>")

    
 
          return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
      }
    
    
    var is_printing = false

        @objc public func print()
        {
            
            if is_printing == false
            {
                  is_printing = true
            }
        
            self.show_printer_dialog()
 
            webView.fullLengthScreenshot { (image) in
                //            self.photo?.image = image
                if image != nil
                {
                    runner_print_class.runPrinterReceipt(  logoData: image , openDeawer: false)

                 }
                
                self.is_printing = false

            }
    }
            
      

}
