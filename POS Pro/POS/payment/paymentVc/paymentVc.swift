//
//  paymentVc.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit


let DisableKeyboardNotification = Notification.Name("DisableKeyboard")
let EnableKeyboardNotification = Notification.Name("EnableKeyboard")

typealias keyboard_vc = paymentVc

class paymentVc: UIViewController ,payment_method_delegate,paymentRowsVc_delegate ,enterBalance_delegate, paymentSuccessfullMessage_delegate,STC_Delegate{
    
    
    
    
    @IBOutlet weak var viewKeyboard: UIView!
    @IBOutlet weak var view_payment: UIView!
    @IBOutlet weak var btnPay: KButton!
    @IBOutlet weak var view_paymentRows: UIView!
    @IBOutlet weak var oldKeyboardStackview: UIStackView!
    @IBOutlet weak var keyboardPaymentView: KeyboardPayment!
//    let p = printArabicClass()
//    let con = SharedManager.shared.conAPI()
    let con_sync = SharedManager.shared.conAPI()

    var loyaltyCheck:loyalty_check?
    
    var isLoaded:Bool = false
    var clearHome:Bool = false
    var BankPayment = false
    
    
    var orderVc:order_listVc? = order_listVc()
    var payment_methodVC:payment_method?
    var paymentRows:paymentRowsVc? = paymentRowsVc()
    
    var ordersList:pos_order_helper_class? = pos_order_helper_class()
    var paymentRowSelected :account_journal_class?
    var keyboard :enterBalanceNew?
    var STC_VC:STCViewController?
    
    var parent_vc:UIViewController?
    var pickup_user_id:Int?
    var completePayment:(() -> Void)?
    var completeList:(([account_journal_class]?) -> Void)?
    var showCashMethodOnly:Bool = false
    var forReturnItems:Bool = false
    
    var orderTotalAmoutStatus: String = ""
   /*
    var orderUid: String = "" {
        didSet {
            self.orderVc?.order = pos_order_class.get(uid: orderUid)
        }
    }
    */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //        customerVC = nil
        //
        //        paymentVc = nil
        //
        //        ordersList = nil
        //        paymentRowSelected = nil
        //        keyboard = nil
        //        STC_VC = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        payment_methodVC = payment_method()
        payment_methodVC?.showCashMethodOnly = self.showCashMethodOnly
        NotificationCenter.default.addObserver(self, selector: #selector(DiableKeyboard), name: DisableKeyboardNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EnableKeyboard), name: EnableKeyboardNotification, object: nil)
        //initalIngenicoDevice()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isLoaded == false
        {
            isLoaded = true
            
            loadData()
            
        }
        showAndHideKeyboard()
    }
    private func showAndHideKeyboard() {
        keyboardPaymentView.delegate = self
        if Bundle.main.bundleIdentifier == "com.dgtera.pos.pro" {
            keyboardPaymentView.isHidden = false
            oldKeyboardStackview.isHidden = true
        } else {
            keyboardPaymentView.isHidden = true
            oldKeyboardStackview.isHidden = false
        }
    }
    func rePrint()
    {
        
    }
    
    func goHome()
    {
        if let parent_vc = parent_vc as? create_order{
            parent_vc.newBannerHolderview.labelDiscount.text = "Discount".arabic("خصم")
            parent_vc.newBannerHolderview.labelPromotionCode.text = ""
            parent_vc.newBannerHolderview.iconPromotion.isHighlighted = false
            parent_vc.remove_payment()
        }else{
            self.dismiss(animated: true,completion: completePayment)
        }
    }
    
    func loadData()
    {
        
        
        viewKeyboard.isHidden = true
        
        
//        initPaymentRows()
        initPayment()
        
        validatePayment()
    }
    
    func btnpay(enable:Bool)
    {
        if  enable {
            btnPay.isEnabled = true
            btnPay.setBackgroundColor_base(base: UIColor.init(hexString: "#6ACA7F"))
        }
        else{
            btnPay.isEnabled = false
            btnPay.setBackgroundColor_base(base: UIColor.init(hexString: "#D6D6D6"))
        }
    }
    
    
    
  
    
