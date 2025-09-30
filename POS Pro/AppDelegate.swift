//
//  AppDelegate.swift
//  pos
//
//  Created by khaled on 7/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//
// change database
//v654
import UIKit
import MMDrawerController
import Firebase
import FirebaseCore
import FirebaseAnalytics
import IQKeyboardManagerSwift
import AWSS3 // 1
import CryptoSwift

let mwIpPos = true

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var auto_export:import_Export = import_Export()
    
    var load_kds: Bool = false
    var app_expire: Bool = false
    
    var timer_poll:Timer?
    var timer_syncOrder = Timer()
    
    
    
    let autologin = autoReLogin()
    let sync = sync_class()
    
    var window: UIWindow?
    
    var centerContainer: MMDrawerController?
    var centerNav :UINavigationController?
    
    var localCash:cash_data_class?
    
    var create_order_vc:create_order!
    var driverLockOrdersVC:DriverLockOrdersVC?
    var memberShipVC:MemberShipVC?
    var mwCategoryVC: MWCategoryVC?
    var returnOrderByUIDVC:ReturnOrderByUIDVC?
    
    
    var loading:loadingViewController!
    
    var upload:uploadAWS3 = uploadAWS3()
    
    static var shared = AppDelegate()
    var leftSideNav:menu_left?
    var pinCodeVC:pinCode?
    var loginUsersVC:loginUsers?
    var zReportVC:zReport?
    var loginVc:loginVC?
    var selectPointOfSaleVC:selectPointOfSale?
    var dashboardVC:dashboard?
    var settingHomeVC:setting_home?
    var globalLinksVC:global_links?
    var reportsHomeVC:reports_home?
    
    
    
    
    
    //    class func shared() -> AppDelegate
    //    {
    //
    //        return UIApplication.shared.delegate as! AppDelegate
    //    }
    //
    
    
    func getDefaultPrinter() -> epson_printer_class
    {
        
        
        
        let setting =  settingClass.getSetting()
        let ip = setting.ip
        
        var printer = SharedManager.shared.printers_pson_print[0]
        if printer == nil
        {
            printer =  epson_printer_class(IP: ip,printer_name: (setting.name ?? ""))
            SharedManager.shared.printers_pson_print[0] = printer
            
        }
        else
        {
            // check if ip changed
            if printer?.IP != ip
            {
                printer =  epson_printer_class(IP: ip,printer_name: (setting.name ?? ""))
                SharedManager.shared.printers_pson_print[0] = printer
            }
        }
        
        return  printer!
    }
    
    
    
    func removeDataBase_data(database:String)
    {
        let database_file = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(database).appendingPathExtension("db")
        let toPath = database_file!.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        
        if  FileManager.default.fileExists(atPath: toPath) {
            do {
                try FileManager.default.removeItem(atPath: toPath)
            } catch {
                SharedManager.shared.printLog(error)
            }
        }
        
    }
    
    func initializeS3() {
        //        let poolId = "RabehIOS" // 3-1
        //        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast2, identityPoolId: poolId)//3-2
        //        let configuration = AWSServiceConfiguration(region: .USEast2, credentialsProvider: credentialsProvider)
        //        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2,
                                                                identityPoolId:"us-east-2:5d4a65b7-af8c-4fb7-b4cf-80545c41719f")
        
        let configuration = AWSServiceConfiguration(region:.USEast2, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    
    func load_app_type()
    {
        let bundleIdentifier =  Bundle.main.bundleIdentifier
        if bundleIdentifier == "rabeh.kds"
        {
            load_kds = true
            
            
            
        }
        
    }
    
    private lazy var fontNames = ["Changa-Bold",
                                  "Changa-ExtraBold",
                                  "Changa-ExtraLight",
                                  "Changa-Light",
                                  "Changa-Medium",
                                  "Changa-Regular",
                                  "Changa-SemiBold",
    ]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SharedManager.shared.printLog("APP Finder: \(NSHomeDirectory())")
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0.0
        }
        AppDelegate.shared = self
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)

