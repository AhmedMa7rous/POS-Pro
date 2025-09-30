//
//  connectionLog_list.swift
//  pos
//
//  Created by Khaled on 12/10/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit

class printer_log_list: baseViewController ,UISearchBarDelegate,WKNavigationDelegate {
    var refreshControl_tableview = UIRefreshControl()
    @IBOutlet weak var txt_search: UISearchBar!

    @IBOutlet weak var view_log: UIView!
    @IBOutlet var tableview: UITableView!
    
    var list_items_org:  [Any]! = []
    var list_items:  [Any]! = []

    var webView: WKWebView!

    @IBOutlet weak var txt_log: UITextView!
    @IBOutlet var seqError: UISegmentedControl!
    
    var selected_log:printer_log_class?
    var log_str :String = ""

    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        
//        list_items = nil
//        list_items_org = nil
//        tableview = nil
    }
    
    override func viewDidLoad() {
        stop_zoom = true
        super.viewDidLoad()

      initRefresh()
        
        refreshOrder(sender: nil)
        setupWebView()
        txt_log.text = ""
        if LanguageManager.currentLang() == .ar {
            seqError.setTitle("الكل", forSegmentAt: 0)
            seqError.setTitle("خطأ", forSegmentAt: 1)
        }
        
     }
    
    func setupWebView()
    {
     
        var currency = ""
        if SharedManager.shared.posConfig().currency_name?.lowercased().contains("sar") ?? false {
            currency = "Saudi"
        }
        let js = "window.appCurrency = '\(currency)';"
        let userScript = WKUserScript(
          source: js,
          injectionTime: .atDocumentStart,
          forMainFrameOnly: true
        )
        
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame:view_log.bounds, configuration: webConfiguration)
        webView.configuration.userContentController.addUserScript(userScript)
        webView.navigationDelegate = self
     
