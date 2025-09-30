//
//  loginUsers.swift
//  pos
//
//  Created by khaled on 9/21/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class invoicesListCollection: UIViewController, invoicesListCollectionCell_delegate,UISearchResultsUpdating {
    
    var delegate:invoicesListCollection_delegate?
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblInvoices: KLabel!
    @IBOutlet weak var btnVoidAll: UIButton!
    @IBOutlet var seq: UISegmentedControl!
    @IBOutlet weak var filterBtn: UIButton!
    var searchController = UISearchController()
    var refreshControl_tableview = UIRefreshControl()
    var enableEdit:Bool = true
    var option:ordersListOpetions! = ordersListOpetions()
    var list_items:[pos_order_class]! = []
    var all_list_items:[pos_order_class]! = []

    let con = SharedManager.shared.conAPI()
    var currentPage:Int = 0
    var last_cell_index:Int = 0
    
    var show_all_orders:Bool = false
    var hide_seq:Bool = false

    var otherPrinter:printersNetworkAvalibleClass = printersNetworkAvalibleClass()

    var selectDriver: pos_driver_class?
//    var timer_refresh: Timer?
    var isLoading:Bool = false
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        timer_refresh?.invalidate()
//        timer_refresh = nil
        option = nil
        list_items = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchController()
        if SharedManager.shared.appSetting().make_all_orders_defalut{
            if self.seq.numberOfSegments > 1 {
                self.seq.selectedSegmentIndex = 1
                self.show_all_orders = true

            }
        }
        update_seq_ui()
        btnVoidAll.isHidden = true
        
        seq.isHidden = hide_seq
        
        init_refresh()
        getList()
        if LanguageManager.currentLang() == .ar {
            seq.setTitle("طلباتى", forSegmentAt: 0)
            seq.setTitle("كل الطلبات", forSegmentAt: 1)
        }
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_remove_order"), object: nil)


