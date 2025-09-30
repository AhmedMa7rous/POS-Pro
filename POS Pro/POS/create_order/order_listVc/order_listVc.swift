//
//  order_listVc.swift
//  pos
//
//  Created by khaled on 9/24/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit



class order_listVc: UIViewController ,UITableViewDelegate , UITableViewDataSource {
    
    
    
    var  promotion_helper:promotion_helper_class? =  promotion_helper_class()

    
    var refreshControl_tableview = UIRefreshControl()
    @IBOutlet var tableview: UITableView!
    //        @IBOutlet var lblTotalPrice: KLabel!
    //    @IBOutlet var btnTotalItems: UIButton!
    
    @IBOutlet var view_footer: UIView!
    
    var parent_create_order:create_order?
    var order:pos_order_class!  = pos_order_class()
    var priceList :product_pricelist_class?
    
    weak var delegate:order_listVc_delegate?
//    var keyboard:keyboardVC = keyboardVC()
    var parent_vc:UIViewController?
    
    var enableEdit:Bool = true
    
   
    var show_delete_item:Bool = true
    
    var disable_btnInput:Bool = false
    
    
    var footerRows:[String:String] = [:]
    var footer_height:Int = 45
    
    var  footer_vc:footer_order!
    
    
    var section_temp:[Int:[Int]] = [:]
    var selectedTableFomIcon: restaurant_table_class?

    var getBalance :enterBalanceNew!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupTable()

        initOrder()
        
        footer_vc = footer_order()
        footer_vc.view.frame = view_footer.bounds
        //        footer_vc.view.backgroundColor = .blue
        view_footer.addSubview(footer_vc.view)
        
        
        
//        let headerNib = UINib.init(nibName: "order_cell_header", bundle: Bundle.main)
//        tableview.register(headerNib, forHeaderFooterViewReuseIdentifier: "order_cell_header")
        //        collapceFooter()
        
