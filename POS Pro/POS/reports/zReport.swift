//
//  zReport.swift
//  pos
//
//  Created by khaled on 9/27/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit

protocol zReport_delegate {
    func zReport_didClosed()
}
class zReport: ReportViewController   ,WKNavigationDelegate{
    
    var delegate : zReport_delegate?
    
    var indc: UIActivityIndicatorView?
    
    @IBOutlet var btnStartDate: UIButton!
    @IBOutlet var btnSelectShift: UIButton!
    @IBOutlet var btnSelectUsers: UIButton!
    @IBOutlet weak var selectUsersStack: UIStackView!

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nav: ShadowView!
    
    @IBOutlet weak var selectBrandStack: UIStackView!
    
    @IBOutlet weak var selectBrandBtn: KButton!
    var webView: WKWebView!
    var list_PaymentMethods:  [Any]!  = []
    var shift_id:Int?
    let option   = ordersListOpetions()
    
    var sessions_list:[pos_session_class]?
    
    var hideNav:Bool = false
    var custom_header:String?
    var forLockDriver:Bool = false
    var forUsersReport:Bool = false


    var total_bankStatment_summery:[String:Double]! = [:]
    var total_deliveryType_accountJournal_summery:[String:[String:Any]]! = [:]
    var total_deliveryType_summery:[String:[String:Any]]! = [:]

    var html:String = ""
    
    var time: String?
    var start_date:String?
    var selectedBrands:[res_brand_class]?
    var selectedUsers:[res_users_class]?
    var dataResUserList:[res_users_class]?
    var is_report_wifi:Bool?

    private lazy var formatter: DateFormatter = {
        let f = DateFormatter()
        f.timeZone  = TimeZone(secondsFromGMT: 0)!
        f.dateFormat = "hh:mm a"      // "HH:mm" for 24-hour
        return f
    }()
    
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
        
//        self.shift_id = nil
        if self.shift_id == nil
        {
            self.btnSelectShift.setTitle("Summary", for: .normal)
            self.btnSelectShift.tag = 1
        }
        else
        {
             self.btnSelectShift.tag = 0
        }
        
  
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.forUsersReport{
            DispatchQueue.global(qos: .background).async {
                self.dataResUserList = res_users_class.getAll().map({res_users_class(fromDictionary: $0)})
            }
        }
        self.selectUsersStack.isHidden = !self.forUsersReport

        nav.isHidden = hideNav
        
        
        
        getLastBussinusDate()
        
        list_PaymentMethods = []
//        list_PaymentMethods.append(contentsOf: api.get_last_cash_result(keyCash: "get_account_Journals") )
        list_PaymentMethods.append(contentsOf: account_journal_class.getAll() )
        
        if SharedManager.shared.posConfig().cloud_kitchen.count <= 0 {
            self.selectBrandStack.isHidden = true
        }
        self.setTitleBrandBtn()
        self.setTitleUsersBtn()
        self.loadReport()

        
        
    }
    func get_create_between() -> String
    {   
        let date_formate = "yyyy-MM-dd hh:mm a"

        if (self.btnSelectShift.tag == -1){
            let dateTime = (self.start_date ?? "") + " " + (self.time ?? "00:00 am")
            let start_date =   baseClass.get_date_utc_to_search(DateOnly: dateTime, format: date_formate ,returnFormate:  baseClass.date_formate_database_wt_secand)
            let end_date =   baseClass.get_date_utc_to_search(DateOnly: dateTime, format: date_formate ,returnFormate:  baseClass.date_formate_database_wt_secand)
            
            return "'\(start_date)' And '\(end_date)'"
        }
        return ""

    }
    func setTitleUsersBtn(){
        if let selectedUsers =  self.selectedUsers,selectedUsers.count > 0{
            if let firstUser = selectedUsers.first{
                DispatchQueue.main.async {
                    self.btnSelectUsers.setTitle(firstUser.name ?? "user", for: UIControl.State.normal)
                }
            }
        }else{
            DispatchQueue.main.async {
                self.btnSelectUsers.setTitle("All Usres".arabic("كل المستخدمين "), for: UIControl.State.normal)
            }
        }
    }
    func setTitleBrandBtn(){
        if let selectedBrands =  self.selectedBrands,selectedBrands.count > 0{
            if let firstBrand = selectedBrands.first{
                DispatchQueue.main.async {
                    self.selectBrandBtn.setTitle(firstBrand.display_name ?? "brand", for: UIControl.State.normal)
                }
            }
        }else{
            DispatchQueue.main.async {
                self.selectBrandBtn.setTitle("All brand".arabic("كل العلامات التجارية"), for: UIControl.State.normal)
            }
        }
    }
    @IBAction func tapOnSelectUsersBtn(_ sender: KButton) {
        let selectUservc:SelectResUserVC = SelectResUserVC.createModule(sender,selectDataList:  self.selectedUsers,dataList:dataResUserList ?? [])
            selectUservc.completionBlock = { selectDataList in
                if  selectDataList.count > 0{
                    if (selectDataList.first?.id ?? 0) == -1{
                        self.selectedUsers = nil
                    }else{
                        self.selectedUsers = selectDataList
                    }
                    self.loadReport()
                    self.setTitleUsersBtn()
                }
            }
            self.present(selectUservc, animated: true, completion: nil)
    }
    @IBAction func tapOnSelectBrandBtn(_ sender: KButton) {
        if let selectBrandvc = SelectBrandVC.createReportModule(sender,selectDataList:  self.selectedBrands ) as? SelectBrandVC {
            selectBrandvc.completionBlock = { selectDataList in
                if  selectDataList.count > 0{
                    if (selectDataList.first?.id ?? 0) == -1{
                        self.selectedBrands = nil
                    }else{
                        self.selectedBrands = selectDataList
                    }
                    self.loadReport()
                    self.setTitleBrandBtn()
                }
            }
            self.present(selectBrandvc, animated: true, completion: nil)
        }
    }
   
    
    @IBAction func btnSelectShift(_ sender: Any) {
        
        let list = options_listVC()
        list.modalPresentationStyle = .formSheet
        let allOption = [options_listVC.title_prefex:"All"]
       let noneOption = [options_listVC.title_prefex:"By Time"]
       list.list_items.append(noneOption)
        list.list_items.append(allOption)
        
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
       
            let title = String( shift.id ) + " - " + startDate
            dic[options_listVC.title_prefex] = title
            
            list.list_items.append(dic)

        }
        
        list.list_items.append([options_listVC.title_prefex:"Summary"])


        list.didSelect = { [weak self] data in
            let dic = data
            let title = dic[options_listVC.title_prefex] as? String ?? ""
            if title == "All"
            {
                self!.shift_id = nil
                self!.btnSelectShift.setTitle("All", for: .normal)
                self!.btnSelectShift.tag = 0

            }
            else if title == "Summary"
            {
                self!.shift_id = nil
                self!.btnSelectShift.setTitle("Summary", for: .normal)
                self!.btnSelectShift.tag = 1
            }
            else if title == "By Time"
            {
                self!.shift_id = nil
                self!.btnSelectShift.setTitle("By Time", for: .normal)
                self!.btnSelectShift.tag = -1
            }
            else
            {
                self!.shift_id = dic["id"] as? Int
                self!.btnSelectShift.setTitle(title, for: .normal)
                self!.btnSelectShift.tag = 2

            }
            self!.loadReport()
        }
          
        
        list.clear = {
            self.shift_id = nil
            self.btnSelectShift.setTitle("By Time", for: .normal)
            self.btnSelectShift.tag = -1

                         list.dismiss(animated: true, completion: nil)

                    }

        
        parent_vc?.present(list, animated: true, completion: nil)

    }
    
   
    
    @IBAction func btnStartDate(_ sender: Any) {
        showCalendarTimePicker()
//        let calendar = calendarVC()
//        
//        if self.start_date != nil
//        {
//            calendar.startDate = Date(strDate: self.start_date!, formate: "yyyy-MM-dd", UTC: true)
//        }
//        
//        calendar.modalPresentationStyle = .formSheet
//        calendar.didSelectDay = { [weak self] date in
//            
//            
//            self?.start_date =  date.toString(dateFormat:"yyyy-MM-dd")
//            self!.setbtnStartDateTitle(date:  date.toString(dateFormat:baseClass.date_fromate_satnder))
//            
//            self!.shift_id = nil
//            self!.btnSelectShift.setTitle("All", for: .normal)
//            
//            
//            self?.doneSelect()
//            
//            calendar.dismiss(animated: true) {
//                self.showCalendarTimePicker()
//            }
//        }
//        
//        calendar.clearDay = {
//            
//            calendar.dismiss(animated: true, completion: nil)
//            
//        }
//        
//        parent_vc?.present(calendar, animated: true, completion: nil)
    }
    
    private func showCalendarTimePicker() {
        let pickerVC          = DateTimePickerVC()
        let dateTimeString = (start_date ?? "") + " " + (time ?? "00:00 am")
        let dateTime = Date().toDate( dateTimeString , format:  baseClass.date_fromate_satnder_12h)
        pickerVC.initialDate  = dateTime
        pickerVC.onPicked     = { [weak self] date, time in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.time = time
                self.start_date = date
                self.btnStartDate.setTitle(date + " " + time, for: .normal)

//                self.shift_id = nil
//                self.btnSelectShift.setTitle("by time", for: .normal)
//                self.btnSelectShift.tag = -1
//                self.setbtnStartDateTitle(date: date)
                self.doneSelect()
            }
        }

        let cardSize = CGSize(width: 380, height: 420)
        pickerVC.modalPresentationStyle = .formSheet
        pickerVC.preferredContentSize   = cardSize
        present(pickerVC, animated: true)
    }
    
    private func presentUTCTimePicker(seed date: Date) {

        let pickerVC = UTCTimePickerVC()
        pickerVC.initialDate = date

        pickerVC.onTimePicked = { [weak self] utcDate in
            guard let self = self else { return }
            self.time = self.formatter.string(from: utcDate)
            Swift.print("Selected Time: \(self.time)")
        }
        pickerVC.preferredContentSize = CGSize(width: 320, height: 280)
        pickerVC.modalPresentationStyle = .formSheet
        present(pickerVC, animated: true)
    }
    
    func setbtnStartDateTitle(date:String?)
    {
        var new_date = date
        if new_date == nil
        {
               new_date = Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: false)
        }