    func checkPayment() -> Bool
    {
        if  completeList == nil && orderVc!.order.pos_order_lines.count == 0
        {
            return false
        }
        
        
        // check is paid before
        if let orderId =  orderVc!.order.id, let account = pos_order_account_journal_class.get(order_id:orderId)
        {
            goHome()
            return false
        }
        if completeList == nil && orderVc!.order.amount_paid.rounded_app() < 0
        {
            return true
        }
        
     
        let amount_paid = orderVc!.order.amount_paid.rounded_double(toPlaces: 2)
        let get_total =  orderVc!.order.amount_total.rounded_double(toPlaces: 2)
        let amount_return = orderVc!.order.amount_return.rounded_double(toPlaces: 2)
        
        if let completeList = self.completeList{
            if amount_paid > get_total{
                SharedManager.shared.initalBannerNotification(title: "", message: "Error,amount returned is greater than amount total".arabic("خطأ، المبلغ المرتجع أكبر من المبلغ الإجمالي"), success: false, icon_name: "icon_error")
                SharedManager.shared.banner?.dismissesOnTap = true
                SharedManager.shared.banner?.show(duration: 3.0)
                return false
            }
            
        }
        if amount_paid >= get_total + amount_return
        {
            return true
        }
        
        
        return false
    }
    
    
    func isStcPaymentExisr() -> Bool
    {
        for item in paymentRows!.list_items
        {
            if item.payment_type == "stc"
            {
                
                return true
            }
        }
        
        return false
    }
    func checkIngenicoDevice(_ amount_total: Double,id:String,name:String){
        IngenicoInteractor.shared.setTotalAmount("\((amount_total * 10).rounded_double(toPlaces: 2))")
        IngenicoInteractor.shared.setEcrWith(ecr_no: id, ecr_receipt_no: name)
//        IngenicoInteractor.shared.setOrderUid(self.orderVc!.order.uid!,for:self.orderVc!.order.id! )
        IngenicoInteractor.shared.checkConnection(with: "")
    }

    func showFailToastMessage(message:String,isSucess:Bool = false,image:String = "icon_error"){
        DispatchQueue.main.async {
        SharedManager.shared.initalBannerNotification(title: "Fail payment".arabic("فشل الدفع") ,
                                                      message: message,
                                                      success: isSucess, icon_name: image)
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
    }

    }
   