        tableview.shouldScrollSectionHeaders = true
        
    }
    
    func collapceFooter()
    {
        var cgrect = view_footer.frame
        cgrect.size.height = 45
        
        UIView.animate(withDuration: 0.3) {
            self.view_footer.frame = cgrect
        }
        
    }
    
    
    func expandFooter()
    {
        var cgrect = view_footer.frame
        cgrect.size.height = CGFloat(footer_height)
        UIView.animate(withDuration: 0.3) {
            self.view_footer.frame = cgrect
        }
    }
    
    @IBAction func btnfotter(_ sender: Any) {
        
        if view_footer.frame.size.height == 45
        {
            expandFooter()
        }
        else
        {
            collapceFooter()
        }
        
    }
    
    func resetVales()
    {
        
        //        lblTotalPrice.text =  String(format:"%@%@" ,"Total : ", "0" )
        //        btnTotalItems.setTitle(String(format:"%@  Items" , "0"), for: .normal)
        
        footerRows.removeAll()
        section_temp.removeAll()
        footer_vc.list_items = footerRows
        footer_vc.reload()

    }
    
    func reload_tableview ()
     {
         
        selected_section = -1
        
        tableview.reloadData()
        refreshControl_tableview.endRefreshing()
    }
    func reload_footer()
    {
        
//        order.pos_order_lines.sort{  $0.product_id! < $1.product_id!  }
       
        if order.id == nil
        {
            return
        }
 
        footerRows.removeAll()
        
        order.total_items = order.clacTotalItems()
        let pos = SharedManager.shared.posConfig()
        let delivery_line =  order.get_delivery_line()
        let service_charge_line =  order.get_service_charge_line()

        let dicount_line = checkDiscountProgram()
        var extra_line:pos_order_line_class? = nil
        if pos.extra_fees  {
            if let extraProductID = pos.extra_product_id, extraProductID != 0 {
                extra_line = pos_order_line_class.get(order_id:  order.id!, product_id: pos.extra_product_id!)
            }
        }

        let delivery_amount = (delivery_line?.is_void ?? false) ? 0 : abs (delivery_line?.price_subtotal ?? 0)
        let service_charge_amount = abs (service_charge_line?.price_subtotal ?? 0)
        let discount_amount = abs (dicount_line?.price_subtotal ?? 0)

        if order.total_items != 0
        {

            let Total_items = "1Total ( \(order.total_items.toIntString()) items )"
            let amount_total = order.amount_total
            let amount_tax = order.amount_tax
//            let total = amount_total - amount_tax - delivery_amount + discount_amount - (extra_line?.price_subtotal ?? 0)

            let total = amount_total - amount_tax  + discount_amount - (extra_line?.price_subtotal ?? 0) - service_charge_amount - delivery_amount

            footerRows[Total_items] = baseClass.currencyFormate( total )
        }
        
        
        checkTax(delivery:delivery_line,discount_line: dicount_line)
        if service_charge_amount > 0 && !(service_charge_line?.is_void ?? false){
            let nameServiceCharge = service_charge_line?.product.display_name ?? MWConstants.service_charge
            footerRows[nameServiceCharge] =  baseClass.currencyFormate( service_charge_amount )
        }
        checkOrderType_delivery(delivery_line)
        checkOrderType_extra(extra_line)
        
        get_notes()
        
        
        
        
        
        //        lblTotalPrice.text =  String(format:"%@%@" ,"Total : ", baseClass.currencyFormate(order.amount_total  ) )
        //        btnTotalItems.setTitle(String(format:"%@  Items" , order.total_items.toIntString() ), for: .normal)
        //        lblRowFooterTitle.text = baseClass.currencyFormate(order.tax_order ) //String(format:"%.2f" ,   order.tax_order)
        buildFooterRows()
        
        
  
    }
    
    
    
    func clearViewFooter()
    {
        //        for view in view_footer.subviews
        //        {
        //            if view.tag == 100
        //            {
        //                view.removeFromSuperview()
        //            }
        //        }
        
    }
    
    func buildFooterRows ()
    {
        footer_vc.list_items = footerRows
        footer_vc.reload()
        
        
        
    }
    
    func buildFooterRows_old()
    {
        //        clearViewFooter()
        //
        //        var y =  0
        //
        //        let count = footerRows.count
        //        for i in 0...footerRows.count - 1
        //        {
        //            let row = footerRows[i] as? [String] ?? []
        //
        //            if row.count > 0
        //            {
        //              if i == 0
        //               {
        //                 y = 55
        //                }
        //                else
        //                {
        //                   y = y + 25
        //                }
        //
        //                if row[0] == "Notes"
        //                {
        //                    let frm_txt:CGRect = CGRect.init(x: 2, y: y, width: 347, height: 47)
        //                    let lbl_txt:KLabel = KLabel(frame: frm_txt)
        //                    lbl_txt.text =  row[1]
        //                    lbl_txt.textColor = UIColor.init(hexString: "#767676")
        //                    lbl_txt.textAlignment = NSTextAlignment.center
        //                    lbl_txt.font =   UIFont.init(name:   app_font_name , size: 16)
        //                    lbl_txt.numberOfLines = 0
        //                    lbl_txt.tag = 100
        //                    lbl_txt.backgroundColor = UIColor.groupTableViewBackground
        //                    lbl_txt.layer.borderWidth  = 1
        //                    lbl_txt.layer.borderColor = UIColor.init(hexString: "#767676").cgColor
        ////                    lbl_txt.sizeToFit()
        //                    view_footer.addSubview(lbl_txt)
        //
        //                }
        //                else
        //                {
        //                    let frm_title:CGRect = CGRect.init(x: 23, y: y, width: 100, height: 20)
        //                    let lbl_title:KLabel = KLabel(frame: frm_title)
        //                    lbl_title.text =  row[0] + " : "
        //                    lbl_title.textColor = UIColor.init(hexString: "#767676")
        //                    lbl_title.font = UIFont.init(name:  app_font_name , size: 15)
        //                    lbl_title.tag = 100
        //                    view_footer.addSubview(lbl_title)
        //
        //
        //                    let frm_txt:CGRect = CGRect.init(x: 138, y: y, width: 240, height: 20)
        //                    let lbl_txt:KLabel = KLabel(frame: frm_txt)
        //                    lbl_txt.text =  row[1]
        //                    lbl_txt.textColor = UIColor.init(hexString: "#767676")
        //                    lbl_txt.textAlignment = NSTextAlignment.right
        //                    lbl_txt.font = UIFont.init(name: app_font_name, size: 15)
        //                      lbl_txt.tag = 100
        //
        //                    view_footer.addSubview(lbl_txt)
        //
        //                    let frm_img:CGRect = CGRect.init(x: 0, y: y + 15, width: 400, height: 20)
        //                    let img = UIImageView(frame: frm_img)
        //                    img.image = #imageLiteral(resourceName: "line_horz_dash.png")
        //                    img.contentMode = .scaleAspectFit
        //                    img.tag = 100
        //                     view_footer.addSubview(img)
        //
        //
        //                }
        //
        //
        //
        ////                let row_value =   formate_row(title:  row[0], value: row[1])    // String(format: "%@ : %@", row[0]  , row[1]  )
        //
        ////                if i == 0
        ////                {
        ////
        ////                    lblRowFooterValue.text = row_value
        ////                }
        ////                else
        ////                {
        ////                     lblRowFooterValue.text = String(format: "%@\n%@", lblRowFooterValue.text! ,row_value )
        ////                }
        //            }
        //
        //
        //        }
        //
        //
        ////        setlineSpacing(lable: lblRowFooterValue, txt: lblRowFooterValue.text!, lineSpacing: 2)
        //
        //
        ////
        //        let h = count * 30
        ////
        ////        var rect2 = lblRowFooterValue.frame
        ////        rect2.size.height = CGFloat(h)
        ////
        ////         lblRowFooterValue.frame = rect2
        ////
        //
        //        let new_height =  70 + h
        //
        //        if footer_height != 45
        //        {
        //             footer_height = new_height
        //           expandFooter()
        //        }
        //        else
        //        {
        //                 footer_height = new_height
        //        }
        
    }
    
    func setlineSpacing(lable:KLabel,txt:String,lineSpacing:CGFloat)
    {
        let attr = NSMutableAttributedString(string: txt)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attr.length))
        
        lable.attributedText = attr;
        
    }
    
    func checkOrderType_delivery(_ delivery:pos_order_line_class?)
    {
        let order_type =  order.orderType
        if order_type ==  nil || delivery == nil
        {
            return
        }
        if delivery?.is_void ?? false {
            return
        }
        
        if ((order_type?.delivery_amount ?? 0) > 0 || (delivery!.price_subtotal_incl ?? 0) > 0)  && ( order_type?.order_type == "delivery" || ((order.customer?.pos_delivery_area_id ?? 0) != 0) )
        {
//            let product = pos_order_line_class(fromDictionary: [:])
//            product.product_id = order_type?.delivery_product_id
//            product.update_values()
            
            //            let product = order_type!.delivery_product
            
            //            if product != nil
            //            {
            //            let tax:[String] = ["Delivery" : baseClass.currencyFormate( order_type!.delivery_amount )]
            //
            //                   footerRows.append(tax)
            let amount_delivery_tax =  (delivery!.price_subtotal_incl ?? 0)  -  (delivery!.price_subtotal ?? 0)

            footerRows[MWConstants.delivery_w_o_tax] =  baseClass.currencyFormate( (delivery!.price_subtotal_incl ?? 0) - amount_delivery_tax )
            //            }
            
            
        }
        
        
        
    }
    
    func checkOrderType_extra(_ extra_line:pos_order_line_class?)
    {
        if extra_line?.is_void ?? false{
            return
        }
        let order_type =  order.orderType
        if order_type ==  nil
        {
            return
        }
        
        let pos = SharedManager.shared.posConfig()
        if   pos.extra_fees == true //  order_type?.order_type == "extra"
        {
            if extra_line != nil
            {
          
                let product = extra_line!.product
                footerRows[(product!.name + " w/o").arabic( (product!.name_ar + " بدون ضريبة"))] =  baseClass.currencyFormate( extra_line!.price_subtotal! )
            }

      
 
            
        }
        
        
        
    }
    
    
    
    
    func checkTax(delivery:pos_order_line_class?,discount_line:pos_order_line_class?)
    {
        //        let tax:[String] = ["Tax" ,  baseClass.currencyFormate(order.amount_tax )]
        
        if order.amount_tax  != 0
        {
 

            footerRows["Tax".arabic("الضريبة")] = baseClass.currencyFormate(order.amount_tax )
        }
        //        footerRows.append(tax)
        
        let isTaxFree = SharedManager.shared.posConfig().allow_free_tax
        if isTaxFree == true
        {
            //              let tax_disc:[String] = ["Promo Disc" , baseClass.currencyFormate(order.amount_tax )]
            //
            //                footerRows.append(tax_disc)
            
            footerRows["Promo Disc"] =  baseClass.currencyFormate(order.amount_tax )
        }
        
    }
    
    func checkDiscountProgram()->pos_order_line_class?
    {
        //        let pos = SharedManager.shared.posConfig()
        //
        //        guard let _ = self.order.id else {
        //             return
        //         }
        //
        //        guard let discount_program_product_id = pos.discount_program_product_id else {
        //            return
        //        }
        
        
        
        let line = self.order.get_discount_line()
        if line != nil
        {
            //            let discount:[String] = ["Discount" , (line!.price_unit ?? 0).toIntString()]
            //
            //              footerRows.append(discount)
            
            let amount_discount_tax =  (line?.price_subtotal_incl ?? 0) - (line?.price_subtotal ?? 0)

            
            footerRows[MWConstants.discount_w_o_tax] = ((line!.price_unit ?? 0) - amount_discount_tax) .toIntString()
        }
        
        return line
    }
    
    func checkDiscountProgram_old()
    {
        
        //      if order.discount_program_id != nil {
        //        if order.discount != 0
        //        {
        //            if order.discount_program_id == 0
        //            {
        //                let discount:[String] = ["Discount" , order.discount.toIntString()]
        //
        //                  footerRows.append(discount)
        //            }
        //            else
        //            {
        //                 let discount_program = pos_discount_program_class.get(id: order.discount_program_id!)
        //                      let discount:[String] = ["Discount" , discount_program.name]
        //
        //                       footerRows.append(discount)
        //            }
        //
        //        }
        //        }
        
        
    }
    
    
    
    func initOrder()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
        
    }
    
    
    @objc func refreshOrder(sender:AnyObject?) {
        
        delegate?.reloadOrders(line: nil)
        reload_footer( )
        refreshControl_tableview.endRefreshing()
        //        getOrder()
    }
    
    func refreshTableView() {
        delegate?.reloadOrders(line: nil)
        reload_footer( )
        refreshControl_tableview.endRefreshing()
    }
    
    func get_notes()
    {
        
        
        let line:String = self.order.note.replacingOccurrences(of: "\n", with: " - ")
        //        for (_,valu) in  self.order.notes
        //        {
        //
        //            let note = noteClass(fromDictionary: valu)
        //
        //            if line.isEmpty {
        //                line = String(format: "Notes : %@", note.display_name  )
        //
        //            }
        //            else
        //            {
        //                line = String(format: "%@,%@", line,note.display_name  )
        //
        //            }
        //
        //        }
        
        if line.isEmpty {return}
        
        //       let note = ["Notes",line]
        //        footerRows.append(note)
        
        footerRows["0Notes"] = line
    }
    
    func addProduct(line: pos_order_line_class, new_qty: Double,check_by_line:Bool,check_last_row:Bool) {
        
    }
    
    func reloadTableOrders(re_calc:Bool = false)
    {
        
    }
    //    func add_note(line:pos_order_line_class? ,  indexPath: IndexPath)
    //    {
    //
    //
    //        let storyboard = UIStoryboard(name: "notes", bundle: nil)
    //        let vc = storyboard.instantiateViewController(withIdentifier: "product_note_qty") as! product_note_qty
    //
    //
    //
    //        vc.delegate = self
    //        vc.line = line
    //        vc.order = self.order
    //
    //
    //        vc.modalPresentationStyle = .popover
    //
    //        let popover = vc.popoverPresentationController!
    //        popover.sourceView = tableview
    //        popover.sourceRect = tableview.cellForRow(at: indexPath)!.frame
    //
    //        self.present(vc, animated: true, completion: nil)
    //    }
    
    func note_added(line:pos_order_line_class?)
    {
        
        delegate?.reloadOrders(line: nil)
    }
    
    func no_notes()
    {
        
    }
    
  
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return enableEdit
    }
    
    
    func delete_Row(line:pos_order_line_class)
    {
        let indexPath = IndexPath.init(row: line.index, section: line.section)
        
        
        let alert = UIAlertController(title: "Delete".arabic("حذف"), message: "Are you sure to void this item ?".arabic("هل أنت متأكد من حذف هذا المنتج ؟"), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Void".arabic("حذف") , style: .default, handler: { (action) in
            
            self.deleteRow(line: line,indexPath: indexPath)
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".arabic("إلغاء") , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        
        self .present(alert, animated: true, completion: nil)
        
    }
    
    func edit_combo(line:pos_order_line_class)
    {
        if line.product_id == nil
        {
            return
        }
        
        self.delegate?.edit_combo(line: line)
    }
    
    func deleteRow(line:pos_order_line_class,indexPath: IndexPath)
    {
        SharedManager.shared.premission_for_void_line(line:line,vc: self) { [weak self] in
            DispatchQueue.main.async {

        guard let self = self else {return}
                if self.order.checISSendToMultisession(){
                    if !MWMasterIP.shared.checkMasterStatus(){
                        return
                    }
                }
        var void_product:pos_order_line_class! // self.order.pos_order_lines[indexPath.row]
        if line.is_combo_line == true
        {
            void_product =  self.get_line(indexPath: indexPath,get_line_parent_combo: true)
        }
        else
        {
            void_product =  self.get_line(indexPath: indexPath)
        }
        
        let line_index = self.order.pos_order_lines.firstIndex {  $0.id == void_product.id    }
        let line_section_index = self.order.section_ids.firstIndex {  $0.id == void_product.id    }

        if line_section_index != nil
        {
           // self.order.section_ids.remove(at: line_section_index!)

        }
        
        void_product.printed = .none
        void_product.is_void = true
        void_product.write_info = true
     
        
        if void_product.is_combo_line!
        {
            if void_product.selected_products_in_combo.count > 0
            {
                for combo_line in void_product.selected_products_in_combo
                {
                    combo_line.is_void = true
                    combo_line.write_info = true
                    combo_line.printed = .none
                    


                }
            }
        }
            if void_product.void_status == .before_sent_to_kitchen {
//            if !self.order.checISSendToMultisession() {
                //Save local
                void_product.pos_multi_session_status = .last_update_from_local
                self.order.pos_order_lines[line_index!] = void_product
            
                self.replace_delete_lines_promotions(line: line)
                self.order.save(write_info: true)
            }else{
                // save local and sent to ms
                void_product.pos_multi_session_status = .sending_update_to_server
                self.order.pos_order_lines[line_index!] = void_product
                self.order.save(write_info: true,updated_session_status: .sending_update_to_server)
            }
        
        
  

 
            self.reload_footer()
      
        self.order.pos_order_lines.remove(at: line_index!)
        
            self.selected_section = -1
        
        
        
            self.delete_lines_promotions_discount_total(line:line )

 
            self.tableview.reloadData()
        
        
        // Check if any lines promotion
//            self.delete_lines_promotions(line:line)
//            self.delete_lines_promotions_free(line:line )
//            self.delete_lines_promotions_discount(line:line )

            self.delegate?.reloadOrders(line: line)

            /*
            let peer = SharedManager.shared.multipeerSession()
            if peer != nil
            {
     
               let json = peer!.message?.build(order: self.order)
                peer!.send(json)
            }
             */
        }
        }

        
    }
    
    func replace_delete_lines_promotions(line:pos_order_line_class)
    {
        let rows_promotion =    promotionSelectHelper.deletePromotion(parentLine: line)
        for row in rows_promotion
        {
            let line_index = self.order.pos_order_lines.firstIndex {  $0.id == row.id    }
 
            if line_index != nil
            {
                self.order.pos_order_lines[line_index!] = row
            }
        }

    }
    
    func delete_lines_promotions_discount_total(line:pos_order_line_class)
    {
        let line_discount = self.order.get_discount_line()
        if line_discount?.pos_promotion_id != nil
        {
            line_discount!.pos_promotion_id = 0
            line_discount!.discount_program_id = 0
            line_discount!.is_void = true
            _ =  line_discount!.save(write_info: true, updated_session_status: .last_update_from_local)
            self.order.save(write_info: false, updated_session_status: .last_update_from_local, re_calc: true)
        }

    }
    
    func delete_lines_promotions(line:pos_order_line_class)
    {
        let list =  pos_order_line_class.get_line_promotions(order_id: line.order_id,_promotion_row_parent: line.id)

        for row in list
        {
            if row.discount == 0
            {
                row.is_void = true
                row.promotion_row_parent = 0
                row.pos_promotion_id = 0
                row.pos_conditions_id = 0
                _ =  row.save(write_info: true, updated_session_status: .last_update_from_local)
            }
            else
            {
                row.promotion_row_parent = 0
                row.pos_promotion_id = 0
                row.pos_conditions_id = 0
                
                row.discount = 0
                row.discount_display_name = ""
                row.discount_type = .percentage

                row.update_values()
                _ =  row.save(write_info: true, updated_session_status: .last_update_from_local)

            }
   
        }
        

    }
    
//    func delete_lines_promotions_free(line:pos_order_line_class )
//    {
//        let pos_conditions_id = "%" //line.pos_conditions_id ?? 0
//        let key = "pos_promotion|\(pos_conditions_id)|\(promotion_types.Buy_X_Get_Y_Free.rawValue)|\(order.id!)"
//        let list_pos_promotion_id = database_class().get_relations_rows(re_id2:  line.id, re_table1_table2:key )
//        
//        if list_pos_promotion_id.count > 0
//        {
//            let pos_promotion_id = list_pos_promotion_id.first
//            
//            _ =  database_class().runSqlStatament(sql: "delete from relations where re_id1 = \(pos_promotion_id!) and re_id2 = \(line.id) and re_table1_table2 like 'pos_promotion|\(pos_conditions_id)|\(promotion_types.Buy_X_Get_Y_Free.rawValue)|\(order.id!)'")
//
//            // delete line Promotion
////            promotion_helper!.delete_line_promotion(  pos_promotion_id!,order.id!)
//            
//                self.promotion_helper?.order = order
//     
//                self.promotion_helper?.line = line
//            
//               self.promotion_helper?.delegate = parent_create_order
//            
//                self.promotion_helper?.get_promotion()
//        }
//         
//     }
//    
//    
//    func delete_lines_promotions_discount(line:pos_order_line_class )
//    {
//        
//        if line.pos_promotion_id == 0 || line.pos_conditions_id == 0
//        {
//            return
//        }
// 
//            
//            _ =  database_class().runSqlStatament(sql: "delete from relations where re_id1 = \(line.pos_conditions_id!) and re_table1_table2 = 'pos_promotion|\(promotion_types.Buy_X_Get_Discount_On_Y.rawValue)|\(order.id!)'")
//
//        _ =  database_class().runSqlStatament(sql:  "update pos_order_line  set discount  = 0 , discount_display_name  = '' ,pos_promotion_id  = 0 , pos_conditions_id  = 0 , promotion_row_parent  = 0 where order_id  = \(order.id!) and pos_promotion_id = \(line.pos_promotion_id!) and pos_conditions_id = \(line.pos_conditions_id!)")
//        
//         
//                self.promotion_helper?.order = order
//     
//                self.promotion_helper?.line = line
//            
//               self.promotion_helper?.delegate = parent_create_order
//            
//                self.promotion_helper?.get_promotion()
////        }
//         
//     }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // check is return order
        //         if  order.parent_orderID != nil
        //         {
        //           return nil
        //           }
        
        var arr_action:[UITableViewRowAction] = []
        
        
        let line = get_line(indexPath: indexPath) //self.order.pos_order_lines[indexPath.row]
        if line.is_void ?? false {
            return nil
        }
        if line.is_combo_line == true
        {
            return nil
        }
        
        if show_delete_item == true
        {
            let delete = UITableViewRowAction(style: .destructive, title: "Void".arabic("حذف")) { (action, indexPath) in
                // delete item at indexPath
                
                let alert = UIAlertController(title: "Delete", message: "Are you sure to void this item ?".arabic("هل أنت متأكد من حذف هذا المنتج ؟"), preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Void".arabic("حذف") , style: .default, handler: { (action) in
                    
                    self.deleteRow(line:line,indexPath: indexPath)
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                }))
                
                
                
                alert.addAction(UIAlertAction(title: "Cancel".arabic("إلغاء") , style: .cancel, handler: { (action) in
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                }))
                
                
                
                self .present(alert, animated: true, completion: nil)
                
                
                
            }
            
            arr_action.append(delete )
            
        }
        
        
        //        let share = UITableViewRowAction(style: .normal, title: "Add note") { (action, indexPath) in
        //            // share item at indexPath
        //             product.index = indexPath.row
        //            product.section = indexPath.section
        //
        //            self.add_note(product: product , indexPath: indexPath)
        //        }
        //        share.backgroundColor = UIColor.blue
        
