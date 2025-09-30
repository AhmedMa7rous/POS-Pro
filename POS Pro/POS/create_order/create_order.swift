//
//  homeVC.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

 // Barcode scanner
//protocol barcode_scanner_delegate {
//  func  text_changed(txt:String)
//}

//class CustomKeyInput: UIView, UIKeyInput{
//    // the string we'll be drawing
//
//    var delegate:barcode_scanner_delegate?
//
//       var input = ""
//
//       override var canBecomeFirstResponder: Bool {
//           true
//       }
//
//       var hasText: Bool {
//           input.isEmpty == false
//       }
//
//
//
//       func insertText(_ text: String) {
//           input += text
//
//           input = replaceArabic(input)
//           delegate?.text_changed(txt: input)
////           setNeedsDisplay()
//
//           DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
//              // Code you want to be delayed
//               self.input = ""
//           }
//       }
//
//       func deleteBackward() {
//           _ = input.popLast()
////           setNeedsDisplay()
//       }
//
//
//
////       override func draw(_ rect: CGRect) {
////           let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 32)]
////           let attributedString = NSAttributedString(string: input, attributes: attrs)
////           attributedString.draw(in: rect)
////       }
//   }




class create_order: baseViewController ,UIPopoverPresentationControllerDelegate {
    //MARK: Outlets
    @IBOutlet weak var newBannerHolderview: NewBanner!
    @IBOutlet weak var btn_enable_sound: UIButton!
    @IBOutlet weak var left_view: ShadowView!
    @IBOutlet weak var right_view: UIView!
    @IBOutlet weak var view_collection_container: UIView!
    @IBOutlet weak var lblinfo: KLabel!
    @IBOutlet weak var categories: ShadowView!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var view_orderList: UIView!
    @IBOutlet weak var view_addCustomer: UIView!
    @IBOutlet weak var view_editCustomer: UIView!
    @IBOutlet weak var lblCustmoerPhone: KLabel!
    @IBOutlet weak var lblCustmerName: KLabel!
    @IBOutlet weak var lblcustomerFirstChar: KLabel!
    @IBOutlet weak var btnSelectCustomer: UIButton!
    @IBOutlet weak var btnPayment: KButton!
    @IBOutlet weak var lblOrderID: KLabel!
    @IBOutlet weak var lbl_total_price: KLabel!
    @IBOutlet weak var lbl_time: KLabel!
    @IBOutlet weak var btnSelectOrderType: UIButton!
    //MARK: Variables
    var pop_up:options_listVC?
    let con = SharedManager.shared.conAPI()
    let con_sync = SharedManager.shared.conAPI()
    let ordersList = pos_order_helper_class()
    var refreshControl_collection = UIRefreshControl()
//    var keyboard:keyboardVC! = keyboardVC()
    var org_list_product: [Any]! = []
    var list_product: [[String:Any]]! = []
    var list_product_search: [Any]! = []
    var list_order_products:  [pos_order_line_class]! = []
    var getBalance :enterBalanceNew!
    var getPromotionCode:addPromoCodeVC!
//    var cls_load_all_apis:load_base_apis! = load_base_apis()
//    var customerVC:new_customers_listVC! = new_customers_listVC()
    var customerVC: new_customers_listVC?

    var priceListVC:price_listVC! = price_listVC()
    var orderTypeVC:order_type_list! = order_type_list()
    var comboList:combo_vc! = combo_vc()
    var disconut_Option:disconutOption!
    var categories_top:categroiesBC! = categroiesBC()
    var list_order_created :[pos_order_class]! = []
    var lstInvoices:invoicesListCollection! = invoicesListCollection()
    var lst_menu:menuList?
    var payment_Vc:paymentVc!
    var selectNewOption:Double = -1
    var orderVc:order_listVc?
    var otherPrinter:printersNetworkAvalibleClass? = printersNetworkAvalibleClass()
    var _promotionSelect = promotionSelect()
    var orderTypePayment = false
    var product_note_vc:product_note?
    var reload_create_order = true
    var newComboVC:MWComboVC? = nil

//    var stocks:[String:[String:Any]] = [:]
    let user = SharedManager.shared.activeUser()
    let epos_printer = AppDelegate.shared.getDefaultPrinter()
    var enable_sound_notification:Bool = false
    var splitOrder:split_order!
    private var VOFocusChanged: NSObjectProtocol?
    var view_temp:UIView?
//    lazy var barcodeDeviceInteractor = BarcodeDeviceInteractor.shared

    var countProductsNeedToAdded:Int = 0
    var previousDeliveryAreaId = 0
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        auto_sent_to_kitchen()
 
//        self.barcodeScaner_view.resignFirstResponder()
//        SharedManager.shared.disCounectMultiPeer()
 
        //       clearMemory()
        
        remove_notificationCenter()
        removeObservalFR()
    }
    
    func auto_sent_to_kitchen(){
        if SharedManager.shared.appSetting().enable_auto_sent_to_kitchen{
            if self.newBannerHolderview.btn_send_kitchen.isEnabled {
                if let order_vc = self.orderVc , order_vc.order.checISSendToMultisession()  {
                    if (order_vc.order.pos_order_lines.count ) > 0 {
                        self.sendToKitchen(sender: self.newBannerHolderview.btn_send_kitchen as Any)
                    }

                }
            }
        }
    }

    

    
    func clearMemory()
    {
//        keyboard = nil
        newComboVC = nil
        auto_sent_to_kitchen()
        
        categories_top.delegate = nil
        categories_top.parent_vc = nil
        categories_top.txt_search.delegate = nil
        self.categories_top.list_categ.removeAll()
        self.categories_top.all_categories.removeAll()
        self.categories_top.main_categ.removeAll()
        self.categories_top.list_categ_BC.removeAll()
        self.categories_top.view_container = UIView()
        self.categories_top.view_collection_container = UIView()
        categories.subviews.forEach { v in
            v.removeFromSuperview()
        }
        
//        self.stocks.removeAll()
//        self.stocks = [:]
        org_list_product.removeAll()
        list_product.removeAll()
        org_list_product = nil
        list_product = nil
        list_product_search = nil
        list_order_products.removeAll()
        list_order_products = nil
        getBalance = nil
//        cls_load_all_apis = nil
        customerVC = nil
        priceListVC = nil
        orderTypeVC = nil
        
        comboList = nil
        disconut_Option = nil
        categories_top = nil
        list_order_created.removeAll()
        lstInvoices = nil
        payment_Vc = nil
        orderVc = nil
        otherPrinter = nil
        product_note_vc = nil
    
        
    }
    
    
