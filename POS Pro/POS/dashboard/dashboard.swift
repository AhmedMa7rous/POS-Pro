//
//  dashboard.swift
//  pos
//
//  Created by khaled on 9/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCrashlytics

class dashboard: baseViewController ,enterBalance_delegate,menu_left_delegate, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate{
    
    //MARK: Outlets
    @IBOutlet weak var rightHolderview: ShadowView!
    @IBOutlet weak var view_statistics: UIView!
    @IBOutlet weak var lblCasherName: KLabel!
//    @IBOutlet weak var lblCasherFirstChar: KLabel!
    @IBOutlet weak var lblloign: KLabel!
    @IBOutlet weak var lblpostion: KLabel!
    @IBOutlet weak var btnEndShift: KButton!
    @IBOutlet weak var btnStartShift: KButton!
    @IBOutlet weak var startShiftLabel: KLabel!
    @IBOutlet weak var btnOpenDrawer: KButton!
//    @IBOutlet weak var btnLogout: UIButton!
//    @IBOutlet var btn_cash_in: KButton!
    @IBOutlet var btn_rule_info: KButton!
//    @IBOutlet var btn_cash_out: KButton!
//    @IBOutlet weak var lblInfo: KLabel!
//    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btn_lock_print: KButton!
    @IBOutlet weak var printEndSession: KLabel!
    @IBOutlet var photo: KSImageView!
//    @IBOutlet weak var lblTitle: KLabel!
    @IBOutlet weak var operationLabel: KLabel!
    @IBOutlet weak var endHolderView: ShadowView!
    @IBOutlet weak var printEndHolderView: ShadowView!
    //MARK: Variables
    let con:api = SharedManager.shared.conAPI()
    var currentSession:pos_session_class?
    var getBalance :enterBalanceNew!
    var ordersStatistics: ordersStatisticsViewController!
    var hideBack:Bool = true
    var isDayOpen = false
    var change_pin:change_pinCode?
    var activeSession:pos_session_class?
    var cls_load_all_apis:load_base_apis! = load_base_apis()
    let user = SharedManager.shared.activeUser()

