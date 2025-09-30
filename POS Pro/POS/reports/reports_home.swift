//
//  setting_home.swift
//  pos
//
//  Created by khaled on 9/30/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class reports_home: baseViewController {
    
     var posConfig:pos_configration?
    var addPrinter_page :addPrinter?
    var cls_load_all_apis:load_base_apis! = load_base_apis()
    
    var z_report:zReport!
    var z_report_total:zReport_total!
    var reportsBuilder:reportsBuilderViewController!


//    var reportViewController: ProductsReportViewController?
//    var rangeReportViewController: Products_Rang_Report?
    var rangeReportViewController2: Products_Rang_Report2?
    var driverViewController: driver_report?
    var sessionListViewController: sessionList_report?

    var total_rang_report_vc: total_rang_report?

    var STCVC:STCLogViewController?
    var stockReport:stock_report?
    var sales_report_multi_pos_vc:sales_report_multi_pos?
    var reportWifiVC:zReport!

    
    @IBOutlet var container: UIView!
    
    @IBOutlet var tableview: UITableView!
    var list_items:  [Any]! = []
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        list_items = nil
//        posConfig = nil
//        addPrinter_page = nil
//        cls_load_all_apis = nil
//        z_report = nil
//        reportViewController = nil
//        rangeReportViewController = nil
//        STCVC = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedManager.shared.updateLastActionDate()
        MaintenanceInteractor.shared.searchBluetoothPrinter()

      initList()
        
    }
    
    func btnPriceList(_ sender: Any)
    {
        
    }
    
    @IBAction func btnOpenMenu(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    func completeSalesReport(){
        clearView()
        
//        let Session:posSessionClass =  posSessionClass.getLastActiveSession()
//        if Session.id == 0
//        {
//            return
//        }
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        z_report = storyboard.instantiateViewController(withIdentifier: "zReport") as? zReport
//        z_report?.activeSessionLast = Session
        z_report.custom_header = LanguageManager.currentLang() == .ar ? "تقرير عمليات " : "Sales report"
        z_report?.view.frame = container.bounds
        z_report.parent_vc = self
        
        var frm = container.bounds
        frm.origin.x = -10
    
        z_report.container.frame = frm
        
        z_report.view.frame.origin.y = -70
        
        z_report.hideNav = true
        container.addSubview(z_report!.view)
    }
    func openZreport() {
        
//        guard  rules.check_access_rule(rule_key.sales_report) else {
//                    return
//                }
        
        rules.check_access_rule(rule_key.sales_report,for: self) {
            DispatchQueue.main.async {
                self.completeSalesReport()
                return
            }
        }
        
      
        
        
    }
    func completeopenUsersReport(){
        clearView()
        
//        let Session:posSessionClass =  posSessionClass.getLastActiveSession()
//        if Session.id == 0
//        {
//            return
//        }
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        z_report = storyboard.instantiateViewController(withIdentifier: "zReport") as? zReport
//        z_report?.activeSessionLast = Session
        z_report.custom_header = LanguageManager.currentLang() == .ar ? "تقرير المستخدمين" : "Users report"
        z_report?.view.frame = container.bounds
        z_report.parent_vc = self
        z_report.forUsersReport = true
        var frm = container.bounds
        frm.origin.x = -10
    
        z_report.container.frame = frm
        
        z_report.view.frame.origin.y = -70
        
        z_report.hideNav = true
        container.addSubview(z_report!.view)
    }
    func openUsersReport(){
//        guard  rules.check_access_rule(rule_key.admin_driver_lock) else {
//                    return
//                }
        
        rules.check_access_rule(rule_key.admin_driver_lock,for: self) {
            DispatchQueue.main.async {
                self.completeopenUsersReport()
                return
            }
        }
        
    }
    func completeopenDriverLockreport(){
        clearView()
        
//        let Session:posSessionClass =  posSessionClass.getLastActiveSession()
//        if Session.id == 0
//        {
//            return
//        }
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        z_report = storyboard.instantiateViewController(withIdentifier: "zReport") as? zReport
//        z_report?.activeSessionLast = Session
        z_report.custom_header = LanguageManager.currentLang() == .ar ? "تقرير جلسات السائقين " : "Drivers session report"
        z_report?.view.frame = container.bounds
        z_report.parent_vc = self
        z_report.forLockDriver = true
        var frm = container.bounds
        frm.origin.x = -10
    
        z_report.container.frame = frm
        
        z_report.view.frame.origin.y = -70
        
        z_report.hideNav = true
        container.addSubview(z_report!.view)
    }
    func openDriverLockreport() {
        
//        guard  rules.check_access_rule(rule_key.admin_driver_lock) else {
//                    return
//                }
        rules.check_access_rule(rule_key.admin_driver_lock,for: self) {
            DispatchQueue.main.async {
                self.completeopenDriverLockreport()
                return
            }
        }
       
        
        
    }
    
    func completeopenZreportMultiPeer(){
        clearView()
         
        reportsBuilder  = reportsBuilderViewController(nibName: "reportsBuilderViewController", bundle: nil)
        reportsBuilder.custom_header = LanguageManager.currentLang() == .ar ? "تقرير عمليات " : "Sales report"
        reportsBuilder.view.frame = container.bounds
        reportsBuilder.parent_vc = self
        
        var frm = container.bounds
        frm.origin.x = -10
    
        reportsBuilder.container.frame = frm
        reportsBuilder.view.frame.origin.y = -70
        
        container.addSubview(reportsBuilder!.view)
    }
    func openZreportMultiPeer() {
        
//        guard  rules.check_access_rule(rule_key.sales_report) else {
//                    return
//                }
        rules.check_access_rule(rule_key.sales_report,for: self) {
            DispatchQueue.main.async {
                self.completeopenZreportMultiPeer()
                return
            }
        }
       
        
        
    }
    
    func completeopenZreport_total(){
        clearView()

        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        total_rang_report_vc = storyboard.instantiateViewController(withIdentifier: "total_rang_report") as? total_rang_report
        total_rang_report_vc?.custom_header = LanguageManager.currentLang() == .ar ? "تقرير ملخص المبيعات" : "Sales summary report"
//        z_report?.activeSessionLast = Session
        total_rang_report_vc?.view.frame = container.bounds
        total_rang_report_vc!.parent_vc = self

//            var frm = container.bounds
//            frm.origin.x = -10
//
//            total_rang_report_vc!.container.frame = frm
//
//            total_rang_report_vc!.view.frame.origin.y = -70
//

        container.addSubview(total_rang_report_vc!.view)
    }
    
        func openZreport_total() {
            
//            guard  rules.check_access_rule(rule_key.sales_summary_report) else {
//                        return
//                    }
            rules.check_access_rule(rule_key.sales_summary_report,for: self) {
                DispatchQueue.main.async {
                    self.completeopenZreport_total()
                    return
                }
            }
           
            
           
            
            
        }
        
    
    
    func openProductsReport() {
        clearView()
        
 
//        let storyboard = UIStoryboard(name: "reports", bundle: nil)
//
//        reportViewController = storyboard.instantiateViewController(withIdentifier: "ProductsReport") as? ProductsReportViewController
////        reportViewController?.activeSessionLast = Session
//        reportViewController?.view.frame = container.bounds
//        reportViewController?.showProduct = true
//         reportViewController?.option.Closed = true
//          reportViewController?.option.orderSyncType = .order
//   reportViewController?.parent_vc = self
//        container.addSubview(reportViewController!.view)
    }
    
    func open_total_report() {
             clearView()
             
 
             let storyboard = UIStoryboard(name: "reports", bundle: nil)
             
             total_rang_report_vc = storyboard.instantiateViewController(withIdentifier: "total_rang_report") as? total_rang_report
              total_rang_report_vc?.view.frame = container.bounds
               total_rang_report_vc?.option.orderSyncType = .order
                 total_rang_report_vc?.option.Closed =  true

             container.addSubview(total_rang_report_vc!.view)
         }
    func completeopen_discount_report(){
        clearView()
        

        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        total_rang_report_vc = storyboard.instantiateViewController(withIdentifier: "total_rang_report") as? total_rang_report
total_rang_report_vc?.custom_header = LanguageManager.currentLang() == .ar ? "تقرير الخصم" : "Discount report"
         total_rang_report_vc?.view.frame = container.bounds
          total_rang_report_vc?.option.orderSyncType = .order
            total_rang_report_vc?.option.Closed =  true
        total_rang_report_vc?.show_discount_only = true
total_rang_report_vc?.parent_vc = self
        container.addSubview(total_rang_report_vc!.view)
    }
    func open_discount_report() {
//        guard  rules.check_access_rule(rule_key.discount_report) else {
//                    return
//                }
        
        rules.check_access_rule(rule_key.discount_report,for: self) {
            DispatchQueue.main.async {
                self.completeopen_discount_report()
                return
            }
        }
               
            }
    
    func completOpenScrapReport(){
        clearView()
        
//        let Session =  posSessionClass.getActiveSession()
//
//        if Session.id == 0 {
//            return
//        }
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        rangeReportViewController2 = storyboard.instantiateViewController(withIdentifier: "Products_Rang_Report2") as? Products_Rang_Report2
//        reportViewController?.activeSessionLast = Session
        rangeReportViewController2?.view.frame = container.bounds
        rangeReportViewController2?.showProduct = true
        rangeReportViewController2?.hide_net = true
        rangeReportViewController2?.hide_discount = true
        rangeReportViewController2?.parent_vc = self
        rangeReportViewController2?.option.orderSyncType = .scrap
        rangeReportViewController2?.custom_header = MWConstants.scrap_product_title

        container.addSubview(rangeReportViewController2!.view)
    }
        func openScrapReport() {
            
//            guard  rules.check_access_rule(rule_key.products_waste) else {
//                        return
//                    }
            
            rules.check_access_rule(rule_key.products_waste,for: self) {
                DispatchQueue.main.async {
                    self.completOpenScrapReport()
                    return
                }
            }
            
            
        }
    func completeOpenReturn(){
        clearView()
        

        
        
             let storyboard = UIStoryboard(name: "reports", bundle: nil)
               
        rangeReportViewController2 = storyboard.instantiateViewController(withIdentifier: "Products_Rang_Report2") as? Products_Rang_Report2
        
        rangeReportViewController2?.view.frame = container.bounds
        rangeReportViewController2?.showProduct = true
        rangeReportViewController2?.hide_discount = true

        rangeReportViewController2?.option.orderSyncType = .order
        rangeReportViewController2?.option.parent_order =  false
        rangeReportViewController2?.option.Closed =  true
        rangeReportViewController2?.parent_vc = self
        rangeReportViewController2?.custom_header = "Products Return"

               container.addSubview(rangeReportViewController2!.view)
    }
        func openReturn() {
            
            
//            guard  rules.check_access_rule(rule_key.products_return) else {
//                        return
//                    }
            
            rules.check_access_rule(rule_key.products_return,for: self) {
                DispatchQueue.main.async {
                    self.completeOpenReturn()
                    return
                }
            }
            
           
            
            
            
       
        }
    
    func completestock(){
        clearView()
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
               
        stockReport = storyboard.instantiateViewController(withIdentifier: "stock_report") as? stock_report
        stockReport?.parent_vc = self
        stockReport?.view.frame = container.bounds

        container.addSubview(stockReport!.view)
    }
    func openStock() {
//        guard  rules.check_access_rule(rule_key.stock) else {
//                    return
//                }
        
        rules.check_access_rule(rule_key.stock,for: self) {
            DispatchQueue.main.async {
                self.completestock()
                return
            }
        }
       

    }
    func open_sales_report_WIFI(){
      
        
        clearView()
        
//        let Session:posSessionClass =  posSessionClass.getLastActiveSession()
//        if Session.id == 0
//        {
//            return
//        }
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        reportWifiVC = storyboard.instantiateViewController(withIdentifier: "zReport") as? zReport
//        z_report?.activeSessionLast = Session
        reportWifiVC.custom_header = LanguageManager.currentLang() == .ar ? "WIFI تقرير عمليات " : "Sales report WIFI"
        reportWifiVC?.view.frame = container.bounds
        reportWifiVC.parent_vc = self
        reportWifiVC.is_report_wifi = true
        var frm = container.bounds
        frm.origin.x = -10
        reportWifiVC.container.frame = frm
        
        reportWifiVC.view.frame.origin.y = -70
        
        reportWifiVC.hideNav = true
        container.addSubview(reportWifiVC!.view)

    }
    
    func completeopen_sales_report_multi_pos(){
        clearView()
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
               
        sales_report_multi_pos_vc = storyboard.instantiateViewController(withIdentifier: "sales_report_multi_pos") as? sales_report_multi_pos
        sales_report_multi_pos_vc?.custom_header = LanguageManager.currentLang() == .ar ? "تقرير ملخص مبيعات الفروع" : "Sales summary report"
        sales_report_multi_pos_vc?.parent_vc = self
        sales_report_multi_pos_vc?.view.frame = container.bounds

         

        container.addSubview(sales_report_multi_pos_vc!.view)
    }
    
    func open_sales_report_multi_pos () {
//        guard  rules.check_access_rule(rule_key.sales_report_multi_pos) else {
//                    return
//                }
        
        rules.check_access_rule(rule_key.sales_report_multi_pos,for: self) {
            DispatchQueue.main.async {
                self.completeopen_sales_report_multi_pos()
                return
            }
        }
       

    }
    func completetillOperation(){
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "tillOperation") as! tillOperation
        
        controller.removeFromParent()
        controller.willMove(toParent: self)
        addChild(controller)
        controller.view.frame = container.bounds
        container.addSubview(controller.view)

        controller.didMove(toParent: self)
    }
    func tillOperation()
      {
//        guard  rules.check_access_rule(rule_key.till_operations) else {
//                    return
//                }
        
          rules.check_access_rule(rule_key.till_operations,for: self) {
              DispatchQueue.main.async {
                  self.completetillOperation()
                  return
              }
          }
          
       

          

          
      }
    func completeopenCancelledProductsReport(){
        clearView()
        
    let storyboard = UIStoryboard(name: "reports", bundle: nil)
    
    rangeReportViewController2 = storyboard.instantiateViewController(withIdentifier: "Products_Rang_Report2") as? Products_Rang_Report2

    rangeReportViewController2?.view.frame = container.bounds
    rangeReportViewController2?.showProduct = true
    rangeReportViewController2?.hide_discount = true
    rangeReportViewController2?.hide_net = true
    rangeReportViewController2?.hide_count_orders = true

    rangeReportViewController2?.option.get_lines_void_only = true
    rangeReportViewController2?.option.Closed = nil
    rangeReportViewController2?.option.orderSyncType = .order
    rangeReportViewController2?.option.void_status = .after_sent_to_kitchen
    rangeReportViewController2?.parent_vc = self
    rangeReportViewController2?.custom_header = MWConstants.void_products_title
    rangeReportViewController2?.sub_header = MWConstants.void_products_desc
    
    container.addSubview(rangeReportViewController2!.view)
    
    }
    //"Void Products"
    func openCancelledProductsReport() {
//        guard  rules.check_access_rule(rule_key.products_void) else {
//                    return
//                }
        rules.check_access_rule(rule_key.products_void,for: self) {
            DispatchQueue.main.async {
                self.completeopenCancelledProductsReport()
                return
            }
        }
        
          
    
        }
    func completepopenVoidProductsReport(){
        clearView()
        
    let storyboard = UIStoryboard(name: "reports", bundle: nil)
    
    rangeReportViewController2 = storyboard.instantiateViewController(withIdentifier: "Products_Rang_Report2") as? Products_Rang_Report2

    rangeReportViewController2?.view.frame = container.bounds
    rangeReportViewController2?.showProduct = true
    rangeReportViewController2?.hide_discount = true
    rangeReportViewController2?.hide_net = true
    rangeReportViewController2?.hide_count_orders = true

    rangeReportViewController2?.option.get_lines_void_only = true
    rangeReportViewController2?.option.Closed = nil
    rangeReportViewController2?.option.orderSyncType = .order
    rangeReportViewController2?.option.void_status = .before_sent_to_kitchen
    rangeReportViewController2?.parent_vc = self
    rangeReportViewController2?.custom_header = MWConstants.cancel_products_title
    rangeReportViewController2?.sub_header = MWConstants.cancel_products_dec

    container.addSubview(rangeReportViewController2!.view)
    }
    func openVoidProductsReport() {
//        guard  rules.check_access_rule(rule_key.products_void) else {
//                    return
//                }
        
        rules.check_access_rule(rule_key.products_void,for: self) {
            DispatchQueue.main.async {
                self.completepopenVoidProductsReport()
                return
            }
        }
            
        
    
        }
    
    
    func openCategorySummery() {
        clearView()
        
        
        
//        let storyboard = UIStoryboard(name: "reports", bundle: nil)
//
//        reportViewController = storyboard.instantiateViewController(withIdentifier: "ProductsReport") as? ProductsReportViewController
//        //        reportViewController?.activeSessionLast = Session
//        reportViewController?.view.frame = container.bounds
//        reportViewController?.showProduct = false
//           reportViewController?.parent_vc = self
//
//        container.addSubview(reportViewController!.view)
    }
    
    func completeopenProductsReportRange(){
        clearView()
        
   
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        rangeReportViewController2 = storyboard.instantiateViewController(withIdentifier: "Products_Rang_Report2") as? Products_Rang_Report2
 
        rangeReportViewController2?.view.frame = container.bounds
        rangeReportViewController2?.showProduct = true
        
        rangeReportViewController2?.option.orderSyncType = .order
        rangeReportViewController2?.option.void = false
        rangeReportViewController2?.option.Closed = true
        rangeReportViewController2?.option.lines_sort_by_category_asc = true

        rangeReportViewController2?.parent_vc = self
        rangeReportViewController2?.custom_header = "Products Mix"

        
        container.addSubview(rangeReportViewController2!.view)
    }
    
    func openProductsReportRange() {
        
//        guard  rules.check_access_rule(rule_key.products_mix_range) else {
//                    return
//                }
        
        rules.check_access_rule(rule_key.products_mix_range,for: self) {
            DispatchQueue.main.async {
                self.completeopenProductsReportRange()
                return
            }
        }
       
    }
    func completeopenProductsReportRange2(){
        clearView()
        
   
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        rangeReportViewController2 = storyboard.instantiateViewController(withIdentifier: "Products_Rang_Report2") as? Products_Rang_Report2
       
        rangeReportViewController2?.hideQtyFactoryView = true

        rangeReportViewController2?.view.frame = container.bounds
        rangeReportViewController2?.hide_count_orders = false
        
        rangeReportViewController2?.option.orderSyncType = .order
        rangeReportViewController2?.option.void = false
        rangeReportViewController2?.option.Closed = true
        rangeReportViewController2?.option.write_pos_id = SharedManager.shared.posConfig().id
        rangeReportViewController2?.option.lines_sort_by_category_asc = true

        rangeReportViewController2?.parent_vc = self
        rangeReportViewController2?.custom_header = "Products Mix"

        container.addSubview(rangeReportViewController2!.view)
    }
    func openProductsReportRange2() {
        
//        guard  rules.check_access_rule(rule_key.products_mix_range) else {
//                    return
//                }
        rules.check_access_rule(rule_key.products_mix_range,for: self) {
            DispatchQueue.main.async {
                self.completeopenProductsReportRange2()
                return
            }
        }
       
    }
    func completeopenCategorySummeryRange2(){
        clearView()
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        rangeReportViewController2 = storyboard.instantiateViewController(withIdentifier: "Products_Rang_Report2") as? Products_Rang_Report2
 
        rangeReportViewController2?.view.frame = container.bounds
        rangeReportViewController2?.hide_count_orders = false
        rangeReportViewController2?.showProduct = false

        rangeReportViewController2?.option.orderSyncType = .order
        rangeReportViewController2?.option.void = false
        rangeReportViewController2?.option.Closed = true
        rangeReportViewController2?.option.lines_sort_by_category_asc = true

        rangeReportViewController2?.parent_vc = self
        rangeReportViewController2?.custom_header = "Products Mix"
        rangeReportViewController2?.tag = 4
        
        container.addSubview(rangeReportViewController2!.view)
    }
    func openCategorySummeryRange2() {
        
//        guard  rules.check_access_rule(rule_key.products_mix_range) else {
//                    return
//        }
        
        rules.check_access_rule(rule_key.products_mix_range,for: self) {
            DispatchQueue.main.async {
                self.completeopenCategorySummeryRange2()
                return
            }
        }
        
       
    }
    
    func completopenDriver(groupByReturnOrder:Bool = false){
        clearView()
        
   
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        driverViewController = storyboard.instantiateViewController(withIdentifier: "driver_report") as? driver_report
 
        driverViewController?.view.frame = container.bounds
        

        driverViewController?.parent_vc = self
        driverViewController?.groupByReturnOrder = groupByReturnOrder
        driverViewController?.custom_header = "Driver report".arabic("تقرير السائقين")
        if groupByReturnOrder {
            driverViewController?.custom_header = "Drivers report for returned orders".arabic("تقرير السائقين عن الطلبات المرتجعة")

        }
        
        container.addSubview(driverViewController!.view)
    }
    
    func openDriver(groupByReturnOrder:Bool = false) {
        
//        guard  rules.check_access_rule(rule_key.driver_report) else {
//                    return
//                }
        rules.check_access_rule(rule_key.driver_report,for: self) {
            DispatchQueue.main.async {
                self.completopenDriver(groupByReturnOrder:groupByReturnOrder)
                return
            }
        }

        
    }
    
    func  openSessionList()  {
        clearView()
        
   
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        sessionListViewController = storyboard.instantiateViewController(withIdentifier: "sessionList_report") as? sessionList_report
 
        sessionListViewController?.view.frame = container.bounds
        

        sessionListViewController?.parent_vc = self
        sessionListViewController?.custom_header = "Session list report".arabic("تقرير الجلسات")

        
        container.addSubview(sessionListViewController!.view)
    }
    func completeopenCategorySummeryRange(){
        clearView()
        
        
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        rangeReportViewController2 = storyboard.instantiateViewController(withIdentifier: "Products_Rang_Report2") as? Products_Rang_Report2
        //        reportViewController?.activeSessionLast = Session
        rangeReportViewController2?.view.frame = container.bounds
        rangeReportViewController2?.showProduct = false
        
        rangeReportViewController2?.option.orderSyncType = .order
        rangeReportViewController2?.option.void = false
        rangeReportViewController2?.option.Closed = true
        rangeReportViewController2?.parent_vc = self
        rangeReportViewController2?.custom_header = "Category Summery"

        container.addSubview(rangeReportViewController2!.view)
    }
    func openCategorySummeryRange() {
        
//        guard  rules.check_access_rule(rule_key.category_summery_range) else {
//                    return
//                }
        
        rules.check_access_rule(rule_key.category_summery_range,for: self) {
            DispatchQueue.main.async {
                self.completeopenCategorySummeryRange()
                return
            }
        }
        
       
    }
    func completeopenSTCPayments(){
        clearView()
        
        
        
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        
        STCVC = storyboard.instantiateViewController(withIdentifier: "STCLogViewController") as? STCLogViewController
        //        reportViewController?.activeSessionLast = Session
        STCVC?.view.frame = container.bounds
      STCVC?.parent_vc = self
        
        container.addSubview(STCVC!.view)
    }
    func openSTCPayments() {
//        guard  rules.check_access_rule(rule_key.stc_payments) else {
//                    return
//                }
        
        rules.check_access_rule(rule_key.stc_payments,for: self) {
            DispatchQueue.main.async {
                self.completeopenSTCPayments()
                return
            }
        }
        
         
      }
 
    
    func clearView()
    {
        autoreleasepool{
            if reportWifiVC != nil
            {
                reportWifiVC!.view.removeFromSuperview()
            }
            if STCVC != nil
            {
                STCVC!.view.removeFromSuperview()
            }
            
            if z_report != nil
            {
                z_report.view.removeFromSuperview()
            }
            
            if z_report_total != nil
            {
                 z_report_total.view.removeFromSuperview()
             }
            

//            if rangeReportViewController2 != nil
//            {
//                rangeReportViewController2!.view.removeFromSuperview()
//
//            }
            
            if rangeReportViewController2 != nil
            {
                rangeReportViewController2!.view.removeFromSuperview()
                
            }
            
            if posConfig != nil {
                posConfig?.view.removeFromSuperview()
            }
            
            if stockReport != nil {
                stockReport?.view.removeFromSuperview()
            }
            
            if total_rang_report_vc != nil {
               total_rang_report_vc?.view.removeFromSuperview()
             }
            
            if sales_report_multi_pos_vc != nil {
                          sales_report_multi_pos_vc?.view.removeFromSuperview()
                        }
            
            if sessionListViewController != nil {
                sessionListViewController?.view.removeFromSuperview()
                        }
            
            if driverViewController != nil {
                driverViewController?.view.removeFromSuperview()
                        }
            
            
            sales_report_multi_pos_vc = nil
            total_rang_report_vc = nil
            z_report_total = nil
            z_report = nil
            STCVC = nil
            rangeReportViewController2 = nil
            posConfig = nil
            stockReport = nil
            sessionListViewController = nil
            driverViewController = nil
        }
        
    }
    
    
    @IBAction func btnPrint(_ sender: Any) {
         
        
        if z_report != nil {
            z_report.print()
        }
//        else if reportViewController != nil
//        {
//            reportViewController!.print()
//        }
        else if rangeReportViewController2 != nil
        {
            rangeReportViewController2!.print()
        }
        else if stockReport != nil
          {
                   stockReport!.print()
        }
        else if total_rang_report_vc != nil
        {
            total_rang_report_vc!.print()
        }
        else if sales_report_multi_pos_vc != nil
        {
            sales_report_multi_pos_vc!.print()
        }
        else if driverViewController != nil {
            driverViewController!.print()
        }
    }
    
}


