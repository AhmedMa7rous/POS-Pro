//
//  return_orders.swift
//  pos
//
//  Created by Khaled on 4/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class accept_orders: baseViewController , UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var tableview: UITableView!
 
    var progressPopup:MWProgressView?

    var order:pos_order_class!
  
 
    var didSelect : ((pos_order_class) -> Void)?
    
    var parent_vc:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //           self.preferredContentSize = CGSize.init(width: 720, height: 700)
        
        blurView()
        
        
 
        tableview.reloadData()
    }
    
    
    
    
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //        if have_discount
        //        {
        //            tableView.reloadData()
        //            return
        //        }
        let itme =  order.pos_order_lines [indexPath.row]
        
        if (itme.tag_temp ?? "") == "returned"
        {
            return
        }
        
        
        
        if itme.tag_temp != nil
        {
            itme.tag_temp = nil
            
        }
        else
        {
            itme.tag_temp = "selected"
        }
        
        order.pos_order_lines[indexPath.row] = itme
        tableView.reloadData()
        
        
        
        //          didSelect?(itme)
        //           self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let line =  order.pos_order_lines[indexPath.row]
        let count = line.selected_products_in_combo.count
        if count > 0
        {
            var h = count * 30
            if !(line.note ?? "").isEmpty
            {
                h = h + 30
            }
            
            return CGFloat(h + 50)
        }
        
        if !(line.note ?? "").isEmpty
        {
            return 60;
        }
        
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  order.pos_order_lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"
        var cell: accept_ordersTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? accept_ordersTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "accept_ordersTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? accept_ordersTableViewCell
        }
        
        
        
        cell.parent = self
        cell.list_items =  order.pos_order_lines
        cell.index = indexPath.row
        cell.updateCell()
        
  
        
        return cell
    }
    
    private func stopProgressPopup() {
        DispatchQueue.main.async {
            
            self.progressPopup?.stopProgress()
            self.progressPopup = nil
        }
       }
    private func showProgressPopup() {
        DispatchQueue.main.async {
            self.progressPopup = MWProgressView()
            self.view.addSubview(self.progressPopup!)
            self.progressPopup?.startProgress()
        }
       }
    
    var isSartUpdate:Bool = false
    
    @IBAction func tapOnCancelBtn(_ sender: KButton) {
        DispatchQueue.main.async {
            self.stopProgressPopup()
            self.isSartUpdate = false
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func btnOk(_ sender: Any) {
        if isSartUpdate {
            return
        }
        
        if !NetworkConnection.isConnectedToNetwork()
        {
            WaringToast.shared.showWaringAlert(with: nil)

            return
        }
        
      //  if self.order.order_integration == .DELIVERY {
           // if let integrationOrder = self.order.pos_order_integration{
        var orderIntegration:pos_order_integration_class? =  self.order.order_integration == .DELIVERY ? self.order.pos_order_integration : nil
        var posOrder:pos_order_class? =  self.order.order_integration != .DELIVERY ? self.order : nil
        self.showProgressPopup()
//            loadingClass.show(view: self.view)
        isSartUpdate = true
        
            DeliveryOrderIntegrationInteractor.shared.updateStatus(integrateOrder:orderIntegration ,posOrder:posOrder  , with: .accepted, completion: { result in
                DispatchQueue.main.async {
                    self.stopProgressPopup()
                    self.isSartUpdate = false
                    if result ?? false{
                        if let orderIntegration = orderIntegration{
                            var isClosed = false
                            if orderIntegration.is_paid ?? false{
                              if !SharedManager.shared.appSetting().enable_stop_paied_intergrate_order{
                                orderIntegration.doPayment()
                                isClosed = true
                             }

                            }
                            self.doAcceptOrder(isClosed)
                        }else{
                            self.doAcceptOrder()
                        }
                       
                    }else{
                        self.dismiss(animated: true, completion: nil)

                    }
                }
            })
        
         //   }
//        }else{
//            doAcceptOrder()
//        }
    }
    func doAcceptOrder(_ isClosed:Bool = false){
        self.order.order_menu_status = .accepted
        self.order.pos_order_lines.forEach { line in
            line.write_date = baseClass.get_date_now_formate_datebase()
        }
        //MARK:- Save Order
        self.order.pos_multi_session_write_date = ""
        self.order.is_closed = isClosed
        self.order.save(write_info: true,  re_calc: false)
       
        //MARK:- Stop Sound
        if !SharedManager.shared.appSetting().enable_play_sound_while_auto_accept_order_menu {
            baseClass.stopSound()
        }
        //MARK:-  print send_accept_order
        if !isClosed {
            print_send_accept_order()
        }else{
            //MARK:- Send Order To Kitchen
            self.order.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
            order.save_and_send_to_kitchen(forceSend:true,with:.NEW_ORDER ,for:[.KDS,.NOTIFIER])
        }
        //MARK:- dissmiss PopUP
       self.dismiss(animated: true, completion: nil)
        self.didSelect?(  self.order)
    }
    
    func print_send_accept_order(){
        guard let orderID = order.id else {
            return
        }
        //MARK:- Print Order
        pos_order_helper_class.increment_print_count(order_id:orderID)
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
            self.order.creatKDSQueuePrinter(.kds)
            MWRunQueuePrinter.shared.startMWQueue()
        }else{
                let other_printers = printersNetworkAvalibleClass()
                let ord =  other_printers.prepear_order(order: order ,reReadOrder: true)
                other_printers.printToAvaliblePrinters(Order: ord)
        SharedManager.shared.epson_queue.run()
        }
        //MARK:- Send Order To Kitchen
        self.order.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
        order.save_and_send_to_kitchen(forceSend:true,with:.NEW_ORDER ,for:[.KDS,.NOTIFIER])
    }
    
    
    
    @IBAction func btnCancel(_ sender: Any) {
        if isSartUpdate {
            return
        }
        if !NetworkConnection.isConnectedToNetwork()
        {
            WaringToast.shared.showWaringAlert(with: nil)

            return
        }
        isSartUpdate = true

//        if self.order.order_integration == .DELIVERY {
//            if let integrationOrder = self.order.pos_order_integration{
                var orderIntegration:pos_order_integration_class? =  self.order.order_integration == .DELIVERY ? self.order.pos_order_integration : nil
                var posOrder:pos_order_class? =  self.order.order_integration != .DELIVERY ? self.order : nil
        self.showProgressPopup()
//            loadingClass.show(view: self.view)

            DeliveryOrderIntegrationInteractor.shared.updateStatus(integrateOrder:orderIntegration ,posOrder:posOrder, with: .rejected, completion: { result in
                DispatchQueue.main.async {
                    self.stopProgressPopup()
                    self.isSartUpdate = false
                    if result ?? false {
                        self.doRejectOrder()
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
//            }
//        }else{
//            doRejectOrder()
//        }
        

    }
    
    func doRejectOrder(){
        self.order.is_void = true
        self.order.is_closed = true
        self.order.order_menu_status = .rejected
        self.order.pos_order_lines.forEach { line in
            line.is_void = true
            let _ = line.save(write_info: true)
        }
        self.order.save(write_info: true,  re_calc: false)
        baseClass.stopSound()
//        AppDelegate.shared.syncNow()
        self.dismiss(animated: true, completion: nil)
        self.didSelect?(  self.order)
    }
     
     
    
}
