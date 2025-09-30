//
//  menu_right.swift
//  pos
//
//  Created by khaled on 9/17/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class menu_left: UIViewController , load_base_apis_delegate ,pinCode_delegate {
    
    @IBOutlet var tableview: UITableView!
    
    var change_pin:change_pinCode?
    
    var list_items:  [Any] = []
    
    var parentName:String? = ""
    var delegate:menu_left_delegate?
    
    var parentViewConroller: UINavigationController?
    var cls_load_all_apis = load_base_apis()
    var count_pending = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initDashList()
    }
    
    //  func btnPriceList() {
    //        delegate?.btnPriceList()
    //    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.menuDidDisappear()
    }
    
    static func closeMenu(animated:Bool = false,completion:((Bool)->())? = nil) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.centerContainer?.closeDrawer(animated: animated, completion: completion)
        
    }
    func btnDashboard() {
        
        AppDelegate.shared.loadDashboard()
    }
    func checkOpenRule(_ rule:rule_key,completion:@escaping()->()){
        rules.check_access_rule(rule,for: self,completion: completion)
    }
    
    func btnHistory() {
//        guard  rules.check_access_rule(rule_key.show_history) else {
//            return
//        }
        checkOpenRule(rule_key.show_history) {
            DispatchQueue.main.async {
                self.completeBtnHistory()
            }
        }
        
       
    }
    func completeBtnHistory(){
        let storyboard = UIStoryboard(name: "OrdersDisplay", bundle: nil)
        let orderHistory = storyboard.instantiateViewController(withIdentifier: "order_history") as! order_history
        
        parentViewConroller?.pushViewController(orderHistory, animated: true)
        
        menu_left.closeMenu()
    }
    
    func Setting_online()
    {
        let storyboard = UIStoryboard(name: "dashboard" , bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "webViewController") as! webViewController
        controller.title_top = "Setting".arabic("الاعدادات")
        controller.url = "http://www.gofekra.com/web#action=86&menu_id=4"
        
        parentViewConroller?.pushViewController(controller, animated: true)
        
        menu_left.closeMenu()
    }
    
    func Inventory()
    {
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "webViewController") as! webViewController
        controller.title_top = "Inventory".arabic("المخزون")
        controller.url = "http://www.gofekra.com/web#action=195&model=stock.inventory&view_type=list&menu_id=98"
        
        parentViewConroller?.pushViewController(controller, animated: true)
        
        menu_left.closeMenu()
    }
    
    func dumy_orders()
    {
        let vc = dumy_data()
        parentViewConroller?.pushViewController(vc, animated: true)
        menu_left.closeMenu()
        
    }
    
    func session_expired()   {
        AppDelegate.shared.loadLogin(re_login: true)
    }
    
    func Sync()
    {
        
        let alert = UIAlertController(title: "Option", message: "Sync mode.", preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Get New only", style: .default, handler: { (action) in
            
            self.sync(get_new: true)
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Reload all", style: .default, handler: { (action) in
            
            self.sync(get_new: false)
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
            
        }))
        
        
        parentViewConroller?.present(alert, animated: true, completion: nil)
        
        
        
        
        
        
        
    }
    func sync_like_dashboard() {
        guard   !check_expire() else { return }
        alter_database_enum.loadingApp.setIsDone(with: false)
        self.syncNew(get_new: false)
    }
    func check_expire() -> Bool
    {
        if AppDelegate.shared.app_expire == true
        {
            messages.showAlert("Your license is expired")
            return true
        }
        
        return false
    }
    func syncNew(get_new:Bool)
    {
        AppDelegate.shared.loadLoading(forceSync: true, get_new: get_new)
    }
    func sync(get_new:Bool)
    {
        let storyboard = UIStoryboard(name: "apis", bundle: nil)
        cls_load_all_apis = storyboard.instantiateViewController(withIdentifier: "load_base_apis") as! load_base_apis
        
        cls_load_all_apis.delegate = self
        cls_load_all_apis.userCash = .stopCash
        cls_load_all_apis.forceSync = true
        cls_load_all_apis.get_new = get_new
        self.present(cls_load_all_apis, animated: true, completion: nil)
        
        cls_load_all_apis.startQueue()
    }
    
    func isApisLoaded(status:Bool)
    {
        cls_load_all_apis.dismiss(animated: true, completion: nil)
        
        menu_left.closeMenu()
        
    }
    
    
    func tillOperation()
    {
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "tillOperation") as! tillOperation
        
        parentViewConroller?.pushViewController(controller, animated: true)
        
        menu_left.closeMenu()
        
    }
    
    func openZreport()
    {
        let Session  =  pos_session_class.getLastActiveSession()
        if Session == nil
        {
            return
        }
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "zReport") as! zReport
        
        vc.activeSessionLast = Session
        
        parentViewConroller?.pushViewController(vc, animated: true)
        
        menu_left.closeMenu()
    }
    
    func  ChangeUser() {
        
        
        res_users_class.deleteDefault()
        AppDelegate.shared.loadLoading()
        
    }
    func Log()
    {
        
        if AppDelegate.shared.enable_debug_mode_code() == false
        {
            //        #if DEBUG
            //        #else
                    
//                    guard  rules.check_access_rule(rule_key.log) else {
//                        return
//                    }
            
            checkOpenRule(rule_key.log) {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "connectionLog", bundle: nil)
                    let  connectionLog = storyboard.instantiateViewController(withIdentifier: "connectionLog_list") as? connectionLog_list
                    connectionLog!.modalPresentationStyle = .fullScreen
                    
                    self.present(connectionLog!, animated: true, completion: nil)
                }
            }
            //        #endif
        }


      
        
       
        
    }
    
    func sessionsLog_list()
    {
        if AppDelegate.shared.enable_debug_mode_code() == false
        {
//            #if DEBUG
//
//            #else
//            guard  rules.check_access_rule(rule_key.log) else {
//                return
//            }
            checkOpenRule(rule_key.log) {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "connectionLog", bundle: nil)
                    let  connectionLog = storyboard.instantiateViewController(withIdentifier: "sessionsLog_list") as? sessionsLog_list
                    connectionLog!.modalPresentationStyle = .fullScreen
                    
                    self.present(connectionLog!, animated: true, completion: nil)
                }
            }
