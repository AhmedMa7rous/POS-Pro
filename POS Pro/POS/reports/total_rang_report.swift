//
//  ProductsReportViewController.swift
//  pos
//
//  Created by Alhaytham Alfeel on 11/20/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit

class total_rang_report: ReportViewController  {
    
    
    @IBOutlet weak var container: UIView!
 
    
    @IBOutlet var btn_filtter: UIButton!

    var selected_dic:[String:Any] = [:]
    var option   = ordersListOpetions()

    
    var webView: WKWebView!
 
    
    
    @IBOutlet var btnSelectShift: UIButton!
    
    var indc: UIActivityIndicatorView?
    
     var dictionary = [Int:[pos_order_line_class]]()
    var total_discount = 0.0
    var total_delivery_amount = 0.0
    
    var showProduct:Bool = true
    var hide_discount:Bool = false
    var hide_net:Bool = false
    var hide_count_orders:Bool = false
    
 
//    let date_formate = "dd/MM/yyyy"
    let date_formate = "yyyy-MM-dd hh:mm a"
    
    var start_date:String = ""
    var end_date:String = ""
    var shift_name:String = "By Time"

    var   html:String = ""
    var sessions_list:[pos_session_class]?
    
    var custom_header:String?
    
    var show_discount_only:Bool = false
    
 
    
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
    
    @IBAction func btn_filter(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
       let  filter  = storyboard.instantiateViewController(withIdentifier: "filter_report") as! filter_report
        filter.modalPresentationStyle = .formSheet
        filter.selected_dic = selected_dic
        
        filter.didSelect = { [weak self] selected_option in
          
            self!.set_filter_title(selected_option)
            self!.loadReport()
        }
          
        
        parent_vc?.present(filter, animated: true, completion: nil)

        
    }
    