//    @objc func adjustForKeyboard(notification: Notification) {
//        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
//
//        let keyboardScreenEndFrame = keyboardValue.cgRectValue
//        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
//
////        if notification.name == UIResponder.keyboardWillHideNotification {
////            script.contentInset = .zero
////        } else {
////            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
////        }
////
////        script.scrollIndicatorInsets = script.contentInset
////
////        let selectedRange = script.selectedRange
////        script.scrollRangeToVisible(selectedRange)
//    }
   
    func text_changed(txt: String) {
        categories_top.setTextSearch(txt: txt)
        searchBar(categories_top.txt_search, textDidChange: txt)
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newBannerHolderview.delegate = self
//        self.failureSendBtn.isHidden = true
        self.newBannerHolderview.labelPromotionCode.text = ""
 
        SharedManager.shared.initalMultipeerSession()
        SharedManager.shared.check_total.initPromotion()
 
//        SharedManager.shared.initalMultipeerSession()
 
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
 
//        promotion_helper?.delegate = self
         
        view_addCustomer.isHidden = false
        view_editCustomer.isHidden  = true
                        

        initCollection()
//        initSlideBar()
        
        loadCategories()
        
        
        
        DispatchQueue.main.async {
            self.getProduct()
            
            let pos = SharedManager.shared.posConfig()
            if pos.iface_start_categ_id != 0
            {
                let categ = pos_category_class.get(id: pos.iface_start_categ_id!)
                
                self.categorySelected(categ: categ)
            }
        }
        
        
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collection?.addGestureRecognizer(lpgr)
        
        /*
         getSTock()
        */
        check_rules()
        
        check_enable_sound()
 
        openTableScreenForWaiter(checkMaster:false)
        if SharedManager.shared.isFreeSpaceLow1GB() {
            messages.showAlert("Need To free some storage".arabic("يلزم تحرير بعض مساحة التخزين"), title: "Storage almost full".arabic("التخزين ممتلئ تقريبًا"))
        }
       InitlizeBarcodeDeviceInteractor()
        addObserveFB()
        SharedManager.shared.updateLastActionDate()

        DispatchQueue.main.async {
            MWTCPRequest.shared.requestAll()
        }
    }

    func showBannerWaitingSearchIP(){
        if SharedManager.shared.mwIPnetwork {
                if SharedManager.shared.posConfig().isMasterTCP() {
                    if MWLocalNetworking.sharedInstance.mwClientTCP.is_loading {
                        SharedManager.shared.initalBannerNotification(title: "", message: "Waiting search for IP devices".arabic("انتظر حتي اكتمال الحصول علي ال ip"), success: true, icon_name: "icon_done" )
                        SharedManager.shared.banner?.dismissesOnTap = false
                        SharedManager.shared.banner?.show(duration: 5.0)
                    }
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                        MWMasterIP.shared.checkMasterStatus()
                    })
                }
            MWQueue.shared.firebaseQueue.async {
                FireBaseService.defualt.updateInfoTCP("create_order")
            }
        }
    }
    func setFaluireIpBadge(){
        self.showBadgeIpError("")
        MWMessageQueueRun.shared.getCountFailureMessage { value in
            self.showBadgeIpError(value)
        }
    }
    func showBadgeIpError(_ value:String){
        DispatchQueue.main.async {
//            self.newBannerHolderview.ipBadgeHolderview.isHidden = value.isEmpty
//            self.newBannerHolderview.lblFailureIPBadge.text = value
        }
    }
    
    func InitlizeBarcodeDeviceInteractor(){
        if SharedManager.shared.posConfig().isWaiterTCP() {
            return
        }else{
            if SharedManager.shared.appSetting().enable_zebra_scanner_barcode{
                DispatchQueue.main.async {
                    lazy var cashZebra:CashZebra = CashZebra.shared
                    if cashZebra.getZebraDeviceStatue().connect{
                        ZebraBarcodeDeviceInteractor.shared.startDiscoveryOrConnect()
                        ZebraBarcodeDeviceInteractor.shared.didReceiveDecodedDataCompletation =  { [weak self] (d1Barcode) in
                            guard let self = self else {return}
                            if let id_product = d1Barcode{
                                self.addProduct(with: id_product)
                            }
                        }
                    }
                }
                
                
            }else{
                if SharedManager.shared.appSetting().enable_scoket_mobile_scanner_barcode{
                    lazy var barcodeDeviceInteractor = BarcodeDeviceInteractor.shared
                    if let nameDevice = cash_data_class.get(key: "barcode_device_name" ), !nameDevice.isEmpty{
                        barcodeDeviceInteractor.initalize()
                        barcodeDeviceInteractor.didReceiveDecodedDataCompletation =  { [weak self] (d1Barcode) in
                            guard let self = self else {return}
                            if let id_product = d1Barcode{
                                self.addProduct(with: id_product)
                            }
                        }
                    }else{
                        barcodeDeviceInteractor.initalize()
                        
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
        SharedManager.shared.report_memory(prefix:"create_order")
    }
    
    func openTableScreenForWaiter(checkMaster:Bool = true){
        /*
        if (SharedManager.shared.posConfig().pos_type?.lowercased().contains("waiter") ?? false)
        {
            //show_table(fromActionIcon: true,checkMaster:checkMaster)
            openOptionTable(newBannerHolderview.btn_table)
        }
        */
 
        
//        connectionManager.host()
 
        
    }
    func showHideMenuIcon(){
        var multi_session_enable = true
        let multi_session_id = SharedManager.shared.posConfig().multi_session_id  ?? 0
        if multi_session_id == 0
        {
            multi_session_enable = false
        }
        let isHidden = !multi_session_enable
        self.newBannerHolderview.menuOrderHolderview.isHidden = isHidden
        self.newBannerHolderview.menuOrderBadgeHolderview.isHidden = isHidden
    }
    
    @IBAction func btn_enable_sound(_ sender: Any) {
        let is_enable = cash_data_class.get(key: "enable_sound") ?? "1"
        if is_enable == "0"
        {
            cash_data_class.set(key: "enable_sound" , value: "1")
            btn_enable_sound.isSelected = false
            enable_sound_notification = true

        }
        else
        {
            cash_data_class.set(key: "enable_sound" , value: "0")
            btn_enable_sound.isSelected = true
            enable_sound_notification = false

        }
        
    }
    @IBAction func btnSelectOrderType(_ sender: Any) {
        show_order_type()
    }
     func hideFailureMessageBtn(){
        DispatchQueue.main.async {
            self.newBannerHolderview.ipHolderview.isHidden = false //MWMessageQueueRun.shared.getCountFailureMessage() <= 0
            self.setFaluireIpBadge()
        }
    }
    @objc func controlFailureMessageNotification(notification: Notification ){
        hideFailureMessageBtn()
}
    @IBAction func tapOnFailureSentToKitchBtn(_ sender: UIButton) {
        let vc = MessageIpErrorVC.createModule(sender)
        vc.completeHandler = {
            self.hideFailureMessageBtn()
        }
        self.present(vc, animated: true)
    }
    @IBAction func tapOnTableMagmentBtn(_ sender: UIButton) {
//        guard  rules.check_access_rule(rule_key.table_management) else {
//            return
//        }
//        rules.check_access_rule(rule_key.table_management,for: self) {
//            DispatchQueue.main.async {
//                self.show_table(for: rule_key.table_management, fromActionIcon: true)
//            }
//        }
        
    }
    @IBAction func tapOnPrintBillBtn(_ sender: UIButton) {
        if self.orderVc?.order.id == 0 ||
            self.orderVc?.order.id == nil ||
            self.orderVc?.order.pos_order_lines.count == 0 {
         return
        }
        self.print_res()
            sender.tintColor = #colorLiteral(red: 0.9682098031, green: 0.5096097589, blue: 0.1061020121, alpha: 1)
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                sender.tintColor = #colorLiteral(red: 0.6431372549, green: 0.662745098, blue: 0.6980392157, alpha: 1)
            }, completion: {_ in
                        
                        sender.isEnabled = false
                        sender.isEnabled = true
            })
       
        

    }
    
    
    func check_rules()
    {
        /*
        if  user.canAccess(for: .table_management) == false
        {
            newBannerHolderview.btn_table.isEnabled = false
            
        }
     
//        if   user.access_rules.firstIndex(where: {$0.key == .select_customer}) == nil
//        {
//            btnSelectCustomer.isEnabled = false
//
//        }
        
        if  user.canAccess(for: .payment) == false
        {
            btnPayment.isEnabled = false
            
        }
        */
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
//            self.check_printer()
//        })

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            self.init_alert_notificationCenter()
        })
 

  
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MaintenanceInteractor.shared.searchBluetoothPrinter()
        
        
        if let count = printer_error_class.getCount(){
            self.newBannerHolderview.printerBadgeHolderviewl.isHidden = false

            self.newBannerHolderview.badgePrinterLbl.text =  "\(count)"
        }else{
            self.newBannerHolderview.printerBadgeHolderviewl.isHidden = true
        }
        showHideMenuIcon()
        self.navigationController?.isNavigationBarHidden = true
        
        init_notificationCenter()
        
        initViewOrderList()
        
        
        var reloadListOrder:Bool = true
        if payment_Vc != nil
        {
            
            reloadListOrder =  payment_Vc.clearHome
            payment_Vc = nil
        }
        
        if reloadListOrder == true
        {
            reloadListOrder = reload_create_order
        }
        DispatchQueue.main.async {
            self.newBannerHolderview.setEnableNewOrder(with: true)
            if reloadListOrder == true
            {
                self.showLastOrder()
                self.readOrder()
                self.reloadTableOrders()
            }
            
            
            self.checkCustomerSelected()
            //        checkCategorySelected()
            self.checkBadgeOrder()
            self.checkBadge()
            
            self.clear_right()
            self.hideFailureMessageBtn()
            
            
            DeliveryOrderIntegrationInteractor.shared.runTaskForSetTimeOut()
            self.newBannerHolderview.sendToKitchenHolderView.isHidden = SharedManager.shared.appSetting().hide_sent_to_kitchen_btn
            // self.btn_send_kitchen.isHidden = SharedManager.shared.appSetting().hide_sent_to_kitchen_btn
            self.setFaluireIpBadge()
            self.showBannerWaitingSearchIP()
            WaringToast.shared.handleShowAlertWaring(complete: nil)
            LicenseInteractor.shared.handleShowAlertLicense(for: [.NEW_ORDER], complete: nil)
            
        }
//        LicenseInteractor.shared.showNotFullAccessLicense()
    }
    
 
    
    func pendding_options() -> ordersListOpetions
    {
        let ActiveSession = pos_session_class.getActiveSession()
        
        let session_id = ActiveSession!.id
        
        let opetions = ordersListOpetions()
        opetions.Closed = false
        opetions.Sync = false
        opetions.void = false
        opetions.order_menu_status = [.accepted]
        opetions.pickup_users_ids = [0]
        
        opetions.sesssion_id = session_id
        opetions.parent_product = true
        
        opetions.LIMIT = 10
        opetions.orderDesc = true
        
       // opetions.get_lines_void = true
        opetions.get_lines_void_from_ui = true
        
//        opetions.order_by_products = true
        
        if lstInvoices.show_all_orders == false {
            opetions.write_pos_id = SharedManager.shared.posConfig().id
        }
        
        return opetions
    }
    /*
    func getSTock()
    {
        
        let pos = SharedManager.shared.posConfig()
        if pos.stock_location_id  != nil
        {
 
            con.userCash = .stopCash
            con.get_stock_by_location(loc_id:pos.stock_location_id!) { (result) in
                if (result.success)
                {
                    
                    self.stocks = result.response?["result"] as? [String:[String:Any]] ?? [:]
 
                }
                
             }
        }
        
        
    }
    */
    
    func get_order_pendding()  {
        list_order_created.removeAll()
        
        
        
        let arr = pos_order_helper_class.getOrders_status_sorted(options: pendding_options(),needProduct: false)
        list_order_created.append(contentsOf: arr)
        
        
    }
    
    func reset_view_order()  {
        setTitleInfo()
                   resetOrderView()
                   
                   orderVc?.order = pos_order_class()
                   orderVc?.resetVales()
        
        reloadTableOrders()
        orderVc?.reload_tableview()
    }
    func showIntialNewOrder(order_visible_id:Int?){
        guard  let order_visible_id = order_visible_id else{return}
        var index_in = 0
        
        index_in =  list_order_created.firstIndex(where:{  $0.id == order_visible_id} ) ?? 0
        
        
        orderVc?.order =  list_order_created[index_in]
//        orderVc?.order.reFetchPosLines()
//        if orderVc?.order.pos_order_lines.count != 0
//        {
//            orderVc?.order.cashier = user
//            orderVc?.order.session_id_local = pos_session_class.getActiveSession()!.id
//        }
//            else{
//                self.payment_Vc = nil
//            }
        
        readOrder()
        reloadTableOrders()
        orderVc?.reload_tableview()
    }
    func showLastOrder ()  {
        
        clear_right()
        self.payment_Vc = nil
        
        let order_visible_id  = orderVc?.order.id
        
        get_order_pendding()
        
        let count = list_order_created.count
        if  count == 0
        {
            setTitleInfo()
            resetOrderView()
            
            orderVc?.order = pos_order_class()
            orderVc?.resetVales()
            
         }
        else
        {
            guard  let order_visible_id = order_visible_id else{return}
            var index_in = 0
            
            index_in =  list_order_created.firstIndex(where:{  $0.id == order_visible_id} ) ?? 0
            
            
            orderVc?.order =  list_order_created[index_in]
            orderVc?.order.reFetchPosLines()
            if orderVc?.order.pos_order_lines.count != 0
            {
                orderVc?.order.cashier = user
                orderVc?.order.session_id_local = pos_session_class.getActiveSession()!.id
            }
//            else{
//                self.payment_Vc = nil
//            }
            
            readOrder()
            
        }
        
        reloadTableOrders()
        orderVc?.reload_tableview()
        
        
        
    }
    
    
    func reloadOrders(line:pos_order_line_class?)
    {
   
        let is_empty = orderVc?.order.pos_order_lines.filter({$0.is_void == false}) ?? []
        if is_empty.count == 0
        {
            cancel_discount()
        }
        
        let discountLine = orderVc?.order.get_discount_line()
        
        if discountLine == nil {
            newBannerHolderview.labelDiscount.text = "Discount".arabic("خصم")
        }
        
        showLastOrder()
        
//        if line != nil
//        {
//            handle_promotion(line: line)
            
//        }
        
        
    }
    
    func order_selected(order_selected:pos_order_class)
    {
        if let brandID = order_selected.brand_id {
        if brandID != SharedManager.shared.selected_pos_brand_id {
             res_brand_class.setSelected(brandID: brandID)
            self.didSelectBrand()
        }
        }
        orderVc?.order = order_selected
        let line_discount = self.orderVc?.order.get_discount_line()
        if line_discount != nil
        {
            newBannerHolderview.labelDiscount.text = "Cancel Discount".arabic("إلغاء الخصم")
        } else {
            newBannerHolderview.labelDiscount.text = "Discount".arabic("خصم")
        }
        readOrder()
        
        reloadTableOrders()
        orderVc?.reload_tableview()
        
        pageCurl_fromLeft()
        remove_payment()
        if SharedManager.shared.appSetting().enable_make_user_resposiblity_for_order {
            newBannerHolderview.setEnableSendKitchen(with: true)
        }
        if !pos_order_class.checkIfSessionHaveEmptyOrder() {
            newBannerHolderview.setEnableNewOrder(with: true)
        } else {
            newBannerHolderview.setEnableNewOrder(with: false)
        }
    }
    
    
    func order_deleted(order_selected:pos_order_class)
    {
        
       
        
        if comboList != nil
        {
            comboList.view.removeFromSuperview()
            self.comboList = nil

        }
        
      //  showLastOrder()
        setTitleInfo()
        resetOrderView()
        
        orderVc?.order = pos_order_class()
        orderVc?.resetVales()
 
        clear_right()

        checkBadge()
        pageCurl_fromRight()
        
    }
    
    
  
    
    func cash_in_out(cash_out:Bool)
    {
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "cash_in_out") as! cash_in_out
        vc.cash_out = cash_out
        
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: true, completion: nil)
    }
}
extension create_order: NewBannerDelegate {
    func showListMenuOrder(sender: Any) {
        let storyboard = UIStoryboard(name: "menuList", bundle: nil)
        lst_menu = storyboard.instantiateViewController(withIdentifier: "menuList") as? menuList
        lst_menu!.modalPresentationStyle = .popover
        //        invoices_List.delegate = self
        lst_menu!.preferredContentSize = CGSize(width: 683, height: 700)
        lst_menu!.delegate = self
        lst_menu!.option.sesssion_id = pos_session_class.getActiveSession()!.id
        lst_menu!.option.Closed = false
        lst_menu!.option.Sync = false
        lst_menu!.option.void = false
        lst_menu!.option.order_menu_status = [.pendding]
        lst_menu!.option.order_integration = [ORDER_INTEGRATION.ONLINE,ORDER_INTEGRATION.DELIVERY]
        
        
        let popover = lst_menu!.popoverPresentationController!
        //        popover.delegate = self
        popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(lst_menu!, animated: true, completion: nil)
    }
    func showTableManagement(sender: Any) {
//        guard  rules.check_access_rule(rule_key.table_management) else {
//            return
//        }
//        self.show_table(fromActionIcon: true)
//        
        
        if newBannerHolderview.btn_table.tag == 1 {
            if orderVc?.order.driver == nil
            {
                show_drives(sender as? UIView ?? UIView())
            }else{
                changeDriver(sender as? UIView ?? UIView())
            }
          return
        }
//        guard  rules.check_access_rule(rule_key.table_management) else {
// 
//            return
//        }
        
        
        if (orderVc?.order.table_name ?? "").isEmpty
        {
            //show_table()
            if let viewSender = sender as? UIView{
                self.openOptionTable(viewSender)
            }
        }
        else
        {
            if let viewSender = sender as? UIView{
                self.openOptionTable(viewSender)
            }
            /*
            let alert = UIAlertController(title: "Table".arabic("طاوله"), message: "", preferredStyle: .actionSheet)
            alert.popoverPresentationController?.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
            alert.popoverPresentationController?.sourceView = sender as? UIView
            alert.popoverPresentationController?.sourceRect =  (sender as AnyObject).bounds
            
            
            alert.addAction(UIAlertAction(title: "Chose/Change table".arabic("اختيار/تغيير الطاوله") , style: .default, handler: { (action) in
                guard  rules.check_access_rule_select_change_table() else {
         
                    return
                }
                self.show_table(changeTable: true)
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel table".arabic("الغاء الطاوله") , style: .destructive, handler: { (action) in
            
               
                
                
                alert.dismiss(animated: true, completion: self.cancelTableAlert)
                
            }))
            
            
            
            
            
            
            self .present(alert, animated: true, completion: nil)
            */
        }
    }
    func cancelTableAlert(){
        rules.check_access_rule(.cancle_table,for: self)  {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Cancel table".arabic("إلغاء الطاولة"), message: "Are you sure void table from current order?".arabic("هل أنت متأكد من إلغاء الطاوله من الطلب الحالي؟"), preferredStyle: .alert)
                
                
                
                alert.addAction(UIAlertAction(title: "Yes".arabic("نعم") , style: .destructive, handler: { (action) in
                    
                    self.cancel_table()

                }))
                
                
                
                alert.addAction(UIAlertAction(title: "NO".arabic("لا"), style: .cancel, handler: { (action) in
                    
                }))
                
                
                self.present(alert, animated: true, completion: nil)
            }
        }
       
    }
    func showMessageAlert(message:String){
        
        messages.showAlert( message, title:"")

    }
    func createNewOrder(sender: Any) {
        //        lblinfo.text = "Order list"
        self.newBannerHolderview.labelDiscount.text = "Discount".arabic("خصم")
        if let selectBrandvc = SelectBrandVC.createModule(sender as? UIView,option: .ADD_NEW_ORDER) as? SelectBrandVC {
            selectBrandvc.completionBlock = { selectDataList in
                self.didSelectBrand()
                self.addNewOrderCompletion()
            }
            self.present(selectBrandvc, animated: true, completion: nil)
        }else{
            addNewOrderCompletion()
        }
    }
    func showListOfOrders(sender: Any) {
        let storyboard = UIStoryboard(name: "invoicesList", bundle: nil)
        lstInvoices = storyboard.instantiateViewController(withIdentifier: "invoicesListCollection") as? invoicesListCollection
        lstInvoices.modalPresentationStyle = .popover
        //        invoices_List.delegate = self
        lstInvoices.preferredContentSize = CGSize(width: 683, height: 700)
        lstInvoices.delegate = self
        lstInvoices.option.sesssion_id = pos_session_class.getActiveSession()!.id
        lstInvoices.option.Closed = false
        lstInvoices.option.Sync = false
        lstInvoices.option.void = false
        
        
        lstInvoices!.option.order_menu_status = [.accepted]
        
        //        lstInvoices.parent_id = "all"
        
        let popover = lstInvoices.popoverPresentationController!
        //        popover.delegate = self
        popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)

        self.present(lstInvoices, animated: true, completion: nil)
    }
    func showPrinter() {
        //  self.check_printer()
      var vc:UIViewController = PrinterErrorVC()
      if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
          // vc = DevicesMangmentVC.createModule()
          if let segmentVC = MWSegmentRouter.createMWprinterMangerWithErrorPrinter() {
              vc = segmentVC
          }
      }
      vc.modalPresentationStyle = .formSheet
      vc.preferredContentSize = CGSize(width: 900, height: 700)