//        timer_refresh = Timer.scheduledTimer(timeInterval:2, target: self, selector: #selector(timerRefresh), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_remove_order"), object: nil)

    }
    func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by (order number,order ref,phone,customer)...".arabic("البحث حسب (رقم الطلب، مرجع الطلب، الهاتف، العميل)...")

            // Wrap the search bar in a container view to add padding
        let searchBarContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: 60))
            searchController.searchBar.frame = searchBarContainer.bounds.insetBy(dx: 0, dy: 0)
            searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            searchBarContainer.addSubview(searchController.searchBar)
            
        tableview.tableHeaderView = searchBarContainer
            
            definesPresentationContext = true
        
            
        }
    // MARK: - Search Results Updating

        func updateSearchResults(for searchController: UISearchController) {
            let searchText = searchController.searchBar.text ?? ""
            list_items = searchText.isEmpty ? all_list_items : self.getListForSearch(wordSearch: searchText)
            
            self.tableview?.reloadData()
            self.refreshControl_tableview.endRefreshing()
            tableview.reloadData()
        }
    
    @objc func poll_update_order(notification: Notification) {
        
        DispatchQueue.main.async {
            self.list_items.removeAll()
            self.getList()
        }
    }
    
    func init_refresh()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    @objc func timerRefresh(){
        refreshOrder(sender: refreshControl_tableview)
    }
    func update_seq_ui(){
        let pos_in_multisession = ((SharedManager.shared.posConfig().multi_session_id  ?? 0) != 0) || SharedManager.shared.mwIPnetwork
        let isExistDeliverOrders = check_exist_delivery()
        DispatchQueue.main.async {
            self.filterBtn.isHidden = true
            if !pos_in_multisession{
                self.remove_all_order_segment()
            }
            if isExistDeliverOrders {
                self.insert_delivery_segment()
            }else{
                if self.seq.numberOfSegments > 1 {
                    self.remove_delivery_segment()
                }
            }
        }
        
    }
     func insert_delivery_segment() {
        seq.insertSegment(withTitle: "Delivery".arabic("توصيل"), at: seq.numberOfSegments, animated: true)
     }

      func remove_delivery_segment() {
        let titleSeq = "Delivery".arabic("توصيل")
        if seq.titleForSegment(at: seq.numberOfSegments-1 ) == titleSeq{
            seq.removeSegment(at: seq.numberOfSegments-1, animated: true)
        }
     }
    func remove_all_order_segment() {
        if seq.numberOfSegments > 1{
      seq.removeSegment(at:1, animated: true)
        }
   }
    func insert_all_order_segment() {
        let titleSeq = "All orders".arabic("كل الطلبات")
        seq.insertSegment(withTitle:titleSeq , at: 1 , animated: true)
    }
    func check_exist_delivery()->Bool{
        let option:ordersListOpetions! = ordersListOpetions()
        option.Closed = false
        option.void = false
        option.orderDesc = true
        option.page = currentPage
        option.LIMIT = Int(page_count)
        option.parent_product = true
        option.is_delivery_order = nil
        option.driverID = nil
        option.is_delivery_order = true
        option.get_lines_void_from_ui = true
        let count_rows = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        return count_rows > 0
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        self.selectDriver = nil
        last_cell_index = 0
        self.list_items.removeAll()
        getList()
    }
    
    @IBAction func tapOnFilterBtn(_ sender: UIButton) {
        let vc = DriverListRouter.createModule(sender, selectDriver: self.selectDriver)
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { driver in
            self.selectDriver = driver
            self.last_cell_index = 0
            self.list_items.removeAll()
            self.getList()
        }
    }
    
    func clear()
    {
        lblInvoices.text = String(format: "Orders [ %d ]".arabic("[ %d ] طلبات"), 0)
        
        self.list_items.removeAll()
        self.tableview?.reloadData()
        self.refreshControl_tableview.endRefreshing()
    }
    
    func get_count()
    {
        let count_rows = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        lblInvoices.text = String(format: "Orders [ %d ]".arabic("[ %d ] طلبات"), count_rows)
    }
    
    func getList()
    {
        if isLoading {
            return
        }
        isLoading = true
        var list:[pos_order_class]
        
        option.orderDesc = true
        option.page = currentPage
        option.LIMIT = Int(page_count)
        option.parent_product = true
        option.is_delivery_order = nil
        option.driverID = nil
//        option.get_lines_void = true
        option.pickup_users_ids = [0]
        option.get_lines_void_from_ui = true

        if AppDelegate  .shared.load_kds == false
        {
            if self.show_all_orders == false {
                if seq.selectedSegmentIndex == 0 {
                    option.write_pos_id = SharedManager.shared.posConfig().id
                }else{
                    option.is_delivery_order = true
                    if let driver = self.selectDriver {
                        option.driverID = driver.id
                    }

                }
            }
            else
            {
                option.create_pos_id = nil
                option.write_pos_id = nil

            }
        }
        
  
        if currentPage == 0
        {
            last_cell_index = 0
            get_count()
            self.list_items.removeAll()
            self.tableview?.reloadData()
        }
        
        list = pos_order_helper_class.getOrders_status_sorted(options: option,needProduct:false)
//sort sequence
        list = list.sorted { order1, order2 in
             let seq1 = order1.sequence_number
              let seq2 = order2.sequence_number
              return seq1 > seq2
          
        }
        
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
       
        if list.count > 0 {
            self.list_items.append(contentsOf:list)
            self.tableview?.reloadData()
        }
        all_list_items =  self.list_items

        self.refreshControl_tableview.endRefreshing()
        isLoading = false

    }
    
    func getListForSearch(wordSearch:String) -> [pos_order_class]
    {
        var list:[pos_order_class]
        
        option.orderDesc = true
        option.page = 0
        option.LIMIT = Int(page_count)
        option.parent_product = true
        option.is_delivery_order = nil
        option.driverID = nil
        option.pickup_users_ids = [0]
        option.get_lines_void_from_ui = true
        option.create_pos_id = nil
        option.write_pos_id = nil
       
        last_cell_index = 0
        self.list_items.removeAll()
        
        list = pos_order_helper_class.search(by:wordSearch, page: 0,options: option)
        lblInvoices.text = String(format: "Orders [ %d ]".arabic("[ %d ] طلبات"), list.count)
       
        
        return list
        
       
    }
    
    @IBAction func btnVoidAll(_ sender: Any) {
        
        for order in list_items
        {
            order.reFetchPosLines()
            order.is_void = true
            if !order.checISSendToMultisession() {
                //Save local
                order.voidAllLines()
                order.save(write_info: true)
            }else{
                // save local and sent to ms
                order.voidAllLines(updated_session_status: .sending_update_to_server,kitchenStatus:.send)
                order.save(write_info: true,updated_session_status: .sending_update_to_server)
                self.printVoidOrder(order: order)
            }
            
//            for void_product in order.pos_order_lines
//            {
//                 void_product.is_void = true
//
//                if void_product.is_combo_line!
//                {
//                    if void_product.selected_products_in_combo.count > 0
//                    {
//                        for combo_line in void_product.selected_products_in_combo
//                        {
//                            combo_line.is_void = true
//
//
//                        }
//                    }
//                }
//            }
            
        
           
//            order.save(write_info: true,updated_session_status: .sending_update_to_server)
//
//
//            pos_order_line_class.void_all(order_id: order.id!)

//            self.printVoidOrder(order: order)

        }
        let temp = pos_order_class()
        
        self.delegate?.order_deleted(order_selected: temp)
        self.list_items.removeAll()
        self.tableview.reloadData()
        self.getList()
        self.update_seq_ui()
    }
    
    @IBAction func seq_changed(_ sender: Any) {
        filterBtn.isHidden = true
        self.selectDriver = nil
        self.currentPage = 0
        self.list_items.removeAll()
        self.tableview.reloadData()
//        btnVoidAll.isHidden = (seq.selectedSegmentIndex == 1)
        if seq.selectedSegmentIndex == 0
        {
//            timer_refresh?.invalidate()
            show_all_orders = false
        }
        else
        {
            let titleSeqment = seq.titleForSegment(at: seq.selectedSegmentIndex ) ?? ""
            if (titleSeqment == "Delivery".arabic("توصيل")) {
//                timer_refresh?.invalidate()
                show_all_orders = false
                filterBtn.isHidden = false
            }else{
//                timer_refresh?.fire()
                show_all_orders = true
            }
            
            
        }
        
        
        self.list_items.removeAll()
        self.tableview.reloadData()
        self.tableview.setContentOffset(.zero, animated:false)
        
        getList()
        
    }
    
}