    func initalIngenicoDevice(){
        IngenicoInteractor.shared.updateIngenicoStatusClosure = { (stateIngenico,message,data) in
            switch stateIngenico {
            case .check:
                DispatchQueue.main.async {
                    loadingClass.hide(view: self.keyboard?.view ?? self.view)
                    if message?.count == 19 {
                        IngenicoInteractor.shared.sendECRRequest()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            IngenicoInteractor.shared.isTimoOutRequest()
                        }
                        return
                    }
                    let error = (message?.isEmpty ?? true) ? "fail connection with Ingenico Device ." : (message ?? "")
                    printer_message_class.show(error, vc: self)
                }
               
            case .error:
                DispatchQueue.main.async {
                    loadingClass.hide(view:   self.keyboard?.view ?? self.view)
//                    printer_message_class.show(message ?? "",vc: self)
                    self.showFailToastMessage(message:message ?? "")

                }
                

            case .receiveResponse:
                DispatchQueue.main.async {
                    
                    loadingClass.hide(view: self.keyboard?.view ?? self.view)
                    
                    self.doPayment()
                }
                return
            case .empty:
               SharedManager.shared.printLog("initalize IngenicoInteractor successfully")
                return
            case .loading:
                DispatchQueue.main.async {
                loadingClass.show(view: self.keyboard?.view ?? self.view)
                }
            case .update_status(message: let message):
                print(message)
            }
        }
       
    }
    
    func checkOrderTotal() -> Bool {
        guard let dbOrder = pos_order_class.get(order_id: self.orderVc?.order.id ?? 0) else { return false }
        if dbOrder.amount_total == orderVc?.order.amount_total {
            return true
        } else {
            if dbOrder.amount_total > orderVc?.order.amount_total ?? 0 {
                orderTotalAmoutStatus = "less".arabic("أقل")
            } else {
                orderTotalAmoutStatus = "greater".arabic("أكثر")
            }
            return false
        }
    }
    
    @IBAction func btnPayment(_ sender: Any) {
        
        if (self.orderVc?.order.orderType?.required_table) ?? false {
            if self.orderVc?.order.table_id == nil || self.orderVc?.order.table_id == 0{
                messages.showAlert("You must chose table before send order to kitchen".arabic("يجب أن تختار الطاولة قبل إرسال الطلب إلى المطبخ"))
                return
            }
        }
        /*
        if !checkOrderTotal() {
            messages.showAlert("Order total amount are \(orderTotalAmoutStatus) than the actual value please check your order again".arabic("إجمالي قيمة الطلب \(orderTotalAmoutStatus) من القيمة المفترض دفعها الرجاء مراجعة الطلب مره اخري"))
            orderTotalAmoutStatus = ""
            return
        }
        */
        if checkPayment()
        {
           // if (self.paymentRowSelected?.code ?? "") == "ING1" {

            if ((self.paymentRowSelected?.is_support_geidea ?? false)) && !showCashMethodOnly {
                if let amount_total = orderVc?.order.amount_total, amount_total > 0.0,
                   let id = orderVc?.order.id,
                   let nameOrder = orderVc?.order.name
                {
                    //self.checkGeideaDevice(amount_total,id:"\(id)",name:nameOrder)
                    self.show_waiting_geidea_popup()
                    return
                }
                
            }
            
            if isStcPaymentExisr() == true && !showCashMethodOnly
            {
                let pos = SharedManager.shared.posConfig()
                if pos.accountJournals_STC() != nil
                {
                    STC_choosePaymentType( sender: sender)
                }
                else
                {
                    printer_message_class.show("STC Payment not found in this POS.", vc: self)
                }
                
                return
            }
            
            if let completeList = self.completeList {
                self.dismiss(animated: true) {
                    completeList( self.getAccountJournalListReturnOrder() )
                }
            }else{
                
                doPayment()
            }
            
            
        }
        
        
    }
    
    func get_retrun_list_bankStatement() -> account_journal_class?
    {
        let pos = SharedManager.shared.posConfig()
        
        let bankStatment = pos.accountJournals_cash_default()
        
        if bankStatment == nil
        {
            printer_message_class.show("Can't retrun , no cash default found.", vc: self)
            return nil
        }
        
        
        //                 bankStatment!.tendered =  total.toIntString()
        bankStatment!.changes = 0
        
        
        return bankStatment
        
    }
    
    func checkIfAllAmountPaidForOrder() -> Bool{
        var amountAccounts:Double = 0.0
        self.paymentRows?.list_items.forEach({ poaj in
            amountAccounts += (poaj.due.rounded_double(toPlaces: 2) - poaj.rest.rounded_double(toPlaces: 2))
        })
        if  let totalAmount = orderVc?.order.amount_total.rounded_double(toPlaces: 2),
                totalAmount >= 0,
                amountAccounts.rounded_double(toPlaces: 2) >= totalAmount {
            return true
        }
        self.showFailToastMessage(message: "Order not complete paid, \nplease sure that total amount for order was paid by payment methods available".arabic("لم يكتمل دفع الطلب ،\n يُرجى التأكد من دفع المبلغ الإجمالي للطلب عن طريق طرق الدفع المتاحة"))
        return false

    }
    func checkBadeAnResetViewOrder(){
        if let parent_vc = parent_vc as? create_order{
            parent_vc.checkBadgeOrder()
           parent_vc.reset_view_order()
        }
    }
    func addLoyalty(for order:pos_order_class) -> pos_order_class{
       return  loyalty_check.apply_loyalty(order)
    }
    func saveToDB(for order:pos_order_class,sentToKitchen:Bool = false){
        SharedManager.shared.printLog("saveToDB === \(Date())")
        if sentToKitchen {
            order.save_and_send_to_kitchen(forceSend:true,with:.PAYIED_ORDER, for: [.KDS])
            order.sent_order_via_ip(with: .PAYIED_ORDER)           
            // order.sent_order_via_ip(with: .PAYIED_ORDER, for: [.SUB_CASHER,.NOTIFIER])
            if SharedManager.shared.appSetting().enable_cloud_qr_code {
                MWQueue.shared.mwCloudQRQueue.async {

                    let syncInteractor = AppDelegate.shared.sync
                    if let lastSession = syncInteractor.get_last_session_onServer(){
                        order.session_id_server = lastSession.server_session_id
                        let _ = syncInteractor.sendOrder_normal(order:order,is_start_sync: true )
                    }
                }
                QrCodeInteractor.shared.checkInternetConnection()
            }else{
                AppDelegate.shared.syncNow()
            }
        }else{
            order.save(write_info: false, re_calc: false)
        }
       
    }
    func copy(order:pos_order_class) -> pos_order_class{
        let option = ordersListOpetions()
        option.parent_product = true
        
         let order_copy = orderVc!.order.copyOrder(option: option)
        order_copy.list_account_journal.append(contentsOf: orderVc!.order.list_account_journal)
        return order_copy
    }
    func sentToMultiPeer(order:pos_order_class){
        
        return
        
        /*
        let peer = SharedManager.shared.multipeerSession()
        if peer != nil
        {
//            peer!.send(order_copy.toJson())
          let json =  peer!.message?.build(order: order)
            peer!.send(json)
        }
         */

    }
    func getAccountJournalListReturnOrder() -> [account_journal_class]{
        var account_journal_items: [account_journal_class] =  []
        paymentRows?.list_items.forEach({ accountJournal in
            var accountJournalReturn = accountJournal
            accountJournalReturn.changes = accountJournalReturn.changes * -1
            accountJournalReturn.due = accountJournalReturn.due * -1
            accountJournalReturn.tendered = ((accountJournalReturn.tendered.toDouble() ?? 0.0)  * -1).toIntString()

            account_journal_items.append(accountJournalReturn)
        })
        return account_journal_items
    }
    func addAccountJournal(for order:pos_order_class,with paymentItem: [account_journal_class] ){
        order.is_closed = true
        order.is_sync = false
        
        if  order.amount_total > 0
        {
            order.list_account_journal = paymentItem
        }
        else
        {
            let total =  orderVc!.order!.amount_total
            
            let accountCls = get_retrun_list_bankStatement()
            if accountCls != nil
            {
                accountCls?.tendered =  total.toIntString()
                accountCls?.due =  total

                order.list_account_journal = []
                order.list_account_journal.append(accountCls!)
            }
        }
    }
    func sentToPosPrinters(_ order:pos_order_class,order_insurance:pos_order_class?){
        let option = ordersListOpetions()
        option.parent_product = true
        var orgin_order = orderVc!.order
         var order_copy = orgin_order!.copyOrder(option: option)
        if let orderOrginID = orgin_order?.id {
            pos_order_helper_class.increment_print_count(order_id: orderOrginID)
            order_copy.id = orderOrginID
        }
        if order_insurance != nil {
            orgin_order = order
            order_copy = order.copyOrder(option: option)
        }
        order_copy.list_account_journal.append(contentsOf: orgin_order!.list_account_journal)
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            if let insurance_order = order_insurance {
                insurance_order.creatInsuranceQueuePrinter()
            }
            order_copy.printOrderByMWqueue()
            MWRunQueuePrinter.shared.startMWQueue()
        }else{
        SharedManager.shared.printOrder(order_copy,order_insurance)
        }
        self.showMessageSuccess(order: order_copy,list_sub:getListSubOrder(for:orderVc!.order))
        
        self.sentToMultiPeer(order:order_copy)

    }
    func sentToKDSPrinters(_ order:pos_order_class,order_insurance:pos_order_class?){
        let option = ordersListOpetions()
        option.parent_product = true
        var orgin_order = orderVc!.order
         var order_copy = orgin_order!.copyOrder(option: option)
        if let orderOrginID = orgin_order?.id {
            pos_order_helper_class.increment_print_count(order_id: orderOrginID)
            order_copy.id = orderOrginID
        }
        if order_insurance != nil {
            orgin_order = order
            order_copy = order.copyOrder(option: option)
        }
        order_copy.list_account_journal.append(contentsOf: orgin_order!.list_account_journal)
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            if let insurance_order = order_insurance {
                insurance_order.creatInsuranceQueuePrinter()
            }
            order_copy.creatKDSQueuePrinter(.kds)
            pos_order_helper_class.increment_print_count(order_id: order_copy.id!)

            MWRunQueuePrinter.shared.startMWQueue()
        }else{
        SharedManager.shared.printOrder(order_copy,order_insurance)
        }
        self.showMessageSuccess(order: order_copy,list_sub:getListSubOrder(for:orderVc!.order))
        
        self.sentToMultiPeer(order:order_copy)

    }
    
    func getListSubOrder(for order:pos_order_class) -> [pos_order_class] {
        var list_sub:[pos_order_class] = []
        
        if order.amount_total < 0.0
        {
            let option = ordersListOpetions()
            option.Closed = true
            option.orderID = order.parent_order_id
            option.parent_product = true

            
            list_sub = pos_order_helper_class.getOrders_status_sorted(options: option)
        }
        return list_sub
    }
    
    @objc func doPayment()
    {
        if !checkIfAllAmountPaidForOrder(){
            return
        }
        clearHome = true
        guard var order = orderVc!.order else {return}
        // account_journal_items contain account for insurance and order
        if let pick_up_user_id = self.pickup_user_id {
            order.pickup_user_id = pick_up_user_id
        }
        //MARK: - add Account Journal For Order
        let account_journal_items: [account_journal_class] = paymentRows?.list_items ?? []
        self.addAccountJournal(for: order,with : account_journal_items  )
        //MARK: - get insurance order
        InsuranceOrderBuilder.shared.setup(InsuranceOrderBuilder.Config(currentOrder:order,accountJournalList:account_journal_items))
        let order_insurance = InsuranceOrderBuilder.shared.getInsuranceAsNewOrder()
        //MARK: - update UI
        self.checkBadeAnResetViewOrder()
        //MARK: - Apply Loyalty Order
        order = addLoyalty(for: order)
        //MARK: - save  Order to Data base
        if order_insurance != nil && order.isAllLinesInsurance(){
            order.is_sync = true
        }
//        if !(orderVc?.order.reward_bonat_code ?? "").isEmpty{
//            BonatCodeInteractor.shared.redeemRewardBonat(order:orderVc?.order )
//        }
        self.saveToDB(for: order)
        //MARK: - order_copy For Print[POS,KDS]  Order to Data base
        if SharedManager.shared.appSetting().enable_cloud_qr_code {
            self.sentToKDSPrinters(order,order_insurance:order_insurance)
        }else{
            self.sentToPosPrinters(order,order_insurance:order_insurance)
        }
        //MARK: - save  Order to Data base
        self.saveToDB(for: orderVc!.order,sentToKitchen: true)
        
        self.goHome()
    }
    
    
    
    func STC_choosePaymentType(sender: Any)
    {
        
        //        let alert = UIAlertController(title: "STC", message: "STC Payment with ", preferredStyle: .actionSheet)
        //
        //
        //         alert.addAction(UIAlertAction(title: "Mobile Number", style: .default, handler: { (action) in
        //
        //            self.STC_enterPhoneNumber( sender: sender)
        //
        //         }))
        //
        //        alert.addAction(UIAlertAction(title: "QR Code", style: .default, handler: { (action) in
        
        let pos = SharedManager.shared.posConfig()
        let qr = STC_QRBuilder()
        
        let ref = self.orderVc!.order.uid!.replacingOccurrences(of: "-", with: "")
        let Bill_Number = String( self.orderVc!.order.id!)

        qr.Bill_Number = Bill_Number //self.orderVc!.order.name!
        qr.Transaction_Amount = self.orderVc!.order.amount_paid.toIntString()
        
        qr.merchant_Identifier = "dgtera.com"
        qr.Acquirer_ID = "STCPAY"
        qr.Merchant_ID =  pos.accountJournals_STC()!.stc_account_code
        qr.Merchant_teller_ID = "Riyadh"
        qr.Merchant_Name = "dgtera"
        qr.Merchant_City = "Riyadh"
        
        qr.Reference_Label = ref
        qr.Store_Label = "dsds"
        qr.Terminal_Labe = "12345"
        
        let image =  qr.bulid()
        
        self.STC_VC = STCViewController()
        self.STC_VC!.modalPresentationStyle = .fullScreen
        
        self.STC_VC?.delegate = self
        self.STC_VC!.amount =  self.orderVc!.order.amount_paid
        self.STC_VC!.RefNum = ref //self.orderVc!.order.name!
        self.STC_VC?.order_id =  self.orderVc!.order.id ?? 0
        self.STC_VC!.BillNumber = Bill_Number//String(  self.orderVc!.order.id ?? 0)
        self.STC_VC?.useQRCode = true
        self.STC_VC?.imageQRCode = image
        
         parent_vc?.present( self.STC_VC!, animated: true, completion: nil)
        
        //           }))
        //
        //
        //               alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
        //                alert.dismiss(animated: true, completion: nil)
        //               }))
        //
        //
        //
        //        alert.popoverPresentationController?.permittedArrowDirections = .down //UIPopoverArrowDirection(rawValue: 0)
        //        alert.popoverPresentationController?.sourceView = sender as? UIView
        //        alert.popoverPresentationController?.sourceRect =  (sender as AnyObject).bounds
        //
        //               self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    func STC_enterPhoneNumber(sender: Any)
    {
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        keyboard = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew
        keyboard!.modalPresentationStyle = .popover
        //        invoices_List.delegate = self
        keyboard!.preferredContentSize = CGSize(width: 400, height: 715)
        keyboard!.delegate = self
        keyboard!.title_vc = "Enter mobile number."
        keyboard!.key = "mobile"
        keyboard!.mobile_mode = true
        keyboard!.initValue = "+966"
        
        let popover = keyboard!.popoverPresentationController!
        //        popover.delegate = self
        popover.permittedArrowDirections = .down //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        parent_vc?.present(keyboard!, animated: true, completion: nil)
    }
    
    func newBalance(key:String,value:String)
    {
        if !value.isEmpty
        {
            STC_VC = STCViewController()
            STC_VC?.delegate = self
            STC_VC!.amount = orderVc!.order.amount_paid
            STC_VC!.MobileNo = value
            STC_VC!.RefNum = orderVc!.order.name!
            STC_VC!.BillNumber = String( orderVc!.order.id ?? 0)
             parent_vc?.present(STC_VC!, animated: true, completion: nil)
            
        }
        
    }
    
    func STC_RequestStatus(status:STC_PaymentStatus)
    {
        if status == .Paid
        {
            //            STC_VC?.dismiss(animated: true, completion: nil)
            self.perform(#selector(doPayment), with: nil, afterDelay: 0.5)
            //            doPayment()
        }
        else
        {
            
        }
    }
    
  
   
 
    func showMessageSuccess(order:pos_order_class,list_sub:[pos_order_class])
    {
        let sucessmsg:paymentSuccessfullMessage
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        // paymentSuccessfullMessage_invoice
        sucessmsg = storyboard.instantiateViewController(withIdentifier: "paymentSuccessfullMessage") as! paymentSuccessfullMessage
        sucessmsg.modalPresentationStyle = .overFullScreen
        sucessmsg.delegate = self
        
        
        
//        let order_print = orderPrintClass(withOrder: orderVc!.order,subOrder: list_sub)
//        let html = order_print.printOrder_html()
        
        sucessmsg.total = String    (format: "%@",  orderVc!.order.amount_return.toIntString())
//        sucessmsg.html = html
        sucessmsg.order = order
        
        
        parent_vc?.present(sucessmsg, animated: true, completion: nil)
        
        if !SharedManager.shared.appSetting().enable_support_multi_printer_brands{
//        if self.orderVc!.order!.amount_total > 0.0
//        {
            let ord = sucessmsg.otherPrinter?.prepear_order(order: orderVc!.order,reReadOrder: true)

            sucessmsg.otherPrinter?.printToAvaliblePrinters(Order: ord)
//        }
        }
    }
  
    
   
    func get_customer_loyalty( )
    {
        if !SharedManager.shared.posConfig().enable_pos_loyalty {
            self.initPayment(partner: nil)
            return
        }
        let partner_id = self.orderVc!.order.partner_id!
        let parent_id = self.orderVc!.order.customer?.parent_id ?? 0

        var customer:res_partner_class?
        
        self.con_sync.userCash = .stopCash
        
        
        loadingClass.show()
        self.con_sync.get_customer_by_id(id: partner_id) { (results) in
            let response = results.response
            
            let  result  = response!["result"] as? [[String:Any]]
            
            loadingClass.hide()
            if result != nil
            {
                if result!.count > 0
                {
                    let temp = result![0]
                    customer = res_partner_class(fromDictionary: temp)
                    let get_local = res_partner_class.get(partner_id: customer?.id)
                    if get_local != nil
                    {
                        customer?.row_id = get_local!.row_id
                        customer?.row_parent_id = get_local!.row_parent_id
                        customer?.parent_name = get_local!.parent_name
                        customer?.parent_id = parent_id

                    }
                    
                    customer!.save()
                    
                    
                    self.orderVc!.order.loyalty_points_remaining_partner = customer!.loyalty_points_remaining
                    self.orderVc!.order.loyalty_amount_remaining_partner = customer!.loyalty_amount_remaining
                    
                    self.initPayment(partner: customer)
                }
                else
                {
                    self.initPayment(partner: nil)
                }
                
            }
            else
            {
                self.initPayment(partner: nil)
            }
            
            
        }
        
        
        
        
    }
    
    func initPayment()
    {
        if (self.orderVc!.order.partner_id ?? 0) != 0
        {
        get_customer_loyalty()
        }
        else
        {
            self.initPayment(partner: nil)
        }
    }
    
    func initPayment(partner:res_partner_class?)
    {
        let orderType = orderVc!.order.orderType
        
        var remove_redeem = false
        
        if self.orderVc?.order.partner_id == 0
        {

            remove_redeem = true
        }
        else
        {
 
            if partner == nil
            {
                remove_redeem = true
            }
            else
            {
//                let multiCash = SharedManager.shared.appSetting().enable_multi_cash
                var multiCash = paymentRows!.list_items.filter({($0.tendered.toDouble() ?? 0.0) > 0.0}).count > 0

                if partner!.loyalty_amount_remaining == 0
                {
                    remove_redeem = true
                }
                else if partner!.loyalty_amount_remaining < (self.orderVc?.order.amount_total)! && multiCash == false
               {
                    //MARK: - as client request
                   remove_redeem = false
               }
                
            }
             
        }
        var journal_ids:[Int] = []
        if self.orderVc?.order.order_integration == .DELIVERY {
            if let force_journal_id = self.orderVc?.order.pos_order_integration?.force_payment_journal_id {
                journal_ids = [force_journal_id]
            }
        }else{
            journal_ids = orderType?.journal_ids  ?? []
        }
        if remove_redeem == true
        {
            let loyalty  = account_journal_class.get_loyalty_default()
            if loyalty != nil
            {
                journal_ids.removeAll (where: {$0 == loyalty!.id})
            }
        }
        
        
        
        let storyboard = UIStoryboard(name: "payment", bundle: nil)
        payment_methodVC = storyboard.instantiateViewController(withIdentifier: "payment_method") as? payment_method
        payment_methodVC!.filterby_journal_ids = journal_ids
        payment_methodVC!.loyalty_amount_remaining = partner?.loyalty_amount_remaining ?? 0

        payment_methodVC!.delegate = self
        payment_methodVC!.view.frame = view_payment.bounds
        payment_methodVC!.orderType = orderType
        payment_methodVC!.showCashMethodOnly = self.showCashMethodOnly
        view_payment.addSubview(payment_methodVC!.view)
        
               payment_methodVC!.getPaymentMethod()

        initPaymentRows()
    }
    
    func initPaymentRows()
    {
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        paymentRows = storyboard.instantiateViewController(withIdentifier: "paymentRowsVc") as? paymentRowsVc
        paymentRows!.delegate = self
        
        paymentRows!.loyalty_amount_remaining = payment_methodVC!.loyalty_amount_remaining

        paymentRows!.total = orderVc!.order.amount_total
        
        paymentRows!.view.frame = view_paymentRows.bounds
        
        view_paymentRows.addSubview(paymentRows!.view)
    }
    
    func reset_zeroTendered_paymentRows(_ selectPayment:account_journal_class){
//        if paymentRows?.list_items.count == 1 {
//            if let selectedPaymentID = paymentRows?.list_items.first?.id, selectedPaymentID == selectPayment.id {
//                return
//            }
//        }
        paymentRows?.list_items.removeAll(where: {($0.tendered.toDouble() ?? 0.0) <= 0.0 && ($0.id != selectPayment.id) })
        paymentRows?.reload()
    }
    func completeDueForLastSelectPayment(){
        let i = (paymentRows?.list_items.count ?? 1) - 1
        let item = paymentRows!.list_items[i]
        item.tendered = item.due.rounded_formated_str()
        paymentRows!.list_items[i] = item
        paymentRows!.reload()
        let indexPath = IndexPath.init(row: i, section: 0)
        guard indexPath.row <   paymentRows!.tableview.numberOfRows(inSection: indexPath.section) else {return}
        paymentRows!.tableview.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
    }
    func payment_selected(payment:account_journal_class)
    {
        /**
         reset_zeroTendered_paymentRows
         [BUG] : - in case multi-cash
         if select bank then select cash invoice print bank so we need to remove payment with value less or equal zero
         */
        self.reset_zeroTendered_paymentRows(payment)
        if payment.payment_type == "loyalty" {
            if paymentRows!.list_items.count > 0 {
                let loyaltyPayments = paymentRows!.list_items.filter({$0.payment_type == "loyalty"})
                if loyaltyPayments.count > 0 {
                    let totalTenderedLoyalty = loyaltyPayments.compactMap({Double($0.tendered)}).reduce(0, +)
                    if (payment_methodVC?.loyalty_amount_remaining ?? 0.0) == totalTenderedLoyalty{
                        return
                    }
                    
                }
            }
        }

        if paymentRows!.list_items.count == 1 {
            if (orderVc?.order.containeInsuranceLines()) ?? false{
            if (paymentRows!.list_items.first?.id ?? 0) != payment.id {
                showFailToastMessage(message: "You Must choose only one payment method as order contains insurance products".arabic("يجب اختيار طريقة دفع واحدة فقط لأن الطلب يحتوي على منتجات تأمين"))
                payment_methodVC?.item_selected = nil

                if let ajSelected = paymentRows?.list_items.first{
                    payment_methodVC?.item_selected = ajSelected
                }
                payment_methodVC?.collectionView.reloadData()
                return
                                     
            }else{
                self.completeDueForLastSelectPayment()
                return
            }
            }
        }
        var isComingMultiCash = paymentRows!.list_items.filter({($0.tendered.toDouble() ?? 0.0) > 0.0}).count > 0
//        let multiCash = SharedManager.shared.appSetting().enable_multi_cash
        
//        if isComingMultiCash == false
//        {
            
            
            if paymentRows!.list_items.count > 0
            {
                
//                for i in 0...paymentRows!.list_items.count - 1
//                {
                let i = (paymentRows?.list_items.count ?? 1) - 1

                    let item = paymentRows!.list_items[i]

                    if item.id == payment.id && (item.tendered.toDouble() ?? 0) <= 0
                    {
                       
                        item.tendered = item.due.rounded_formated_str(maximumFractionDigits: 3)
                        paymentRows!.list_items[i] = item
                        paymentRows!.reload()
                        let indexPath = IndexPath.init(row: i, section: 0)
                        guard indexPath.row <   paymentRows!.tableview.numberOfRows(inSection: indexPath.section) else {return}
                        paymentRows!.tableview.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                        
                        return
                    }
               // }
                
            }
//        }
//        else
//        {
//            let lastRow = paymentRows!.list_items.last
//            if lastRow?.tendered.toDouble() == 0
//            {
//                return
//            }
//        }
        
        
        viewKeyboard.isHidden = false
        
        
        payment.rowIndex = paymentRows!.list_items.count
        
         
        paymentRows!.loyalty_amount_remaining =  payment_methodVC!.loyalty_amount_remaining //-  payment_methodVC!.loyalty_amount_remaining_used
        paymentRowSelected = payment
        paymentRows!.list_items.append(payment)
        paymentRows!.reload()
        
        // select last row
        let count = paymentRows!.list_items.count
        if count > 0
        {
            let indexPath = IndexPath.init(row:  count - 1, section: 0)
            guard indexPath.row <   paymentRows!.tableview.numberOfRows(inSection: indexPath.section)  else {return}
            paymentRows!.tableview.selectRow(at: IndexPath.init(row: count - 1 , section: 0), animated: true, scrollPosition: .bottom)
            
        }
        
    }
    func completeAmountPayment(){
        
    }
    
    func updateLoyalty( )
    {
     

 
        payment_methodVC?.loyalty_amount_remaining_used = paymentRows?.loyaltyAmount() ?? 0
//        paymentRows!.loyalty_amount_remaining =  payment_methodVC!.loyalty_amount_remaining -  payment_methodVC!.loyalty_amount_remaining_used

        payment_methodVC?.reload()
    }

    
    func paymentRowSelected(rowStatment:account_journal_class)
    {
        paymentRowSelected = rowStatment
    }
    
    func paymentRowDeleted(rowStatment:account_journal_class)
    {
        if paymentRows!.list_items.count == 0
        {
            viewKeyboard.isHidden = true
            
            payment_methodVC?.item_selected = nil
            payment_methodVC?.collectionView.reloadData()
            
        }
        
        if rowStatment.payment_type == "loyalty"
        {
            updateLoyalty()
         }
  
        
    }
    
    
    func payment_status(amount_paid:Double , amount_return:Double)
    {
        orderVc!.order.amount_paid = amount_paid
        orderVc!.order.amount_return = amount_return * -1
        
        validatePayment()
    }
    
 
   @IBAction func btn_back(_ sender: Any)
    {
        if let parent_vc = parent_vc as? create_order {
            parent_vc.remove_payment()
        }else{
            self.dismiss(animated: true,completion: {
                self.completeList?(nil)
            })
            
        }
    }
    
}
extension paymentVc: KeyboardPaymentDelegate {
    func keyboardAction(sender: Any) {
        if ( BankPayment == false ) {
            let btn :UIButton = sender as! UIButton
            handlePrice(newQty: btn.tag)
        }
    }
}





// keyboard
extension keyboard_vc
{
    enum numbers : Int {
        case zero = 0, one , two, three, four, five, six, seven,eight,nine,dot,backscpace,clear,addTen,addTwoenty,addFiftty
    }
    
    
    
    func handlePrice(newQty:Int)
    {
        
        if paymentRowSelected  == nil {
            return
        }
        
        var tendered:String =   paymentRowSelected!.tendered
        // MARK: - Validation for count char
        if (Double(tendered) ?? 0 ) >= 99999{
            if ( tendered.count == 6 && ( newQty != 11 && newQty != 12)) || (newQty > 12 && tendered.count == 5){
                return
            }
        }
        
        switch newQty {
        case numbers.zero.rawValue...numbers.nine.rawValue:
            
            
            if tendered == "0"
            {
                tendered = ""
            }
            
            
            if tendered.contains(".")
            {
                let sp = tendered.components(separatedBy: ".")
                let seq = sp[1]
                if seq.count == 2
                {
                    tendered.removeLast()
                }
            }
            
            tendered = String(format:"%@%d", tendered , newQty )
            
            
        case numbers.dot.rawValue:
            
            let txt = tendered
            
            if !txt.contains(".")
            {
                tendered = String(format:"%@%@",  tendered , "." )
                
            }
            
            
        case numbers.backscpace.rawValue:
            
            var str :String! =  tendered
            if  str.count != 0
            {
                str = String(str.dropLast())
            }
            
            
            
            tendered = str
            
        case numbers.clear.rawValue:
            
            
            tendered = ""
            
            
        case numbers.addTen.rawValue:
            
            var add = tendered.toDouble() ?? 0
            add = add + 10
            
            if add.isInteger()
            {
                tendered = String(add.toInt())
            }
            else
            {
                tendered = String(format: "%.2f", add)
            }
            
        case numbers.addTwoenty.rawValue:
            
            var add = tendered.toDouble() ?? 0
            add = add + 50
            
            if add.isInteger()
            {
                tendered = String(add.toInt())
            }
            else
            {
                tendered = String(format: "%.2f", add)
                
            }
            
        case numbers.addFiftty.rawValue:
            
            var add = tendered.toDouble() ?? 0
            add = add + 100
            
            if add.isInteger()
            {
                tendered = String(add.toInt())
            }
            else
            {
                tendered = String(format: "%.2f", add)
            }
        default:
            SharedManager.shared.printLog(newQty)
        }
        
        //        let total = order.total_order
        //        let cash = paymentRowSelected.tendered.toDouble() ?? 0
        //        let changes = total - cash
        //
        //        order.amount_paid = cash
        //
        //        if changes < 0
        //        {
        //            order.amount_return = changes
        //            paymentRowSelected.changes = baseClass.currencyFormate(changes)
        //        }
        //        else
        //        {
        //
        //            order.amount_return = 0
        //            paymentRowSelected.changes = baseClass.currencyFormate(0)
        //
        //        }
        
        
        if paymentRows!.list_items.count > 0
        {
            paymentRowSelected!.tendered = tendered
            
            if paymentRowSelected!.rowIndex >  paymentRows!.list_items.count
            {
                let row = paymentRows!.list_items.count - 1
                paymentRowSelected! = paymentRows!.list_items[row]
                paymentRowSelected!.rowIndex = row
            }
            
            if (paymentRowSelected!.rowIndex >= 0 && paymentRows!.list_items.count > paymentRowSelected!.rowIndex) {
         
                paymentRows!.list_items[paymentRowSelected!.rowIndex] = paymentRowSelected!

            }
            
            paymentRows!.reload()
           if self.paymentRows!.tableview.numberOfRows(inSection: 0) > 1 {
               let indexPath = IndexPath.init(row: self.paymentRowSelected?.rowIndex ?? 0, section: 0)
               guard indexPath.row <   paymentRows!.tableview.numberOfRows(inSection: indexPath.section)  else {return}

                self.paymentRows!.tableview.selectRow(at: IndexPath.init(row: self.paymentRowSelected?.rowIndex ?? 0, section: 0), animated: true, scrollPosition: .bottom)
            }
            
           
        }
        else
        {
            
            viewKeyboard.isHidden = true
            payment_methodVC!.collectionView.reloadData()
        }
        
        
        validatePayment()
    }
    
    
    func validatePayment()
    {
        if checkPayment()
        {
            view_payment.isUserInteractionEnabled = false
            view_payment.alpha = 0.5
            btnpay(enable: true)
        }
        else
        {
            view_payment.isUserInteractionEnabled = true
            view_payment.alpha = 1
            
            btnpay(enable: false)
        }
    }
    
    @IBAction func btn_keyboardAction(_ sender: Any) {
          if ( BankPayment == false ) {
              let btn :UIButton = sender as! UIButton
              handlePrice(newQty: btn.tag)
          }
          
      }
      @objc func DiableKeyboard()
      {
          BankPayment = true
      }
      @objc func EnableKeyboard()
      {
          BankPayment = false
      }
    
    
}
