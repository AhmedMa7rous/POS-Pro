//
//  loginUsers.swift
//  pos
//
//  Created by khaled on 9/21/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class invoicesList: UIViewController {
    
    var delegate:invoicesList_delegate?
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblInvoices: KLabel!
    @IBOutlet weak var btnVoidAll: UIButton!
    @IBOutlet var seq: UISegmentedControl!
    @IBOutlet weak var filterBtn: UIButton!
    
    var refreshControl_tableview = UIRefreshControl()
    var enableEdit:Bool = true
    var option:ordersListOpetions! = ordersListOpetions()
    var list_items:[pos_order_class]! = []
    let con = SharedManager.shared.conAPI()
    var currentPage:Int = 0
    var last_cell_index:Int = 0
    
    var show_all_orders:Bool = false
    var hide_seq:Bool = false

    var otherPrinter:printersNetworkAvalibleClass = printersNetworkAvalibleClass()

    var selectDriver: pos_driver_class?
//    var timer_refresh: Timer?
    var isLoading : Bool = false
    var isEmbedded:Bool = false
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        timer_refresh?.invalidate()
//        timer_refresh = nil
        option = nil
        list_items = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblInvoices.text = ""
        update_seq_ui()
        btnVoidAll.isHidden = true
        
        seq.isHidden = hide_seq
        
        init_refresh()
        if !isEmbedded {
            getList()
        }
        if LanguageManager.currentLang() == .ar {
            seq.setTitle("طلباتى", forSegmentAt: 0)
            seq.setTitle("كل الطلبات", forSegmentAt: 1)
        }
//        timer_refresh = Timer.scheduledTimer(timeInterval:2, target: self, selector: #selector(timerRefresh), userInfo: nil, repeats: true)
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
        let isExistDeliverOrders = check_exist_delivery()
        DispatchQueue.main.async {
            self.filterBtn.isHidden = !isExistDeliverOrders
            if isExistDeliverOrders {
                self.insert_delivery_segment()
            }else{
                if self.seq.numberOfSegments > 2 {
                    self.remove_delivery_segment()
                }
            }
        }
        
    }
     func insert_delivery_segment() {
        seq.insertSegment(withTitle: "Delivery".arabic("توصيل"), at: seq.numberOfSegments, animated: true)
     }

      func remove_delivery_segment() {
        seq.removeSegment(at: seq.numberOfSegments-1, animated: true)
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
        let count_rows = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        return count_rows > 0
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func refreshOrder(sender:AnyObject?) {
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
        self.reloadTable()
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
            self.reloadTable()
        }
        
        list = pos_order_helper_class.getOrders_status_sorted(options: option,needProduct: false)

        
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
    func reloadTable(){
        DispatchQueue.main.async {
            self.tableview?.reloadData()
        }
    }
    
    func getListForSearch()
    {
        var list:[pos_order_class]
        
        option.orderDesc = true
        option.page = currentPage
        option.LIMIT = Int(page_count)
        option.parent_product = true

        if self.show_all_orders == false {
            option.write_pos_id = SharedManager.shared.posConfig().id
        }
        else
        {
            option.create_pos_id = nil
            option.write_pos_id = nil

        }
  
        if currentPage == 0
        {
            last_cell_index = 0
            get_count()
            self.list_items.removeAll()
        }
        
        list = pos_order_helper_class.getOrders_status_sorted_for_search(options: option)
//        lblInvoices.text = String(format: "Orders [ %d ]".arabic("[ %d ] طلبات"), list.count)
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
        
        self.list_items.append(contentsOf:list)
        self.reloadTable()
        self.refreshControl_tableview.endRefreshing()
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
//
//            self.printVoidOrder(order: order)

        }
        let temp = pos_order_class()
        
        self.delegate?.order_deleted(order_selected: temp)
        
        self.getList()
        self.update_seq_ui()
    }
    
    @IBAction func seq_changed(_ sender: Any) {
        filterBtn.isHidden = true
        self.selectDriver = nil
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
            if seq.selectedSegmentIndex == 2 {
//                timer_refresh?.invalidate()
                show_all_orders = false
                filterBtn.isHidden = false
            }else{
//                timer_refresh?.fire()
                show_all_orders = true
            }
            
            
        }
        
        
        self.list_items.removeAll()
        
        
        getList()
        
    }
    
}


extension invoicesList: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if seq.selectedSegmentIndex != 1{
            return enableEdit
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let Void = UITableViewRowAction(style: .destructive, title: "Void") { (action, indexPath) in
            // delete item at indexPath
            //voidـitem
//            guard  rules.check_access_rule(rule_key.voidـitem) else {
//                return
//            }
            
            let row = indexPath.row
            let order = self.list_items[row]
            let alert = UIAlertController(title: "Void".arabic("خصم"), message: "Are you sure to void ?".arabic("هل انت متأكد من الحذف؟"), preferredStyle: .alert)
            
            let action_void = UIAlertAction(title: "Void".arabic("حذف") , style: .default, handler: { (action) in
                order.reFetchPosLines()
                
//                let row = indexPath.row
//                let order = self.list_items[row]
                SharedManager.shared.premission_for_void_order(order: order, vc: self) { [weak self] in
                    DispatchQueue.main.async {
                        
                    
                guard let self = self else {return}
                        if order.checISSendToMultisession(){
                            if !MWMasterIP.shared.checkMasterStatus(){
                                return
                            }
                        }
                self.list_items.remove(at: row)
                
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.endUpdates()
                
     
                order.is_void = true
                order.voidAllLines()
                    if !order.checISSendToMultisession() {
                        //Save local
                        order.save(write_info: true)
                    }else{
                        // save local and sent to ms
                        order.voidAllLines(updated_session_status: .sending_update_to_server,kitchenStatus:.send)
                        order.save(write_info: true,updated_session_status: .sending_update_to_server)
                        self.printVoidOrder(order: order)
                    }
//                order.save(write_info: true,updated_session_status: .sending_update_to_server)
//
//                pos_order_line_class.void_all(order_id: order.id!)
//
//
//
//                self.printVoidOrder(order: order)

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
        dic.reFetchPosLines()
        self.dismiss(animated: true, completion: {
            self.delegate?.order_selected(order_selected: dic)
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! invoicesListTableViewCell
        
        let cls = list_items[indexPath.row]
        //        let cls = orderClass(fromDictionary: obj as! [String : Any])
        
        cell.object = cls
    
        cell.updateCell((self.show_all_orders == false && seq.selectedSegmentIndex != 0))
        //MARK:- Coloring pending order with blue
        if isEmbedded {
            if  cell.contentView.layer.borderWidth == 0 {
            if cls.is_closed && !cls.is_void &&  !cls.is_sync {
                    cell.contentView.layer.borderWidth = 1
                    cell.contentView.layer.borderColor = #colorLiteral(red: 0.09714175016, green: 0.5167663693, blue: 1, alpha: 1).cgColor
            }else{
                cell.contentView.layer.borderWidth = 0
            }
            }
        }
        
        return cell
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

protocol invoicesList_delegate {
    func order_selected(order_selected:pos_order_class);
    func order_deleted(order_selected:pos_order_class);
    
}