    func set_filter_title(_ dic:[String:Any])
    {
        self.selected_dic = dic
        self.option = dic["option"] as! ordersListOpetions
        shift_name = dic["shift_name"] as? String ?? ""
        start_date = dic["start_date"] as? String ?? ""
        end_date = dic["end_date"] as? String ?? ""

       
        
        let btn_title = shift_name + "          From:" + start_date  + "        To:" + end_date
        
        btn_filtter.setTitle(btn_title, for: .normal)

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
    
    func loadReport()
    {
        dictionary.removeAll()
        total_discount = 0
        total_delivery_amount = 0
        if !(self.shift_name).lowercased().contains("by time"){
            get_sessions()
        }else{

            self.option.betweenDate = get_create_between()
        }
        
//        let start_date =  get_start_date() //ClassDate.getWithFormate(txtDate.text, formate: date_formate, returnFormate: "yyyy-MM-dd",use_UTC: true) ?? ""
//        let end_date =  get_end_date() //ClassDate.getWithFormate(txtDate_to.text, formate: date_formate, returnFormate: "yyyy-MM-dd",use_UTC: true) ?? ""
//
//        option.between_start_session = []
//        option.between_start_session?.append(start_date)
//        option.between_start_session?.append(end_date)
//        option.sesssion_id = shift_id  ?? 0
//        option.parent_product = true
//        option.write_pos_id = SharedManager.shared.posConfig().id
        
        showActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            self.html = self.printOrder_html()
            SharedManager.shared.printLog( self.html )
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
//    func getLastBussinusDate()
//    {
//        //        var lastSession = posSessionClass.getLastActiveSession()
//        //        if lastSession == nil
//        //        {
//        //            lastSession = posSessionClass.getActiveSession()
//        //        }
//
//        var lastSession = pos_session_class.getActiveSession()
//        if lastSession == nil
//        {
//            lastSession = pos_session_class.getLastActiveSession()
//        }
//
//        if lastSession != nil
//        {
//            let lastDate = lastSession!.start_session
//
//            if lastDate != nil
//            {
//                //            let date =   ClassDate.convertTimeStampTodate( String(lastDate) , returnFormate: date_formate, timeZone: NSTimeZone.local)
//
//                let dt = Date(strDate: lastDate!, formate: baseClass.date_fromate_satnder,UTC: false)
//                start_date = dt.toString(dateFormat: date_formate, UTC: true)
//
//                //                start_date = ClassDate.getWithFormate(lastDate, formate: ClassDate.satnderFromate(), returnFormate: date_formate,use_UTC: true )
//                end_date = start_date
//
//
//
//                //                txtDate.formateDate = date_formate
//                //                txtDate.textDate = date
//                //                txtDate.text = date
//                //
//                //                txtDate_to.formateDate = date_formate
//                //                txtDate_to.textDate = date
//                //                txtDate_to.text = date
//
//            }
//            else
//            {
//                start_date = Date().toString(dateFormat: date_formate, UTC: false) //ClassDate.getNow(date_formate , timeZone: NSTimeZone.local )
//                end_date = start_date
//                //                txtDate.formateDate = date_formate
//                //                txtDate.textDate = day
//                //                txtDate.text = day
//                //
//                //                txtDate_to.formateDate = date_formate
//                //                txtDate_to.textDate = day
//                //                txtDate_to.text = day
//            }
//        }
//        else
//        {
//            start_date = Date().toString(dateFormat: date_formate, UTC: false) //ClassDate.getNow(date_formate , timeZone: NSTimeZone.local )
//            end_date = start_date
//
//            //            txtDate.formateDate = date_formate
//            //            txtDate.textDate = day
//            //            txtDate.text = day
//            //
//            //            txtDate_to.formateDate = date_formate
//            //            txtDate_to.textDate = day
//            //            txtDate_to.text = day
//        }
//
//
//        btnStartDate.setTitle(start_date, for: .normal)
//        btnEndDate.setTitle(end_date, for: .normal)
//
//    }
    
    @IBAction func btnPrint(_ sender: Any) {
        self.print()
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
    
    
    
    
    
//    func get_start_date() -> String
//    {
//        let date_str = start_date!
//        let checkDay = baseClass.get_date_local_to_search(DateOnly: date_str, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss")
//
//        return checkDay
//    }
//
//    func get_end_date() -> String
//    {
//        let date_str = end_date!
//
//        let endDaty_str = baseClass.get_date_local_to_search(DateOnly: date_str, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss",addHours: 24)
//
//        return endDaty_str
//    }
    
//    func getSessionForDay() -> [pos_session_class]
//    {
//        var lst_sessions:[pos_session_class] = []
//
//        let start_date = get_start_date()
//        let end_date = get_end_date()
//
//
//        let options = posSessionOptions()
//        options.between_start_session = [start_date,end_date]
//
//        lst_sessions = pos_session_class.get_pos_sessions(options: options)
//
//        lst_sessions =  lst_sessions.sorted(by: {$0.id < $1.id})
//
//
//
//        return lst_sessions
//
//    }
//
    func printOrder_html() -> String {
        
        
        
//        sessions_list = getSessionForDay()
//        if sessions_list?.count == 0
//        {
//            hideActivityIndicator()
//
//            return ""
//        }
        
        
        
        var html = baseClass.get_file_html(filename: "z_report",showCopyRight: true)
//        let pos = SharedManager.shared.posConfig()
        
        //html = html.replacingOccurrences(of: "#logo", with: pos.company!.logo )
        html = html.replacingOccurrences(of: "#title", with: custom_header ?? "")
//        html = html.replacingOccurrences(of: "#header", with: pos.receipt_header!)
        //html = html.replacingOccurrences(of: "#footer", with: pos.receipt_footer)
        html = html.replacingOccurrences(of: "#header", with: "")

        html = html.replacingOccurrences(of: "#font", with: app_font_name_printer + "-Regular")
        
        if LanguageManager.currentLang() == .ar
        {
            html = html.replacingOccurrences(of: "#DIR#", with: style_right)
            value_dirction_style = "left"

        }
        else
        {
            html = html.replacingOccurrences(of: "#header", with: "")

        }

        
        html = printOrder_setHeader(html: html)
        
        html = printOrder_setTotal(html: html )
        
        //                SharedManager.shared.printLog("%@", html)
        
        hideActivityIndicator()
        return html
    }
    
//    func doneSelect() {
//
//        let def = baseClass.compareTwoDate(start_date!, dt2_new: end_date!, formate: date_formate)
//        if def < 0
//        {
//            end_date = start_date
//            printer_message_class.show("invaled date", vc: self)
//        }
//        else
//        {
//
//            loadReport()
//        }
//
//
//    }
//
    func get_sessions()
    {
        sessions_list = []
        
        let options_session = posSessionOptions()

        options_session.between_start_session = option.between_start_session
        
        let arr_session: [pos_session_class] =    pos_session_class.get_pos_sessions(options: options_session)
      
        sessions_list?.append(contentsOf: arr_session)
    }
    func get_create_between() -> String
    {
        if (self.shift_name).lowercased().contains("by time"){
            
            let start_date =   baseClass.get_date_utc_to_search(DateOnly: self.start_date, format: date_formate ,returnFormate:  baseClass.date_formate_database_wt_secand)
            let end_date =   baseClass.get_date_utc_to_search(DateOnly: self.end_date, format: date_formate ,returnFormate:  baseClass.date_formate_database_wt_secand)
            
            return "'\(start_date)' And '\(end_date)'"
        }
        return ""

    }
    func get_sessions_ids() -> String
    {
//        if shift_id != nil
//        {
//            return String( shift_id!)
//        }
        var ids = ""
        if !(self.shift_name).lowercased().contains("by time"){
            if option.sesssion_id != 0 {
                ids = "\(option.sesssion_id)"
            }else{
                
                for item in sessions_list! {
                    ids =  ids + "," + String( item.id)
                }
                if (!ids.isEmpty){
                    ids.removeFirst()
                }
            }
        }
        
       
        

        return ids
    }
    
    func printOrder_setHeader(html: String) -> String {
        let rows_header:NSMutableString = NSMutableString()
        
        if self.shift_name.lowercased().contains("by time"){
            
            //        rows_header.append(" <tr><td colspan = '3'   align=\"center\" >   \(startDate )  to  \(end_date  )   </td></tr>")
            rows_header.append(" <tr><td colspan = '3'>  <hr />  </td></tr>")
            
            let posName = SharedManager.shared.posConfig().name ?? ""
            
            rows_header.append(" <tr><td>"+"POS Name".arabic("نقطة البيع")+"</td><td>: </td><td> \(posName)</td></tr>")
            //        rows_header.append(" <tr><td>TO Date</td><td>: </td><td> \(end_date ?? "" )</td></tr>")
            
            
            rows_header.append(" <tr><td>"+"Start Date".arabic("البداية")+"</td><td>: </td><td> \( start_date )</td></tr>")
            rows_header.append(" <tr><td>"+"End Date".arabic("النهاية")+"</td><td>: </td><td> \( end_date )</td></tr>")

        }else{
            if sessions_list?.count == 0
            {
                rows_header.append(" <tr><td colspan = '3'>  <hr />  </td></tr>")
                
                let posName = SharedManager.shared.posConfig().name ?? ""
                
                rows_header.append(" <tr><td>"+"POS Name".arabic("نقطة البيع")+"</td><td>: </td><td> \(posName)</td></tr>")
                //        rows_header.append(" <tr><td>TO Date</td><td>: </td><td> \(end_date ?? "" )</td></tr>")
                
                
                rows_header.append(" <tr><td>"+"Start Date".arabic("البداية")+"</td><td>: </td><td> \( start_date )</td></tr>")
                rows_header.append(" <tr><td>"+"End Date".arabic("النهاية")+"</td><td>: </td><td> \( end_date )</td></tr>")
                //return ""
            } else {
                
                let session = sessions_list![0]
                
                let dt = Date(strDate: session.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
                let startDate = dt.toString(dateFormat: "dd/MM/yyyy", UTC: false)
                
                //        let startDate =  ClassDate.getWithFormate(session.start_session, formate: ClassDate.satnderFromate(), returnFormate: "dd/MM/yyyy",use_UTC: true )
                
                //        rows_header.append(" <tr><td>Cashier</td><td>: </td><td> \(activeSessionLast.shift_current!.casher.name)</td></tr>")
                
                let first_session = sessions_list?.first
                let last_session = sessions_list?.last
                
                let start_date_session = Date(strDate: first_session!.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
                let last_date_session = Date(strDate: last_session!.end_session!, formate: baseClass.date_fromate_satnder,UTC: true)
                
                let start_date = selected_dic["start_date"] as? String ?? ""
                let end_date = selected_dic["end_date"] as? String ?? ""
                
                //        rows_header.append(" <tr><td colspan = '3'   align=\"center\" >   \(startDate )  to  \(end_date  )   </td></tr>")
                rows_header.append(" <tr><td colspan = '3'>  <hr />  </td></tr>")
                
                
                
                rows_header.append(" <tr><td>"+"POS Name".arabic("نقطة البيع")+"</td><td>: </td><td> \(session.pos().name!)</td></tr>")
                //        rows_header.append(" <tr><td>TO Date</td><td>: </td><td> \(end_date ?? "" )</td></tr>")
                
                
                rows_header.append(" <tr><td>"+"Start Date".arabic("البداية")+"</td><td>: </td><td> \( start_date_session.toString(dateFormat: "dd/MM/yyyy  hh:mm a", UTC: false) )</td></tr>")
                rows_header.append(" <tr><td>"+"End Date".arabic("النهاية")+"</td><td>: </td><td> \( last_date_session.toString(dateFormat: "dd/MM/yyyy hh:mm a", UTC: false) )</td></tr>")
            }
        }
        
        
//        if shift_id != nil
//        {
//            rows_header.append(" <tr><td>Shift</td><td>: </td><td> \(shift_id! )</td></tr>")
//
//        }
        
        
        
        return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
    
    func printOrder_setTotal(html: String  ) -> String {
        let rows :NSMutableString = NSMutableString()
        if !self.shift_name.lowercased().contains("by time"){
            if sessions_list?.count == 0 {
                rows.append("<h3>" + "No sessions or sales during this period.".arabic(".لاتوجد جلسات او مبيعات في تلك الفترة")+"</h3>")
                return html.replacingOccurrences(of: "#rows_total", with: String(rows))
            }
        }else{
            
        }
        let sesstion_ids = get_sessions_ids()
        let create_between = get_create_between()
        if show_discount_only == false
        {
        let totalOrderTax = getTotal_order(sesstion_ids: sesstion_ids,create_between: create_between)
        rows.append( total_order_tax_html(price_subtotal_incl:  totalOrderTax.price_subtotal_incl, price_subtotal: totalOrderTax.price_subtotal, amount_tax:  totalOrderTax.amount_tax))
        
        let total = get_Statistics(  sesstion_ids: sesstion_ids,create_between: create_between)
            rows.append( total_statistics_html(total_void: total.total_void, total_return: total.total_return, total_discount: total.total_discount,total_delete: total.total_delete,total_reject:total.total_rejected,total_wasted: total.total_wasted,total_product_return: total.total_product_return,total_insurances_return: total.total_insurance_return))
        
        let gbdc = get_group_by_deliveryType_accountJournal(  sesstion_ids: sesstion_ids,create_between: create_between)
        rows.append( get_group_by_deliveryType_accountJournal_html(list: gbdc.list, total_all: gbdc.total_all, count_all: gbdc.count_all))
        
        let gbaj = get_group_by_accountJournal(  sesstion_ids: sesstion_ids,create_between: create_between)
        rows.append( get_group_by_accountJournal_html(list: gbaj.list, total_all: gbaj.total_all, count_all: gbaj.count_all))
        
        let gbgeidea = get_group_by_geidea(  sesstion_ids: sesstion_ids,create_between: create_between)
        rows.append( get_group_by_geidea_html(list: gbgeidea.list, total_all: gbgeidea.total_all, count_all: gbgeidea.count_all))

        let gbd  = get_group_by_deliveryType(  sesstion_ids: sesstion_ids,create_between: create_between)
        rows.append( get_group_by_deliveryType_html(list: gbd.list, total_all: gbd.total_all, count_all: gbd.count_all))
        }
        
        let gbdic  = get_group_by_discount(  sesstion_ids: sesstion_ids,create_between: create_between)
        rows.append( get_group_by_discount_html(list: gbdic.list, total_all: gbdic.total_all, count_all: gbdic.count_all))
        
        
        return html.replacingOccurrences(of: "#rows_total", with: String(rows))
    }
    
    
    func getTotal_order( sesstion_ids:String,create_between:String,brandSQL:String = "",usersSQL:String = "") -> (price_subtotal_incl:Double,price_subtotal:Double,amount_tax:Double)
    {
        var posID = SharedManager.shared.posConfig().id
        var posWriteQuery = "pos_order.write_pos_id  = \(posID)"

        var sqlBrand = ""
        var sqlSession = ""
        var sqlCreateBetween = ""

        if !sesstion_ids.isEmpty{
            sqlSession = "pos_order.session_id_local in (\(sesstion_ids))"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        var  price_subtotal_incl = 0.0
        var  price_subtotal = 0.0
        var  amount_tax = 0.0
        
        // =====================================================================================
        let pos = SharedManager.shared.posConfig()
        
       /* let old_sql = """
        SELECT  SUM(price_subtotal_incl) as price_subtotal_incl ,  SUM(price_subtotal) as price_subtotal
        ,( SELECT  SUM(amount_tax)    FROM  pos_order  where  session_id_local in (\(sesstion_ids))  and pos_order .is_void  = 0 and pos_order.is_closed = 1 and order_sync_type = 0 and pos_order.write_pos_id  = \(pos.id)) as amount_tax
         FROM  pos_order_line
        inner join pos_order on  pos_order_line.order_id  = pos_order.id
        where   pos_order_line.is_void = 0 and pos_order.order_menu_status != 3 and pos_order.is_closed = 1 and order_sync_type =0  and session_id_local in (\(sesstion_ids)) and pos_order.write_pos_id  = \(pos.id)
        """*/
        /*
        let sql_base_line = """
SELECT
    SUM(price_subtotal_incl) as price_subtotal_incl ,
    SUM(price_subtotal) as price_subtotal ,
    (
   SELECT SUM(amount_tax) from pos_order where pos_order.id in (
   SELECT
       DISTINCT pos_order.id
   FROM
       pos_order, pos_order_account_journal poaj
   where
       poaj.order_id = pos_order.id
       and pos_order.session_id_local in (\(sesstion_ids)) \(brandSQL)
       and pos_order.is_void = 0
       and pos_order.is_closed = 1
       and order_sync_type = 0
   )
        ) as amount_tax
From
    (
    select
        price_subtotal_incl,
        price_subtotal
    from
        pos_order_line
    where
        pos_order_line.is_void = 0
        and pos_order_line.order_id in (
        SELECT
            pos_order.id as id_order
        FROM
            pos_order
        inner join pos_order_account_journal poaj on
            poaj.order_id = pos_order.id
        where
            pos_order.order_menu_status != 3
            and pos_order.is_closed = 1
            and order_sync_type = 0
            and session_id_local in (\(sesstion_ids)) \(brandSQL)
            and pos_order.is_void = 0
    )
         )
"""
        */
        let sql = """
 SELECT
     *,
     (price_subtotal_incl - amount_tax ) as price_subtotal
 from
     (
     SELECT
         Sum(amount_tax) as amount_tax ,
         Sum(amount_total) as price_subtotal_incl
     from
         pos_order
     where
         pos_order.id in (
         SELECT
             DISTINCT pos_order.id
         FROM
             pos_order,
             pos_order_account_journal poaj
         where
             poaj.order_id = pos_order.id
             and \(sqlSession) \(sqlCreateBetween) \(brandSQL) \(usersSQL) \(posWriteQuery)
                 and pos_order.is_void = 0
                 and pos_order.is_closed = 1
                 and order_sync_type = 0
    )
    )

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
    func total_order_tax_html(price_subtotal_incl:Double,price_subtotal:Double,amount_tax:Double,get_rows:Bool = false) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        if get_rows == false
        {
            rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")

        }
        
        rows.append("<tr>  <td colspan=\"3\">   <h4  style=\"line-height: 0%\"> <u> \("Sales summary".arabic("الاجمالي")) </u> </h4>  </td>    </tr>")
        rows.append("<tr> <td > \("Total w\\o Tax".arabic("المجموع بدون الضريبة "))   </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   price_subtotal.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> \("Tax".arabic("الضريبة"))  </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(  amount_tax.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> \("Total with tax".arabic(" المجموع بالضريبة"))   </td>  <td> </td> <td style=\"text-align:\(value_dirction_style);\">   \(   price_subtotal_incl.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        
        
//        if LanguageManager.currentLang() == .ar {
//            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\" > <u> الاجمالي </u> </h4>  </td>    </tr>")
//            rows.append("<tr> <td > المجموع بدون الضريبة  </td>  <td> </td> <td style=\"text-align:right;\">   \(   price_subtotal.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
//            rows.append("<tr> <td> الضريبة </td>  <td> </td> <td style=\"text-align:right;\">   \(  amount_tax.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
//            rows.append("<tr> <td> المجموع بالضريبة </td>  <td> </td> <td style=\"text-align:right;\">   \(   price_subtotal_incl.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
//        } else {
//        rows.append("<tr>  <td colspan=\"3\">   <h4  style=\"line-height: 0%\"> <u> Sales summary </u> </h4>  </td>    </tr>")
//        rows.append("<tr> <td > Total w\\o Tax  </td>  <td> </td> <td style=\"text-align:right;\">   \(   price_subtotal.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
//        rows.append("<tr> <td> Tax </td>  <td> </td> <td style=\"text-align:right;\">   \(  amount_tax.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
//        rows.append("<tr> <td> Total with tax  </td>  <td> </td> <td style=\"text-align:right;\">   \(   price_subtotal_incl.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
//        }
        
        //        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day order summary</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        if get_rows == false
        {
            rows.append("</table>")

        }
        
        return String(rows)
    }
    
    func getTotalProductsSql(for sesstion_ids:String,create_between:String,as result:String, with condation:String) -> String{
        var sqlSession = ""
        var sqlCreateBetween = ""

        if !sesstion_ids.isEmpty{
            sqlSession = "pos_order.session_id_local in (\(sesstion_ids))"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
        }
        
        let sql = """
           SELECT
               SUM(price_subtotal_incl) as \(result)
           from
               (
               SELECT
                   SUM(price_subtotal_incl) as price_subtotal_incl
               from
                   (
                   SELECT
                       pos_order_line.price_subtotal_incl
                   from
                       pos_order
                   inner join pos_order_line on
                       pos_order.id = pos_order_line.order_id
                   where
                    \(sqlCreateBetween)
                       \(sqlSession)
                      \(condation)
                       
                       )
                       
           )

        """
        
        return sql
    }
    
    func get_Statistics( sesstion_ids:String,create_between:String,brandSQL:String = "",usersSQL:String = "") -> (total_void:Double,total_return:Double,total_discount:Double,total_delete:Double,total_rejected:Double,total_wasted:Double,total_product_return:Double,total_insurance_return:Double)
    {
        var posID = SharedManager.shared.posConfig().id
        let posWriteQuery = "pos_order.write_pos_id  = \(posID)"
        var  total_delete = 0.0
        var  total_void = 0.0
        var  total_return = 0.0
        var  total_discount  = 0.0
        var total_rejected = 0.0
        var total_wasted = 0.0
        var  total_product_return  = 0.0
        var  total_insurance_return  = 0.0
        var sqlSession = ""
        var sqlCreateBetween = ""
        if !sesstion_ids.isEmpty{
            sqlSession = "pos_order.session_id_local in (\(sesstion_ids))"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
        }
        // =====================================================================================
        
//        let sql_total_void = "SELECT  sum(amount_total) as total_void  from pos_order  where session_id_local in (\(sesstion_ids)) and is_void  = 1 "
        let sql_total_void = getTotalProductsSql( for:sesstion_ids,
                                                  create_between:create_between,
                                                  as:"total_void",
                                                  with:"""
                                                        and pos_order_line.is_void = 1
                                                        and pos_order_line.void_status in (2)
                                                        and pos_order_line.discount_display_name = ""
                                                        and \(posWriteQuery) \(brandSQL) \(usersSQL)
                                                        """)
        let sql_total_delete = getTotalProductsSql( for:sesstion_ids,
                                                    create_between:create_between,
                                                  as:"total_delete",
                                                  with:"""
                                                        and pos_order_line.is_void = 1
                                                        and pos_order_line.void_status in (0,1)
                                                        and pos_order_line.discount_display_name = ""
                                                        and \(posWriteQuery) \(brandSQL) \(usersSQL)
                                                        """)
        let sql_total_return = getTotalProductsSql( for:sesstion_ids,
                                                    create_between:create_between,
                                                  as:"total_return",
                                                  with:"""
                                                        and amount_total < 0
                                                        and pos_order.is_closed  = 1
                                                        and \(posWriteQuery) \(brandSQL) \(usersSQL)
                                                        """)
        let sql_total_waste = getTotalProductsSql( for:sesstion_ids,
                                                   create_between:create_between,
                                                  as:"total_waste",
                                                  with:"""
                                                        and pos_order.order_sync_type = 1
                                                        and \(posWriteQuery) \(brandSQL) \(usersSQL)
                                                        """)
//        let sql_total_return = getTotalProductsSql( for:sesstion_ids,
//                                                  as:"total_return",
//                                                  with:"""
//                                                        and amount_total < 0
//                                                        and pos_order.is_closed  = 1
//                                                        """)
//
        /*
        let sql_total_void = """
        SELECT  sum(pos_order.amount_total) as total_void  from pos_order
        where pos_order.session_id_local in (\(sesstion_ids)) and pos_order.is_void  = 1
        and id in (
        SELECT DISTINCT order_id from pos_order_line
        inner join pos_order
        on pos_order.id = pos_order_line.order_id
        WHERE pos_multi_session_status   = 4  and pos_order.session_id_local in (\(sesstion_ids))
        )
         
        """
        */
        let sql_total_rejected = """
        SELECT  sum(pos_order.amount_total) as total_rejected  from pos_order
        where \(sqlSession) \(sqlCreateBetween) \(brandSQL) \(usersSQL) and pos_order.is_void  = 1
        and id in (
        SELECT DISTINCT order_id from pos_order_line
        inner join pos_order
        on pos_order.id = pos_order_line.order_id
        WHERE  pos_order.order_menu_status = 3  and pos_order.session_id_local in (\(sesstion_ids)) \(brandSQL) \(usersSQL) and \(posWriteQuery)
        )
         
        """
        /*
        let sql_total_delete = """
        SELECT  sum(pos_order.amount_total) as total_delete  from pos_order
        where pos_order.session_id_local in (\(sesstion_ids)) and pos_order.is_void  = 1
        and id in (
        SELECT DISTINCT order_id from pos_order_line
        inner join pos_order
        on pos_order.id = pos_order_line.order_id
        WHERE pos_multi_session_status  = 1  and pos_order.session_id_local in (\(sesstion_ids))
        )
         
        """
        */
        
        /*
        let sql_total_return = "SELECT  sum(amount_total) as total_return  from pos_order  where session_id_local  in (\(sesstion_ids)) and amount_total < 0 and pos_order.is_closed  = 1"
        */
        let sql_total_discount =  """
        SELECT sum (price_subtotal_incl) as total_discount  from (
        SELECT (pos_order_line.price_subtotal_incl)  from pos_order
        inner join pos_order_line
        on pos_order.id = pos_order_line.order_id
        where \(sqlSession) \(sqlCreateBetween) \(brandSQL) \(usersSQL) and pos_order_line.price_unit < 0 and pos_order_line.is_void  = 0 and pos_order.is_closed  = 1
        and \(posWriteQuery) )
        """
        
        
        
        let sql_total_product_return = "SELECT SUM(pos_order.amount_total) as total_product_return from pos_order where \(sqlSession) \(sqlCreateBetween) and pos_order.amount_total < 0 and pos_order.is_closed = 1 and \(posWriteQuery) and pos_order.parent_order_id not in ( SELECT pio.insurance_id from pos_insurance_order pio WHERE pio.insurance_id in ( SELECT pos_order.parent_order_id from pos_order where \(sqlSession) \(sqlCreateBetween) and pos_order.amount_total < 0 and pos_order.is_closed = 1 and \(posWriteQuery) ) )"
        let sql_total_insurance_return = "SELECT sum(total_insurance_return) as total_insurance_return from ( SELECT  sum(pos_order.amount_total) as total_insurance_return  from pos_order, pos_insurance_order  where pos_order.parent_order_id = pos_insurance_order.insurance_id and \(sqlSession) \(sqlCreateBetween) and pos_order.amount_total < 0 and pos_order.is_closed  = 1 and \(posWriteQuery) GROUP by pos_order.id )"
        total_void = database_class(connect: .database).get_row(sql: sql_total_void)?["total_void"] as? Double ?? 0
        total_delete = database_class(connect: .database).get_row(sql: sql_total_delete)?["total_delete"] as? Double ?? 0
        total_rejected = database_class(connect: .database).get_row(sql: sql_total_rejected)?["total_rejected"] as? Double ?? 0

        total_return = database_class(connect: .database).get_row(sql: sql_total_return)?["total_return"] as? Double ?? 0
        total_discount = database_class(connect: .database).get_row(sql: sql_total_discount)?["total_discount"] as? Double ?? 0
        total_wasted = database_class(connect: .database).get_row(sql: sql_total_waste)?["total_waste"] as? Double ?? 0
        total_product_return = database_class(connect: .database).get_row(sql: sql_total_product_return)?["total_product_return"] as? Double ?? 0
        total_insurance_return = database_class(connect: .database).get_row(sql: sql_total_insurance_return)?["total_insurance_return"] as? Double ?? 0

        return (total_void,total_return,total_discount,total_delete,total_rejected,total_wasted,total_product_return,total_insurance_return)
    }
    
    func total_statistics_html (total_void:Double,total_return:Double,total_discount:Double,get_rows:Bool = false,total_delete:Double,total_reject:Double,total_wasted:Double,total_product_return:Double,total_insurances_return:Double) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        if get_rows == false
        {
            rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")

        }
        
        
        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> ملخص اليوم </u> </h4>  </td>    </tr>")
            
            rows.append("<tr> <td> \(MWConstants.void_products_title) </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_void.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr ><td colspan=\"3\" style=\"font-size: 20px\">\(MWConstants.void_products_desc)</td></tr>")
            
            rows.append("<tr> <td> \(MWConstants.cancel_products_title) </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_delete.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr><td colspan=\"3\" style=\"font-size: 20px\">\(MWConstants.cancel_products_dec)</td></tr>")

//            rows.append("<tr> <td> المرتجعات_old  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr> <td> \(MWConstants.return_products_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_product_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> \(MWConstants.return_insurance_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_insurances_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr> <td> الطلبات المرفوضة  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_reject.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr> <td> الخصومات </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_discount.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
        } else {
        rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> Day summary </u> </h4>  </td>    </tr>")
        
            rows.append("<tr> <td> \(MWConstants.void_products_title) </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_void.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr ><td colspan=\"3\" style=\"font-size: 20px\">\(MWConstants.void_products_desc)</td></tr>")
            
            rows.append("<tr> <td> \(MWConstants.cancel_products_title) </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_delete.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            rows.append("<tr><td colspan=\"3\" style=\"font-size: 20px\">\(MWConstants.cancel_products_dec)</td></tr>")

//        rows.append("<tr> <td> Return products_old  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> \(MWConstants.return_products_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_product_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
            
            rows.append("<tr> <td> \(MWConstants.return_insurance_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_insurances_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        
        rows.append("<tr> <td> Rejected orders  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_reject.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> Discount </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_discount.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        }
        
        //        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day  summary</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        if get_rows == false
        {
            rows.append("</table>")

        }
        return String(rows)
    }
    
    
    func get_group_by_deliveryType_accountJournal(sesstion_ids:String,create_between:String) -> (list:[String:[String:Any]],total_all:Double,count_all:Double)
    {
        var posID = SharedManager.shared.posConfig().id
        var posWriteQuery = "pos_order.write_pos_id  = \(posID)"
        
        
        var total_dic:[String:[String:Any]]! = [:]
        
        var total_all = 0.0
        var count_all = 0.0
        var sqlSession = ""
        var sqlCreateBetween = ""
        if !sesstion_ids.isEmpty{
            sqlSession = "pos_order.session_id_local in (\(sesstion_ids))"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        
        let sql = """
        
        select  account_journal.display_name as payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || account_journal.display_name)  as new_display_name ,
        \(MWConstants.selectTotalStatmentQry) ,pos_order.delivery_amount , count(*) as count
        from pos_order
        inner join pos_order_account_journal on pos_order.id = pos_order_account_journal.order_id
        inner join delivery_type on delivery_type.id =  pos_order.delivery_type_id
        inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
        
        where   \(sqlSession) \(sqlCreateBetween) \(posWriteQuery)
        
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
        
        if is_order_type_enabled() == false
        {
            return ""
        }
        
        let rows :NSMutableString = NSMutableString()
        
        
        
        rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
        
        rows.append("<tr>  <td style = \"height:100px;\" colspan = '2'>   <b style=\"font-size:42px\" > <u> "+"Payment - order type summary".arabic("الدفع - ملخص نوع الدفع")+"  </u> </b>  </td>    <td style = \"text-align: \(value_dirction_style);width:25%;\" > \(SharedManager.shared.getCurrencyName()) </td>  </tr>")

        
        
        
        for (key,value) in list
        {
            let total:Double = value["total"] as? Double ?? 0
            let count:Double = value["count"] as? Double ?? 0

            let prec = (total / total_all ) * 100
            
            rows.append("<tr> <td style = \"width:50%;font-size:35px\"> \(count.toIntString()) &nbsp&nbsp  \(   key ) </td>  <td style = \"width:25%;font-size:35px\"> \(  prec.rounded_formated_str(max_len: 6) ) %</td> <td style=\"text-align:\(value_dirction_style);width:25%;font-size:35px\">   \(  total.rounded_formated_str(max_len: 12,always_show_fraction: false) ) </td> </tr>")
            
        }
        
        
        
        //        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day  Payment</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        rows.append("</table>")
        
        return String(rows)
    }
    
    
    func get_group_by_deliveryType (sesstion_ids:String,create_between:String) -> (list:[String:[String:Any]],total_all:Double,count_all:Double)
    {
        var posID = SharedManager.shared.posConfig().id
        var posWriteQuery = "pos_order.write_pos_id  = \(posID)"
        
        var total_dic:[String:[String:Any]]! = [:]
        
        var total_all = 0.0
        var count_all = 0.0
        var sqlSession = ""
        // \(sqlSession) \(sqlCreateBetween)
        var sqlCreateBetween = ""
        if !sesstion_ids.isEmpty{
            sqlSession = "pos_order.session_id_local in (\(sesstion_ids))"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        
        let sql = """
        select    payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || payment_method )  as new_display_name ,
        sum( due )    as total , total_orders.delivery_amount , count(*) as count
        from
        (
        SELECT count(*) as cnt ,(SUM(due) -  sum(rest)) as due ,order_id ,account_journal.display_name as payment_method ,pos_order.delivery_type_id,pos_order.delivery_amount as delivery_amount  from pos_order_account_journal
        inner join  pos_order   on pos_order.id = pos_order_account_journal.order_id
        inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
        where  \(sqlSession) \(sqlCreateBetween) \(posWriteQuery)
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
        if is_order_type_enabled() == false
        {
            return ""
        }
        
        let rows :NSMutableString = NSMutableString()
        
        
        
        rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
        
        rows.append("<tr>  <td style = \"width:50%;\">   <h4  style=\"line-height: 0%\"> <u>"+"Order type".arabic("نوع الطلب")+"  </u> </h4>  </td>  <td style = \"width:25%;\">  </td>   <td style = \"text-align: \(value_dirction_style);width:25%;\"> \(SharedManager.shared.getCurrencyName()) </td>  </tr>")
        
        for (key,value) in list
        {
            let total:Double = value["total"] as? Double ?? 0
            let count:Double = value["count"] as? Double ?? 0

            let prec = (total / total_all ) * 100
            
            rows.append("<tr> <td  style = \"width:50%;font-size:35px\"> \(count.toIntString()) &nbsp&nbsp \(   key ) </td>  <td  style = \"width:25%;font-size:35px\"> \(  prec.rounded_formated_str(max_len: 6) ) %</td> <td style=\"text-align:\(value_dirction_style);width:25%;font-size:35px\">   \(  total.rounded_formated_str(max_len: 12,always_show_fraction: false) ) </td> </tr>")
            
         }
        
        
        
        //            rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day    Order type</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        rows.append("</table>")
        
        return String(rows)
    }
    
    func get_group_by_accountJournal (sesstion_ids:String,create_between:String) -> (list:[String:[String:Any]],total_all:Double,count_all:Double)
    {
        var posID = SharedManager.shared.posConfig().id
        var posWriteQuery = "pos_order.write_pos_id  = \(posID)"
        
        var total_dic:[String:[String:Any]]! = [:]
        
        var total_all = 0.0
        var count_all = 0.0
        var sqlSession = ""
        // \(sqlSession) \(sqlCreateBetween)
        var sqlCreateBetween = ""
        if !sesstion_ids.isEmpty{
            sqlSession = "pos_order.session_id_local in (\(sesstion_ids))"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        
        let sql = """
        select    payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || payment_method )  as new_display_name ,
        sum( due )    as total , total_orders.delivery_amount , count(*) as count
        from
        (
        SELECT count(*) as cnt ,(SUM(due) -  sum(rest)) as due ,order_id ,account_journal.display_name as payment_method ,pos_order.delivery_type_id,pos_order.delivery_amount as delivery_amount  from pos_order_account_journal
        inner join  pos_order   on pos_order.id = pos_order_account_journal.order_id
        inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
        where   \(sqlSession) \(sqlCreateBetween) \(posWriteQuery)
        group by  payment_method ) as total_orders
        LEFT join delivery_type on delivery_type.id =   delivery_type_id
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
    
    func get_group_by_geidea (sesstion_ids:String,create_between:String) -> (list:[String:[String:Any]],total_all:Double,count_all:Double)
    {
        var posID = SharedManager.shared.posConfig().id
        var posWriteQuery = "pos_order.write_pos_id  = \(posID)"
        
        var total_dic:[String:[String:Any]]! = [:]
        
        var total_all = 0.0
        var count_all = 0.0
        var sqlSession = ""
        // \(sqlSession) \(sqlCreateBetween)
        var sqlCreateBetween = ""
        if !sesstion_ids.isEmpty{
            sqlSession = "pos_order.session_id_local in (\(sesstion_ids))"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        
        let sql = """
        select
                    payment_method ,
                    card_type as delivery_type ,
                    (card_scheme) as new_display_name ,
                    sum(due) as total ,
                    total_orders.delivery_amount ,
                    total_orders.cnt as count
                from
                    (
                    SELECT
                        count(*) as cnt ,
                        (SUM(due) - sum(rest)) as due ,
                        ingenico_order_class.card_scheme as payment_method ,
                        pos_order.delivery_amount as delivery_amount,
                        card_type,
                        card_scheme
                    from
                        ingenico_order_class
                    inner join pos_order on
                        pos_order.id = ingenico_order_class.order_id
                    inner join pos_order_account_journal on
                        ingenico_order_class.order_id = pos_order_account_journal.order_id
                     and ingenico_order_class.account_Journal_id = pos_order_account_journal.account_Journal_id
                    where
                        \(sqlSession) \(sqlCreateBetween) \(posWriteQuery)
                    group by
                        ingenico_order_class.card_scheme ) as total_orders
                group by
                    payment_method
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
        
        
        
        rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
        rows.append("<tr>  <td style = \"width:50%;\" colspan = '2'>   <h4    > <u> "+"payment method".arabic("طريقة الدفع")+"  </u> </h4>  </td>     <td style = \"text-align: \(value_dirction_style);width:25%;\"> \(SharedManager.shared.getCurrencyName()) </td>  </tr>")

        
        
        
        for (key,value) in list
        {
            let total:Double = value["total"] as? Double ?? 0
            let count:Double = value["count"] as? Double ?? 0

            let prec = (total / total_all ) * 100
            
            rows.append("<tr> <td style = \"width:50%;font-size:35px\"> \(count.toIntString()) &nbsp&nbsp \(   key ) </td>  <td style = \"width:25%;font-size:35px\"> \(  prec.rounded_formated_str(max_len: 6) ) %</td> <td style=\"text-align:\(value_dirction_style);width:25%;font-size:35px\">   \(  total.rounded_formated_str(max_len: 12,always_show_fraction: false) ) </td> </tr>")
            
        }
        
        
        
        //           rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day payment method</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        rows.append("</table>")
        
        return String(rows)
    }
    func get_group_by_geidea_html (list:[String:[String:Any]] ,total_all:Double,count_all:Double ) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        
        
        rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
        rows.append("<tr>  <td style = \"width:50%;\" colspan = '2'>   <h4    > <u> "+"Bank analysis".arabic("تفاصيل الحركات البنكيه")+"  </u> </h4>  </td>     <td style = \"text-align: \(value_dirction_style);width:25%;\"> \(SharedManager.shared.getCurrencyName()) </td>  </tr>")

        
        
        
        for (key,value) in list
        {
            let total:Double = value["total"] as? Double ?? 0
            let count:Double = value["count"] as? Double ?? 0

            let prec = (total / total_all ) * 100
            
            rows.append("<tr> <td style = \"width:50%;font-size:35px\"> \(count.toIntString()) &nbsp&nbsp \(   key ) </td>  <td style = \"width:25%;font-size:35px\"> \(  prec.rounded_formated_str(max_len: 6) ) %</td> <td style=\"text-align:\(value_dirction_style);width:25%;font-size:35px\">   \(  total.rounded_formated_str(max_len: 12,always_show_fraction: false) ) </td> </tr>")
            
        }
        
        
        
        //           rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day payment method</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        rows.append("</table>")
        
        return String(rows)
    }
    func get_group_by_discount (sesstion_ids:String,create_between:String) -> (list:[String:[String:Any]],total_all:Double,count_all:Double)
    {
        var posID = SharedManager.shared.posConfig().id
        var posWriteQuery = "pos_order.write_pos_id  = \(posID)"

        var total_dic:[String:[String:Any]]! = [:]
        
        var total_all = 0.0
        var count_all = 0.0
        var sqlSession = ""
        // \(sqlSession) \(sqlCreateBetween)
        var sqlCreateBetween = ""
        if !sesstion_ids.isEmpty{
            sqlSession = "pos_order.session_id_local in (\(sesstion_ids))"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
            posWriteQuery = "and pos_order.write_pos_id  = \(posID)"
        }
        
        let sql = """
        SELECT SUM(price_subtotal_incl) as total ,discount_type ,discount_display_name, count(*) as count FROM
        (
        SELECT  *  FROM  pos_order_line
        inner join pos_order on  pos_order_line.order_id  = pos_order.id
        where pos_order_line.discount  > 0 and  \(sqlSession) \(sqlCreateBetween) \(posWriteQuery) and pos_order.is_closed = 1 and pos_order_line.is_void = 0 and pos_order.is_void = 0) as ordes
        GROUP  by discount_display_name
        """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                
                let discount_type = rows.string(forColumn: "discount_type") ?? ""
                 let discount_display_name = rows.string(forColumn: "discount_display_name") ?? ""
                 let new_name  = discount_type + " (" + discount_display_name +  ")"
  
                let total = rows.double (forColumn: "total")
                let count = rows.double (forColumn: "count")
                
                total_all += total
                count_all += count
                
                
                
                var orderType_summery = total_dic[new_name] ??  [:]
                var total_summery = orderType_summery["total"] as? Double ?? 0
                var total_count = orderType_summery["count"] as? Double ?? 0
                
                total_summery = total_summery + total
                total_count = total_count + count
                
                
                
                orderType_summery["total"] = total_summery
                orderType_summery["count"] = total_count
 
                
                
                total_dic[new_name] = orderType_summery
                
                
                
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        return (total_dic,total_all,count_all)
    }
    
    func get_group_by_discount_html (list:[String:[String:Any]] ,total_all:Double,count_all:Double ) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        
        
        rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
        rows.append("<tr>  <td  style = \"width:50%;\">   <h4 style=\"line-height: 0%\" > <u> "+"Discount".arabic("الخصم")+"  </u> </h4>  </td>  <td  style = \"width:25%;\">   </td>   <td style = \"text-align: \(value_dirction_style);width:25%;\"> \(SharedManager.shared.getCurrencyName()) </td>  </tr>")
        
        
        for (key,value) in list
        {
            let total:Double = value["total"] as? Double ?? 0
            let count:Double = value["count"] as? Double ?? 0

            let prec = (total / total_all ) * 100
            
            rows.append("<tr> <td  style = \"width:50%;font-size:35px\">\(count.toIntString()) &nbsp&nbsp \(   key ) </td>  <td  style = \"width:25%;font-size:35px\"> \(  prec.rounded_formated_str(max_len: 6) ) %</td> <td style=\"text-align:\(value_dirction_style);width:25%;font-size:35px\">   \(  total.rounded_formated_str(max_len: 12,always_show_fraction: false) ) </td> </tr>")
            
        }
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> "+"Total".arabic("المجموع")+" </u> </h5>  </td>  <td>   </td> <td  style=\"text-align:\(value_dirction_style);\">  \(total_all.rounded_formated_str(max_len: 12,always_show_fraction: false))   </td> </tr>")
        
        
        
        rows.append("</table>")
        
        return String(rows)
    }
    
}