extension invoicesListCollection: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if seq.selectedSegmentIndex != 1{
            return enableEdit
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let Void = UITableViewRowAction(style: .destructive, title: "Void") { (action, indexPath) in
            // delete item at indexPath
            self.void_order(at:indexPath.row)
        }
        
        return [Void]
    }
    
    
    func printVoidOrder(order:pos_order_class)
    {
        
         
        if (order.pos_multi_session_write_date ?? "") != ""
        {
//            order.sendToKDS(isDeleted: true,printAll: true,reRead: false)
            order.save_and_send_to_kitchen(printAll: true, isDeleted: true,reRead: false,
                                           with: IP_MESSAGE_TYPES.VOID_ORDER,
                                           for: [DEVICES_TYPES_ENUM.KDS,.NOTIFIER])
            
            if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
                order.creatKDSQueuePrinter(.kds)
                MWRunQueuePrinter.shared.startMWQueue()
            }else{
            self.otherPrinter.printToAvaliblePrinters(Order: order)
            SharedManager.shared.epson_queue.run()
            }
             if !SharedManager.shared.appSetting().enable_force_longPolling_multisession {
            AppDelegate.shared.run_poll_send_local_updates()
            }

        }
        
    }
 
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let dic = list_items[indexPath.row]
        if canEdit(dic){
            dic.reFetchPosLines()
            dic.calcAll()
            self.delegate?.order_selected(order_selected: dic)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! invoicesListCollectionTableViewCell
        if indexPath.row > list_items.count {
            return UITableViewCell()
        }
        let cls = list_items[indexPath.row]
        //        let cls = orderClass(fromDictionary: obj as! [String : Any])
        
        cell.object = cls
        cell.delegate = self
        cell.PindexPath = indexPath
    
        cell.updateCell((self.show_all_orders == false && seq.selectedSegmentIndex != 0))
        cell.removeBtn.tag = indexPath.row
        cell.removeBtn.isHidden = seq.selectedSegmentIndex != 0
        cell.removeBtn.addTarget(self, action: #selector(removeOrder(_:)), for: .touchUpInside)
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if last_cell_index < indexPath.row
        {
            let lastItem = self.list_items.count - 1
            if lastItem >= page_count - 1
            {
                if indexPath.row == lastItem {
                   SharedManager.shared.printLog("IndexRow\(indexPath.row)")
                    currentPage += 1
                    last_cell_index = indexPath.row
                    
                    self.getList()
                }
            }
        }
        
        
    }
    func canEdit(_ order_selected:pos_order_class)->Bool{
        if (order_selected.table_id ?? 0) != 0{
            if SharedManager.shared.mwIPnetwork {
                if SharedManager.shared.appSetting().enable_make_user_resposiblity_for_order{
                    if !SharedManager.shared.posConfig().isMasterTCP(){
                        guard let ownerID = order_selected.get_control_by_user_id() ?? order_selected.create_user_id else { return true }
                        let currentUserID = SharedManager.shared.activeUser().id
                        if ownerID != currentUserID {
                            messages.showAlert( "Order can select only by master or create user".arabic("يمكن تحديد الطلب فقط بواسطة المستخدم الرئيسي أو المستخدم المُنشئ"),vc: self)
                            
                            return false
                            
                        }
                    }
                    
                }
            }
        }
        return true
    }
    
    func order_selected(order_selected:pos_order_class)
    {
        if canEdit(order_selected){
            delegate?.order_selected(order_selected: order_selected)
            
            self.dismiss(animated: true, completion: nil)
        }

    }
    @objc func removeOrder(_ sender:UIButton){
        let order = self.list_items[sender.tag]
        if !self.canEdit(order){
            return
        }
        self.void_order(at:sender.tag)
        
    }
    private func void_order(at row:Int){
        let alert = UIAlertController(title: "Void".arabic("حذف"), message: "Are you sure to void ?".arabic("هل انت متأكد من الحذف؟"), preferredStyle: .alert)
        let action_void = UIAlertAction(title: "Void".arabic("حذف") , style: .default, handler: { (action) in

        let order = self.list_items[row]
            if !self.canEdit(order){
                return
            }
            order.reFetchPosLines()

            SharedManager.shared.premission_for_void_order(order: order, vc: self) { [weak self] in
            DispatchQueue.main.async {

            guard let self = self else {return}
                if order.checISSendToMultisession(){
                    if !MWMasterIP.shared.checkMasterStatus(){
                        return
                    }
                }
        
        
        self.list_items.remove(at: row)
        
        
        self.tableview.beginUpdates()
        self.tableview.deleteRows(at: [IndexPath(row:row,section: 0)], with: .left)
        self.tableview.endUpdates()
        

        order.is_void = true
//                pos_order_line_class.void_all(order_id: order.id!)
                var posOrderLines:[pos_order_line_class] = []

        order.getAllLines().forEach { line in
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
//                if (line.pos_multi_session_status?.rawValue ?? 0 ) >= 2 {
//                    count_send_to_kitchen += 1
//                }
            posOrderLines.append(line)
        }
          order.pos_order_lines.removeAll()
           order.pos_order_lines.append(contentsOf: posOrderLines)
            if order.void_status == .before_sent_to_kitchen{
//            if !order.checISSendToMultisession() {
                //Save local
                order.save(write_info: true)
            }else{
                // save local and sent to ms
                order.save(write_info: true,updated_session_status: .sending_update_to_server,kitchenStatus:.send)
                if SharedManager.shared.appSetting().enable_force_longPolling_multisession {
                AppDelegate.shared.run_poll_send_local_updates()
                }
                self.printVoidOrder(order: order)
            }
//            order.save(write_info: true,updated_session_status: .sending_update_to_server)
        self.delegate?.order_deleted(order_selected: order)
        self.getList()
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

protocol invoicesListCollection_delegate {
    func order_selected(order_selected:pos_order_class);
    func order_deleted(order_selected:pos_order_class);
    
}
