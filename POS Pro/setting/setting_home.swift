//
//  setting_home.swift
//  pos
//
//  Created by khaled on 9/30/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class setting_home: baseViewController,menu_left_delegate {
    
     var posConfig:pos_configration?
    var change_user:setting_change_user?

    var addPrinter_page :addPrinter?
    var syncForce_page :syncForce?
    var importExport_page:import_Export?
 
    @IBOutlet var lbl_info: UILabel!
    @IBOutlet var container: UIView!
    
    @IBOutlet var tableview: UITableView!
    var list_items:  [Any]! = []
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        list_items = nil
        posConfig = nil

        syncForce_page = nil
        importExport_page = nil
    
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lbl_info.text = Bundle.main.fullVersion
  
        SettingAppInteractor.shared.getSettingPos()

    }
    
   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initList()
      if addPrinter_page != nil
      {
        printer()
      }
//       addPrinter_page?.printer_ip = nil
//       addPrinter_page?.viewWillAppear(animated)
    
    }
    
    func btnPriceList(_ sender: Any)
    {
        
    }
    
    @IBAction func btnOpenMenu(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    func add_mw_settings()
    {
        let mwSettingAppVC = MWSettingAppVC.createModule()
        addChild(mwSettingAppVC)
        mwSettingAppVC.view.frame = container.bounds
        container.subviews.forEach { view in
            view.removeFromSuperview()
        }
        container.addSubview(mwSettingAppVC.view)
        mwSettingAppVC.didMove(toParent: self)
    }
    func add_payment_device(_ type:DEVICE_PAYMENT_TYPES)
    {
        let addIngenicoDeviceVC = AddIngenicoDeviceRouter.createModule(for:type)
        addChild(addIngenicoDeviceVC)
        addIngenicoDeviceVC.view.frame = container.bounds
        container.subviews.forEach { view in
            view.removeFromSuperview()
        }
        container.addSubview(addIngenicoDeviceVC.view)
        addIngenicoDeviceVC.didMove(toParent: self)
    }
    func add_Zebra_device()
    {
        let addIngenicoDeviceVC = MWZebraVC.createModule()
        addChild(addIngenicoDeviceVC)
        addIngenicoDeviceVC.view.frame = container.bounds
        container.subviews.forEach { view in
            view.removeFromSuperview()
        }
        container.addSubview(addIngenicoDeviceVC.view)
        addIngenicoDeviceVC.didMove(toParent: self)
    }
    func add_scan_barcode_device()
    {
        let barcodeDeviceVC = BarcodeDeviceRouter.createModule()
        addChild(barcodeDeviceVC)
        barcodeDeviceVC.view.frame = container.bounds
        container.subviews.forEach { view in
            view.removeFromSuperview()
        }
        container.addSubview(barcodeDeviceVC.view)
        barcodeDeviceVC.didMove(toParent: self)
    }
   
    func posConfigration()
    {
  
        
        let storyboard = UIStoryboard(name: "setting_home", bundle: nil)
        posConfig  = storyboard.instantiateViewController(withIdentifier: "pos_configration") as? pos_configration
        
        //        orderVc = order_listVc()
//        orderVc?.delegate = self
        posConfig?.view.frame = container.bounds
        
        container.addSubview(posConfig!.view)
    }

    func changeUser()
    {
  
        
        let storyboard = UIStoryboard(name: "setting_home", bundle: nil)
        change_user  = storyboard.instantiateViewController(withIdentifier: "setting_change_user") as? setting_change_user
        
        //        orderVc = order_listVc()
//        orderVc?.delegate = self
        posConfig?.view.frame = container.bounds
        
        container.addSubview(change_user!.view)
    }


    func devicesMangment(){
        var devicesTypes:[DEVICES_TYPES_ENUM] = []
        if SharedManager.shared.activeUser().canAccess(for: .printers_managment){
            if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
                if !SharedManager.shared.cannotPrintBill(){
                    devicesTypes.append(contentsOf: [.POS_PRINTER])

                }
                if !SharedManager.shared.cannotPrintKDS(){
                    devicesTypes.append(contentsOf: [.KDS_PRINTER])

                }
            }
        }
        if SharedManager.shared.posConfig().isMasterTCP() {

        if SharedManager.shared.appSetting().enable_add_kds_via_wifi{
            devicesTypes.append(contentsOf: [.KDS,.NOTIFIER])
        }
        if SharedManager.shared.appSetting().enable_add_waiter_via_wifi{
            devicesTypes.append(contentsOf: [.WAITER,.SUB_CASHER])
        }
        }
        devicesTypes.append(contentsOf: [.GEIDEA])
        if devicesTypes.count > 0{
            let vc = DevicesMangmentVC.createModule(devicesTypes:devicesTypes)
        vc.view.frame = container.bounds
//            vc.parent_vc = self
        container.addSubview(vc.view)
        }else{
            SharedManager.shared.initalBannerNotification(title: "" ,
                                                          message: "You need Access to printers managment".arabic("ليس لديك صلاحيه اداره الطابعات"),
                                                          success: false, icon_name: "icon_error")
            SharedManager.shared.banner?.dismissesOnTap = true
            SharedManager.shared.banner?.show(duration: 3.0)
        }
    }
    
    func printer()
    {
  
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            let vc = DevicesMangmentVC.createModule(devicesTypes:[.POS_PRINTER,.KDS_PRINTER])
            vc.view.frame = container.bounds
//            vc.parent_vc = self
            container.addSubview(vc.view)
        }else{
        let storyboard = UIStoryboard(name: "setting_home", bundle: nil)
        addPrinter_page  = storyboard.instantiateViewController(withIdentifier: "printer_home") as? addPrinter
        
        //        orderVc = order_listVc()
        //        orderVc?.delegate = self
        addPrinter_page?.view.frame = container.bounds
        addPrinter_page?.parent_vc = self
        container.addSubview(addPrinter_page!.view)
        }
    }
    
    func findPrinter()
    {
        let storyboard = UIStoryboard(name: "setting_home", bundle: nil)

            let vc = storyboard.instantiateViewController(
                      withIdentifier: "findPrinter") as! DiscoveryViewController
        
        vc.hideBack = true
        vc.view.frame = container.bounds
        vc.parent_vc = self
       
               
        container.addSubview(vc.view)
    }
    
    
    func Setting_online()
    {
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "webViewController") as! webViewController
        controller.title_top = "Setting"
        controller.url = api.getDomain() + "/web#action=86&menu_id=4"
        controller.view.frame = container.bounds
        
        container.addSubview(controller.view)
    }
    
    func Setting_app()
    {
        
        if AppDelegate.shared.load_kds
        {
            let storyboard = UIStoryboard(name: "setting_home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "setting_app_kds") as! setting_app_kds
            controller.self_me =  controller
            controller.view.frame = container.bounds

            container.addSubview(controller.view)
        }
        else
        {
//            let controller = AppSettingsRouter.createModule()
            let storyboard = UIStoryboard(name: "setting_home", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "setting_app2") as! setting_app
            controller.self_me =  controller
            controller.view.frame = container.bounds
//            self.addChild(controller)
            container.addSubview(controller.view)
//            controller.didMove(toParent: self)

        }
  
        
        
    }
    
    func Sync()
    {
        
        let storyboard = UIStoryboard(name: "setting_home", bundle: nil)
        syncForce_page = storyboard.instantiateViewController(withIdentifier: "syncForce") as? syncForce
        syncForce_page?.view.frame = container.bounds
   
        syncForce_page?.parent_vc = self
        container.addSubview(syncForce_page!.view)
        
    }
    
    func Log()
    {
        if AppDelegate.shared.enable_debug_mode_code() == false
        {
            //        #if DEBUG
            //        #else
                    
            rules.check_access_rule(rule_key.log,for: self)  {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "connectionLog", bundle: nil)
                    let  connectionLog = storyboard.instantiateViewController(withIdentifier: "connectionLog_list") as? connectionLog_list
             
                    self.present(connectionLog!, animated: true, completion: nil)
                }
                    }
            //        #endif
        }
       
        
    }
    func ingenicoLog_list()
    {
        
        rules.check_access_rule(rule_key.log,for: self)  {
            DispatchQueue.main.async {
                
                let vc:IngenicoLogVC = IngenicoLogVC()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        
    }
    func sessionsLog_list()
    {
        if AppDelegate.shared.enable_debug_mode_code() == false
        {
//            #if DEBUG
//
//            #else
            rules.check_access_rule(rule_key.log,for: self)  {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "connectionLog", bundle: nil)
                    let  connectionLog = storyboard.instantiateViewController(withIdentifier: "sessionsLog_list") as? sessionsLog_list
                    connectionLog!.modalPresentationStyle = .fullScreen
                    
                    self.present(connectionLog!, animated: true, completion: nil)
                }
                return
            }
//            #endif
        }
      
        
        
    }
    func printerLog_list()
    {
        
        rules.check_access_rule(rule_key.log,for: self)  {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "printer_log", bundle: nil)
                let  connectionLog = storyboard.instantiateViewController(withIdentifier: "printer_log_list") as? printer_log_list
                connectionLog!.modalPresentationStyle = .fullScreen
                
        //        parentViewConroller?.pushViewController(connectionLog!, animated: true)
        //        menu_left.closeMenu()

                self.present(connectionLog!, animated: true, completion: nil)
            }
        }
        
        
        
        
    }
    func importExport()
    {
        
     
        let storyboard = UIStoryboard(name: "setting_home", bundle: nil)
        importExport_page = storyboard.instantiateViewController(withIdentifier: "import_Export") as? import_Export
        importExport_page!.view.frame = container.bounds
        importExport_page?.parent_vc = self
      
        container.addSubview(importExport_page!.view)
        
    }
    
    func clearView()
    {
        
        for view in container.subviews as [UIView] {
            
            if view.isKind(of: UIView.self)
            {
                
                view.removeFromSuperview()
                
            }
            
        }
        
    }
    func resetFactoryAction(){
        let alert = UIAlertController(title: "Reset POS Factory".arabic("إعادة ضبط نقاط البيع"), message: "Application will delete all data saved.\n and launch login screen".arabic("سيقوم التطبيق بحذف جميع البيانات المحفوظة. \n وتشغيل شاشة تسجيل الدخول"), preferredStyle: .alert)
        
        
 

        alert.addAction(UIAlertAction(title: "OK".arabic("موافق"), style: .default, handler: { (action) in
            let posID = SharedManager.shared.posConfig().id
            let dbName = api.getDatabase()

            SharedManager.shared.openPincode(order: nil, for: self, completion: {
//            self.deleteCashed()
                
            UserDefaults.standard.removeObject(forKey: "version_user_default")
            api.setDomain(url: "")
            api.setDatabase(url: "")
            api.set_Cookie(Cookie: "")
            api.saveItem(name: userLogin.username.rawValue , value: "")
            api.saveItem(name: userLogin.password.rawValue , value: "")
                

//            self.setDatabase()
            alter_database_enum.loadingApp.setIsDone(with: false)
            AppDelegate.shared.logOut()
            AppDelegate.shared.loadLoading()
            })
            
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".arabic("الغاء"), style: .cancel, handler: { (action) in
            
        }))
        
 
        self.present(alert, animated: true, completion: nil)
        
        
    }
    func add_custom_permission()
    {
        let customPermissionVC = PremissionRouter.createModule(with: false)
        self.present(customPermissionVC, animated: true, completion: nil)

//        addChild(customPermissionVC)
//        customPermissionVC.view.frame = container.bounds
//        container.subviews.forEach { view in
//            view.removeFromSuperview()
//        }
//        container.addSubview(customPermissionVC.view)
//        customPermissionVC.didMove(toParent: self)
    }
    
    
}


