//
//  DriverLockOrdersVC.swift
//  pos
//
//  Created by M-Wageh on 16/01/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit
import WebKit

class DriverLockOrdersVC: UIViewController,menu_left_delegate {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var rightDetailsView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var lockBtn: KButton!
    @IBOutlet weak var printBtn: KButton!
    @IBOutlet weak var payBtn: KButton!
   
    @IBOutlet weak var seqment: UISegmentedControl!
    @IBOutlet weak var badgePrinterLbl: KLabel!

    @IBOutlet weak var orderTypeBtn: UIButton!
    var refreshControl_tableview = UIRefreshControl()

    var list_items:[pos_order_class]! = []
    var currentPage:Int = 0
    var last_cell_index:Int = 0
    var isLoading : Bool = false
    var option:ordersListOpetions! = ordersListOpetions()
    var orderSelected:pos_order_class?
    var html_temp = ""
    var order_print:orderPrintBuilderClass!
    var access_admin_driver_lock:Bool = false
    var selectOrderTypeList:[delivery_type_class] = []
    enum STATUS_SEGMENT_TABS{
        case ADMIN,PENDING,LOCK,PAIED
        
        static func getStatus(for index:Int,accessAdmin:Bool) ->STATUS_SEGMENT_TABS? {
            if accessAdmin {
                if index == 0 {return STATUS_SEGMENT_TABS.ADMIN}
                else if index == 1 {return STATUS_SEGMENT_TABS.PENDING}
                else if index == 2 {return STATUS_SEGMENT_TABS.LOCK}
                else if index == 3 {return STATUS_SEGMENT_TABS.PAIED}
            }else{
                if index == 0 {return STATUS_SEGMENT_TABS.PENDING}
                else if index == 1 {return STATUS_SEGMENT_TABS.LOCK}
                else if index == 2 {return STATUS_SEGMENT_TABS.PAIED}
            }
        return nil
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        insertـadmin_segment()
        self.rightDetailsView.isHidden = true
        setupTable()
        setOrderTypeDefault()
        init_refresh()
        getList()
        seqment.ensureiOS12Style()
        init_notificationCenter()
       
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkErrorPrinter()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        remove_notificationCenter()
    }
    func setOrderTypeDefault(){
        if let defaultOrderTypeID = SharedManager.shared.posConfig().delivery_method_id{
            if let orderTypeDefault = delivery_type_class.get(id: defaultOrderTypeID ){
                selectOrderTypeList.append(orderTypeDefault)
            }
        }
        self.changeOrderBtnTitle()
    }
    func insertـadmin_segment() {
        let casher = SharedManager.shared.activeUser()
        self.access_admin_driver_lock  = rules.access_rule(user_id:casher.id,key:rule_key.admin_driver_lock)
        if self.access_admin_driver_lock{
        seqment.insertSegment(withTitle: "Admin".arabic("ادمن"), at: 0, animated: true)
            seqment.selectedSegmentIndex = 0
            
        }
        if LanguageManager.currentLang() == .ar {
            if seqment.numberOfSegments == 4 {
                seqment.setTitle("ادمن", forSegmentAt: 0)
                seqment.setTitle("جارية", forSegmentAt: 1)
                seqment.setTitle("الملتقطه", forSegmentAt: 2)
                seqment.setTitle("مدفوعه", forSegmentAt: 3)
            }
            if seqment.numberOfSegments == 3 {
                seqment.setTitle("جارية", forSegmentAt: 0)
                seqment.setTitle("مقبولة", forSegmentAt: 1)
                seqment.setTitle("مدفوعه", forSegmentAt: 2)

            }
        }
    }
    
