//
//  ProductsReportViewController.swift
//  pos
//
//  Created by Alhaytham Alfeel on 11/20/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit

class Products_Rang_Report: ReportViewController  {
    
 
    @IBOutlet weak var container: UIView!
//    @IBOutlet weak var txtDate: kTextField_datePicker!
//    @IBOutlet weak var txtDate_to: kTextField_datePicker!
    
    var start_date:String?
    var end_date:String?

    
    var webView: WKWebView!
    var shift_id:Int?

    
    @IBOutlet var btnSelectShift: UIButton!

    var indc: UIActivityIndicatorView?
    
    @IBOutlet var btnEndDate: UIButton!
    @IBOutlet var btnStartDate: UIButton!
    var dictionary = [Int:[pos_order_line_class]]()
    var total_discount = 0.0
    var total_delivery_amount = 0.0
    
    var showProduct:Bool = true
    var hide_discount:Bool = false
    var hide_net:Bool = false
    var hide_count_orders:Bool = false

    let option   = ordersListOpetions()
    
    let date_formate = "dd/MM/yyyy"
    var   html:String = ""
    
    var custom_header:String?
    
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
    
       @IBAction func btnSelectShift(_ sender: Any) {
            
            let list = options_listVC()
            list.modalPresentationStyle = .formSheet
            
            list.list_items.append([options_listVC.title_prefex:"All"])
            
            let options = posSessionOptions()
//        let dt = Date.init(strDate: start_date!, formate: date_formate)
//        options.start_session = dt.toString(dateFormat: "yyyy-MM-dd", UTC: true)
          options.between_start_session = [get_start_date(),get_end_date()]

//        let checkDay = baseClass.get_date_local_to_search(DateOnly: date_str, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss")

      
            let arr: [[String:Any]] =    pos_session_class.get_pos_sessions(options: options)
            for item in arr
            {
                var dic = item
                let shift = pos_session_class(fromDictionary: item)
                
                let dt = Date(strDate: shift.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
                let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
                
    //           let startDate = ClassDate.getWithFormate(shift.start_session! , formate: ClassDate.satnderFromate(), returnFormate: ClassDate.satnderFromate_12H() ,use_UTC: true)
                
                let title = String( shift.id ) + " - " + startDate
                dic[options_listVC.title_prefex] = title
                
                list.list_items.append(dic)

            }
            


            list.didSelect = { [weak self] data in
                let dic = data
                let title = dic[options_listVC.title_prefex] as? String ?? ""
                if title == "All"
                {
                    self!.shift_id = nil
                    self!.btnSelectShift.setTitle("All", for: .normal)

                }
                else
                {
                    self!.shift_id = dic["id"] as? Int
                    self!.btnSelectShift.setTitle(title, for: .normal)

                }
                self!.loadReport()
            }
              
            
            list.clear = {
                self.shift_id = nil
                self.btnSelectShift.setTitle("All", for: .normal)
                
                             list.dismiss(animated: true, completion: nil)

                        }

            
            parent_vc?.present(list, animated: true, completion: nil)

        }
    
    @IBAction func btnStartDate(_ sender: Any) {
        let calendar = calendarVC()

        if self.start_date != nil
        {
            calendar.startDate = Date(strDate: self.start_date!, formate: self.date_formate, UTC: true)
        }
        
        calendar.modalPresentationStyle = .formSheet
        calendar.didSelectDay = { [weak self] date in
            
            
            self?.start_date = date.toString(dateFormat:self!.date_formate)
            self?.btnStartDate.setTitle( self?.start_date, for: .normal)
            
            self?.end_date = date.toString(dateFormat:self!.date_formate)
            self?.btnEndDate.setTitle( self?.end_date, for: .normal)
            
            
             self?.doneSelect()
            
             calendar.dismiss(animated: true, completion: nil)
        }
        parent_vc?.present(calendar, animated: true, completion: nil)
    }
    
    @IBAction func btnEndDate(_ sender: Any) {
        let calendar = calendarVC()

        if self.end_date != nil
        {
            calendar.startDate = Date(strDate: self.end_date!, formate:self.date_formate, UTC: true)
        }
        
        calendar.modalPresentationStyle = .formSheet
        calendar.didSelectDay = { [weak self] date in
            
            
            self?.end_date = date.toString(dateFormat: self!.date_formate)
            self?.btnEndDate.setTitle(self?.end_date, for: .normal)
            
            
             self?.doneSelect()
            
            calendar.dismiss(animated: true, completion: nil)

        }
        parent_vc?.present(calendar, animated: true, completion: nil)
    }
    
 
    
    
    func loadReport()
    {
          dictionary.removeAll()
        total_discount = 0
        total_delivery_amount = 0
        
        let start_date =  get_start_date() //ClassDate.getWithFormate(txtDate.text, formate: date_formate, returnFormate: "yyyy-MM-dd",use_UTC: true) ?? ""
        let end_date =  get_end_date() //ClassDate.getWithFormate(txtDate_to.text, formate: date_formate, returnFormate: "yyyy-MM-dd",use_UTC: true) ?? ""
        
        option.between_start_session = []
        option.between_start_session?.append(start_date)
        option.between_start_session?.append(end_date)
        option.sesssion_id = shift_id  ?? 0
        option.parent_product = true
        option.write_pos_id = SharedManager.shared.posConfig().id

        showActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            self.html = self.printOrder_html()
//            SharedManager.shared.printLog( self.html )
            DispatchQueue.main.async {
                self.webView.loadHTMLString(self.html, baseURL:  Bundle.main.bundleURL)
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
        //        var lastSession = posSessionClass.getLastActiveSession()
        //        if lastSession == nil
        //        {
        //            lastSession = posSessionClass.getActiveSession()
        //        }
        
        var lastSession = pos_session_class.getActiveSession()
        if lastSession == nil
        {
            lastSession = pos_session_class.getLastActiveSession()
        }
        
        if lastSession != nil
        {
            let lastDate = lastSession!.start_session
            
            if lastDate != nil
            {
                //            let date =   ClassDate.convertTimeStampTodate( String(lastDate) , returnFormate: date_formate, timeZone: NSTimeZone.local)
                
                let dt = Date(strDate: lastDate!, formate: baseClass.date_fromate_satnder,UTC: false)
                start_date = dt.toString(dateFormat: date_formate, UTC: true)
                
//                start_date = ClassDate.getWithFormate(lastDate, formate: ClassDate.satnderFromate(), returnFormate: date_formate,use_UTC: true )
                end_date = start_date
                
              

//                txtDate.formateDate = date_formate
//                txtDate.textDate = date
//                txtDate.text = date
//
//                txtDate_to.formateDate = date_formate
//                txtDate_to.textDate = date
//                txtDate_to.text = date
                
            }
            else
            {
                start_date = Date().toString(dateFormat: date_formate, UTC: false) //ClassDate.getNow(date_formate , timeZone: NSTimeZone.local )
                 end_date = start_date
//                txtDate.formateDate = date_formate
//                txtDate.textDate = day
//                txtDate.text = day
//
//                txtDate_to.formateDate = date_formate
//                txtDate_to.textDate = day
//                txtDate_to.text = day
            }
        }
        else
        {
              start_date = Date().toString(dateFormat: date_formate, UTC: false) //ClassDate.getNow(date_formate , timeZone: NSTimeZone.local )
             end_date = start_date
            
//            txtDate.formateDate = date_formate
//            txtDate.textDate = day
//            txtDate.text = day
//
//            txtDate_to.formateDate = date_formate
//            txtDate_to.textDate = day
//            txtDate_to.text = day
        }
        
        
        btnStartDate.setTitle(start_date, for: .normal)
      btnEndDate.setTitle(end_date, for: .normal)
        
    }
    
    
    
    func printOrder(txt: String) {
        //        webView.fullLengthScreenshot { (image) in
        //            //            self.photo?.image = image
        //            if image != nil {
        //                EposPrint.runPrinterReceipt(  logoData: image , openDeawer: false)
        //            }
        //        }
        
        DispatchQueue.global(qos: .background).async {
            
            runner_print_class.runPrinterReceipt_image(  html: self.html, openDeawer: false,row_type: .report)
            
        }
        
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
             if image != nil
            {
                runner_print_class.runPrinterReceipt(  logoData: image , openDeawer: false)
                
             }
            
            self.is_printing = false

        }
        
    }
    
 
    
    func printOrder_setHeader(html: String) -> String {
        let rows_header:NSMutableString = NSMutableString()
//        let startDate =  txtDate.text
//        let endDate =  txtDate_to.text
        
        
        //        rows_header.append(" <tr><td>Cashier</td><td>: </td><td> \(activeSessionLast.shift_current!.casher.name)</td></tr>")
        //        let countOrders = ordersListClass.get_count(sql:getSQl(getCount: true))
        
        let pos = SharedManager.shared.posConfig()
        
        
            rows_header.append(" <tr><td>"+"POS Name".arabic("نقطة البيع")+"</td><td>: </td><td> \(pos.name!)</td></tr>")
            rows_header.append(" <tr><td>"+"FROM Date".arabic("البداية")+"</td><td>: </td><td> \(start_date ?? "")</td></tr>")
            rows_header.append(" <tr><td>"+"TO Date".arabic("النهاية")+"</td><td>: </td><td> \(end_date ?? "" )</td></tr>")
        
        
        
        if hide_count_orders == false
        {
            let countOrders = pos_order_helper_class.getOrders_status_sorted_count(options: option)

            
            rows_header.append(" <tr><td>"+"Total # Order".arabic("المجموع # الطلب")+"</td><td>: </td><td> \(countOrders)</td></tr>")


        }
        
        return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
    
    func printOrder_setOrders(html: String) -> String {
        return html.replacingOccurrences(of: "#rows_order", with: "")
    }
    
    
    func getProductList(list_products:[product_product_class],cobo_count:Double ,  isComboList:Bool)
    {
        /*
        for product in list_products {
            
            if product.pos_categ_id != 0
            {
                let category = product.pos_categ_name ?? ""
                var products = dictionary[category]
                
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
                            dictionary[category] = products
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
                    dictionary[category] = products
                    
                    if product.list_product_in_combo.count > 0
                    {
                        let productsCombo = product_product_class.readProducts(arr: product.list_product_in_combo)
                        getProductList(list_products: productsCombo  ,cobo_count: product.qty_app , isComboList:true)
                    }
                    
                }
                
                dictionary[category] = products
                
                
            }
        }
        */
        
    }
    
    func getProductList_new(lines:[pos_order_line_class],cobo_count:Double , isComboList:Bool)
    {
       
        for line in lines
        {
            let product = line.product!
//            if product.pos_categ_id != 0
//            {
                let category =   product.pos_categ_id ?? 0   //product.pos_categ_name ?? ""
                var products_lines = dictionary[category]
                
                if products_lines != nil {
                    var isExist:Bool = false
                    
                    for i in 0...products_lines!.count - 1
                    {
                        let storege_product = products_lines![i]
                        
                        if storege_product.product_id == product.id
                        {
                            isExist = true
                            
                            line.qty = line.qty  * cobo_count
                            
                            storege_product.qty  =  storege_product.qty  + line.qty
                            
                            if isComboList
                            {
                                line.price_subtotal_incl = line.extra_price!  * line.qty
                            }
                            
//                            line.price_subtotal_incl = (isComboList == true) ? line.extra_price : line.price_subtotal_incl
//                            line.price_subtotal_incl = line.price_subtotal_incl! * line.qty
                            
                            storege_product.price_subtotal_incl = storege_product.price_subtotal_incl! + line.price_subtotal_incl!
                            
                            products_lines![i] = storege_product
                            
                            
                            dictionary[category] = products_lines
                            
                            check_product_combo(line: line)
                            //                        if product.list_product_in_combo.count > 0
                            //                        {
                            //                            let productsCombo = productClass.readProducts(arr: product.list_product_in_combo)
                            //                            getProductList_new(list_products: productsCombo,cobo_count: product.qty_app , isComboList:true)
                            //                        }
                            
                        }
                    }
                    
                    if isExist == false
                    {
                        line.qty  = line.qty   * cobo_count
                        
                        if isComboList
                        {
                            line.price_subtotal_incl = line.extra_price!  * line.qty
                        }
//                        line.price_subtotal_incl = (isComboList == true) ? line.extra_price : line.price_unit
//                        line.price_subtotal_incl = line.price_subtotal_incl!  * line.qty
                        
                        products_lines?.append(line)
                        
                        check_product_combo(line: line)
                        
                        
                    }
                    
                } else {
                    
                    line.qty = line.qty * cobo_count
                    
                    if isComboList
                    {
                        line.price_subtotal_incl = line.extra_price!  * line.qty
                    }
                    
//                    line.price_subtotal_incl = (isComboList == true) ? line.extra_price : line.price_subtotal_incl
//                    line.price_subtotal_incl = line.price_subtotal_incl!  * line.qty
                    
                    products_lines = [line]
                    dictionary[category] = products_lines
                    
                    check_product_combo(line: line)
                    
                    //                if product.list_product_in_combo.count > 0
                    //                {
                    //                    let productsCombo = productClass.readProducts(arr: product.list_product_in_combo)
                    //                    getProductList_new(list_products: productsCombo , cobo_count:product.qty_app , isComboList:true)
                    //                }
                    
                }
                
                dictionary[category] = products_lines
                
                
            }
        
        
       
    }
    
    func check_product_combo(line:pos_order_line_class)
    {
         
        let list_sub = pos_order_line_class.get_lines_in_combo(order_id: line.order_id, product_id: line.product_id!,parent_line_id: line.id)
//            let productsCombo = product_product_class.readProducts(arr: product.list_product_in_combo)
            //            getProductList_new(list_products: productsCombo,cobo_count: product.qty_app , isComboList:true)
        
        if list_sub.count > 0
        {
            getProductList_new(lines: list_sub,cobo_count: 1 , isComboList:true)

        }
            
       
    }
    
    func getProductGroupByCateogry()
    {
        
        // =====================================================================================
        //              let sql = getSQl(getCount: false)
          
//        let pos_id = SharedManager.shared.posConfig().id
//        let start_date =  get_start_date()
//          let end_date =  get_end_date()
//
//        let sql = """
//            select pos_order.* from pos_order
//            inner join pos_session on pos_order.session_id_local = pos_session.id
//            inner join pos_order_account_journal on pos_order_account_journal.order_id = pos_order.id
//            where     pos_session.start_session between '\(start_date)' and '\(end_date)' and pos_order.write_pos_id  = \(pos_id)  order by pos_order.id desc
//            """
//
//         let arr =  database_class(connect: .database).get_rows(sql: sql)
        
        let arr = pos_order_helper_class.getOrders_status_sorted(options: option)
        
        for item in arr
        {
//            let item = pos_order_class(fromDictionary: obj)
            getProductList_new (lines: item.pos_order_lines ,cobo_count: 1, isComboList:false)

//            if item.discount != 0
//            {
//                 total_discount = total_discount + item.discount
//            }
            
            let line_discount = item.get_discount_line()
            if line_discount != nil
            {
                total_discount = total_discount + line_discount!.price_unit!
            }
            
            if item.delivery_amount != 0
            {
//                let delivery_amount = item.orderType?.delivery_amount ?? 0
                total_delivery_amount = total_delivery_amount + item.delivery_amount
            }
            
        }
        
        
        /*
        
        let sql = pos_order_helper_class.getOrders_status_sorted_Sql(options: option, getCount: false)
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
                
                // TODO: 
//                getProductList_new (list_products: item.pos_order_lines ,cobo_count: 1, isComboList:false)
                
                
                
                if item.discountProgram.amount != 0
                {
                    let discount_product = item.discountProgram.discount_product!
                    total_discount = total_discount + discount_product.product.lst_price.rounded()
                }
                
                if item.orderType?.delivery_amount != 0
                {
                    let delivery_amount = item.orderType?.delivery_amount ?? 0
                    total_delivery_amount = total_delivery_amount + delivery_amount
                }
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        */
        
    }
    
    func printOrder_setTotal(html: String) -> String {
        
        let rows_order:NSMutableString = NSMutableString()
        
        getProductGroupByCateogry()
        
        
        var  total_all = 0.0
        
        
        let sortedKeys = dictionary.sorted {$0.key < $1.key}
        if showProduct == false
        {
            rows_order.append("<tr><td colspan=\"3\" align=\"center\"><hr style=\"border: 2px dashed black;\"></td></tr>")
            
            
            
            rows_order.append("<tr>  <td><h3 style=\"line-height: 5px;\">"+"Name".arabic("الاسم")+"</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">"+"Qty".arabic("الكمية")+"</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">"+"Price".arabic("السعر")+"</h3></td>  </tr>")

            
        }
        
        for item in sortedKeys {
            if showProduct == true
            {
                let categ = item.value[0].product.pos_categ_name ?? ""

                
                rows_order.append(" <tr><td colspan=\"3\" align=\"center\"><hr style=\"border: 2px dashed black;\">\(categ)<hr style=\"border: 2px dashed black;\"></td></tr>")
                
                
                rows_order.append("<tr>  <td><h3 style=\"line-height: 5px;\">"+"Name".arabic("الاسم")+"</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">"+"Qty".arabic("الكمية")+"</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">"+"Price".arabic("السعر")+"</h3></td>  </tr>")

                
            }
            
            
            //            let products = dictionary[key]
            let products = item.value
            
            if   products.count > 0 {
                
                var total = 0.0
                var  total_qty = 0.0
                
                let sortedProducts =   products.sorted { $0.product.title < $1.product.title }
                
                for line in sortedProducts {
                    
                    if showProduct == true
                    {
                        let product = line.product
                        var tit = product!.title
//                        if !product!.attribute_names.isEmpty
//                        {
//                            tit = tit + " " + product!.attribute_names
//                        }
                        
                        rows_order.append(" <tr><td>\(tit) </td><td>\(line.qty.toIntString())</td><td> \(line.price_subtotal_incl!.toIntString())</td></tr>")
                    }

                  
                        total += line.price_subtotal_incl!

                     
                    
                    total_qty += line.qty
                    
                }
                
//                if item.value[0].parent_product_id == 0
//               {
                total_all = total_all + total
//                }
                
                if showProduct == true
                {
                    rows_order.append(" <tr><td><h3 style=\"line-height: 5px;\">Total</h3></td><td><h3 style=\"line-height: 5px;\">\(total_qty.toIntString())</h3></td><td><h3 style=\"line-height: 5px;\">\(total.toIntString())</h3></td></tr>")
                }
                    
                else
                {
                    var categ = item.value[0].product.pos_categ_name ?? ""
                    let lst = categ.split(separator: "/")
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
        
        rows_order.append("<tr><td><b>"+"Total Summary".arabic("الملخص الاجمالي")+"</b></td><td></td><td><b>\(total_all.rounded_formated_str())</b></td></tr>")

        
        
        if total_delivery_amount != 0
        {
            rows_order.append("<tr><td><b>"+"Total delivery".arabic("اجمالي التوصيل")+"</b></td><td></td><td><b>\(total_delivery_amount.rounded_formated_str())</b></td></tr>")
            
        }
        
        
        
        if hide_discount == false
        {
            
            
            rows_order.append("<tr><td><b>"+"Total Discount".arabic("اجمالي الخصم")+"</b></td><td></td><td><b>\(total_discount.rounded_formated_str())</b></td></tr>")
            
        }
        
        if hide_net == false
        {
            rows_order.append("<tr><td><b>"+"Total net".arabic("الاجمالي الصافي")+"</b></td><td></td><td><b>\((total_all + total_discount + total_delivery_amount).rounded_formated_str())</b></td></tr>")
        }
        
        
        return html.replacingOccurrences(of: "#rows_total", with: String(rows_order))
    }
    
    
    //    func getSessionForRange() -> [posSessionClass]
    //    {
    //
    //
    ////        let txtday = txtDate.text
    //        let fromDay =  get_start_date() // ClassDate.getWithFormate(txtday, formate: date_formate , returnFormate: "yyyy-MM-dd" ,use_UTC: true )
    //        let toDay = get_end_date() //ClassDate.getWithFormate( txtDate_to.text, formate: date_formate , returnFormate: "yyyy-MM-dd" ,use_UTC: true )
    //
    //        if fromDay == nil
    //        {
    //            return []
    //        }
    //
    //        //        let fromTime = ClassDate.convert(toTimeStamp: checkDay, dateFormate: date_formate, timeZone: NSTimeZone.local)
    //        //        let toTime = ClassDate.convert(toTimeStamp:  txtDate_to.text, dateFormate: date_formate, timeZone: NSTimeZone.local)
    //
    //
    //
    //
    //        let arr_Session:[posSessionClass] = posSessionClass.getSessionBetween(fromDate: fromDay, toDate: toDay)
    //
    //        //        let allSession = posSessionClass.getAllSessions()
    //        //
    //        //        for item in allSession
    //        //        {
    //        //            let session = posSessionClass(fromDictionary: item)
    //        //            let dt = ClassDate.convertTimeStampTodate(String( session.id) , returnFormate: date_formate, timeZone: NSTimeZone.local)
    //        //            let sessionTime = ClassDate.convert(toTimeStamp: dt, dateFormate: date_formate, timeZone: NSTimeZone.local)
    //        //
    //        //            if   sessionTime   >= fromTime  &&   sessionTime  <= toTime
    //        //            {
    //        //                arr_Session.append(session)
    //        //            }
    //        //
    //        //
    //        //        }
    //
    //        return arr_Session
    //
    //    }
    
    func get_start_date() -> String
    {
        let date_str = start_date!
        let checkDay = baseClass.get_date_local_to_search(DateOnly: date_str, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss")
        
        return checkDay
    }
    
    func get_end_date() -> String
    {
        let date_str = end_date!
        
        let endDaty_str = baseClass.get_date_local_to_search(DateOnly: date_str, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss",addHours: 24)
        
        return endDaty_str
    }
    
    
    //     func getSessionForDay() -> [posSessionClass]
    //        {
    //            var lst_sessions:[posSessionClass] = []
    //
    //            let start_date = get_start_date()
    //            let end_date = get_end_date()
    //
    //    //
    //    //        let txtday = String(format:"%@ 00:00:00" ,date_str )
    //    ////        var endDay:Date =  ClassDate.getDate(date_str, formate: "yyyy-MM-dd")
    //    //        var endDay = Date().toDate(date_str, format: "yyyy-MM-dd")
    //    //
    //    //        let checkDay = ClassDate.getWithFormate(txtday, formate: "yyyy/MM/dd HH:mm:ss", returnFormate: "yyyy-MM-dd HH:mm:ss",use_UTC: true)
    //    //
    //    //        if checkDay == nil
    //    //        {
    //    //            return []
    //    //        }
    //    //
    //    //        endDay = endDay.add( days: 1 )!
    //    //
    //    //        var endDaty_str = String(format:"%@ 00:00:00" , endDay.toString(dateFormat: "yyyy/MM/dd"))
    //    //        endDaty_str = ClassDate.getWithFormate(endDaty_str, formate: "yyyy/MM/dd HH:mm:ss", returnFormate: "yyyy-MM-dd HH:mm:ss",use_UTC: true)
    //
    //
    //
    //            let sql = "select * from sessions where start_session between '\(start_date)'  and  '\(end_date)'"
    //
    //
    //            let semaphore = DispatchSemaphore(value: 0)
    //            SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
    //
    //                let rows:FMResultSet = try! db.executeQuery(sql, values: [])
    //
    //                while rows.next()
    //                {
    //
    //                    let data = rows.string(forColumn: "data")
    //                    let dic =  data?.toDictionary() ?? [:]
    //                    let session = posSessionClass(fromDictionary: dic)
    //                    session.id = Int(rows.int(forColumn: "session_id"))
    //
    //
    //                    lst_sessions.append(session)
    //
    //                }
    //
    //                rows.close()
    //                semaphore.signal()
    //            }
    //
    //
    //            semaphore.wait()
    //
    //            //        let allSession = posSessionClass.getAllSessions()
    //            //
    //            //        for item in allSession
    //            //        {
    //            //            let session = posSessionClass(fromDictionary: item)
    //            //            let day = ClassDate.convertTimeStampTodate( String( session.id), returnFormate:"yyyy/MM/dd" , timeZone:NSTimeZone.local  )
    //            //
    //            //            if day == checkDay
    //            //            {
    //            //                return session
    //            //
    //            //            }
    //            //
    //            //        }
    //
    //            return lst_sessions
    //
    //        }
    //    func getSessionForDay() -> posSessionClass?
    //    {
    //
    //        let txtday = txtDate.text
    //        let checkDay = ClassDate.getWithFormate(txtday, formate: date_formate, returnFormate: date_formate ,use_UTC: true )
    //
    //        if checkDay == nil
    //        {
    //            return nil
    //        }
    //
    //        // TODO : fix it
    //
    //
    //
    //
    //        //        let allSession = posSessionClass.getAllSessions()
    //        //
    //        //        for item in allSession
    //        //        {
    //        //            let session = posSessionClass(fromDictionary: item)
    //        //            let day = ClassDate.convertTimeStampTodate( String( session.id), returnFormate:date_formate, timeZone:NSTimeZone.local  )
    //        //
    //        //            if day == checkDay
    //        //            {
    //        //                return session
    //        //
    //        //            }
    //        //
    //        //        }
    //
    //        return posSessionClass.getSession(day: checkDay!)
    //
    //    }
    
    func printOrder_html() -> String {
        
        
        var html = baseClass.get_file_html(filename: "products",showCopyRight: true)
//        let pos = SharedManager.shared.posConfig()
        
        var header = "" //pos.receipt_header
        if custom_header != nil
        {
            header = "  \(custom_header!)  " +  header
            
        }
        //html = html.replacingOccurrences(of: "#logo", with: pos.company!.logo )
        html = html.replacingOccurrences(of: "#header", with: header)
        //html = html.replacingOccurrences(of: "#footer", with: pos.receipt_footer)
        
        html = html.replacingOccurrences(of: "#font", with: app_font_name_printer + "-Regular")

        html = printOrder_setHeader(html: html)
        html = printOrder_setOrders(html: html)
        html = printOrder_setTotal(html: html)
        
        hideActivityIndicator()
        //        SharedManager.shared.printLog(html)
        return html
    }
    
    
    func doneSelect() {
        
        let def = baseClass.compareTwoDate(start_date!, dt2_new: end_date!, formate: date_formate)
        if def < 0
        {
            end_date = start_date
            printer_message_class.show("invaled date", vc: self)
        }
        else
        {
          
            loadReport()
        }
        
        
    }
    
    
    //    func getSQl(getCount:Bool)-> String
    //    {
    //        var select = "orders.*"
    //        if getCount == true
    //        {
    //            select = "count(*)"
    //        }
    //
    //        var sql = ""
    //        let txtday = txtDate.text
    //             let fromDay = ClassDate.getWithFormate(txtday, formate: date_formate , returnFormate: "yyyy-MM-dd" ,use_UTC: false ) ?? ""
    //             let toDay = ClassDate.getWithFormate( txtDate_to.text, formate: date_formate , returnFormate: "yyyy-MM-dd" ,use_UTC: false ) ?? ""
    //
    //        if fromDay != toDay
    //        {
    //            sql = "select  \(select) from orders inner join sessions on orders.session_id = sessions.session_id where sessions.start_session between '\(fromDay)' and '\(toDay)'"
    //        }
    //        else
    //        {
    //            sql = "select  \(select) from orders inner join sessions on orders.session_id = sessions.session_id where sessions.start_session like '\(fromDay)%'"
    //
    //        }
    //
    //        return sql
    //
    //    }
    
    
}