//        if show_edit_item == true
//        {
            if line.is_combo_line == false
            {
                let product = self.get_line(indexPath: indexPath) //self.order.pos_order_lines[indexPath.row]
                let is_open_price = product_template_class.get(id: product.product_id!)?.open_price ?? false
                if is_open_price
                {
                    let editCombo = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
               
                        product.index = indexPath.row
//                        self.delegate?.edit_combo(line: product)
//                        self.show_edit_price(sender: tableView,line_product: product)
                        self.checkOpenRule(sender:tableView,line_product:product)

                    }
                    
                    arr_action.append(editCombo)
                }
                
 
                
            }
//        }
        
        
        
        
        return arr_action
    }
    func open_edit_quantity_popup(indexPath:IndexPath){
        let line = self.get_line(indexPath: indexPath)
        let is_edit_quty = line.product.select_weight ?? false
        if is_edit_quty  {
            DispatchQueue.main.async {
            self.show_edit_qty_popup(line_product: line , self.tableview)
            }

        }
    }
    func open_price_popup_new_combo(product:pos_order_line_class){
        
        let is_open_price = product_template_class.get(id: product.product_tmpl_id!)?.open_price ?? false
        if !is_open_price {
            return
        }
        checkOpenRule(sender:self.tableview,line_product:product)

        
       
        
       // }
        
    }
    
    func open_price_popup(indexPath:IndexPath){
      //  DispatchQueue.main.async {
        let product = self.get_line(indexPath: indexPath)
        
        let is_open_price = product_template_class.get(id: product.product_tmpl_id!)?.open_price ?? false
        if !is_open_price {
            return
        }
       
        checkOpenRule(sender:self.tableview,line_product:product)
      
       // }
        
    }
    func checkOpenRule(sender:UIView,line_product:pos_order_line_class){
        rules.check_access_rule(rule_key.open_price,for:self){
            DispatchQueue.main.async {
                self.show_edit_price(sender:sender,line_product:line_product)
            }
        }
    }
    func show_edit_price(sender:UIView,line_product:pos_order_line_class)
    {
        
//        guard  rules.check_access_rule(rule_key.open_price) else {
//            return
//        }
//        
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        getBalance = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew
        getBalance.modalPresentationStyle = .popover
        getBalance.preferredContentSize = CGSize(width: 400, height: 715)
        
//        getBalance.delegate = self
        getBalance.key = "open_price"
        getBalance.title_vc = LanguageManager.text("Edit Price for unit", ar:"تعديل السعر للوحده الواحده")
        getBalance.disable = false
        
        let popover = getBalance.popoverPresentationController!
      
        popover.permittedArrowDirections = .left
        popover.sourceView = sender
        popover.sourceRect =  (sender as AnyObject).bounds
        
        
        self.present(getBalance, animated: true, completion: nil)
        
        getBalance.didSelect = {    key,value in
             
            line_product.custom_price = value.toDouble()
            line_product.update_values()
          _ =  line_product.save(write_info: true)
            
            self.order.save(write_info: true,updated_session_status: .last_update_from_local, re_calc: true)
            self.tableview.reloadData()
           self.delegate?.reloadOrders(line: nil)
            
        }
        
    }
    //edit quantity
    func show_edit_qty_popup(line_product:pos_order_line_class,_ sender: UIView)
    {
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
         getBalance = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew
        getBalance.modalPresentationStyle = .popover
        getBalance.preferredContentSize = CGSize(width: 400, height: 715)

        getBalance.key = "edit_qty"
        getBalance.title_vc =  LanguageManager.text("Enter new quantity", ar: "أدخل كمية جديدة")
        if line_product.qty != 0
        {
            getBalance.initValue  = "\(line_product.qty)"
            
        }
        getBalance.disable = false
        
        let popover = getBalance.popoverPresentationController!
        popover.permittedArrowDirections = .left
        popover.sourceView = sender
        popover.sourceRect =  sender.bounds
        
        self.present(getBalance, animated: true, completion: nil)
        getBalance.didSelect = {    key,value in
             
            line_product.qty = value.toDouble() ?? 1
            line_product.update_values()
          _ =  line_product.save(write_info: true)
            
            self.order.save(write_info: true,updated_session_status: .last_update_from_local, re_calc: true)
            self.tableview.reloadData()
           self.delegate?.reloadOrders(line: nil)
            
        }
        
    }
    
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        parent_create_order?.btnPayment.isEnabled = false
        let product = self.get_line(indexPath: indexPath) //order.pos_order_lines[indexPath.row]
        if product.is_void ?? false {
            return
        }
