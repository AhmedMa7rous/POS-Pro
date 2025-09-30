//
//  loginUsers.swift
//  pos
//
//  Created by khaled on 9/21/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class menuList: UIViewController {
    
    var delegate:menuList_delegate?
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblInvoices: KLabel!
    @IBOutlet weak var btnVoidAll: UIButton!
    
    @IBOutlet var seq: UISegmentedControl!
    
    
    var refreshControl_tableview = UIRefreshControl()
 
    var option:ordersListOpetions! = ordersListOpetions()
    var list_items:[pos_order_class]! = []
    let con = SharedManager.shared.conAPI()
    var currentPage:Int = 0
    var last_cell_index:Int = 0
    
 

    var otherPrinter:printersNetworkAvalibleClass = printersNetworkAvalibleClass()

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotification()
        option = nil
        list_items = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initalizeNotification()
        init_refresh()
        getList()
        if LanguageManager.currentLang() == .ar {
            seq.setTitle("جارية", forSegmentAt: 0)
            seq.setTitle("مقبولة", forSegmentAt: 1)
            seq.setTitle("مرفوضة", forSegmentAt: 2)
            seq.setTitle("منتهية", forSegmentAt: 3)
            seq.setTitle("ألغيت", forSegmentAt: 4)


        }
        


    }
   private func initalizeNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector( reload_fetch_order(notification:)), name: Notification.Name("time_out_integration_order"), object: nil)


    }
    private func removeNotification(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name("time_out_integration_order"), object: nil)

    }
    @objc func reload_fetch_order(notification: Notification) {
        DispatchQueue.main.async {
            self.seq_changed(self.seq)
        }
    }
    
    
    func init_refresh()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        last_cell_index = 0
        self.list_items.removeAll()
        getList()
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
        var list:[pos_order_class]
        
        option.orderDesc = true
        option.page = currentPage
        option.LIMIT = Int(page_count)
        option.parent_product = true

//        if AppDelegate.shared.load_kds == false
//        {
//            if self.show_all_orders == false {
//                option.write_pos_id = SharedManager.shared.posConfig().id
//            }
//            else
//            {
//                option.create_pos_id = nil
//                option.write_pos_id = nil
//
//            }
//        }
        
  
        if currentPage == 0
        {
            last_cell_index = 0
            get_count()
            self.list_items.removeAll()
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
        
        self.list_items.append(contentsOf:list)
        self.tableview?.reloadData()
        self.refreshControl_tableview.endRefreshing()
    }
    
    func getListForSearch()
    {
        var list:[pos_order_class]
        
        option.orderDesc = true
        option.page = currentPage
        option.LIMIT = Int(page_count)
        option.parent_product = true

//        if self.show_all_orders == false {
//            option.write_pos_id = SharedManager.shared.posConfig().id
//        }
//        else
//        {
//            option.create_pos_id = nil
//            option.write_pos_id = nil
//
//        }
  
        if currentPage == 0
        {
            last_cell_index = 0
//            get_count()
            self.list_items.removeAll()
        }
        
        list = pos_order_helper_class.getOrders_status_sorted_for_search(options: option)
        lblInvoices.text = String(format: "Orders [ %d ]".arabic("[ %d ] طلبات"), list.count)
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
        self.tableview?.reloadData()
        self.refreshControl_tableview.endRefreshing()
    }
    
    @IBAction func btnVoidAll(_ sender: Any) {
        
        for order in list_items
        {

            order.is_void = true
            if !order.checISSendToMultisession() {
                //Save local
                order.voidAllLines()
                order.save(write_info: true)
            }else{
                // save local and sent to ms
                order.voidAllLines(updated_session_status: .sending_update_to_server,kitchenStatus:.send)
                order.save(write_info: true,updated_session_status: .sending_update_to_server,kitchenStatus:.send)
                self.printVoidOrder(order: order)
            }
//            order.save(write_info: true,updated_session_status: .sending_update_to_server,kitchenStatus:.send)
//            pos_order_line_class.void_all(order_id: order.id!)

//            self.printVoidOrder(order: order)

        }
        let temp = pos_order_class()
        
        self.delegate?.menu_order_deleted(order_selected: temp)
        
        self.getList()
    }
    
    @IBAction func seq_changed(_ sender: UISegmentedControl) {
       
        
        self.list_items.removeAll()
        
        option.void = nil
        option.Closed = nil
        option.Sync = nil
        if seq.selectedSegmentIndex == 0
        {
           option.order_menu_status = [.pendding]
        }
        else if seq.selectedSegmentIndex == 1 {
            option.order_menu_status = [.accepted]
            option.Sync = nil


        } else if seq.selectedSegmentIndex == 2  {
            option.order_menu_status = [.rejected]
            option.void = true
            option.Closed = true
            

        }else if seq.selectedSegmentIndex == 3{
            option.order_menu_status = [.time_out]
//            option.void = true
//            option.Closed = true
        }else if seq.selectedSegmentIndex == 4{
            option.order_menu_status = [.cancelled,.cancelling]
//            option.void = true
//            option.Closed = true
        }
        
        
        getList()
        
    }
    
    
    
}


extension menuList: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
     
    func printVoidOrder(order:pos_order_class)
    {
         
        if (order.pos_multi_session_write_date ?? "") != ""
        {
            order.save_and_send_to_kitchen(printAll: true, isDeleted: true,
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
        if seq.selectedSegmentIndex != 0 {
            return
        }
        
        let obj = list_items[indexPath.row]
        

        self.dismiss(animated: true) {
            self.delegate?.menu_order_selected(order_selected: obj)

         }
        
    
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell-collection
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! menuListTableViewCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell-collection", for: indexPath) as! invoicesListCollectionTableViewCell
        
        let cls = list_items[indexPath.row]
        //        let cls = orderClass(fromDictionary: obj as! [String : Any])
        
//        cell.object = cls
//        cell.updateCell()
        
        cell.object = cls
        cell.delegate = self
        cell.PindexPath = indexPath
    
        cell.updateMenuCell()
        cell.removeBtn.tag = indexPath.row
        cell.removeBtn.isHidden = true
//        cell.removeBtn.addTarget(self, action: #selector(removeOrder(_:)), for: .touchUpInside)
        
        
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
    
    
}

protocol menuList_delegate {
    func menu_order_selected(order_selected:pos_order_class);
    func menu_order_deleted(order_selected:pos_order_class);
    
}
extension menuList:invoicesListCollectionCell_delegate{
    func order_selected(order_selected: pos_order_class) {
        if seq.selectedSegmentIndex != 0 {
            return
        }


        self.dismiss(animated: true) {
            self.delegate?.menu_order_selected(order_selected: order_selected)

         }
    }
    
    
}