//        FirebaseAnalytics().setAnalyticsCollectionEnabled(true)
        
        //        DispatchQueue.global(qos: .background).async {
        MWQueue.shared.firebaseQueue.async {
            let _ = CashHtmlFiles.shared
            FireBaseService.defualt.updateInfoPOS()
            FireBaseService.defualt.updateInfoTCP("start_app")
            FireBaseService.defualt.getFRSettingApp()
        }
        
        FileMangerHelper.shared.clearTrash()
        DispatchQueue.global(qos: .background).async {
            HTMLTemplateGlobal.shared.intialTemplate()
        }
        load_app_type()
        
        //        if load_kds == true
        //        {
        application.isIdleTimerDisabled = SharedManager.shared.appSetting().disable_idle_timer
        //        }
        
        
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
        
        setupCash()
        let versionManager = VersionManager()
                
                if versionManager.checkForUpdate() {
                    loadLoading(forceSync: true, get_new: false)

                }else{
                    loadLoading()

                }
        //        AppDelegate.shared.loadLoading(forceSync: true, get_new: get_new)

        
        
        IQKeyboardManager.shared.enable = true
        
        //        registerUnLocalNotification(application)
        
        
        
        run_poll()
        syncOrder()
        
        
        
        self.initializeS3() //2
        
        
        let arr = NSArray(objects: "en")
        UserDefaults.standard.set(arr, forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        
        auto_export.check_auto_upload()
        
        //        let password = "DgTeRa@!#$"
        //        let key128   = "1234567890123456"                   // 16 bytes for AES128
        //        let key256   = "12345678901234561234567890123456"   // 32 bytes for AES256
        ////        let iv       = "abcdefghijklmnop"                   // 16 bytes for AES128
        
        
        
        
        //        test()
        //        WiFi.shared.setupLocation()
        AppStoreUpdate.shared.initalAppStore()
        
        SharedManager.shared.initalMultipeerSession()
        
        MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.updateInfoPOS()
            FireBaseService.defualt.updateInfoTCP("start_app_2")
            FireBaseService.defualt.getFRSettingApp()
            FireBaseService.defualt.updateForceLongPolling()
            LicenseInteractor.shared.updateAppLicense()
            FireBaseService.defualt.setLastChainIndexFromFR()
            
        }
        DispatchQueue.global(qos: .background).async {
            let _ = CashHtmlFiles.shared
            let _ = CashHtmlFiles.shared
            MWPrinterMigration.shared.setDefaultForMultibrandPrinterSetting()
            //            MaintenanceInteractor.shared.getLastContextImageErrorOrder()
            WaringToast.shared.handleShowAlertWaring(complete: nil)

        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(8000), execute: {
//            fatalError("test crash lytics")
//        })

        /*
         if SharedManager.shared.appSetting().enable_add_kds_via_wifi{
         MWLocalNetworking.sharedInstance.startAutoJoinOrHost()
         }
         */
        //        SharedManager.shared.createLogFile()
        
        return true
    }
    
    func test()
    {
        // https://www.javainuse.com/aesgenerator
        
        
        let text =  """
        {"order_ref":"334434","order_number":"5555555","point_of_sale":"بيبسي سيبسيب","company_name":"5555555","total_order":"5555555","tax_number":"5555555"}
        """
        
        let key256   = "85412389003209855218541230068988"   // 32 bytes for AES256
        let iv       = "gTeRaabcdefghijx" //"1234567890123456"                   // 16 bytes for AES128
        
        let aes256 = AES_ENC(key: key256, iv: iv)
        
        //        let encryptedPassword128 = aes128?.encrypt(string: password)
        //      let en =  aes128?.decrypt(data: encryptedPassword128)
        
        let encryptedPassword256 = aes256?.encrypt(string: text)
        
        let str = encryptedPassword256?.base64EncodedString() //String(bytes: encryptedPassword256!.bytes, encoding: .utf8)
        
        
        //        let enbc = aes256?.decrypt(data: encryptedPassword256)
        
        SharedManager.shared.printLog(str)
        
        
        //        do {
        //            let iv = AES.randomIV(320)
        //
        //            let key1: [UInt8] = Array(key_str.utf8)
        //            let message1: [UInt8] = Array(message.utf8)
        //
        //
        //            let gcm = GCM(iv: iv, mode: .combined)
        //             let aes = try AES(key: key1, blockMode: gcm, padding: .noPadding)
        //            let decrypted = try aes.decrypt(message1)
        //
        //
        //            SharedManager.shared.printLog(decrypted)
        //
        //        } catch {
        //             SharedManager.shared.printLog(error)
        //
        //        }
        
        
        //        do {
        //            let password: [UInt8] = Array("DgTeRa@!#$".utf8)
        //            let salt: [UInt8] = Array(message.utf8)
        //            /* Generate a key from a `password`. Optional if you already have a key */
        //            let key = try PKCS5.PBKDF2(
        //                password: password,
        //                salt: salt,
        //                iterations: 4096,
        //                keyLength: 32, /* AES-256 */
        //                variant: .sha256
        //            ).calculate()
        //            /* Generate random IV value. IV is public value. Either need to generate, or get it from elsewhere */
        //            let iv = AES.randomIV(AES.blockSize)
        //            /* AES cryptor instance */
        //            let aes = try AES(key: key, blockMode: CBC(iv:iv) , padding: .pkcs7)
        //            /* Encrypt Data */
        ////            let inputData = Data()
        ////            let encryptedBytes = try aes.encrypt(inputData.bytes)
        ////            let encryptedData = Data(encryptedBytes)
        //            /* Decrypt Data */
        //
        //            let encryptedData = Data(base64Encoded: messageData)!
        ////            let encryptedData = Data( messageData)
        //
        //            let decryptedBytes = try aes.decrypt(encryptedData.bytes)
        //            let decryptedData = Data(decryptedBytes)
        //            let str = String(bytes: decryptedData, encoding: .utf8)
        //           SharedManager.shared.printLog("Decrypted: \(decryptedData.toHexString())")
        //
        //            SharedManager.shared.printLog(str)
        //        } catch {
        //             SharedManager.shared.printLog(error)
        //        }
        
    }
    
    func setupCash()   {
        let CashTime = SharedManager.shared.appSetting().cash_time
        localCash = cash_data_class(CashTime)
        localCash?.enableCash = true
        
    }
    
    func vacuum_database()
    {
        //        logDB.vacuum_database()
        logClass.init().dbClass?.vacuum_database()
        pos_order_helper_class.vacuum_database()
        
        printer_log_class.vacuum_database()
        ingenico_log_class.vacuum_database()
        
    }
    
    func enable_debug_mode_code() -> Bool
    {
#if DEBUG
        
        if stop_debug_code == 1
        {
            return false
        }
        else
        {
            return true
        }
        
#else
        return false
#endif
    }
    func disable_firebase_database()-> Bool{
#if DEBUG
        return stop_firebase_database == 0
#else
        return false
#endif
    }
    
    
    func loadKDS()
    {
        //        let storyboard = UIStoryboard(name: "kds_home", bundle: nil)
        //        let controller = storyboard.instantiateViewController(withIdentifier: "kds_home_vc") as! kds_home_vc
        //        self.centerNav = UINavigationController(rootViewController: controller)
        //        self.centerNav?.isNavigationBarHidden = true
        //        self.rootDrawer(for: "kds",delegate: controller)
    }
    
    func loadLoading(forceSync:Bool = false,get_new:Bool = true)   {
        FileMangerHelper.shared.restInvoiceLogo()
        
        self.resetAllVC()
        
        DispatchQueue.main.async {
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            self.loading = mainStoryboard.instantiateViewController(withIdentifier: "loadingViewController") as? loadingViewController
            
            //            self.loading  = loadingViewController()
            let nav = UINavigationController(rootViewController: self.loading)
            
            self.loading.forceSync = forceSync
            self.loading.get_new = get_new
            
            self.window!.rootViewController = nav
            self.window!.makeKeyAndVisible()
        }
        
    }
    
    func removeDatabases()
    {
        SharedManager.shared.remove_database()
        SharedManager.shared.remove_log()
        SharedManager.shared.remove_printerlog()
        SharedManager.shared.remove_multipeerlog()
        SharedManager.shared.remove_ingenico_log()
        SharedManager.shared.remove_user_default()
        
    }
    
    
    func logOut()   {
        //        DispatchQueue.global(qos: .background).async {
        MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.updatePresenceStatus(.offline)
        }
        removeDatabases()
        
        
        
        loadLoading()
        
        
    }
    
    
    func auto_Login()
    {
        
        self.autologin.auto()
        
        
    }
    func resetAllVC(){
        SharedManager.shared.restLastActionDate()
        if centerNav != nil {
            centerNav?.removePreviousController()
            centerNav = nil
        }
        if returnOrderByUIDVC != nil {
            returnOrderByUIDVC = nil
        }
        if driverLockOrdersVC != nil {
            driverLockOrdersVC = nil
        }
        if memberShipVC != nil {
            memberShipVC = nil
        }
        if mwCategoryVC != nil {
            mwCategoryVC = nil
        }
        if   create_order_vc != nil
        {
            create_order_vc.clearMemory()
            create_order_vc = nil
        }
        if pinCodeVC != nil {
            pinCodeVC = nil
        }
        if loading != nil
        {
            loading = nil
        }
        if loginUsersVC != nil { loginUsersVC = nil }
        if zReportVC != nil { zReportVC = nil }
        if dashboardVC != nil { dashboardVC = nil }
        if loginVc != nil { loginVc = nil }
        if selectPointOfSaleVC != nil { selectPointOfSaleVC = nil }
        if settingHomeVC != nil { settingHomeVC = nil}
        if globalLinksVC != nil { globalLinksVC = nil}
        if reportsHomeVC != nil { reportsHomeVC = nil}
        
        
    }
    func completeLoadHome(){
        DispatchQueue.main.async {
            self.resetAllVC()
            let storyboard = UIStoryboard(name: "create_order", bundle: nil)
            self.create_order_vc = storyboard.instantiateViewController(withIdentifier: "create_order") as? create_order
            self.centerNav = UINavigationController(rootViewController: self.create_order_vc)
            self.centerNav?.isNavigationBarHidden = true
            self.rootDrawer(for:"RESUME Shift",delegate:self.create_order_vc )
            return
        }
    }
    func loadHome(checkRule:Bool = true)   {
//        guard  rules.check_access_rule(rule_key.open_session) else {
//            return
//        }
        if checkRule {
            guard let targetVC =  UIApplication.getTopViewController() else {
                print("Error: Unable to find a valid view to show the loading animation.")
                return
            }
            rules.check_access_rule(rule_key.open_session,for: targetVC) {
                self.completeLoadHome()
            }
        }else{
            self.completeLoadHome()
        }
       
        
    }
    func loadDriverLockHome()   {
        //        guard  rules.check_access_rule(rule_key.open_session) else {
        //            return
        //        }
        self.resetAllVC()
        self.driverLockOrdersVC = DriverLockOrdersVC.createModule()
        guard let driverLockOrdersVC = driverLockOrdersVC else{return}
        self.centerNav = UINavigationController(rootViewController: driverLockOrdersVC)
        self.centerNav?.isNavigationBarHidden = true
        self.rootDrawer(for:"Driver Lock",delegate:self.driverLockOrdersVC )
        
    }
    
    func rootDrawer(for parentName:String, delegate:menu_left_delegate? = nil){
        guard let navCenter = self.centerNav else {return}
        leftSideNav?.parentViewConroller?.removePreviousController()
        leftSideNav?.parentViewConroller = nil
        self.centerContainer = nil
        leftSideNav = nil
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        leftSideNav = mainStoryboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? menu_left
        guard let leftSideNav = self.leftSideNav else {return}
        leftSideNav.parentViewConroller = navCenter
        leftSideNav.parentName = parentName
        leftSideNav.delegate = delegate
        self.centerContainer = MMDrawerController(center: self.centerNav, leftDrawerViewController: leftSideNav,rightDrawerViewController:nil)
        
        self.centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.tapCenterView;
        self.centerContainer!.maximumLeftDrawerWidth = 210
        
        self.centerContainer?.shouldStretchDrawer = false
        DispatchQueue.main.async {
            self.window!.rootViewController =  self.centerContainer
            self.window!.makeKeyAndVisible()
        }
    }
    func loadPin()   {
        resetAllVC()
        let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
        pinCodeVC = storyboard.instantiateViewController(withIdentifier: "pinCode") as! pinCode
        self.window!.rootViewController =  pinCodeVC
        self.window!.makeKeyAndVisible()
    }
    
    func check_if_session_not_closed()
    {
        let session_id =  UserDefaults.standard.integer(forKey: "session_not_closed")
        if session_id != 0
        {
            pos_session_class.force_close_sessions(session_id: session_id)
            
            // check of closed
            if pos_session_class.check_session_closed(session_id: session_id)
            {
                UserDefaults.standard.removeObject(forKey: "session_not_closed")
            }
            
        }
        
    }
    
    func login_users(activeSession:pos_session_class? )
    {
        
        DispatchQueue.main.async {
            
            //            self.check_if_session_not_closed()
            
            self.resetAllVC()
            res_users_class.deleteDefault()
            
            let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
            self.loginUsersVC = storyboard.instantiateViewController(withIdentifier: "loginUsers") as? loginUsers
            guard let vc = self.loginUsersVC else {return}
            vc.hideBack = true
            
            self.centerNav = UINavigationController(rootViewController: vc)
            self.centerNav?.isNavigationBarHidden = true
            
            self.window!.rootViewController =  self.centerNav
            self.window!.makeKeyAndVisible()
            
            if activeSession != nil
            {
                let setting = SharedManager.shared.appSetting()
                if setting.auto_print_zreport == true
                {
                    
                    let storyboard = UIStoryboard(name: "reports", bundle: nil)
                    self.zReportVC = storyboard.instantiateViewController(withIdentifier: "zReport") as? zReport
                    
                    self.zReportVC?.activeSessionLast = activeSession
                    self.zReportVC?.shift_id = activeSession?.id
                    self.zReportVC?.print_inOpen = true
                    self.zReportVC?.auto_close = true
                    self.zReportVC?.custom_header = "End session".arabic("نهايه الجلسه") // LanguageManager.currentLang() == .ar ? "تقرير عمليات مفصل" : "Sales report summary"
                    
                    
                    self.zReportVC?.hideNav = false
                    self.zReportVC?.forLockDriver = (SharedManager.shared.posConfig().pos_type?.lowercased().contains("driver_screen") ?? false)
                    
                    self.centerNav?.pushViewController(self.zReportVC!, animated: true)
                }
            }
        }
        
    }
    func loadLogin(re_login:Bool = false)   {
        DispatchQueue.main.async {
            self.resetAllVC()
            let storyboard = UIStoryboard(name: "newloginStoryboard", bundle: nil)
            self.loginVc = storyboard.instantiateViewController(withIdentifier: "loginVC") as? loginVC
            //            let nav:UINavigationController = UINavigationController(rootViewController: controller)
            self.loginVc?.re_login = re_login
            guard let loginVc = self.loginVc else {return}
            self.window!.rootViewController =  loginVc
            self.window!.makeKeyAndVisible()
        }
        
    }
    func loadSelectPointOfSale()   {
        DispatchQueue.main.async {
            self.resetAllVC()
            let storyboard = UIStoryboard(name: "newloginStoryboard", bundle: nil)
            self.selectPointOfSaleVC = storyboard.instantiateViewController(withIdentifier: "selectPointOfSale") as? selectPointOfSale
            guard let controller = self.selectPointOfSaleVC else {return}
            self.window!.rootViewController =  controller
            self.window!.makeKeyAndVisible()
        }
        
    }
    
    
    func loadDashboard()   {
        self.resetAllVC()
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        dashboardVC = storyboard.instantiateViewController(withIdentifier: "dashboard") as? dashboard
        guard let controller = self.dashboardVC else {return}
        self.centerNav = UINavigationController(rootViewController: controller)
        self.centerNav?.isNavigationBarHidden = true
        self.rootDrawer(for:"dashboard",delegate: controller)
        
    }
    
    func loadSetting()   {
        self.resetAllVC()
        let storyboard = UIStoryboard(name: "setting_home", bundle: nil)
        settingHomeVC = storyboard.instantiateViewController(withIdentifier: "setting_home") as? setting_home
        guard let controller = self.settingHomeVC else {return}
        
        self.centerNav = UINavigationController(rootViewController: controller)
        self.centerNav?.isNavigationBarHidden = true
        self.rootDrawer(for:"Setting",delegate: controller)
        
    }
    
    
    func loadSetting_kds()   {
        self.resetAllVC()
        
        let storyboard = UIStoryboard(name: "setting_home", bundle: nil)
        settingHomeVC = storyboard.instantiateViewController(withIdentifier: "setting_home") as? setting_home
        guard let controller = self.settingHomeVC else {return}
        
        
        self.centerNav = UINavigationController(rootViewController: controller)
        self.centerNav?.isNavigationBarHidden = true
        self.rootDrawer(for: "Setting", delegate: controller)
    }
    
    func loadglobal_links()   {
        self.resetAllVC()
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        globalLinksVC = storyboard.instantiateViewController(withIdentifier: "global_links") as? global_links
        guard let controller = self.globalLinksVC else {return}
        self.centerNav = UINavigationController(rootViewController: controller)
        self.centerNav?.isNavigationBarHidden = true
        self.rootDrawer(for: "Inventory")
    }
    func loadReports()   {
        self.resetAllVC()
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        reportsHomeVC = storyboard.instantiateViewController(withIdentifier: "reports_home") as? reports_home
        guard let controller = self.reportsHomeVC else {return}
        self.centerNav = UINavigationController(rootViewController: controller)
        self.centerNav?.isNavigationBarHidden = true
        self.rootDrawer(for: "Reports")
    }
    
    private func syncOrder()
    {
        //        if load_kds == true
        //        {
        //            return
        //        }
        //150 = 2.5 mine
        timer_syncOrder = Timer.scheduledTimer(timeInterval:150, target: self, selector: #selector(syncNow), userInfo: nil, repeats: true)
        timer_syncOrder.fire()
        
        
    }
    
    @objc func syncNow()
    {
        //        MWQueue.shared.syncOrdersQueue.async {
        
        
        //    return
        
        //       SharedManager.shared.printLog("Start Sync at " , Date())
        
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
            //        #if DEBUG
            if test_mode == 1
            {
                return
            }
            //        #endif
        }
        
        
        if SharedManager.shared.appSetting().enable_testMode
        {
            return
        }
        
        
        
        
        DispatchQueue.global(qos: .background).async {
            self.sync.syncOrders()
        }
        
    }
    
    func run_poll()
    {
        //        if mwIpPos {
        //            return
        //        }
        
        let multi_session_id = SharedManager.shared.posConfig().multi_session_id  ?? 0
        if multi_session_id == 0
        {
            let setting = SharedManager.shared.appSetting()

            if setting.enable_resent_failure_ip_kds_order_automatic{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(setting.enter_time_for_auto_send_fail_ip_message)), execute: {
                    self.timer_poll = Timer.scheduledTimer(timeInterval:setting.enter_time_for_auto_send_fail_ip_message, target: self, selector: #selector(self.run_retry_ip_message_now), userInfo: nil, repeats: true)
                    self.timer_poll!.fire()
                })
                
            }
            return
        }
        
        
