//
//  ProductsReportViewController.swift
//  pos
//
//  Created by Alhaytham Alfeel on 11/20/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit

class ProductsReportViewController: ReportViewController  {
   
    
    // MARK: - Properties
    var indc: UIActivityIndicatorView?

    @IBOutlet weak var container: UIView!
 
    var webView: WKWebView!
 
    
    var dictionary = [String:[product_product_class]]()
    var total_discount = 0.0
    var total_delivery_amount = 0.0
    var showProduct:Bool = true
    
    var hide_discount:Bool = false
    var hide_net:Bool = false

     let option   = ordersListOpetions()
    
    var html:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tvProductsReport.text = ""
        //getPaymentMethod()
        
     
        
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame:self.view.bounds, configuration: webConfiguration)
//        webView.uiDelegate = self
        webView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
//        webView.frame = container.bounds
        container.addSubview(webView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
      getLastBussinusDate()
            
  loadReport()
    }
    
    func loadReport()
       {
           showActivityIndicator()
                 DispatchQueue.global(qos: .userInteractive).async {
                    self.html = self.printOrder_html()
                    DispatchQueue.main.async {
                      self.webView.loadHTMLString( self.html, baseURL: nil)
                   }
               }
       }
       
    
    func showActivityIndicator() {
        if indc == nil
        {
            indc = UIActivityIndicatorView(style: .whiteLarge)
            indc?.center = self.view.center
            indc?.color = UIColor.black
            self.view.addSubview(indc!)
        }

        indc?.startAnimating()
    }

       func hideActivityIndicator(){
         if (indc != nil){
          DispatchQueue.main.async {
             self.indc?.stopAnimating()
          }
         }
     }
    
    func getLastBussinusDate()
    {
        var lastSession = pos_session_class.getLastActiveSession()
        if lastSession == nil
              {
                  lastSession = pos_session_class.getActiveSession()
              }
        
        let lastDate = lastSession!.start_session
        
        if lastDate != nil
        {
//            let date =   ClassDate.convertTimeStampTodate( String(lastDate) , returnFormate: "yyyy/MM/dd" , timeZone: NSTimeZone.local)
   
            let date = ClassDate.getWithFormate(lastDate, formate: ClassDate.satnderFromate(), returnFormate:  "yyyy-MM-dd" ,use_UTC: true)

//            txtDate.textDate = date
//            txtDate.text = date
        }
        else
        {
            let day = ClassDate.getNow("yyyy-MM-dd", timeZone: NSTimeZone.local )
//            txtDate.textDate = day
//            txtDate.text = day
        }
        
    }
    
      func printOrder(txt: String) {
//        webView.fullLengthScreenshot { (image) in
//            //            self.photo?.image = image
//            if image != nil {
//                EposPrint.runPrinterReceipt(  logoData: image , openDeawer: false)
//            }
//        }
        
             DispatchQueue.global(qos: .background).async {
             
                             EposPrint.runPrinterReceipt_image(  html: self.html, openDeawer: false)
                             
                         }
        
    }
    
    @objc public func print()
    {
        
//        DispatchQueue.global(qos: .background).async {
//
//                             EposPrint.runPrinterReceipt_image(  html: self.html, openDeawer: false)
//
//                         }
//
        webView.fullLengthScreenshot { (image) in
            //            self.photo?.image = image
            if image != nil
            {
                EposPrint.runPrinterReceipt(  logoData: image , openDeawer: false)

            }
        }
        
    }
 
    func get_file_html(filename: String) -> String {
        var html:String = ""
        let bundle = Bundle.main
        var path = bundle.bundlePath
        
        path = bundle.path(forResource: filename, ofType: "html" )!
        
        do {
            try html = String(contentsOfFile: path, encoding: .utf8)
        } catch {
            //ERROR
        }
        
        return html
    }
    
    func printOrder_setHeader(html: String) -> String {
        let rows_header:NSMutableString = NSMutableString()
//        let startDate =  ClassDate.convertTimeStampTodate(String(activeSessionLast.start_session  ) , returnFormate: "dd/MM/yyyy hh:mm a" , timeZone: NSTimeZone.local)
   
        let startDate = ClassDate.getWithFormate(activeSessionLast.start_session, formate: ClassDate.satnderFromate(), returnFormate:  ClassDate.satnderFromate_12H(),use_UTC: true )

        var endDate =  ""
        
        if activeSessionLast.end_session != nil
        {
//            endDate =  ClassDate.convertTimeStampTodate(String(activeSessionLast.end_session  ) , returnFormate: "dd/MM/yyyy hh:mm a" , timeZone: NSTimeZone.local)
             
           endDate = ClassDate.getWithFormate(activeSessionLast.end_session, formate: ClassDate.satnderFromate(), returnFormate:  ClassDate.satnderFromate_12H() ,use_UTC: true)

        }
        
          let BusinessDay = ClassDate.getWithFormate(activeSessionLast.start_session, formate: ClassDate.satnderFromate(), returnFormate:  ClassDate.satnderFromate_date() ,use_UTC: true)
        
     
        let countOrders = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        
//        let BusinessDay =  ClassDate.convertTimeStampTodate(String(activeSessionLast.id  ) , returnFormate: "dd/MM/yyyy" , timeZone: NSTimeZone.local)

//        rows_header.append(" <tr><td>Cashier</td><td>: </td><td> \(activeSessionLast.shift_current!.casher.name)</td></tr>")
        rows_header.append(" <tr><td>Business day</td><td>: </td><td> \(BusinessDay ?? "")</td></tr>")
        rows_header.append(" <tr><td>Start Date</td><td>: </td><td> \(startDate ?? "")</td></tr>")
        rows_header.append(" <tr><td>End Date</td><td>: </td><td> \(endDate )</td></tr>")
        rows_header.append(" <tr><td>Total # Order</td><td>: </td><td> \(countOrders)</td></tr>")
        
        return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
    
    func printOrder_setOrders(html: String) -> String {
        return html.replacingOccurrences(of: "#rows_order", with: "")
    }
    
    
    func getProductList(list_products:[product_product_class],cobo_count:Double ,  isComboList:Bool)
    {
        for product in list_products {
            
            /*
            if product.pos_categ_id != 0
            {
                let category = product.pos_categ_name
                var products = dictionary[category!]
                
                if products != nil {
                    var isExist:Bool = false
                    
                    for i in 0...products!.count - 1
                    {
                        let storege_product = products![i]
                        
                        if storege_product.id == product.id
                        {
                            isExist = true
                            
                            product.qty_app = product.qty_app * cobo_count
                            
                            storege_product.qty_app =  storege_product.qty_app + product.qty_app
                            
//                            product.price_total_app = (isComboList == true) ? product.comob_extra_price : product.lst_price
//                             product.price_total_app = product.price_total_app  * product.qty_app
                            
                            storege_product.price_total_app =  storege_product.price_total_app + product.price_total_app
                            
                            products![i] = storege_product
                            dictionary[category!] = products
                            if product.list_product_in_combo.count > 0
                            {
                                let productsCombo = product_product_class.readProducts(arr: product.list_product_in_combo)
                                getProductList(list_products: productsCombo  ,cobo_count: product.qty_app, isComboList:true)
                            }
                            
                        }
                    }
                    
                    if isExist == false
                    {
                        product.qty_app = product.qty_app * cobo_count
//                        product.price_total_app = (isComboList == true) ? product.comob_extra_price : product.lst_price
//                        product.price_total_app = product.price_total_app  * product.qty_app
                        
                        products?.append(product)
                        
                    }
                    
                } else {
                    
                    product.qty_app = product.qty_app * cobo_count
//                    product.price_total_app = (isComboList == true) ? product.comob_extra_price : product.lst_price
//                    product.price_total_app = product.price_total_app  * product.qty_app
                    
                    products = [product]
                    dictionary[category!] = products
                    
                    if product.list_product_in_combo.count > 0
                    {
                        let productsCombo = product_product_class.readProducts(arr: product.list_product_in_combo)
                        getProductList(list_products: productsCombo  ,cobo_count: product.qty_app , isComboList:true)
                    }
                    
                }
                
                dictionary[category!] = products
                
                
            }
            
            */
        }
    }
    
    func getProductList_new(list_products:[pos_order_line_class],cobo_count:Double , isComboList:Bool)
    {
        for line in list_products {
            
       if line.product.pos_categ_id != 0
        {
            let category = line.product.pos_categ_name!
            var products = dictionary[category]
            
            if products != nil {
                var isExist:Bool = false
                
                for i in 0...products!.count - 1
                {
                    let storege_product = products![i]
                    
                    if storege_product.id == line.id
                    {
//                        isExist = true
//                        
//                        line.qty = line.qty  * cobo_count
//                        
//                        storege_product.qty  =  storege_product.qty + line.qty
//                        
//                        line.price_total_app = (isComboList == true) ? line.extra_price! : line.product.lst_price
//                        line.price_total_app = line.price_total_app  * line.qty
//
//                        storege_product.price_total_app =  storege_product.price_total_app + line.price_total_app
//                        
//                        products![i] = storege_product
//                        
//                        
//                        dictionary[category] = products
//                        
//                        check_product_combo(product: line.product)
// 
                       
                    }
                }
                
                if isExist == false
                {
                    line.qty  = line.qty  * cobo_count
                    line.price_unit = (isComboList == true) ? line.extra_price! : line.product.lst_price
                    line.price_unit = line.price_unit!  * line.qty

                    products?.append(line.product)
                    
                    check_product_combo(product: line.product)

                    
                }
                
            } else {
                
                line.qty  = line.qty  * cobo_count
                line.price_unit = (isComboList == true) ? line.extra_price! : line.product.lst_price
                line.price_unit = line.price_unit!  * line.qty
                
                products = [line.product]
               dictionary[category] = products
                
                check_product_combo(product: line.product)

 
                
            }
            
            dictionary[category] = products
            
            
        }
        }
    }
    
    func check_product_combo(product:product_product_class)
    {
        if product.list_product_in_combo.count > 0
        {
            let productsCombo = product_product_class.readProducts(arr: product.list_product_in_combo)
 
            // TODO: fix
//            getProductList_new(list_products: productsCombo,cobo_count: 1 , isComboList:true)

        }
    }
    
    func getProductGroupByCateogry()
    {
   
        // =====================================================================================
              let sql = pos_order_helper_class.getOrders_status_sorted_Sql(options: option,getCount: false)
              
              let semaphore = DispatchSemaphore(value: 0)
              SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
                  
                  let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
                  while (rows.next()) {
                      //retrieve values for each record
                      let data = rows.string(forColumn: "data")
                      let dic =  data?.toDictionary() ?? [:]
                      
                      let item = pos_order_class(fromDictionary: dic)
                      
                      item.id = Int(rows.int(forColumn: "id"))
                      item.sequence_number = Int(rows.int(forColumn: "invoice_id"))
                      // =====================================================================================
                      
                    
//        for item in list_orders {
//            let order = item //orderClass(fromDictionary: item as! [String : Any])
            
          
//              getProductList(list_products: item.products  ,cobo_count: 1, isComboList:false)
            getProductList_new (list_products: item.pos_order_lines ,cobo_count: 1, isComboList:false)

          
            
            if item.discountProgram.amount != 0
            {
                let discount_product = item.discountProgram.discount_product!
                total_discount = total_discount + discount_product.product.lst_price.rounded()
            }
            
//            if item.orderType?.delivery_amount != 0
//            {
//                let delivery_amount = item.orderType?.delivery_amount ?? 0
//                total_delivery_amount = total_delivery_amount + delivery_amount
//            }
//        }
            // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
     
    }
    
    func printOrder_setTotal(html: String) -> String {
    
        let rows_order:NSMutableString = NSMutableString()
        
          getProductGroupByCateogry()
      
        
        var  total_all = 0.0
      
        
        let sortedKeys = dictionary.sorted {$0.key < $1.key}
        if showProduct == false
        {
             rows_order.append("<tr><td colspan=\"3\" align=\"center\"><hr style=\"border: 2px dashed black;\"></td></tr>")
              rows_order.append("<tr>  <td><h3 style=\"line-height: 5px;\">Name</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">Qty</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">Price</h3></td>  </tr>")
        }
        
        for item in sortedKeys {
            if showProduct == true
            {
                let categ = item.key
              
                
            rows_order.append(" <tr><td colspan=\"3\" align=\"center\"><hr style=\"border: 2px dashed black;\">\(categ)<hr style=\"border: 2px dashed black;\"></td></tr>")
            rows_order.append("<tr>  <td><h3 style=\"line-height: 5px;\">Name</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">Qty</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">Price</h3></td>  </tr>")
            }
          
            
//            let products = dictionary[key]
            let products = item.value

            if   products.count > 0 {
                
                var total = 0.0
                var  total_qty = 0.0
                
             let sortedProducts =   products.sorted { $0.title < $1.title }

                for product in sortedProducts {
                    
//                    if showProduct == true
//                    {
//                        rows_order.append(" <tr><td>\(product.title)</td><td>\(product.qty.toIntString())</td><td> \(product.price_total_app.toIntString())</td></tr>")
//                    }
//
//                    total += product.price_total_app
//                    total_qty += product.qty_app
//
                }
                
                total_all = total_all + total
                
             
                
                if showProduct == true
                {
                   rows_order.append(" <tr><td><h3 style=\"line-height: 5px;\">Total</h3></td><td></td><td><h3 style=\"line-height: 5px;\">\(total.toIntString())</h3></td></tr>")
                }
                    
                else
                {
                    var categ = item.key
                    let lst = item.key.split(separator: "/")
                    if lst.count > 0
                    {
                        categ = String( lst[lst.count - 1])
                    }
                    
                    rows_order.append(" <tr><td>\(categ)</td><td> \(total_qty.toIntString()) </td><td> \(total.toIntString())</td></tr>")

                }
            }
        }
        
//        total_all = total_all + total_delivery_amount
        
        rows_order.append(" <tr><td colspan=\"3\" align=\"center\"> <hr style=\"border: 2px dashed black;\"></td></tr>")
        
        if total_delivery_amount != 0
        {
            rows_order.append("<tr><td><h3>Total delivery</h3></td><td></td><td><h3>\(total_delivery_amount.rounded_formated_str())</h3></td></tr>")
        }
        
        rows_order.append("<tr><td><h3>Total Summary</h3></td><td></td><td><h3>\(total_all.rounded_formated_str())</h3></td></tr>")
         
        if hide_discount == false
        {
            rows_order.append("<tr><td><h3>Total Discount</h3></td><td></td><td><h3>\(total_discount.rounded_formated_str())</h3></td></tr>")

        }
        
        if hide_net == false
             {
        rows_order.append("<tr><td><h3>Total net</h3></td><td></td><td><h3>\((total_all + total_discount).rounded_formated_str())</h3></td></tr>")
        }
      
        
        return html.replacingOccurrences(of: "#rows_total", with: String(rows_order))
    }
    
    func getSessionForDay() -> pos_session_class?
    {
     
        let txtday = "" // txtDate.text
        let checkDay = ClassDate.getWithFormate(txtday, formate: "yyyy/MM/dd", returnFormate: "yyyy-MM-dd",use_UTC: true )
        
        if checkDay == nil
        {
            return nil
        }
        
        // TODO : fix it
    
//        let allSession = posSessionClass.getAllSessions()
//        
//        for item in allSession
//        {
//            let session = posSessionClass(fromDictionary: item)
//            let day = ClassDate.convertTimeStampTodate( String( session.id), returnFormate:"yyyy/MM/dd" , timeZone:NSTimeZone.local  )
//            
//            if day == checkDay
//            {
//                return session
// 
//            }
//            
//        }
        
        return pos_session_class.getSession(day: checkDay!)
        
    }
    
    func printOrder_html() -> String
    {
        
        activeSessionLast = getSessionForDay()

        if activeSessionLast == nil
        {
            return ""
        }
        
        option.sesssion_id = activeSessionLast.id
//
//        let option   = ordersListOpetions()
//        option.Closed = true
//        option.orderSyncType = .order
//        option.sesssion_id = activeSessionLast.id
  
//        orders = ordersListClass.getOrders_status_sorted(options: option)

//        orders = ordersListClass.getOrders_status_sorted(Closed: true, orderSyncType: .order, sesssion_id: activeSessionLast.id)

//        option.LIMIT = 1000
        
        var html = get_file_html(filename: "products")
        let pos = pos_config_class.getDefault()
        
        //html = html.replacingOccurrences(of: "#logo", with: pos.company!.logo )
        html = html.replacingOccurrences(of: "#header", with: pos.receipt_header!)
        //html = html.replacingOccurrences(of: "#footer", with: pos.receipt_footer)
        
        html = printOrder_setHeader(html: html)
        html = printOrder_setOrders(html: html)
        html = printOrder_setTotal(html: html)
        
        hideActivityIndicator()
//        Swift.print(html)
        return html
    }
    
    
    func doneSelect() {
        dictionary.removeAll()
        
        loadReport()
    }
    
    
}
