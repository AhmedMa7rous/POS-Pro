//
//  reportsBuilderViewController.swift
//  pos
//
//  Created by khaled on 03/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit
import WebKit

class reportsBuilderViewController: ReportViewController ,WKNavigationDelegate {

    @IBOutlet var btnStartDate: UIButton!
    @IBOutlet var btnSelectShift: UIButton!
    @IBOutlet weak var container: UIView!

    var indc: UIActivityIndicatorView?
    var webView: WKWebView!

    var start_date:String?
     
    var delegate : zReport_delegate?
    var custom_header:String?

    
    var allPOS:[String:salesReportSummary] = [:]
    var requestedCount:Int = 0
    
    var selectedReportType:reportsList = .salesReportSummary
    
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
        
        start_date = Date().toString(dateFormat: "yyyy-MM-dd", UTC: false)

        getLastBussinusDate()
        
        self.btnSelectShift.setTitle("Summary", for: .normal)
        
        SharedManager.shared.initalMultipeerSession()

        
         NotificationCenter.default.addObserver(self, selector: #selector( methodOfReceivedNotification(notification:)), name: Notification.Name("requestReport"), object: nil)

    }
    
    
 
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        SharedManager.shared.disCounectMultiPeer()

        NotificationCenter.default.removeObserver(self, name:Notification.Name( "requestReport"), object: nil)

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
    
    @IBAction func btnSelectShift(_ sender: Any) {
        
        let list = options_listVC()
        list.modalPresentationStyle = .formSheet
        
        list.list_items.append([options_listVC.title_prefex:"All"])
        
//        let options = posSessionOptions()
//
//        options.between_start_session = [reportBuilderHelper.get_start_date(start_date),reportBuilderHelper.get_end_date(start_date)]
//
//
//        let arr: [[String:Any]] =    pos_session_class.get_pos_sessions(options: options)
//        for item in arr
//        {
//            var dic = item
//            let shift = pos_session_class(fromDictionary: item)
//
//            let dt = Date(strDate: shift.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
//            let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
//
//            let title = String( shift.id ) + " - " + startDate
//            dic[options_listVC.title_prefex] = title
//
//            list.list_items.append(dic)
//
//        }
        
        list.list_items.append([options_listVC.title_prefex:"Summary"])


        list.didSelect = { [weak self] data in
            let dic = data
            let title = dic[options_listVC.title_prefex] as? String ?? ""
            if title == "All"
            {
//                self!.shift_id = nil
                self!.btnSelectShift.setTitle("All", for: .normal)
                self!.btnSelectShift.tag = 0
                self!.selectedReportType = .salesReport

            }
            else if title == "Summary"
            {
//                self!.shift_id = nil
                self!.btnSelectShift.setTitle("Summary", for: .normal)
                self!.btnSelectShift.tag = 1
                self!.selectedReportType = .salesReportSummary
            }
//            else
//            {
//                self!.shift_id = dic["id"] as? Int
//                self!.btnSelectShift.setTitle(title, for: .normal)
//                self!.btnSelectShift.tag = 2
//
//            }
            
            self?.requestReport(self!.selectedReportType)
        }
          
        
        list.clear = {
//            self.shift_id = nil
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
            
//            self!.shift_id = nil
//             self!.btnSelectShift.setTitle("All", for: .normal)
            
            
            self?.requestReport(self!.selectedReportType)
              
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
    
    
    
    
    func loadReport(html:String)   {
         
         
        showActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
          
            DispatchQueue.main.async { [self] in
                
//                let bulider = reportsBuilder()
//                let html =  bulider.build(_report: .salesReport, forDay: self.start_date!)
//                SharedManager.shared.printLog( html)
                self.webView.loadHTMLString(  html, baseURL: Bundle.main.bundleURL)
                
                hideActivityIndicator()
                
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
    
    
    func requestReport(_ _report:reportsList)
    {
        self.webView.loadHTMLString(  "", baseURL: Bundle.main.bundleURL)

        requestedCount =  SharedManager.shared.multipeerSession()?.requestSalesReport(_report: _report,  forDay: self.start_date!) ?? 0
        
        if requestedCount != 0
        {
            showActivityIndicator()
        }
        else
        {
            
            messages.showAlert("No Devices connected.",vc:self)
           getReportLocal()
        }
        
    }
    
    
    func getReportLocal()
    {
        var isSummary = false
        if selectedReportType == .salesReportSummary
        {
            isSummary = true
        }
        
        
        let bulider = reportsBuilder()

        let rpt = bulider.requestReport(_report: .salesReport, forDay: self.start_date!)
        let html = bulider.printSalesReport(rpt!,isSummary: isSummary)
 
        loadReport(html: html)
        
 

    }
    
    func getAllReportsSummary() -> [salesReportSummary]
    {
        var list :[salesReportSummary] = []
        
        for (_,value) in allPOS
        {
            list.append(value)
        }
        
        return list
    }
    
    @objc func methodOfReceivedNotification(notification: NSNotification) {
     
        let data = notification.object as? [String:Any] ?? [:]

        if data.isEmpty
        {
            return
        }
        
        let rpt_received = salesReportSummary(fromDictionary: data)
        
        let bulider = reportsBuilder()
        let local_rpt = bulider.requestReport(_report: .salesReport, forDay: self.start_date!)
        allPOS[local_rpt!.posName!] = local_rpt
 
        allPOS[rpt_received.posName!] = rpt_received
        
//        if ((requestedCount + 1) == allPOS.keys.count)
//        {
//            let bulider = reportsBuilder()
            var html = ""
            
             if selectedReportType == .salesReportSummary
            {
 
                let sum_rpt = bulider.sumReports(getAllReportsSummary())
                html = bulider.printSalesReport(sum_rpt,isSummary: true)

            }
            else if selectedReportType == .salesReport
            {
                let allReports = getAllReportsSummary()
                
                let sum_rpt = bulider.sumReports(allReports)
                
                for rpt_temp in allReports
                {
                    let sum_forPOS = bulider.sumReports([rpt_temp])

                    sum_rpt.subReports.append(  sum_forPOS)
                }
 
                  html = bulider.printSalesReport(sum_rpt,isSummary: false)

            }
            
            
            loadReport(html: html)

//        }
        
        
        
    }

    
    @IBAction func btnConnectedDevices(_ sender: Any) {
        
        let vc = connectedDevicesViewController()
        
        parent_vc?.present(vc, animated: true, completion: nil)
    }
    
}
