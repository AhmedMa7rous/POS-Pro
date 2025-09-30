//
//  return_orders.swift
//  pos
//
//  Created by Khaled on 4/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class split_order: baseViewController , UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var btnSelectAll: UIButton!
    
    
    var order:pos_order_class?
    var sub_orders:[pos_order_class]  = []
    
    
    var list_items:[pos_order_line_class] = []
    
    var have_discount:Bool = false
    
    
    var didSelect : ((pos_order_class) -> Void)?
    
    var parent_vc:create_order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        blurView()
        
        checkSelected()
        tableview.reloadData()
    }
    
    
    

    func checkSelected()
    {
        btnSelectAll.tag = 0
 

        for line in order!.pos_order_lines
        {
 

            list_items.append(line)

        }

 
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    
        let itme =  list_items[indexPath.row]
        
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
        
        list_items[indexPath.row] = itme
        tableView.reloadData()
        
   
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let line =  list_items[indexPath.row]
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
        
        if !(line.note ?? "").isEmpty || !(line.discount_display_name ?? "").isEmpty
        {
            return 60;
        }
        
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"
        var cell: split_orderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? split_orderTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "split_orderTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? split_orderTableViewCell
        }
        
        
        
        cell.parent = self
        let itme =  list_items[indexPath.row]
        cell.updateCell(with: itme)
        
        if (itme.tag_temp ?? "") == "returned"
        {
            cell.selectionStyle = .none
        }
        
        
        
        
        return cell
    }
    
    @IBAction func btnSelectAll(_ sender: Any) {
       
        let returnedOItems = list_items.filter({ (item) -> Bool in
           return item.tag_temp  == "returned"
        })
        if returnedOItems.count == list_items.count {
            return
        }
        var selected:String? = nil
        if btnSelectAll.tag == 0
        {
            btnSelectAll.tag = 1
            selected = "selected"
            btnSelectAll.setTitle("Un select all", for: .normal)
        }
        else
        {
            btnSelectAll.tag = 0
            btnSelectAll.setTitle("Select all", for: .normal)
            
        }
        
        for item in list_items {
            if item.tag_temp != "returned"{
                item.tag_temp = selected
            }
        }
        tableview.reloadData()
        
    }
    
    func selectAll()
    {
    
        
        for line in order!.pos_order_lines
        {
 
                line.tag_temp = "selected"
          
            list_items.append(line)
            
        }
        
    }
    
    func  split()
    {
        
        let order_new = pos_order_helper_class.creatNewOrder() //getSplitOrder(order: order!)
//        if order_new ==  nil
//        {
//            messages.showAlert("Please create session frist.")
//            return false
//        }
//
//        order_new?.pos_order_lines.removeAll()
        
        
        
//        order_new!.delivery_amount = 0
//        order_new!.delivery_type_id = order?.delivery_type_id
//        order_new!.pos_multi_session_write_date = ""
        
  

        for item in list_items {
            if (item.tag_temp ?? "") == "selected"
            {
                
                // update current order
              let index =  parent_vc?.orderVc?.order?.pos_order_lines.firstIndex(where: {$0.id == item.id})
              let last_line = parent_vc?.orderVc?.order?.pos_order_lines[index!]
//                let last_line = parent_vc?.orderVc?.order?.pos_order_lines.first(where: {$0.id == item.id})
                let diff_qty = last_line!.qty - item.qty
                if diff_qty == 0
                {
                    last_line!.is_void = true
                }
                
                last_line!.qty = diff_qty
                
                if last_line!.selected_products_in_combo.count > 0 {
                     
                    for p in last_line!.selected_products_in_combo
                    {
                        p.qty = p.qty - item.qty
                        if p.qty < 0
                        {
                            p.qty = 1
                        }
                        p.update_values()
                    }
                }
                
                last_line!.update_values()

                parent_vc?.orderVc?.order?.pos_order_lines[index!] = last_line!
                parent_vc?.orderVc?.order?.save(write_info: true, write_date: true, updated_session_status: .last_update_from_local,   re_calc: true)
                parent_vc?.re_read_order()
                
                
                let new_line = pos_order_line_class(fromDictionary: item.toDictionary())
                new_line.id = 0
                new_line.order_id = order_new.id!
                new_line.write_info = true
                new_line.printed = .none
                new_line.pos_multi_session_write_date = ""
                new_line.last_qty = 0
                
                if last_line!.selected_products_in_combo.count > 0 {
                     
                    for p in last_line!.selected_products_in_combo
                    {
                        let compo_line = pos_order_line_class(fromDictionary: p.toDictionary())
                        
                        compo_line.id = 0
                        compo_line.order_id = order_new.id!
                        compo_line.parent_line_id = 0
                        compo_line.qty = item.qty
                        compo_line.update_values()
                        
                        new_line.selected_products_in_combo.append(compo_line)
                        
                    }
                }
                
                
                new_line.update_values()
 
                order_new.pos_order_lines.append(new_line)
                
                
            }
        }
        
 
        order_new.save(write_info: true, write_date: true, updated_session_status: .last_update_from_local,re_calc: true )
 
 
//        didSelect?(order_new)
       
         self.dismiss(animated: true, completion: {
            self.didSelect?(order_new)
         })

        
        
//        return true
    }
    @IBAction func btnOk(_ sender: Any) {
        
        
//      let check =
        split()
//       if check == true
//       {
//        self.dismiss(animated: true, completion: nil)
//
//       }
        
    }
 
    
     
    
    @IBAction func btnCancel(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
 
    
    func getSplitOrder(order:pos_order_class) -> pos_order_class?
    {
        let activeSession = pos_session_class.getActiveSession()
        if activeSession == nil
        {
            return nil
        }
        
        
        let returnOrder = pos_order_class(fromDictionary: order.toDictionary())
 
        
        let orderID_server =  pos_order_helper_class.get_new_order_id_server(sequence_number: returnOrder.sequence_number )
        
        
        returnOrder.sequence_number = returnOrder.generateInviceID(session_id: returnOrder.session_id_local! )
  
        
        returnOrder.name = String(format: "Order-%@",orderID_server )
        returnOrder.uid = orderID_server
        
        returnOrder.id = nil
        returnOrder.is_sync = false
        returnOrder.is_closed = false
//        returnOrder.parent_order_id = order.id ?? 0
//        returnOrder.parent_order_id_server = order.name
        
 
        
        returnOrder.amount_return =  returnOrder.amount_total
        returnOrder.amount_paid = returnOrder.amount_total * -1
        
     
        returnOrder.session = activeSession
         returnOrder.cashier = SharedManager.shared.activeUser()
   
        
        return returnOrder
        
        
        
    }
    
}
