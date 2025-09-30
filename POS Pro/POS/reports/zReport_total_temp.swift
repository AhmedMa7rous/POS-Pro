//
//  zReport.swift
//  pos
//
//  Created by khaled on 9/27/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit

class zReport_total_temp: ReportViewController   ,WKNavigationDelegate{
    
    var delegate : zReport_delegate?
    
    var indc: UIActivityIndicatorView?
    
    @IBOutlet var btnStartDate: UIButton!
    @IBOutlet var btnSelectShift: UIButton!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nav: ShadowView!
    
    
    var webView: WKWebView!
    var list_PaymentMethods:  [Any]!  = []
    var shift_id:Int?
    let option   = ordersListOpetions()
    
    var sessions_list:[pos_session_class]?
    
    var hideNav:Bool = false
    
    var total_bankStatment_summery:[String:Double]! = [:]
    var total_deliveryType_accountJournal_summery:[String:[String:Any]]! = [:]
    var total_deliveryType_summery:[String:[String:Any]]! = [:]
    
    var html:String = ""
    
    var start_date:String?
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        total_bankStatment_summery.removeAll()
        total_deliveryType_accountJournal_summery.removeAll()
        //        webView = nil
        list_PaymentMethods.removeAll()
        //        shift_id = nil
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
        
        list_PaymentMethods = []
        //        list_PaymentMethods.append(contentsOf: api.get_last_cash_result(keyCash: "get_account_Journals") )
        list_PaymentMethods.append(contentsOf: account_journal_class.getAll() )
        
        
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
    
