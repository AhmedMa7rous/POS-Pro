//
//  products_rang_report2.swift
//  pos
//
//  Created by khaled on 01/04/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import WebKit

class Products_Rang_Report2: ReportViewController  {
    
 
    @IBOutlet weak var container: UIView!
 
 
    @IBOutlet weak var showQtyFactoryView: UIView!
    @IBOutlet weak var showQtyFactoryToggle: UISwitch!
    
    var tag:Int = 0
    
    var webView: WKWebView!
 

    
 
    var indc: UIActivityIndicatorView?
    
     @IBOutlet var btn_filtter: UIButton!
    
    
    var dictionary = [Int:[pos_order_line_class]]()
 
    
    var showProduct:Bool = true
    var hide_discount:Bool = false
    var hide_net:Bool = false
    var hide_count_orders:Bool = false

    var option   = ordersListOpetions()
    var selected_dic:[String:Any] = [:]

    
    //let date_formate = "dd/MM/yyyy"
    let date_formate = "yyyy-MM-dd hh:mm a"
    
    var start_date:String = ""
    var end_date:String = ""
    var shift_name:String = "By Time"
    
    var   html:String = ""
    
    var custom_header:String?
    var sub_header:String?

    var hideQtyFactoryView:Bool?
    var hide_qty_factory:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
  
        
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame:self.view.bounds, configuration: webConfiguration)
        //        webView.uiDelegate = self
        webView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        //        webView.frame = container.bounds
        container.addSubview(webView)
        self.showQtyFactoryView.isHidden = self.hideQtyFactoryView ?? true
        hide_qty_factory = !SharedManager.shared.appSetting().enable_quantity_factor_product_reports
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
 
        getLastBussinusDate()
 
        loadReport()
    }
    
    @IBAction func tapOnShowQtyFactoryToggle(_ sender: UISwitch) {
        hide_qty_factory = !sender.isOn
        loadReport()
    }
    
    func getLastBussinusDate()
    {
  
        option.between_start_session = []
        var start_date = ""
        
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
 
                let dt = Date(strDate: lastDate!, formate: baseClass.date_fromate_satnder,UTC: false)
                  start_date = dt.toString(dateFormat: date_formate, UTC: true)
                
                set_date_filtter(date: start_date)
              

                
            }
            else
            {
                  start_date = Date().toString(dateFormat: date_formate, UTC: false) //ClassDate.getNow(date_formate , timeZone: NSTimeZone.local )

                set_date_filtter(date: start_date)

            }
        }
        else
        {
             start_date = Date().toString(dateFormat: date_formate, UTC: false) //ClassDate.getNow(date_formate , timeZone: NSTimeZone.local )
            set_date_filtter(date: start_date)

        }
        
        var dic:[String:Any] = [:]
        dic["option"] = option
        dic["shift_name"] =  "By Time"
        dic["start_date"] = option.between_start_session?.first ?? start_date
        dic["end_date"] =  option.between_start_session?.last ?? start_date
        
       set_filter_title(dic)
        
    }
    
    func set_date_filtter(date:String)
    {
        //        let start_date =   baseClass.get_date_local_to_search(DateOnly: date, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss")
        //        let endDaty_str = baseClass.get_date_local_to_search(DateOnly: date, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss",addHours: 24)
        
        let start_date =   baseClass.get_date_local_to_search(DateOnly: date, format: date_formate ,returnFormate: date_formate)
        let endDaty_str = baseClass.get_date_local_to_search(DateOnly: date, format: date_formate ,returnFormate: date_formate,addHours: 24)
        
        option.between_start_session?.append(start_date)
        option.between_start_session?.append(endDaty_str)
    }
    
    
    
    func loadReport( )
    {
//          dictionary.removeAll()
//        total_discount = 0
//        total_delivery_amount = 0
//
//        let start_date =  get_start_date()
//        let end_date =  get_end_date()
//
//        option.between_start_session = []
//        option.between_start_session?.append(start_date)
//        option.between_start_session?.append(end_date)
//        option.sesssion_id = shift_id  ?? 0
//        option.parent_product = true
//        option.write_pos_id = SharedManager.shared.posConfig().id
//
        showActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            self.html = self.printOrder_html()
//            Swift.SharedManager.shared.printLog( self.html )
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
        DispatchQueue.main.async {
            self.indc?.startAnimating()
        }
    }
    
    func hideActivityIndicator(){
        if (indc != nil){
            DispatchQueue.main.async {
                self.indc?.stopAnimating()
            }
        }
    }
  
   
    
  
    
    @IBAction func btn_filter(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
       let  filter  = storyboard.instantiateViewController(withIdentifier: "filter_report") as! filter_report
        filter.modalPresentationStyle = .formSheet
        filter.selected_dic = selected_dic
        filter.withParseDate = true
        filter.didSelect = { [weak self] selected_option in
          
            self!.set_filter_title(selected_option)
            self!.loadReport()
        }
          
        
        parent_vc?.present(filter, animated: true, completion: nil)

        
    }
    
    func set_filter_title(_ dic:[String:Any])
    {
        self.selected_dic = dic
        let selected_option = dic["option"] as! ordersListOpetions
        option.betweenDate = selected_option.betweenDate
        option.between_start_session = selected_option.between_start_session
        option.sesssion_id = selected_option.sesssion_id
        shift_name = dic["shift_name"] as? String ?? ""
        start_date = dic["start_date"] as? String ?? ""
        end_date = dic["end_date"] as? String ?? ""

       
        
        let btn_title = shift_name + "          From:" + start_date  + "        To:" + end_date
        
        btn_filtter.setTitle(btn_title, for: .normal)

    }
 
    func printOrder_html() -> String {
        
        
        var html = baseClass.get_file_html(filename: "products",showCopyRight: true)
//        let pos = SharedManager.shared.posConfig()
        
        var header = "" //pos.receipt_header
        if custom_header != nil
        {
            header = "  \(custom_header!)  " +  header
            
        }
        if let sub_header = sub_header {
            header +=  """
            <span style = \"display: block;
            font-size:20px;
            text-align: center;\">
            \(sub_header)
            </span>
            """
        }
         html = html.replacingOccurrences(of: "#header", with: header)
 
        html = html.replacingOccurrences(of: "#font", with: app_font_name_printer + "-Regular")
        showActivityIndicator()
        
        html = printOrder_setHeader(html: html)
        html = html.replacingOccurrences(of: "#rows_order", with: "")
        html = build_report(html: html)
        
        
        if LanguageManager.currentLang() == .ar
        {
            html = html.replacingOccurrences(of: "#DIR#", with: style_right)
            value_dirction_style = "left"

        }
        else
        {
            html = html.replacingOccurrences(of: "#header", with: "")

        }

        
        hideActivityIndicator()
        //        SharedManager.shared.printLog(html)
        return html
    }
    
    func printOrder_setHeader(html: String) -> String {
        let rows_header:NSMutableString = NSMutableString()
 
        let pos = SharedManager.shared.posConfig()
        
        
            rows_header.append(" <tr><td>"+"POS Name".arabic("نقطة البيع")+"</td><td>: </td><td> \(pos.name!)</td></tr>")
        rows_header.append(" <tr><td>"+"FROM Date".arabic("البداية")+"</td><td>: </td><td> \(start_date )</td></tr>")
            rows_header.append(" <tr><td>"+"TO Date".arabic("النهاية")+"</td><td>: </td><td> \(end_date )</td></tr>")
        
        
        
        if hide_count_orders == false
        {
            let countOrders = pos_order_helper_class.getOrders_status_sorted_count(options: option)

            
            rows_header.append(" <tr><td>"+"Total # Order".arabic("المجموع # الطلب")+"</td><td>: </td><td> \(countOrders)</td></tr>")


        }
        
        return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
     
    
    func header_section(categ:String) -> String
    {
        if showProduct == false
        {
            return ""
        }
        
        let rows_order:NSMutableString = NSMutableString()

 
        rows_order.append(" <tr><td colspan=\"4\" style=\"text-align:center\"><hr style=\"border: 2px dashed black;\">\(categ)<hr style=\"border: 2px dashed black;\"></td></tr>")
        var width_qty_faactory = 13
        var title_qty_faactory:String = "Qty".arabic("الكمية")

        if self.hide_qty_factory{
            width_qty_faactory = 1
            title_qty_faactory = ""
        }
        rows_order.append("<tr>  <td><h4 style=\"line-height: 5px;\">"+"Name".arabic("الاسم") +
                          "</h4></td> <td style=\"width: \(width_qty_faactory)% \"><h4 style=\"line-height: 5px;\">" +
                          title_qty_faactory +
                          "</h4></td>  <td style=\"width: 13% \"><h4 style=\"line-height: 5px;\">" +
                          "Count".arabic("العدد") +
                          "</h4></td>  <td style=\"width: 13% \"><h4 style=\"line-height: 5px;\">" +
                          "Price".arabic("السعر")+"</h4></td>  </tr>")
        
        return String( rows_order)
    }
    
    func footer_section(qty_factory:Double, qty:Double , amount:Double) -> String
    {
        if showProduct == false
        {
            return ""
        }
        
        let rows_order:NSMutableString = NSMutableString()
        var width_style_qty_faactory = ""
        var title_qty_faactory:String = qty_factory.toIntString()

        if self.hide_qty_factory{
            width_style_qty_faactory = "width: 1%:"
            title_qty_faactory = ""
        }

 
        rows_order.append(" <tr><td><h4 style=\"line-height: 5px;\">\("Total".arabic("الاجمالى"))</h4></td><td><h4 style= \" \(width_style_qty_faactory) line-height: 5px;text-align:center\">\(title_qty_faactory)</h4></td><td><h4 style=\"line-height: 5px;text-align:center\">\(qty.toIntString())</h4></td><td><h4 style=\"line-height: 5px;text-align:center\">\(amount.toIntString())</h4></td></tr>")
         
        return String( rows_order)
    }
    
    func build_report(html: String) -> String
    {
        let query = get_query()
        let arr_data = query.result
        
        var total_all = 0.0

        if tag == 4
        {
            for item in arr_data
            {
                total_all = total_all  + (item["price_subtotal_incl"] as? Double ?? 0)
            }
        }
     
//        if arr_data.count == 0
//        {
//            return ""
//        }
        
        let rows_order:NSMutableString = NSMutableString()

        var last_pos_categ_name = ""
        var total_amount_categ:Double = 0
        var total_qty_categ:Double = 0
        var total_qty_factory_categ:Double = 0

        var total_amount_categ_summary:Double = 0
        var total_qty_categ_summary:Double = 0
        var total_qty_factory_categ_summary:Double = 0
        
        var width_qty_faactory = 13
        var title_qty_faactory:String = "Qty".arabic("الكمية")

        if self.hide_qty_factory{
            width_qty_faactory = 1
            title_qty_faactory = ""
        }
        
        if tag == 4 && showProduct == false {
            rows_order.append("<tr>  <td><h4 style=\"line-height: 5px;\">"+"Cateogry".arabic("التصنيف") +
                              "</h4></td> <td style=\"width: \(width_qty_faactory)% \"><h4 style=\"line-height: 5px;\">" +
                              title_qty_faactory +
                              "</h4></td>  <td style=\"width: 13% \"><h4 style=\"line-height: 5px;text-align:center;\">" +
                              "%" +
                              "</h4></td>  <td style=\"width: 13% \"><h4 style=\"line-height: 5px;\">" +
                              "Price".arabic("السعر")+"</h4></td>  </tr>")
        }
       
        if arr_data.count > 0
        {
        
        for i in 0...arr_data.count - 1
        {
            let row = arr_data[i]
            let pos_categ_name = row["pos_categ_name"] as? String ?? ""
            let name = row["name"] as? String ?? ""
            let name_ar = row["name_ar"] as? String ?? ""
            let cont = row["qty"] as? Double ?? 0
            let qty_factory = row["qty_factory"] as? Double ?? 1
            let qty = qty_factory * cont
            let price_subtotal_incl = row["price_subtotal_incl"] as? Double ?? 0
            
            total_amount_categ_summary = total_amount_categ_summary + price_subtotal_incl
            total_qty_categ_summary = total_qty_categ_summary + qty
            total_qty_factory_categ_summary = total_qty_factory_categ_summary + qty_factory

            
            if last_pos_categ_name == ""
            {
                rows_order.append(header_section(categ: pos_categ_name))
                last_pos_categ_name = pos_categ_name
                
                total_amount_categ = total_amount_categ + price_subtotal_incl
                total_qty_categ = total_qty_categ + qty
                total_qty_factory_categ = total_qty_factory_categ + (qty_factory * cont)
            }
            else if last_pos_categ_name == pos_categ_name
            {
                total_amount_categ = total_amount_categ + price_subtotal_incl
                total_qty_categ = total_qty_categ + qty
                total_qty_factory_categ = total_qty_factory_categ + (qty_factory * cont)



            }
            else if last_pos_categ_name != pos_categ_name
            {
                
                rows_order.append(footer_section(qty_factory: total_qty_factory_categ, qty: total_qty_categ, amount: total_amount_categ))
                
                last_pos_categ_name = pos_categ_name
                total_amount_categ = 0
                total_qty_categ = 0
                total_qty_factory_categ = 0

                
                total_amount_categ = total_amount_categ + price_subtotal_incl
                total_qty_categ = total_qty_categ + qty
                total_qty_factory_categ = total_qty_factory_categ + (qty_factory * cont)
                
                rows_order.append(header_section(categ: pos_categ_name))

                
            }
            
            
          
            if tag == 4
            {
                if showProduct == true
                {
                    rows_order.append(" <tr><td>\(name.arabic(name_ar)) (\(qty.toIntString())) </td><td style=\"text-align:center;\">\( ((price_subtotal_incl / total_all) * 100).toIntString() )%</td><td style=\"text-align:center;\"> \( price_subtotal_incl.toIntString())</td></tr>")

                }
                else
                {
                    // MARK: - Category summary report
                
//                    rows_order.append(" <tr><td>\(pos_categ_name) (\(qty.toIntString()))</td><td style=\"text-align:center;\"> \( ((price_subtotal_incl / total_all) * 100).toIntString() )%</td><td style=\"text-align:center;\"> \( price_subtotal_incl.toIntString())</td></tr>")
                    
                    rows_order.append(" <tr><td>\(pos_categ_name)  </td><td style=\"text-align:center;\"> \(qty.toIntString()) </td><td style=\"text-align:center;\"> \( ((price_subtotal_incl / total_all) * 100).toIntString() )% </td><td style=\"text-align:center;\"> \( price_subtotal_incl.toIntString())</td></tr>")


                }
            }
            else
            {
                if showProduct == true
                {
                    // MARK: - Products mix report,  Void Products, canceled products
                    var value_qty_faactory:String = qty_factory.toIntString()

                    if self.hide_qty_factory{
                        value_qty_faactory = ""
                    }

                    rows_order.append(" <tr><td>\(name.arabic(name_ar))  </td><td style=\" width: \(width_qty_faactory)%;  text-align:center;\"> \(value_qty_faactory) </td><td style=\"text-align:center;\"> \(qty.toIntString()) </td><td style=\"text-align:center;\"> \( price_subtotal_incl.toIntString())</td></tr>")

                }
                else
                {
                
                    rows_order.append(" <tr><td>\(pos_categ_name)  </td><td style=\"text-align:center;\">\(qty.toIntString())</td><td style=\"text-align:center;\"> \( price_subtotal_incl.toIntString())</td></tr>")

                }
            }
        
            

            if i == arr_data.count - 1
            {
                // MARK: - Void Products
                rows_order.append(footer_section(qty_factory: total_qty_factory_categ, qty: total_qty_categ, amount: total_amount_categ))

            }
        }
        }
        
        
        rows_order.append(" <tr><td colspan=\"4\" align=\"center\"> <hr style=\"border: 2px dashed black;\"></td></tr>")
        
        rows_order.append("<tr><td><b>"+"Total Summary".arabic("الملخص الاجمالي")+"</b></td><td></td><td></td><td><b>\(total_amount_categ_summary.rounded_formated_str())</b></td></tr>")
        
        let total_discount = get_discount_total(sessions: query.filter_session)
        let total_delivery_amount:Double = get_delivery_total(sessions: query.filter_session)
        
        
        if total_delivery_amount != 0
        {
            rows_order.append("<tr><td><b>"+"Total delivery".arabic("اجمالي التوصيل")+"</b></td><td></td><td></td><td><b>\(total_delivery_amount.rounded_formated_str())</b></td></tr>")
            
        }
        
        if hide_discount == false
        {
            
            
            rows_order.append("<tr><td><b>"+"Total Discount".arabic("اجمالي الخصم")+"</b></td><td></td><td></td><td><b>\(total_discount.rounded_formated_str())</b></td></tr>")
            
        }
        
        if hide_net == false
        {
            
             if option.parent_order == false
             {
                // return orders
                rows_order.append("<tr><td><b>"+"Total net".arabic("الاجمالي الصافي")+"</b></td><td></td><td></td><td><b>\((total_amount_categ_summary  ).rounded_formated_str())</b></td></tr>")
             }
            else
             {
                rows_order.append("<tr><td><b>"+"Total net".arabic("الاجمالي الصافي")+"</b></td><td></td><td></td><td><b>\((total_amount_categ_summary + total_discount + total_delivery_amount).rounded_formated_str())</b></td></tr>")
             }


        }
        
        return    html.replacingOccurrences(of: "#rows_total", with: String(rows_order))

    }
    
    func get_query() -> (result:[[String : Any]],filter_session:String)
    {
        let pos = SharedManager.shared.posConfig()
        var sessions = ""
        var sqlCreateBetween = ""
        if option.sesssion_id != 0 {
            sessions = "\(option.sesssion_id)"
        }else{
            if let create_between = option.betweenDate,  !create_between.isEmpty {
                sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"

            }else{
                let options_session = posSessionOptions()
                
                options_session.between_start_session = option.between_start_session
                
                let arr_session: [[String:Any]] =    pos_session_class.get_pos_sessions(options: options_session)
                for item in arr_session
                {
                    let id = item["id"] as? Int  ??  0
                    sessions = sessions + "," +  String( id)
                }
                if sessions.count > 0 {
                    sessions.removeFirst()
                }
            }
        }
        
        var group_by = "GROUP BY  id"
        if showProduct == false
        {
            group_by = "GROUP BY  pos_categ_name"
        }
        
        var is_void = 0
        var is_closed_query = ""
    
        if let is_closed = option.Closed {
            is_closed_query = "and pos_order.is_closed  = \(is_closed ? 1 : 0) "
        }

        if option.get_lines_void_only == true
        {
            is_void  = 1
        }
        
        var is_scrap = 0
        if option.orderSyncType == .scrap
        {
            is_scrap = 1
        }
        
        var return_orders = ""
        var write_pos_id_condation = ""

        if option.parent_order == false
        {
            return_orders = "and pos_order.parent_order_id != 0"
        }
        if let write_pos_id = option.write_pos_id
        {
            write_pos_id_condation = "and pos_order.write_pos_id = \(write_pos_id)"
        }
        var void_status_condation = ""
        if let void_status = option.void_status{
            void_status_condation = "and pos_order_line.void_status = \(void_status.rawValue)"
        }
        var querySession = ""
        if !sqlCreateBetween.isEmpty {
            querySession = sqlCreateBetween
        }else{
            querySession = "pos_order.session_id_local  in (  \(sessions) )"
        }
        let sql = """

            SELECT  pos_categ_name, name ,name_ar,calculated_quantity as qty_factory, SUM(qty) as qty ,SUM(price_subtotal_incl) as price_subtotal_incl
            from (

            SELECT product_product.pos_categ_id ,pos_category.name as pos_categ_name , product_product.id , product_product.name  ,product_product.calculated_quantity, product_product.name_ar,pos_order_line.qty ,pos_order_line.price_subtotal_incl from pos_order
            inner join pos_order_line
            on pos_order.id = pos_order_line.order_id
            inner join product_product
            on pos_order_line.product_id = product_product.id
            inner join pos_category
            on pos_category.id  = product_product.pos_categ_id
            where
            \(querySession)
            and pos_order_line.product_id not in (SELECT discount_program_product_id from pos_config where id = \(pos.id) )
            and pos_order_line.is_void  = \(is_void) \(void_status_condation) and pos_order.order_sync_type = \(is_scrap) \(is_closed_query)
            \(return_orders) \(write_pos_id_condation)
            )
            \(group_by)
            order by pos_categ_name

        """
        
        SharedManager.shared.printLog(sql)
        
        let cls = pos_order_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        
        return (arr,sessions)
        
    }
   
   
    
    func get_discount_total(sessions:String) -> Double
    {
        let pos = SharedManager.shared.posConfig()
        
      
        let sql = """
            SELECT  SUM(price_subtotal_incl) as total
            from (

            SELECT  pos_order_line.qty ,pos_order_line.price_subtotal_incl from pos_order
            inner join pos_order_line
            on pos_order.id = pos_order_line.order_id
             
            where
            pos_order.session_id_local  in ( \(sessions)  )
            and pos_order_line.product_id   in (SELECT discount_program_product_id from pos_config where id = \(pos.id))
            and pos_order_line.is_void  = 0  and pos_order_line.is_scrap  = 0
            )
        """
        
        let cls = pos_order_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        
        if arr.count > 0
        {
            let total = arr[0]["total"] as? Double ?? 0
            return total
        }
        
        return 0
        
    }
    func get_delivery_total(sessions:String) -> Double
    {
        let sql = """
            SELECT  SUM(price_subtotal_incl) as total
            from (

            SELECT  pos_order_line.qty ,pos_order_line.price_subtotal_incl from pos_order
            inner join pos_order_line
            on pos_order.id = pos_order_line.order_id
             
            where
            pos_order.session_id_local  in ( \(sessions)  )
            and pos_order_line.product_id   in (SELECT  delivery_type.delivery_product_id from delivery_type where order_type = "delivery")
            and pos_order_line.is_void  = 0  and pos_order_line.is_scrap  = 0
            )
        """
        
        let cls = pos_order_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        
        if arr.count > 0
        {
            let total = arr[0]["total"] as? Double ?? 0
            return total
        }
        
        return 0
        
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
    
}