//       let dt =   ClassDate.getWithFormate(start_date, formate: "yyyy-MM-dd", returnFormate:  "dd/MM/yyyy" ,use_UTC: true )
        let dt = Date(strDate: new_date!, formate:  baseClass.date_fromate_satnder_date,UTC: true)
        let checkDay = dt.toString(dateFormat: "dd/MM/yyyy" , UTC: false)
        
        
        self.btnStartDate.setTitle(checkDay, for: .normal)

    }
    
    func loadReport()
    {
        showActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
          
            DispatchQueue.main.async {
                
                  self.html = self.printOrder_html()
                SharedManager.shared.printLog(self.html)
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
    
    var is_printing = false

    @objc public func print()
    {
        if is_printing == false
        {
              is_printing = true
        }
    
        self.show_printer_dialog()

        webView?.fullLengthScreenshot { (image) in
             if image != nil
            {
                if (self.custom_header == "End session" || self.custom_header == "نهايه الجلسه"){
                    let _ = FileMangerHelper.shared.saveLastSessionImage(image: image!)
                }
                let id = self.shift_id
                let start_date = self.get_start_date()
                let end_date = self.get_end_date()
                
                runner_print_class.runPrinterReceipt(  logoData: image , openDeawer: false)
                
                
            }
            
            self.is_printing = false
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
        if let nav = self.navigationController{
            nav.popViewController(animated: true)

        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
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
    func getUsersSql()->String{
        var sqlBrand = ""
        if !(self.is_report_wifi ?? false){
            if let selectedUsers = self.selectedUsers {
                let stringIds = "(\(selectedUsers.map({"\($0.id)"}).joined(separator: ", ")))"
                sqlBrand = "and pos_order.write_user_id in \(stringIds)"
            }
        }
        return sqlBrand
    }
    func getBrandSql()->String{
        var sqlBrand = ""
        if let selectedBrands = self.selectedBrands{
            let stringIds = "(\(selectedBrands.map({"\($0.id)"}).joined(separator: ", ")))"
            sqlBrand = "and pos_order.brand_id in \(stringIds)"
        }
        return sqlBrand
    }
    func getTotalStatment(casher:res_users_class?,  session:pos_session_class?, create_between:String) -> [String:[String:Any]]
    {
        
        var total_bankStatment:[String:[String:Any]] = [:]
        
        var sqlSession = ""
        // \(sqlSession) \(sqlCreateBetween)
        var sqlCreateBetween = ""
        if let session = session{
            sqlSession = "pos_order.session_id_local = \(session.id)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
        }
        
        // =====================================================================================
//        let sql = """
//        select payment_method.display_name ,payment_method.type  , ( sum( payment_method.tendered) + sum( payment_method.changes)) as total   from orders inner join payment_method on orders.id = payment_method.order_id
//        where   orders.shift_id = \(shift.id) group by payment_method.display_name
//        """
        
        let sql = """
                select account_journal.display_name ,account_journal.type  , \(MWConstants.selectTotalStatmentQry) , count(*) as count
                from pos_order
                inner join pos_order_account_journal on pos_order.id = pos_order_account_journal.order_id
                inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
        
                where   \(sqlSession) \(sqlCreateBetween) \(self.getBrandSql()) \(self.getUsersSql())

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
                let count = rows.double   (forColumn: "count")

                var map:[String:Any] = [:]
                map["display_name"] = display_name
                map["type"] = type
                map["total"] = total
                map["count"] = count

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
    func getInsuranceTotalStatment(casher:res_users_class?,  session:pos_session_class?, create_between:String) -> [String:[String:Any]]
    {
        
        var total_bankStatment:[String:[String:Any]] = [:]
        var sqlSession = ""
        // \(sqlSession) \(sqlCreateBetween)
        var sqlCreateBetween = ""
        if let session = session{
            sqlSession = "pos_order.session_id_local = \(session.id)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
        }
        
        
        // =====================================================================================
//        let sql = """
//        select payment_method.display_name ,payment_method.type  , ( sum( payment_method.tendered) + sum( payment_method.changes)) as total   from orders inner join payment_method on orders.id = payment_method.order_id
//        where   orders.shift_id = \(shift.id) group by payment_method.display_name
//        """
        
        let sql = """
        select  'Insurance - التأمين' as display_name,
        ( sum(pos_order_account_journal.due) - sum(pos_order_account_journal.rest) ) as total ,
            count(*) as count
        from
            pos_order
        inner join pos_order_account_journal on
            pos_order.id = pos_order_account_journal.order_id
        inner join pos_insurance_order pio on
            pio.insurance_id  = pos_order.id
        where
                    \(sqlSession) \(sqlCreateBetween) \(self.getBrandSql()) \(self.getUsersSql())
        GROUP BY 'Insurance - التأمين'
        
        """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                let display_name = rows.string(forColumn: "display_name") ?? ""
                let type = rows.string(forColumn: "type") ?? ""
                let total = rows.double   (forColumn: "total")
                let count = rows.double   (forColumn: "count")

                var map:[String:Any] = [:]
                map["display_name"] = display_name
                map["type"] = type
                map["total"] = total
                map["count"] = count

                total_bankStatment[display_name] = map
                
                var total_summery = total_bankStatment_summery[display_name] ?? 0
                total_summery = total_summery  + total
                
                //total_bankStatment_summery[display_name] = total_summery
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        
        
        return total_bankStatment
    }
    func getDriverLockStatment(casher:res_users_class?,  session:pos_session_class?, create_between:String) -> [String:[String:Any]]
    {
        
        var total_bankStatment:[String:[String:Any]] = [:]
        var sqlSession = ""
        // \(sqlSession) \(sqlCreateBetween)
        var sqlCreateBetween = ""
        if let session = session{
            sqlSession = "pos_order.session_id_local = \(session.id)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
        }
        
        
        
        // =====================================================================================
//        let sql = """
//        select payment_method.display_name ,payment_method.type  , ( sum( payment_method.tendered) + sum( payment_method.changes)) as total   from orders inner join payment_method on orders.id = payment_method.order_id
//        where   orders.shift_id = \(shift.id) group by payment_method.display_name
//        """
        
        let sql = """
                select
                    ru.name as display_name ,
                    ru.pos_user_type as type ,
                    ( sum(pos_order_account_journal.due) - sum(pos_order_account_journal.rest) ) as total ,
                    count(*) as count
                from
                    pos_order
                inner join pos_order_account_journal on
                    pos_order.id = pos_order_account_journal.order_id
                inner join res_users ru on
                    ru.id = pos_order.pickup_user_id
                where
                     \(sqlSession) \(sqlCreateBetween) \(self.getBrandSql()) \(self.getUsersSql())
                group by
                    ru.name
        """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                let display_name = rows.string(forColumn: "display_name") ?? ""
                let type = rows.string(forColumn: "type") ?? ""
                let total = rows.double   (forColumn: "total")
                let count = rows.double   (forColumn: "count")

                var map:[String:Any] = [:]
                map["display_name"] = display_name
                map["type"] = type
                map["total"] = total
                map["count"] = count

                total_bankStatment[display_name] = map
                
                var total_summery = total_bankStatment_summery[display_name] ?? 0
                total_summery = total_summery  + total
                
                //total_bankStatment_summery[display_name] = total_summery
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        
        
        return total_bankStatment
    }
    func getGeideaTotalStatment(casher:res_users_class?,  session:pos_session_class?, create_between:String) -> [String:[String:Any]]
    {
        
        var total_bankStatment:[String:[String:Any]] = [:]
        
        var sqlSession = ""
        // \(sqlSession) \(sqlCreateBetween)
        var sqlCreateBetween = ""
        if let session = session{
            sqlSession = "pos_order.session_id_local = \(session.id)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
        }
        
        // =====================================================================================
//        let sql = """
//        select payment_method.display_name ,payment_method.type  , ( sum( payment_method.tendered) + sum( payment_method.changes)) as total   from orders inner join payment_method on orders.id = payment_method.order_id
//        where   orders.shift_id = \(shift.id) group by payment_method.display_name
//        """
        
        let sql = """
                select
                    ioc.card_scheme as display_name ,
                    ioc.card_type as type ,
                    ( sum(pos_order_account_journal.due) - sum(pos_order_account_journal.rest) ) as total ,
                    count(*) as count
                from
                    pos_order
                inner join pos_order_account_journal on
                    pos_order.id = pos_order_account_journal.order_id
                inner join ingenico_order_class ioc  on
                    ioc.order_id = pos_order.id
                    and ioc.account_Journal_id = pos_order_account_journal.account_Journal_id
                where
                    \(sqlSession) \(sqlCreateBetween) \(self.getBrandSql()) \(self.getUsersSql())
                group by
                    ioc.card_scheme
        """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                let display_name = rows.string(forColumn: "display_name") ?? ""
                let type = rows.string(forColumn: "type") ?? ""
                let total = rows.double   (forColumn: "total")
                let count = rows.double   (forColumn: "count")

                var map:[String:Any] = [:]
                map["display_name"] = display_name
                map["type"] = type
                map["total"] = total
                map["count"] = count

                total_bankStatment[display_name] = map
                
                var total_summery = total_bankStatment_summery[display_name] ?? 0
                total_summery = total_summery  + total
                
                //total_bankStatment_summery[display_name] = total_summery
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        
        
        return total_bankStatment
    }
    
    func getTotalOrderType_group_deliveryType_accountJournal(casher:res_users_class?,  session:pos_session_class?, create_between:String) -> [String:[String:Any]]
    {
        var total_orderType:[String:[String:Any]] = [:]
        var sqlSession = ""
        // \(sqlSession) \(sqlCreateBetween)
        var sqlCreateBetween = ""
        if let session = session{
            sqlSession = "pos_order.session_id_local = \(session.id)"
        }
        if !create_between.isEmpty{
            sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
        }
        
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

                where  \(sqlSession) \(sqlCreateBetween) \(self.getBrandSql()) \(self.getUsersSql())

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

        func getTotalOrderType_group_deliveryType(casher:res_users_class?,  session:pos_session_class?, create_between:String) -> [String:[String:Any]]
        {
            var total_orderType:[String:[String:Any]] = [:]
            var sqlSession = ""
            // \(sqlSession) \(sqlCreateBetween)
            var sqlCreateBetween = ""
            if let session = session{
                sqlSession = "pos_order.session_id_local = \(session.id)"
            }
            if !create_between.isEmpty{
                sqlCreateBetween = "strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(create_between)"
            }
            
            //        total_orderType_summery.removeAll()
            
            // =====================================================================================
     
            
//             let sql = """
//
//                    select  account_journal.display_name as payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || account_journal.display_name)  as new_display_name ,
//                    ( sum( pos_order_account_journal.due)  ) as total ,pos_order.delivery_amount , count(*) as count
//                    from pos_order
//                    inner join pos_order_account_journal on pos_order.id = pos_order_account_journal.order_id
//                    inner join delivery_type on delivery_type.id =  pos_order.delivery_type_id
//                    inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
//
//                    where   pos_order.session_id_local = \(session.id)
//
//                     group by  delivery_type
//                """
            
            let sql = """

                 select    payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || payment_method )  as new_display_name ,
                                    sum( due )    as total , total_orders.delivery_amount , count(*) as count
                from
                (
                 SELECT count(*) as cnt ,(SUM(due) -  sum(rest)) as due ,order_id ,account_journal.display_name as payment_method ,pos_order.delivery_type_id,pos_order.delivery_amount as delivery_amount  from pos_order_account_journal
                 inner join  pos_order   on pos_order.id = pos_order_account_journal.order_id
                 inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
                 where   \(sqlSession) \(sqlCreateBetween) \(self.getBrandSql()) \(self.getUsersSql())
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
    
    /*public func printOrder(txt:String) {
     if txt.isEmpty {return}
     
     let pos = posConfigClass.getDefault()
     
     
     _ =  EposPrint.runPrinterReceipt(header: txt, items: "" , total: "", footer:"" , logoData: UIImage.ConvertBase64StringToImage(imageBase64String:pos.company!.logo ), openDeawer: false)
     
     
     //       self.runPrinterReceiptSequence(header: txt, items:"" , total: "", footer:"",logoData: UIImage.ConvertBase64StringToImage(imageBase64String:pos.company!.logo ) , openDeawer: false)
     
     
     
     }*/
    
 
    
    func printOrder_setHeader(html: String) -> String {
        let rows_header:NSMutableString = NSMutableString()
        if btnSelectShift.tag == -1
        {
            let posName = SharedManager.shared.posConfig().name ?? ""
            let dateTime =  (self.start_date ?? "") + " " + (self.time ?? "")
                        
            rows_header.append(" <tr><td>\("POS Name".arabic("نقطة البيع"))</td><td>: </td><td> \(posName)</td></tr>")
            if let selectedBrands = selectedBrands{
                let nameBrnads = selectedBrands.map({$0.display_name ?? ""}).joined(separator: ", ")
                rows_header.append(" <tr><td>\("Brand Name".arabic("اسم العلامة التجارية"))</td><td>: </td><td> \(nameBrnads)</td></tr>")
            }
            if let selectedUser = selectedUsers{
                let nameBrnads = selectedUser.map({$0.name ?? ""}).joined(separator: ", ")
                rows_header.append(" <tr><td>\("User Name".arabic("اسم المستخدم"))</td><td>: </td><td> \(nameBrnads)</td></tr>")
            }
            rows_header.append(" <tr><td>\("Date time".arabic("التوقيت"))</td><td>: </td><td> \(dateTime )</td></tr>")
            
           
                return html.replacingOccurrences(of: "#rows_header", with: String(rows_header) )
          
        }else{
            
            let session = sessions_list![0]
            
            let dt = Date(strDate: session.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
            let startDate = dt.toString(dateFormat: "dd/MM/yyyy", UTC: false)
            
            //        let startDate =  ClassDate.getWithFormate(session.start_session, formate: ClassDate.satnderFromate(), returnFormate: "dd/MM/yyyy",use_UTC: true )
            
            //        rows_header.append(" <tr><td>Cashier</td><td>: </td><td> \(activeSessionLast.shift_current!.casher.name)</td></tr>")
            
            //        if LanguageManager.currentLang() == .ar {
            //            rows_header.append(" <tr><td>نقطة البيع</td><td>: </td><td> \(session.pos().name!)</td></tr>")
            //            rows_header.append(" <tr><td>اليوم</td><td>: </td><td> \(startDate )</td></tr>")
            //        } else {
            //        rows_header.append(" <tr><td>POS Name</td><td>: </td><td> \(session.pos().name!)</td></tr>")
            //        rows_header.append(" <tr><td>Business day</td><td>: </td><td> \(startDate )</td></tr>")
            //        }
            
            rows_header.append(" <tr><td>\("POS Name".arabic("نقطة البيع"))</td><td>: </td><td> \(session.pos().name!)</td></tr>")
            if let selectedBrands = selectedBrands{
                let nameBrnads = selectedBrands.map({$0.display_name ?? ""}).joined(separator: ", ")
                rows_header.append(" <tr><td>\("Brand Name".arabic("اسم العلامة التجارية"))</td><td>: </td><td> \(nameBrnads)</td></tr>")
            }
            if let selectedUser = selectedUsers{
                let nameBrnads = selectedUser.map({$0.name ?? ""}).joined(separator: ", ")
                rows_header.append(" <tr><td>\("User Name".arabic("اسم المستخدم"))</td><td>: </td><td> \(nameBrnads)</td></tr>")
            }
            rows_header.append(" <tr><td>\("Business day".arabic("اليوم"))</td><td>: </td><td> \(startDate )</td></tr>")
            
            if btnSelectShift.tag == 0 ||  btnSelectShift.tag == 1
            {
                return html.replacingOccurrences(of: "#rows_header", with: String(rows_header) +  "#rows_header")
            }
            else
            {
                return html.replacingOccurrences(of: "#rows_header", with: String(rows_header)  )
                
            }
        }
        
   
    }
    
    func renderShift(){
        
    }
    
    func printOrder_setTotal(_html: String  ) -> String {
        //in case shift All [ btnSelectShift.tag == 0 , shift_id == nil ]
        //in case Summary Day [ btnSelectShift.tag == 1 , shift_id == nil ]
        // btnSelectShift.tag == 1 // Summary Report
        // shift_id == nil // in case all
        var new_html = _html
        
        let rows :NSMutableString = NSMutableString()
        
        var currect_cash = 0.0
        
        var all_total_SessionCash = 0.0
        var all_total_cash = 0.0
        
        
        
        var shifts_All :[[String : Any]] = []
        var last_day_shift:[String : Any]?
        var end_Balance_last_shift:Double = -1.0
        
        var frist_session:[String:Any]?
        var last_session:[String:Any]?


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
            if self.btnSelectShift.tag == -1 {
                shifts_All = []
            }else{
                
                let start_date = get_start_date()
                let end_date = get_end_date()
                
                let options = posSessionOptions()
                options.orderDesc = false
                options.between_start_session = [start_date,end_date]
                
                let arr:[[String:Any]] = pos_session_class.get_pos_sessions(options: options)
                frist_session = arr.first
                last_session = arr.last
                
                shifts_All  = arr
                var frist_shift_id  = 0
                if shifts_All.count > 0
                {
                    let shift_temp = shifts_All[0]
                    frist_shift_id = shift_temp["id"] as? Int ?? 0
                }
                
                if frist_shift_id != 0
                {
                    let options = posSessionOptions()
                    options.id = frist_shift_id
                    options.orderDesc = false
                    options.page = 0
                    options.LIMIT = 1
                    
                    let shifts_temp:[[String : Any]] = pos_session_class.get_pos_sessions(options: options)
                    
                    
                    let count = shifts_temp.count
                    if count > 0
                    {
                        
                        last_day_shift = shifts_temp[count - 1]
                        let obj = pos_session_class(fromDictionary: last_day_shift! )
                        end_Balance_last_shift = obj.end_Balance
                    }
                }
            }

        }
        
        let total_range = total_rang_report()
        total_range.value_dirction_style = value_dirction_style
        
        
        var geidea_payment_html:String = ""
        var insurance_payment_html:String = ""
        var orders_paymeny_driver_lock_html:String = ""
        if shifts_All.count > 0{
            for item in shifts_All
            {
                let create_between = ""
                currect_cash = 0.0
                
                let obj = pos_session_class(fromDictionary: item )
                
                
                if btnSelectShift.tag != 1
                {
                    rows.append(header_shift(obj: obj, create_between: create_between))
                    
                    rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
                }
                if forLockDriver {
                    let orders_paymeny_driver_lock = orders_count_driver_lock_html(obj: obj, create_between: create_between,cash: currect_cash)
                    orders_paymeny_driver_lock_html = orders_paymeny_driver_lock.html
                    
                }else{
                    
                    let payment = Payment_html(obj: obj, create_between: create_between,cash: currect_cash)
                    let geidea_payment = Payment_Geidea_html(obj: obj, create_between: create_between,cash: currect_cash)
                    geidea_payment_html = geidea_payment.html
                    let insurance_payment = Payment_Insurance_html(obj: obj, create_between: create_between,cash: currect_cash)
                    insurance_payment_html = insurance_payment.html
                    currect_cash = payment.cashTotal
                    rows.append(payment.html)
                    
                    if btnSelectShift.tag != 1
                    {
                        //                rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
                        rows.append(geidea_payment.html)
                        rows.append(insurance_payment.html)
                        
                        //                rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
                        
                    }
                    
                    rows.append(orderType_group_deliveryType_accountJournal_html(obj: obj, create_between: create_between ))
                    rows.append(orderType_group_deliveryType_html(obj: obj, create_between: create_between ))
                    
                    // =========================================================
                    // Cash
                    SharedManager.shared.printLog("Cash")
                    
                    var total_cash =  obj.start_Balance +  currect_cash
                    
                    if btnSelectShift.tag != 1
                    {
                        rows.append(cash_shift(obj: obj, create_between: create_between,currect_cash: currect_cash))
                    }
                    // =========================================================
                    // cashbox
                    SharedManager.shared.printLog("cashbox")
                    
                    let cashboxshift = cashbox_shift(obj: obj, create_between: create_between, totalcash: total_cash)
                    let  cash_difference = cashboxshift.cash_difference
                    total_cash = cashboxshift.total_cash
                    
                    if btnSelectShift.tag != 1
                    {
                        rows.append(cashboxshift.html)
                    }
                    // =========================================================
                    // current shift difference
                    SharedManager.shared.printLog("current shift difference")
                    
                    if btnSelectShift.tag != 1
                    {
                        rows.append(current_difference_shift(obj: obj, create_between: create_between, total_cash: total_cash))
                    }
                    // =========================================================
                    // shift difference with last
                    SharedManager.shared.printLog("shift difference with last")
                    
                    let difference = difference_with_last_shift(obj: obj, create_between: create_between, endBalanceLastShift: end_Balance_last_shift)
                    end_Balance_last_shift = difference.end_Balance_last_shift
                    
                    if btnSelectShift.tag != 1
                    {
                        rows.append(difference.html)
                    }
                    // =========================================================
                    // cash in out
                    if btnSelectShift.tag != 1
                    {
                        SharedManager.shared.printLog("cash in out")
                        
                        if cash_difference != 0
                        {
                            rows.append("<tr> <td> Cash difference </td>  <td>  </td> <td style=\"text-align:right;\">   \(cash_difference.rounded_formated_str(max_len: 12)) </td> </tr>")
                        }
                    }
                    // =========================================================
                    
                    
                    
                    if btnSelectShift.tag != 1 && shift_id != nil
                    {
                        rows.append("<tr> <td colspan=\"3\"> <hr  style=\"border: 2px dashed black;\">   </td></tr>")
                        
                        let totalOrderTax = total_range.getTotal_order(sesstion_ids: String( obj.id),create_between: create_between,brandSQL: self.getBrandSql(),usersSQL: self.getUsersSql())
                        
                        rows.append( total_range.total_order_tax_html(price_subtotal_incl:  totalOrderTax.price_subtotal_incl, price_subtotal: totalOrderTax.price_subtotal, amount_tax:  totalOrderTax.amount_tax,get_rows: true))
                        if !self.forUsersReport{
                            let total = total_range.get_Statistics(  sesstion_ids: String( obj.id),create_between: create_between,brandSQL: self.getBrandSql(),usersSQL: self.getUsersSql())
                            rows.append( total_range.total_statistics_html(total_void: total.total_void, total_return: total.total_return, total_discount: total.total_discount,get_rows: true,total_delete: total.total_delete,total_reject:total.total_rejected,total_wasted: total.total_wasted,total_product_return: total.total_product_return,total_insurances_return: total.total_insurance_return))
                        }
                        rows.append("</table>")
                        
                        
                    }
                    
                    
                    all_total_cash = all_total_cash + total_cash
                    all_total_SessionCash = all_total_SessionCash + currect_cash
                }
                
                
            }
        }else{
            let create_between = get_create_between()
            currect_cash = 0.0
            
            let obj:pos_session_class? = nil
            
            
            if btnSelectShift.tag != 1
            {
                rows.append(header_shift(obj: obj, create_between: create_between))
                
                rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
            }
            if forLockDriver {
                let orders_paymeny_driver_lock = orders_count_driver_lock_html(obj: obj, create_between: create_between,cash: currect_cash)
                orders_paymeny_driver_lock_html = orders_paymeny_driver_lock.html
                
            }else{
                
                let payment = Payment_html(obj: obj, create_between: create_between,cash: currect_cash)
                let geidea_payment = Payment_Geidea_html(obj: obj, create_between: create_between,cash: currect_cash)
                geidea_payment_html = geidea_payment.html
                let insurance_payment = Payment_Insurance_html(obj: obj, create_between: create_between,cash: currect_cash)
                insurance_payment_html = insurance_payment.html
                currect_cash = payment.cashTotal
                rows.append(payment.html)
                
                if btnSelectShift.tag != 1
                {
                    //                rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
                    rows.append(geidea_payment.html)
                    rows.append(insurance_payment.html)
                    
                    //                rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
                    
                }
                
                rows.append(orderType_group_deliveryType_accountJournal_html(obj: obj, create_between: create_between ))
                rows.append(orderType_group_deliveryType_html(obj: obj, create_between: create_between ))
                
                // =========================================================
                // Cash
                SharedManager.shared.printLog("Cash")
                
                var total_cash =    currect_cash
                
                if btnSelectShift.tag != 1
                {
                    rows.append(cash_shift(obj: obj, create_between: create_between,currect_cash: currect_cash))
                }
                // =========================================================
                // cashbox
                SharedManager.shared.printLog("cashbox")
                
                let cashboxshift = cashbox_shift(obj: obj, create_between: create_between, totalcash: total_cash)
                let  cash_difference = cashboxshift.cash_difference
                total_cash = cashboxshift.total_cash
                
                if btnSelectShift.tag != 1
                {
                    rows.append(cashboxshift.html)
                }
                // =========================================================
                // current shift difference
                
                if btnSelectShift.tag != 1
                {
                    rows.append(current_difference_shift(obj: obj, create_between: create_between, total_cash: total_cash))
                }
                // =========================================================
                // shift difference with last
                
                let difference = difference_with_last_shift(obj: obj, create_between: create_between, endBalanceLastShift: end_Balance_last_shift)
                end_Balance_last_shift = difference.end_Balance_last_shift
                
                if btnSelectShift.tag != 1
                {
                    rows.append(difference.html)
                }
                // =========================================================
                // cash in out
                if btnSelectShift.tag != 1
                {
                    SharedManager.shared.printLog("cash in out")
                    
                    if cash_difference != 0
                    {
                        rows.append("<tr> <td> Cash difference </td>  <td>  </td> <td style=\"text-align:right;\">   \(cash_difference.rounded_formated_str(max_len: 12)) </td> </tr>")
                    }
                }
                // =========================================================
                
                
                
                if btnSelectShift.tag != 1 && shift_id != nil
                {
                    rows.append("<tr> <td colspan=\"3\"> <hr  style=\"border: 2px dashed black;\">   </td></tr>")
                    
                    let totalOrderTax = total_range.getTotal_order(sesstion_ids: "",create_between: create_between,brandSQL: self.getBrandSql(),usersSQL: self.getUsersSql())
                    
                    rows.append( total_range.total_order_tax_html(price_subtotal_incl:  totalOrderTax.price_subtotal_incl, price_subtotal: totalOrderTax.price_subtotal, amount_tax:  totalOrderTax.amount_tax,get_rows: true))
                    if !self.forUsersReport{
                        let total = total_range.get_Statistics(  sesstion_ids: "",create_between: create_between,brandSQL: self.getBrandSql(),usersSQL: self.getUsersSql())
                        rows.append( total_range.total_statistics_html(total_void: total.total_void, total_return: total.total_return, total_discount: total.total_discount,get_rows: true,total_delete: total.total_delete,total_reject:total.total_rejected,total_wasted: total.total_wasted,total_product_return: total.total_product_return,total_insurances_return: total.total_insurance_return))
                    }
                    rows.append("</table>")
                    
                    
                }
                
                
                all_total_cash = all_total_cash + total_cash
                all_total_SessionCash = all_total_SessionCash + currect_cash
            }
            
        }
       
        
        if shift_id == nil
        {
            if btnSelectShift.tag == 0 ||  btnSelectShift.tag == 1
            {
                if frist_session != nil && last_session != nil
                {
                    let fs = pos_session_class(fromDictionary: frist_session!)
                    let ls = pos_session_class(fromDictionary: last_session!)
                    
                    let dt = Date(strDate: fs.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
                    let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
                    
                    var EndDate = ""
                    if !ls.end_session!.isEmpty
                    {
                        let dt_l = Date(strDate: ls.end_session!, formate: baseClass.date_fromate_satnder,UTC: true)
                          EndDate = dt_l.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
                    }
                   
                 
                    
                    let rows_header:NSMutableString = NSMutableString()

                    rows_header.append(" <tr><td>\("From".arabic("من"))</td><td>: </td><td> \(startDate )</td></tr>")
                    rows_header.append(" <tr><td>\("To".arabic("الى"))</td><td>: </td><td> \(EndDate )</td></tr>")
                    rows_header.append(" <tr><td></td><td></td><td></td></tr>")

                    new_html = new_html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
                }
            }
            if forLockDriver{
                if !orders_paymeny_driver_lock_html.isEmpty{
                rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
                rows.append(orders_paymeny_driver_lock_html)
                rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")

                }
            }else{
            var needAddSeprator = true
            rows.append( total_Payment_html() )
            if !geidea_payment_html.isEmpty{
            rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
            rows.append(geidea_payment_html)
                if needAddSeprator {
                    rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
                    needAddSeprator = !needAddSeprator

                }
            }
            if !insurance_payment_html.isEmpty{
            rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
            rows.append(insurance_payment_html)
                if needAddSeprator{
            rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
                    needAddSeprator = !needAddSeprator
                }

            }
                if needAddSeprator {
                    rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
                    needAddSeprator = !needAddSeprator

                }
            
                  rows.append( total_deliveryType_html() )
            rows.append( total_deliveryType_accountJournal_html() )
            
            let sesstion_ids = get_sessions_ids()
      
                let totalOrderTax = total_range.getTotal_order(sesstion_ids: sesstion_ids,create_between: get_create_between(),brandSQL: self.getBrandSql(),usersSQL: self.getUsersSql())
            rows.append( total_range.total_order_tax_html(price_subtotal_incl:  totalOrderTax.price_subtotal_incl, price_subtotal: totalOrderTax.price_subtotal, amount_tax:  totalOrderTax.amount_tax,get_rows: false))
                if !forUsersReport{
                    let total = total_range.get_Statistics(  sesstion_ids: sesstion_ids,create_between: get_create_between(),brandSQL: self.getBrandSql(),usersSQL: self.getUsersSql())
                    rows.append( total_range.total_statistics_html(total_void: total.total_void, total_return: total.total_return, total_discount: total.total_discount,get_rows: false,total_delete: total.total_delete,total_reject: total.total_rejected,total_wasted: total.total_wasted,total_product_return: total.total_product_return,total_insurances_return: total.total_insurance_return))
                }
            }
            
        }
        else
        {
            new_html = new_html.replacingOccurrences(of: "#rows_header", with: "")

        }
        
        
        return new_html.replacingOccurrences(of: "#rows_total", with: String(rows))
    }
    
    
    func total_Payment_html() -> String
    {
        SharedManager.shared.printLog("total_Payment_html")
        
        let sortedKeys = total_bankStatment_summery.sorted {$0.key < $1.key}
        let rows :NSMutableString = NSMutableString()
        
        var all_Payment = 0.0
        var currect_cash = 0.0
        
        
        rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black;padding-right: 20px; padding-left: 20px\">")
        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> ملخص الدفع </u> </h4>  </td>    </tr>")
        } else {
        rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> Payment summary </u> </h4>  </td>    </tr>")
        }
        
        
        
        for (name, total) in sortedKeys {
            if total > 0 {
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
        }
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> \("Payment summary".arabic("ملخص الدفع"))</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        
//        if LanguageManager.currentLang() == .ar {
//            rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> ملخص الدفع</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
//        } else {
//        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> Payment summary</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
//        }
        
        rows.append("</table>")
        return String(rows)
    }
    
    func total_deliveryType_accountJournal_html() -> String
    {
        if is_order_type_enabled() == false
        {
            return ""
        }
        
        
           SharedManager.shared.printLog("total_orderType_html")
        
        let sortedKeys = total_deliveryType_accountJournal_summery.sorted {$0.key < $1.key}
        let rows :NSMutableString = NSMutableString()
        
        var all_Payment = 0.0
        
        
        
        rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
        
        rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\" > <u> "+"payment - Order Type summary".arabic("الدفع - ملخص نوع الطلب")+" </u> </h4>  </td>    </tr>")

        
        for (name, value) in sortedKeys {
            
            let total = value["total"] as? Double ?? 0
            let count = value["count"] as? Double ?? 0
            if total != 0 {
            //            let bankStatement = value["bankStatement"] as? String ?? ""
            
            all_Payment =  all_Payment + total
            
            
            let title =  String(format:"%@  \u{202A}(\u{202C} %@ \u{202A})\u{202C}" , name,count.toIntString() )

            
            rows.append("<tr> <td style=\"width: 75%;\">  \(title)  </td>  <td ></td> <td style=\"text-align:\(value_dirction_style);width: 25%;\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
            }
        }
        
        
        rows.append("<tr> <td> <h5  > <u> \("payment - Order Type summary".arabic(" الدفع - ملخص نوع الطلب ")) </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align: \(value_dirction_style)\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        
//        if LanguageManager.currentLang() == .ar {
//
//        rows.append("<tr> <td> <h5  > <u> الدفع - ملخص نوع الطلب </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
//        } else {
//            rows.append("<tr> <td> <h5  > <u> payment - Order Type summary </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
//
//        }
        
        rows.append("</table>")
        return String(rows)
    }
    
    func total_deliveryType_html() -> String
     {
        if is_order_type_enabled() == false
        {
            return ""
        }
        
            SharedManager.shared.printLog("total_orderType_html")
         
         let sortedKeys = total_deliveryType_summery.sorted {$0.key < $1.key}
         let rows :NSMutableString = NSMutableString()
         
         var all_Payment = 0.0
         
         
         
//         rows.append("<table style=\"width: 98%;text-align: left; border: 4px solid black; padding-right: 20px; padding-left: 20px\">")
        
        rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> "+"Order Type summary".arabic("ملخص نوع الطلب")+" </u> </h4>  </td>    </tr>")

        
        
         
         for (name, value) in sortedKeys {
             
             let total = value["total"] as? Double ?? 0
             let count = value["count"] as? Double ?? 0
             if total != 0 {
             //            let bankStatement = value["bankStatement"] as? String ?? ""
             
             all_Payment =  all_Payment + total
             
            let title = String(format:"%@  \u{202A}(\u{202C} %@ \u{202A})\u{202C}" , name,count.toIntString() )

             rows.append("<tr> <td style=\"width: 75%;\">  \(title)  </td>  <td ></td> <td style=\"text-align:\(value_dirction_style);width: 25\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
             }
         }
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>"+"Order Type summary".arabic("ملخص نوع الطلب")+"</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")

         
         
         rows.append("</table>")
         return String(rows)
     }
     
    
    func Payment_html(obj:pos_session_class?,create_between:String ,  cash:Double ) -> (html:String , cashTotal:Double) {
        SharedManager.shared.printLog("Payment_html")
        let rows :NSMutableString = NSMutableString()
        
        var currect_cash = cash
        var all_Payment = 0.0
        
        if btnSelectShift.tag != 1
        {
        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> طريقة الدفع </u> </h4>  </td>    </tr>")
        } else {
        rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> Payment </u> </h4>  </td>    </tr>")
        }
        }
        
        let total_bankStatment = getTotalStatment(casher: obj?.cashier(),  session: obj,create_between:create_between)
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
            if total != 0 {
            if type == "cash"
            {
                currect_cash = currect_cash + total
                
            }
            else
            {
                all_Payment =  all_Payment + total
                
                
                //                header .addLine(title: name, val:String(format: "%@", total.toIntString()), alignMode: .titleLeft_valRight)
                
            }
            
            if btnSelectShift.tag != 1
            {
            rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
        }
            }
        }
        
        let total_payment = all_Payment + currect_cash
        
        if btnSelectShift.tag != 1
        {
            rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> \("Total Payment".arabic("اجمالي النقدية")) </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(total_payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
            
            
//        if LanguageManager.currentLang() == .ar {
//            rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>اجمالي النقدية </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(total_payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
//        } else {
//        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>Total Payment </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(total_payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
//        }
        }
        //        for (name, total) in other_bankStatment {
        //            //            header .addLine(title: name, val:String(format: "%@", total.toIntString()), alignMode: .titleLeft_valRight)
        //            rows.append("<tr> <td> \(name) </td>  <td>  : </td> <td>   \(String(format: "%@", total.toIntString())) </td> </tr>")
        //        }
        if total_payment <= 0 {
            return ("",0)
        }
        return (String(rows),currect_cash)
    }
    func orders_count_driver_lock_html(obj:pos_session_class?,create_between:String ,  cash:Double ) -> (html:String , cashTotal:Double) {
        SharedManager.shared.printLog("orders_count_driver_lock_html")
        let rows :NSMutableString = NSMutableString()
        
        var currect_cash = cash
        var all_Payment = 0.0
        
        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u>تفاصيل الطلبات </u> </h4>  </td>    </tr>")
        } else {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u>Driver Lock analysis</u> </h4>  </td>    </tr>")
        }
        
        let total_driverLockStatment = getDriverLockStatment(casher: obj?.cashier(),  session: obj, create_between: create_between)
                
        var all_driverLockStatment: [String:[String:Any]] = [:]
        all_driverLockStatment.merge(with: total_driverLockStatment)
                
        let sortedKeys = all_driverLockStatment.sorted {$0.key < $1.key}
        
        for (name, map) in sortedKeys {
            let display_name = map["display_name"]
//            let type =  map["type"] as? String ?? ""
            let total =  map["total"] as? Double ?? 0
            all_Payment =  all_Payment + total
            rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
        }
        
        let total_payment = all_Payment + currect_cash
        
            rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> \("Total".arabic("الاجمالي")) </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(total_payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        if total_payment <= 0 {
            return ("",0)
        }
        return (String(rows),currect_cash)
    }
    func Payment_Geidea_html(obj:pos_session_class?,create_between:String ,  cash:Double ) -> (html:String , cashTotal:Double) {
        SharedManager.shared.printLog("Payment_Geidea_html")
        let rows :NSMutableString = NSMutableString()
        
        var currect_cash = cash
        var all_Payment = 0.0
        
        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u>تفاصيل الحركات البنكيه</u> </h4>  </td>    </tr>")
        } else {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u>Bank analysis</u> </h4>  </td>    </tr>")
        }
        
        let total_bankStatment = getGeideaTotalStatment(casher: obj?.cashier(),  session: obj, create_between: create_between)
                
        var all_bankStatment: [String:[String:Any]] = [:]
        all_bankStatment.merge(with: total_bankStatment)
                
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
                                
            }
            
            rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
        }
        
        let total_payment = all_Payment + currect_cash
        
            rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> \("Total".arabic("الاجمالي")) </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(total_payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        if total_payment <= 0 {
            return ("",0)
        }
        return (String(rows),currect_cash)
    }
    func Payment_Insurance_html(obj:pos_session_class?,create_between:String ,  cash:Double ) -> (html:String , cashTotal:Double) {
        SharedManager.shared.printLog("Payment_Insurance_html")
        let rows :NSMutableString = NSMutableString()
        
        var currect_cash = cash
        var all_Payment = 0.0
        
        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u>تفاصيل ايصالات التآمين </u> </h4>  </td>    </tr>")
        } else {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u>Insurance analysis</u> </h4>  </td>    </tr>")
        }
        
        let total_bankStatment = getInsuranceTotalStatment(casher: obj?.cashier(),  session: obj, create_between: create_between)
                
        var all_bankStatment: [String:[String:Any]] = [:]
        all_bankStatment.merge(with: total_bankStatment)
                
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
                                
            }
            
            rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
        }
        
        let total_payment = all_Payment + currect_cash
        
            rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u> \("Total".arabic("الاجمالي")) </u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%;text-align:\(value_dirction_style)\">  \(total_payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        if total_payment <= 0 {
            return ("",0)
        }
        return (String(rows),currect_cash)
    }
    
    //    func getTotalOrders(casher:cashierClass,session:posSessionClass, shift:posSessionClass) -> Int
    //    {
    //        var total_orderType :Int = 0
    //
    //        for item in orders
    //        {
    //            let obj = item  //orderClass(fromDictionary: item as! [String : Any])
    ////              #warning("Fix it")
    //            let shift_current = obj.shift //posSessionClass.getShift(session_id: session.id)
    //            if obj.cashier?.id == casher.id && session.id == obj.session?.id && shift.id ==  shift_current!.id
    //            {
    //               total_orderType += 1
    //            }
    //
    //        }
    //
    //        return total_orderType
    //    }
    
    
    func orderType_group_deliveryType_accountJournal_html(obj:pos_session_class?,create_between:String   ) -> String {
        
        if is_order_type_enabled() == false
        {
            return ""
        }
        
         SharedManager.shared.printLog("orderType_html")

        
        let rows :NSMutableString = NSMutableString()
        
 
        
        var all_Payment = 0.0
        
        if btnSelectShift.tag != 1
        {
        rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> Order Type </u> </h4>  </td>    </tr>")
        }
        
        let total_bankStatment = getTotalOrderType_group_deliveryType_accountJournal(casher: obj?.cashier(),  session: obj, create_between: create_between)
        let sortedKeys = total_bankStatment.sorted {$0.key < $1.key}
        
        for (name, value) in sortedKeys {
            let total = value["total"] as? Double ?? 0
            let count = value["count"] as? Double ?? 0
            //               let bankStatement = value["bankStatement"] as? String ?? ""
            if total != 0 {
            all_Payment =  all_Payment + total
            
            if btnSelectShift.tag != 1
            {
            let title = String(format:"%@  \u{202A}(\u{202C} %@ \u{202A})\u{202C}" , name,count.toIntString() )
            
             rows.append("<tr> <td style = \"width:75%;\">   \(title)  </td>  <td  >  </td> <td style=\"text-align:\(value_dirction_style);width:25%;\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
            }
            }
            
        }
        
        //        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>Total Order Type </u> </h5>  </td>  <td>  : </td> <td> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str())  </h5>  </td> </tr>")
        
        
        return String(rows)
    }
    
      func orderType_group_deliveryType_html(obj:pos_session_class?,create_between:String   ) -> String {
        
        if is_order_type_enabled() == false
        {
            return ""
        }
        
            SharedManager.shared.printLog("orderType_html")

           
           let rows :NSMutableString = NSMutableString()
           
    
           
           var all_Payment = 0.0
           
        if btnSelectShift.tag != 1
        {
           rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> Order Type </u> </h4>  </td>    </tr>")
        }
        
          let total_bankStatment = getTotalOrderType_group_deliveryType(casher: obj?.cashier(),  session: obj, create_between: create_between)
           let sortedKeys = total_bankStatment.sorted {$0.key < $1.key}
           
           for (name, value) in sortedKeys {
               let total = value["total"] as? Double ?? 0
               let count = value["count"] as? Double ?? 0
               //               let bankStatement = value["bankStatement"] as? String ?? ""
               if total != 0 {
               all_Payment =  all_Payment + total
               
//               rows.append("<tr> <td> \(name)  </td>  <td>  \(count.toIntString() ) </td> <td style=\"text-align:right;\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")

            if btnSelectShift.tag != 1
            {
            let title = String(format:"%@  \u{202A}(\u{202C} %@ \u{202A})\u{202C}" , name,count.toIntString() )

               rows.append("<tr> <td style = \"width:75%;\"> \(title)  </td>  <td   >   </td> <td style=\"text-align:\(value_dirction_style);width:25%;\">   \(  total.rounded_formated_str(max_len: 12)  ) </td> </tr>")
            }
               }
           }
           
           //        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>Total Order Type </u> </h5>  </td>  <td>  : </td> <td> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str())  </h5>  </td> </tr>")
           
           
           return String(rows)
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
 
        
//        let sql = "select * from sessions where start_session between '\(start_date)'  and  '\(end_date)'"
//
//
//        let semaphore = DispatchSemaphore(value: 0)
//        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
//
//            let rows:FMResultSet = try! db.executeQuery(sql, values: [])
//
//            while rows.next()
//            {
//
//                let data = rows.string(forColumn: "data")
//                let dic =  data?.toDictionary() ?? [:]
//                let session = pos_session_class(fromDictionary: dic)
//                session.id = Int(rows.int(forColumn: "session_id"))
//
//
//                lst_sessions.append(session)
//
//            }
//
//            rows.close()
//            semaphore.signal()
//        }
//
//
//        semaphore.wait()
        
      
        return lst_sessions
        
    }
    
    func get_sessions_ids() -> String
    {
        if self.btnSelectShift.tag == -1 {
            return ""
        }
        if shift_id != nil
        {
            return String( shift_id!)
        }
        
        var ids = ""
        
        for item in sessions_list! {
            ids =  ids + "," + String( item.id)
        }
        ids.removeFirst()
        
        return ids
    }
    
    func printOrder_html() -> String {
        
        total_bankStatment_summery.removeAll()
        total_deliveryType_accountJournal_summery.removeAll()
        total_deliveryType_summery.removeAll()
        
        sessions_list = getSessionForDay()
        
        var html = baseClass.get_file_html(filename: "z_report",showCopyRight: true)
//        let pos = SharedManager.shared.posConfig()
        if (self.selectedBrands?.count ?? 0) > 0 {
            html = html.replacingOccurrences(of: "#title", with: "Brand report".arabic("تقرير العلامة التجارية"))

        }else{
            if (self.selectedUsers?.count ?? 0) > 0 {
                if let userName = self.selectedUsers?.first?.name{
                    html = html.replacingOccurrences(of: "#title", with: "\(userName) report".arabic("تقرير \(userName) "))
                }else{
                    html = html.replacingOccurrences(of: "#title", with: custom_header ?? "")

                }
            }else{
                //html = html.replacingOccurrences(of: "#logo", with: pos.company!.logo )
                html = html.replacingOccurrences(of: "#title", with: custom_header ?? "")
            }
        }
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

        if sessions_list?.count == 0
        {
            hideActivityIndicator()
            let rows_header:NSMutableString = NSMutableString()
            let posName = SharedManager.shared.posConfig().name ?? ""
            let dateTime =  (self.start_date ?? "") + " " + (self.time ?? "")
            
            rows_header.append(" <tr><td>\("POS Name".arabic("نقطة البيع"))</td><td>: </td><td> \(posName)</td></tr>")
            if let selectedBrands = selectedBrands{
                let nameBrnads = selectedBrands.map({$0.display_name ?? ""}).joined(separator: ", ")
                rows_header.append(" <tr><td>\("Brand Name".arabic("اسم العلامة التجارية"))</td><td>: </td><td> \(nameBrnads)</td></tr>")
            }
            if let selectedUser = selectedUsers{
                let nameBrnads = selectedUser.map({$0.name ?? ""}).joined(separator: ", ")
                rows_header.append(" <tr><td>\("User Name".arabic("اسم المستخدم"))</td><td>: </td><td> \(nameBrnads)</td></tr>")
            }
            rows_header.append(" <tr><td>\("Date time".arabic("التوقيت"))</td><td>: </td><td> \(dateTime )</td></tr>")
            
            html = html.replacingOccurrences(of: "#rows_total", with: "<h3>" + "No sessions or sales during this period.".arabic(".لاتوجد جلسات او مبيعات في تلك الفترة")+"</h3>")
            return html.replacingOccurrences(of: "#rows_header", with: String(rows_header) )
        }
        
        html = printOrder_setHeader(html: html)
        
        html = printOrder_setTotal(_html: html )
        
 
        hideActivityIndicator()
        return html
    }
    
    
    func doneSelect() {
        
        loadReport()
        
        
    }
    
    
    
    
    func header_shift(obj:pos_session_class?,create_between:String) -> String
    {
        
        
        let rows :NSMutableString = NSMutableString()
        if let obj = obj{
            let dt = Date(strDate: obj.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
            let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
            
            
            var endDate = ""
            
            if obj.end_session  != ""
            {
                
                let dt = Date(strDate: obj.end_session!, formate: baseClass.date_fromate_satnder,UTC: true)
                endDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
                
            }
            
            
            
            let option = ordersListOpetions()
            
            option.sesssion_id = obj.id
            option.orderSyncType = .order
            option.void = false
            option.Closed = true
            option.write_pos_id = SharedManager.shared.posConfig().id
            if let userWriteId =  self.selectedUsers?.first?.id {
                option.write_user_id = userWriteId
                
            }
            if let selectedBrands = self.selectedBrands {
                option.brandIDS = selectedBrands.map({$0.id})
            }
            let countOrders = pos_order_helper_class.getOrders_status_sorted_count(options: option)
            
            rows.append("<table style=\"width: 98%;text-align: left;border: 4px solid black;padding: 10px;margin-top: 20px;\">")
            var shiftString = String( obj.id)
            if obj.server_session_name != "" {
                shiftString += " (\(obj.server_session_name))"
            }
            if LanguageManager.currentLang() == .ar {
                
                rows.append("<tr><td style=\"width: 30%\">  <b>  الجلسة </b> </td> <td>  :  </td><td>  \( shiftString )</b> </td></tr>")
                if !self.forUsersReport{
                    rows.append("<tr><td style=\"width: 30%\">  <b>  الموظف </b> </td> <td>  :  </td><td>  \(obj.cashier().name ?? "" )</b> </td></tr>")
                }
                rows.append("<tr><td >   <b> البداية </b> </td> <td>  :  </td><td> <b> \(startDate )</b> </td></tr>")
                rows.append("<tr><td >   <b> النهاية </b> </td> <td>  :  </td><td><b>  \(endDate) </b></td></tr>")
                rows.append("<tr><td >   <b> الطلبات </b> </td> <td>  :  </td><td><b>  \(countOrders) </b></td></tr>")
            } else {
                
                rows.append("<tr><td style=\"width: 30%\">  <b>  Shift </b> </td> <td>  :  </td><td>  \( shiftString )</b> </td></tr>")
                if !self.forUsersReport{
                    
                    rows.append("<tr><td style=\"width: 30%\">  <b>  Employee </b> </td> <td>  :  </td><td>  \(obj.cashier().name ?? "" )</b> </td></tr>")
                }
                rows.append("<tr><td >   <b> Opened at </b> </td> <td>  :  </td><td> <b> \(startDate )</b> </td></tr>")
                rows.append("<tr><td >   <b> Closed at </b> </td> <td>  :  </td><td><b>  \(endDate) </b></td></tr>")
                rows.append("<tr><td >   <b> Orders # </b> </td> <td>  :  </td><td><b>  \(countOrders) </b></td></tr>")
            }
            rows.append("</table>")
            
            
            return String(rows)
        }else{
            let startDate = (self.start_date ?? "") + " " + (self.time ?? "")
            
            let option = ordersListOpetions()
            option.betweenDate = self.get_create_between()
            option.orderSyncType = .order
            option.void = false
            option.Closed = true
            option.write_pos_id = SharedManager.shared.posConfig().id
            if let userWriteId =  self.selectedUsers?.first?.id {
                option.write_user_id = userWriteId
                
            }
            if let selectedBrands = self.selectedBrands {
                option.brandIDS = selectedBrands.map({$0.id})
            }
            let countOrders = pos_order_helper_class.getOrders_status_sorted_count(options: option)
            
            rows.append("<table style=\"width: 98%;text-align: left;border: 4px solid black;padding: 10px;margin-top: 20px;\">")
            if LanguageManager.currentLang() == .ar {
                
                rows.append("<tr><td >   <b> التوقيت </b> </td> <td>  :  </td><td> <b> \(startDate )</b> </td></tr>")
                rows.append("<tr><td >   <b> الطلبات </b> </td> <td>  :  </td><td><b>  \(countOrders) </b></td></tr>")
            } else {
                
                rows.append("<tr><td >   <b> Date time at </b> </td> <td>  :  </td><td> <b> \(startDate )</b> </td></tr>")
                rows.append("<tr><td >   <b> Orders # </b> </td> <td>  :  </td><td><b>  \(countOrders) </b></td></tr>")
            }
            rows.append("</table>")
            
            
            return String(rows)
            
        }
    }
    
    
    func cash_shift(obj:pos_session_class?,create_between:String,currect_cash:Double) -> String
    {
        if ( self.selectedBrands?.count ?? 0 ) > 0 {
            return ""
        }
        let rows :NSMutableString = NSMutableString()

        if LanguageManager.currentLang() == .ar {
            rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> المجموع </u> </h4>  </td>    </tr>")
        } else {
        rows.append("<tr>  <td colspan=\"3\">   <h4 style=\"line-height: 0%\"> <u> Total </u> </h4>  </td>    </tr>")
        }
        
        if LanguageManager.currentLang() == .ar {
            if let obj = obj{
                rows.append("<tr> <td> الرصيد الافتتاحي  </td>  <td>  </td> <td style=\"text-align:\(value_dirction_style);\">   \(obj.start_Balance.rounded_formated_str(max_len: 12)) </td> </tr>")
            }
            rows.append("<tr> <td> المبيعات النقدية  </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(currect_cash.rounded_formated_str(max_len: 12)) </td> </tr>")
        } else {
            if let obj = obj{
                rows.append("<tr> <td> Opening Balance  </td>  <td>  </td> <td style=\"text-align:\(value_dirction_style);\">   \(obj.start_Balance.rounded_formated_str(max_len: 12)) </td> </tr>")
            }
        rows.append("<tr> <td> Cash sales  </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(currect_cash.rounded_formated_str(max_len: 12)) </td> </tr>")
        }
        
        
        return String(rows)

    }
    
    func cashbox_shift(obj:pos_session_class?,create_between:String,totalcash:Double) -> (html:String,cash_difference:Double,total_cash:Double)
    {
        let rows :NSMutableString = NSMutableString()
        var total_cash = totalcash
        
        var dif_total_cashbox_In = 0.0
        var dif_total_cashbox_out = 0.0
        
        if let obj = obj{
            if obj.cashbox_list.count != 0
            {
                let titel_Cash_in = "Cash in"
                let titel_Cash_Out = "Cash out"
                
                
                for item in obj.cashbox_list
                {
                    
                    let shift_cashbox = item //cashbox_class(fromDictionary: item  )
                    if shift_cashbox.cashbox_in_out == "in"
                    {
                        dif_total_cashbox_In = dif_total_cashbox_In + shift_cashbox.cashbox_amount
                    }
                    else
                    {
                        
                        dif_total_cashbox_out = dif_total_cashbox_out + shift_cashbox.cashbox_amount
                    }
                    
                    
                    
                }
                
                if dif_total_cashbox_In > 0
                {
                    rows.append("<tr> <td> \(titel_Cash_in)  </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(dif_total_cashbox_In.toIntString()) </td> </tr>")
                }
                
                if dif_total_cashbox_out > 0
                {
                    rows.append("<tr> <td> \(titel_Cash_Out)  </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\">   \(dif_total_cashbox_out.toIntString()) </td> </tr>")
                }
            }
        }
        total_cash = total_cash + dif_total_cashbox_In - dif_total_cashbox_out
        let cash_difference = dif_total_cashbox_In - dif_total_cashbox_out
        if (self.selectedBrands?.count ?? 0) <= 0 {
            if LanguageManager.currentLang() == .ar {
                rows.append("<tr> <td colspan=\"3\"> <hr  style=\"border: 2px dashed black;\">   </td></tr>")
                rows.append("<tr> <td> <h4 style=\"line-height: 0%\"> الاجمالي </h4>  </td>  <td>   </td> <td style=\"text-align:\(value_dirction_style);\"> <h4 style=\"line-height: 0%\">  \(total_cash.rounded_formated_str(max_len: 12))  </h4>  </td> </tr>")
                rows.append("<tr> <td colspan=\"3\"> <hr  style=\"border: 2px dashed black;\">   </td></tr>")
                if let obj = obj{
                    rows.append("<tr> <td> الرصيد الختامي  </td>  <td>  </td> <td style=\"text-align:\(value_dirction_style);\">   \(obj.end_Balance.rounded_formated_str(max_len: 12)) </td> </tr>")
                }
            } else {
                rows.append("<tr> <td colspan=\"3\"> <hr  style=\"border: 2px dashed black;\">   </td></tr>")
                rows.append("<tr> <td> <h4 style=\"line-height: 0%\"> Total Cash </h4>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h4 style=\"line-\(value_dirction_style): 0%\">  \(total_cash.rounded_formated_str(max_len: 12))  </h4>  </td> </tr>")
                rows.append("<tr> <td colspan=\"3\"> <hr  style=\"border: 2px dashed black;\">   </td></tr>")
                if let obj = obj{
                    rows.append("<tr> <td> Closed Balance  </td>  <td>  </td> <td style=\"text-align:\(value_dirction_style);\">   \(obj.end_Balance.rounded_formated_str(max_len: 12)) </td> </tr>")
                }
            }
        }
        return (String(rows) , cash_difference,total_cash)
    }
    
    
    func current_difference_shift(obj:pos_session_class?,create_between:String,total_cash:Double) -> String
    {
        if (self.selectedBrands?.count ?? 0 )  > 0 {
            return ""
        }
        guard let obj = obj else { return  ""}

        let rows :NSMutableString = NSMutableString()

        let balance_difference =     obj.end_Balance - total_cash
        if balance_difference != 0
        {
            if LanguageManager.currentLang() == .ar {
                rows.append("<tr > <td style=\"border: 2px solid red;\"> الفروقات  </td>  <td >  </td> <td style=\"text-align:right;border: 2px solid red;\">   \(balance_difference.rounded_formated_str(max_len: 12)) </td> </tr>")
            } else {
            rows.append("<tr > <td style=\"border: 2px solid red;\"> Difference Balance  </td>  <td >  </td> <td style=\"text-align:right;border: 2px solid red;\">   \(balance_difference.rounded_formated_str(max_len: 12)) </td> </tr>")
        }
        }
        
        return String(rows)
    }
    
    func difference_with_last_shift(obj:pos_session_class?,create_between:String,endBalanceLastShift:Double) -> (html:String,end_Balance_last_shift:Double)
    {
        var end_Balance_last_shift = endBalanceLastShift
        let rows :NSMutableString = NSMutableString()

        if end_Balance_last_shift  != -1
        {
            let balance_difference_shift = (obj?.start_Balance ?? 0.0)  -  end_Balance_last_shift

                     if balance_difference_shift != 0
                     {
                         rows.append("<tr> <td style=\"border: 2px solid red;\">Shift Difference Balance  </td>  <td>  </td> <td style=\"text-align:right;border: 2px solid red;\">   \(balance_difference_shift.rounded_formated_str(max_len: 12)) </td> </tr>")
                     }
        }
     
        
        end_Balance_last_shift = obj?.end_Balance ?? 0.0
        
        return (String(rows) ,end_Balance_last_shift)
    }
}