//        return
        if enableEdit == false
        {
            return
        }
        
        tableview.reloadData()
        tableview.selectRow(at: indexPath, animated: false, scrollPosition: .none)

        
        if selected_section != -1
        {
            selected_section = -1
//            tableview.reloadSections(IndexSet(integer:indexPath.section), with: .none)
//            tableview.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
 
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
        product.index = indexPath.row
        product.section = indexPath.section
        
        // check is return order
        //        if  order.parent_orderID != nil~
        //        {
        //           return
        //        }
        
        if product.qty < 0
        {
            messages.showAlert("You can't edit return product".arabic("لا يمكنك التعديل على مرتجع"))
            return
        }
        
        if product.is_combo_line == true && product.parent_line_id == 0
        {
            let combo_line = self.get_line(indexPath: indexPath,get_line_parent_combo: true)
            
            self.edit_combo(line: combo_line)
        }
        else if product.is_combo_line == true && product.parent_line_id != 0
        {
            //                    let combo_line = get_line(indexPath: indexPath,get_line_parent_combo: true)
            //MARK: - TODO : -  return
            return
           // self.edit_combo(line: product)
        }
        else
        {
            self.edit_combo(line: product)
            
        }
        })
 
        
    }
    
    
    
    
    class MyTapGesture: UITapGestureRecognizer {
        var section: Int?
        var line_sesction:pos_order_line_class?
        var line:pos_order_line_class?
        var view_header:order_cell_header?
    }
 
    class MyTapGestureSwipe: UISwipeGestureRecognizer {
        var section: Int?
        var line_sesction:pos_order_line_class?
        var line:pos_order_line_class?
    }
    
    
    @objc func header_click(_ sender:MyTapGesture){
        
        if sender.view_header?.offset != 0
        {
            sender.view_header!.moveCellsTo(x:0)
            return
        }
        
        if sender.line!.qty < 0
        {
            messages.showAlert("You can't edit return product".arabic("لا يمكنك التعديل على مرتجع"))
            return
        }
        
        selected_section = sender.line?.section ?? -1
        
        tableview.reloadData()
        if sender.line!.is_combo_line!
        {
            
            edit_combo(line: sender.line!)
//           tableview.reloadSections(IndexSet(integer:selected_section), with: .none)

        }
    }
    
    func setupTable(){
        tableview.sectionHeaderHeight = UITableView.automaticDimension
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 50
        tableview.estimatedSectionHeaderHeight = 68
        let headerNib = UINib.init(nibName: "order_cell_header", bundle: Bundle.main)
        tableview.register(headerNib, forHeaderFooterViewReuseIdentifier: "order_cell_header")
        tableview.register(UINib(nibName: "itemTableViewCell", bundle: nil), forCellReuseIdentifier: "itemTableViewCell")
        tableview.register(UINib(nibName: "itemTableViewCell_sec", bundle: nil), forCellReuseIdentifier: "itemTableViewCell_sec")
        tableview.reloadData()

    }
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            let line_sesction = order.section_ids[section]
            if line_sesction.is_combo_line == false
                    {
                        return 0
                    }
            return UITableView.automaticDimension
        }