//        pos_multi_session_sync_class.clear()
        
        if timer_poll != nil
        {
            timer_poll!.invalidate()
            
        }
        let pos = SharedManager.shared.posConfig()
        if pos.name != "" && pos.id != 0 {
            if !SharedManager.shared.appSetting().enable_force_longPolling_multisession{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                    self.timer_poll = Timer.scheduledTimer(timeInterval:10, target: self, selector: #selector(self.run_poll_now), userInfo: nil, repeats: true)
                    self.timer_poll!.fire()
                self.run_poll_now()
                })
            }else{
                let setting = SharedManager.shared.appSetting()
                if setting.enable_resent_failure_ip_kds_order_automatic || setting.enable_reconnect_with_printer_automatic{
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(25), execute: {
                        self.timer_poll = Timer.scheduledTimer(timeInterval:25, target: self, selector: #selector(self.run_retry_ip_message_now), userInfo: nil, repeats: true)
                        self.timer_poll!.fire()
                    })
                    
                }else{
                    self.run_poll_now()
                }
                
            }
            
        }
        
        
    }
    
    @objc func run_poll_send_local_updates(force:Bool = false)
    {
        
        //        if mwIpPos {
        //            return
        //        }
        //        MWQueue.shared.multisessionQueue.async {
        
        
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
            if test_mode == 1
            {
                //             #if DEBUG
                return
                //                    #endif
            }
        }
        
        
        
        if SharedManager.shared.appSetting().enable_testMode
        {
            return
        }
        
        if SharedManager.shared.poll?.last_id == nil
        {
            return
        }
        if  SharedManager.shared.poll?.run_ID != 0
        {
            
            DispatchQueue.global(qos: .background).async {
                SharedManager.shared.poll_updates.cls_pos_multi_session = SharedManager.shared.poll!
                
                SharedManager.shared.poll_updates.send_local_changes()
                // }
            }
        }
    }
    @objc func run_retry_ip_message_now(){
        QrCodeInteractor.shared.retryForFailure()

        let settings =  SharedManager.shared.appSetting()
        if  settings.enable_resent_failure_ip_kds_order_automatic{
            
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                MWMessageQueueRun.shared.resendFaluireMessages()
            })
        }
        if  settings.enable_reconnect_with_printer_automatic{
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                MWPrinterRetry.shared.runRetryPrinter()

            })
        }
        DispatchQueue.main.async {
            SharedManager.shared.timeToNavigateLockScreen()
        }

}
    @objc func run_poll_now()
    {
//        MWQueue.shared.multisessionQueue.async {
        
//        if mwIpPos {
//            return
//        }
        self.run_retry_ip_message_now()
      
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
            if test_mode == 1
            {
                //             #if DEBUG
                return
                //                    #endif
            }
        }
        if  SharedManager.shared.poll?.is_running ?? false {
             return
         }
        
        if SharedManager.shared.appSetting().enable_testMode
        {
            return
        }
        
        if SharedManager.shared.poll?.pos_id == 0
        {
            let pos = SharedManager.shared.posConfig()
            if pos.id != 0
            {
                SharedManager.shared.poll?.pos_id = pos.id
                
            }
            else
            {
                return
            }
        }
        if !SharedManager.shared.appSetting().enable_force_longPolling_multisession {
            run_poll_send_local_updates()
        }
        
        DispatchQueue.global(qos: .background).async {
            SharedManager.shared.poll?.load_kds = self.load_kds
            SharedManager.shared.poll?.check_poll()
       // }
        }
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        goBackground()