    private var didConfirmBalance = false
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        SharedManager.shared.disCounectMultiPeer()

        
        currentSession = nil
        getBalance = nil
//        ordersStatistics = nil
        
    }
    
    override func viewDidLoad() {
        stop_zoom = true
        super.viewDidLoad()
        SharedManager.shared.updateLastActionDate()
        DispatchQueue.main.async {
            SharedManager.shared.setGloobalObject()
            AppDelegate.shared.hitUpdateFcmTokenAPI()
        }
        
        AppDelegate.shared.run_poll()
        
//        SharedManager.shared.initalMultipeerSession()

        
//        btn_cash_in.isHidden = true
//        btn_cash_out.isHidden = true
        MWPrinterMigration.shared.setDefaultForMultibrandPrinterSetting()

             
        //        check_auto_close_session()
        
        //        test()
//        PrinterMacAddressInteractor.shared.setMacAddress()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rightHolderview.roundCorners(corners: [.topRight, .bottomRight], radius: 24)
        if LanguageManager.currentLang() == .ar {
            operationLabel.textAlignment = .right
        } else {
            operationLabel.textAlignment = .left
        }
    }
    
    func check_rules()
    {
/*
        if  user.canAccess(for: .open_drawer) == false
        {
            btnOpenDrawer.isEnabled = false
            btnOpenDrawer.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            
        }
        let oldRule = user.canAccess(for: .open_session)
        if !oldRule {
            let openSessionRule = user.canAccess(for: .open_session_rule)
            let resumSessionRule = user.canAccess(for: .resume_session)
            let closeSessionRule = user.canAccess(for: .close_session)
            if let activeSession = activeSession, activeSession.isOpen
            {
                if !resumSessionRule{
                    btnStartShift.isEnabled = false
                    btnStartShift.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
                }
               
            }else{
                if !openSessionRule{
                    btnStartShift.isEnabled = false
                    btnStartShift.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
                }
            }

            if !closeSessionRule{
                btnEndShift.isEnabled = false
                btnEndShift.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            }
        }
 */
        
        
        
     
//        if  user.canAccess(for: .open_session) == false
//        {
//            btnStartShift.isEnabled = false
//            btnStartShift.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
//         
//            btnEndShift.isEnabled = false
//            btnEndShift.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MaintenanceInteractor.shared.searchBluetoothPrinter()

        AppDelegate.shared.check_if_session_not_closed()
        
        activeSession = pos_session_class.getActiveSession()

        if SharedManager.shared.posConfig().cash_control == true
        {
             if activeSession != nil
            {
//                btn_cash_in.isHidden = false
//                btn_cash_out.isHidden = false
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        addStatitics()
        getUserInfo()
        refreshUI()
        
        res_users_class.set_frist_login()
        
        check_rules()
        
    }
    
    
//    func check_auto_close_session()
//    {
//        let setting = SharedManager.shared.appSetting()
//        let enable_auto_close = setting.enable_auto_close_session
//        if enable_auto_close == true
//        {
//            let time = setting.time_auto_close_session
//            let time_now = Date().toString(dateFormat: "hh:mm a", UTC: false)
//
//            let date_close = Date(strDate: time, formate: "hh:mm a", UTC: false)
//            let date_now = Date(strDate: time_now, formate: "hh:mm a", UTC: false)
//
//            if date_now >= date_close
//            {
//                 if activeSession != nil
//                {
//                    activeSession!.end_session = baseClass.get_date_now_formate_satnder() // must to be UTC  as server online
//                    activeSession!.end_Balance =   0
//                    activeSession!.isOpen = false
//
//                    activeSession!.saveSession()
//
//                    pos_session_class.force_close_all_sessions()
//                }
//
//
//            }
//
//        }
//    }
    
    func test()
    {
        
        let opetions = ordersListOpetions()
        opetions.Closed = true
        opetions.Sync = true
        opetions.orderDesc = false
        opetions.orderSyncType = .all
        opetions.page = 0
        opetions.LIMIT = 1
        opetions.parent_product = true
        opetions.write_pos_id = SharedManager.shared.posConfig().id
        opetions.orderID = 1021
        
        let arr = pos_order_helper_class.getOrders_status_sorted(options: opetions)
        
        
        let data:[String:Any] = pos_order_builder_class.bulid_order_data(order:arr[0], for_pool: nil)
        
        SharedManager.shared.printLog(data)
        
    }
    
   
    
  
    
    
    func addStatitics()
    {
        if ordersStatistics != nil
        {
            return
//            ordersStatistics.view.removeFromSuperview()
        }
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        ordersStatistics = storyboard.instantiateViewController(withIdentifier: "ordersStatisticsViewController") as? ordersStatisticsViewController
        ordersStatistics.parent_vc = self
        
        view_statistics.addSubview(ordersStatistics.view)

        
        ordersStatistics.view.frame = view_statistics.bounds
        ordersStatistics.view.autoresizingMask = [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
    }
    
    func getUserInfo()
    {
        let chasher = SharedManager.shared.activeUser()
        if chasher.fristLogin! == ""
        {
            chasher.fristLogin =  String( Date.currentDateTimeMillis())   // ClassDate.getTimeINMS()
            chasher.save()
        }
        
        
        lblCasherName.text =  chasher.name
        lblpostion.text = chasher.pos_user_type
        
        
        if(chasher.image != "")
        {
            SharedManager.shared.loadImageFrom(.images,
                                               in:.res_users,
                                               with: chasher.image ?? "",
                                               for: self.photo)

        }
        
        lblloign.text = Date.init(millis:   Int64(chasher.lastLogin ?? "0")! ).toString(dateFormat: baseClass.date_fromate_short, UTC: false)
        
        
        
    }
    
    func refreshUI()
    {

        
    
        var is_seesion_open = false
        if activeSession != nil
        {
            if activeSession!.isOpen == true
            {
                is_seesion_open = true
            }
        }

        
        if is_seesion_open == false
        {
            
            isDayOpen = false
            
            DispatchQueue.main.async {
                 
        
                self.btnStartShift.isEnabled = true
//                self.btnEndShift.isEnabled = false
                self.btnEndShift.isHidden = true

//                self.btnStartShift.setTitle(LanguageManager.text("Start session", ar: "ابدأ الجلسه"), for: .normal)
                self.startShiftLabel.text = LanguageManager.text("Start session", ar: "ابدأ الجلسه")
//                self.btnEndShift.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            
//                self.btn_lock_print.isHidden = !SharedManager.shared.appSetting().show_print_last_session_dashboard
                self.printEndHolderView.isHidden = !SharedManager.shared.appSetting().show_print_last_session_dashboard
                self.endHolderView.isHidden = true
//                self.btn_lock_print.backgroundColor = UIColor.white
//                 self.btn_lock_print.setTitleColor( UIColor.red.withAlphaComponent(0.5), for: .normal)
//                self.printEndSession.textColor =  UIColor.red.withAlphaComponent(0.5)
                if self.activeSession == nil && SharedManager.shared.appSetting().show_print_last_session_dashboard
                {
//                    self.btn_lock_print.setTitle(LanguageManager.text("Print last session", ar: "اطبع اخر جلسه"), for: .normal)
                    self.printEndSession.text = LanguageManager.text("Print last session", ar: "اطبع اخر جلسه")
                }
                
            }
            
           let lastSession = pos_session_class.getLastActiveSession()
            if lastSession != nil
            {
                set_shift_info(shift: lastSession!)
                
            }
            
            
            
      
            
        }
        else
        {
            isDayOpen = true
            
            
            set_shift_info(shift: activeSession!)
            
//            btnStartShift.setTitle(LanguageManager.text("RESUME session", ar: "استئناف الجلسه") , for: .normal)
            self.startShiftLabel.text = LanguageManager.text("Resume session", ar: "استئناف الجلسه")
            btnStartShift.isEnabled = true
            btnEndShift.isHidden = false
            
//            btnEndShift.backgroundColor = UIColor.white
            
//            btn_lock_print.isHidden = true
            printEndHolderView.isHidden = true
            endHolderView.isHidden = false
//            btn_lock_print.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
//            self.btn_lock_print.setTitleColor(btnEndShift.titleLabel?.textColor, for: .normal)

            
        }
        
        btnEndShift.isHighlighted  =  !btnEndShift.isEnabled
        btnStartShift.isHighlighted  =  !btnStartShift.isEnabled
        
        
        ordersStatistics.reloadTable()
    }
    
    
    func set_shift_info(shift:pos_session_class)
    {
        ordersStatistics.cashierID = shift.cashierID
        
        ordersStatistics.shift_id = String( shift.id)
        ordersStatistics.business_day = Date(strDate: shift.start_session!, formate: baseClass.date_fromate_satnder ,UTC: true).toString(dateFormat: baseClass.date_fromate_short , UTC: false) //  baseClass.getDateFormate(date: shift.start_session , formate:baseClass.date_fromate_satnder ,returnFormate: "yyyy-MM-dd"  )
        ordersStatistics.shift_start_date = Date(strDate: shift.start_session!, formate: baseClass.date_fromate_satnder ,UTC: true).toString(dateFormat: baseClass.date_time_fromate_short, UTC: false) // baseClass.getDateFormate(date: shift.start_session , formate: baseClass.date_fromate_satnder )
        
        if shift.end_session  != ""
        {
            ordersStatistics.shift_end_date =   Date(strDate: shift.end_session!, formate: baseClass.date_fromate_satnder ,UTC: true).toString(dateFormat: baseClass.date_time_fromate_short, UTC: false)  // baseClass.getDateFormate(date: shift.end_session , formate:  baseClass.date_fromate_satnder  )
        }
        
        
        ordersStatistics.shift_start_balance = shift.start_Balance.toIntString()
        
        if shift.isOpen == true
        {
            ordersStatistics.session_status = "Open"
            
        }
        else
        {
            ordersStatistics.session_status = "Closed"
            
        }
        
        if shift.isOpen
        {
            if shift.end_Balance != 0
            {
                ordersStatistics.shift_end_balance = shift.end_Balance.toIntString()
                
            }
            else
            {
                ordersStatistics.shift_end_balance = ""
            }
        }
        else
        {
          
                ordersStatistics.shift_end_balance = shift.end_Balance.toIntString()
                
         
        }
       
        
        
        ordersStatistics.reloadTable()
    }
    
    
    func openHome()
    {
         if activeSession != nil
        {
           
             let DriverLockRule = (SharedManager.shared.posConfig().pos_type?.lowercased().contains("driver_screen") ?? false)
             if DriverLockRule {
                 AppDelegate.shared.loadDriverLockHome()
             }else{
                 AppDelegate.shared.loadHome(checkRule: false)
             }
        }
        else
        {
            messages.showAlert(LanguageManager.text("please start session.", ar: "من فضلك ابدأ الجلسة."))
        }
        
    }
    
    @IBAction func btnChangeUser(_ sender: Any) {
        guard   !check_expire() else {
            return
        }
        
//        if !(SharedManager.shared.posConfig().name?.lowercased().contains("rajhi_issue") ?? false) {
//            exit(0)
//
//        }
        AppDelegate.shared.login_users(activeSession: nil )
        
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        guard   !check_expire() else {
            return
        }
        
        
        AppDelegate.shared.logOut()
        
    }
    
    
    @IBAction func btnOpenMenu(_ sender: Any) {
        guard   !check_expire() else {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    
    func btnPriceList(_ sender: Any)
    {
        
    }
    
    
    var enablePrintDrawer:Bool = true
    var isStartOpenDrawer:Bool = false

    @IBAction func btnOpenDrawer(_ sender: Any) {
//        InvoiceSignature.shared.loadInvoiceSignature(hashInvoice: "sadas")
//        alert(msg: "test aleart")
        
        guard   !check_expire() else {
            return
        }
        
//        guard  rules.check_access_rule(rule_key.open_drawer) else {
//            return
//        }
        rules.check_access_rule(rule_key.open_drawer,for: self) {
            DispatchQueue.main.async {
                self.completeOpenDrawer()
            }
        }
        
      
        
        
    }
    func completeOpenDrawer(){
        if enablePrintDrawer == true
        {
            enablePrintDrawer = false
            if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
                self.startOpenDrawer(posPrinters:restaurant_printer_class.get(printer_type: .POS_PRINTER),index: 0)
            }else{
            runner_print_class.openDrawer_background()
            }
            
            self.perform(#selector(enablebtnDrawer), with: nil, afterDelay: 3)
        }
    }
    func startOpenDrawer(posPrinters:[restaurant_printer_class],index:Int){
        if self.isStartOpenDrawer{
            return
        }
        if posPrinters.count > index{
            let printer = posPrinters[index]
        DispatchQueue.global(qos: .background).async{
            if !self.isStartOpenDrawer{
                self.isStartOpenDrawer = true
        MWPrinterSDK.shared.openDrawer(for: printer) { successOpen in
            SharedManager.shared.printLog("successOpen == \(successOpen)")
            self.isStartOpenDrawer = false
            self.startOpenDrawer(posPrinters:posPrinters,index:index+1)
        }
            
        }
        }
        }
        
    }
    
    
    
    @objc func enablebtnDrawer()
    {
        enablePrintDrawer = true
    }
    
    
    
    func get_cash_local() -> Double
    {
        var amount:Double = 0.0
        
        let lastSession = pos_session_class.getLastActiveSession()
        amount = lastSession?.end_Balance ?? 0
        
        return amount
    }
    
    func actionStartShiftBtn(_ sender: Any){
        guard   !check_expire() else {
            return
        }
        let rule = (activeSession?.isOpen) ?? false ? rule_key.open_session_rule : rule_key.resume_session
        
//        guard  rules.check_access_rule(rule_key.open_session) else {
//            return
//        }
        
        rules.check_access_rule(rule,for: self) {
            DispatchQueue.main.async {
                self.completeStartShift(sender:sender)
            }
        }
        
       
 
    }
    
    func completeStartShift(sender: Any){
        if let selectBrandvc = SelectBrandVC.createModule(sender as! UIView,option: .START_SESSION) as? SelectBrandVC {
            selectBrandvc.completionBlock = { selectDataList in
                self.startSessionCompletion(sender)
            }
            self.present(selectBrandvc, animated: true, completion: nil)
        }else{
            startSessionCompletion(sender)
        }
        self.endHolderView.isHidden = true

    }
    
    
    @IBAction func btnStartShift(_ sender: Any) {

//        DispatchQueue.global(qos: .background).async {
//
//            SharedManager.shared.poll?.get_orders_sync_all_online()
//
//            SharedManager.shared.poll?.get_last_id()
//        }
//
//        return
        WaringToast.shared.handleShowAlertWaring(complete: nil)
        LicenseInteractor.shared.handleShowAlertLicense(for: [.SESSION]) {
            self.actionStartShiftBtn(sender)
        }
    }
    func startSessionCompletion(_ sender: Any){
        if activeSession != nil
        {
            if activeSession!.isOpen == true
            {
               
                DispatchQueue.global(qos: .background).async {
//                    SharedManager.shared.poll?.get_orders_sync_all_online()
              SharedManager.shared.poll?.last_id = nil
              SharedManager.shared.poll?.check_poll()
              }
                openHome()
                return

            }
        }
        let  amount = get_cash_local()
        if (SharedManager.shared.posConfig().pos_type?.lowercased().contains("waiter") ?? false)
        {
            startSession()
            MWLocalNetworking.sharedInstance.startSession()
        }else{
            self.start_shift(amount: amount, sender)

        }
        
            
       
//        MWQueue.shared.multisessionQueue.async {
          DispatchQueue.global(qos: .background).async {
//              SharedManager.shared.poll?.get_orders_sync_all_online()

        SharedManager.shared.poll?.last_id = nil
        SharedManager.shared.poll?.check_poll()
        }
       

    }
    
    func start_shift(amount:Double,_ sender: Any)
    {
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        getBalance = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew
        getBalance.modalPresentationStyle = .popover
        
        getBalance.delegate = self
        getBalance.key = "start_session"
        getBalance.title_vc =  LanguageManager.text("Open session cash", ar: "نقود الجلسة المفتوحة")
        if amount != 0
        {
            getBalance.initValue  = amount.toIntString()
            
        }
        getBalance.disable = false
        
        let popover = getBalance.popoverPresentationController!
        popover.permittedArrowDirections = .left
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        
        popover.delegate = self
        getBalance.presentationController?.delegate = self
        didConfirmBalance = false
        
        self.present(getBalance, animated: true, completion: nil)
    }
    func completeEndSfit(_ sender: Any){
        MWQueue.shared.firebaseQueue.async {
//             DispatchQueue.global(qos: .background).async {
        FireBaseService.defualt.updateInfoPOS()
            FireBaseService.defualt.updateInfoTCP("close_shift")
        }
        
        if (SharedManager.shared.posConfig().pos_type?.lowercased().contains("waiter") ?? false)
        {
            SharedManager.shared.activeSessionShared = nil
            close_session(value: "0" )
            MWLocalNetworking.sharedInstance.endSession()

            return
        }else{
        
        guard   !pendding_orders()  else {
            return
        }
           
            MWQueue.shared.firebaseQueue.async {
//             DispatchQueue.global(qos: .background).async {
            FireBaseService.defualt.updateInfoPOS()
            FireBaseService.defualt.setLastChainIndexFromFR()

            }
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        getBalance = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew
        getBalance.modalPresentationStyle = .popover
        getBalance.preferredContentSize = CGSize(width: 400, height: 715)
        
        getBalance.delegate = self
        getBalance.key = "close_session"
        getBalance.title_vc = LanguageManager.text("Close session cash", ar: "إغلاق الدورة النقدية")
        getBalance.disable = false
        
        let popover = getBalance.popoverPresentationController!
      
        popover.permittedArrowDirections = .left
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        
        popover.delegate = self
        getBalance.presentationController?.delegate = self
        didConfirmBalance = false
            
            
        self.present(getBalance, animated: true, completion: nil)
        }
    }
    func actionEndShiftBtn(_ sender: Any){
        guard   !check_expire() else {
            return
        }
//        let oldRule = user.canAccess(for: .open_session)
//        if !oldRule {
//            let newRule = user.canAccess(for: .close_session)
//            if !newRule {
                rules.check_access_rule(rule_key.close_session,for: self)  {
                    DispatchQueue.main.async {
                        self.completeEndSfit(sender)
                    }
                }
           // }
       // }
     
    }
    
    @IBAction func btnCloseShift(_ sender: Any) {
        WaringToast.shared.handleShowAlertWaring(complete: nil)
       let canAccess = LicenseInteractor.shared.licenseCanAccess(for: [.SESSION])
        LicenseInteractor.shared.handleShowAlertLicense(for: [.SESSION]) {
            self.btnStartShift.isEnabled = false
            self.actionEndShiftBtn(sender)
        }
       
    }
    
//    func start_session(cash:Double )
//    {
//
//        let session = pos_session_class()
//        session.id = 0
//        session.start_session = baseClass.get_date_now_formate_satnder()
//        session.start_Balance = cash
//        session.cashierID = SharedManager.shared.activeUser().id
//        session.posID = SharedManager.shared.posConfig().id
//        session.isOpen = true
//        session.save()
//
//        ordersStatistics.session_status = "Open"
//
//        refreshUI()
//    }
    
    func startSession(amount:Double = 0){
        activeSession = pos_session_class()
        activeSession!.id = 0
        activeSession!.start_session = baseClass.get_date_now_formate_satnder()
        activeSession!.start_Balance = amount
        
        activeSession!.cashierID = SharedManager.shared.activeUser().id
        activeSession!.posID = SharedManager.shared.posConfig().id
        
       
        activeSession!.start_session = baseClass.get_date_now_formate_satnder() // must to be UTC  as server online
        
        ordersStatistics.session_status = "Open"
        
        activeSession!.start_Balance = amount
   
        
      let session_id =  activeSession!.saveSession()
        
        pos_session_class.open_session(session_id: session_id)
        if SharedManager.shared.appSetting().enable_move_pending_orders{
            if SharedManager.shared.mwIPnetwork{
                if SharedManager.shared.posConfig().isMasterTCP(){
                    activeSession?.update_session_id_local_pending_order(session_id: session_id)
                }
            }else{
                if !SharedManager.shared.posConfig().isWaiterTCP(){
                    activeSession?.update_session_id_local_pending_order(session_id: session_id)
                }
            }
        }
        //activeSession?.update_session_id_local_pending_order(session_id)
        
        openHome()
        
        AppDelegate.shared.syncNow()
    }
    
    func newBalance(key:String,value:String)
    {
        didConfirmBalance = true
        let amount = value.toDouble() ?? 0
        
        if key == "start_session" {
            startSession(amount:amount)
            MWLocalNetworking.sharedInstance.startSession()
        }
        else
        {
 
            SharedManager.shared.activeSessionShared = nil
            close_session(value:value)
            MWLocalNetworking.sharedInstance.endSession()

            
            
        }
        if SharedManager.shared.appSetting().enable_resent_failure_ip_kds_order_automatic {
            messages_ip_queue_class.setQueueType(with: .DELETED)
        }
            if key != "start_session" {
                if MaintenanceInteractor.shared.isOneMonthsPassed(){
                    if MaintenanceInteractor.shared.isThereisOrder(){
                        askMaintanceAlert()
                    }
            }
        }
        
        
        
    }
    func askMaintanceAlert(){
        let alert = UIAlertController(title: "Maintenance Required".arabic("الصيانة مطلوبة"),
                                      message: "Is this a suitable time to perform maintenance? It may take up to 5 minutes.".arabic("هل هذا هو الوقت المناسب لإجراء الصيانة؟ قد يستغرق الأمر ما يصل إلى 5 دقائق."),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes" , style: .default, handler: { (action) in
            let vc = MWenhanceDBVC.createModule()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    var try_close:Int = 0
    func try_close_session(value:String)-> Bool
    {
        
        let dt = baseClass.get_date_now_formate_satnder() // must to be UTC  as server online
        let val:Double = value.toDouble() ?? 0
        let session_id = activeSession!.id
        
        
        let _ = NSError(domain: "close session", code: 5002, userInfo:
            [
                "id" : session_id,
                "date" :  dt ,
                "value" : val,
                "close" : "try"
            ]
        )
        
//        Crashlytics.crashlytics().record(error: error)
        
        
        pos_session_class.close_session(session_id: session_id,end_session: dt,end_Balance: val)
        
        
        let get_last_session =  pos_session_class.getActiveSession()
        
        if get_last_session != nil
        {
            // session not closed
            // try close
            activeSession = get_last_session
            
            return false
           
        }
        else
        {
            return true
        }
        

     }
    
    func is_closed_session()-> Bool
    {
 
  
        let get_last_session =  pos_session_class.getActiveSession()
        
        if get_last_session != nil
        {
            // session not closed
            // try close
            activeSession = get_last_session
            
            return false
           
        }
        else
        {
            return true
        }
        

     }
    
    
    func close_session(value:String)
    {
    

        let closed =   try_close_session(value: value)
        var closed_str = "No"
        if closed == true
        {
            closed_str = "Yes"
        }
         
        
        let dt = baseClass.get_date_now_formate_satnder() // must to be UTC  as server online
        let val:Double = value.toDouble() ?? 0
        
        let _ = NSError(domain: "close session", code: 5002, userInfo:
            [
                "id" : activeSession!.id,
                "date" :  dt ,
                "value" : val,
                "close" : closed_str


                
            ]
        )
        
//        Crashlytics.crashlytics().record(error: error)
        
 
          
        if is_closed_session() == true
        {
//            activeSession = nil
            activeSession?.isOpen = false
            
            cash_data_class.set(key: "cash_run_ID", value: "")
            SharedManager.shared.poll?.run_ID = 0
            AppDelegate.shared.auto_export.upload_all()
            
            AppDelegate.shared.syncNow()
            
            SharedManager.shared.resetSequenceFromMultipeer()
            
            refreshUI()
            
        }
        
        
    
    }
    
    func close_session_old(value:String)
    {
        try_close += 1

        let closed =   try_close_session(value: value)
        if closed == false
        {
            if try_close <= 3
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.close_session(value: value)
                }
                return
            }
        }
        
//        pos_session_class.force_close_all_sessions()

        
        let sessdion_id = activeSession?.id ?? 0
        if sessdion_id == 0
        {
            messages.showAlert("Can't close session .")
            return
        }
        
        if is_closed_session() == false
        {
            UserDefaults.standard.set(activeSession?.id, forKey: "session_not_closed")

        }
        
        AppDelegate.shared.login_users(activeSession: activeSession )
        
        AppDelegate.shared.auto_export.upload_all()
        
        AppDelegate.shared.syncNow()
    }
    func askToExitApp(){
        let alert = UIAlertController(title: "Lock", message: "App Will be Exit", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok" , style: .default, handler: { (action) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  exit(0)
                 }
            }
            alert.dismiss(animated: true, completion: nil)
            
        }))
        self .present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btn_lock_print(_ sender: Any) {
      //  askToExitApp()
        let titleBtn = (sender as? UIButton ?? UIButton()).titleLabel?.text?.lowercased() ?? ""
        // || titleBtn.contains("print end session".arabic("طباعه نهايه الجلسه"))
        if (titleBtn.contains("print last session".arabic("اطبع اخر جلسه"))  ) {
            self.ordersStatistics.printLastSession()
            return
        }
        if self.activeSession == nil
        {
            let last_session = pos_session_class.getLastSession()
            AppDelegate.shared.login_users(activeSession: last_session )

         }
        else
        {
            AppDelegate.shared.login_users(activeSession: activeSession )

        }
        
        
       
    }
    
    @IBAction func btnReloadAllApis(_ sender: Any) {
        
 
        guard   !check_expire() else {
            return
        }
    alter_database_enum.loadingApp.setIsDone(with: false)
      self.sync(get_new: false)
 
        
        
    }
    
    func sync(get_new:Bool)
    {
 
        AppDelegate.shared.loadLoading(forceSync: true, get_new: get_new)

    }
    
    @IBAction func btn_rule_info(_ sender: Any) {
        
        guard   !check_expire() else {
            return
        }
        
        let get_all_rules = rules.list
        
        let list = options_listVC(nibName: "options_popup", bundle: nil)
        list.hideClearBtnFlag = true
        list.modalPresentationStyle = .overFullScreen
        list.modalTransitionStyle = .crossDissolve
        list.title = "Rules".arabic("صلاحيات المستخدم")
        
        
        for rule in get_all_rules
        {
            let key_rule = rule["key"] as? String ?? ""
            let key_name = rule["name"]  as? String ?? ""
            let key_other_lang_name = rule["other_lang_name"]  as? String ?? ""

            var dic:[String:Any] = [:]

      
            if  user.canAccess(for: rule_key(rawValue: key_rule) ?? .open_session )
            {
                dic[options_listVC.cell_style] = options_listVC.style_check
            }
            
            dic[options_listVC.title_prefex] = key_name.arabic(key_other_lang_name)
            list.list_items.append(dic)

        }
        
 
        
        options_listVC.show_option(list:list,viewController: self, sender: sender   )

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
    
    
    func pendding_orders() -> Bool
    {
        let setting = SharedManager.shared.appSetting()
        if setting.close_session_with_closed_orders == false
        {
            return false
        }
        
        
      let option = ordersListOpetions()
        option.Closed = false
        option.Sync = false
        option.void = false
         option.get_not_empty_orders = true
        option.sesssion_id = pos_session_class.getActiveSession()!.id
        option.write_pos_id = SharedManager.shared.posConfig().id
        option.order_menu_status = [.none,.accepted]
        option.LIMIT = 30
        let casher = SharedManager.shared.activeUser()
         let access_admin_driver_lock  = rules.access_rule(user_id:casher.id,key:rule_key.admin_driver_lock)
        if access_admin_driver_lock{
            option.has_pickup_users_ids = true
            option.pickup_users_ids = nil
        }else{
            option.pickup_users_ids = [0]
            option.has_pickup_users_ids = nil

        }
//      let   list_count = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        let   list_count = pos_order_helper_class.getOrders_status_sorted(options: option)

        if list_count.count > 0
        {
            // "Please close pendding orders"
            messages.showAlert( MWConstants.alert_pending_order(list_count.map({$0.sequence_number})) )

            return true
        }
         
        return false
    }
    
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard !didConfirmBalance else { return }
        refreshUI()
        didConfirmBalance = false
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard !didConfirmBalance else { return }
        refreshUI()
        didConfirmBalance = false
    }
    
}