extension reports_home: UITableViewDelegate ,UITableViewDataSource {
    
    func initList()
    {
        
        
        list_items = []
        let casher = SharedManager.shared.activeUser()
        if SharedManager.shared.mwIPnetwork{
            if SharedManager.shared.posConfig().isMasterTCP(){
                list_items.append(["Sales report via WIFI","icon_reports.png","تقرير مبيعات WIFI",true])

            }
        }
        if (SharedManager.shared.posConfig().pos_type?.lowercased().contains("driver_screen") ?? false){

            list_items.append(["Drivers session report","icon_reports.png","تقرير جلسات السائقين " ,casher.canAccess(for:.admin_driver_lock )])
            list_items.append(["Users report","icon_reports.png","تقرير المستخدمين" ,casher.canAccess(for:.admin_driver_lock )])

        }else{
            list_items.append(["Sales report","icon_reports.png","تقرير عمليات مفصل" ,casher.canAccess(for: .sales_report)])
            list_items.append(["Sales summary report","icon_reports.png","تقرير ملخص المبيعات",casher.canAccess(for: .sales_summary_report )])

//        list_items.append(["Order type","icon_history.png"])
//        list_items.append(["Product categories","icon_history.png"])
//        list_items.append(["Products Mix","icon_history.png"])
//         list_items.append(["Products Mix Range","icon_reports.png","مجموعة المنتجات المختلطة",((casher.access_rules.firstIndex(where: {$0.key == .products_mix_range}) != nil) ? true : false)])
        
            list_items.append(["Products Mix Range","icon_reports.png","مجموعة المنتجات المختلطة",casher.canAccess(for: .products_mix_range)])
            list_items.append(["Category summery Range","icon_reports.png","ملخص الاقسام",casher.canAccess(for:.category_summery_range )])

//        list_items.append(["Category summery","icon_history.png"])
//        list_items.append(["Category summery Range","icon_reports.png","ملخص الاقسام",((casher.access_rules.firstIndex(where: {$0.key == .category_summery_range}) != nil) ? true : false)])
            list_items.append(["STC Payments","icon_reports.png","STC مدفوعات",casher.canAccess(for: .stc_payments)])
            list_items.append([MWConstants.cancel_products_title,"icon_reports.png",MWConstants.cancel_products_title,casher.canAccess(for: .products_void)])
            list_items.append([MWConstants.void_products_title,"icon_reports.png",MWConstants.void_products_title,casher.canAccess(for:.products_void )])

            list_items.append([MWConstants.scrap_product_title,"icon_reports.png",MWConstants.scrap_product_title,casher.canAccess(for: .products_waste)])
            list_items.append(["Products Return","icon_reports.png","المرتجع",casher.canAccess(for: .products_return)])
            list_items.append(["Stock","icon_reports.png","المخزون",casher.canAccess(for: .stock)])
            list_items.append(["Till Operations","icon_reports.png","العمليات",casher.canAccess(for: .till_operations)])
            list_items.append(["Sales report multi pos","icon_reports.png","تقرير مبيعات الفروع",casher.canAccess(for: .sales_report_multi_pos)])
            list_items.append(["Discount report","icon_reports.png","تقرير الخصم",casher.canAccess(for: .discount_report)])
        list_items.append(["Driver report","icon_reports.png","تقرير السائقين",  true ])
        //"Driver report Return order"
        list_items.append(["Drivers report for returned orders","icon_reports.png","تقرير السائقين عن الطلبات المرتجعة",  true ])

        list_items.append(["Session list","icon_reports.png","تقرير الجلسات",  true ])
        }
//        list_items.append(["Sales report multiPeer","icon_reports.png","تقرير عمليات مفصل multiPeer" ,((casher.access_rules.firstIndex(where: {$0.key == .sales_report}) != nil) ? true : false)])

        
 
        
        
        self.tableview.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = list_items[indexPath.row] as? [Any]
        
        switch item![0] as? String ?? "" {
        case "Sales report via WIFI":
            open_sales_report_WIFI()
        case "Users report":
            openUsersReport()
        case "Drivers session report":
            openDriverLockreport()
        case "Sales report":
            openZreport()
        case "Sales summary report":
              openZreport_total()
        case "Products Mix":
            openProductsReport()
        case "Products Mix Range":
            openProductsReportRange2()
        case "Products Mix Range 2":
            openProductsReportRange2()
        case "Category summery":
            openCategorySummery()
        case "Category summery Range":
            openCategorySummeryRange2()
        case "Category summery Range 2":
            openCategorySummeryRange2()
        case "STC Payments":
            openSTCPayments()
        case MWConstants.cancel_products_title:
            openVoidProductsReport()
        case MWConstants.void_products_title:
            openCancelledProductsReport()
        case MWConstants.scrap_product_title:
            openScrapReport()
        case "Products Return":
            openReturn()
        case "Stock":
            openStock()
        case "Till Operations":
            tillOperation()
        case "Sales report multi pos":
            open_sales_report_multi_pos()
        case "Discount report":
            open_discount_report()
        case "Driver report":
            openDriver()
        case "Drivers report for returned orders":
            openDriver(groupByReturnOrder: true)
        case "Session list":
            openSessionList()
        case "Sales report multiPeer":
            openZreportMultiPeer()
            
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! reports_homeTableViewCell
        
        let item = list_items[indexPath.row] as? [Any]
        
        if LanguageManager.currentLang() == .ar
        {
            cell.lblTitle.text = item?[2] as? String ?? ""

        }
        else
        {
            cell.lblTitle.text = item?[0] as? String ?? ""

        }
        cell.photo.image = UIImage(name: item![1] as? String ?? "")
        
        var enable = true
        if item?.count == 4
        {
           // enable = item![3] as? Bool ?? true
        }
        
        if enable == false
        {
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        }
        
        return cell
    }
    
    
}