extension setting_home: UITableViewDelegate ,UITableViewDataSource {
    
    func initList()
    {
        
        
        list_items = []
        
        let bundleID = Bundle.main.bundleIdentifier
        if bundleID?.contains("kds") ?? false {
//            list_items.append(["Pos Configration","icon_history.png", "اعدادات نقطة البيع"])
//            list_items.append(["Change user","icon_history.png", "تغيير المستخدم"])

            list_items.append(["Sync","icon_history.png", "مزامنة"])
            if !SharedManager.shared.appSetting().enable_support_multi_printer_brands {
                list_items.append(["Printer","icon_history.png", "الطباعة"])
            }
            list_items.append(["Export","icon_history.png", "تصدير"])
            list_items.append(["Setting App","icon_history.png", "اعدادات التطبيق"])

            
        } else {
//        list_items.append(["Pos Configration","icon_history.png", "اعدادات نقطة البيع"])
//            list_items.append(["Change user","icon_history.png", "تغيير المستخدم"])

        list_items.append(["Sync","icon_history.png", "مزامنة"])
        //        list_items.append(["Database","icon_history.png"])
//            list_items.append(["Ingenico","logo-ingenico.png", "جهاز الدفع"])
//            list_items.append(["Geidea","gediea-log.png", "جهاز الدفع"])
        
            if !SharedManager.shared.cannotPrintBill() || !SharedManager.shared.cannotPrintKDS()  {
                list_items.append(["Devices Mangment","icon_history.png", "إدارة الأجهزة"])
            }
            if !SharedManager.shared.posConfig().isWaiterTCP(){
                list_items.append(["Zebra barcode","icon_history.png", "جهاز الباركود "])
            }

            if !SharedManager.shared.appSetting().enable_support_multi_printer_brands {
                list_items.append(["Printer","icon_history.png", "الطباعة"])
            }
//        list_items.append(["Setting online","icon_history.png", "اعدادات الاتصال"])
        list_items.append(["Setting App","icon_history.png", "اعدادات التطبيق"])
        list_items.append(["Export","icon_history.png", "تصدير"])
//            list_items.append(["IP Host Device Connetion","icon_history.png", "ربط الاجهزة عن طريق الIP"])
//            list_items.append(["IP Join Device Connetion","icon_history.png", "ربط الاجهزة عن طريق الIP"])
        list_items.append(["Log","icon_log.png","السجل"])
        list_items.append(["Ingenico Log","icon_log.png", "عمليات الدفع"])
        list_items.append(["Sessions Log","icon_log.png","سجل الجلسات"])
        list_items.append(["Printer Log","icon_log.png","عمليات الطابعه"])
//        list_items.append(["__ Find printer","icon_history.png"])
        }
        
        list_items.append(["Reset POS Factory","icon_history.png", "إعادة ضبط نقطة البيع"])
        list_items.append(["Permissions access","icon_history.png", "إذن الوصول"])

        self.tableview.reloadData()
        
    }
    
    
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
           clearView()
        