//        self.stopSockectIP()

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        goBackground()
//        self.window?.endEditing(true)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        goForeGround()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        goForeGround()
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
       /*
        SharedManager.shared.disCounectMultiPeer()
        if SharedManager.shared.mwIPnetwork {
            MWLocalNetworking.sharedInstance.stopAutoJoinOrHost()
        }
        */
        goBackground()
//        self.window?.endEditing(true)
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)

    }
    func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
        goBackground()
    }
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        goForeGround()
    }
    
    
    func alert(tile:String  ,msg:String,date:String  ,   icon_name:String ,success:Bool = false)
    {
 
        
   
        notifications_messages_class.alert(tile:tile,msg: msg,date: date,icon_name: icon_name, success: success)
 

        
        
    }
    func goForeGround(){
        MWMessageQueueRun.shared.setState(with: .FORE_GROUND)
        SharedManager.shared.initalMultipeerSession()
        MWQueue.shared.firebaseQueue.async {
        FireBaseService.defualt.updatePresenceStatus(.online)
        }
        NetWorkMonitor.shared.startMonitor()
        startSockectIP()
    }
    func goBackground(){
        MWMessageQueueRun.shared.setState(with: .BACK_GROUND)
        SharedManager.shared.disCounectMultiPeer()
        MWQueue.shared.firebaseQueue.async {
        FireBaseService.defualt.updatePresenceStatus(.offline)
        FireBaseService.defualt.updateInfoTCP("go_back_ground")
        }
        NetWorkMonitor.shared.cancelMonitor()
        self.stopSockectIP()
        MWLocalNetworking.sharedInstance.mwServerTCP.isStarWorking = false
        MWMasterIP.shared.dismissMasterBanner()
    }
    func stopSockectIP(){
        if SharedManager.shared.mwIPnetwork {
            MWLocalNetworking.sharedInstance.stopAutoJoinOrHost()
            MWMessageQueueRun.shared.removeQueueMessages()
        }
    }
    func startSockectIP(){
        if SharedManager.shared.mwIPnetwork {
           
            let ipV4 = MWConstantLocalNetwork.getIPV4Address()
            if !ipV4.isEmpty && ipV4.verifyIP() {
                SharedManager.shared.cashWorkingIP = ipV4
                if SharedManager.shared.posConfig().isMasterTCP(){
                MWLocalNetworking.sharedInstance.startAutoJoinOrHost()
                MWMessageQueueRun.shared.updateIpQueueType()
                }else{
                    device_ip_info_class.resetDevicesInfo()
                    socket_device_class.saveMasterSockectDevice(status: SharedManager.shared.mwIPnetwork)
                    if  let activeSession = pos_session_class.getActiveSession() {
                        SharedManager.shared.printLog("activeSession === \(activeSession.id)")
                        MWLocalNetworking.sharedInstance.startAutoJoinOrHost()
                        MWMessageQueueRun.shared.updateIpQueueType()
                    }
//                    DispatchQueue.main.asyncAfter(deadline:.now() + .seconds(3) , execute: {
//                        MWMasterIP.shared.checkMasterStatus()
//                    })
                    
                }


            }else{
                DispatchQueue.main.asyncAfter(deadline:.now() + .seconds(3) , execute: {
                    self.startSockectIP()
                })

             
            }
        }
    }
    
}


