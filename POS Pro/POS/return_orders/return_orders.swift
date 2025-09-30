//
//  return_orders.swift
//  pos
//
//  Created by Khaled on 4/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class return_orders: baseViewController , UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var btnSelectAll: UIButton!
    
    @IBOutlet weak var subTitleLbl: UILabel!
    
    var order:pos_order_class?
    var sub_orders:[pos_order_class]  = []
    
    
    var list_items:[pos_order_line_class] = []
    
    var have_discount:Bool = false
    var delivery_line:pos_order_line_class?
    var lineServiceCharge:pos_order_line_class?

    var didSelectReturnOrder : ((pos_order_class) -> Void)?
    
    var parent_vc:UIViewController?
    
    var line_discount:pos_order_line_class?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //           self.preferredContentSize = CGSize.init(width: 720, height: 700)
        
        blurView()
        
        
        checkSelected()
        checkItemsReturned()
        subTitleLbl.text = "Select item you want returned".arabic("حدد العنصر الذي تريد إرجاعه")
        tableview.reloadData()
        if !(order?.canReturnLineFromOrder() ?? true){
            subTitleLbl.text = "These order must return as all".arabic("يجب أن يعود هذا الطلب ككل")
            self.btnSelectAll(self.btnSelectAll as Any)
//            self.selectAll()
        }
    }
    
    
    
    func checkItemsReturned() {
        
        
        
        if sub_orders.count > 0
        {
            var all_lines :[pos_order_line_class] = []
           let subOrdersLines = sub_orders.flatMap({$0.pos_order_lines})
            all_lines.append(contentsOf:subOrdersLines)
//            for  order in sub_orders {
//                all_lines.append(contentsOf: order.pos_order_lines)
//            }
            
            for line in list_items
            {
                if have_discount == true
                {
                    line.tag_temp = "returned"
                }
                else
                {
                    let orginQty = line.qty
                    let orginUnitePriceSub = (line.price_subtotal ?? 0.0) / orginQty
                    let orginPriceInc = (line.price_subtotal_incl ?? 0.0) / orginQty
                    
                    let currentQty = self.getQty(for: line)
                    line.qty = currentQty
                    line.price_subtotal = (currentQty * orginUnitePriceSub).rounded_app()
                    line.price_subtotal_incl = (currentQty * orginPriceInc).rounded_app()
                    
                    if line.is_combo_line ?? false {
                        line.selected_products_in_combo.forEach { addOn in
                            let orginQty = addOn.qty
                            let orginUnitePriceSub = (addOn.price_subtotal ?? 0.0) / orginQty
                            let orginPriceInc = (addOn.price_subtotal_incl ?? 0.0) / orginQty
                            
                            let currentAddOnQty = orginQty * (currentQty / orginQty)
                            addOn.qty = currentAddOnQty
                            addOn.price_subtotal = (currentAddOnQty * orginUnitePriceSub).rounded_app()
                            addOn.price_subtotal_incl = (currentAddOnQty * orginPriceInc).rounded_app()
                        }
                    }

                    let return_item = all_lines.filter({$0.product_id == line.product_id})
                    if return_item.count > 0
                    {
                        let totalQty = return_item.compactMap({abs($0.qty)}).reduce(0,+)
                        if totalQty >= orginQty{
                            line.tag_temp = "returned"
                        }
                    }
                }
                
                
           
            }
            
        }
        
        
    }
    
    func checkSelected()
    {
        list_items.removeAll()
        btnSelectAll.tag = 0
        
          line_discount = order!.get_discount_line()
        let have_promotion = order!.is_have_promotions()
        delivery_line = order!.get_delivery_line()
        if (delivery_line?.is_void ?? false){
            delivery_line = nil
        }
        lineServiceCharge = order!.get_service_charge_line()
        if (lineServiceCharge?.is_void ?? false){
            lineServiceCharge = nil
        }
        if (line_discount?.is_void ?? false){
            line_discount = nil
        }
        
        if (line_discount != nil || have_promotion   || delivery_line != nil || lineServiceCharge != nil )
        {
            have_discount = true
            btnSelectAll.isEnabled = false
            tableview.allowsSelection = false
            
            
        }
        
        for line in order!.pos_order_lines
        {
            
            if have_discount
            {
                line.tag_temp = "selected"
                
            }
            
            list_items.append(line)
            
        }
        
        if (line_discount != nil)
        {
            
            line_discount!.tag_temp = "selected"
            list_items.append(line_discount!)
        }
        
        if let delivery_line = delivery_line
        {
            
            delivery_line.tag_temp = "selected"
            list_items.removeAll(where: {$0.product_id == delivery_line.product_id })
            list_items.append(delivery_line)
        }
        if (lineServiceCharge != nil)
        {
            
            lineServiceCharge!.tag_temp = "selected"
            list_items.removeAll(where: {$0.product_id == lineServiceCharge!.product_id })
            list_items.append(lineServiceCharge!)
        }
        
        
//        if (have_extra_fess != nil)
//        {
//
//            have_extra_fess!.tag_temp = "selected"
//            list_items.append(have_extra_fess!)
//        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //        if have_discount
        //        {
        //            tableView.reloadData()
        //            return
        //        }
        if (order?.canReturnLineFromOrder() ?? true){

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
        }
        tableView.reloadData()
        
        
        
        //          didSelect?(itme)
        //           self.dismiss(animated: true, completion: nil)
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
        var cell: return_ordersTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? return_ordersTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "return_ordersTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? return_ordersTableViewCell
        }
        
        
        cell.orderClass = self.order
        cell.parent = self
        cell.list_items =  list_items
        cell.index = indexPath.row
        cell.updateCell()
        
        let itme =  list_items[indexPath.row]
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
        if btnSelectAll.tag == 0
        {
            btnSelectAll.tag = 1
            for item in list_items where item.tag_temp != "returned" {
                item.tag_temp = "selected"
            }
            btnSelectAll.setTitle("Un select all", for: .normal)
        }
        else
        {
            btnSelectAll.tag = 0
            for item in list_items where item.tag_temp != "returned" {
                item.tag_temp = nil
            }
            btnSelectAll.setTitle("Select all", for: .normal)
        }
        
        if !(((order?.canReturnLineFromOrder() ?? true) && btnSelectAll.tag == 1) ||  btnSelectAll.tag == 0) {
            btnSelectAll.tag = 0
            btnSelectAll.setTitle("Select all", for: .normal)
        }
        tableview.reloadData()
    }
    func selectServiceLines(){
        line_discount = order!.get_discount_line()
      delivery_line = order!.get_delivery_line()
        lineServiceCharge = order!.get_service_charge_line()
        if (line_discount != nil)
        {
            list_items.removeAll(where: {($0.product_id == line_discount?.product_id)  })
            line_discount!.tag_temp = "selected"
            list_items.append(line_discount!)
        }
        
        if (delivery_line != nil)
        {
            list_items.removeAll(where: { ($0.product_id == delivery_line?.product_id)  })

            delivery_line!.tag_temp = "selected"
            list_items.append(delivery_line!)
        }
        if (lineServiceCharge != nil)
        {
            list_items.removeAll(where: {($0.product_id == lineServiceCharge?.product_id)  })
            lineServiceCharge!.tag_temp = "selected"
            list_items.append(lineServiceCharge!)
        }
    }
    func selectAll()
    {
        self.selectServiceLines()
        
        for line in order!.pos_order_lines
        {
 
                line.tag_temp = "selected"
          
            list_items.append(line)
            
        }
       
        
    }
    func getQty(for line:pos_order_line_class,addOn:pos_order_line_class? = nil) -> Double{
        var qty = 0.0
        sub_orders.forEach { order_item in
            let pos_line_array = order_item.pos_order_lines.filter { $0.product_id ==  line.product_id }
            pos_line_array.forEach({ product_item in
                qty += (product_item.qty * -1)
            })
        }
        if qty > 0 && line.qty > 0 {
            qty = line.qty - qty
        }
        return qty > 0 ? qty : line.qty
    }
    func mustChosePayment() -> Bool{
       return ( SharedManager.shared.appSetting().enable_chosse_account_journal_for_return_order) || ((order?.get_bankStatement().count ?? 1) > 1)
    }
    func  returnOrder(parentVC:UIViewController? = nil,complete: ((Bool)->Void)? = nil)
    {
        guard  let order = self.order else {
        complete?(false)
            return
        }
        self.getSequenceOrderReturn(order: order) { (createRerunOrder,showAlert) in
            if let rerunOrder = createRerunOrder {
                rerunOrder.pos_order_lines.removeAll()
                
                
                
                rerunOrder.delivery_amount = 0
                rerunOrder.delivery_type_id = order.delivery_type_id
                rerunOrder.pos_multi_session_write_date = ""
                
                var total_subtotal_incl:Double = 0
                var total_subtotal :Double = 0

                for item in self.list_items {
                    if (item.tag_temp ?? "") == "selected"
                    {
                        item.id = 0
                        let totalQty =  item.last_qty
                        if item.max_qty_app == nil
                        {
                            item.max_qty_app = item.qty
                        }
                        
                        item.max_qty_app =  item.max_qty_app! * -1
                        item.qty =  item.qty * -1
                        //                if item.is_combo_line == true
                        //                {
                        //                    item.price_subtotal  =    item.price_subtotal! * -1
                        //                    item.price_subtotal_incl  =    item.price_subtotal_incl! * -1
                        //                }
                        
                        //                item.custome_price_app = true
                        //                item.update_values()
                        item.price_subtotal  =    item.price_subtotal! * -1
                        item.price_subtotal_incl  =    item.price_subtotal_incl! * -1
                        
                        if self.line_discount?.product_id == item.product_id
                        {
                            item.price_unit  =    item.price_unit! * -1
                        }
                    
                        
                        total_subtotal_incl = total_subtotal_incl + item.price_subtotal_incl!
                        total_subtotal = total_subtotal + item.price_subtotal!
                        
                        item.write_info = true
                        item.printed = .none
                        item.pos_multi_session_write_date = ""
                        item.last_qty = 0
                        
                        if item.selected_products_in_combo.count > 0
                        {
                            //BUG ISSUE:- if combo containe not_require_addon May addon_qty not match combo_qty
                            //BUG ISSUE:- if combo containe require_addon May addon_qty not match combo_qty
                            for i in 0..<item.selected_products_in_combo.count
                            {
                                let combo_item = item.selected_products_in_combo[i]
                               /*
                                if abs(item.qty) != combo_item.qty || combo_item.qty <= 0 {
                                    continue
                                }
                                */

                                var unitQty = 1.0
                                if totalQty > 0 {
                               //  unitQty = (combo_item.qty / totalQty)
                                }
                                combo_item.qty =  abs( combo_item.qty ) * unitQty  * -1
                                combo_item.id = 0
                                combo_item.price_subtotal  =    combo_item.price_subtotal! * -1
                                combo_item.price_subtotal_incl  =    combo_item.price_subtotal_incl! * -1
                                
                                total_subtotal_incl = total_subtotal_incl + combo_item.price_subtotal_incl!
                                total_subtotal = total_subtotal + combo_item.price_subtotal!

                                
                                combo_item.printed = .none
                                combo_item.pos_multi_session_write_date = ""
                                combo_item.last_qty = 0
                                
                                item.selected_products_in_combo[i] =  combo_item
                                
                            }
                        }
                        
                        
                        rerunOrder.pos_order_lines.append(item)
                        
                        
                    }
                }
                
                
                if rerunOrder.pos_order_lines.count == 0
                {
                    messages.showAlert("Please select item.")
                    complete?(false)
                    return
                }
                
                // =========================================
                // line_extra_fees
                let pos = SharedManager.shared.posConfig()
                if  pos.extra_fees == true
                {
                    let line = pos_order_line_class.get(order_id:  order.id!, product_id: pos.extra_product_id!)
                    if line != nil
                    {
        //                let lines_extra_fees = rerunOrder?.pos_order_lines.filter({!($0.is_void ?? false) && $0.product.allow_extra_fees}) ?? []
        //                let extra_percentage = Double( pos.extra_percentage!) / 100
        //                var extra_amount = lines_extra_fees.compactMap({ $0.price_subtotal_incl ?? 0.0 }).reduce(0.0, +)
        //                extra_amount = extra_amount * extra_percentage

        //                var extra_amount = total_subtotal_incl
        //                if delivery_line != nil
        //                {
        //                    extra_amount = extra_amount - delivery_line!.price_subtotal_incl!
        //                }
                        
        //                extra_amount = ((extra_amount * Double( pos.extra_percentage!)) / 100 )
                        
                        line!.id = 0
                         line!.write_info = true
                        line!.printed = .none
                        line!.pos_multi_session_write_date = ""
                        line!.last_qty = 0
                        line!.custom_price =  (line!.custom_price ?? 0.0) * -1
                        line!.update_values()
                        
                        total_subtotal_incl += line!.price_subtotal_incl!
                        total_subtotal   += line!.price_subtotal!

                        rerunOrder.pos_order_lines.append(line!)

                        
                    }
                }
                // =========================================
                let isReturnAllLine =   self.list_items.count == (self.list_items.filter({($0.tag_temp ?? "") == "selected"}).count)
                let totalSubtotalIncl = (total_subtotal_incl == 0 && isReturnAllLine) ? ((rerunOrder.amount_total ) ) : total_subtotal_incl
                rerunOrder.amount_tax = totalSubtotalIncl - total_subtotal //rerunOrder!.amount_tax * -1
                rerunOrder.amount_total = totalSubtotalIncl
                rerunOrder.amount_paid = totalSubtotalIncl
                rerunOrder.amount_return = totalSubtotalIncl * -1
                
                //        order?.save(write_info: true, updated_session_status: .last_update_from_local,re_calc: false )
                let setting = SharedManager.shared.appSetting()
                if setting.enable_customer_return_order {
                    if rerunOrder.customer == nil {
                        let storyboard = UIStoryboard(name: "customers", bundle: nil)
                       if let vc = storyboard.instantiateViewController(withIdentifier: "new_customers_listVC") as? new_customers_listVC
                       {
                        vc.selectedCustomer = nil
                        vc.completionBlock = { [weak self]selectCustomer in
                            rerunOrder.customer = selectCustomer
                            if let self = self {
                                /**Bug [save amount_total for return lines]**/
        //                        self.order?.customer = selectCustomer
        //                        self.order?.save()
                                self.sendReturnedLinesToKDViaIP(rerunOrder.pos_order_lines )
                                self.didSelectReturnOrder?(rerunOrder)
                                if !mustChosePayment(){
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                           vc.modalPresentationStyle = .overFullScreen
                           vc.modalTransitionStyle = .crossDissolve
                           if let parentVC = parentVC {
                               parentVC.present(vc, animated: true, completion: nil)
                           }else{
                               self.present(vc, animated: true, completion: nil)
                           }
        //                messages.showAlert("should chose customer")
                       }
                        complete?(false)
                        return
                    }
                }
                self.sendReturnedLinesToKDViaIP(rerunOrder.pos_order_lines)
                self.didSelectReturnOrder?(rerunOrder)
                
                complete?(true)
                return
            }else{
                if let showAlert = showAlert, showAlert {
                    messages.showAlert("Please create session frist.")
                }
                complete?(false)
            }
        }
        
        
        
    }
    func sendReturnedLinesToKDViaIP(_ returnedLines:[pos_order_line_class]){
        if !(order?.isAllLinesInsurance() ?? false){
             if SharedManager.shared.appSetting().enable_add_kds_via_wifi {
            order?.sent_returned_order_via_ip(returnedLines: returnedLines)
        }
           
        }
       
    }
    @IBAction func btnOk(_ sender: Any) {
        
        
       returnOrder()
       
        
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
    
    func updateKitchenStatus(for returnedLines:[pos_order_line_class],in order:pos_order_class){
        if returnedLines.count == order.pos_order_lines.count {
//            order.pos_order_lines.forEach { existLine in
//                existLine.save(write_info: true, updated_session_status: .sending_update_to_server, kitchenStatus: .returned)
//            }
            
            order.save(write_info: true, write_date: true, updated_session_status: .sending_update_to_server, kitchenStatus: .returned, re_calc: false)
            AppDelegate.shared.run_poll_send_local_updates()

        }else{
        returnedLines.forEach { returnedLine in
            order.pos_order_lines.forEach { existLine in
                if existLine.product_id == returnedLine.product_id {
                   let diffQty = existLine.qty + returnedLine.qty
                    if diffQty == 0 {
                        existLine.save(write_info: true, updated_session_status: .sending_update_to_server, kitchenStatus: .returned)
                    }
                    if diffQty < 0 {
                        //Not Possilble
                        return
                    }
                   
                    if diffQty > 0 {
                        // TODO: - Send only quanty
                    }
                }
            }
        }
        }

       
    }
    func doReturn(order:pos_order_class,list_bankStatement:[pos_order_account_journal_class],checkListAccount:Bool = true)
    {
        
//        if list_bankStatement.count > 1
//        {
        if checkListAccount{
            order.list_account_journal = []
            for cls in  list_bankStatement
            {
                let account:account_journal_class = account_journal_class(fromDictionary: [:])
                account.id = cls.account_Journal_id
                
                if list_bankStatement.count > 1
                {
                    account.changes =  cls.changes! * -1
                    let tendered:Double = cls.tendered!.toDouble()!  * -1
                    account.tendered = tendered.toIntString()
                    account.due =  cls.due!  * -1
                    account.rest = cls.rest!  * -1
                }
                else
                {
                    let total =   order.amount_total
                    
                    account.tendered =  total.toIntString()
                    account.due =  total
                    account.rest = 0
                    account.changes =  0
                    
                }
                
                order.list_account_journal.append(account)
                
                
            }
        }
//        }
//        else
//        {
//            let total =   order.amount_total
//
//            let accountCls = get_retrun_list_bankStatement()
//            if accountCls != nil
//            {
//                accountCls?.tendered =  total.toIntString()
//                accountCls?.due =  total
//
//                order.list_account_journal = []
//                order.list_account_journal.append(accountCls!)
//            }
//        }
        
        
        
        
        order.is_closed = true
        order.is_sync = false
        
        order.save(write_info: true, updated_session_status: .last_update_from_local,re_calc: false )
        
        order.setBill_uid()
        let option = ordersListOpetions()
        option.Closed = true
        option.orderID = order.parent_order_id
        option.parent_product = true
        
        
//        let list_sub:[pos_order_class] = pos_order_helper_class.getOrders_status_sorted(options: option)
        
        showMessageSuccess(order: order)
        
        
        
//        let otherPrinter:printersNetworkAvalibleClass? = printersNetworkAvalibleClass()
//
//        let ord =   otherPrinter?.prepear_order(order: order ,reReadOrder: false)
//
//        otherPrinter!.printToAvaliblePrinters(Order: ord)
//
//        SharedManager.shared.epson_queue.run()
        
        
    }
    
    func showMessageSuccess(order:pos_order_class )
    {
        let sucessmsg:paymentSuccessfullMessage
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        // paymentSuccessfullMessage_invoice
        sucessmsg = storyboard.instantiateViewController(withIdentifier: "paymentSuccessfullMessage") as! paymentSuccessfullMessage
        sucessmsg.modalPresentationStyle = .overFullScreen
        //        sucessmsg.delegate = self
        
        
        sucessmsg.total = String    (format: "%@",  order.amount_return.toIntString())
        sucessmsg.order = order
        sucessmsg.needToPrint = true
        self.dismiss(animated: true, completion: {
            self.parent_vc?.present(sucessmsg, animated: true, completion: nil)
            if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
//                order.creatKDSQueuePrinter(.return_order)
//                MWRunQueuePrinter.shared.startMWQueue()
            }else{
            let ord = sucessmsg.otherPrinter?.prepear_order(order: order,reReadOrder: true)

            sucessmsg.otherPrinter?.printToAvaliblePrinters(Order: ord)
            }
        })
       
        
        
        
        
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func get_list_bankStatement() -> account_journal_class?
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
    func showLoading(){
        DispatchQueue.main.async {
            loadingClass.show(view: self.view )
        }
    }
    func hideLoading(){
        DispatchQueue.main.async {
            loadingClass.hide(view: self.view )
        }
    }
    func getSequenceOrderReturn(order:pos_order_class,complete:@escaping (pos_order_class?,Bool?)->Void) {
        if SharedManager.shared.appSetting().enable_sync_order_sequence_wifi{
            if !(SharedManager.shared.posConfig().isMasterTCP() ){
                self.showLoading()
            }
            sequence_session_ip.shared.getSequenceForNextOrder(for: self.view)  { result in
                if !(SharedManager.shared.posConfig().isMasterTCP() ){
                    self.hideLoading()
                }
                if result {
                    let ipSequence = sequence_session_ip.shared.completeGetSequenceFromMaster()

                    complete(self.getReturnOrder(order:order,with:ipSequence),nil)
                }else{
                    messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
                    complete(nil,false)
                    
                }
            }
        }else{
            complete(self.getReturnOrder(order:order),true)
        }
    }
    func getReturnOrder(order:pos_order_class,with sequence:Int? = nil) -> pos_order_class?
    {
        
        let activeSession = pos_session_class.getActiveSession()
        if activeSession == nil
        {
            return nil
        }
        
       let returnOrder = order.copyOrder()
        returnOrder.bill_uid = nil
        returnOrder.id = 0
//        let returnOrder = pos_order_class(fromDictionary: order.toDictionary())
        let sequence_number = sequence != nil ? (sequence ?? 1) : returnOrder.generateInviceID(session_id: activeSession?.id )
        returnOrder.sequence_number = sequence_number
        //            let newID :Int64  =  baseClass.getTimeINMS() // ClassDate.getTimeINMS()!.toInt()!
        
        
        //            let orderID_server = String(format: "%d%d", newID ,   returnOrder.sequence_number_lastupdate   )
        //            returnOrder.name = pos_order_helper_class.formateOrderID(orderID: orderID_server)
        
        let orderID_server =  pos_order_helper_class.get_new_order_id_server(sequence_number: returnOrder.sequence_number )
        
        //            let total =  returnOrder.amount_total * -1
        //
        //            let pos = SharedManager.shared.posConfig()
        //
        //            let bankStatment = pos.accountJournals_cash_default()
        //
        //            if bankStatment == nil
        //            {
        //                MessageView.show("Can't retrun , no cash default found.", vc: self)
        //                return nil
        //            }
        //
        //
        //            bankStatment!.tendered =  total.toIntString()
        //            bankStatment!.changes = 0
        //
        //             returnOrder.list_bankStatement = []
        //            returnOrder.list_bankStatement.append(bankStatment!)
        
        
        returnOrder.name = String(format: "Order-%@",orderID_server )   //formateOrderID(orderID: orderID_server)
        returnOrder.uid = orderID_server
        
        returnOrder.id = nil
        returnOrder.is_sync = false
        returnOrder.is_closed = false
        returnOrder.parent_order_id = order.id ?? 0
        returnOrder.parent_order_id_server = order.name
        
        
        
        //            for item in returnOrder.products
        //            {
        //                item.max_qty_app =  item.qty_app
        //                item.qty_app =  item.qty_app * -1
        //                item.price_app_priceList =    item.price_app_priceList * -1
        ////                item.update_values()
        //            }
        
        returnOrder.amount_return =  returnOrder.amount_total
        returnOrder.amount_paid = returnOrder.amount_total * -1
        
        
        
        // update if different session
        //              let shift = posSessionClass.getCurrentShift(session_id: activeSession!.id)
        returnOrder.session = activeSession
        //              returnOrder.shift = shift
        returnOrder.cashier = SharedManager.shared.activeUser()
        
        
        //        returnOrder.calcAll()
        //        returnOrder.saveOrder()
        
        
        return returnOrder
        
        
        
    }
    
}
