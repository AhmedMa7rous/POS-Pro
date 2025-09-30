//
//  products.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
import UIKit
typealias products = create_order
extension products :UICollectionViewDataSource ,UICollectionViewDelegate,promotion_helper_delegate,UIGestureRecognizerDelegate,combo_vc_delegate, UICollectionViewDelegateFlowLayout
{
 
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.list_product_search.count
        
    }
    
    //3
    func collectionView(  _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath  ) -> UICollectionViewCell {
        let reuseIdentifier = "FlickrCell"
        let cell = collectionView  .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! homeCollectionViewCell
        //        cell.backgroundColor = .lightGray
        // Configure the cell
        
        let obj = self.list_product_search[indexPath.row]
        
        let product = product_product_class(fromDictionary: obj as! [String : Any])
        
        
        cell.priceList = self.priceListVC.selectedItem
        cell.product = product
        
        
        cell.updateCell()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if SharedManager.shared.appSetting().prevent_new_order_if_empty {
            if !pos_order_class.checkIfSessionHaveEmptyOrder() {
                createNewOrderWhenSelectProduct(for: indexPath)
            } else if self.orderVc?.order.id != nil{
                createNewOrderWhenSelectProduct(for: indexPath)
            } else {
                SharedManager.shared.initalBannerNotification(title:  "Not Allowed".arabic("غير مسموح"), message: "Can't Add new order. current order is empty".arabic("لا يمكنك انشاء طلب جديد والطلب الحالي مازال فارغ"), success: false, icon_name: "icon_error")
                SharedManager.shared.banner?.dismissesOnTap = true
                SharedManager.shared.banner?.show(duration: 3)
            }
        } else {
            createNewOrderWhenSelectProduct(for: indexPath)
        }
        
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.bounds.width / 5, height: 150)
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            let totalSpacing = layout.minimumInteritemSpacing * (5 - 1) // for 5 items, there are 4 spacings
            let totalInsets = layout.sectionInset.left + layout.sectionInset.right

            let width = (collectionView.bounds.width - totalSpacing - totalInsets) / 5
            return CGSize(width: width, height: 150)
        }

        // Fallback in case layout is not UICollectionViewFlowLayout
        return CGSize(width: collectionView.bounds.width / 5, height: 150)
    }
    func showAlertRequestQuantity(_ collectionView: UICollectionView,for indexPath:IndexPath,complete:()->()){
        //TODO: - show make stock request
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! homeCollectionViewCell
        if !cell.needToRequesStock{
            complete()
            return
        }
        let alert = UIAlertController(title: "Reached max product available quantity".arabic("تم الوصول إلى الحد الأقصى للكمية المتاحة للمنتج"), message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Request quantity".arabic("طلب الكمية") , style: .destructive, handler: { (action) in
            if var productCell = cell.product{
                let vm = ProductAvaliablityVM()
                vm.selectCategoryID = productCell.pos_categ_id
                vm.selectCategoryName = productCell.pos_categ_name
                if vm.setProductsData(){
                    let vc = ProductAvaliablityRouter.createProductAvaliablityModule(vm:vm) {
                        DispatchQueue.main.async {
                        self.collection.reloadData()
                        }
                    }
                    vc.modalPresentationStyle = .fullScreen
                    /*
                     let vc = CreateStockRequestVC.createModule(completeHandler: {
                     //TODO: - update cells
                     DispatchQueue.main.async {
                     self.collection.reloadData()
                     }
                     
                     },.pageSheet,productRequest:productCell )
                     */
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel".arabic("إلغاء"), style: .cancel, handler: { (action) in
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addProduct(_ product: [String : Any] , _ row:Int )  {
        if self.orderVc?.order.id == nil  {
            addNewOrder {
                self.completeAddProduct(product, row)
            }
        }else{
            if let order = self.orderVc?.order {
            if  order.is_send_toKDS() || order.isSendToMultisession()
            {
                rules.check_access_rule(rule_key.edit_after_sent_to_kitchen,for: self){
                    DispatchQueue.main.async {
                        self.completeAddProduct( product, row)
                        return
                    }
                }
                return
            }
        }
        self.completeAddProduct(product, row)
        }
       
    }
    func completeAddProduct(_ product: [String : Any] , _ row:Int )  {
        let ptemp = product_product_class(fromDictionary: product )
 
        if self.orderVc?.order.id == nil  {
            addNewOrder(complete: {
                self.completeAddProduct(ptemp,row:row)
            })
        }else{
            self.completeAddProduct(ptemp,row:row )
        }
       
    }
    
    func createNewOrderWhenSelectProduct(for indexPath: IndexPath) {
        SharedManager.shared.updateLastActionDate()
        // check is return order
        //        if   orderVc?.order.parent_order_id != 0
        //        {
        //            return
        //        }
        
        
        self.view.endEditing(true)
        self.showAlertRequestQuantity(collection, for: indexPath) {
            let obj = self.list_product_search[indexPath.row]
            
            
            self.countProductsNeedToAdded += 1
            addProduct(obj as! [String : Any],indexPath.row)
            self.countProductsNeedToAdded -= 1
            if self.countProductsNeedToAdded < 0 {
                self.countProductsNeedToAdded = 0
            }
        }
    }
    
    func completeAddProduct(_ ptemp:product_product_class,row:Int ){
        let section = 0

        if self.orderVc?.order.table_id == nil ||  self.orderVc?.order.table_id == 0{
            if let selectedTable =  self.orderVc?.selectedTableFomIcon  {
                self.selectedTable(selectedTable: selectedTable)
                self.orderVc?.selectedTableFomIcon = nil
            }
        }
        
        
        if self.orderVc!.order.is_return()
        {
            printer_message_class.show("You can't edit this return order.".arabic("لا يمكنك التعديل على هذا المرتجع"))
            return
        }
        
        if ptemp.is_combo == true
        {
            //            let line = pos_order_line_class.get_or_create(order_id: orderVc?.order.id!, product: ptemp)
            let line = pos_order_line_class.create(order_id: (orderVc?.order.id!)!, product: ptemp)
            line.section = section
            line.index = row
            

            show_combo(line: line,isEdit: false)
            
            return
        }
        else if ptemp.variants_count > 1 && ptemp.is_combo == false
        {
            let line = pos_order_line_class.create(order_id: (orderVc?.order.id!)!, product: ptemp)
             line.section = section
             line.index =  row
            
 
            show_combo(line: line,isEdit: false)
            
              
            return
        }
        if SharedManager.shared.appSetting().enable_local_qty_avaliblity {
            ptemp.updateQtyAvaliable(with: .MINS) { newAvaliableQty in
                SharedManager.shared.printLog("newAvaliableQty = \(newAvaliableQty)")
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        self.collection.reloadData()
                    }
                }
            }
        }
           
//        var line = pos_order_line_class.get_or_create(order_id: orderVc?.order.id!, product: ptemp)
            
        var line = pos_order_line_class.create (order_id: (orderVc?.order.id!)!, product: ptemp)

        
        
        line =  add_product(line: line,check_by_line:false,check_last_row:true)
           
        handle_promotion(line: line)
        let indexPathLine = IndexPath(row: line.index, section: line.section)
        DispatchQueue.global(qos: .background).async{
        self.orderVc?.open_edit_quantity_popup(indexPath: indexPathLine)
        self.orderVc?.open_price_popup(indexPath: indexPathLine)
        }

        newBannerHolderview.setEnableNewOrder(with: true)
        NSLog("add")
    }
    func addProduct(with d1BarCodeModel:D1BarCodeModel){
        var ptemp:product_product_class?
        var qty:Double = 1
        var stopCheck:Bool = false
        if let barode = d1BarCodeModel.d1barcode{
            ptemp = product_product_class.get(barcode: barode)
        }
        if ptemp == nil {
            if let id = d1BarCodeModel.productID{
                ptemp = product_product_class.get(barcode: "\(id)")
                if let weight = d1BarCodeModel.weight{
                    qty = weight
                    stopCheck = true
                }
            }
        }
        guard let ptemp = ptemp else {
            showToastMessage(title:"Wrong barcode".arabic(" باركود خاطئ"),Message:"Wrong barcode, please check barcode".arabic("رمز شريطي خاطئ ، يرجى التحقق من الرمز الشريطي"))
            return
        }
        if self.orderVc?.order.id == nil  {
            addNewOrder {
                self.completeAddProductBar(with:d1BarCodeModel,ptemp:ptemp,stopCheck:stopCheck,qty:qty)
            }
        }else{
            self.completeAddProductBar(with:d1BarCodeModel,ptemp:ptemp,stopCheck:stopCheck,qty:qty)
        }
     

    }
        
        
    
    func completeAddProductBar(with d1BarCodeModel:D1BarCodeModel,ptemp:product_product_class,stopCheck:Bool,qty:Double){
        if self.orderVc?.order.table_id == nil ||  self.orderVc?.order.table_id == 0{
            if let selectedTable =  self.orderVc?.selectedTableFomIcon  {
                self.selectedTable(selectedTable: selectedTable)
                self.orderVc?.selectedTableFomIcon = nil
            }
        }
        
        
        if self.orderVc!.order.is_return()
        {
            printer_message_class.show("You can't edit this return order.".arabic("لا يمكنك التعديل على هذا المرتجع"))
            return
        }
        if (ptemp.is_combo == true) ||
            ( ptemp.variants_count > 1 && ptemp.is_combo == false)
        {
            return
        }
        var line = pos_order_line_class.create (order_id: (orderVc?.order.id!)!, product: ptemp)
       // line.qty = qty
        line =  add_product(line: line,new_qty: qty,check_by_line:false,check_last_row:true,stop_check: stopCheck)
        handle_promotion(line: line)
        newBannerHolderview.setEnableNewOrder(with: true)
    }
    
    func showToastMessage(title:String,Message:String,isSucess:Bool = false,image:String = "icon_error"){
        DispatchQueue.main.async {
        SharedManager.shared.initalBannerNotification(title: "Wrong barcode".arabic(" باركود خاطئ") ,
                                                      message: "Wrong barcode, please check barcode".arabic("رمز شريطي خاطئ ، يرجى التحقق من الرمز الشريطي"),
                                                      success: isSucess, icon_name: image)
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
    }

    }
 
    
 
    
    @objc  func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        
        if (gestureRecognizer.state != UIGestureRecognizer.State.ended){
            return
        }
        
        let p = gestureRecognizer.location(in: self.collection)
        
        if let indexPath = self.collection.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            //             let cell = self.collection.cellForItem(at: indexPath)
            
            
            let obj = list_product_search[indexPath.row]
            let ptemp = product_product_class(fromDictionary: obj as! [String : Any])
            
            
            let info = product_info()
            info.product = ptemp
            
            
            info.modalPresentationStyle = .popover
            
            
            
            let popover = info.popoverPresentationController!
            //        popover.delegate = self
            popover.permittedArrowDirections = .any //UIPopoverArrowDirection(rawValue: 0)
            popover.sourceView = self.collection
            
             let v =  self.collection.cellForItem(at: indexPath)
             if v != nil
             {
                popover.sourceRect = v!.frame

            }
            
            
            self.present(info, animated: true, completion: nil)
            
            
            // do stuff with the cell
        } else {
           SharedManager.shared.printLog("couldn't find index path")
        }
        
    }
    
    func newCompleteComboHandler(_ line:pos_order_line_class?,_ orginQty:Double?){
        guard let line = line else { return  }
        SharedManager.shared.printLog(self.orderVc?.selected_section)
        SharedManager.shared.printLog(line.section)
        SharedManager.shared.printLog(line.qty)

            
        if  priceListVC.selectedItem != nil
        {
            line.priceList = priceListVC.selectedItem
        }
        else
        {
            line.priceList = self.orderVc?.order.priceList
        }
        
        line.update_values()
        DispatchQueue.main.async {

        if line.id != 0 {
            if let indexLine = self.orderVc?.order.pos_order_lines.firstIndex(where: {$0.uid == line.uid}){
                self.orderVc?.order.pos_order_lines[indexLine] = line
                self.orderVc?.order.applyPriceList(for:indexLine)
                
            }
            if let indexSection =  self.orderVc?.order.section_ids.firstIndex(where: {$0.uid == line.uid}){
                self.orderVc?.order.section_ids[indexSection] = line
                
            }
            line.printed = .none
            let _ = line.save(write_info: true,
                      updated_session_status:.last_update_from_local,
                      kitchenStatus:kitchen_status_enum.none)

            
            
            //            _ =  saveProduct(line: line , rowIndex: line.section,printed: .none)
        }else{
            if !(line.is_void ?? false) {
                self.addProduct(line:line , new_qty: line.qty , check_by_line: false, check_last_row: false, stop_check: true)
               //Not need to append new line as add product append it
               // self.orderVc?.order.pos_order_lines.append(line)


            }
          
        }
            //TODO: -
            if let ptemp = line.product{
                var addQty = line.qty
                if let orginQty = orginQty{
                    addQty = line.qty - orginQty
                }
                var operation = OPERATION_QTY_TYPES.MINS
                
                if addQty < 0 {
                    operation = .PLUS
                }else if addQty > 0{
                    operation = .MINS
                }
                ptemp.updateQtyAvaliable(by:abs(addQty) , with: operation) { newAvaliableQty in
                    SharedManager.shared.printLog("newAvaliableQty = \(newAvaliableQty)")
                    DispatchQueue.main.async {
                        self.collection.reloadData()
                    }
                }
            }
            self.orderVc?.order.save( write_date: false, updated_session_status: .last_update_from_local, re_calc: true)
            SharedManager.shared.printLog("line.write_date ==2== \(line.write_date)")
            SharedManager.shared.printLog("lorder.write_date ===2= \(self.orderVc?.order.write_date)")
            self.orderVc?.reload_tableview()
            self.reloadTableOrders(re_calc: true)

            self.orderVc?.reload_footer()

        }
        DispatchQueue.global(qos: .background).async{
        self.orderVc?.open_price_popup_new_combo(product: line)
        }
        newBannerHolderview.setEnableNewOrder(with: true)
    }
    func show_combo(line:pos_order_line_class,isEdit:Bool)
    {
        
//        let storyboard = UIStoryboard(name: "combo", bundle: nil)
//        comboList_ver2 = storyboard.instantiateViewController(withIdentifier: "combo_list_ver2") as? combo_list_ver2
//        comboList_ver2.modalPresentationStyle = .fullScreen
//        comboList_ver2.product_combo = line // product!.product_combo_ids!
//        comboList_ver2.product_combo?.combo_edit = isEdit
//        comboList_ver2.delegate = self
//        comboList_ver2.order_id = orderVc?.order.id
//
//        self.present(comboList_ver2, animated: true, completion: nil)
        //DispatchQueue.main.async { // case done not close and + - qty not work
            
        
//        if self.comboList != nil
//        {
//            self.comboList.view.removeFromSuperview()
//            self.comboList = nil
//        }
        self.clear_right()
        if SharedManager.shared.newCombo{
            if line.is_void ?? false {
                return
            }
            let newComboVC = MWComboRouter.createModule(multiProductObject: MultiProductObject(from: line),orderVc:self.orderVc,completeHandler:newCompleteComboHandler )
            let viewCombo = newComboVC.view
            guard let viewCombo = viewCombo else {return}
            viewCombo.frame = self.right_view.bounds
            
            newComboVC.willMove(toParent: self)
            self.right_view.addSubview( viewCombo)
            self.addChild(newComboVC)
            newComboVC.didMove(toParent: self)
            

        }else{
            let storyboard = UIStoryboard(name: "create_order", bundle: nil)
            self.comboList = storyboard.instantiateViewController(withIdentifier: "combo_vc") as? combo_vc
            //                comboList_ver2.modalPresentationStyle = .fullScreen
            self.comboList.product_combo = line // product!.product_combo_ids!
            self.comboList.product_combo?.combo_edit = isEdit
            self.comboList.delegate = self
            self.comboList.order_id = self.orderVc?.order.id
            self.comboList.parent_create_order = self
            self.comboList.fristShow = !isEdit
            
            
            self.comboList.view.frame = self.right_view.bounds

            self.right_view.addSubview( self.comboList.view)
            self.comboList.init_combo()


//            self.comboList.view.frame = self.right_view.bounds
        }
       


       // }
        
//        if isEdit == false
//        {
//
//            if line.is_combo_line == true
//            {
//                comboList.combo_done(false)
//
//            }
//            else
//            {
//                comboList.product_done(false)
//            }
//
//            comboList.product_combo?.combo_edit = true
//        }
          
     }
    
    func edit_combo(line:pos_order_line_class)
    {
        if let order = self.orderVc?.order {
            if  line.is_send_toKDS() || line.isSendToMultisession()
            {
                rules.check_access_rule(rule_key.edit_after_sent_to_kitchen,for: self){
                    DispatchQueue.main.async {
                        self.show_combo(line: line,isEdit: true)
                        return
                    }
                }
                return
            }
        }
        show_combo(line: line,isEdit: true)
        
    }
    
    
    func deleteProductt(line:pos_order_line_class )
    {
        let indexPath = IndexPath.init(row: line.index, section: line.section)

        orderVc?.deleteRow(line: line,indexPath: indexPath )
    }
    
    func addProduct(line:pos_order_line_class,new_qty:Double,check_by_line:Bool ,check_last_row:Bool ,stop_check:Bool )
    {
        _ = add_product(line: line,new_qty: new_qty,check_by_line:check_by_line,check_last_row:check_last_row,stop_check:stop_check)
    }
    
    func add_product(line:pos_order_line_class,new_qty:Double = 0,check_by_line:Bool,check_last_row:Bool,printed:ptint_status_enum = .none,stop_check:Bool = false) -> pos_order_line_class
    {
        var new_line = line
        
     
        var rowIndex =  -1
        
        if stop_check == false
        {
            if let order_vc = self.orderVc{
            rowIndex =   order_vc.order.checkProductExist(line: line,check_by_line:check_by_line,check_last_row:check_last_row)
            }
        }
      
        
        
        if rowIndex == -1
        {
            if  new_qty == 0
            {
                line.qty  = 1
            }
            else
            {
                line.qty = new_qty
            }
            
            line.discount = 0
            
            
            line.id = 0
            
            new_line =  saveProduct(line: line , rowIndex: -1,printed: printed)
            
            
//            new_line =  saveProduct(line: line , rowIndex: rowIndex)
//             let section = line.section // get_section_product(product_id: p.product_id!)
//             let row = IndexPath.init(row: rowIndex, section: section)
//             orderVc?.tableview.selectRow(at: row, animated: true, scrollPosition: .middle)
            
//               let last_section = orderVc?.order.section_ids.count - 2
//                orderVc?.tableview.reloadRows(at: [IndexPath.init(row: count, section: 0)], with: UITableView.RowAnimation.bottom)
//            orderVc?.tableview.reloadData()
//             orderVc?.tableview.selectRow(at: IndexPath.init(row: 0, section: last_section), animated: true, scrollPosition: .bottom)
            
        }
        else
        {
            guard let order_vc = self.orderVc else {
                return new_line
            }
            let old_line = order_vc.order.pos_order_lines[rowIndex]
            
            if old_line.pos_multi_session_status == .sended_update_to_server
               {
            old_line.last_qty = old_line.qty
            }
            
            
            if line.id == 0
            {
                    old_line.qty += 1
            }
            else
            {
                if new_qty == 0
                          {
                              old_line.qty += 1
                          }
                          else
                          {
                              old_line.qty  = new_qty
                          }
            }
          
            
             
            _ =  saveProduct(line: old_line , rowIndex: rowIndex,printed: printed)

            return old_line
            
//            orderVc?.tableview.reloadData()

//            orderVc?.tableview.reloadRows(at: [IndexPath.init(row: rowIndex, section: 0)], with: UITableView.RowAnimation.middle)
//            orderVc?.tableview.selectRow(at: IndexPath.init(row: rowIndex, section: 0), animated: true, scrollPosition: .middle)
//
            
//            new_line =  saveProduct(line: line , rowIndex: rowIndex)
//            let section = line.section // get_section_product(product_id: p.product_id!)
//            let row = IndexPath.init(row: rowIndex, section: section)
//            orderVc?.tableview.selectRow(at: row, animated: true, scrollPosition: .middle)

         }
        
    
        
        
        return new_line
    }
    
    func select_last_row( )
    {
        if let order_vc = self.orderVc{
        var last_section = (order_vc.order.section_ids.count ) - 1
        if last_section < 0
        {
            last_section = 0
        }
        
        let rows = order_vc.tableview.numberOfRows(inSection: last_section)
 
        if  order_vc.tableview.numberOfSections >  last_section && rows > 0
        {
            let indexPath = IndexPath.init(row: 0, section: last_section)
            guard indexPath.row <  self.orderVc?.tableview.numberOfRows(inSection: indexPath.section) ?? 0 else {return}
            self.orderVc?.tableview.selectRow(at: indexPath , animated: true, scrollPosition: .bottom)
        }
        }
    }
    
    
    func select_row(section:Int )
    {
        if let order_vc = self.orderVc{

        let sec = order_vc.tableview.numberOfSections
        if sec > section
        {
            let rows = order_vc.tableview.numberOfRows(inSection: section)
                if   (rows > 0)
                {
                    let indexPath = IndexPath.init(row: 0, section: section)
                    guard indexPath.row <  self.orderVc?.tableview.numberOfRows(inSection: indexPath.section) ?? 0 else {return}

                    order_vc.tableview?.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                    
                }
        }
        }
    }
    
    func handle_promotion(line:pos_order_line_class?)
    {
        guard let _ = orderVc!.order.orderType else {return}
        if line == nil
        {
            return
        }
        
        if pos_promotion_class.getAll().count > 0 {
 
            var pos_promotion_id = line!.pos_promotion_id
            if line!.promotion_row_parent == line!.id
            {
                pos_promotion_id = promotionSelectFilter.getPromotionId(promotion_row_parent: line!.promotion_row_parent!, order_id: line!.order_id)
            }
            
            let filter = promotionSelectFilter(_product_id: line!.product_id!,_podId: orderVc!.order.pos_id!,_orderType: orderVc!.order.orderType!.id,_promotion_id: pos_promotion_id)
            
            if !orderVc!.order.promotion_code.isEmpty
            {
                filter.filter_code =  orderVc!.order.promotion_code
                filter.required_code = true
            }
            
            let lst = filter.getAvailablePromotions()
            if lst.count != 0
            {
                  
            let storyboard = UIStoryboard(name: "promotionSelect", bundle: nil)
            let promotion = storyboard.instantiateViewController(withIdentifier: "promotionSelect") as! promotionSelect
            promotion.modalPresentationStyle = .formSheet
            promotion.preferredContentSize = CGSize(width: 783, height: 627)

            promotion.parent_line = line
            promotion.order = orderVc!.order
            
            promotion.filter = filter
            promotion.list_promotions.append(contentsOf: lst)
                

            promotion.didSelect = {   lines, promotionType in
                if lines.count > 0
                {
                    
                    if promotionType == .Fix_Discount_on_Quantity || promotionType == .Percent_Discount_on_Quantity
                    {
                        promotion.parent_line = lines.first
                        
                        if promotion.parent_line.pos_promotion_id != 0
                        {
                            promotion.parent_line.is_promotion = true

                        }
                        else
                        {
                            promotion.parent_line.is_promotion = false

                        }
 
                        self.saveProductPromotion(line: promotion.parent_line,parent_line: nil)

                    }
                    else
                    {
                        for row in lines
                        {
                            self.saveProductPromotion(line: row,parent_line: line)

                        }
                         
                    }
                    
                    
                    self.reloadTableOrders(re_calc: true,reSave: true)
                    
                    
 
                    self.orderVc?.selected_section = -1
                   self.orderVc?.tableview.reloadData()
//                    self.orderVc?.reloadTableOrders()
//                    self.reloadTableOrders()

                }
                 
             }
                
           
            
            self.present(promotion, animated: true, completion: nil)
            }
        }
  
         

    }
    
    
    func resetPromotion()
    {
        if !(orderVc?.order.promotion_code ?? "").isEmpty {
           self.cancel_discount()
        } else {
            orderVc!.order =  promotionSelectHelper.deletePromotionInOrder(order: orderVc!.order)
        }
        
        self.reloadTableOrders(re_calc: true,reSave: true)
        
        

        self.orderVc?.selected_section = -1
       self.orderVc?.tableview.reloadData()
        
//        orderVc!.order =  promotionSelectHelper.deletePromotionInOrder(order: orderVc!.order)
//        
//        self.reloadTableOrders(re_calc: true,reSave: true)
//        
//        
//
//        self.orderVc?.selected_section = -1
//       self.orderVc?.tableview.reloadData()
//        self.orderVc?.reloadTableOrders()
//        self.reloadTableOrders()

    }
    
    func setParentPromotion(_ parent_line:pos_order_line_class?,isPromotion:Bool )
    {
        if parent_line == nil
        {
            return
        }
            
            
        if isPromotion == false
        {
            parent_line!.is_promotion = false
            parent_line!.promotion_row_parent = 0
        }
        else
        {
            parent_line!.promotion_row_parent = parent_line!.id
            parent_line!.is_promotion = true
        }
        
        if parent_line != nil
        {
          
            
            let index:Int = self.orderVc?.order.pos_order_lines.firstIndex(where: {$0.id == parent_line!.id}) ?? -1
            if index != -1
            {
                self.orderVc?.order.pos_order_lines[index] = parent_line!
            }
        }
        
    }
    func saveProductPromotion(line:pos_order_line_class ,parent_line:pos_order_line_class? )
    {
        if  priceListVC.selectedItem != nil
        {
            line.priceList = priceListVC.selectedItem
        }
        else
        {
            line.priceList = self.orderVc?.order.priceList
        }
        
        line.pos_multi_session_status = .last_update_from_local
        line.write_info = true
        line.kitchen_status = .send
        line.printed = .none
        
        let index:Int = self.orderVc?.order.pos_order_lines.firstIndex(where: {$0.id == line.id}) ?? -1
        if index != -1
        {
            var updateLine =  self.orderVc?.order.pos_order_lines[index]

            if line.is_promotion == false && line.pos_promotion_id == 0 // removed premotion
            {
                updateLine!.discount_program_id = 0
                updateLine!.discount_type = .fixed
                updateLine!.discount = 0
                updateLine!.promotion_row_parent = 0
                updateLine!.pos_promotion_id = 0
                updateLine!.pos_conditions_id = 0
                updateLine!.is_promotion = false
                updateLine!.discount_display_name = ""
                updateLine!.update_values()
                
               setParentPromotion(parent_line, isPromotion: false)

            }
            else
            {
                line.update_values()
                updateLine = line
                
                setParentPromotion(parent_line, isPromotion: true)

            }
            
          
            
            
            self.orderVc?.order.pos_order_lines[index] = updateLine!
        self.orderVc?.order.applyPriceList(for:index)
        }
        else
        {
            setParentPromotion(parent_line, isPromotion: true)

            line.update_values()

            self.orderVc?.order.pos_order_lines.append(line)
            
            self.orderVc?.order.section_ids.append(line)
             line.section = (self.orderVc?.order.section_ids.count ?? 0 ) - 1
            self.orderVc?.order.applyPriceList(for:(self.orderVc?.order.pos_order_lines.count ?? 0) - 1)
        }
        
   

    }
    
    func saveProduct(line:pos_order_line_class,rowIndex:Int ,forceSave:Bool = false  )
    {
     _ =   saveProduct(line: line, rowIndex: rowIndex, printed: .none,forceSave: forceSave)
    }
    
    func saveProduct(line:pos_order_line_class,rowIndex:Int,printed:ptint_status_enum = .none,forceSave:Bool = false) -> pos_order_line_class
    {
        if  priceListVC.selectedItem != nil
        {
            line.priceList = priceListVC.selectedItem
        }
        else
        {
            line.priceList = self.orderVc?.order.priceList
        }

        line.update_values()
        line.pos_multi_session_status = .last_update_from_local
        line.write_info = true
        line.kitchen_status = .send
        line.printed = printed
        
        if forceSave
        {
            let index:Int = self.orderVc?.order.pos_order_lines.firstIndex(where: {$0.id == line.id}) ?? -1
            if index != -1
            {
            self.orderVc?.order.pos_order_lines[index] = line
            self.orderVc?.order.applyPriceList(for:index)
            }
        }
        else
        {
        if rowIndex == -1
        {
            self.orderVc?.order.pos_order_lines.append(line)
            
            self.orderVc?.order.section_ids.append(line)
             line.section = (self.orderVc?.order.section_ids.count ?? 0 ) - 1
            self.orderVc?.order.applyPriceList(for:(self.orderVc?.order.pos_order_lines.count ?? 0) - 1)
        }
        else
        {

            let index:Int = self.orderVc?.order.pos_order_lines.firstIndex(where: {$0.id == line.id}) ?? -1
            if index != -1
            {
                if line.is_void!
                {
                    line.is_void = false
                    line.qty = 1
                    line.last_qty = 0
                    _ = line.save(write_info: true, updated_session_status: .last_update_from_local)
                    self.orderVc?.order.pos_order_lines[index] = line


                 }
                else
                {
                    self.orderVc?.order.pos_order_lines[index] = line

                }

            }
            self.orderVc?.order.applyPriceList(for:index)
        }
        }
       
         
        
//        DispatchQueue.main.async  {
            

            self.orderVc?.order.save(write_info: true,write_date: false ,re_calc: true)
            
//                                    self.readOrder()
//        self.orderVc?.reload_tableview()
            self.reloadTableOrders(re_calc: true)
            
//            self.orderVc?.reload_tableview()
         self.orderVc?.selected_section = -1
        self.orderVc?.tableview.reloadData()
        self.orderVc?.tableview.reloadData {
            
            
             if line.is_combo_line == false
                {
                    if rowIndex == -1
                             {
                                 self.select_last_row()

                             }
                             else
                             {
                                 self.select_row(section: line.section)
                                 
                             }
                }
                else
                {
                     self.select_row(section: line.section  )
                }
                    
        }
 
            
   
         
            
            
//        }
        
        
 
        
        return line
        
        
    }
    
    //      func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    //
    //        if (kind == UICollectionView.elementKindSectionHeader) {
    //            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
    //
    //            return headerView
    //        }
    //
    //        return UICollectionReusableView()
    //
    //    }
    
    
    func initCollection()   {
         
         //        refreshControl_collection.attributedTitle = NSAttributedString(string: "Pull to refresh")
         //        refreshControl_collection.addTarget(self, action: #selector(refreshCollection(sender:)), for: UIControl.Event.valueChanged)
         //        collection.addSubview(refreshControl_collection) // not required when using UITableViewContr
     }
     
     @objc func refreshCollection(sender:AnyObject) {
         // Code to refresh table view
         
        self.con.userCash = .stopCash
         getProduct()
         
     }
     
     func getProduct()
     {
         self.org_list_product = product_product_class.getMainProduct()  // api.get_last_cash_result(keyCash: "Items_by_POS_Category2") as? [[String:Any]] ?? [[:]]
         self.filterProducts(list: self.org_list_product)
         
         
         
         
         //        loadingClass.show()
         //
         //        con.userCash = .useCash
         //
         //        con.get_Items_by_POS_Category { (results) in
         //            self.refreshControl_collection.endRefreshing()
         //            loadingClass.hide()
         //
         //            if (!results.success)
         //            {
         //                return
         //            }
         //
         //            let response = results.response
         //            //            let header = results.header
         //
         //            self.org_list_product = response?["result"] as? [Any] ?? []
         //            self.filterProducts(list: self.org_list_product)
         //
         //
         //        }
     }
     
     func filterProducts(list:[Any])
     {
         self.list_product = list as? [[String : Any]]
         
         if     self.list_product.count > 0
         {
             let obj =  self.list_product?[0]["invisible_in_ui"]
             
             if obj != nil
             {
                 self.list_product = self.list_product.filter{$0["invisible_in_ui"]! as? Int == 0}
             }
         }
         
         
         //
         //         self.list_product.removeAll()
         //
         //         for item in list
         //         {
         //            let dic = item as? [String:Any]
         //            let invisible_in_ui = dic!["invisible_in_ui"] as? Bool ?? false
         //
         //            if invisible_in_ui == false
         //            {
         //                self.list_product.append(dic!)
         //            }
         //
         //         }
         
         
         let setting = SharedManager.shared.appSetting()
         
         if setting.show_all_products_inHome
         {
             self.list_product_search?.removeAll()
             self.list_product_search?.append(contentsOf:  self.list_product )
             
             self.collection?.reloadData()
         }
         
     }
    
    func combo_list_selected(line:pos_order_line_class,check_by_line: Bool,check_last_row:Bool,reload_list:Bool,show_promotion:Bool,fristShow:Bool = false)
    {
        
        var update_line:pos_order_line_class?
        
        if line.is_combo_line == false
        {
            if line.combo_edit == false
            {
                update_line =  self.add_product(line: line,new_qty:line.qty,check_by_line: check_by_line,check_last_row: check_last_row)
            }
            else
            {

                update_line =  self.saveProduct(line: line , rowIndex: line.index)
                
            }
            
        }
        else
        {
            if line.combo_edit == false
            {
                update_line =  self.add_product(line: line,new_qty: line.qty,check_by_line: check_by_line,check_last_row: check_last_row)
               
            }
            else
            {
                update_line =  self.saveProduct(line: line , rowIndex: line.index,printed: line.printed)
                
                
            }
        }
        
        
      
        if update_line != nil
        {
            
           
            
            if (self.comboList.product_combo?.combo_edit == false && show_promotion == true)
            {
                handle_promotion(line: update_line!)
            }
            else if  self.comboList.product_combo?.combo_edit == true && show_promotion == true  && fristShow == true
            {
                handle_promotion(line: update_line!)
            }
            

            if reload_list
            {
                self.comboList.view.removeFromSuperview()
                self.comboList = nil

                            show_combo(line: update_line!, isEdit: true)
                //            comboList.product_combo = update_line
                //            comboList.init_combo()
            }
            else
            {
                self.comboList.product_combo = update_line
                self.comboList.product_combo?.combo_edit = true
            }
     
        }
        
     
        
        if let line = update_line {
            self.orderVc?.open_price_popup(indexPath: IndexPath(row:line.index,section: line.section))
        }
        //self.orderVc?.reloadTableOrders()
//        self.reloadTableOrders()
    }
    
}