        let item = list_items[indexPath.row] as? [String]
        
        switch item![0] {
        case "Pos Configration":
            posConfigration()
        case "Change user":
            changeUser()
        case "Devices Mangment":
            devicesMangment()
       
        case "Printer":
            printer()
        case "__ Find printer":
            findPrinter()
        case "Setting online" :
            Setting_online()
        case "Setting App" :
//            Setting_app()
            add_mw_settings()
        case "Sync" :
            Sync()
        case "Log" :
            Log()
        case "Ingenico Log":
            ingenicoLog_list()
        case "Sessions Log":
            sessionsLog_list()
        case "Printer Log":
            printerLog_list()
        case "Export" :
            importExport()
        case "Ingenico" :
            add_payment_device(DEVICE_PAYMENT_TYPES.Ingenico)
//        case "Barcode Scanner" :
//            add_scan_barcode_device()
        case "Geidea":
            add_payment_device(DEVICE_PAYMENT_TYPES.GEIDEA)
        case "Zebra barcode":
            add_Zebra_device()
        case "Permissions access":
            add_custom_permission()
        case "Reset POS Factory":
            resetFactoryAction()

        default: break
            
        }
        
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! setting_homeTableViewCell
        
        let item = list_items[indexPath.row] as? [String]
        
        
        cell.lblTitle.text = LanguageManager.currentLang() == .ar ? item?[2] : item?[0]
        cell.photo.image = UIImage(name: item![1])
        
        
        return cell
    }
    
    
}
