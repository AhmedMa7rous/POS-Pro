//
//  stock_report.swift
//  pos
//
//  Created by Khaled on 3/28/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
import WebKit

class sales_report_multi_pos : ReportViewController {
    @IBOutlet weak var container: UIView!
    var webView: WKWebView!
    @IBOutlet weak  var indc: UIActivityIndicatorView?
    
    @IBOutlet var btnEndDate: UIButton!
    @IBOutlet var btnStartDate: UIButton!
    var start_time: String?
    var end_time: String?
    var start_date:String?
    var end_date:String?
    let date_formate = "yyyy-MM-dd"
    @IBOutlet var btnSelectPOSs: UIButton!
    var list_pos:options_choose?
    var list_fillter:options_choose?

    var selected_poss:[pos_config_class] = []
    var selected_pos_ids:[Int] = []

    var selected_pos_str :String =  "All"
    var custom_header:String?

    var selected_fillter:[String] = []
    var listPOSFetched:[pos_config_class] = []

    
    private lazy var formatter: DateFormatter = {
        let f = DateFormatter()
        f.timeZone  = TimeZone(secondsFromGMT: 0)!
        f.dateFormat = "hh:mm a"      // "HH:mm" for 24-hour
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.fetchAllPOS()
        }
        let webConfiguration = WKWebViewConfiguration()
        container.frame.size.width = self.view.frame.size.width
        container.frame.size.height = self.view.frame.size.height - 60

        webView = WKWebView(frame:container.bounds, configuration: webConfiguration)
        //        webView.uiDelegate = self
                webView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
                webView.frame = container.bounds
        container.addSubview(webView)
        
        getLastBussinusDate()
        
        loadReport()
        
        let setting = SharedManager.shared.appSetting()
        let json =    setting.sales_report_filtter
        let dic_fillter = json.toDictionary() ?? [:]
        
        selected_pos_str = dic_fillter["pos_str"] as? String ??  "All"
        selected_pos_ids = dic_fillter["pos_ids"] as? [Int] ?? []
        selected_fillter = dic_fillter["selected_fillter"] as? [String] ??  []