//            #endif
        }
      
        
       
        
    }
    
    func printerLog_list()
    {
        
//        guard  rules.check_access_rule(rule_key.log) else {
//            return
//        }
        checkOpenRule(rule_key.log) {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "printer_log", bundle: nil)
                let  connectionLog = storyboard.instantiateViewController(withIdentifier: "printer_log_list") as? printer_log_list
                connectionLog!.modalPresentationStyle = .fullScreen
                
                self.parentViewConroller?.pushViewController(connectionLog!, animated: true)
                menu_left.closeMenu()
            }
        }
        
       

//        self.present(connectionLog!, animated: true, completion: nil)
        
    }
    func ingenicoLog_list()
    {
        
//        guard  rules.check_access_rule(rule_key.log) else {
//            return
//        }
        checkOpenRule(rule_key.log) {
            DispatchQueue.main.async {
                let vc:IngenicoLogVC = IngenicoLogVC()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        
    }
    
    func cash_in_out(cash_out:Bool)
    {
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "cash_in_out") as! cash_in_out
        vc.cash_out = cash_out
        
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func cash_in()
    {
        cash_in_out(cash_out: false)
        
    }
    
    
    func cash_out()
    {
        
        cash_in_out(cash_out: true)
        
        
    }
    
    func change_pin_code()
    {
        change_pin = change_pinCode()
        change_pin?.parent_vc = parentViewConroller
        change_pin?.change()
    }
    
    func completeshow_all_promotion(){
        let list = options_listVC(nibName: "options_listVC", bundle: nil)
        list.modalPresentationStyle = .formSheet
//        list.modalTransitionStyle = .crossDissolve
        
        list.title = "Pos Promotion."
 
        let list_promotion = pos_promotion_class.getAll()
        
        for item in list_promotion
        {
            let prom = pos_promotion_class(fromDictionary: item)
            list.add(title: prom.display_name , data: prom)

        }
 
        
        options_listVC.show_option(list:list,viewController: self, sender: nil   )
        list.hideClearBtnFlag = true

        list.didSelect_object = {    item in
             
            let vc =   promotionViewVC(nibName: "promotionViewVC", bundle: nil)
            vc.promotion = item as? pos_promotion_class
 
//            vc.modalPresentationStyle = .overFullScreen
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func show_all_promotion()
    {
        rules.check_access_rule(rule_key.show_pos_promotion,for: self) {
            DispatchQueue.main.async {
                self.completeshow_all_promotion()
                return
            }
        }
    }
    
}


extension menu_left: UITableViewDelegate ,UITableViewDataSource {
    
    func initDashList()
    {
        count_pending = SharedManager.shared.get_count_pending_orders()
        let casher = SharedManager.shared.activeUser()
        
        list_items = []
        
        
        let is_kds = AppDelegate.shared.load_kds
        
        list_items.append(["header","POS","نقاط البيع"])
        
        if   is_kds == false
        {
            let activeSession = pos_session_class.getActiveSession()
            if activeSession != nil
            {
                list_items.append(["RESUME Shift","icon_dashboard-p.png","استئناف"])
            }
        }
        list_items.append(["Dashboard","icon_dashboard.png","اللوحه"])
        
        //if casher.canAccess(for: .memberShips){
            list_items.append(["MemberShips","icon_history.png","الاشتراكات"])
        //}
       // if casher.canAccess(for: .return_by_search){
            list_items.append(["Return orders","icon_history.png","إرجاع الطلبات"])
            
       // }
let accessOrders = true //(casher.canAccess(for: .show_history))
        //list_items.append(["Orders","icon_history.png","الطلبات",accessOrders])
         if count_pending > 0 {
            list_items.append(["Orders \(count_pending)", "icon_history-p.png", "\(count_pending) الطلبات", accessOrders])
        } else {
            list_items.append(["Orders", "icon_history-p.png", "الطلبات", accessOrders])
        }
        
        
//        let accessForReport = ( casher.canAccessForAny(keies: [.sales_report,.discount_report, .sales_summary_report,.driver_report ])
//                                    && is_kds == false )
//        if  casher.pos_user_type == "manager" && is_kds == false
//        if accessForReport
//        {
//            
            list_items.append(["Reports","icon_reports.png","التقارير"])
       // }
        
//        let access_pos_promotion = casher.canAccess(for: .show_pos_promotion)
//            if access_pos_promotion
//            {
                list_items.append(["Pos Promotion","icon_reports.png","عروض نقطة البيع"])
           // }

        
        // ===============================================================
        let access_in_stock = true //casher.canAccess(for: .in_stock_management)
        let access_adjustment = true //casher.canAccess(for: .adjustment_stock_management)
        let access_stock_request =  true //casher.canAccess(for: .request_stock_order_management)
        let accessForStock = true //(( access_in_stock || access_adjustment || access_stock_request ) && is_kds == false )

        if accessForStock {
        list_items.append(["header","Stock","المخزون"])
        }
        list_items.append(["Products avaliablity","btn_setting-p.png","رصيد المنتجات"])

        if access_stock_request  {
        list_items.append(["Stock Request","icon_reports-p.png","طلب المخزون",true])
        }
        if access_in_stock {
        list_items.append(["In Stock","btn_setting-p.png","وارد المخزن",true])
        }
        if access_adjustment {
        list_items.append(["Adjustments","btn_setting-p.png","تعديلات المخزن",true])
        }
        if accessForStock {
        list_items.append(["Stock report","icon_reports-p.png","تقرير المخزون",true])
        }
        // ===============================================================
        list_items.append(["header","Settings","الاعدادات"])
        
        if parentName != "setting" {
            
//            if casher.pos_user_type == "manager"
//            {
                
             
                let enable_settings = true //casher.canAccess(for:  .setting)
                list_items.append(["Setting","btn_setting.png","الاعدادات",enable_settings])
          //  }
        }
        
//        list_items.append(["Upload database","btn_setting-p.png","رفع الداتا بيز",true])

        
        var enable_log =  true //casher.canAccess(for: .log )
        var show_log =  SharedManager.shared.appSetting().show_log
        
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
//            #if DEBUG
           // enable_log = true
           // show_log = true
//            #endif
        }
  

        if  show_log == true
        {

//            list_items.append(["Log","icon_log-p.png","السجل",enable_log])
            
            if is_kds == false
            {
//                list_items.append(["Sessions Log","icon_log-p.png","سجل الجلسات",enable_log])
                
            }
            
            if AppDelegate.shared.enable_debug_mode_code() == true
            {
//                #if DEBUG
                list_items.append(["dumy orders","icon_log-p.png","طلبات وهمية",enable_log])
                
//                #endif
            }
       
            
//            list_items.append(["Printer Log","icon_log-p.png","عمليات الطابعه",enable_log])
//            list_items.append(["Ingenico Log","icon_log-p.png","عمليات الدفع",enable_log])
        }
        


        
        
        // ===============================================================
//        list_items.append(["header","User","المستخدم"])
        
        list_items.append(["Change Pin Code","icon_change_pin-p.png","تغيير الرقم السري"])
        list_items.append(["Lock Screen","icon_lock-p.png","اغلاق الشاشة"])
        
        // ===============================================================
        
        if SharedManager.shared.session_expired {
            list_items.append(["header","Alert","Alert"])
            
            list_items.append(["Session expired","icon_error.png","انتهت الجلسة"])
        }
        
        // ===============================================================
//        list_items.append(["header","Langauge","اللغه"])
        
        if LanguageManager.currentLang() == .ar
        {
            list_items.append(["English","1","English"])
        }
        else
        {
            list_items.append(["العربيه","2","العربيه"])
        }
        
        
        
        self.tableview.reloadData()
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let item = list_items[indexPath.row] as? [Any]
        var txt = item?[0] as? String ?? ""
        if txt == "header"
        {
            return
        }
        
        
        if parentName?.lowercased() == txt.lowercased()
        {
            return
        }
        
        if (item?[1] as? String ?? "")  == "1"
        {
            LanguageManager.setLang(.en)
            AppDelegate.shared.loadLoading()
            return
        }
        else if (item?[1] as? String ?? "") == "2"
        {
            LanguageManager.setLang(.ar)
            AppDelegate.shared.loadLoading()
            return
        }
        if txt.hasPrefix("Orders") {
            txt = "Orders"
        }
        switch txt {
        //        case "Home":
        //            AppDelegate.shared.loadHome()
        case "Dashboard" :
            
            let bundleID = Bundle.main.bundleIdentifier
            if bundleID?.contains("kds") ?? false {
                AppDelegate.shared.loadKDS()
            } else {
                AppDelegate.shared.loadDashboard()
            }
        case "Products avaliablity":
            AppDelegate.shared.initialMWCategoryVC()
        case "MemberShips":
            AppDelegate.shared.initialMemberShipVC()
        case "Return orders":
            AppDelegate.shared.initialReturnOrderByUIDVC()
        case "Orders" :
            btnHistory()
        case "Price list" :
            delegate?.btnPriceList( tableView.cellForRow(at: indexPath)!)
        case "Setting" :
            openSetting()
//            get_pin(title: "Code")
        case "Inventory" :
            AppDelegate.shared.loadglobal_links() 
        case "Setting online" :
            Setting_online()
        case "Sync" :
//            Sync()
            sync_like_dashboard()
        case "Till Operations":
            tillOperation()
        case "Reports":
            AppDelegate.shared.loadReports()
        case "Lock Screen":
            ChangeUser()
        case "Log":
            Log()
        case "Sessions Log":
            
            sessionsLog_list()
            
        case  "Printer Log":
            
            printerLog_list()
        case "Cash in":
            cash_in()
        case "Cash out":
            cash_out()
        case "Change Pin Code":
            change_pin_code()
        case "dumy orders":
            dumy_orders()
        case "RESUME Shift" :
//            AppDelegate.shared.loadHome()
            let DriverLockRule = (SharedManager.shared.posConfig().pos_type?.lowercased().contains("driver_screen") ?? false)
       //     let DriverLockRule = false// rules.check_access_rule(rule_key.driver_lock,show_msg: false)
            if DriverLockRule {
                AppDelegate.shared.loadDriverLockHome()
            }else{
                AppDelegate.shared.loadHome()
            }
        case "Driver Lock" :
//            AppDelegate.shared.loadDriverLockHome()
            let DriverLockRule = (SharedManager.shared.posConfig().pos_type?.lowercased().contains("driver_screen") ?? false)
           // let DriverLockRule = false //rules.check_access_rule(rule_key.driver_lock,show_msg: false)
            if DriverLockRule {
                AppDelegate.shared.loadDriverLockHome()
            }else{
                AppDelegate.shared.loadHome()
            }
        case "Session expired":
            session_expired()
        case "Upload database":
            upload_database()
        case "In Stock":
            openInStockSC()
        case "Adjustments":
            openAdjustmentsSC()
        case "Ingenico Log":
            ingenicoLog_list()
        case "Pos Promotion":
            show_all_promotion()
        case "Stock Request":
            openStockRequest()
        case "Stock report":
            openViewReportStockVC()
        default: break
            
        }
        
        
        
    }
    func openViewReportStockVC(){
//        guard  rules.check_access_rule(rule_key.stock) else {
//                    return
//                }
        
        checkOpenRule(rule_key.stock) {
            DispatchQueue.main.async {
                let viewReportVC = ViewAndPrintReportVCRouter.createModule(htmlReport:"stock_report")
            viewReportVC.modalPresentationStyle = .pageSheet
            viewReportVC.modalTransitionStyle = .coverVertical
            self.present(viewReportVC, animated: true, completion: nil)
            menu_left.closeMenu()
            }
        }
           
        
    }
    
    func openStockRequest(){
        AppDelegate.shared.loadStockRequest()

//       let vc = OrderSrockRquestListRouter.createModule()
//        parentViewConroller?.pushViewController(vc, animated: true)
//        menu_left.closeMenu()
        
//        let controller = InStockRouter.createModule(with: STOCK_TYPES.REQUEST_STOCK_OREDER)
//        parentViewConroller?.pushViewController(controller, animated: true)
//        menu_left.closeMenu()


    }
    func get_pin(title:String)
    {
        let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "pinCode") as! pinCode
        controller.delegate = self
        controller.mode_get_only = true
        controller.title_vc = title
        self.present(controller, animated: true, completion: nil)
    }
    
    func closeWith(pincode:String)
    {
        //    #if DEBUG
        //    openSetting()
        //    return
        //    #endif
        
        
        //        if  pincode == "122333444455555"
        //       {
//        openSetting()
        //       }
        //       else
        //       {
        //
        //           messages.showAlert("invalid pin code".arabic("الرقم السرى خطأ"))
        //
        //
        //       }
        
    }
    func openAdjustmentsSC(){
        rules.check_access_rule(rule_key.adjustment_stock_management,for: self) {
            DispatchQueue.main.async {
                AppDelegate.shared.loadAdjustment()
            }
        }
//        let controller = AdjustmentRouter.createModule()
//        parentViewConroller?.pushViewController(controller, animated: true)
//        menu_left.closeMenu()


    }
    func openInStockSC(){
        
       
        rules.check_access_rule(rule_key.in_stock_management,for: self) {
            DispatchQueue.main.async {
                AppDelegate.shared.loadInStock()
            }
        }
//        let controller = InStockRouter.createModule(with: .IN_STOCK_ALL)
//        parentViewConroller?.pushViewController(controller, animated: true)
//        menu_left.closeMenu()


//        let vc = InStockRouter.createModule()
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
        
    }
    func openSetting()
    {
        SharedManager.shared.updateLastActionDate()
        
//        if AppDelegate.shared.enable_debug_mode_code() == false
//        {
//            #if DEBUG
//            #else
//            guard  rules.check_access_rule(rule_key.setting) else {
//                return
//            }
            
            checkOpenRule(rule_key.setting) {
                DispatchQueue.main.async {
                    let bundleID = Bundle.main.bundleIdentifier
                    if bundleID?.contains("kds") ?? false {
                        AppDelegate.shared.loadSetting_kds()
                    } else {
                        AppDelegate.shared.loadSetting()
                    }
                }
            }
//            #endif
      //  }
      
      
        
        
       
    }
    
    func upload_database()
    {
        AppDelegate.shared.auto_export.upload_all()
        menu_left.closeMenu()

        messages.showAlert("Backup is  in process".arabic("جارى الرفع فى الخلفيه"))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! menu_leftTableViewCell
        
        let item = list_items[indexPath.row] as? [Any]
        
        let txt = item?[0] as? String ?? ""
        
       

        
        
        
        if txt == "header"
        {
            
            var tit = item![1] as? String ?? ""
            if LanguageManager.currentLang() == .ar
            {
                tit = item![2] as? String ?? ""
            }
            else
            {
                cell.lblTitle.font = UIFont.init(name: String(format: "%@-%@", app_font_name , "Medium"), size: 18)
                
            }
            
            cell.lblTitle.text = tit
            
            cell.photo.isHidden = true
            cell.bg_header_cell.isHidden = true
            cell.contentView.backgroundColor = UIColor.init(hexString: "#4e39af")
            cell.lblTitle.textColor = UIColor.init(hexString: "#FFFFFF")
            cell.selectionStyle = .none
        }
        else
        {
            
            var tit:String = txt
            if LanguageManager.currentLang() == .ar
            {
                tit = item![2] as? String ?? ""
            }
            
            cell.bg_header_cell.isHidden = true
            cell.contentView.backgroundColor = UIColor.init(hexString: "#e9e6f6")
            cell.lblTitle.textColor = UIColor.init(hexString: "#4e39af")
            cell.photo.isHidden = false
            
            cell.lblTitle.text = String(format: "%@", tit)
            cell.photo.image = UIImage(name: item![1] as? String ?? "")
            
            if parentName?.lowercased() == txt.lowercased()
            {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            }
            
            var enable = true
            if item?.count == 4
            {
                enable = item![3] as? Bool ?? true
            }
            
            if enable == false
            {
                cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
            }
        }
        
        
        
        
        return cell
    }
    
    
}

protocol menu_left_delegate {
    func btnPriceList(_ sender: Any)
    func menuDidDisappear()

    
}
extension menu_left_delegate {
    func menuDidDisappear(){}
}
extension UINavigationController{
public func removePreviousController(){
    let totalViewControllers = self.viewControllers.count
    self.viewControllers.removeSubrange(0..<totalViewControllers - 1)
}}
