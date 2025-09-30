//
//  scrap_list.swift
//  pos
//
//  Created by khaled on 10/15/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol scrap_list_delegate {
    func reloadOrders(line:pos_order_line_class?)
}
class scrap_list: UIViewController ,order_listVc_delegate{
   
    

    var delegate:scrap_list_delegate?
    
    var orderVc = order_listVc()
   let con = SharedManager.shared.conAPI()
    
        var list_items:  [Any]! = []
    
    @IBOutlet var view_orderList: UIView!
    @IBOutlet var tableview: UITableView!
    @IBOutlet var txt: UITextView!

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        list_items = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initViewOrderList()
        get_reason()
    }
    func get_reason()
    {
        
      let arr =  scrap_reason_class.getDefault()
        self.list_items.append(contentsOf: arr)
         self.tableview.reloadData()
        
//        con.get_scrap_reason { (results) in
//            if (!results.success)
//            {
//                return
//            }
//
//            let response = results.response
//
//            self.list_items.removeAll()
//            let arr = response?["result"] as? [[String:Any]] ?? []
//
//            self.list_items.append(contentsOf: arr)
//            self.tableview.reloadData()
//
//        }
    }
    func initViewOrderList()
    {
        let order = orderVc.order
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        orderVc = storyboard.instantiateViewController(withIdentifier: "order_listVc") as! order_listVc
        
        //        orderVc = order_listVc()
        orderVc.delegate = self
        orderVc.view.frame = view_orderList.bounds
        orderVc.order = order
        orderVc.disable_btnInput = true
        orderVc.enableEdit = false
        
        view_orderList.addSubview(orderVc.view ?? UIView())
        orderVc.reload_footer()
    }
    
    func add_note(product:product_product_class?)
    {
        
    }
    func reloadOrders(line:pos_order_line_class?)
    {
   
    }
    
    func clacTotal()   {
      
    }

    @IBAction func btnOk(_ sender: Any) {
        
       for product in orderVc.order.pos_order_lines
        {
                product.scrap_reason = txt.text
        }
        
        
        orderVc.order.order_sync_type =  .scrap
        if self.orderVc.order?.checISSendToMultisession() ?? false{
            orderVc.order.is_closed = true

            orderVc.order.save(write_info:true,updated_session_status:.sending_update_to_server)
            orderVc.order.sent_order_via_ip(with: .SCRAP_ORDER)

        }else{
            orderVc.order.is_closed = true
            orderVc.order.save(write_info:true)

        }
        
        AppDelegate.shared.syncNow()
        
        delegate?.reloadOrders(line: nil)
        
        let order_print = scrapPrintBuilderClass(withOrder: orderVc.order )
        let html = order_print.printOrder_html()
        
        DispatchQueue.global(qos: .background).async {
  
            runner_print_class.runPrinterReceipt_image(  html:  html , openDeawer: false,row_type: .scrap)
                    
           }
        
//        let order_helper = orderPrintClass(withOrder: orderVc?.order,subOrder: []).printOrder_Formate()
//
//        _ =  EposPrint.runPrinterReceipt(header: order_helper.header, items: order_helper.items, total: order_helper.total, footer: order_helper.footer, logoData: nil, openDeawer: false)
        
        
        
        self.dismiss(animated: true, completion: nil)
        
 
        
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func edit_combo(line: pos_order_line_class) {
        
    }
}


extension scrap_list: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let cls = list_items[indexPath.row] as? [String:Any]

        let name = cls!["name"]  as? String ?? ""

        txt.text = String(format: "%@" , name)
        
      
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! scrap_listCell
        
        let cls = list_items[indexPath.row] as? [String:Any]
        
        cell.lblTtile.text = cls!["name"]  as? String ?? ""
        
        //        let obj = bankStatementClass(fromDictionary: cls as! [String : Any])
//        cls.rowIndex = indexPath.row
//        cell.delegate = self
//        cell.object = cls
//        cell.updateCell()
        
        
        return cell
    }
    
   
    
}