    func getOtherPaymentStatment()-> [String:[String:Any]]
    {
        var total_bankStatment:[String:[String:Any]] = [:]
        
        for item in list_PaymentMethods
        {
            let obj = account_journal_class(fromDictionary: item as! [String : Any])
            if !list_ids_order.contains(String(format: "(%d)", obj.id))
            {
                var map:[String:Any] = [:]
                map["display_name"] = obj.display_name
                map["type"] = obj.type
                map["total"] = 0
                
                total_bankStatment[obj.display_name] = map
            }
            
            
        }
        
        
        return total_bankStatment
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
    
    func getTotal_order( sesstion_ids:String) -> (price_subtotal_incl:Double,price_subtotal:Double,amount_tax:Double)
    {
        
        
        var  price_subtotal_incl = 0.0
        var  price_subtotal = 0.0
        var  amount_tax = 0.0
        
        // =====================================================================================
        
        let sql = """
        SELECT  SUM(price_subtotal_incl) as price_subtotal_incl ,  SUM(price_subtotal) as price_subtotal ,  SUM(amount_tax) as amount_tax  FROM  pos_order_line
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
    
    func getTotalStatment(casher:res_users_class,  session:pos_session_class) -> [String:[String:Any]]
    {
        
        var total_bankStatment:[String:[String:Any]] = [:]
        
        
        
        // =====================================================================================
        //        let sql = """
        //        select payment_method.display_name ,payment_method.type  , ( sum( payment_method.tendered) + sum( payment_method.changes)) as total   from orders inner join payment_method on orders.id = payment_method.order_id
        //        where   orders.shift_id = \(shift.id) group by payment_method.display_name
        //        """
        
        let sql = """
        select account_journal.display_name ,account_journal.type  , \(MWConstants.selectTotalStatmentQry)
        from pos_order
        inner join pos_order_account_journal on pos_order.id = pos_order_account_journal.order_id
        inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
        
        where   pos_order.session_id_local = \(session.id)
        
        group by account_journal.display_name
        """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                let display_name = rows.string(forColumn: "display_name") ?? ""
                let type = rows.string(forColumn: "type") ?? ""
                let total = rows.double   (forColumn: "total")
                
                var map:[String:Any] = [:]
                map["display_name"] = display_name
                map["type"] = type
                map["total"] = total
                
                total_bankStatment[display_name] = map
                
                var total_summery = total_bankStatment_summery[display_name] ?? 0
                total_summery = total_summery  + total
                
                total_bankStatment_summery[display_name] = total_summery
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        
        
        return total_bankStatment
    }
    
    func getTotalOrderType_group_deliveryType_accountJournal(casher:res_users_class,  session:pos_session_class) -> [String:[String:Any]]
    {
        var total_orderType:[String:[String:Any]] = [:]
        
        //        total_orderType_summery.removeAll()
        
        // =====================================================================================
        //        let sql = """
        //        select  payment_method.display_name as payment_method , ( order_type.display_name || ' - ' || payment_method.display_name)  as new_display_name ,( sum( payment_method.tendered) + sum( payment_method.changes)) as total ,order_type.delivery_amount , count(*) as count from orders inner join payment_method on orders.id = payment_method.order_id inner join order_type on orders.id =  order_type.order_id
        //        where  orders.shift_id = \(shift.id)  group by  new_display_name
        //        """
        
        let sql = """
        
        select  account_journal.display_name as payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || account_journal.display_name)  as new_display_name ,
        \(MWConstants.selectTotalStatmentQry) ,pos_order.delivery_amount , count(*) as count
        from pos_order
        inner join pos_order_account_journal on pos_order.id = pos_order_account_journal.order_id
        inner join delivery_type on delivery_type.id =  pos_order.delivery_type_id
        inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
        
        where   pos_order.session_id_local = \(session.id)
        
        group by  new_display_name
        """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                
                let payment_method = rows.string(forColumn: "payment_method") ?? ""
                let delivery_type = rows.string(forColumn: "delivery_type") ?? ""
                let new_display_name = rows.string(forColumn: "new_display_name") ?? ""
                let total = rows.double (forColumn: "total")
                let count = rows.double (forColumn: "count")
                
                
                var temp:[String:Any] =    [:]
                temp["total"] = total
                temp["count"] = count
                temp["bankStatement"]  =  payment_method
                temp["delivery_type"]  =  delivery_type
                
                total_orderType[new_display_name] = temp
                
                
                
                var orderType_summery = total_deliveryType_accountJournal_summery[new_display_name] ??  [:]
                var total_summery = orderType_summery["total"] as? Double ?? 0
                var total_count = orderType_summery["count"] as? Double ?? 0
                
                total_summery = total_summery + total
                total_count = total_count + count
                
                
                
                orderType_summery["total"] = total_summery
                orderType_summery["count"] = total_count
                orderType_summery["bankStatement"] = payment_method
                
                
                
                total_deliveryType_accountJournal_summery[new_display_name] = orderType_summery
                
                
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        return total_orderType
    }
    
    func getTotalOrderType_group_deliveryType(casher:res_users_class,  session:pos_session_class) -> [String:[String:Any]]
    {
        var total_orderType:[String:[String:Any]] = [:]
        
 
        // =====================================================================================
        
  
        
        let sql = """
        
        select    payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || payment_method )  as new_display_name ,
        sum( due )    as total , total_orders.delivery_amount , count(*) as count
        from
        (
        SELECT count(*) as cnt ,(SUM(due) -  sum(rest)) as due ,order_id ,account_journal.display_name as payment_method ,pos_order.delivery_type_id,pos_order.delivery_amount as delivery_amount  from pos_order_account_journal
        inner join  pos_order   on pos_order.id = pos_order_account_journal.order_id
        inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
        where   pos_order.session_id_local =  \(session.id)
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
                let new_display_name = delivery_type  //rows.string(forColumn: "new_display_name") ?? ""
                let total = rows.double (forColumn: "total")
                let count = rows.double (forColumn: "count")
                
                
                var temp:[String:Any] =    [:]
                temp["total"] = total
                temp["count"] = count
                temp["bankStatement"]  =  payment_method
                temp["delivery_type"]  =  delivery_type
                
                total_orderType[new_display_name] = temp
                
                
                
                var orderType_summery = total_deliveryType_summery[new_display_name] ??  [:]
                var total_summery = orderType_summery["total"] as? Double ?? 0
                var total_count = orderType_summery["count"] as? Double ?? 0
                
                total_summery = total_summery + total
                total_count = total_count + count
                
                
                
                orderType_summery["total"] = total_summery
                orderType_summery["count"] = total_count
                orderType_summery["bankStatement"] = payment_method
                
                
                
                total_deliveryType_summery[new_display_name] = orderType_summery
                
                
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        return total_orderType
    }
    
    
 
    
    func printOrder_setHeader(html: String) -> String {
        let rows_header:NSMutableString = NSMutableString()
        
        let session = sessions_list![0]
        
        let dt = Date(strDate: session.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
        let startDate = dt.toString(dateFormat: "dd/MM/yyyy", UTC: false)
        
        //        let startDate =  ClassDate.getWithFormate(session.start_session, formate: ClassDate.satnderFromate(), returnFormate: "dd/MM/yyyy",use_UTC: true )
        
        //        rows_header.append(" <tr><td>Cashier</td><td>: </td><td> \(activeSessionLast.shift_current!.casher.name)</td></tr>")
        
        rows_header.append(" <tr><td>"+"POS Name".arabic("نقطة البيع")+"</td><td>: </td><td> \(session.pos().name!)</td></tr>")
        rows_header.append(" <tr><td>"+"Business day".arabic("اليوم")+"</td><td>: </td><td> \(startDate )</td></tr>")
        
        return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
    
    func printOrder_setTotal(html: String  ) -> String {
        let rows :NSMutableString = NSMutableString()
 
         let sesstion_ids = get_sessions_ids()
        
        
        let totalOrderTax = total_order_tax(sesstion_ids: sesstion_ids)
        rows.append( total_order_tax_html(price_subtotal_incl:  totalOrderTax.price_subtotal_incl, price_subtotal: totalOrderTax.price_subtotal, amount_tax:  totalOrderTax.amount_tax))

           let total = get_Statistics(  sesstion_ids: sesstion_ids)
        rows.append( total_statistics_html(total_void: total.total_void, total_return: total.total_return, total_discount: total.total_discount,total_product_return: total.total_product_return,total_insurances_return: total.total_insurance_return))

        
       return html.replacingOccurrences(of: "#rows_total", with: String(rows))
    }
    
    func printOrder_setTotal_old(html: String  ) -> String {
        
        var price_subtotal_incl:Double = 0
        var price_subtotal:Double = 0
        var amount_tax:Double = 0
        
        var total_void:Double = 0
        var total_return:Double = 0
        var total_discount:Double = 0
        var  total_product_return  = 0.0
        var  total_insurance_return  = 0.0
        
        let rows :NSMutableString = NSMutableString()
        
    
      
        var shifts_All :[[String : Any]] = []
     
        if shift_id != nil
        {
            let options = posSessionOptions()
            options.id = shift_id
            
            let arr:[[String:Any]] = pos_session_class.get_pos_sessions(options: options)
            if arr.count > 0
            {
                shifts_All.append( arr[0])
            }
            
        }
        else
        {
 
            let start_date = get_start_date()
            let end_date = get_end_date()
            
            let options = posSessionOptions()
            options.orderDesc = false
            options.between_start_session = [start_date,end_date]
            
            let arr:[[String:Any]] = pos_session_class.get_pos_sessions(options: options)
            
            
            shifts_All  = arr //pos_session_class.getAllShift(start_date: start_date,end_date: end_date)
     
             
        }
         
        for item in shifts_All
        {
 
            let obj = pos_session_class(fromDictionary: item )
            
            let dt = Date(strDate: obj.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
            let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
            
            var endDate = ""
            
            if obj.end_session  != ""
            {
                
                let dt = Date(strDate: obj.end_session!, formate: baseClass.date_fromate_satnder,UTC: true)
                endDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
                
                
            }
            
            if shift_id != nil
            {
                let option = ordersListOpetions()
                //            option.shift_id = obj.id
                option.sesssion_id = obj.id
                option.orderSyncType = .order
                option.void = false
                option.Closed = true
                option.write_pos_id = SharedManager.shared.posConfig().id
                
                let countOrders = pos_order_helper_class.getOrders_status_sorted_count(options: option)
                //            let countOrders = orderClass.getOrdersCount(session_id: obj.session_id, shift_id: obj.id)
                
                rows.append("<table style=\"width: 100%;text-align: left;border: 4px solid black;padding: 10px;margin-top: 20px;\">")
                rows.append("<tr><td style=\"width: 30%\">  <b>  Shift </b> </td> <td>  :  </td><td>  \( String( obj.id) )</b> </td></tr>")
                rows.append("<tr><td style=\"width: 30%\">  <b>  Employee </b> </td> <td>  :  </td><td>  \(obj.cashier().name ?? "" )</b> </td></tr>")
                rows.append("<tr><td >   <b> Opened at </b> </td> <td>  :  </td><td> <b> \(startDate )</b> </td></tr>")
                rows.append("<tr><td >   <b> Closed at </b> </td> <td>  :  </td><td><b>  \(endDate) </b></td></tr>")
                rows.append("<tr><td >   <b> Orders # </b> </td> <td>  :  </td><td><b>  \(countOrders) </b></td></tr>")
                
                rows.append("</table>")
                
            }
            
            
           _ = getTotalOrderType_group_deliveryType_accountJournal(casher: obj.cashier(),  session: obj)
 
//            let payment = Payment_html(obj: obj,cash: 0)
//            let totalOrderTax = total_order_tax(obj: obj)
//            let totalStatistics = total_statistics(obj: obj)
            
//            price_subtotal_incl += totalOrderTax.price_subtotal_incl
//            price_subtotal += totalOrderTax.price_subtotal
//            amount_tax += totalOrderTax.amount_tax
                  
//            total_void += totalStatistics.total_void
//            total_return += totalStatistics.total_return
//            total_discount += totalStatistics.total_discount
            
            
            if shift_id != nil
            {
//                rows.append(payment.html)
//                rows.append(totalOrderTax.html )
//                rows.append( totalStatistics.html )
            }
            
            
        }
        
        if shift_id == nil
        {
    
            
            rows.append( total_order_tax_html(price_subtotal_incl:  price_subtotal_incl, price_subtotal: price_subtotal, amount_tax:  amount_tax))
            rows.append( total_statistics_html(total_void:  total_void, total_return: total_return, total_discount:  total_discount,total_product_return: total_product_return,total_insurances_return: total_insurance_return))
            
          
            
        }
        
        rows.append( total_Payment_html() )
                      rows.append( total_deliveryType_accountJournal_html() )
        
        return html.replacingOccurrences(of: "#rows_total", with: String(rows))
    }
    
    func total_order_tax(sesstion_ids:String) -> (html:String,price_subtotal_incl:Double,price_subtotal:Double,amount_tax:Double)
    {
        SharedManager.shared.printLog("total_order_tax_html")
        
        let total = getTotal_order(  sesstion_ids: sesstion_ids)
        
        let html = total_order_tax_html(price_subtotal_incl:  total.price_subtotal_incl, price_subtotal: total.price_subtotal, amount_tax: total.amount_tax)
 
        return (html,total.price_subtotal_incl,total.price_subtotal,total.amount_tax)
    }
    
    func total_order_tax_html(price_subtotal_incl:Double,price_subtotal:Double,amount_tax:Double) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        
        rows.append("<br /><table style=\"width: 100%;text-align: left; border: 4px solid black; padding: 20px\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> End of day order summary </u> </h3>  </td>    </tr>")
        
        rows.append("<tr> <td> Total with tax  </td>  <td> </td> <td style=\"text-align:right;\">   \(   price_subtotal_incl.rounded_formated_str(max_len: 12) ) </td> </tr>")
        rows.append("<tr> <td> Total w\\o Tax  </td>  <td> </td> <td style=\"text-align:right;\">   \(   price_subtotal.rounded_formated_str(max_len: 12) ) </td> </tr>")
        rows.append("<tr> <td> Tax </td>  <td> </td> <td style=\"text-align:right;\">   \(  amount_tax.rounded_formated_str(max_len: 12) ) </td> </tr>")
        
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day order summary</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        rows.append("</table>")
        
        return String(rows)
    }
    
    func total_statistics(sesstion_ids:String) -> (html:String,total_void:Double,total_return:Double,total_discount:Double,total_product_return:Double,total_insurances_return:Double)
    {
        SharedManager.shared.printLog("total_statistics_html")
        
        let total = get_Statistics(  sesstion_ids: sesstion_ids)
        let html = total_statistics_html(total_void: total.total_void, total_return: total.total_return, total_discount: total.total_discount,total_product_return: total.total_product_return,total_insurances_return: total.total_insurance_return)
         
        return  (html,total.total_void,total.total_return,total.total_discount,total.total_product_return,total.total_insurance_return)
    }
    
    func total_statistics_html (total_void:Double,total_return:Double,total_discount:Double,total_product_return:Double,total_insurances_return:Double) -> String
    {
        let rows :NSMutableString = NSMutableString()
        
        
        rows.append("<br /><table style=\"width: 100%;text-align: left; border: 4px solid black; padding: 20px\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> End of day  summary </u> </h3>  </td>    </tr>")
        
        rows.append("<tr> <td> Void order </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_void.rounded_formated_str(max_len: 12) ) </td> </tr>")
//        rows.append("<tr> <td> Return order_old  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_return.rounded_formated_str(max_len: 12) ) </td> </tr>")
        rows.append("<tr> <td> \(MWConstants.return_products_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_product_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        
        rows.append("<tr> <td> \(MWConstants.return_insurance_title)  </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_insurances_return.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> Discount </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_discount.rounded_formated_str(max_len: 12) ) </td> </tr>")
        
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day  summary</u> </h5>  </td>  <td>   </td> <td  >    </td> </tr>")
        
        rows.append("</table>")
        
        return String(rows)
    }
    
    
    func total_Payment_html() -> String
    {
        SharedManager.shared.printLog("total_Payment_html")
        
        let sortedKeys = total_bankStatment_summery.sorted {$0.key < $1.key}
        let rows :NSMutableString = NSMutableString()
        
        var all_Payment = 0.0
        var currect_cash = 0.0
        
        
        rows.append("<br /><table style=\"width: 100%;text-align: left; border: 4px solid black; padding: 20px\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> End of day Payment summary </u> </h3>  </td>    </tr>")
        
        for (name, total) in sortedKeys {
            if name == "cash"
            {
                currect_cash = currect_cash + total
                
            }
            else
            {
                all_Payment =  all_Payment + total
                
                //                header .addLine(title: name, val:String(format: "%@", total.toIntString()), alignMode: .titleLeft_valRight)
                rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:right;\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
            }
        }
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day Payment summary</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        
        rows.append("</table>")
        return String(rows)
    }
    
    func total_deliveryType_accountJournal_html() -> String
    {
        SharedManager.shared.printLog("total_orderType_html")
        
        
        
        let sortedKeys = total_deliveryType_accountJournal_summery.sorted {$0.key < $1.key}
        let rows :NSMutableString = NSMutableString()
        
        var all_Payment = 0.0
        
        
        
        rows.append("<br /><table style=\"width: 100%;text-align: left; border: 4px solid black; padding: 20px\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> End of day Order Type summary </u> </h3>  </td>    </tr>")

        
        
        
        for (name, value) in sortedKeys {
            
            let total = value["total"] as? Double ?? 0
            let count = value["count"] as? Double ?? 0
            //            let bankStatement = value["bankStatement"] as? String ?? ""
            
            all_Payment =  all_Payment + total
            
            rows.append("<tr> <td>  \(name)  </td>  <td>\(count.toIntString() )</td> <td style=\"text-align:right;\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
        }
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>End of day  Order Type summary</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")

//        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> ملخص انواع الطلب الختامي </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")


        
        
        rows.append("</table>")
        return String(rows)
    }
    
    
    
    
    func Payment_html(obj:pos_session_class ,  cash:Double ) -> (html:String , cashTotal:Double) {
        SharedManager.shared.printLog("Payment_html")
        let rows :NSMutableString = NSMutableString()
        
        var currect_cash = cash
        var all_Payment = 0.0
        
        //        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> Payment </u> </h3>  </td>    </tr>")
        
        let total_bankStatment = getTotalStatment(casher: obj.cashier(),  session: obj)
        let other_bankStatment = getOtherPaymentStatment()
        
        //        let temp = NSMutableDictionary(dictionary: other_bankStatment)
        //        temp.addEntries(from: total_bankStatment)
        //        let all_bankStatment: [String:[String:Any]] = temp as? [String : [String : Any]] ?? [:]
        
        var all_bankStatment: [String:[String:Any]] = [:]
        all_bankStatment.merge(with: other_bankStatment)
        all_bankStatment.merge(with: total_bankStatment)
        
        
        //        var keys = total_bankStatment.keys
        let sortedKeys = all_bankStatment.sorted {$0.key < $1.key}
        
        for (name, map) in sortedKeys {
            //           let display_name = map["display_name"]
            let type =  map["type"] as? String ?? ""
            let total =  map["total"] as? Double ?? 0
            
            if type == "cash"
            {
                currect_cash = currect_cash + total
                
            }
            else
            {
                all_Payment =  all_Payment + total
                
                
                //                header .addLine(title: name, val:String(format: "%@", total.toIntString()), alignMode: .titleLeft_valRight)
                
            }
            
            //            rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:right;\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
        }
        
        let total_payment = all_Payment + currect_cash
        
        //        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>Total Payment </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(total_payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        
        //        for (name, total) in other_bankStatment {
        //            //            header .addLine(title: name, val:String(format: "%@", total.toIntString()), alignMode: .titleLeft_valRight)
        //            rows.append("<tr> <td> \(name) </td>  <td>  : </td> <td>   \(String(format: "%@", total.toIntString())) </td> </tr>")
        //        }
        
        return (String(rows),currect_cash)
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
        
        total_bankStatment_summery.removeAll()
        total_deliveryType_accountJournal_summery.removeAll()
        total_deliveryType_summery.removeAll()
        
        sessions_list = getSessionForDay()
        if sessions_list?.count == 0
        {
            hideActivityIndicator()
            
            return ""
        }
        
    
        
        var html = baseClass.get_file_html(filename: "z_report",showCopyRight: true)
//        let pos = SharedManager.shared.posConfig()
        
        //html = html.replacingOccurrences(of: "#logo", with: pos.company!.logo )
//        html = html.replacingOccurrences(of: "#header", with: pos.receipt_header!)
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
            ids = "," + String( item.id)
        }
        ids.removeFirst()
        
        return ids
    }
    
    func doneSelect() {
        
        loadReport()
        //
        //        activeSessionLast = getSessionForDay()
        //
        //        if activeSessionLast == nil
        //        {
        //            webView.loadHTMLString("", baseURL: nil)
        //        }
        //        else{
        //
        //            loadReport()
        //        }
        
        
    }
}
