//
//  products_rang_report2.swift
//  pos
//
//  Created by khaled on 01/04/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import WebKit

class driver_report: ReportViewController  {
    
 
    @IBOutlet weak var container: UIView!
 
 

    
    var webView: WKWebView!
 

    
 
    var indc: UIActivityIndicatorView?
    
     @IBOutlet var btn_filtter: UIButton!
    
    
    var dictionary = [Int:[pos_order_line_class]]()
 
    
 

    var option   = ordersListOpetions()
    var selected_dic:[String:Any] = [:]

    
    //let date_formate = "dd/MM/yyyy"
    let date_formate = "yyyy-MM-dd hh:mm a"
    
    var start_date:String = ""
    var end_date:String = ""
    var shift_name:String = "By Time"
    
    var   html:String = ""
    
    var custom_header:String?
    var groupByReturnOrder:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
  
        
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
        
        //let start_date =   baseClass.get_date_local_to_search(DateOnly: date, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss")
        //let endDaty_str = baseClass.get_date_local_to_search(DateOnly: date, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss",addHours: 24)
        
        let start_date =   baseClass.get_date_local_to_search(DateOnly: date, format: date_formate ,returnFormate: date_formate)
        let endDaty_str = baseClass.get_date_local_to_search(DateOnly: date, format: date_formate ,returnFormate: date_formate,addHours: 24)
        
        option.between_start_session?.append(start_date)
        option.between_start_session?.append(endDaty_str)
    }
    
    
    
    func loadReport( )
    {
 
 
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
 
    func printOrder_html() -> String {
        
        
        var html = baseClass.get_file_html(filename: "driver",showCopyRight: true)
//        let pos = SharedManager.shared.posConfig()
        
        var header = "" //pos.receipt_header
        if custom_header != nil
        {
            header = "  \(custom_header!)  " +  header
            
        }
         html = html.replacingOccurrences(of: "#header", with: header)
        
        
 
        html = html.replacingOccurrences(of: "#font", with: app_font_name_printer + "-Regular")
        showActivityIndicator()
        
        html = printOrder_setHeader(html: html)
        html = html.replacingOccurrences(of: "#rows_order", with: "")
        html = build_report(html: html)
        
        if LanguageManager.currentLang() == .ar
        {
            
            html = html.replacingOccurrences(of: "#dir", with:   "dir=\"rtl\"")
            html = html.replacingOccurrences(of: "text-align: left", with:   "text-align: right")


        }
        else
        {
            html = html.replacingOccurrences(of: "#dir", with:   "dir=\"ltr\"")


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
        
        
 
        return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
 
    
    func footer_section(qty:Double , amount:Double) -> String
    {
 
        
        let rows_order:NSMutableString = NSMutableString()

 
        rows_order.append(" <tr><td><h3 style=\"line-height: 5px;\">Total</h3></td><td><h3 style=\"line-height: 5px;\">\(qty.toIntString())</h3></td><td><h3 style=\"line-height: 5px;\">\(amount.toIntString())</h3></td></tr>")
         
        return String( rows_order)
    }
    
    func build_report(html: String) -> String
      {
        
                let query = get_query()
                let arr_data = query.result
 
                let rows_order:NSMutableString = NSMutableString()
        
           
 
                rows_order.append("<tr>  <td><h3 style=\"line-height: 5px;width:60%;text-align: left;\">"+"Name".arabic("الاسم")+"</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">"+"Qty".arabic("الكمية")+"</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">"+"Amount".arabic("الاجمالى")+"</h3></td> <td style=\"width: 20% \"><h3 style=\"line-height: 5px;\">"+"Cost".arabic("التكلفة")+"</h3></td>  </tr>")
//        rows_order.append(" <tr><td colspan=\"3\" align=\"center\"> <hr style=\"border: 2px dashed black;\"></td></tr>")

        var total_all:Double = 0
        var qty_all:Double = 0
        var total_all_cost:Double = 0


                if arr_data.count > 0
                {
        
                for i in 0...arr_data.count - 1
                {
                    let row = arr_data[i]
                   let driver_name = row["name"] as? String ?? ""
                   let qty = row["cnt"] as? Double ?? 0
                    let total = row["total"] as? Double ?? 0
                    let driver_cost = row["driver_cost"] as?  Double ?? 0
                    qty_all = qty_all + qty
                    total_all = total_all + total
                    let total_cost = driver_cost * qty
                     total_all_cost += total_cost

//                    rows_order.append(" <tr><td style=\"line-height: 5px;width: 60%;text-align: left;\">\(driver_name) </td><td style=\"width: 20% \"> \(qty.toIntString())</td><td style=\"width: 20% \"> \( total.toIntString())</td></tr>")
                    
                    rows_order.append(" <tr><td style=\"width: 60%;text-align: left;\">\(driver_name) </td><td style=\"width: 20% \"> \(qty.toIntString())</td></td><td style=\"width: 20% \"> \(total.toIntString())</td><td style=\"width: 20% \"> \( total_cost.toIntString())</td></tr>")

 
                }
                    
                }
        
//        rows_order.append(" <tr><td colspan=\"3\" align=\"center\"> <hr style=\"border: 2px dashed black;\"></td></tr>")
        
//        rows_order.append(" <tr><td><h3 style=\"line-height: 5px;width:60%;text-align: left;\">\("Total".arabic("الاجمالى"))</h3> </td><td><h3 style=\"line-height: 5px;\">\(qty_all.toIntString())</h3></td><td><h3 style=\"line-height: 5px;\"> \( total_all.toIntString())</h3></td></tr>")
        
        rows_order.append(" <tr><td><h3 style=\"line-height: 5px;width:60%;text-align: left;\">\("Total".arabic("الاجمالى"))</h3> </td><td><h3 style=\"line-height: 5px;\">\(qty_all.toIntString())</h3></td><td><h3 style=\"line-height: 5px;\"> \( total_all.toIntString())</h3></td><td><h3 style=\"line-height: 5px;\"> \( total_all_cost.toIntString())</h3></td></tr>")


        
        return html.replacingOccurrences(of: "#rows_total", with: String(rows_order))
    }
     
    
    func get_query() -> (result:[[String : Any]],filter_session:String)
    {
        var condation = " and pos_order.amount_total > 0 "
        let pos = SharedManager.shared.posConfig()
        var sessions = ""
        if (option.sesssion_id) != 0 {
            sessions = "\(option.sesssion_id)"
        }else{
            let options_session = posSessionOptions()
            
            options_session.between_start_session = option.between_start_session
            //        options_session.between_start_session = option.between_start_session
            
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
        if groupByReturnOrder {
            condation = " and pos_order.parent_order_id  !=  0 "
        }
        
       
        let sql = """

          SELECT  count(*) as cnt , sum(amount_total) as total ,  sum(driver_cost) as total_cost, pos_driver.id ,pos_driver.name,pos_driver.driver_cost from (select * from pos_order WHERE driver_id != 0 and is_void = 0 \(condation) and pos_order.is_closed = 1 and pos_order.session_id_local  in (\(sessions)) and pos_order.write_pos_id  = \(pos.id)
          )  as orders
          inner join pos_driver
          on pos_driver.id  = orders.driver_id
          GROUP by  orders.driver_id
           

        """

        let cls = pos_order_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        
        return (arr,sessions)
        
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
