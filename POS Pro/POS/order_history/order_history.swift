//
//  order_history.swift
//  pos
//
//  Created by khaled on 9/26/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import WebKit
import MobileCoreServices

class order_history: baseViewController ,invoicesList_delegate ,WKNavigationDelegate ,UISearchBarDelegate  {
    
    @IBOutlet var view_orderList: UIView!
    @IBOutlet var view_orderDetials: UIView!
    
    @IBOutlet var seq: UISegmentedControl!
    var lstInvoices:invoicesList? // = invoicesList()
    //    var orderVc = order_listVc()
    var orderSelected:pos_order_class?
    var webView: WKWebView!
    @IBOutlet weak var view_buttons: UIView!
    
    @IBOutlet weak var btnPrint: KButton!
    @IBOutlet weak var btnSync: KButton!
    @IBOutlet weak var btnReturn: KButton!
    @IBOutlet weak var btnLog: KButton!
    @IBOutlet var btnSelectShift: UIButton!
    
    var order_print:orderPrintBuilderClass!
    
    var webViewPDF:WKWebView?
    
    
    //     @IBOutlet var btnCloseSearch: UIButton!
    
    @IBOutlet weak var txt_search: UISearchBar!
    var html_temp = ""
    
    var order_name:String?
    var order_id:Int?
    
    
    weak var order_print_att:NSAttributedString?
    var    filtter:HistorySearchFilterViewController?
    
    var returnorder =  return_orders()
    
    
    let date_formate = "dd/MM/yyyy"
    
    var sesssion_ids:String?
    
    var start_date:String?
    var end_date:String?
    var otherPrinter:printersNetworkAvalibleClass?

    @IBOutlet var btnEndDate: UIButton!
    @IBOutlet var btnStartDate: UIButton!
    //    @IBOutlet var btnFillter: KButton!
    
    
    
    enum index_seq:Int {
        case CLOSED = 0,Pending=1,Void=2,Rejected=3,TIME_OUT=4,Delete=5,Insurance=6,All=7
//        case Synced = 0,Paid = 1,Pending=2,Void=3,Rejected=4,Delete=5,All=6
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        order_print_att = nil
        lstInvoices = nil
        orderSelected = nil
        webView = nil
        html_temp = ""
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedManager.shared.updateLastActionDate()
        otherPrinter = printersNetworkAvalibleClass()
        //           btnCloseSearch.isHidden = true
        
        self.initOrderList()
        //        initViewOrderList()
        self.setupWebView()
        self.hideAllBtns()
        DispatchQueue.main.async {
//            let font_medium = UIFont.init(name: "HelveticaNeue-Medium", size: 17)
//            let font_regular = UIFont.init(name: "HelveticaNeue", size: 17)
            //            self.seq.setTitleTextAttributes([.foregroundColor: UIColor.init(named: "#9D9D9D") , NSAttributedString.Key.font: font_regular!], for: .normal)
            //            self.seq.setTitleTextAttributes([.foregroundColor: UIColor.init(named: "#5F5F5F") , NSAttributedString.Key.font: font_medium!], for: .selected)
            self.seq.frame = CGRect(origin: self.seq.frame.origin, size: CGSize(width: self.seq.frame.size.width, height: 50))
            self.seq.backgroundColor = .lightText
            
            if LanguageManager.currentLang() == .ar {
                self.seq.setTitle("تمت", forSegmentAt: index_seq.CLOSED.rawValue)
                self.seq.setTitle("معلق", forSegmentAt: index_seq.Pending.rawValue)
                self.seq.setTitle("ملغي", forSegmentAt: index_seq.Void.rawValue)
                self.seq.setTitle("مرفوض", forSegmentAt: index_seq.Rejected.rawValue)
                self.seq.setTitle("منتهي", forSegmentAt: index_seq.TIME_OUT.rawValue)
                self.seq.setTitle("محذوفة", forSegmentAt: index_seq.Delete.rawValue)
                self.seq.setTitle("الكل", forSegmentAt: index_seq.All.rawValue)
                self.seq.setTitle("تآمين", forSegmentAt: index_seq.Insurance.rawValue)

            }
        }
        