        self.btnSelectPOSs.setTitle(self.selected_pos_str, for: .normal)

    }
    
    // ===================================================================
    func getLastBussinusDate()
    {
        
        
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
                
                end_date = start_date
                
                
            }
            else
            {
                start_date = Date().toString(dateFormat: date_formate, UTC: false) //ClassDate.getNow(date_formate , timeZone: NSTimeZone.local )
                end_date = start_date
                
            }
        }
        else
        {
            start_date = Date().toString(dateFormat: date_formate, UTC: false) //ClassDate.getNow(date_formate , timeZone: NSTimeZone.local )
            end_date = start_date
            
        }
        
        
        btnStartDate.setTitle(start_date, for: .normal)
        btnEndDate.setTitle(end_date, for: .normal)
        
    }
    
    @IBAction func btnStartDate(_ sender: Any) {
        showCalendarTimePicker(forStartDate: true)
//        let calendar = calendarVC()
//        
//        if self.start_date != nil
//        {
//            calendar.startDate = Date(strDate: self.start_date!, formate:self.date_formate, UTC: true)
//        }
//        
//        calendar.modalPresentationStyle = .formSheet
//        calendar.didSelectDay = { [weak self] date in
//            
//            
//            self?.start_date = date.toString(dateFormat:self!.date_formate)
//            self?.btnStartDate.setTitle( self?.start_date, for: .normal)
//            
//            self?.end_date = date.toString(dateFormat:self!.date_formate)
//            self?.btnEndDate.setTitle( self?.end_date, for: .normal)
//            
//            self?.doneSelect()
//            
//            calendar.dismiss(animated: true) {
//                self?.presentUTCTimePicker(seed: date)
//            }
//        }
//        parent_vc?.present(calendar, animated: true, completion: nil)
    }
    @IBAction func btnEndDate(_ sender: Any) {
        showCalendarTimePicker(forStartDate: false)
//        let calendar = calendarVC()
//        
//        if self.end_date != nil
//        {
//            calendar.startDate = Date(strDate: self.end_date!, formate: self.date_formate, UTC: true)
//        }
//        
//        calendar.modalPresentationStyle = .formSheet
//        calendar.didSelectDay = { [weak self] date in
//            
//            
//            self?.end_date = date.toString(dateFormat: self!.date_formate)
//            self?.btnEndDate.setTitle(self?.end_date, for: .normal)
//            
//            
//            self?.doneSelect()
//            
//            calendar.dismiss(animated: true, completion: nil)
//            
//        }
//        parent_vc?.present(calendar, animated: true, completion: nil)
    }
    
    private func showCalendarTimePicker(forStartDate: Bool) {
        let pickerVC          = DateTimePickerVC()
        if forStartDate {
            let dateTimeString = (start_date ?? "") + " " + (start_time ?? "00:00 am")
            let dateTime = Date().toDate( dateTimeString , format:  baseClass.date_fromate_satnder_12h)
            pickerVC.initialDate  = dateTime

        }else{
            let dateTimeString = (end_date ?? "") + " " + (end_time ?? "00:00 am")
            let dateTime = Date().toDate( dateTimeString , format:  baseClass.date_fromate_satnder_12h)
            pickerVC.initialDate  = dateTime

        }
        pickerVC.onPicked     = { [weak self] date, time in
            guard let self = self else { return }
            // format & assign to your labels
            if forStartDate {
                self.start_date = date
                self.start_time = time
                self.btnStartDate.setTitle(date, for: .normal)
            } else {
                self.end_date = date
                self.end_time = time
                self.btnEndDate.setTitle(date, for: .normal)
            }
            self.doneSelect()
            Swift.print("Selected Date: \(date) and Selected Time: \(time)")
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
            self.start_time = self.formatter.string(from: utcDate)
            Swift.print("Selected Time: \(self.start_time)")
        }
        pickerVC.preferredContentSize = CGSize(width: 320, height: 280)
        pickerVC.modalPresentationStyle = .formSheet
        present(pickerVC, animated: true)
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
    func fetchAllPOS(complete:(()->())? = nil ){
        loadingClass.show(view: self.view)
        pos_config_class.hitGetAllPOSAPI { posList, message in
            loadingClass.hide(view: self.view)
            if let posList = posList{
                self.listPOSFetched.removeAll()

                if posList.count <= 0 {
                    messages.showAlert("Not found POS at branch")

                }else{
                    self.listPOSFetched.append(contentsOf: posList)
                    self.intalizelistPOS()
                    complete?()
                }
            }else{
                messages.showAlert(message)
            }
        }
    }
    func intalizelistPOS(){
            list_pos = options_choose()
            list_pos!.modalPresentationStyle = .formSheet
            list_pos!.list_items.append([options_choose.title_prefex:"All"])
            for pos in listPOSFetched
            {
                var dic = pos.toDictionary()
                dic[options_choose.title_prefex] = pos.name
                dic[options_choose.obj_prefex] = pos
                list_pos!.list_items.append(dic)
            }
    }
    
    @IBAction func btnSelectPOS(_ sender: Any) {
        
        if list_pos == nil
        {
            self.fetchAllPOS {
                self.btnSelectPOS(sender)
            }
            return
            /*
            list_pos = options_choose()
            
            list_pos!.modalPresentationStyle = .formSheet
            
            list_pos!.list_items.append([options_choose.title_prefex:"All"])
            
            let lst:[[String:Any]] = pos_config_class.getAll()
            
            for item in lst
            {
                var dic = item
                let pos = pos_config_class(fromDictionary: item  )
                
                dic[options_choose.title_prefex] = pos.name
                dic[options_choose.obj_prefex] = pos
                
                list_pos!.list_items.append(dic)
                
            }
            */
        }
        
         
        list_pos!.didSelect = { [weak self] data in
            self!.selected_poss = data as! [pos_config_class]

            if self!.selected_poss.count == (self!.list_pos!.list_items.count - 1)
            {
                self!.selected_pos_str = "All"
            }
            else
            {
                  self!.selected_pos_str = ""
                for item in self!.selected_poss
                           {
                            self!.selected_pos_str = self!.selected_pos_str + "/" + item.name!
                          }
                         
                         if  self!.selected_poss.count == 0
                         {
                             self!.selected_pos_str = "All"
                         }
            }
            
            let setting = SharedManager.shared.appSetting()
            let json =    setting.sales_report_filtter
            var dic_fillter = json.toDictionary() ?? [:]
            
            dic_fillter["pos_str"] = self!.selected_pos_str
            dic_fillter["pos_ids"]  = self!.selected_pos_ids
            setting.sales_report_filtter = dic_fillter.jsonString()  ?? ""
            setting.save()
            
 
            self!.btnSelectPOSs.setTitle(self!.selected_pos_str, for: .normal)
            
            self!.selected_pos_ids = self!.get_selected_pos()
            
            self!.loadReport()
 
        }
        
        
        self.present(list_pos!, animated: true, completion: nil)
        list_pos!.lblTitle.text = "Select POS"
        
        
    }
    
    @IBAction func btn_fillter(_ sender: Any) {
        
      if list_fillter == nil
               {
                   list_fillter = options_choose()
                   
                   list_fillter!.modalPresentationStyle = .formSheet
                   
                   list_fillter!.list_items.append([options_choose.title_prefex:"All"])
                   
                
                                     
                  list_fillter!.list_items.append([options_choose.title_prefex:"End of day Payment summary"
                    ,options_choose.obj_prefex:"End of day Payment summary"])
                
        if is_order_type_enabled() == false
        {
            list_fillter!.list_items.append([options_choose.title_prefex:"End of day Order type summary"
                             ,options_choose.obj_prefex:"End of day Order type summary"])
        }
            
                
                list_fillter!.list_items.append([options_choose.title_prefex:"End of day Sales summary"
                                 ,options_choose.obj_prefex:"End of day Sales summary"])
                
                list_fillter!.list_items.append([options_choose.title_prefex:"Sales summary"
                                 ,options_choose.obj_prefex:"Sales summary"])
                
                   
               }
               
                
               list_fillter!.didSelect = { [weak self] data in
                   self!.selected_fillter = data as! [String]
 
               
                
                
                let setting = SharedManager.shared.appSetting()
                let json =    setting.sales_report_filtter
                var dic_fillter = json.toDictionary() ?? [:]
                
                dic_fillter["selected_fillter"] = self!.selected_fillter
                setting.sales_report_filtter = dic_fillter.jsonString()  ?? ""
                setting.save()
                
                
                
 
                   self!.loadReport()
        
               }
               
               
               self.present(list_fillter!, animated: true, completion: nil)
    }
    
    
    // ===================================================================
    
    func get_selected_pos() -> [Int]
    {
        var lst_pos:[Int] = []
        
        for item in selected_poss
        {
            lst_pos.append(item.id)
        }
         
        return lst_pos
    }
    
    func loadReport()
    {
        
        indc?.startAnimating()
        
        let dt = start_date
        let dt_start_date = Date(strDate: dt!, formate: date_formate,UTC: true)
        let str_start_date = dt_start_date.toString(dateFormat: "yyyy-MM-dd", UTC: true)
        
        let dt_end_date = Date(strDate: end_date!, formate:date_formate,UTC: true)
        let str_end_date = dt_end_date.toString(dateFormat: "yyyy-MM-dd", UTC: true)
        
         
        
        con.userCash = .stopCash
        con.get_ios_get_summary_reports(from_date: str_start_date, to_date: str_end_date, pos_config_ids: selected_pos_ids) { (result) in
            if (result.success)
            {
                
                
                let dic = result.response?["result"] as? [String:Any] ?? [:]
                if !dic.isEmpty
                {
                    let rows :NSMutableString = NSMutableString()
                    
                    let payment_summary = dic["payment_summary"]  as? [[String:Any]] ?? []
                    let order_type_summary = dic["order_type_summary"] as? [[String:Any]] ?? []
                    let sales_summary = dic["sales_summary"] as? [[String:Any]] ?? []
//                    let product_summary = dic["product_summary"] as? [[String:Any]] ?? []
                    
                    let order_summary = dic["order_summary"] as? [String:Any] ?? [:]
                    
                    
                    
                    rows.append(self.payment_summary_html(  payment_summary))
                    rows.append(self.order_type_summary_html(  order_type_summary))
                    rows.append(self.sales_summary_html(  sales_summary))
                    rows.append(self.order_summary_html(  order_summary))
                    
                    
                    self.loadReport(rows: String(rows))
                }
                
            }else
            {
//                MessageView.show("Check your internet connection.", vc: self)
            }
            
            self.indc?.stopAnimating()
        }
        
    }
    
    func apply_fillter(key:String) -> Bool
    {
        if self.selected_fillter.count == 0
        {
            return true
        }
        
        if self.selected_fillter.contains(key) == false
        {
            return false
        }
        
        return true
    }
    
    
    
    func loadReport(rows:String)
    {
        var html = baseClass.get_file_html(filename: "z_report",showCopyRight: true)
        html = printOrder_setHeader(html: html)
        
        html = html.replacingOccurrences(of: "#rows_total", with: rows)
        
        html = html.replacingOccurrences(of: "#font", with: app_font_name_printer + "-Regular")
        
//        let pos = SharedManager.shared.posConfig()
        
        html = html.replacingOccurrences(of: "#title", with: custom_header ?? "")
//        html = html.replacingOccurrences(of: "#header", with: pos.receipt_header!)
        html = html.replacingOccurrences(of: "#header", with: "")

        
        self.webView.loadHTMLString( html, baseURL:  Bundle.main.bundleURL)
        
    }
    
    func printOrder_setHeader(html: String) -> String {
        let rows_header:NSMutableString = NSMutableString()
        
        
        rows_header.append(" <tr><td>From</td><td>: </td><td> \(start_date! )</td></tr>")
        rows_header.append(" <tr><td>To</td><td>: </td><td> \(end_date! )</td></tr>")
        rows_header.append(" <tr><td>POS</td><td>: </td><td> \(selected_pos_str  )</td></tr>")

        
        return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
    
    
    @IBAction func btnPrint(_ sender: Any) {
        self.print()
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
    
    
    func payment_summary_html(_ arr:[[String:Any]]) -> String
    {
        guard apply_fillter(key: "End of day Payment summary") == true else {
            return ""
        }
        
        guard arr.count != 0 else {
            return ""
        }
        
        SharedManager.shared.printLog("payment_summary_html")
        
        let rows :NSMutableString = NSMutableString()
        
        var all_Payment = 0.0
        
        
        rows.append("<br /><table style=\"width: 100%;text-align: left; border: 4px solid black; padding: 20px\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> "+"End of day Payment summary".arabic("ملخص الدفع بنهاية اليوم")+" </u> </h3>  </td>    </tr>")
        
        for i in 0...arr.count - 1
        {
            let dic  = arr[i]
            let name = dic["journal"] as? String ?? ""
            let total = dic["amount"] as? Double ?? 0
            
            rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:right;\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
            
            all_Payment = all_Payment + total
        }
        
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>"+"End of day Payment summary".arabic("ملخص الدفع بنهاية اليوم")+"</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        
        rows.append("</table>")
        return String(rows)
    }
    
    
    func order_type_summary_html(_ arr:[[String:Any]]) -> String
    {
        if is_order_type_enabled() == false
        {
            return ""
        }
        guard apply_fillter(key: "End of day Order type summary") == true else {
            return ""
        }
        
        guard arr.count != 0 else {
            return ""
        }
        
        SharedManager.shared.printLog("total_Payment_html")
        
        let rows :NSMutableString = NSMutableString()
        
        var all_Payment = 0.0
        
        
        rows.append("<br /><table style=\"width: 100%;text-align: left; border: 4px solid black; padding: 20px\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> "+"End of day order type summary".arabic("ملخص نوع الطلب بنهاية اليوم")+" </u> </h3>  </td>    </tr>")
        
        for i in 0...arr.count - 1
        {
            let dic  = arr[i]
            let name = (dic["order_type"] as? String ?? "") + (dic["journal"] as? String ?? "")
            let total = dic["amount"] as? Double ?? 0
            
            rows.append("<tr> <td> \(name) </td>  <td>   </td> <td style=\"text-align:right;\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
            
            all_Payment = all_Payment + total
        }
        
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>"+"End of day order type summary".arabic("ملخص نوع الطلب بنهاية اليوم")+"</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        
        rows.append("</table>")
        return String(rows)
    }
    
    func sales_summary_html(_ arr:[[String:Any]]) -> String
    {
        guard apply_fillter(key: "End of day Sales summary") == true else {
                   return ""
               }
        
        guard arr.count != 0 else {
            return ""
        }
        
        SharedManager.shared.printLog("sales_summary")
        
        let rows :NSMutableString = NSMutableString()
        
        var all_Payment = 0.0
        
        
        rows.append("<br /><table style=\"width: 100%;text-align: left; border: 4px solid black; padding: 20px\">")
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> "+"End of day sales summary".arabic("ملخص المبيعات بنهاية اليوم")+" </u> </h3>  </td>    </tr>")
        
        for i in 0...arr.count - 1
        {
            let dic  = arr[i]
            let name = (dic["order"] as? String ?? "")
            let count = (dic["count"] as? String ?? "")
            let total = dic["amount"] as? Double ?? 0
            
            rows.append("<tr> <td> \(name) </td>  <td> \(count)  </td> <td style=\"text-align:right;\">   \(String( total.rounded_formated_str(max_len: 12))) </td> </tr>")
            
            all_Payment = all_Payment + total
        }
        
        
        rows.append("<tr> <td> <h5 style=\"line-height: 0%\"> <u>"+"End of day sales summary".arabic("ملخص المبيعات بنهاية اليوم")+"</u> </h5>  </td>  <td>   </td> <td style=\"text-align:right;\"> <h5 style=\"line-height: 0%\">  \(all_Payment.rounded_formated_str(max_len: 12))  </h5>  </td> </tr>")
        
        rows.append("</table>")
        return String(rows)
    }
    
    func order_summary_html(_ dic:[String:Any]) -> String
    {
        guard apply_fillter(key: "Sales summary") == true else {
                    return ""
                }
        
        
        guard dic.values.count != 0 else {
            return ""
        }
        
        let rows :NSMutableString = NSMutableString()
        
        let total_amount = dic["total_amount"] as? Double ?? 0
        let total_tax = dic["total_tax"] as? Double ?? 0
        let total_untaxed = dic["total_untaxed"] as? Double ?? 0
        
        
        rows.append("<br /><table style=\"width: 100%;text-align: left; border: 4px solid black; padding: 20px\">")
        
        rows.append("<tr>  <td colspan=\"3\">   <h3 style=\"line-height: 0%\"> <u> "+"Sales summary".arabic("ملخص المبيعات")+" </u> </h3>  </td>    </tr>")
        
        rows.append("<tr> <td> "+"Total with tax".arabic("الاجمالي بالضريبة")+"  </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_amount.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> "+"Total w\\o Tax".arabic("الاجمالي بدون الضريبة")+"  </td>  <td> </td> <td style=\"text-align:right;\">   \(   total_untaxed.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        rows.append("<tr> <td> "+"Tax".arabic("الضريبة")+" </td>  <td> </td> <td style=\"text-align:right;\">   \(  total_tax.rounded_formated_str(max_len: 12,always_show_fraction: true) ) </td> </tr>")
        
        
        
        rows.append("</table>")
        
        
        return String(rows)
        
    }
}