//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 44
//    }
//    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        //        let line = order.pos_order_lines[section]
//        //              if line.list_product_in_combo.count > 0
//        //              {
//        //                  return 80
//        //              }
//        let line_sesction = order.section_ids[section]
//
//        if line_sesction.is_combo_line == false
//        {
//            return 0
//        }
//
//        var height:CGFloat = 65.0
//
//        if line_sesction.discount != 0
//        {
//
//            height += 20
//        }
//
//        if !(line_sesction.note ?? "").isEmpty
//        {
//            height  += 20
//        }
//
//        return height
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//          var height:Int = 60
//        var line_hight_note = 30
//
//          let line = get_line(indexPath: indexPath)//order.pos_order_lines[indexPath.row]
//
//        if line.is_combo_line == true
//        {
//            height = 44
//            line_hight_note = 20
//        }
//
//          if  line.discount != 0
//          {
//              height = height + line_hight_note
//          }
//          else
//          {
//              if !(line.discount_display_name  ?? "").isEmpty
//              {
//                  height = height + line_hight_note
//
//              }
//          }
//
//
//          if !(line.note ?? "").isEmpty
//          {
//              height = height + line_hight_note
//          }
//
//
//
//          return CGFloat(height)
//      }
      
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //        let arr = Array( order.total_product_qty.keys)
        
        return order.section_ids.count //order.pos_order_lines.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        
        let line_sesction = order.section_ids[section]
        
