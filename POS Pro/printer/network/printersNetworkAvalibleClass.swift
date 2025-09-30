//
//  printersAvalibleClass.swift
//  pos
//
//  Created by Khaled on 1/13/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class printersNetworkAvalibleClass: NSObject {
    
    var all_printers:[String:[String:Any]]? = [:]
    var order:pos_order_class?
    
    var lst_restaurant_printer:[[String:Any]] = []
    
    deinit {
        all_printers!.removeAll()
        all_printers = nil
        order = nil
        
        lst_restaurant_printer.removeAll()
 
     }
    
    func prepear_order(order:pos_order_class,reReadOrder:Bool) -> pos_order_class
    {
    
    
        var ord:pos_order_class = order
        
        if reReadOrder == true
        {
            let opetions = ordersListOpetions()
            opetions.get_lines_void = true
            opetions.uid = order.uid
            opetions.parent_product = true
            opetions.printed = false
            opetions.get_lines_void_from_ui = true
            
            let temp_order = pos_order_helper_class.getOrders_status_sorted(options: opetions)
            if temp_order.count > 0
            {
                  ord = temp_order[0]
            }
        }
        
   
            // remove line that delete before send to printer

             ord.pos_order_lines.removeAll{  $0.is_void == true && $0.pos_multi_session_write_date == ""  }

            
            for line in ord.pos_order_lines
            {
                if line.is_combo_line == true
                {
                    line.selected_products_in_combo.removeAll{  $0.is_void == true && $0.pos_multi_session_write_date == ""  }

                    line.selected_products_in_combo.removeAll{  $0.printed == .printed   }
                }
                 
            }

//            self.printToAvaliblePrinters(Order: ord )

        
        return ord
    }
    
    func printToAvaliblePrinters(Order:pos_order_class?)
    {
        lst_restaurant_printer = restaurant_printer_class.getAll()
        
        if lst_restaurant_printer.count == 0
        {
            return
        }
        

        if Order != nil
        {
           
            if !check_if_order_have_lines_need_to_print(for: Order)
            {
                return
            }
            
            self.order = Order!
            
//            DispatchQueue.global(qos: .background).async {
                self.getPrinters()
                self.createQueue()
//                self.runQueue()
//            }
        }
        
        
    }
    func check_if_order_have_lines_need_to_print(for Order: pos_order_class?) -> Bool{
        // get non-printed lines
        let  non_printed_lines_arr = Order?.pos_order_lines.filter {$0.printed != .printed} ?? []
        // check if non-printed lines > 0
        if non_printed_lines_arr.count > 0 {
            let same_qty_lines_arr = non_printed_lines_arr.filter {$0.qty == $0.last_qty && $0.is_void == false}
            if same_qty_lines_arr.count == non_printed_lines_arr.count {
                Order?.pos_order_lines.forEach({ line in
                    line.printed = .printed
                })
                Order?.save()
                return false
            }
            
        }else{
            if non_printed_lines_arr.count == 0 {
                return false
            }
        }
        return true
    }
    
    private  func getPrinters()
    {
        
        all_printers!.removeAll()
        

        for printer in lst_restaurant_printer
        {
            //         let printer_ip = printer["printer_ip"] as? String ?? ""
            let cls_printer = restaurant_printer_class(fromDictionary: printer)
            //         let name = printer["name"] as? String ?? ""
            let product_order_type_ids = cls_printer.get_order_type_ids()
            if product_order_type_ids.count > 0
            {
                if let type_order = order!.orderType {
                    if !product_order_type_ids.contains(type_order.id)
                    {
                        continue
                    }
                }
            }
          

            
            let product_categories_ids = cls_printer.get_product_categories_ids() // printer["product_categories_ids"]

            if product_categories_ids.count > 0
            {
                let products = get_products_toPrint(categories_ids: product_categories_ids )
                if products.count > 0
                {
                    var dic = all_printers![cls_printer.name] ?? [:]
                    var list = dic["list"] as? [pos_order_line_class]  ?? []
                    list.append(contentsOf: products)
                    
                    dic["list"] = list
                    dic["printer"] = printer
                    
                    all_printers![cls_printer.name] = dic
                }
            }
            
        }
        
        //        SharedManager.shared.printLog(all_printers)
        
    }
    
    private func get_products_toPrint(categories_ids:[Int]) -> [pos_order_line_class]
    {
        var list:[pos_order_line_class] = []
        
        for line in order!.pos_order_lines
        {
            if line.qty != line.last_qty || line.is_void == true {
            if line.product.pos_categ_id != 0
            {
                let pos_categ_id = line.product.pos_categ_id  ?? 0
                let filtered = categories_ids.filter { $0 == pos_categ_id }
                if filtered.count > 0
                {
                    list.append(line)
                }
            }
            }
            
        }
        return list
    }
    
    
    private func createQueue()
    {
        guard let order = order else{return}
        let tempOrder = order.copyOrder()
//        let is_order_void = tempOrder.is_void
//        let is_order_close = tempOrder.is_closed
//        let is_order_print_for_kitchen = tempOrder.is_print_for_kitchen
//        let prevent_print_condation = is_order_print_for_kitchen && !is_order_void && is_order_close
//        if prevent_print_condation {
//            return
//        }
        for (_,value) in all_printers!
        {
            let printer_info = value["printer"] as? [String:Any] ?? [:]
            let printer_ip = printer_info["printer_ip"] as? String ?? ""
            let printer_name = printer_info["name"] as? String ?? ""
            let id = printer_info["id"] as? Int
            
            if id != nil
            {
                let list = value["list"] as? [pos_order_line_class]  ?? []
            
            tempOrder.pos_order_lines.removeAll()
            tempOrder.pos_order_lines.append(contentsOf: list)
     
                let  queue_log_class = queue_log_class(fromDictionary: [:])
                queue_log_class.ip = printer_ip
                queue_log_class.printer_name = printer_name
                queue_log_class.order_id = tempOrder.id ?? 0
                queue_log_class.numb_lines = list.count
                queue_log_class.type_printer = "kds"
                queue_log_class.init_qty = Int(order.pos_order_lines.map({$0.qty}).reduce(0, +) )
                queue_log_class.last_qty = Int(order.pos_order_lines.map({$0.last_qty}).reduce(0, +) )

                let count_printed = list.filter({$0.printed == .printed}).count
                if list.count == count_printed{
                    queue_log_class.state_printed = state_printed_queue.printed
                }else{
                    if  count_printed <= 0{
                        queue_log_class.state_printed = state_printed_queue.not_printed
                    }else
                    if  count_printed >= 0 {
                        queue_log_class.state_printed = state_printed_queue.not_all_printed
                    }else{
                        queue_log_class.state_printed = state_printed_queue.none

                    }
                }
                queue_log_class.save()

            SharedManager.shared.epson_queue.add_job_printer(id:id!,IP: printer_ip,printer_name: printer_name, order:tempOrder ,print_items_only: true ,openDeawer: false,index: 0,master:false)
            }

             
             
        }
//        order!.is_print_for_kitchen = true
//        order!.save()
     }
    
    
    private func runQueue()
    {
        for (_,printer) in SharedManager.shared.printers_pson_print
        {
            printer.runPrinterQueue()
        }
    }
    
    
    
}
