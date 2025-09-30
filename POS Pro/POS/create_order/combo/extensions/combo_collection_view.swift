//
//  combo_collection_view.swift
//  pos
//
//  Created by Khaled on 8/6/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

typealias combo_collection_view = combo_vc
extension combo_collection_view :UICollectionViewDataSource ,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let key = list_collection_keys [indexPath.section]
        if  key.type == .variant
        {
            return CGSize(width: 280, height: 47)
        }
        
        return CGSize(width: 280, height: 47)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        let key_sec = list_collection_keys[section]
      if key_sec.type == .note
            {
                     return CGSize(width: 911, height: 200)
        }
        return CGSize(width: 0, height: 0)
    }
    
    
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return list_collection_keys.count
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        let key = list_collection_keys [section]
        if key.type == .combo
        {
            let arr = list_collection[key.title] ?? []

           return arr.count
        }
        else if  key.type == .variant
         {
          let arr = list_attribute[key.title] ?? []

        return  arr.count
       }
        else if  key.type == .note
        {
            return  list_notes.count
        }

        
        
        return 0
        
    }
    
    //3
    func collectionView(  _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath  ) -> UICollectionViewCell {
        let cell = collectionView  .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! combo_list_cell
        //        cell.backgroundColor = .lightGray
        // Configure the cell
        
        cell.combo_parent = self
        
        let key = list_collection_keys [indexPath.section]
        
        cell.section = key
        
        if key.type == .combo
        {
            let arr = list_collection[key.title] ?? []
             let product = arr[indexPath.row]
              
             cell.product = product
             cell.indexPath = indexPath
//             let selected = check_is_selected(key: key, product_id: product.id)
             
             cell.updateCell()
        }
        else if key.type == .variant
        {
            let arr = list_attribute [key.title] ?? []
           let att = arr[indexPath.row]
            
            let selected = check_list_attribute_selected(attribute_id: att.attribute_id_id ,att_id: att.id)
            var list_price:Double? = nil
            if list_attribute.count == 1 {
                list_price = product_combo?.product.list_price
            }
            cell.update_cell_variant(row: att, selected: selected,list_price: list_price)
        }
        else  if key.type == .note
        {
              
                 let note = list_notes[indexPath.row]
                  
//                let selected = check_list_attribute_selected(attribute_id: att.attribute_id_id ,att_id: att.id)
                 cell.update_cell_note(row: note, selected: false)
           
        }
        
 
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.view.endEditing(true)
        let key = list_collection_keys [indexPath.section]
        
        if key.type == .combo
        {
            
            let arr = list_collection[key.title] ?? []
            let product = arr[indexPath.row]
            product.image = ""
            
            if product.app_require == false
            {
                select_item_combo(key: key, product: product)

            }
        }
        else if key.type == .variant
        {
            let arr = list_attribute [key.title] ?? []
            let att = arr[indexPath.row]
            if product_combo?.printed == .printed{
                let currentName = product_combo?.product.display_name ?? "Variant"
                newNote = String(format: "*** Void - %@ - %@","\(product_combo?.qty ?? 1)", currentName )


            }else{
                if ( product_combo?.last_qty ?? 0 ) == (product_combo?.qty ?? 0 ){
                    product_combo?.last_qty = 0
                }
            }
            list_attribute_selected[att.attribute_id_id] = att
             product_combo?.attribute_value_id = att.id
            

            
            reload_combo()
            
            change_qty(new_value: qty)
            if !newNote.isEmpty{
                product_combo?.note_kds =  newNote
                product_combo?.last_qty = 0
                product_combo?.printed = .none


            }
            
            
        }
        else if key.type == .note
         {
            add_note(indexPath: indexPath)
        }
        
//        self.collection.reloadData()
//        let n = self.collection.numberOfSections
        let section_num:Int = indexPath.section
        self.collection.reloadSections(IndexSet(integer: section_num))
        
        done(removeFromSuperview: false)
        
        
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
          
          return header_cell(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        else  if (kind == UICollectionView.elementKindSectionFooter)
        {

              return footer_cell(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
 
        }
        
        return UICollectionReusableView()
        
    }
    func footer_cell(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let headerView:combo_list_footer_cell =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "combo_list_footer_cell", for: indexPath) as! combo_list_footer_cell
        
        let key_sec = list_collection_keys[indexPath.section]
        if key_sec.type == .note
        {
            headerView.isHidden = false
            headerView.txt_notes.text = product_combo?.note
            headerView.txt_notes.delegate = self
        }
        else
        {
            headerView.isHidden = true
        }
        
        return headerView
        
    }
    
    
    
    func header_cell(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let headerView:combo_list_header_cell =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "combo_list_header_cell", for: indexPath) as! combo_list_header_cell
        
        headerView.parent_combo = self
        
        let key_sec = list_collection_keys[indexPath.section]
        headerView.btn_clear_notes.isHidden = true
        if key_sec.type == .variant
        {
            headerView.lblTitle.text = String(format: "%@ ", key_sec.title )
            
        }
        else  if key_sec.type == .note
        {
            headerView.lblTitle.text = String(format: "%@ ", key_sec.title )
            headerView.btn_clear_notes.isHidden = false
        }
        else
        {
            let arr = list_collection[key_sec.title] ?? []
            let arr_key = key_sec.title.split(separator: "_")
            
            var key_title:String = ""
            if arr_key.count > 1
            {
                key_title =  String( arr_key[1] )
            }
            else
            {
                key_title  = key_sec.title
            }
            
            
            
            if key_title != Require_header
            {
                
                if arr.count > 0
                {
                    let obj = arr[0]
                    if obj.combo?.pos_category_id == 0
                    {
                        key_title = ""
                    }
                    
                    headerView.lblTitle.text = String(format: "%@ - Choose Any %@".arabic("%@ - اختيار أي %@"), key_title , no_of_items_for_qty(combo:obj.combo!).toIntString())
                    //                                         headerView.lblTitle.text = String(format: "%@", key_title  )
                }
                
            }
            else
            {
                headerView.lblTitle.text = String(format: "%@ ", key_title )
                
            }
        }
        
        
        return headerView
        
    }
    
    
    func AddOrMinusQty(product:product_product_class , plus:Bool,section:section_view)
    {
        


        
        let key_selected = product.section_name //section.title!
        
//        let combo = product_combo_class.get_combo(ID: product.combo!.id)
        let seleted_rows =  list_selected[key_selected] ?? []
        
        
        var new_line:pos_order_line_class?
        let old_line = seleted_rows.first (where: {$0.product_id  == product.id})
        if old_line != nil
        {
//            let product_combo_class = product_combo_class.get_combo(ID: old_line?.combo_id ?? 0)
//            let is_required = product_combo_class.require 
//            if is_required && (old_line?.qty ?? 0) == 1 && !plus {
//                return
//            }
            new_line = old_line
            new_line?.is_void = false
        }
        else
        {
            new_line = create_line(product: product)
            
        }
        
        
        AddOrMinusQty(section_key:key_selected,list: seleted_rows,   product: new_line!, plus: plus)
    }
    
    func select_item_combo(key:section_view,product:product_product_class)
    {
        let key_selected = product.section_name //key.title!
        
//        let combo = product_combo_class.get_combo(ID: product.combo!.id)
        let seleted_rows =  list_selected[key_selected] ?? []
        
        let line = create_line(product: product)
        
        AddOrMinusQty(section_key:key_selected,list: seleted_rows,  product: line, plus: true)
        
        //            if check_is_selected(key: key, product_id: product.id) == false
        //            {
        //                if checkTotalOfSection(arr: seleted_rows, combo: combo) == false
        //                {
        //                    seleted_rows.removeLast()
        //                }
        //
        //                let line = create_line(product: product)
        //                seleted_rows.append(line)
        //                list_selected[key_selected] = seleted_rows
        //            }
        //            else
        //            {
        //                list_selected.removeValue(forKey: key_selected)
        //            }
        
        
        
        
    }
    
    
    
    func check_is_selected(key:section_view,product_id:Int) -> Bool
    {
        var exist:Bool = false
       
        
        let key_selected = key.title!
        let arr = list_selected[key_selected]
        if  arr != nil
        {
            let filtered = arr!.filter { $0.product_id == product_id   }
            
            if filtered.count > 0
            {
                exist = true
            }
        }
        
        
        
        
        return exist
        
    }
    
    func check_list_attribute_selected(attribute_id:Int,att_id:Int) -> Bool
       {
           var exist:Bool = false
      
         let att =  list_attribute_selected[attribute_id]
 
           if att != nil
           {
            if att?.id == att_id
            {
                exist = true

            }
           }
           
           
           
           
           return exist
           
       }
    
    
    func no_of_items_for_qty(combo:product_combo_class) -> Double
    {
        return   Double(combo.no_of_items)  * qty
    }
    
    
    func checkTotalOfSection(arr: [pos_order_line_class] , combo:product_combo_class) -> Bool
    {
        let no_of_items = no_of_items_for_qty(combo:  combo)
        var checkTotal = 0.0
        
        for item in arr
        {
//            if item.combo_id == combo.id
//            {
                checkTotal = checkTotal + item.qty
//            }
        }
        
        if checkTotal  <  no_of_items
        {
            return true
        }
        else {
            return false
        }
        
    }
    
    
    func AddOrMinusQty(section_key:String,list :[pos_order_line_class]   ,product:pos_order_line_class,plus:Bool)
    {
        
        var list_items = list
        
        
        if plus == true
        {
            
            let combo = product_combo_class.get_combo(ID: product.combo_id!)
            
            if checkTotalOfSection(arr: list_items,combo: combo ) == false
            {
                list_items = list_items.sorted(by: { $0.auto_select_num! > $1.auto_select_num!})
                guard list_items.count != 0 else {
                    return
                }
                
                let frist_item = list_items[0]
                if frist_item.auto_select_num != 0
                {
                    if  frist_item.qty  > 0
                    {
                        frist_item.qty  -= 1
                        list_items[0] = frist_item
                        list_selected[section_key]  = list_items
                        
                        do_AddOrMinusQty(section_key: section_key,   product: product, plus: plus, listitems: list_items)
                        
                        
                    }
                    else if frist_item.qty == 0
                    {
                              return
                     }
//                    else if qty == 1
//                    {
//                        product.qty  = frist_item.qty
//                        list_items[0] = product
//                        list_selected[section_key]  = list_items
//                        reCheckCount()
//                    }
                    else if frist_item.qty  == 1 && frist_item.default_product_combo == true
                    {
                        list_items.remove(at: 0)
                        list_selected[section_key]  = list_items
                        
                        do_AddOrMinusQty(section_key: section_key,  product: product, plus: plus, listitems: list_items)
                        
                    }
                    
                }
                else if list_items.count == 1 && frist_item.auto_select_num == 0
                {
                    product.qty = frist_item.qty
                    list_items[0] = product
                    list_selected[section_key]  = list_items
                    reCheckCount()
                }
                
                
             
          
                return
                 
            }
             
            
            
        }
         
        
            do_AddOrMinusQty(section_key: section_key,   product: product, plus: plus, listitems: list_items)

    
         
        
        
    }
    
    
    func do_AddOrMinusQty(section_key:String   ,product:pos_order_line_class,plus:Bool,listitems: [pos_order_line_class])
    {
        var list_items = listitems
        
//        let updated_line = pos_order_line_class.get(uid: product.uid)
//        if updated_line != nil
//        {
//            if updated_line?.pos_multi_session_status == .sended_update_to_server
//            {
//                product.last_qty = product.qty
////                product.printed = updated_line!.printed
//            }
//        }
        
        
        var plus_val = 1.0
        if plus == false
        {
            plus_val = -1.0
        }
        
        
        let rowProduct =  checkProductExist(productSearch: product,list_items: list_items)
        
        if rowProduct == nil
        {
            product.qty = 1
            product.printed = .none

            list_items.append(product)
            
        }
        else
        {
            rowProduct?.printed = .none
            rowProduct?.qty  += plus_val
            list_items[rowProduct!.index] = rowProduct!
        }
        
        product_combo?.printed = .none

        list_selected[section_key] = list_items
        
        reCheckCount()
        
    }
    
    
    func checkProductExist(productSearch:pos_order_line_class,list_items:[pos_order_line_class]) -> pos_order_line_class? {
        
        
        let count = list_items.count
        
        if count == 0 {return nil}
        
        for n in 0...count - 1
        {
            let line = list_items[n]
            if line.product_id == productSearch.product_id
            {
                line.index = n
                return line
            }
            
        }
        
        
        return nil
    }
    
    func reCheckCount()
    {
//        self.collection.reloadData()
//
//        return
  
        var seleted_items = 0.0
        //            var avalibale_items:Double = 0.0
        
        for (key_sec,_) in list_selected
        {
            
            let key = key_sec
            
            
            var arr = list_selected[key]
            let arr_count =  arr?.count ?? 0
            
            if arr_count != 0
            {
                
                let line = arr![0]
                let combo = product_combo_class.get_combo(ID: line.combo_id!)
                let no_of_items = no_of_items_for_qty(combo:  combo)
                
                var total = 0.0
                for i in 0...arr!.count - 1
                {
                    let item = arr![i]
                    total = total + item.qty
                    
                    if total > no_of_items
                    {
                        if i == 0
                        {
                            item.qty  = no_of_items
                            arr![i] = item
                        }
                        else
                        {
                          item.qty  -= 1
                          arr![i] = item
//                            arr?.remove(at: i)
                        }
                        
                        
                        list_selected[key] = arr
                    }
                    else
                    {
                        seleted_items = seleted_items + item.qty
                    }
                    
                }
                
            }
            
        }
        
        //            avalibale_items = avalibale_total_items   - seleted_items
        //            lblTitle.text =  avalibale_items.toIntString()
        //
        //            self.delegate?.selected_items(count: Int(seleted_items))
        //
        //              reload_Table()
        
        self.collection.reloadData()
    }
}