//        let filtered = order.pos_order_lines.filter { $0.product_id == line_sesction.product_id && $0.is_combo_line == false }
//        let filtered = order.pos_order_lines.filter { $0.id == line_sesction.id && $0.is_combo_line == false && $0.is_void == false }
        let filtered = order.pos_order_lines.filter { $0.id == line_sesction.id && $0.is_combo_line == false && ($0.void_status?.isNotVoidLogic() ?? false) }


        if filtered.count != 0
        {
            count = count + filtered.count
            
        }
        else
        {
//            let filtered_combo = order.pos_order_lines.filter { $0.id == line_sesction.id  && $0.is_void == false   }
            let filtered_combo = order.pos_order_lines.filter { $0.id == line_sesction.id  && ($0.void_status?.isNotVoidLogic() ?? false)   }

            for line in filtered_combo
            {
                let filtered_line_combo = line.selected_products_in_combo.filter { ($0.void_status?.isNotVoidLogic() ?? false)   }

                if filtered_line_combo.count > 0
                {
                    
                    count = count + filtered_line_combo.count
                }
                
            }
        }
        
        
        
        return  count
    }
    
  

    var selected_section = -1
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "order_cell_header") as! order_cell_header
        headerView.parent_create_order = parent_create_order //increase memory
//        headerView.view_header.frame.origin.x = 0
        
        let line_sesction = order.section_ids[section]
        
        let filtered = order.pos_order_lines.filter { $0.id == line_sesction.id && ($0.void_status?.isNotVoidLogic() ?? false) }
        if filtered.count > 0
        {
            let line = filtered[0]
            
            headerView.product_combo = line
            
            let product = line.product
            
            headerView.lbl_product_name.text = product?.title //+ String(line.id)

 
            
            var note_promotion = ""
            if line.discount != 0
            {
                if line.discount_type == .percentage
                {
                    if !(line.discount_display_name  ?? "").isEmpty
                    {
                        note_promotion = line.discount_display_name!

                    }
                    else
                    {
                        note_promotion  =  String( format:" With a %@ %@ discount"  , line.discount!.toIntString(),"%")
                    }

                }
                else
                {
                    if !(line.discount_display_name  ?? "").isEmpty
                    {
                        note_promotion = line.discount_display_name!

                    }
                    else
                    {
                        note_promotion  =  String( format:" With a %@ discount"  , line.discount!.toIntString() )
                    }
                    

                }
     
            }
            else
            {
                if !line.discount_display_name!.isEmpty
                {
                    note_promotion = line.discount_display_name!

                }
            }
            
            
            if line.is_combo_line!
            {
                headerView.lbl_total_qty.text = line.qty.toIntString()
                
            }
            else
            {
                headerView.lbl_total_qty.text = order.total_product_qty[line.product_id!]?.toIntString()
                //                headerView.lbl_price.text = line.price_unit?.toIntString()
            }
            
            
            if SharedManager.shared.appSetting().enable_show_price_without_tax{
                headerView.lbl_price.text =  line.price_subtotal!.toIntString()

            }else{
                headerView.lbl_price.text =  line.price_subtotal_incl!.toIntString()

            }
            

            
            
            note_promotion = (note_promotion.isEmpty) ? "" : ( note_promotion + "\n" )
            if !(line.note ?? "").isEmpty
            {
                headerView.lbl_notes.text = (line.note?.replacingOccurrences(of: "\n", with:  ","))! + "\n" + note_promotion
            }
            else
            {
                headerView.lbl_notes.text = note_promotion
            }
            
            line.section = section
            
            let click_action = MyTapGesture(target: self, action: #selector(header_click(_:)))
            click_action.section = section
            click_action.view_header = headerView
            click_action.line_sesction = line_sesction
            click_action.line = line
            
            headerView.addGestureRecognizer(click_action)
            
            
        }
        
        headerView.lbl_product_name.textColor =  #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        let bk_color = #colorLiteral(red: 0.9490190148, green: 0.9490202069, blue: 0.9748200774, alpha: 1)

        let mod = section % 2
  
        if line_sesction.isVoidFromUI() || line_sesction.qty <= 0
        {
            headerView.view_header.backgroundColor = UIColor.init(hexFromString: "#BF3F57", alpha: 0.3)
            
        }else{
            if order.isSendToMultisession(){
            if line_sesction.is_sent_to_kitchen(){
                headerView.lbl_product_name.textColor  = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
            }
            }
        if mod != 0
        {
            headerView.view_header.backgroundColor = bk_color
            line_sesction.section_color = 1
        }
        else
        {
            headerView.view_header.backgroundColor = UIColor.white
            line_sesction.section_color = 0

            
        }
        }
        
        
        if selected_section == section
        {
            headerView.view_header.backgroundColor =  UIColor.init(hexFromString: "#D1D1D6", alpha: 1.0)
        }
        
       
        
          order.section_ids[section] = line_sesction
          headerView.lbl_notes.isHidden = (headerView.lbl_notes.text?.isEmpty ?? true)

    
        
 
        return headerView
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! itemTableViewCell
        var product =  get_line(indexPath: indexPath)//order.pos_order_lines[indexPath.row]
        
        var identifier = "itemTableViewCell_sec"
        if product.is_combo_line == true
        {
            product =  get_line(indexPath: indexPath,get_line_parent_combo: false)
            identifier = "itemTableViewCell"
        }
        
        
        var cell: itemTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? itemTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? itemTableViewCell
        }
        
        //        let product = productClass(fromDictionary: obj as! [String : Any])
        
        //        let index = indexPath.row //+  indexPath.section
        //        if product.is_combo_line!
        //        {
        ////            index = indexPath.section
        //            let is_use_extra_price = check_combo_have_extra_price(indexPath: indexPath)
        //            if is_use_extra_price == false
        //            {
        //                      product =  get_line(indexPath: indexPath,get_line_parent_combo: true)
        //            }
        //        }
        
        
        cell.product = product
        cell.priceList = priceList
        
        cell.updateCell()
        
        cell.lblTitle.textColor  =  #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        let bk_color = #colorLiteral(red: 0.9490190148, green: 0.9490202069, blue: 0.9748200774, alpha: 1)
        let mod = indexPath.section % 2
        
        if mod != 0
        {
    
            cell.backgroundColor =   bk_color
        }
        else
        {
            cell.backgroundColor = UIColor.white
            
            
        }
        if product.isVoidFromUI()  || product.qty <= 0
        {
            //MARK: If the product is "Delivery Charge" but it's voided, then remove it.
            if product.product.title == "Delivery Charge" {
                if let indexToRemove = order.pos_order_lines.firstIndex(where: { $0 === product }) {
                    order.pos_order_lines.remove(at: indexToRemove)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [IndexPath(row: indexToRemove, section: indexPath.section)], with: .fade)
                    tableView.endUpdates()
                    return UITableViewCell()
                }
            } else {
                if SharedManager.shared.appSetting().enable_hide_void_before_line {
                    if product.void_status == .before_sent_to_kitchen {
                        if let indexToRemove = order.pos_order_lines.firstIndex(where: { $0 === product }) {
                            order.pos_order_lines.remove(at: indexToRemove)
                            tableView.beginUpdates()
                            tableView.deleteRows(at: [IndexPath(row: indexToRemove, section: indexPath.section)], with: .fade)
                            tableView.endUpdates()
                            return UITableViewCell()
                        }
                    } else {
                        //MARK: If the product is not "Delivery Charge" but is voided, just color it.
                        cell.backgroundColor = UIColor.init(hexFromString: "#BF3F57", alpha: 0.3)
                    }
                } else {
                    //MARK: If the product is not "Delivery Charge" but is voided, just color it.
                    cell.backgroundColor = UIColor.init(hexFromString: "#BF3F57", alpha: 0.3)
                }
            }
            
        }else{
            if order.isSendToMultisession(){
            if product.is_sent_to_kitchen(){
                //#colorLiteral(red: 0.9999127984, green: 1, blue: 0.9998814464, alpha: 1)
                cell.backgroundColor = mod == 0 ? UIColor.white : bk_color
//                cell.backgroundColor =  #colorLiteral(red: 0.3019607843, green: 0.7450980392, blue: 0.4549019608, alpha: 1).withAlphaComponent(0.3)
                cell.lblTitle.textColor  =   #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)

            }
            }
        }
 
        return cell
    }
    
    func check_combo_have_extra_price(indexPath: IndexPath)-> Bool
    {
        let line_sesction = order.section_ids[indexPath.section]
        let filtered = order.pos_order_lines.filter { $0.id == line_sesction.id   }
        if filtered.count > 0
        {
            let line = filtered[0]
            let filtered_combo = line.selected_products_in_combo.filter {  $0.extra_price != 0 }
            if filtered_combo.count > 0
            {
                return true
                
            }
        }
        
        return false
    }
    
    func get_line(indexPath: IndexPath,get_line_parent_combo:Bool  = false) -> pos_order_line_class
    {
        var sec = indexPath.section
        if sec > order.section_ids.count
        {
            sec = order.section_ids.count - 1
        }
        
        // check combo
        let line_sesction = order.section_ids[sec]
//        let filtered = order.pos_order_lines.filter { $0.id == line_sesction.id  && $0.is_void == false }
        let filtered = order.pos_order_lines.filter { $0.id == line_sesction.id   }

        
        let line = filtered[0]
        
        if get_line_parent_combo == true
        {
            return line
        }
        
        let filtered_line_combo = line.selected_products_in_combo.filter { ($0.void_status?.isNotVoidLogic() ?? false)   }

        if filtered_line_combo.count > 0
        {
            var row =  indexPath.row
//            let sec =  indexPath.section

//            line.list_product_in_combo.sort{  $0.product_id! < $1.product_id!  }
           line.selected_products_in_combo = filtered_line_combo.sorted(by: {$0.id < $1.id})

            if row > filtered_line_combo.count - 1
            {
                row = filtered_line_combo.count - 1
            }
 
            return filtered_line_combo[row]
        }
        
        
        // check normal
//        filtered = order.pos_order_lines.filter { $0.product_id == line_sesction.product_id  }
//        line = filtered[indexPath.row]
        
        
        return line
    }
    
    func keyboard_returnedValue(Qty:Double,Disc:Double,price:Double,customPrice:Bool,item_indexPath_selected:IndexPath)
    {
        
       SharedManager.shared.printLog("Qty :\(Qty)" + "Disc :\(Disc)" + "price :\(price)"  )
        
        let product =  get_line(indexPath: item_indexPath_selected ) // order.pos_order_lines[item_indexPath_selected.row]
//        product.discount_program_id =
        product.discount = Disc
        product.price_unit! = price
        
        if product.custome_price_app == false
        {
            product.custome_price_app = customPrice
            
        }
        
        
        // in Return
        if product.max_qty_app != nil
        {
            
            if product.max_qty_app! < 0.0
            {
                
                
                if  abs(Qty)  <=  abs(product.max_qty_app!)
                {
                    
                    if  Qty == 0
                    {
                        product.qty =  -1
                    }
                    else
                    {
                        product.qty = abs(Qty) * -1
                        
                    }
                    
                    
                }
                else
                {
//                    keyboard.Qty = product.max_qty_app!
//                    keyboard.in_start = true
                    
                    if parent_vc != nil
                    {
                        printer_message_class.show("Qty larger than orgianl qty", vc: parent_vc!)
                        
                    }
                }
            }
            else
            {
                product.qty = abs(Qty) * -1
                
            }
        }
        else
        {
            product.qty = Qty
            
        }
        
        
        product.update_values()
        product.write_info = true
        product.kitchen_status = .send
        product.pos_multi_session_status = .last_update_from_local
        
        let line_index = self.order.pos_order_lines.firstIndex {  $0.id == product.id    }
        
        
        order.pos_order_lines[line_index!] = product
        
        //        get_line_notes()
        
        
        
        
        order.save(write_info: true)
        
        reload_footer()
        
        guard item_indexPath_selected.row <  self.tableview.numberOfRows(inSection: item_indexPath_selected.section)  else {return}

        tableview.reloadRows(at: [item_indexPath_selected], with: .fade)
        tableview.selectRow(at: item_indexPath_selected, animated: false, scrollPosition: .none)
        
        delegate?.reloadOrders(line:product)
        
    }
    
    
    
    //     func get_line_notes()
    //     {
    //
    //        if keyboard.note_vc?.line != nil
    //        {
    //            let line_note = keyboard.note_vc?.line
    //
    //            let temp = self.order.pos_order_lines[(line_note?.index)!]
    //              temp.note = line_note?.note
    //
    //               self.order.pos_order_lines[(line_note?.index)!] = temp
    //        }
    //
    ////                     self.order.save(write_info: true,updated_session_status: .last_update_from_local)
    //    }
    
    
}


protocol  order_listVc_delegate:class {
    
    func reloadOrders(line:pos_order_line_class?)
    func edit_combo(line:pos_order_line_class)
}