//        webView.frame.origin.x = -10
        //        webView.uiDelegate = self
        webView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        //        webView.frame = container.bounds
        view_log.addSubview(webView)
        webView.sizeToFit()
    }
    
    
    func initRefresh()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    @IBAction func seqChanged(_ sender: Any) {
        list_items.removeAll()
        list_items_org.removeAll()

        if seqError.selectedSegmentIndex == 0
        {
            list_items =  printer_log_class.getAll(limit: [0,1000])

  
        }
        else
        {
            let result  =  printer_log_class.search(print_sequence: "can''t",   limit: [0,1000])
             list_items.append(contentsOf: result)
        }
        
        list_items_org.append(contentsOf: list_items)

        self.tableview.reloadData()
        refreshControl_tableview.endRefreshing()
        
    }
    
    @objc func refreshOrder(sender:AnyObject?) {
        // Code to refresh table view
//        list_items = logDB.lstitems("con_log" ,limit: [0,10000] , orderASC: false)
        list_items =  printer_log_class.getAll(limit: [0,1000])
 
        list_items_org.append(contentsOf: list_items)
        
        self.tableview.reloadData()
        refreshControl_tableview.endRefreshing()
    }
    
    @IBAction func btnPrint(_ sender: Any) {
        if selected_log != nil
        {
            if selected_log!.order_id != 0
            {
              
                let storyboard = UIStoryboard(name: "OrdersDisplay", bundle: nil)
                let orderHistory = storyboard.instantiateViewController(withIdentifier: "order_history") as! order_history
                orderHistory.order_id = selected_log!.order_id
                self.navigationController?.pushViewController(orderHistory, animated: true)
            }
        }
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self .dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func btnClearAll(_ sender: Any) {
//        logDB.deletelstitems("con_log"  )
        printer_log_class.deleteAll(prefix: nil)
        
            refreshOrder(sender: nil)
        txt_log.text = ""
    }
    
    @IBAction func btnShare(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [log_str], applicationActivities: nil)
        activityVC.modalPresentationStyle = .popover
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        present(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            if completed  {
                activityVC.dismiss(animated: true, completion: nil)
            }
        }
    }
  
    
    func share() {
        let objectsToShare = [log_str]

        let activity = UIActivityViewController(activityItems:objectsToShare as [Any], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
}



extension printer_log_list: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let dic =   list_items[indexPath.row] as! [String:Any]
        selected_log = printer_log_class(fromDictionary: dic)
        
        let start_at:String =  Date(strDate: selected_log!.start_at!, formate: baseClass.date_formate_database,UTC: true).toString(dateFormat: "dd/MM/yyyy hh:mm:ss a" , UTC: false)
        let stop_at:String =  Date(strDate: selected_log!.stop_at!, formate: baseClass.date_formate_database,UTC: true).toString(dateFormat: "dd/MM/yyyy hh:mm:ss a" , UTC: false)
        var str:String = selected_log!.status! + "\n" +  selected_log!.print_sequence!
         str = str.replacingOccurrences(of: "\\n", with: "\n")
        
        log_str = "Start : \(start_at) \n Stop : \(stop_at ) \n Wifi SSID : \(selected_log?.wifi_ssid ?? "") \n Printer name : \(selected_log?.printer_name ?? "") \n Printer ip : \(selected_log?.ip ?? "") \n \(selected_log?.row_type?.rawValue ?? "") \n---------------------------------\n \(str) "
        self.txt_log.text  =  log_str
//        imageView.isHidden = true
//        webView.isHidden = true

        if (selected_log?.html ?? "").contains("FILE_NAME:"){
            if let file_name = selected_log?.html?.replacingOccurrences(of: "FILE_NAME:", with: "") {
                if let image_printer = FileMangerHelper.shared.getFile(from: APP_FOLDERS.printer_erro, with:file_name) {
//                    imageView.isHidden = false
//                    webView.isHidden = true
                    let imageData = image_printer.pngData()
                    let base64String = imageData?.base64EncodedString() ?? "" // Your String Image
                    let strHtml = "<html><body><p></p><p><b><img src='data:image/png;base64,\(String(describing: base64String) )'></b></p></body></html>"
                    webView.loadHTMLString(strHtml, baseURL: Bundle.main.bundleURL)

//                    imageView.image = image_printer
                }
            }
        }else
        if !(selected_log?.html ?? "").isEmpty{
//            imageView.isHidden = true
//            webView.isHidden = false
            webView.loadHTMLString(selected_log?.html ?? "", baseURL: Bundle.main.bundleURL)
        }
 

     
 

        
     }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! printer_log_listTableViewCell
        
        let obj =   list_items[indexPath.row] as! [String:Any]
        let log = printer_log_class(fromDictionary: obj)
       

        cell.lbl_id.text =  String( log.id  )
        cell.lblName.text =  log.ip! + " / order:" + String( log.order_id) + " / " + log.row_type!.rawValue
        
        if (log.print_sequence ?? "").lowercased().contains("can't")
        {
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            cell.layer.borderColor = UIColor.clear.cgColor

        }
        
        return cell
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!searchText.isEmpty){
          
            let result  =  printer_log_class.search(any: searchText ,  limit: [0,1000] )
            list_items.removeAll()
            list_items.append(contentsOf: result)
        }
        else
        {
            list_items.removeAll()
            list_items.append(contentsOf: list_items_org)
        }
        
        tableview.reloadData()
    }
    
    @IBAction func btn_reprint(_ sender: Any) {
        
        if selected_log != nil
        {
            re_print(IP: selected_log!.ip ?? "", printer_name: selected_log!.printer_name ?? "" , html: selected_log!.html ?? "")
        }
        else
        {
            messages.showAlert("Please select log.")
        }
    }
    func re_print(IP:String ,printer_name:String,html:String)
    {
 
        var id = -1
        for (key,value) in SharedManager.shared.printers_pson_print
        {
            if value.IP == IP
            {
                id = key
                
                break
            }
        }
        
        if id == -1
        {
            let printer = restaurant_printer_class.get(ip: IP)
            if printer != nil
            {
                id = printer!.id
            }
        }
        
        if id == -1
        {
            messages.showAlert("Printer not exist.")

            return
        }
        
        let printer = SharedManager.shared.printers_pson_print[id] ?? epson_printer_class(IP: IP,printer_name: printer_name,printer_id: id )
        
        
        let jobPrinter = job_printer()
        jobPrinter.type = .image
        jobPrinter.html = html
        jobPrinter.time = baseClass.getTimeINMS()
        
        
        printer.addToQueue(job: jobPrinter,index:0)

        
        SharedManager.shared.printers_pson_print[id] = printer
        SharedManager.shared.epson_queue.run()

    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        webView.evaluateJavaScript("applyCurrency(window.appCurrency || '');", completionHandler: nil)
        if(webView.isLoading){
            return
        }
    }
}