//        vc.popoverPresentationController?.sourceView = sender as? UIView
      self.present(vc, animated: true, completion: nil)
    }
    func sendToKitchen(sender: Any) {
        
        if self.orderVc?.order?.orderType?.required_guest_number ?? false && self.orderVc?.order.table_name != nil
            && self.orderVc?.order?.table_name?.isEmpty == false && self.orderVc?.order.guests_number == nil {
            
            self.add_guests_number()
            
        } else {
            
            
            guard let orderID = self.orderVc?.order.id else{return}
            if (self.orderVc?.order.orderType?.required_table) ?? false {
                if self.orderVc?.order.table_id == nil || self.orderVc?.order.table_id == 0{
                    messages.showAlert("You must choose table before send order to kitchen".arabic("يجب أن تختار الطاولة قبل إرسال الطلب إلى المطبخ"))
                    return
                }
            }
            
            
            
            let validateRequireCustomer = orderVc?.order.validationSelectCustomer(forSentToKitchen: true) ?? (true,"")
            if !validateRequireCustomer.0 {
                messages.showAlert(validateRequireCustomer.1)
                return
            }
            
            //        for line in orderVc?.order.pos_order_lines
            //        {
            //            if line.kitchen_status != .done
            //            {
            //                line.kitchen_status = .send
            //            }
            //
            //            line.pos_multi_session_status = .sending_update_to_server
            //
            //           _ = line.save(write_info: false)
            //        }
            //
            //        orderVc?.order.save(write_info: true)
            
            
            //        DispatchQueue.global(qos: .background).async {
            //            if self.orderVc?.order!.amount_total > 0.0
            //              {
            
            pos_order_helper_class.increment_print_count(order_id: orderID)
            
            
            //        DispatchQueue.global(qos: .background).async {
            
            //            let opetions = ordersListOpetions()
            //            opetions.get_lines_void = true
            //            opetions.uid = self.orderVc?.order.uid
            //            opetions.parent_product = true
            //            opetions.printed = false
            //
            //            let temp_order = pos_order_helper_class.getOrders_status_sorted(options: opetions)
            //            if temp_order.count > 0
            //            {
            //                let ord:pos_order_class = temp_order[0]
            //
            //                // remove line that delete before send to printer
            //
            //                 ord.pos_order_lines.removeAll{  $0.is_void == true && $0.pos_multi_session_write_date == ""  }
            //
            //
            //                for line in ord.pos_order_lines
            //                {
            //                    if line.is_combo_line == true
            //                    {
            //                        line.selected_products_in_combo.removeAll{  $0.is_void == true && $0.pos_multi_session_write_date == ""  }
            //
            //                        line.selected_products_in_combo.removeAll{  $0.printed == .printed   }
            //                    }
            //
            //                }
            //
            //                self.otherPrinter!.printToAvaliblePrinters(Order: ord )
            //
            //            }
            guard let order_vc = self.orderVc else {return}
            if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
                order_vc.order.creatKDSQueuePrinter(.kds)
                MWRunQueuePrinter.shared.startMWQueue()
            }else{
                let ord = self.otherPrinter?.prepear_order(order: order_vc.order ,reReadOrder: true)
                self.otherPrinter!.printToAvaliblePrinters(Order: ord)
                SharedManager.shared.epson_queue.run()
            }
            
            
            
            
            //           }
            
            //              }
            //        }
            
            
            self.orderVc?.order.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
            
            var ip_message_type: IP_MESSAGE_TYPES = .NEW_ORDER
            if self.orderVc?.order.checISSendToMultisession() ?? false {
                ip_message_type = .ChANGED_ORDER
            }
            self.orderVc?.order.save_and_send_to_kitchen(with:ip_message_type, for: [.KDS,.NOTIFIER])
            
            
            newBannerHolderview.setEnableSendKitchen(with: false)
            
            
            clear_right()
            openTableScreenForWaiter()
            
            self.orderVc?.order.reloadOrder(with: pendding_options())
            orderVc?.tableview.reloadData()
        }
    }
    func showSideMenu(sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.centerContainer?.open(.left, animated: false, completion: nil)
    }
    func onFailureSentToKitchen(sender: Any) {
        let vc = MessageIpErrorVC.createModule(sender as? UIView)
        vc.completeHandler = {
            self.hideFailureMessageBtn()
        }
        self.present(vc, animated: true)
    }
    func completeBonatCode(_ value:String){
        if (self.orderVc?.order.reward_bonat_code ?? "") == value {
            return
        }
        self.clear_right()
        
        resetPromotion()
        
        self.orderVc?.order.reward_bonat_code = value
        self.newBannerHolderview.labelPromotionCode.text = value
        
        //TODO: - Check if code valid or not and if valid get it's value
        
        if ( value != "")
        {
            
            self.orderVc?.order.save()
            self.newBannerHolderview.iconPromotion.isHighlighted = true
            BonatCodeInteractor.shared.checkRewardBonat(order: self.orderVc?.order) { result in
                if result {
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    alert.popoverPresentationController?.sourceView = self.view
                    alert.popoverPresentationController?.sourceRect =  CGRect(x: self.view.bounds.midX,
                                                                              y: self.view.bounds.midY,
                                                                              width: 0,
                                                                              height: 0)
                    alert.popoverPresentationController?.permittedArrowDirections = []
    
                    guard let promoObject = promo_bonat_class.get(by:self.orderVc?.order.uid ?? "" , isVoid: false), let discount_amount = promoObject.discount_amount else {
                        messages.showAlert("This code is expired".arabic("هذا الكود منتهي"))
                        return
                    }
                    let title = "Redeem Reward\n".arabic("")
                    var message: String
                    if promoObject.is_percentage ?? false {
                        message = "% \(discount_amount)"
                    } else {
                        message = "\(SharedManager.shared.posConfig().currency_name ?? "SAR") \(discount_amount)"
                    }
                    
                    let titleFont = UIFont.boldSystemFont(ofSize: 22)
                    let messageFont = UIFont.systemFont(ofSize: 20)
                    
                    let titleAttributes: [NSAttributedString.Key: Any] = [
                        .font: titleFont,
                        .foregroundColor: UIColor.black
                    ]
                    
                    let messageAttributes: [NSAttributedString.Key: Any] = [
                        .font: messageFont,
                        .foregroundColor: UIColor.darkGray
                    ]
                    
                    let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
                    let attributedMessage = NSAttributedString(string: message, attributes: messageAttributes)
                    
                    // Set attributed title and message
                    alert.setValue(attributedTitle, forKey: "attributedTitle")
                    alert.setValue(attributedMessage, forKey: "attributedMessage")
                    
                    
                    alert.addAction(UIAlertAction(title: "Reward Redeem".arabic("") , style: .default, handler: { (action) in
                        BonatCodeInteractor.shared.redeemRewardBonat(order:self.orderVc?.order)
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel".arabic("الغاء") , style: .destructive, handler: { (action) in
                        promo_bonat_class.void(for:self.orderVc?.order.uid ?? "" , isVoid: true)
                        self.cancel_discount()
                        alert.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    DispatchQueue.main.async {
                        messages.showAlert("Coupon does not exist".arabic("هذا الكود غير موجود"))
                    }
                    promo_bonat_class.void(for:self.orderVc?.order.uid ?? "" , isVoid: true)
                    self.cancel_discount()
                }
                
                self.reloadTableOrders(re_calc: true )

            }

        }
        else
        {
            if let promoBonat = promo_bonat_class.get(by:orderVc?.order.uid ?? "" ){
                promoBonat.promo_code = ""
                promoBonat.mobile_number = orderVc?.order.customer?.phone
                promoBonat.update()
            }
            self.newBannerHolderview.iconPromotion.isHighlighted = false
            checkTotalDiscount()
            self.reloadTableOrders(re_calc: true )
          

        }
       
    }
    func completeBtnPromotionCode(_ sender: Any,type:PROMO_CODE_TYPES){
        self.getPromotionCode =  addPromoCodeVC()
        self.getPromotionCode.typeCode = type
        self.getPromotionCode.modalPresentationStyle = .popover
        //        invoices_List.delegate = self
        self.getPromotionCode.preferredContentSize = CGSize(width: 440, height: 316)
        
        
        let popover = self.getPromotionCode.popoverPresentationController!
        //        popover.delegate = self
        //            popover.permittedArrowDirections = .left //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        self.getPromotionCode.code = type == .DGTERA ? (self.orderVc?.order?.promotion_code ?? "") : (self.orderVc?.order?.reward_bonat_code ?? "")
        switch type {
        case .DGTERA:
            self.getPromotionCode.code = (self.orderVc?.order?.promotion_code ?? "")
        case .Coupon:
            self.getPromotionCode.code = (self.orderVc?.order?.coupon_code ?? "")
        case .BONATE:
            self.getPromotionCode.code = (self.orderVc?.order?.reward_bonat_code ?? "")
        }
        
        self.getPromotionCode.didSelect = { [self]   (value,type) in
            if value.isEmpty
            {
                DispatchQueue.main.async { [weak self] in
                    self?.newBannerHolderview.iconPromotion.isHighlighted = false
                    self?.newBannerHolderview.labelPromotionCode.text = ""
                    self?.orderVc?.order.promotion_code = ""
                    self?.resetCouponUI()
                    self?.cancel_discount()
                }
                self.reloadTableOrders(re_calc: true )
                return
            }
            
            if type == .BONATE {
                self.completeBonatCode(value)
                return
            }
            if type == .Coupon {
                self.completeCouponCode(value)
                return
            }
            if (self.orderVc?.order.promotion_code ?? "") == value {
                return
            }
            self.clear_right()
            resetPromotion()
            
            self.orderVc?.order.promotion_code = value
//            self.btnPromotionCode.setTitle(value, for: .normal)
            self.newBannerHolderview.labelPromotionCode.text = value


            
            if ( value != "")
            {
                
                self.orderVc?.order.save()
                self.newBannerHolderview.iconPromotion.isHighlighted = true

            }
            
//            checkTotalDiscount()
            self.reloadTableOrders(re_calc: true )

        }
        
        self.present(self.getPromotionCode, animated: true, completion: nil)
    }
    func selectPromoCodeType(sender: UIView){
        let alert = UIAlertController(title: "Choose".arabic("إختر"), message: "Please Select promo code type".arabic("من فضلك اختر كود العرض"), preferredStyle: .actionSheet)
           
        alert.addAction(UIAlertAction(title: PROMO_CODE_TYPES.DGTERA.getTitle(), style: .default , handler:{ (UIAlertAction)in
            self.showPromotionCode2(sender: sender,type:PROMO_CODE_TYPES.DGTERA)
           }))
           
        alert.addAction(UIAlertAction(title: PROMO_CODE_TYPES.Coupon.getTitle(), style: .default , handler:{ (UIAlertAction)in
            self.showPromotionCode2(sender: sender,type:PROMO_CODE_TYPES.Coupon)
           }))
        
        alert.addAction(UIAlertAction(title: PROMO_CODE_TYPES.BONATE.getTitle(), style: .default , handler:{ (UIAlertAction)in
            self.showPromotionCode2(sender: sender,type:PROMO_CODE_TYPES.BONATE)
//            if (self.orderVc?.order.customer?.phone ?? "").isEmpty{
//                messages.showAlert( "Require customer mobile number".arabic("يجب تحديد رقم جوال العميل"), title:"")
//                return
//            }else{
//                self.showPromotionCode2(sender: sender,type:PROMO_CODE_TYPES.BONATE)
//            }
           }))

           
           alert.popoverPresentationController?.sourceView = sender

           self.present(alert, animated: true, completion: nil)
    }
    func showPromotionCode(sender: Any) {
        if !(SharedManager.shared.posConfig().loyalty_type ?? "").isEmpty{
            if let sender = sender as? UIView{
                self.selectPromoCodeType(sender: sender )
            }
        }else{
            self.showPromotionCode2(sender: sender,type:PROMO_CODE_TYPES.DGTERA)
        }
    }
    func showPromotionCode2(sender: Any,type:PROMO_CODE_TYPES) {
        
            if !MWMasterIP.shared.isOnLine(){
                messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
                return
            }
            if orderVc?.order.id == nil {
                addNewOrder {
                    self.completeBtnPromotionCode(sender,type: type)
                }
            }else{
                self.completeBtnPromotionCode(sender,type: type)
            }
      
    
    }
    func addNotes() {
        self.add_note(product: nil)
    }
    func printBill() {
        if payment_Vc != nil {
            self.remove_payment()
        }
        if self.orderVc?.order.id == 0 ||
            self.orderVc?.order.id == nil ||
            self.orderVc?.order.pos_order_lines.count == 0 {
            return
        }
        self.print_res()
    }
    func applyDiscount() {
        // Check if the payment screen is open
        if payment_Vc != nil {
            // Present an alert to the user
            showAlertWithOptionToCancelPayment()
            return
        }
        // Check if the order is valid and has items
//        guard  rules.check_access_rule(rule_key.discount) else {
//            return
//        }
        let pos = SharedManager.shared.posConfig()
        if pos.allow_discount_program == false {
            return
        }
        if self.orderVc?.order.id == 0 || self.orderVc?.order.id == nil || self.orderVc?.order.pos_order_lines.count == 0 {
            return
        }
        let line_discount = self.orderVc?.order.get_discount_line()
        if line_discount != nil {
            cancel_discount()
            return
        }
        show_discount()
/*
        let pos = SharedManager.shared.posConfig()
        if pos.allow_discount_program == true {
//            if user.canAccess(for: .discount) == false {
//                newBannerHolderview.discountBtn.isEnabled = false
//            }
        }
        */
    }
    func showAlertWithOptionToCancelPayment() {
        let title = "Discount Not Allowed".arabic("غير مسموح بالخصم")
        let message = "You can't apply a discount while payment is in progress. Do you want to continue without discount or cancel the payment?".arabic("لا يمكنك تطبيق خصم أثناء عملية الدفع. هل تريد المتابعة بدون خصم أو إلغاء الدفع؟")
        let continueButtonTitle = "Continue".arabic("متابعة")
        let cancelButtonTitle = "Cancel Payment".arabic("إلغاء الدفع")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let continueAction = UIAlertAction(title: continueButtonTitle, style: .default) { _ in }
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.remove_payment()
        }

        alertController.addAction(continueAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    func showSettings(sender: Any)
    {
        if self.payment_Vc != nil
        {
            messages.showAlert("You can't change order options in payment screen.".arabic("لا يمكنك تغيير خيارات الطلب في شاشة الدفع."))
            return
        }
        
        if self.orderVc?.order.id == nil
        {
            return
        }
        let pos = SharedManager.shared.posConfig()
        
        let list = options_listVC(nibName: "options_popup", bundle: nil)
        list.hideClearBtnFlag = true
        list.modalPresentationStyle = .overFullScreen
        list.modalTransitionStyle = .crossDissolve
        
        
        list.title = "Pleas select action.".arabic("الرجاء تحديد الإجراء.")
        
        //        if  orderVc?.order.amount_total > 0
        //        {
        //            list.add(title: "Price list".arabic("قائمة الاسعار"), data: show_price_list)
        list.add(title: "Order type".arabic("نوع الطلب"), data: show_order_type)
        
        //            if pos.allow_discount_program == true
        //            {
        //                var dic:[String:Any] = [:]
        //                dic[options_listVC.title_prefex] =  "Discount".arabic("خصم")
        //                dic["data"] = show_discount
        //
        //                if user.canAccess(for: .discount) == false
        //                {
        //                    dic[options_listVC.cell_style] = options_listVC.style_disable
        //                }
        //
        //                list.list_items.append(dic)
        //
        ////                list.add(title: "Discount".arabic("خصم"), data: show_discount)
        //            }
        
        //            let line_discount = self.orderVc?.order.get_discount_line()
        //            if line_discount != nil
        //            {
        //                list.add(title: "Cancel Discount".arabic("إلغاء الخصم"), data: cancel_discount)
        //
        //            }
        
        list.add(title: MWConstants.scrap_title, data: show_scrap)
        
        //        }
        
        //        list.add(title: "Add order note".arabic("اضافه ملاحظه"), data: show_add_note)
        //        list.add(title: "Print".arabic("طبع"), data: print_res)
        //        list.add(title: "void".arabic("حذف"), data: void_order)
        list.addAction(title: "Offers".arabic("عروض"), action: { [weak self] in
            guard let self = self else { return }
            self.showPromotionCode(sender: sender)
        })


        list.add(title: "Split".arabic("تقسيم الفاتوره"), data: split_order_method)
        list.add(title: "Move Items".arabic("نقل العناصر"), data: move_items_method)
        
        list.add(title: "Add guests number".arabic("إضافة عدد الضيوف"), data: add_guests_number)
        list.add(title: "Send note via KDS printers".arabic("ارسال ملاحظات من خلال طابعات المطبخ"), data: send_note_via_kds_printers)
        list.add(title: "Settings".arabic("الإعدادات"), data: showPrinter)

        //        list.add(title: "Cancel", data: nil)
        
        options_listVC.show_option(list:list,viewController: self, sender: sender   )
        
        list.didSelect_func = {    fnc in
            fnc()
        }
    }
    func applyVoid() {
        void_order()
    }
    
    func prevent_create_order_when_exist_is_empty() -> Bool {
        if SharedManager.shared.appSetting().prevent_new_order_if_empty {
            if !pos_order_class.checkIfSessionHaveEmptyOrder() {
                newBannerHolderview.setEnableNewOrder(with: true)
                return false
            } else {
                newBannerHolderview.setEnableNewOrder(with: false)
                return true
            }
        } else {
            newBannerHolderview.setEnableNewOrder(with: true)
            return false
        }
    }
    func completeCouponCode(_ value: String) {
        guard hasCodeChanged(value) else { return }
        
        prepareForCouponProcessing(value)
        
        if !value.isEmpty {
            processCouponCode(value)
        }
    }
    
    private func hasCodeChanged(_ newCode: String) -> Bool {
        return (orderVc?.order.coupon_code ?? "") != newCode
    }

    private func prepareForCouponProcessing(_ code: String) {
        clear_right()
        resetPromotion()
        orderVc?.order.coupon_code = code
        newBannerHolderview.labelPromotionCode.text = code
    }
    
    private func processCouponCode(_ code: String) {
        orderVc?.order.save()
        newBannerHolderview.iconPromotion.isHighlighted = true
        
        CouponCodeInteractor.shared.checkCouponReward(order: orderVc?.order) { [weak self] result in
            guard let self = self else { return }
            
            if result {
                self.handleValidCoupon()
            } else {
                self.handleInvalidCoupon()
            }
            
            self.reloadTableOrders(re_calc: true)
        }
    }
    
    private func handleValidCoupon() {
        guard let coupon = validateAndGetCoupon() else {
            showInvalidCouponAlert()
            return
        }
        
        presentRedeemAlert(for: coupon)
    }

    private func handleInvalidCoupon() {
        showInvalidCouponAlert()
        cancel_discount()
    }
    
    private func validateAndGetCoupon() -> promo_coupon_class? {
        guard let orderUid = orderVc?.order.uid,
              let coupon = promo_coupon_class.get(by: orderUid),
              let discountAmount = coupon.amount,
              (coupon.remaining_coupons_number ?? 0) > 0 else {
            return nil
        }
        return coupon
    }
    
    private func showInvalidCouponAlert() {
        resetCouponUI()
        DispatchQueue.main.async { [weak self] in
            self?.newBannerHolderview.labelPromotionCode.text = ""
            self?.newBannerHolderview.iconPromotion.isHighlighted = false
            messages.showAlert("You entered wrong or expired coupon code".arabic(" هذا الكوبون خطأ أو قد انتهى"))
        }
    }

    private func resetCouponUI() {
        orderVc?.order.coupon_code = ""
    }

    private func presentRedeemAlert(for coupon: promo_coupon_class) {
        let alert = createRedeemAlert()
        configureAlertPresentation(alert)
        
        let (title, message) = createAlertContent(for: coupon)
        setAlertAttributedText(alert, title: title, message: message)
        
        addRedeemAction(to: alert, coupon: coupon)
        addCancelAction(to: alert)
        
        present(alert, animated: true)
    }
    
    private func createRedeemAlert() -> UIAlertController {
        return UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    }

    private func configureAlertPresentation(_ alert: UIAlertController) {
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(
            x: view.bounds.midX,
            y: view.bounds.midY,
            width: 0,
            height: 0
        )
        alert.popoverPresentationController?.permittedArrowDirections = []
    }

    private func createAlertContent(for coupon: promo_coupon_class) -> (title: String, message: String) {
        let title = "Redeem Reward\n".arabic("")
        let message = formatDiscountMessage(
            amount: coupon.amount ?? 0,
            isPercentage: coupon.type == "percentage"
        )
        return (title, message)
    }

    private func formatDiscountMessage(amount: Double, isPercentage: Bool) -> String {
        if isPercentage {
            return "% \(amount)"
        } else {
            let currency = SharedManager.shared.posConfig().currency_name ?? "SAR"
            return "\(currency) \(amount)"
        }
    }

    private func setAlertAttributedText(_ alert: UIAlertController, title: String, message: String) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black
        ]
        
        let messageAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.darkGray
        ]
        
        alert.setValue(NSAttributedString(string: title, attributes: titleAttributes), forKey: "attributedTitle")
        alert.setValue(NSAttributedString(string: message, attributes: messageAttributes), forKey: "attributedMessage")
    }
    
    private func addRedeemAction(to alert: UIAlertController, coupon: promo_coupon_class) {
        let action = UIAlertAction(title: "Redeem Reward".arabic(""), style: .default) { [weak self] _ in
            self?.handleRedeemAction(coupon: coupon)
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
    }

    private func addCancelAction(to alert: UIAlertController) {
        let action = UIAlertAction(title: "Cancel".arabic("الغاء"), style: .destructive) { [weak self] _ in
            self?.cancel_discount()
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
    }
    
    private func handleRedeemAction(coupon: promo_coupon_class) {
        guard validateMinimumOrderAmount(coupon) else {
            showMinimumAmountAlert(coupon.min_order_amount ?? 0)
            resetCouponUI()
            return
        }
        
        guard let productDiscount = pos_discount_program_class.get_discount_product() else {
            return
        }
        
        productDiscount.discount_program_id = coupon.id ?? 0
        
        if !validateFixedDiscount(coupon) {
            showMinimumAmountAlert(coupon.min_order_amount ?? 0)
            resetCouponUI()
            return
        }
        
        applyCouponDiscount(coupon, productDiscount: productDiscount.product)
    }

    private func validateMinimumOrderAmount(_ coupon: promo_coupon_class) -> Bool {
        let minAmount = coupon.min_order_amount ?? 0
        let orderAmount = orderVc?.order.amount_total ?? 0
        return orderAmount >= minAmount
    }

    private func validateFixedDiscount(_ coupon: promo_coupon_class) -> Bool {
        guard coupon.type == "fixed" else { return true }
        let orderAmount = orderVc?.order.amount_total ?? 0
        let discountAmount = coupon.amount ?? 0
        return orderAmount >= discountAmount
    }

    private func showMinimumAmountAlert(_ minAmount: Double) {
        DispatchQueue.main.async { [weak self] in
            self?.newBannerHolderview.labelPromotionCode.text = ""
            self?.newBannerHolderview.iconPromotion.isHighlighted = false
            let message = "Order amount must be greater than or equal to \(minAmount)"
                .arabic("يجب ان يكون اجمالي الطلب اكثر من او يساوي \(minAmount)")
            messages.showAlert(message)
        }
    }

    private func applyCouponDiscount(_ coupon: promo_coupon_class, productDiscount: product_product_class) {
        let discountValue = -(coupon.amount ?? 0)
        let isFixed = coupon.type == "fixed"
        
        CouponCodeInteractor.shared.redeemCoupon(order: orderVc?.order) { [weak self] result in
            guard let self = self else { return }
            
            if result {
                self.add_discount(
                    value: discountValue,
                    is_fixed: isFixed,
                    product_discount: productDiscount,
                    discount_display_name: coupon.display_name ?? "",
                    disocunt: nil
                )
                self.reloadTableOrders(re_calc: false)
            } else {
                DispatchQueue.main.async {
                    messages.showAlert("You entered expired coupon code".arabic(" هذا الكوبون قد انتهى"))
                }
                self.cancel_discount()
            }
        }
    }
    
}
