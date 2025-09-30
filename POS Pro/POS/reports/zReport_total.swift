//
//  zReport.swift
//  pos
//
//  Created by khaled on 9/27/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit

class zReport_total: ReportViewController   ,WKNavigationDelegate{
    
    var delegate : zReport_delegate?
    
    var indc: UIActivityIndicatorView?
    
    @IBOutlet var btnStartDate: UIButton!
    @IBOutlet var btnSelectShift: UIButton!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nav: ShadowView!
    
    
    var webView: WKWebView!
 
    let option   = ordersListOpetions()
    
    var sessions_list:[pos_session_class]?
    
    var hideNav:Bool = false
    
  var shift_id:Int?

    
    var html:String = ""
    
    var start_date:String?
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame:container.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self
        //        webView.uiDelegate = self
        
        webView.frame = container.bounds
        //        webView.backgroundColor = UIColor.red
        
        webView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        container.addSubview(webView)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nav.isHidden = hideNav
        
        
        
        getLastBussinusDate()
      
        loadReport()
        
    }
    
    
    @IBAction func btnSelectShift(_ sender: Any) {
        
        let list = options_listVC()
        list.modalPresentationStyle = .formSheet
        
        list.list_items.append([options_listVC.title_prefex:"All"])
        
        let options = posSessionOptions()
        //           options.start_session = get_start_date()
        options.between_start_session = [get_start_date(),get_end_date()]
        
        
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
            calendar.startDate = Date(strDate: self.start_date!, formate: "yyyy-MM-dd", UTC: true)
        }
        
        calendar.modalPresentationStyle = .formSheet
        calendar.didSelectDay = { [weak self] date in
            
            
            self?.start_date =  date.toString(dateFormat:"yyyy-MM-dd")
            self!.setbtnStartDateTitle(date:  date.toString(dateFormat:baseClass.date_fromate_satnder))
            
            self!.shift_id = nil
            self!.btnSelectShift.setTitle("All", for: .normal)
            
            
            self?.doneSelect()
            
            calendar.dismiss(animated: true, completion: nil)
        }
        
        calendar.clearDay = {
            
            calendar.dismiss(animated: true, completion: nil)
            
        }
        
        parent_vc?.present(calendar, animated: true, completion: nil)
    }
    
    func setbtnStartDateTitle(date:String?)
    {
        var new_date = date
        if new_date == nil
        {
            new_date = Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: false)
        }
        //       let dt =   ClassDate.getWithFormate(start_date, formate: "yyyy-MM-dd", returnFormate:  "dd/MM/yyyy" ,use_UTC: true )
        let dt = Date(strDate: new_date!, formate:  baseClass.date_fromate_satnder,UTC: true)
        let checkDay = dt.toString(dateFormat: "dd/MM/yyyy" , UTC: false)
        
        
        self.btnStartDate.setTitle(checkDay, for: .normal)
        
    }
    
    func loadReport()
    {
        showActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            
            DispatchQueue.main.async {
                
                self.html = self.printOrder_html()
                self.webView.loadHTMLString(self.html, baseURL: Bundle.main.bundleURL)
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
    

        
    
       
       func get_before_start_date() -> String
       {
           
           let endDaty_str = baseClass.get_date_local_to_search(DateOnly: start_date!, format: "yyyy-MM-dd" ,returnFormate: baseClass.date_formate_database,addHours: -24)
           
           return endDaty_str
       }
       
       
       func get_start_date() -> String
       {
           
           let checkDay = baseClass.get_date_local_to_search(DateOnly: start_date!, format: "yyyy-MM-dd" ,returnFormate:  baseClass.date_formate_database)
           
           return checkDay
       }
       
       func get_end_date() -> String
       {
           
           let endDaty_str = baseClass.get_date_local_to_search(DateOnly: start_date!, format: "yyyy-MM-dd" ,returnFormate:  baseClass.date_formate_database,addHours: 24)
           
           return endDaty_str
       }
       
    func getLastBussinusDate()
    {
        //        var lastSession = posSessionClass.getLastActiveSession()
        //        if lastSession == nil
        //        {
        //            lastSession = posSessionClass.getActiveSession()
        //        }
        var lastSession:pos_session_class?
        
        if activeSessionLast != nil
        {
            lastSession = activeSessionLast
            
        }
        else
        {
            lastSession = pos_session_class.getActiveSession()
            if lastSession == nil
            {
                lastSession = pos_session_class.getLastActiveSession()
            }
        }
        
        
        
        var lastDate:String?
        if lastSession != nil
        {
            lastDate = lastSession!.start_session
            
            if lastDate != nil
            {
                //            let date =   ClassDate.convertTimeStampTodate( String(lastDate) , returnFormate: "yyyy/MM/dd" , timeZone: NSTimeZone.local)
                //            let date = ClassDate.getOnly(lastDate, formate: ClassDate.satnderFromate(), returnFormate:  "yyyy-MM-dd"  )
                
                let dt = Date(strDate: lastDate!, formate: baseClass.date_fromate_satnder,UTC: false)
                start_date = dt.toString(dateFormat: "yyyy-MM-dd", UTC: false)
                
                //                start_date = ClassDate.getWithFormate(lastDate, formate: ClassDate.satnderFromate(), returnFormate:  "yyyy-MM-dd" ,use_UTC: true )
                
                
            }
            else
            {
                start_date = Date().toString(dateFormat: "yyyy-MM-dd", UTC: false) //ClassDate.getNow("yyyy-MM-dd", timeZone: NSTimeZone.local )
                
            }
            
            
        }
        else
        {
            start_date = Date().toString(dateFormat: "yyyy-MM-dd", UTC: false) //ClassDate.getNow("yyyy-MM-dd", timeZone: NSTimeZone.local )
            
        }
        
        setbtnStartDateTitle(date: lastDate)
        
    }
    
       func getSessionForDay() -> [pos_session_class]
       {
           var lst_sessions:[pos_session_class] = []
           
           let start_date = get_start_date()
           let end_date = get_end_date()
           
           
           let options = posSessionOptions()
           options.between_start_session = [start_date,end_date]
           
           lst_sessions = pos_session_class.get_pos_sessions(options: options)
           
          
           
           
           return lst_sessions
           
       }
       
       func printOrder_html() -> String {
           
         
           
           sessions_list = getSessionForDay()
           if sessions_list?.count == 0
           {
               hideActivityIndicator()
               
               return ""
           }
           
       
           
           var html = baseClass.get_file_html(filename: "z_report",showCopyRight: true)
//           let pos = SharedManager.shared.posConfig()
           
           //html = html.replacingOccurrences(of: "#logo", with: pos.company!.logo )
//           html = html.replacingOccurrences(of: "#header", with: pos.receipt_header!)
           //html = html.replacingOccurrences(of: "#footer", with: pos.receipt_footer)
        html = html.replacingOccurrences(of: "#header", with: "")

           html = html.replacingOccurrences(of: "#font", with: app_font_name_printer + "-Regular")
           
           
           html = printOrder_setHeader(html: html)
           
           html = printOrder_setTotal(html: html )
           
           //                SharedManager.shared.printLog("%@", html)
           
           hideActivityIndicator()
           return html
       }
       
       func get_sessions_ids() -> String
       {
           var ids = ""
           
           for item in sessions_list! {
               ids =  ids + "," + String( item.id)
           }
           ids.removeFirst()
           
           return ids
       }
       
       func doneSelect() {
           
           loadReport()
        
           
       }
    
    
    
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!){
        
        if print_inOpen == true && SharedManager.shared.appSetting().enable_autoPrint == true
        {
            self.perform(#selector(print), with: nil, afterDelay: 1)
            
        }
        
        if auto_close == true
        {
            self.perform(#selector(close), with: nil, afterDelay: 5)
            
        }
    }
    
    @objc public func print()
    {
     
        
        webView?.fullLengthScreenshot { (image) in
            //            self.photo?.image = image
            if image != nil
            {
                runner_print_class.runPrinterReceipt(  logoData: image , openDeawer: false)
                
                self.show_printer_dialog()
                
            }
        }
        
    }
    
    
    
    
    
    @IBAction func btnPrint(_ sender: Any) {
        self.print()
    }
    
    @objc func close()
    {
        if delegate != nil
        {
            delegate?.zReport_didClosed()
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func btnBack(_ sender: Any) {
        close()
    }
    
   
    
    

    
   
  
    
 
    
    func printOrder_setHeader(html: String) -> String {
        let rows_header:NSMutableString = NSMutableString()
        
        let session = sessions_list![0]
        
        let dt = Date(strDate: session.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
        let startDate = dt.toString(dateFormat: "dd/MM/yyyy", UTC: false)
        
        //        let startDate =  ClassDate.getWithFormate(session.start_session, formate: ClassDate.satnderFromate(), returnFormate: "dd/MM/yyyy",use_UTC: true )
        
        //        rows_header.append(" <tr><td>Cashier</td><td>: </td><td> \(activeSessionLast.shift_current!.casher.name)</td></tr>")
        
        
        if LanguageManager.currentLang() == .ar {
            rows_header.append(" <tr><td>نقطة البيع</td><td>: </td><td> \(session.pos().name!)</td></tr>")
            rows_header.append(" <tr><td>اليوم</td><td>: </td><td> \(startDate )</td></tr>")
        } else {
        rows_header.append(" <tr><td>POS Name</td><td>: </td><td> \(session.pos().name!)</td></tr>")
        rows_header.append(" <tr><td>Business day</td><td>: </td><td> \(startDate )</td></tr>")
        }
        
        return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
    
    func printOrder_setTotal(html: String  ) -> String {
        let rows :NSMutableString = NSMutableString()
 
         let sesstion_ids = get_sessions_ids()
        
        
        let totalOrderTax = getTotal_order(sesstion_ids: sesstion_ids)
        rows.append( total_order_tax_html(price_subtotal_incl:  totalOrderTax.price_subtotal_incl, price_subtotal: totalOrderTax.price_subtotal, amount_tax:  totalOrderTax.amount_tax))

           let total = get_Statistics(  sesstion_ids: sesstion_ids)
        rows.append( total_statistics_html(total_void: total.total_void, total_return: total.total_return, total_discount: total.total_discount,total_product_return: total.total_product_return,total_insurances_return: total.total_insurance_return))

        let gbdc = get_group_by_deliveryType_accountJournal(  sesstion_ids: sesstion_ids)
        rows.append( get_group_by_deliveryType_accountJournal_html(list: gbdc.list, total_all: gbdc.total_all, count_all: gbdc.count_all))
        
        let gbaj = get_group_by_accountJournal(  sesstion_ids: sesstion_ids)
        rows.append( get_group_by_accountJournal_html(list: gbaj.list, total_all: gbaj.total_all, count_all: gbaj.count_all))
        
        
        let gbd  = get_group_by_deliveryType(  sesstion_ids: sesstion_ids)
        rows.append( get_group_by_deliveryType_html(list: gbd.list, total_all: gbd.total_all, count_all: gbd.count_all))
        
        
       return html.replacingOccurrences(of: "#rows_total", with: String(rows))
    }
    
     
    func getTotal_order( sesstion_ids:String) -> (price_subtotal_incl:Double,price_subtotal:Double,amount_tax:Double)
    {
        
        
        var  price_subtotal_incl = 0.0
        var  price_subtotal = 0.0
        var  amount_tax = 0.0
        
        // =====================================================================================
        
        let sql = """
        SELECT  SUM(price_subtotal_incl) as price_subtotal_incl ,  SUM(price_subtotal) as price_subtotal  ,( SELECT  SUM(amount_tax)    FROM  pos_order  where  session_id_local in (\(sesstion_ids))
        )  as amount_tax   FROM  pos_order_line
        inner join pos_order on  pos_order_line.order_id  = pos_order.id
        where   pos_order_line.is_void = 0  and session_id_local in (\(sesstion_ids))
        """
        
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            if (rows.next()) {
                //retrieve values for each record
                price_subtotal_incl = rows.double(forColumn: "price_subtotal_incl")
                price_subtotal = rows.double(forColumn: "price_subtotal")
                amount_tax = rows.double   (forColumn: "amount_tax")
                
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        
        return (price_subtotal_incl,price_subtotal,amount_tax)
    }
    func total_order_tax_html(price_subtotal_incl:Double,price_subtotal:Double,amount_tax:Double) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        
        rows.append("<br /><table style=\"width: 98%;text-align: left; border: 4px solid black; padding: 20px\">")
        
        
            rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> "+"Order summary".arabic("ملخص الطلب")+" </u> </h3>  </td>    </tr>")
            
            rows.append("<tr> <td> "+"Total with tax".arabic("المجموع بالضريبة")+"  </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   price_subtotal_incl.rounded_formated_str(max_len: 12) ) </td> </tr>")
            rows.append("<tr> <td> "+"Total w\\o Tax".arabic("المجموع بدون الضريبة")+"  </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   price_subtotal.rounded_formated_str(max_len: 12) ) </td> </tr>")
            rows.append("<tr> <td> "+"Tax".arabic("الضريبة")+" </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(  amount_tax.rounded_formated_str(max_len: 12) ) </td> </tr>")
        
        
//        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day order summary</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        rows.append("</table>")
        
        return String(rows)
    }
    
    
    func get_Statistics( sesstion_ids:String) -> (total_void:Double,total_return:Double,total_discount:Double,total_product_return:Double,total_insurance_return:Double)
    {
        
        var posID = SharedManager.shared.posConfig().id
        let posWriteQuery = "pos_order.write_pos_id  = \(posID)"
        
        var  total_void = 0.0
        var  total_return = 0.0
        var  total_discount  = 0.0
        var  total_product_return  = 0.0
        var  total_insurance_return  = 0.0

        // =====================================================================================
        
        let sql_total_void = "SELECT  sum(amount_total) as total_void  from pos_order  where session_id_local in (\(sesstion_ids)) and is_void  = 1 "
        let sql_total_return = "SELECT  sum(amount_total) as total_return  from pos_order  where session_id_local  in (\(sesstion_ids)) and amount_total < 0 and pos_order.is_closed  = 1"
        let sql_total_discount =  """
        SELECT sum (price_subtotal_incl) as total_discount from (
        SELECT (pos_order_line.price_subtotal_incl)  from pos_order
        inner join pos_order_line
        on pos_order.id = pos_order_line.order_id
        where session_id_local  in (\(sesstion_ids))  and pos_order_line.price_unit < 0 and pos_order_line.is_void  = 0 and pos_order.is_closed  = 1 GROUP BY pos_order.id)
        """
        let sql_total_product_return = "SELECT SUM(pos_order.amount_total) as total_product_return from pos_order where pos_order.session_id_local in (\(sesstion_ids)) and pos_order.amount_total < 0 and pos_order.is_closed = 1 and \(posWriteQuery) and pos_order.parent_order_id not in ( SELECT pio.insurance_id from pos_insurance_order pio WHERE pio.insurance_id in ( SELECT pos_order.parent_order_id from pos_order where pos_order.session_id_local in (\(sesstion_ids)) and pos_order.amount_total < 0 and pos_order.is_closed = 1 and \(posWriteQuery) ) )"
        let sql_total_insurance_return = "SELECT sum(total_insurance_return) as total_insurance_return from ( SELECT  sum(pos_order.amount_total) as total_insurance_return  from pos_order, pos_insurance_order  where pos_order.parent_order_id = pos_insurance_order.insurance_id and pos_order.session_id_local  in (\(sesstion_ids)) and pos_order.amount_total < 0 and pos_order.is_closed  = 1 and \(posWriteQuery) GROUP by pos_order.id )"
        total_void = database_class(connect: .database).get_row(sql: sql_total_void)?["total_void"] as? Double ?? 0
        total_return = database_class(connect: .database).get_row(sql: sql_total_return)?["total_return"] as? Double ?? 0
        total_discount = database_class(connect: .database).get_row(sql: sql_total_discount)?["total_discount"] as? Double ?? 0
        total_product_return = database_class(connect: .database).get_row(sql: sql_total_product_return)?["total_product_return"] as? Double ?? 0
        total_insurance_return = database_class(connect: .database).get_row(sql: sql_total_insurance_return)?["total_insurance_return"] as? Double ?? 0

        
        return (total_void,total_return,total_discount,total_product_return,total_insurance_return)
    }
    
    func total_statistics_html (total_void:Double,total_return:Double,total_discount:Double,total_product_return:Double,total_insurances_return:Double) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        
        rows.append("<br /><table style=\"width: 98%;text-align: left; border: 4px solid black; padding: 20px\">")
        
        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> ملخص اليوم </u> </h3>  </td>    </tr>")
            
            rows.append("<tr> <td> الطلبات الملغية </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   total_void.rounded_formated_str(max_len: 12) ) </td> </tr>")
//            rows.append("<tr> <td> المرتجعات_old  </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(  total_return.rounded_formated_str(max_len: 12) ) </td> </tr>")
            rows.append("<tr> <td> \(MWConstants.return_products_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_product_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> \(MWConstants.return_insurance_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_insurances_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr> <td> الخصومات </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   total_discount.rounded_formated_str(max_len: 12) ) </td> </tr>")
        } else {
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> Day summary </u> </h3>  </td>    </tr>")
        
        rows.append("<tr> <td> Void order </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   total_void.rounded_formated_str(max_len: 12) ) </td> </tr>")
//        rows.append("<tr> <td> Return order_old  </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(  total_return.rounded_formated_str(max_len: 12) ) </td> </tr>")
            rows.append("<tr> <td> \(MWConstants.return_products_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_product_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> \(MWConstants.return_insurance_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_insurances_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> Discount </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   total_discount.rounded_formated_str(max_len: 12) ) </td> </tr>")
        }
        
//        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day  summary</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        rows.append("</table>")
        
        return String(rows)
    }
    
    
    func get_group_by_deliveryType_accountJournal(sesstion_ids:String) -> (list:[String:[String:Any]],total_all:Double,count_all:Double)
    {
        var total_dic:[String:[String:Any]]! = [:]
         
        var total_all = 0.0
        var count_all = 0.0
        
        let sql = """
        
        select  account_journal.display_name as payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || account_journal.display_name)  as new_display_name ,
        \(MWConstants.selectTotalStatmentQry) ,pos_order.delivery_amount , count(*) as count
        from pos_order
        inner join pos_order_account_journal on pos_order.id = pos_order_account_journal.order_id
        inner join delivery_type on delivery_type.id =  pos_order.delivery_type_id
        inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
        
        where   pos_order.session_id_local in (\(sesstion_ids))
        
        group by  new_display_name
        """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                
                let payment_method = rows.string(forColumn: "payment_method") ?? ""
//                let delivery_type = rows.string(forColumn: "delivery_type") ?? ""
                let new_display_name = rows.string(forColumn: "new_display_name") ?? ""
                let total = rows.double (forColumn: "total")
                let count = rows.double (forColumn: "count")
                
                total_all += total
                count_all += count

             
                 
                var orderType_summery = total_dic[new_display_name] ??  [:]
                var total_summery = orderType_summery["total"] as? Double ?? 0
                var total_count = orderType_summery["count"] as? Double ?? 0
                
                total_summery = total_summery + total
                total_count = total_count + count
                
                
                
                orderType_summery["total"] = total_summery
                orderType_summery["count"] = total_count
                orderType_summery["bankStatement"] = payment_method
                
                
                
                total_dic[new_display_name] = orderType_summery
                
                
                
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        return (total_dic,total_all,count_all)
    }
    
     func get_group_by_deliveryType_accountJournal_html (list:[String:[String:Any]] ,total_all:Double,count_all:Double ) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        
        
        rows.append("<br /><table style=\"width: 98%;text-align: left; border: 4px solid black; padding: 20px\">")
        rows.append("<tr>  <td >   <h3 style=\"line-height: 0%\"> <u>"+"Payment".arabic("الدفع")+"  </u> </h3>  </td>  <td> % </td>   <td style = \"text-align: right;\" > \(SharedManager.shared.getCurrencyName()) </td>  </tr>")

        
        for (key,value) in list
        {
            let total:Double = value["total"] as? Double ?? 0
            let prec = (total / total_all ) * 100
            
            rows.append("<tr> <td>  \(   key ) </td>  <td> \(  prec.rounded_formated_str(max_len: 6) ) </td> <td style=\"text-align:right;\">   \(  total.rounded_formated_str(max_len: 12) ) </td> </tr>")
 
        }
   
 
        
//        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day  Payment</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        rows.append("</table>")
        
        return String(rows)
    }
    

        func get_group_by_deliveryType (sesstion_ids:String) -> (list:[String:[String:Any]],total_all:Double,count_all:Double)
        {
            var total_dic:[String:[String:Any]]! = [:]
             
            var total_all = 0.0
            var count_all = 0.0
            
            let sql = """
            select    payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || payment_method )  as new_display_name ,
                   sum( due )    as total , total_orders.delivery_amount , count(*) as count
                   from
                   (
                   SELECT count(*) as cnt ,(SUM(due) -  sum(rest)) as due ,order_id ,account_journal.display_name as payment_method ,pos_order.delivery_type_id,pos_order.delivery_amount as delivery_amount  from pos_order_account_journal
                   inner join  pos_order   on pos_order.id = pos_order_account_journal.order_id
                   inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
                   where   pos_order.session_id_local  in (\(sesstion_ids))
                   group by  pos_order.id ) as total_orders
                   inner join delivery_type on delivery_type.id =   delivery_type_id
                   group by  delivery_type
            """
            
            let semaphore = DispatchSemaphore(value: 0)
            SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
                
                let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
                while (rows.next()) {
                    //retrieve values for each record
                    
                    let payment_method = rows.string(forColumn: "payment_method") ?? ""
                    let delivery_type = rows.string(forColumn: "delivery_type") ?? ""
           
                    let total = rows.double (forColumn: "total")
                    let count = rows.double (forColumn: "count")
                    
                    total_all += total
                    count_all += count

                 
                     
                    var orderType_summery = total_dic[delivery_type] ??  [:]
                    var total_summery = orderType_summery["total"] as? Double ?? 0
                    var total_count = orderType_summery["count"] as? Double ?? 0
                    
                    total_summery = total_summery + total
                    total_count = total_count + count
                    
                    
                    
                    orderType_summery["total"] = total_summery
                    orderType_summery["count"] = total_count
                    orderType_summery["bankStatement"] = payment_method
                    
                    
                    
                    total_dic[delivery_type] = orderType_summery
                    
                    
                    
                    
                    // =====================================================================================
                }
                
                rows.close()
                semaphore.signal()
            }
            
            
            semaphore.wait()
            // =====================================================================================
            
            return (total_dic,total_all,count_all)
        }
        
         func get_group_by_deliveryType_html (list:[String:[String:Any]] ,total_all:Double,count_all:Double ) -> String
        {
            let rows :NSMutableString = NSMutableString()
            
            
            
            rows.append("<br /><table style=\"width: 98%;text-align: left; border: 4px solid black; padding: 20px\">")
            rows.append("<tr>  <td >   <h3 style=\"line-height: 0%\"> <u>Order type  </u> </h3>  </td>  <td>   </td>   <td style = \"text-align: right;\"> \(SharedManager.shared.getCurrencyName()) </td>  </tr>")
            
            for (key,value) in list
            {
                let total:Double = value["total"] as? Double ?? 0
                let count:Double = value["count"] as? Double ?? 0

                let prec = (total / total_all ) * 100
                
                rows.append("<tr> <td>\(count.toIntString())  \(   key ) </td>  <td> \(  prec.rounded_formated_str(max_len: 6) ) %</td> <td style=\"text-align:right;\">   \(  total.rounded_formated_str(max_len: 12,always_show_fraction: false) ) </td> </tr>")
     
            }
       
     
            
//            rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day    Order type</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
            
            rows.append("</table>")
            
            return String(rows)
        }
        
      func get_group_by_accountJournal (sesstion_ids:String) -> (list:[String:[String:Any]],total_all:Double,count_all:Double)
       {
           var total_dic:[String:[String:Any]]! = [:]
            
           var total_all = 0.0
           var count_all = 0.0
           
           let sql = """
           select    payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || payment_method )  as new_display_name ,
                  sum( due )    as total , total_orders.delivery_amount , count(*) as count
                  from
                  (
                  SELECT count(*) as cnt ,(SUM(due) -  sum(rest)) as due ,order_id ,account_journal.display_name as payment_method ,pos_order.delivery_type_id,pos_order.delivery_amount as delivery_amount  from pos_order_account_journal
                  inner join  pos_order   on pos_order.id = pos_order_account_journal.order_id
                  inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
                  where   pos_order.session_id_local  in (\(sesstion_ids))
                  group by  pos_order.id ) as total_orders
                  inner join delivery_type on delivery_type.id =   delivery_type_id
                  group by  payment_method
           """
           
           let semaphore = DispatchSemaphore(value: 0)
           SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
               
               let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
               while (rows.next()) {
                   //retrieve values for each record
                   
                   let payment_method = rows.string(forColumn: "payment_method") ?? ""
//                   let delivery_type = rows.string(forColumn: "delivery_type") ?? ""
          
                   let total = rows.double (forColumn: "total")
                   let count = rows.double (forColumn: "count")
                   
                   total_all += total
                   count_all += count

                
                    
                   var orderType_summery = total_dic[payment_method] ??  [:]
                   var total_summery = orderType_summery["total"] as? Double ?? 0
                   var total_count = orderType_summery["count"] as? Double ?? 0
                   
                   total_summery = total_summery + total
                   total_count = total_count + count
                   
                   
                   
                   orderType_summery["total"] = total_summery
                   orderType_summery["count"] = total_count
                   orderType_summery["bankStatement"] = payment_method
                   
                   
                   
                   total_dic[payment_method] = orderType_summery
                   
                   
                   
                   
                   // =====================================================================================
               }
               
               rows.close()
               semaphore.signal()
           }
           
           
           semaphore.wait()
           // =====================================================================================
           
           return (total_dic,total_all,count_all)
       }
       
        func get_group_by_accountJournal_html (list:[String:[String:Any]] ,total_all:Double,count_all:Double ) -> String
       {
           let rows :NSMutableString = NSMutableString()
           
           
           
           rows.append("<br /><table style=\"width: 98%;text-align: left; border: 4px solid black; padding: 20px\">")
            rows.append("<tr>  <td >   <h3 style=\"line-height: 0%\"> <u> "+"payment method".arabic("طريقة الدفع")+"  </u> </h3>  </td>  <td> % </td>   <td style = \"text-align: right;\"> \(SharedManager.shared.getCurrencyName()) </td>  </tr>")

            
           for (key,value) in list
           {
               let total:Double = value["total"] as? Double ?? 0
               let prec = (total / total_all ) * 100
               
               rows.append("<tr> <td>  \(   key ) </td>  <td> \(  prec.rounded_formated_str(max_len: 6) ) </td> <td style=\"text-align:right;\">   \(  total.rounded_formated_str(max_len: 12) ) </td> </tr>")
    
           }
      
    
           
//           rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day payment method</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
           
           rows.append("</table>")
           
           return String(rows)
       }
       
    
}