        DispatchQueue.main.async {
            self.getLastBussinusDate()
        }
        // initalWithAllFilter()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            
            if self.order_name != nil
            {
                self.seq.selectedSegmentIndex = index_seq.Rejected.rawValue
                //            txt_search.text = order_number
                self.seq_changed(AnyClass.self)
                
                self.lstInvoices!.option.name = self.order_name
                self.lstInvoices?.currentPage = 0
                self.lstInvoices!.getList()
            }
            else if self.order_id != nil
            {
                self.seq.selectedSegmentIndex = index_seq.Rejected.rawValue
                self.seq_changed(AnyClass.self)
                
                self.lstInvoices!.option.parent_order = nil
                self.lstInvoices!.option.orderID = self.order_id
                self.lstInvoices?.currentPage = 0
                
                self.lstInvoices!.getList()
            }
            self.lstInvoices?.refreshOrder(sender:nil)
            self.lstInvoices?.reloadTable()
        }
    }
    
    func sentToKitchen(){
        if orderSelected == nil {
            return
        }
        //[Feature]Reprint to kds-printers
        orderSelected!.pos_order_lines.forEach { posLine in
            if !(posLine.is_void ?? false) {
                posLine.printed = .none
                posLine.last_qty = 0
                posLine.save()
            }
        }
        pos_order_helper_class.increment_print_count(order_id: orderSelected!.id ?? 0)
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
            orderSelected!.creatKDSQueuePrinter(.kds,isResend: true)
            MWRunQueuePrinter.shared.startMWQueue()
        }else{
            let ord = self.otherPrinter?.prepear_order(order: orderSelected! ,reReadOrder: true)
            self.otherPrinter!.printToAvaliblePrinters(Order: ord)
            SharedManager.shared.epson_queue.run()
        }
        if SharedManager.shared.mwIPnetwork {
            orderSelected!.sent_order_via_ip(with: IP_MESSAGE_TYPES.RE_SEND)
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
        
        webView = WKWebView(frame:view_orderDetials.bounds, configuration: webConfiguration)
        webView.configuration.userContentController.addUserScript(userScript)
        webView.navigationDelegate = self
        webView.frame.origin.x = -10
        //        webView.uiDelegate = self
        webView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        //        webView.frame = container.bounds
        view_orderDetials.addSubview(webView)
        webView.sizeToFit()
    }
    
    //    func webView(_ webView: WKWebView,
    //                 didFinish navigation: WKNavigation!){
    //
    //        //        if print_inOpen == true
    //        //        {
    //        //            self.perform(#selector(print), with: nil, afterDelay: 1)
    //        //
    //        //        }
    //    }
    
    
    func get_sub_orders() -> [pos_order_class]
    {
        let option = ordersListOpetions()
        //        option.Closed = orderSelected!.is_closed
        option.void = false
        //        option.Sync = orderSelected!.is_sync
        option.parent_orderID = orderSelected!.id
        option.LIMIT = Int(page_count)
        option.parent_product = true
        
        let list_sub = pos_order_helper_class.getOrders_status_sorted(options: option)
        
        return list_sub
    }
    func getPosHTML(_ hideLogo:Bool = true) -> String{
        order_print.isCopy = true
        
        let setting = SharedManager.shared.appSetting()
        
        order_print.qr_print = true //setting.qr_enable
        order_print.qr_url = setting.qr_url
        order_print.hideLogo = hideLogo
      //  order_print.for_waiter =  seq.selectedSegmentIndex == index_seq.Pending.rawValue
        order_print.for_waiter = false
        order_print.showOrderReference = false
        if orderSelected?.containeInsuranceLines() ?? false{
            order_print.for_insurance = true
        }
        return order_print.printOrder_html()
    }
    func loadSeletedOrder()
    {
        
        
        let list_sub:[pos_order_class]  =  get_sub_orders()
        orderSelected?.sub_orders = list_sub
        
        
        
        
        if AppDelegate.shared.load_kds == false
        {
            if seq.selectedSegmentIndex == index_seq.Void.rawValue{
                html_temp = self.orderSelected?.getInvoiceHTML(.history_void, hideLogo: true) ?? "Cannot load invoice"

            }else{
                if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
                    html_temp = self.orderSelected?.getInvoiceHTML(.history, hideLogo: true) ?? "Cannot load invoice"
                }else{
                    order_print = orderPrintBuilderClass(withOrder: orderSelected!,subOrder: list_sub)
                    html_temp = getPosHTML()
                }
            }
        }
        else
        {
            order_print.hidePrice = true
            order_print.hideHeader = true
            order_print.hideFooter = true
            order_print.hideLogo = true
            order_print.hideRef = true
            order_print.hideVat = true
            order_print.hideCalories = true
            order_print.print_new_only = false
            order_print.for_kds = true
            order_print.isCopy = true
            order_print.showOrderReference = false
            
            
            let html = order_print.printOrder_html()
            
            html_temp = html
        }
        webView.loadHTMLString(html_temp, baseURL: Bundle.main.bundleURL)
    }
    func write(text: String, to fileNamed: String, folder: String = "SavedFiles") {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return }
        try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        let file = writePath.appendingPathComponent(fileNamed + ".txt")
        try? text.write(to: file, atomically: false, encoding: String.Encoding.utf8)
    }
    //    func initViewOrderList()
    //    {
    //
    //
    //        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
    //        orderVc = storyboard.instantiateViewController(withIdentifier: "order_listVc") as! order_listVc
    //        orderVc?.order = orderClass()
    //        orderVc?.enableEdit = false
    //
    //        orderVc?.view.frame = view_orderDetials.bounds
    //
    //
    //        view_orderDetials.addSubview(orderVc?.view)
    //
    //    }
    
    func initOrderList()
    {
        let storyboard = UIStoryboard(name: "invoicesList", bundle: nil)
        lstInvoices  = storyboard.instantiateViewController(withIdentifier: "invoicesList") as? invoicesList
        lstInvoices?.isEmbedded = true
        lstInvoices!.delegate = self
        lstInvoices!.enableEdit = false
        lstInvoices!.hide_seq = true
        
        lstInvoices!.option.Closed = true
        lstInvoices!.option.Sync = true
        lstInvoices!.option.parent_order = true
        
        //        lstInvoices.parent_id = nil
        
        
        lstInvoices!.view.frame = view_orderList.bounds
        
        view_orderList.addSubview(lstInvoices!.view)
        
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func order_selected(order_selected:pos_order_class)
    {
        orderSelected = order_selected
        loadSeletedOrder()
        
        handleBtns()
        
        //        if order_selected.isVoid == true ||   order_selected.isClosed == false
        //        {
        //            return
        //        }
        
        
    }
    
    func order_deleted(order_selected:pos_order_class)
    {
        
    }
    
    func handleBtns()
    {
        btnReturn.setTitle("Return".arabic("إرجاع"), for: .normal)
        btnReturn.tag = 0
        
        if AppDelegate.shared.load_kds
        {
            //            btnPrint.isHidden = false
            btnSync.isHidden = true
            btnLog.isHidden = true
            btnReturn.isHidden = true
            
            return
        }
        
        
        if seq.selectedSegmentIndex == index_seq.CLOSED.rawValue
        {
            
            //            btnPrint.isHidden = false
            btnSync.isHidden = false
            btnLog.isHidden = false
            btnReturn.isHidden = false
            
            
        }
        else if seq.selectedSegmentIndex == index_seq.Pending.rawValue
        {
            
            
            hideAllBtns()
            btnReturn.isHidden = false
            btnReturn.tag = 1
            btnReturn.setTitle("Move to my orders".arabic("نقل إلى طالباتي"), for: .normal)
            
            
            
        }
        else if seq.selectedSegmentIndex == index_seq.Void.rawValue
        {
            
            //            btnPrint.isHidden = true
            btnSync.isHidden = false
            btnLog.isHidden = false
            
        }
        else if seq.selectedSegmentIndex == index_seq.Delete.rawValue
        {
            
            //            btnPrint.isHidden = true
            btnSync.isHidden = false
            btnLog.isHidden = false
            
        }
        else if seq.selectedSegmentIndex == index_seq.Rejected.rawValue
        {
            
            
            //            btnPrint.isHidden = true
            btnSync.isHidden = true
            btnLog.isHidden = false
            btnReturn.isHidden = true
            
            
        }
        else if seq.selectedSegmentIndex == index_seq.TIME_OUT.rawValue
        {
            
            
            //            btnPrint.isHidden = true
            btnSync.isHidden = true
            btnLog.isHidden = false
            btnReturn.isHidden = true
        }  
        else if seq.selectedSegmentIndex == index_seq.Insurance.rawValue
        {
            
            //            btnPrint.isHidden = true
            btnSync.isHidden = true
            btnLog.isHidden = true
            btnReturn.isHidden = false

            
        }
        
        let user = SharedManager.shared.activeUser()
        let isUserCanReturn  = user.canAccessForAny(keies: [._return,.insurance_return])
       /* if   user.access_rules.firstIndex(where: {$0.key == ._return}) == nil
        {
            btnReturn.isEnabled = false
            btnReturn.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            
        }*/
        if   isUserCanReturn == nil
        {
            btnReturn.isEnabled = false
            btnReturn.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            
        }
        btnSync.isHidden = true
        
    }
    func hideAllBtns()
    {
        //        btnPrint.isHidden = true
        btnSync.isHidden = true
        btnLog.isHidden = true
        btnReturn.isHidden = true
    }
    
    @IBAction func seq_changed(_ sender: Any) {
        self.lstInvoices?.list_items.removeAll()
        self.lstInvoices?.tableview.reloadData()
        
        loadReport()
        self.lstInvoices?.refreshOrder(sender: nil)
        self.lstInvoices?.reloadTable()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        
        //           btnCloseSearch(AnyClass.self)
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        let txt = searchBar.text
        
        if txt == "" && searchBar.tag == 0
        {
            txt_search.resignFirstResponder()
            btnshowFiltter(AnyClass.self)
            
            searchBar.tag = 1
        }
        else  if txt != "" && searchBar.tag == 1
        {
            txt_search.resignFirstResponder()
            btnshowFiltter(AnyClass.self)
            
        }
        else  if txt == "" && searchBar.tag == 1
        {
            
            
            //                btnCloseSearch(AnyClass.self)
            
        }
        
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        txt_search.resignFirstResponder()
        
        
        //
        //        if(!searchText.isEmpty){
        //
        //            lstInvoices!.option.orderID_server = txt_search.text
        //
        //        }
        //        else
        //        {
        //             lstInvoices!.option.orderID_server = nil
        //        }
        //
        //        lstInvoices?.currentPage = 0
        //         lstInvoices!.getList()
    }
    
    
    func get_total_lines(lines:[pos_order_line_class],is_void:Bool?) -> Double
    {
        var total = 0.0
        for line in lines
        {
            if is_void != nil
            {
                if line.is_void == is_void
                {
                    total  += line.price_subtotal_incl!
                }
            }
            else
            {
                total  += line.price_subtotal_incl!
                
            }
            
        }
        
        return total
    }
    
    
    
    
    func check_lines_order(order:pos_order_class)
    {
        //       var final_lines:[pos_order_line_class] = []
        let total_lines = get_total_lines(lines:order.pos_order_lines,is_void: nil)
        
        if total_lines == order.amount_total
        {
            // remove void
            for line in order.pos_order_lines
            {
                line.is_void = false
            }
            
            //            final_lines.append(contentsOf: order.pos_order_lines)
        }
        else
        {
            if order.pos_order_lines.count > 0
            {
                for line in order.pos_order_lines
                {
                    line.is_void = true
                }
                
                let line =   order.pos_order_lines[0]
                line.is_void = false
                line.custom_price = order.amount_total
                line.update_values()
            }
            
        }
        
        //       return final_lines
    }
    
    func check_order_is_ok(order:pos_order_class) -> Bool
    {
        let total_lines = get_total_lines(lines: order.pos_order_lines, is_void: false)
        if total_lines == order.amount_total
        {
            return true
        }
        
        return false
    }
    
    func custom_fix()
    {
        
        let option =  ordersListOpetions()
        option.parent_product = true
        option.get_lines_void = true
        option.write_pos_id = SharedManager.shared.posConfig().id
        
        let orders_arr = pos_order_helper_class.getOrders_status_sorted(options: option)
        
        for order in orders_arr
        {
            
            if order.amount_total == 0
            {
                let paid_list =  order.get_bankStatement()
                for paid in paid_list
                {
                    order.amount_total += paid.due ?? 0
                }
                
            }
            
            if check_order_is_ok(order: order) == false
            {
                order.skip_order = false
                
                check_lines_order(order: order)
                
                order.save(re_calc: true)
            }
            
        }
        
        
    }
    
    @IBAction func fix_noc(_ sender: Any) {
        let pos = SharedManager.shared.posConfig()
        if pos.id == 69
        {
            let check_is_exist = pos_order_class.get(uid: "1599763090-C1-1711")
            if check_is_exist != nil
            {
                if check_is_exist?.is_sync == false
                {
                    _ =  database_class(connect: .database).runSqlStatament(sql: "update pos_order set write_pos_id  = 1 , write_pos_name = 'NocCafe [1]'  where is_closed  = 1 and is_sync = 0 and id <= 2055")
                    
                }
            }
        }
        
        lstInvoices!.getList()
        
    }
    
    @IBAction func fix_all_order(_ sender: Any) {
        
        
        custom_fix()
        
        lstInvoices!.getList()
        
        
    }
    
    @IBAction func fix_order(_ sender: Any) {
        
        
        
        
        if orderSelected!.amount_total == 0
        {
            let paid_list =  orderSelected!.get_bankStatement()
            for paid in paid_list
            {
                orderSelected!.amount_total += paid.due ?? 0
            }
            
        }
        
        
        for line in orderSelected!.pos_order_lines
        {
            line.update_values()
            
            if line.is_combo_line == true
            {
                for cobo_lines in line.selected_products_in_combo
                {
                    cobo_lines.update_values()
                }
            }
        }
        
        orderSelected?.save(re_calc:true)
        loadSeletedOrder()
        
    }
    
    @IBAction func skip_order(_ sender: Any) {
        orderSelected?.is_sync = true
        orderSelected?.skip_order = true
        orderSelected?.save()
    }
    
    @IBAction func btnLog(_ sender: Any) {
        
        
        let con :connection_log = connection_log()
        let key = "order " + orderSelected!.name!
        let log = logClass.get(key: key, prefix: "pos_order" )
        
        con.str = log.data ?? ""
        
        //        con.url = orderVc?.order.url
        //        con.header = orderVc?.order.header
        //        con.request = orderVc?.order.request
        //        con.response = orderVc?.order.response
        //        con.url = orderSelected?.url ?? ""
        //        con.header = orderSelected?.header ?? [:]
        //        con.request = orderSelected?.request ?? [:]
        //        con.response = orderSelected?.response ?? [:]
        
        //        self.navigationController?.pushViewController(con, animated: true)
        
        self.present(con, animated: true, completion: nil)
    }
    
    @IBAction func btnForceSync(_ sender: Any) {
        AppDelegate.shared.syncNow()
        printer_message_class.show(title:"","Sync in running .",image:"MWnotification_icon")
    }
    @IBAction func btnPrint(_ sender: Any) {
        
        //             webView.fullLengthScreenshot { (image) in
        //
        //                       if image != nil
        //                       {
        //                            EposPrint.runPrinterReceipt(  logoData: image , openDeawer: false)
        //
        //                       }
        //                   }
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            let isBill = (self.orderSelected?.is_closed ?? false) == false
            self.orderSelected?.creatCopyBillQueuePrinter(rowType.history, hideLogo: false,isBill: isBill)
            MWRunQueuePrinter.shared.startMWQueue()
        }else{
            guard let _ = order_print else{return}
            
            DispatchQueue.global(qos: .background).async {
                
                runner_print_class.runPrinterReceipt_image(  html: self.getPosHTML(false), openDeawer: false,row_type: .history)
                
                
            }
        }
        
        let printer_status_vc = printer_status()
        printer_status_vc.modalPresentationStyle = .overCurrentContext
        
        self.present(printer_status_vc, animated: true, completion: nil)
        
    }
    
    
    func snapshot(scrollView:UIScrollView) -> UIImage?
    {
        UIGraphicsBeginImageContext(scrollView.contentSize)
        
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame
        
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    func takeScreenshot() -> UIImage? {
        let currentSize = webView.frame.size
        let currentOffset = webView.scrollView.contentOffset
        
        webView.frame.size = webView.scrollView.contentSize
        webView.scrollView.setContentOffset(CGPoint.zero, animated: false)
        
        
        
        let rect = CGRect(x: 0, y: 0, width: webView.bounds.size.width, height: webView.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        webView.drawHierarchy(in: rect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        webView.frame.size = currentSize
        webView.scrollView.setContentOffset(currentOffset, animated: false)
        
        return image
    }
    
    func showConfirmAlertMovToMyOrder(){
        let alert = UIAlertController(title: "Move to my orders".arabic("نقل إلى طالباتي"), message: "Are you want to move that order to my orders".arabic("هل تريد نقل هذا الطلب إلى قائمة طالباتي"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes".arabic("نعم") , style: .default, handler: { (action) in
            if let activeSession = pos_session_class.getActiveSession(){
                if self.orderSelected?.session_id_local != activeSession.id {
                    self.orderSelected?.session_id_local = activeSession.id
                    self.orderSelected?.save()
                    printer_message_class.show(title:"" , "Order moved to my orders successfully".arabic("تم نقل الطلب الي قائمة طالباتي بنجاح"),image:"MWnotification_icon")
                }else{
                    printer_message_class.show(title:"","Order already exited at my order list".arabic("الطلب موجود بالفعل في قائمة الطلبات الخاصة بي"),image:"MWnotification_icon")
                    
                }
            }
            
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "NO".arabic("لا"), style: .cancel, handler: { (action) in
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeRetunOrder(tag:Int){
        if self.orderSelected!.able_to_return()
        {
            messages.showAlert("This order already returned .".arabic("تم استرجاع الطلب مسبقا"))
            return
            
        }
        
        if tag == 1 {
            self.showConfirmAlertMovToMyOrder()
            return
        }
                
        let option = ordersListOpetions()
        option.parent_order = true
        option.orderID = self.orderSelected?.id
        let list = pos_order_helper_class.getOrders_status_sorted(options: option)
        if list.count > 0
        {
            self.orderSelected = list[0]
            
            let list_sub =   self.get_sub_orders()
            self.orderSelected?.sub_orders = list_sub
        }
        
        
        var message = "Are you sure to return this invoice ?"
        let bankStatement = self.orderSelected?.get_bankStatement()
        
        if (bankStatement?.count ?? 1) > 1
        {
            
//            if (self.orderSelected?.sub_orders.count ?? 0) > 0
//            {
//                messages.showAlert("This order already returned .")
//                return
//                
//            }
             
            
           // message = "This order have multi payment method , All order will return ?"
        }
        
        let alert = UIAlertController(title: "Return", message: message, preferredStyle: .alert)
        
        
        
        alert.addAction(UIAlertAction(title: "Yes" , style: .default, handler: { (action) in
            if let orderName = self.orderSelected?.name {
                SharedManager.shared.conAPI().checkIfOrderCanReturn(with: orderName) { result in
                    if result.success {
                        let response = result.response
                        if let resultArray = response?["result"] as? [[String: Any]], let firstResult = resultArray.first, let allowReturn = firstResult["allow_return"] as? Bool {
                            if allowReturn {
                                messages.showAlert("Return order had stopped by admin.".arabic("لقد توقف أمر الإرجاع من قبل المشرف."))
                                return
                            }
                        }
                    }
                    self.show_return_reason()
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action) in
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func btnReturn(_ sender: UIButton) {
        if !MWMasterIP.shared.isOnLine(){
            messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
            return
        }
        //MARK:- Check allow pin code
        if self.orderSelected?.containeInsuranceLines() ?? false {
            
            
//            if rules.check_access_rule(rule_key.insurance_return,show_msg: true) {
//                self.makeRetunOrder(tag: sender.tag)
//                return
//            }
            
            rules.check_access_rule(rule_key.insurance_return,for: self) {
                DispatchQueue.main.async {
                    self.makeRetunOrder(tag: sender.tag)
                    return
                }
            }
            
            
            return
        }
        rules.check_access_rule(rule_key._return,for: self) {
            DispatchQueue.main.async {
                self.makeRetunOrder(tag: sender.tag)
                return
            }
        }
        
        
//        if rules.check_access_rule(rule_key._return,show_msg: false) {
//            self.makeRetunOrder(tag: sender.tag)
//        }else{
//            let pos = SharedManager.shared.posConfig()
//            let is_allow_pin = pos.allow_pin_code
//            if is_allow_pin {
//                SharedManager.shared.openPincode(order:nil,for :self, completion: { [weak self] in
//                    guard let self = self else {return}
//                    self.makeRetunOrder(tag: sender.tag)
//                })
//                
//            }else{
//                guard  rules.check_access_rule(rule_key._return) else {
//                    return
//                }
//            }
//        }

        
    }
    func openPayment(orderNeedToReturn:pos_order_class,return_orders_vc:return_orders)
    {
        var order = orderNeedToReturn.copyOrder()
        order.amount_paid = 0
        order.amount_total = order.amount_total * -1
        order.amount_return = 0
        let storyboard = UIStoryboard(name: "payment", bundle: nil)
        if  let paymentVC = storyboard.instantiateViewController(withIdentifier: "paymentVc") as? paymentVc{
            paymentVC.completeList = { bankStatement in
                if let bankStatement = bankStatement {
                    orderNeedToReturn.list_account_journal = bankStatement
                    //                orderNeedToReturn.amount_total = orderNeedToReturn.amount_total * -1
                    return_orders_vc.doReturn(order: orderNeedToReturn,list_bankStatement:[],checkListAccount: false)
                }else{
                    return_orders_vc.dismiss(animated: false)
                }
                
            }
            paymentVC.forReturnItems = true
            paymentVC.showCashMethodOnly = true
            paymentVC.parent_vc = self
            paymentVC.clearHome = false
            paymentVC.orderVc!.order =  order
            paymentVC.pickup_user_id = SharedManager.shared.activeUser().id
            let activeSession = pos_session_class.getActiveSession()
            paymentVC.orderVc!.order.session_id_local = activeSession!.id
        
            paymentVC.viewDidLoad()
            paymentVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            return_orders_vc.present(paymentVC, animated: true)
        }
    }
    
    func showOrderReturn(return_reason_id:Int?)
    {
        guard  let return_order = orderSelected else {return}
        
        let isNeedChoseBank = SharedManager.shared.appSetting().enable_chosse_account_journal_for_return_order || (return_order.get_bankStatement().count) > 1
       
            var bankStatement = orderSelected?.get_bankStatement() ?? []
            
            
            
            returnorder =  return_orders()
            
            let option = ordersListOpetions()
            option.parent_product = true
            
            returnorder.parent_vc = self
            returnorder.order = return_order.copyOrder(option: option)
            returnorder.sub_orders =  orderSelected?.sub_orders ?? []
            returnorder.order!.return_reason_id = return_reason_id
            returnorder.order!.loyalty_earned_point  =  -1  * returnorder.order!.loyalty_earned_point
            returnorder.order!.loyalty_earned_amount = -1 *  returnorder.order!.loyalty_earned_amount

            returnorder.modalPresentationStyle = .overFullScreen
            
            returnorder.didSelectReturnOrder  = {  order in
                self.returnorder.updateKitchenStatus(for:order.pos_order_lines , in:return_order)
                if isNeedChoseBank {
                    self.openPayment(orderNeedToReturn:order,return_orders_vc:self.returnorder)
                }else{
                    self.returnorder.doReturn(order: order,list_bankStatement:bankStatement)
                }
                
            }
        if isNeedChoseBank{
            self.present(returnorder, animated: true, completion: nil)

        }else{
            if (bankStatement.count) == 1
            {
                self.present(returnorder, animated: true, completion: nil)
                
            }
            else
            {
                let alert = UIAlertController(title: "Return", message: "Are you sure to return all items in this order ?", preferredStyle: .alert)
                
                
                
                alert.addAction(UIAlertAction(title: "Yes" , style: .default, handler: { (action) in
                    
                    self.returnorder.selectAll()
                    self.returnorder.returnOrder(parentVC: self)
                }))
                
                
                
                alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            }
        }
            
        
        
        
    }
    
    
    func show_return_reason()
    {
        
        let arr: [[String:Any]] =  pos_return_reason_class.getAll()
        if arr.count == 0
        {
            self.showOrderReturn(return_reason_id: nil)
            
            return
        }
        
        
        let list = options_listVC()
        list.modalPresentationStyle = .formSheet
        //        list.modalTransitionStyle = .crossDissolve
        
        list.preferredContentSize = CGSize.init(width: 500, height: 400)
        
        list.title = "Return reason".arabic("سبب المرتجع")
        
        for item in arr
        {
            var dic = item
            let cls = pos_return_reason_class(fromDictionary: item)
            
            dic[options_listVC.title_prefex] = cls.display_name
            
            list.list_items.append(dic)
            
        }
        
        
        
        list.didSelect = { [weak self] data in
            let dic = data
            
            let cls = pos_return_reason_class(fromDictionary: dic)
            
            
            self!.showOrderReturn(return_reason_id: cls.id)
            
            
            
        }
        
        
        list.clear = {
            
        }
        
        
        self.present(list, animated: true, completion: nil)
//        list.btn_clear.isHidden = true
        list.hideClearBtnFlag = true
        
    }
    
    
    
    
    @IBAction func btnDetails(_ sender: Any) {
        
    }
    
    
    
    @IBAction func btnMore(_ sender: Any) {
        
        let alert = UIAlertController(title: "More", message: "Pleas select action.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "PDF" , style: .default, handler: { (action) in
            
            self.printPDF()
            
        }))
        
        
//        alert.addAction(UIAlertAction(title: "Log" , style: .default, handler: { (action) in
//
//            self.btnLog(AnyClass.self)
//
//        }))
        alert.addAction(UIAlertAction(title: "Sent to kitchen" , style: .default, handler: { (action) in
            
            self.sentToKitchen()
            
        }))
        
        
        //        alert.addAction(UIAlertAction(title: "Fix noc" , style: .default, handler: { (action) in
        //
        //            self.fix_noc(AnyClass.self)
        //
        //        }))
        //
        //        alert.addAction(UIAlertAction(title: "Fix all orders" , style: .default, handler: { (action) in
        //
        //            self.fix_all_order(AnyClass.self)
        //
        //        }))
        //
        //        alert.addAction(UIAlertAction(title: "Fix order" , style: .default, handler: { (action) in
        //
        //            self.fix_order(AnyClass.self)
        //
        //        }))
        
//        alert.addAction(UIAlertAction(title: "Skip order" , style: .default, handler: { (action) in
//
//            self.skip_order(AnyClass.self)
//
//        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        alert.popoverPresentationController?.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
        alert.popoverPresentationController?.sourceView = sender as? UIView
        alert.popoverPresentationController?.sourceRect =  (sender as AnyObject).bounds
        
        //        alert.popoverPresentationController?.sourceView = sender as? UIView// works for both iPhone & iPad
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func test_printer()
    {
        htmlToPDF(html: html_temp)
    }
    
    
    
    
    func convertToPdfFileAndShare(html:String){
        
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        
        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage();
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output").appendingPathExtension("pdf")
        else { fatalError("Destination URL not created") }
        
        pdfData.write(to: outputURL, atomically: true)
       SharedManager.shared.printLog("open \(outputURL.path)")
        
        if FileManager.default.fileExists(atPath: outputURL.path){
            
            let url = URL(fileURLWithPath: outputURL.path)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView=self.view
            
            //If user on iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                }
            }
            present(activityViewController, animated: true, completion: nil)
            
        }
        else {
           SharedManager.shared.printLog("document was not found")
        }
        
    }
    
    func htmlToPDF(html:String)
    {
        // 1. Create a print formatter
        
        
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        
        // 2. Assign print formatter to UIPrintPageRenderer
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        
        //        let page_a4 = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 1) // A4, 72 dpi
        
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        let count:Double = Double(render.numberOfPages)
        
        let all_page = CGRect(x: 0, y: 0, width: 595.2, height: count) // A4, 72 dpi
        
        
        let render_page = UIPrintPageRenderer()
        render_page.addPrintFormatter(fmt, startingAtPageAt: 0)
        render_page.setValue(all_page, forKey: "paperRect")
        render_page.setValue(all_page, forKey: "printableRect")
        
        // 4. Create PDF context and draw
        
        let pdfData = render_page.makePDF()
        
        //        let pdfData = NSMutableData()
        //        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        //
        //        for i in 0..<render.numberOfPages {
        //            UIGraphicsBeginPDFPage();
        //            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        //        }
        //
        //        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output").appendingPathExtension("pdf")
        else { fatalError("Destination URL not created") }
        
        let x = try!  pdfData.write(to: outputURL)
        
        //        pdfData.write(to: outputURL, atomically: true)
        SharedManager.shared.printLog("open \(outputURL.path)") // command to open the generated file
        
        //        let image:UIImage = drawPDFfromURL(url: outputURL)!
        //        image.save(at: .documentDirectory, pathAndImageName: "test.jpg")
        
        guard let imageURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        else { fatalError("Destination URL not created") }
        
        
        guard let image1_url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output-Page1").appendingPathExtension("jpg")
        else { fatalError("Destination URL not created") }
        
        guard let image2_url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output-Page2").appendingPathExtension("jpg")
        else { fatalError("Destination URL not created") }
        
        do {
            
            try convertPDF(at: outputURL, to: imageURL, fileType: .jpg, dpi: 200)
            
            //            let image1:UIImage = UIImage.init(fileURLWithPath: image1_url)!
            //            let image2:UIImage = UIImage.init(fileURLWithPath: image2_url)!
            //
            //            let newimage:UIImage =  imageByCombiningImage(topImage: image1, withImage: image2)
            //            newimage.save(at: .documentDirectory, pathAndImageName: "test.jpg")
            
        } catch   {
            
        }
        
    }
    
    
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        
        
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)
                
                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                
                ctx.cgContext.drawPDFPage(page)
            }
            
            return img
            
            
        } else {
            // Fallback on earlier versions
            
            return nil
        }
        
    }
    
    
    
    struct ImageFileType {
        var uti: CFString
        var fileExtention: String
        
        // This list can include anything returned by CGImageDestinationCopyTypeIdentifiers()
        // I'm including only the popular formats here
        static let bmp = ImageFileType(uti: kUTTypeBMP, fileExtention: "bmp")
        static let gif = ImageFileType(uti: kUTTypeGIF, fileExtention: "gif")
        static let jpg = ImageFileType(uti: kUTTypeJPEG, fileExtention: "jpg")
        static let png = ImageFileType(uti: kUTTypePNG, fileExtention: "png")
        static let tiff = ImageFileType(uti: kUTTypeTIFF, fileExtention: "tiff")
    }
    
    func convertPDF(at sourceURL: URL, to destinationURL: URL, fileType: ImageFileType, dpi: CGFloat = 200) throws -> [URL] {
        let pdfDocument = CGPDFDocument(sourceURL as CFURL)!
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue
        
        var urls = [URL](repeating: URL(fileURLWithPath : "/"), count: pdfDocument.numberOfPages)
        DispatchQueue.concurrentPerform(iterations: pdfDocument.numberOfPages) { i in
            // Page number starts at 1, not 0
            let pdfPage = pdfDocument.page(at: i + 1)!
            
            let mediaBoxRect = pdfPage.getBoxRect(.mediaBox)
            let scale = dpi / 72.0
            let width = Int(mediaBoxRect.width * scale)
            let height = Int(mediaBoxRect.height * scale)
            
            let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)!
            context.interpolationQuality = .high
            //            context.setFillColor(.white)
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            context.scaleBy(x: scale, y: scale)
            context.drawPDFPage(pdfPage)
            
            let image = context.makeImage()!
            let imageName = sourceURL.deletingPathExtension().lastPathComponent
            let imageURL = destinationURL.appendingPathComponent("\(imageName)-Page\(i+1).\(fileType.fileExtention)")
            
            let imageDestination = CGImageDestinationCreateWithURL(imageURL as CFURL, fileType.uti, 1, nil)!
            CGImageDestinationAddImage(imageDestination, image, nil)
            CGImageDestinationFinalize(imageDestination)
            
            urls[i] = imageURL
        }
        return urls
    }
    
    func imageByCombiningImage(topImage: UIImage, withImage bottomImage: UIImage) -> UIImage {
        
        let size = CGSize(width: topImage.size.width, height: topImage.size.height + bottomImage.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        topImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: topImage.size.height))
        bottomImage.draw(in: CGRect(x: 0, y: topImage.size.height, width: size.width, height: bottomImage.size.height))
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @IBAction func btnCloseSearch(_ sender: Any) {
        
        
        filtter = nil
        //           btnFillter.setTitle("Fillter", for: .normal)
        //           btnCloseSearch.isHidden = true
        
        seq_changed(AnyClass.self)
        
        
    }
    
    @IBAction func btnshowFiltter(_ sender: Any) {
        
        
        if filtter == nil
        {
            let storyboard = UIStoryboard(name: "HistorySearch", bundle: nil)
            
            
            filtter = storyboard.instantiateViewController(withIdentifier: "HistorySearchFilterId") as? HistorySearchFilterViewController
            filtter!.modalPresentationStyle = .formSheet
        }
        
        
        self.present(filtter!, animated: true, completion: nil)
        
        
    }
    
    @IBAction func onSearchClick(_ sender: UIButton) {
        performSegue(withIdentifier: "Segue2SearchFilter", sender: self)
    }
    
    @IBAction func unwindToOrderHistoryViewController(segue: UIStoryboardSegue) {
       SharedManager.shared.printLog("Unwind to Order History view controller")
        if let source = segue.source as? HistorySearchFilterViewController {
            var hasOptions = true
            
            
            var txt_search_temp = ""
            lstInvoices!.option.creationDate = source.date
            hasOptions = source.date != nil
            /*
            if source.date != nil {
                hasOptions = true
                
                txt_search_temp = lstInvoices!.option.creationDate!
                
                lstInvoices!.option.creationDate =  baseClass.get_date_local_to_search(DateOnly: lstInvoices!.option.creationDate!, format: "yyyy-MM-dd" ,returnFormate: "yyyy-MM-dd")
                
                
            }
            */
            lstInvoices!.option.creationTime = source.time
            if source.time != nil {
                hasOptions = true
                
                txt_search_temp = txt_search_temp + "," +  lstInvoices!.option.creationTime!
                
            }
            
            lstInvoices!.option.invoiceId = source.orderNumber
            if source.orderNumber != nil {
                hasOptions = true
                txt_search_temp = txt_search_temp + "," + String( lstInvoices!.option.invoiceId!)
                
            }
            
            lstInvoices!.option.orderTypeName = source.orderType
            if source.orderType != nil {
                hasOptions = true
                txt_search_temp = txt_search_temp + "," +  lstInvoices!.option.orderTypeName!
                
            }
            
            lstInvoices!.option.customerName = source.customer
            lstInvoices!.option.customerPhone = source.customerPhone
            lstInvoices!.option.customerEmail = source.customerEmail

            if source.customer != nil {
                hasOptions = true
                txt_search_temp = txt_search_temp + "," +  lstInvoices!.option.customerName!
                
            }
            
            if source.customerPhone != nil {
                hasOptions = true
                txt_search_temp = txt_search_temp + "," +  lstInvoices!.option.customerPhone!
                
            }
            if source.customerEmail != nil {
                hasOptions = true
                txt_search_temp = txt_search_temp + "," +  lstInvoices!.option.customerEmail!
                
            }
            
            lstInvoices!.option.paymentMethodName = source.paymentMethod
            if source.paymentMethod != nil {
                hasOptions = true
                txt_search_temp = txt_search_temp + "," +  lstInvoices!.option.paymentMethodName!
                
            }
            
            lstInvoices!.option.cashierName = source.cashier
            if source.cashier != nil {
                hasOptions = true
                txt_search_temp = txt_search_temp + "," +  lstInvoices!.option.cashierName!
                
            }
            
            lstInvoices!.option.sesssion_id = source.sessionNumber
            if source.sessionNumber != 0 {
                hasOptions = true
                txt_search_temp = txt_search_temp + "," + String( lstInvoices!.option.sesssion_id)
                
            }
            lstInvoices!.option.driverID = source.selectDriver?.id
            if source.selectDriver != nil {
                hasOptions = true
                txt_search_temp = txt_search_temp + "," + "\( lstInvoices!.option.driverID!)"
            }
            
            if hasOptions {
                lstInvoices?.option.sesssion_ids = nil
                lstInvoices?.currentPage = 0
                lstInvoices!.getListForSearch()
                
            }
        }
    }
    
    func  loadReport()
    {
        if self.sesssion_ids == nil
        {
            lstInvoices!.clear()
            
            return
        }
        
        lstInvoices!.option = ordersListOpetions()
        //        lstInvoices!.option.parent_order = true
//        lstInvoices!.option.sesssion_ids = self.sesssion_ids
        
        if AppDelegate.shared.load_kds == false
        {
            lstInvoices!.option.write_pos_id = SharedManager.shared.posConfig().id
        }
        
        hideAllBtns()
        
        if seq.selectedSegmentIndex == index_seq.CLOSED.rawValue
        {
            lstInvoices!.option.Closed = true
//            lstInvoices!.option.Sync = true
            lstInvoices!.option.void = false
        }
        else if seq.selectedSegmentIndex == index_seq.Pending.rawValue
        {
            lstInvoices!.option.Closed = false
            lstInvoices!.option.Sync = false
            lstInvoices!.option.void = false
            lstInvoices!.option.order_menu_status = [.none,.accepted]
            lstInvoices!.option.get_not_empty_orders = true

        }
        else if seq.selectedSegmentIndex == index_seq.Void.rawValue
        {
            lstInvoices!.option.Closed = false
            lstInvoices!.option.Sync = false
            lstInvoices!.option.void = true
            lstInvoices!.option.get_lines_void = true
            lstInvoices!.option.order_menu_status = [orderMenuStatus.none]
            //            lstInvoices!.option.pos_multi_session_status = .last_update_from_local
        }
        else if seq.selectedSegmentIndex == index_seq.Delete.rawValue
        {
            lstInvoices!.option.Closed = false
            lstInvoices!.option.Sync = false
            lstInvoices!.option.void = true
            lstInvoices!.option.get_lines_void = true
            lstInvoices!.option.order_menu_status = [orderMenuStatus.none]
            lstInvoices!.option.pos_multi_session_status = .sended_update_to_server
            
        }
        else if seq.selectedSegmentIndex == index_seq.Rejected.rawValue
        {
            lstInvoices!.option.void = true
            lstInvoices!.option.get_lines_void = true
            lstInvoices!.option.order_integration = [ORDER_INTEGRATION.ONLINE,ORDER_INTEGRATION.DELIVERY]
            lstInvoices!.option.order_menu_status = [.rejected]
            
        }
        else if seq.selectedSegmentIndex == index_seq.TIME_OUT.rawValue
        {
            lstInvoices!.option.order_integration = [ORDER_INTEGRATION.DELIVERY]
            lstInvoices!.option.order_menu_status = [.time_out]
            
        }
        else if seq.selectedSegmentIndex == index_seq.All.rawValue
        {
            
//            lstInvoices!.option.get_lines_void = true
            lstInvoices!.option.void = false

        }
        else if seq.selectedSegmentIndex == index_seq.Insurance.rawValue
        {
            
            lstInvoices!.option.pos_multi_session_status = .insurance_order
        }
        
        webView.loadHTMLString("", baseURL: Bundle.main.bundleURL)
        
        lstInvoices?.currentPage = 0
        lstInvoices!.getList()
        
    }
}

extension order_history
{
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
                start_date = Date().toString(dateFormat: date_formate, UTC: false)
                end_date = start_date
                
            }
            
            self.sesssion_ids = String( lastSession!.id)
            
            let dt = Date(strDate: lastSession!.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
            let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
            
            
            let title = String( lastSession!.id ) + " - " + startDate
            
            btnSelectShift.setTitle(title, for: .normal)
            
            
        }
        else
        {
            start_date = Date().toString(dateFormat: date_formate, UTC: false)
            end_date = start_date
            
            
        }
        
        
        btnStartDate.setTitle(start_date, for: .normal)
        btnEndDate.setTitle(end_date, for: .normal)
        
        loadReport()
        //initalWithAllFilter()
        
    }
    
    func initalWithAllFilter(){
        //        start_date = Date().toString(dateFormat: date_formate, UTC: false)
        //        end_date = start_date
        btnSelectShift.setTitle("All", for: .normal)
        seq.selectedSegmentIndex = index_seq.CLOSED.rawValue
        //        btnStartDate.setTitle(start_date, for: .normal)
        //        btnEndDate.setTitle(end_date, for: .normal)
        DispatchQueue.main.async {
            let allSessionTuple = self.getAllSession()
            self.sesssion_ids = allSessionTuple.1
            self.lstInvoices!.clear()
            self.lstInvoices?.currentPage = 0
            self.loadReport()
        }
    }
    
    func getAllSession() -> ([[String : Any]],String?) {
        var list_items: [[String : Any]] = []
        
        let options = posSessionOptions()
        options.between_start_session = [get_start_date(),get_end_date()]
        
        var string_sessions:String? = nil
        let arr: [[String:Any]] =    pos_session_class.get_pos_sessions(options: options)
        for item in arr
        {
            var dic = item
            let shift = pos_session_class(fromDictionary: item)
            
            let dt = Date(strDate: shift.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
            let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
            
            
            let title = String( shift.id ) + " - " + startDate
            dic[options_listVC.title_prefex] = title
            list_items.append(dic)
            if string_sessions == nil
            {
                string_sessions = String( shift.id)
            }
            else
            {
                string_sessions =  string_sessions! + "," + String( shift.id)
            }
            
            
        }
        return (list_items,string_sessions);
    }
    
    @IBAction func btnSelectShift(_ sender: Any) {
        
        let list = options_listVC()
        list.modalPresentationStyle = .formSheet
        
        list.list_items.append([options_listVC.title_prefex:"All"])
        
        //        let dt = Date.init(strDate: start_date!, formate: date_formate)
        //        options.start_session = dt.toString(dateFormat: "yyyy-MM-dd", UTC: true)
        
        //        let checkDay = baseClass.get_date_local_to_search(DateOnly: date_str, format: date_formate ,returnFormate: "yyyy-MM-dd HH:mm:ss")
        
        sesssion_ids = nil
        
        let allSessionTuple = getAllSession()
        list.list_items.append(contentsOf: allSessionTuple.0)
        
        
        
        list.didSelect = { [weak self] data in
            let dic = data
            let title = dic[options_listVC.title_prefex] as? String ?? ""
            if title == "All"
            {
                self!.sesssion_ids = allSessionTuple.1 ?? ""
                self!.btnSelectShift.setTitle("All", for: .normal)
                
            }
            else
            {
                let shift_id = dic["id"] as? Int ?? 0
                self!.sesssion_ids = String(shift_id)
                self!.btnSelectShift.setTitle(title, for: .normal)
                
            }
            self!.loadReport()
        }
        
        
        list.clear = {
            
            self.btnSelectShift.setTitle("All", for: .normal)
            
            list.dismiss(animated: true, completion: nil)
            
        }
        
        
        self.present(list, animated: true, completion: nil)
    }
    @IBAction func btnStartDate(_ sender: Any) {
        let calendar = calendarVC()
        
        calendar.modalPresentationStyle = .formSheet
        calendar.didSelectDay = { [weak self] date in
            
            self?.lstInvoices?.list_items.removeAll()
            self?.lstInvoices?.tableview.reloadData()
            
            self?.start_date = date.toString(dateFormat:self!.date_formate)
            self?.btnStartDate.setTitle( self?.start_date, for: .normal)
            
            self?.end_date = date.toString(dateFormat:self!.date_formate)
            self?.btnEndDate.setTitle( self?.end_date, for: .normal)
            
            self?.doneSelect()
            
            calendar.dismiss(animated: true, completion: nil)
        }
        self.present(calendar, animated: true, completion: nil)
    }
    @IBAction func btnEndDate(_ sender: Any) {
        let calendar = calendarVC()
        
        calendar.modalPresentationStyle = .formSheet
        calendar.didSelectDay = { [weak self] date in
            self?.lstInvoices?.list_items.removeAll()
            self?.lstInvoices?.tableview.reloadData()
            
            self?.end_date = date.toString(dateFormat: self!.date_formate)
            self?.btnEndDate.setTitle(self?.end_date, for: .normal)
            
            
            self?.doneSelect()
            
            calendar.dismiss(animated: true, completion: nil)
            
        }
        self.present(calendar, animated: true, completion: nil)
    }
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
    
    func doneSelect() {
        
        let def = baseClass.compareTwoDate(start_date!, dt2_new: end_date!, formate: date_formate)
        if def < 0
        {
            end_date = start_date
            self.btnEndDate.setTitle(self.end_date, for: .normal)
            
            DispatchQueue.main.async {
                printer_message_class.show("invaled date", vc: self)
                
            }
            
        }
        else
        {
            
            let options = posSessionOptions()
            options.between_start_session = [get_start_date(),get_end_date()]
            
            sesssion_ids = nil
            
            let arr: [[String:Any]] =    pos_session_class.get_pos_sessions(options: options)
            for item in arr
            {
                
                let shift = pos_session_class(fromDictionary: item)
                
                if sesssion_ids == nil
                {
                    sesssion_ids = String( shift.id)
                }
                else
                {
                    sesssion_ids =  sesssion_ids! + "," + String( shift.id)
                }
                
                
            }
            
            loadReport()
        }
        
        
    }
    
    
}

extension UIPrintPageRenderer {
    public func makePDF() -> Data {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, paperRect, nil)
        prepare(forDrawingPages: NSMakeRange(0, numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()
        
        for i in 0 ..< numberOfPages {
            UIGraphicsBeginPDFPage()
            drawPage(at: i, in: bounds)
        }
        UIGraphicsEndPDFContext()
        
        return data as Data
    }
}

extension order_history
{
    func printPDF()
    {
        
//        SharedManager.shared.printLog(html_temp)
        var html =  ""
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            let isReturn = (self.orderSelected?.parent_order_id) != 0
            if self.orderSelected?.is_closed ?? false &&  !(self.orderSelected?.is_void ?? false) && !isReturn {
                html = self.orderSelected?.getInvoiceHTML(.order, hideLogo: false) ?? "Cannot load invoice"

            }else{
                if isReturn {
                    html = self.orderSelected?.getInvoiceHTML(.return_order, hideLogo: false) ?? "Cannot load invoice"
                }else{
                    html = self.orderSelected?.getInvoiceHTML(.bill, hideLogo: false) ?? "Cannot load invoice"

                }

            }
        }else{
            order_print.showOrderReference = true
            
            html = order_print.printOrder_html()
        }
        
        initWebViewPD(htmlString: html,tag: 200)
        
        //        let html =  invoiceTaxClass.getPdf(order:orderSelected!)
        //
        //        self.webView.loadHTMLString(html,  baseURL: Bundle.main.bundleURL)
    }
    
    func loadinvoiceVat()
    {
        DispatchQueue.main.async{
            let html =  invoiceTaxClass.getPdf(order:self.orderSelected!)
            self.initWebViewPD(htmlString: html,tag: 201)
        }
    }
    
    func initWebViewPD(htmlString:String,tag:Int) {
        
        let webConfiguration = WKWebViewConfiguration()
        
        self.webViewPDF = WKWebView(frame:view_orderDetials.bounds, configuration: webConfiguration)
        self.webViewPDF!.navigationDelegate = self
        self.webViewPDF!.frame.origin.x = -10
        self.webViewPDF!.tag = tag
        self.webViewPDF!.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        self.webViewPDF!.sizeToFit()
        self.webViewPDF!.loadHTMLString(htmlString, baseURL:  Bundle.main.bundleURL)
        
    }
    
    func loadPDFAndShare(){
        
        DispatchQueue.main.async {
            let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let path_invoiceVat = documentsDirectory.appendingPathComponent("invoiceVat-" + self.orderSelected!.name! + ".pdf");
            let path_invoice = documentsDirectory.appendingPathComponent("invoice-" +  self.orderSelected!.name! + ".pdf");
            
            
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: path_invoiceVat.path){
                //                let invoiceVat = NSData(contentsOfFile: path_invoiceVat.path)
                //                let invoice = NSData(contentsOfFile: path_invoice.path)
                
                
                
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [ path_invoice,path_invoiceVat], applicationActivities: nil)
                
                activityViewController.popoverPresentationController?.sourceView = self.btnLog
                
                
                self.present(activityViewController, animated: true, completion: nil)
            }
            else {
               SharedManager.shared.printLog("document was not found")
            }
        }
        
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        webView.evaluateJavaScript("applyCurrency(window.appCurrency || '');", completionHandler: nil)
        if(webView.isLoading){
            return
        }
        
        if webView.tag != 200 && webView.tag != 201
        {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            
            let render = UIPrintPageRenderer()
            render.addPrintFormatter((self.webViewPDF?.viewPrintFormatter())!, startingAtPageAt: 0)
            
            //Give your needed size
            // set header and footer spaces
            
            
            
            var page:CGRect
            
            if webView.tag == 200
            {
                page = CGRect(x: 0, y: 0, width: (self.webViewPDF?.scrollView.contentSize.width)! + 150, height: (self.webViewPDF?.scrollView.contentSize.height)! + 400)
                
            }
            else
            {
                page = CGRect(x: 0, y: 0, width: (self.webViewPDF?.scrollView.contentSize.width)! + 150, height: (self.webViewPDF?.scrollView.contentSize.height)! + 100)
                
            }
            
            
            render.setValue(NSValue(cgRect:page),forKey:"paperRect")
            render.setValue(NSValue(cgRect:page), forKey: "printableRect")
            
            let pdfData = NSMutableData()
            UIGraphicsBeginPDFContextToData(pdfData,page, nil)
            
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: 0, in: bounds)
            
            //        for i in 1...render.numberOfPages-1{
            //
            //            UIGraphicsBeginPDFPage();
            //            let bounds = UIGraphicsGetPDFContextBounds()
            //            render.drawPage(at: i - 1, in: bounds)
            //        }
            
            UIGraphicsEndPDFContext();
            
            //For locally view page
            var fileNamePDf = "invoice-" + self.orderSelected!.name! + ".pdf"
            if webView.tag == 201
            {
                fileNamePDf = "invoiceVat-" +  self.orderSelected!.name! + ".pdf"
            }
            
            let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileNamePDf);
            //         if !FileManager.default.fileExists(atPath:fileURL.path) {
            do {
                try pdfData.write(to: fileURL)
               SharedManager.shared.printLog("file saved")
                
            } catch {
               SharedManager.shared.printLog("error saving file:\(error)" );
            }
            //         }
            
            
            if webView.tag == 200
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                    self.loadinvoiceVat()
                }
            }
            else if (webView.tag == 201)
            {
                self.loadPDFAndShare()
            }
            
        }
    }
    
    
    
    
}
extension api {
    func checkIfOrderCanReturn(with orderName:String,completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params":  [
                "model": "pos.order",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": ["allow_return"],
                    "domain": [["pos_reference","=",orderName]],
                    "context":  [
                        "lang": "en_US",
                        "tz": "Europe/Brussels",
                        "uid": 1
                    ]
                ]
            ]
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"validate_Order_Return"),header: header, param: param, completion: completion);
        
    }
}