    func checkErrorPrinter(){
        if let count = printer_error_class.getCount(){
            self.badgePrinterLbl.isHidden = false

        self.badgePrinterLbl.text =  "\(count)"
        }else{
            self.badgePrinterLbl.isHidden = true
        }
    }
    func init_refresh()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        table.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    func init_notificationCenter()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_remove_order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("update_pos_multisession_status"), object: nil)
    }
    
    func remove_notificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_remove_order"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("update_pos_multisession_status"), object: nil)


        SharedManager.shared.reset_order_void_id()
        
    }
    @objc func poll_update_order(notification: Notification) {
        
        DispatchQueue.main.async {
            self.rightDetailsView.isHidden = true
            self.refersh()
        }
        
    }
    @objc func refreshOrder(sender:AnyObject?) {
        // Code to refresh table view
        self.rightDetailsView.isHidden = true
        refersh()
    }
    func refersh(){
        self.rightDetailsView.isHidden = true
        last_cell_index = 0
        currentPage = 0
        self.list_items.removeAll()
        self.table.reloadData()
        getList()
    }
    func changeOrderBtnTitle(){
        if selectOrderTypeList.count == 0 {
            self.orderTypeBtn.setTitle("All order type".arabic("جميع انواع الطلبات"), for: .normal)

        }else{
            if selectOrderTypeList.count <= 2 {
                let value = selectOrderTypeList.map(){$0.display_name}.joined(separator: ", ")
                self.orderTypeBtn.setTitle(value, for: .normal)
                
                
            }else{
                self.orderTypeBtn.setTitle("\(selectOrderTypeList.count) " + "Selected".arabic("محدد"), for: .normal)
                
            }
        }
    }
    func show_order_types_view(_ sender:UIView)
    {
        let vc = SelectOrderTypesVC.createModule(sender, selectDataList: self.selectOrderTypeList)
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { selectDataList in
            self.selectOrderTypeList.removeAll()
            self.selectOrderTypeList.append(contentsOf: selectDataList)
            self.changeOrderBtnTitle()
            self.rightDetailsView.isHidden = true
            self.refersh()
        }
    }
    
    @IBAction func tapOnOrderTypeBtn(_ sender: UIButton) {
        show_order_types_view(sender)
        
    }
    @IBAction func tapOnPrinterLogo(_ sender: Any) {
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
    
    @IBAction func tapOnSeqment(_ sender: UISegmentedControl) {
        refersh()
    }
    
    @IBAction func tapOnMenuBtn(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    
    @IBAction func tapOnPickup(_ sender: KButton) {
        if sender.tag == 2 {
            //void Order
            self.void_order()
        }else{
            self.orderSelected?.pickup_user_id = sender.tag == 0 ? SharedManager.shared.activeUser().id : 0
            self.handleUI()
            self.orderSelected?.save(write_info: true, write_date: true, updated_session_status: .sending_update_to_server)
            refersh()
            AppDelegate.shared.run_poll_send_local_updates(force: true)

        }
        
    }
    @IBAction func tapOnPrint(_ sender: KButton) {
        guard let order = self.orderSelected else {return}
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            order.creatCopyBillQueuePrinter(rowType.history, hideLogo: false)
            MWRunQueuePrinter.shared.startMWQueue()
        }else{
            DispatchQueue.global(qos: .background).async {
                runner_print_class.runPrinterReceipt_image(  html: self.getPosHTML(false), openDeawer: false,row_type: .history)
            }
        }
        let printer_status_vc = printer_status()
        printer_status_vc.modalPresentationStyle = .overCurrentContext
        self.present(printer_status_vc, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                self.checkErrorPrinter()
            })

        }
        
    }
    @IBAction func tapOnPay(_ sender: KButton) {
        openPayment()
        /*
        self.orderSelected?.is_closed = true
        self.orderSelected?.pickup_user_id = SharedManager.shared.activeUser().id
        self.handleUI()
        self.orderSelected?.save(write_info: true, write_date: true, updated_session_status: .sending_update_to_server)
        refersh()
        AppDelegate.shared.run_poll_send_local_updates(force: true)
         */
    }
    
    func openPayment()
    {

        let storyboard = UIStoryboard(name: "payment", bundle: nil)
        if let order = self.orderSelected, let paymentVC = storyboard.instantiateViewController(withIdentifier: "paymentVc") as? paymentVc{
            order.amount_paid = 0.0
            paymentVC.completePayment = {  
                self.orderSelected?.is_closed = true
                self.orderSelected?.pickup_user_id = SharedManager.shared.activeUser().id
                self.handleUI()
//                self.orderSelected?.save(write_info: true, write_date: true, updated_session_status: .sending_update_to_server)
                self.refersh()
//                AppDelegate.shared.run_poll_send_local_updates(force: true)

            }
            paymentVC.parent_vc = self
            paymentVC.clearHome = false
            paymentVC.orderVc!.order =  order
            paymentVC.pickup_user_id = SharedManager.shared.activeUser().id
            let activeSession = pos_session_class.getActiveSession()
            paymentVC.orderVc!.order.session_id_local = activeSession!.id
        
            paymentVC.viewDidLoad()
            paymentVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(paymentVC, animated: true)
        }
//      payment_Vc.view.frame = right_view.bounds
      
//      right_view.addSubview( self.payment_Vc.view)
//        blurView(view: left_view)
//          self.navigationController?.pushViewController(payment_Vc, animated: true)
    }
    
    func getList()
    {
        if isLoading {
            return
        }
        isLoading = true
        var list:[pos_order_class]
        setOption()
        
  
        if currentPage == 0
        {
            last_cell_index = 0
            get_count()
            self.list_items.removeAll()
            self.reloadTable()
        }
        
        list = pos_order_helper_class.getOrders_status_sorted(options: option)

        
        if list.count == 0
        {
            currentPage -= 1
            if currentPage  < 0
            {
                currentPage = 0
            }
        }
        
        var count = self.list_items.count - 1
        if count < 0
        {
            count = 0
        }
        if list.count > 0{
            self.list_items.append(contentsOf:list)
            self.reloadTable()
        }
        self.refreshControl_tableview.endRefreshing()
        isLoading = false
    }
    func setOption(){
        let selectIndex = self.seqment.selectedSegmentIndex
        let selectSegment = STATUS_SEGMENT_TABS.getStatus(for:selectIndex , accessAdmin:self.access_admin_driver_lock ) ?? .PENDING
        let userID = SharedManager.shared.activeUser().id

        option.orderDesc = true
        option.page = currentPage
        option.LIMIT = Int(page_count)
        option.parent_product = true
        option.is_delivery_order = nil
        option.driverID = nil
        option.create_pos_id = nil
        option.write_pos_id = nil
        option.void = false
        option.sesssion_id = pos_session_class.getActiveSession()?.id ?? 0
        option.has_pickup_users_ids = nil
        option.pickup_users_ids = nil
        if self.selectOrderTypeList.count > 0{
            option.deliveryTypesIDS = self.selectOrderTypeList.map({$0.id})
        }else{
            option.deliveryTypesIDS = nil
        }
        if selectSegment == .ADMIN {
            //Admin Orders
            option.has_pickup_users_ids = true
            option.has_write_pickup_users_ids = true

            option.Closed = false


        }
        
        if selectSegment == .PENDING {
           
            //Pending Orders
            option.Closed = false
            option.pickup_users_ids = [0]
            

        }
        if selectSegment == .LOCK {
            //Lock Orders
            option.pickup_users_ids = [userID]
            option.Closed = false
        }
        if selectSegment == .PAIED {
            //Paied Orders
            option.Closed = true
            if self.access_admin_driver_lock {
                option.has_pickup_users_ids = true
            }else{
            option.pickup_users_ids = [userID]
            }

        }
    }
    func reloadTable(){
        DispatchQueue.main.async {
            self.table?.reloadData()
        }
    }
    func get_count()
    {
        let count_rows = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        titleLbl.text = String(format: "Orders [ %d ]".arabic("[ %d ] طلبات"), count_rows)
    }
    static func  createModule() -> DriverLockOrdersVC{
        let vc = DriverLockOrdersVC()
//        vc.orderLines = orderLines
//        vc.modalPresentationStyle = .formSheet
//        vc.preferredContentSize = CGSize(width: 900, height: 700)
//
//        vc.modalPresentationStyle = .popover
      //        vc.preferredContentSize = CGSize(width: 683, height: 700)
      //        let popover = vc.popoverPresentationController!
      //        popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
      //        popover.sourceView = sender
      //        popover.sourceRect =  (sender as AnyObject).bounds
        return vc
    }
    func btnPriceList(_ sender: Any)
    {
        
    }
   
    func loadSeletedOrder()
    {
        
        guard let orderSelected = orderSelected else {return}
        let list_sub:[pos_order_class]  = [] //  get_sub_orders()
        orderSelected.sub_orders = list_sub
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            html_temp = orderSelected.getInvoiceHTML(.history, hideLogo: true)
        }else{
            
            
            order_print = orderPrintBuilderClass(withOrder: orderSelected,subOrder: list_sub)
            
            if AppDelegate.shared.load_kds == false
            {
                html_temp = getPosHTML()
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
        }
        webView.loadHTMLString(html_temp, baseURL: Bundle.main.bundleURL)
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
    func void_order()
    {
        let alert = UIAlertController(title: "Void".arabic("حذف"), message: "Are you sure to void ?".arabic("هل انت متأكد من الحذف؟"), preferredStyle: .alert)
        
        let action_void = UIAlertAction(title: "Void".arabic("حذف") , style: .default, handler: { (action) in
            guard let orderSelected = self.orderSelected else {return}
            SharedManager.shared.premission_for_void_order(order: orderSelected, vc: self) { [weak self] in
                DispatchQueue.main.async {

                guard let self = self else {return}

           orderSelected.is_void = true
//            var count_send_to_kitchen = 0
            var posOrderLines:[pos_order_line_class] = []

            orderSelected.getAllLines().forEach { line in
                let is_line_void_and_printed = (line.is_void ?? false) && (line.printed == .printed)
                 if !is_line_void_and_printed {
                     line.is_void = true
                     line.write_info = true
                     line.printed = .none
                 }

                if line.is_combo_line!
                {
                    if line.selected_products_in_combo.count > 0
                    {
                        for combo_line in line.selected_products_in_combo
                        {
                            // if line void and printed -> not set printed with none
                            let is_combo_line_void_and_printed = (combo_line.is_void ?? false) && (combo_line.printed == .printed)
                            if !is_combo_line_void_and_printed{
                            combo_line.is_void = true
                            combo_line.write_info = true
                            combo_line.printed = .none
                            }

                        }
                    }
                }

                 posOrderLines.append(line)
             }
               orderSelected.pos_order_lines.removeAll()
               orderSelected.pos_order_lines.append(contentsOf: posOrderLines)
               orderSelected.save(write_info: true,updated_session_status: .sending_update_to_server,kitchenStatus:.send)
                    AppDelegate.shared.run_poll_send_local_updates(force: true)
                    self.refersh()


            }
            }
        })
                     
        alert.addAction(action_void)

        alert.addAction(UIAlertAction(title: "Cancel".arabic("الغاء") , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
extension DriverLockOrdersVC:UITableViewDelegate,UITableViewDataSource{

    func setupTable(){
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.register(UINib(nibName: "DriverOrderCell", bundle: nil), forCellReuseIdentifier: "DriverOrderCell")
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
   
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! invoicesListTableViewCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverOrderCell", for: indexPath) as! DriverOrderCell
        // Configure the cell...
         let cls = list_items[indexPath.row]
         //        let cls = orderClass(fromDictionary: obj as! [String : Any])
         let tapGesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(handleTapTableCell(recognizer:)))
         cell.contentView.tag = indexPath.row
         cell.contentView.isUserInteractionEnabled = true
         cell.contentView.addGestureRecognizer(tapGesture)

         cell.object = cls
         cell.updateCell(false)
         //MARK:- Coloring pending order with blue
//         if isEmbedded {
//             if  cell.contentView.layer.borderWidth == 0 {
//             if cls.is_closed && !cls.is_void &&  !cls.is_sync {
//                     cell.contentView.layer.borderWidth = 1
//                     cell.contentView.layer.borderColor = #colorLiteral(red: 0.09714175016, green: 0.5167663693, blue: 1, alpha: 1).cgColor
//             }else{
//                 cell.contentView.layer.borderWidth = 0
//             }
//             }
//         }
         
         return cell
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100//UITableView.automaticDimension
    }
 
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if last_cell_index < indexPath.row
        {
            let lastItem = self.list_items.count - 1
            if lastItem >= page_count - 1
            {
                if indexPath.row == lastItem {
                    currentPage += 1
                    last_cell_index = indexPath.row
                    
                    self.getList()
                }
            }
        }
        
        
    }

    
}
extension DriverLockOrdersVC {
    func order_selected(order_selected:pos_order_class){
        orderSelected = order_selected
        handleUI()
        loadSeletedOrder()
        rightDetailsView.isHidden = false
    }
    @objc func handleTapTableCell(recognizer:UITapGestureRecognizer){
        if let index = recognizer.view?.tag {
        let dic = list_items[index]
        self.order_selected(order_selected:dic)
        }
    }
    func handleUI(){
        guard let order = self.orderSelected else {return}
        let userId = SharedManager.shared.activeUser().id
        let pickupUserId = (order.pickup_user_id ?? 0)
        let isPickup =  self.access_admin_driver_lock ? pickupUserId != 0 : pickupUserId == userId
        let isPaied = order.is_closed
        self.payBtn.isHidden = isPaied
        self.lockBtn.isHidden = isPaied
        if !self.lockBtn.isHidden{
            let selectIndex = self.seqment.selectedSegmentIndex
            let selectSegment = STATUS_SEGMENT_TABS.getStatus(for:selectIndex , accessAdmin:self.access_admin_driver_lock ) ?? .PENDING
            if  selectSegment == .ADMIN{
                let isNeedToVoid = order.pickup_write_user_id != 0 && order.pickup_user_id == 0
                handleLockBtn(isPickup:isPickup,isNeedToVoid:isNeedToVoid)
            }else{
                handleLockBtn(isPickup:isPickup,isNeedToVoid:false)

            }
        }
    }
    
    func handleLockBtn(isPickup:Bool,isNeedToVoid:Bool){
        self.lockBtn.backgroundColor = #colorLiteral(red: 0.846493125, green: 0.4242321551, blue: 0.1012048349, alpha: 1)

        if isPickup {
            self.lockBtn.setTitle("Unlock".arabic("ترك"), for: .normal)
            self.lockBtn.tag = 1
        }else{
            if isNeedToVoid{
                self.lockBtn.setTitle("Void".arabic("حذف"), for: .normal)
                self.lockBtn.tag = 2
                self.lockBtn.backgroundColor = #colorLiteral(red: 0.9304464459, green: 0.1336709261, blue: 0.2233623266, alpha: 1)
            }else{
                self.lockBtn.setTitle("Lock".arabic("التقاط"), for: .normal)
                self.lockBtn.tag = 0
            }
        }
    }
     
}
