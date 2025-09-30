//
//  combo_seleted_items.swift
//  pos
//
//  Created by Khaled on 12/23/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
protocol  combo_seleted_items_delegate {
    func selected_items(count:Int)
}


class combo_seleted_items: UIViewController  {
    
    @IBOutlet var tableview: UITableView!
    
    @IBOutlet weak var lblTitle: KLabel!
    var delegate:combo_seleted_items_delegate?
    
    var list_default_collection: [String:[pos_order_line_class]] = [:]
    var list_collection: [String:[pos_order_line_class]] = [:]
    var list_collection_keys:[String] = []
    
    var avalibale_total_items = 0.0

    var qty : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
             lblTitle.layer.cornerRadius = 15
        lblTitle.layer.masksToBounds = true
        
        
        let headerNib = UINib.init(nibName: "combo_seleted_items_header_view", bundle: Bundle.main)
        tableview.register(headerNib, forHeaderFooterViewReuseIdentifier: "combo_seleted_items_header_view")
        
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
 
    
   
    
    func  reload_Table()    {
        
       
        
        tableview.reloadData()
        
   
    }
    
    
    func setAutoSelect(newQty:Double)
    {
        
        if list_collection_keys.count == 0
        {
            return
        }
        
        for key_index in 0...list_collection_keys.count - 1
        {
            let key = list_collection_keys[key_index]
            var arr = list_collection[key] ?? []
            let count = arr.count
            if count > 0
            {
                for product_index in 0...arr.count - 1
                {
                    let product_row = arr[product_index]
                    let totalExit = getTotalExitInSection(lst: arr)

                    if  0 == Int(totalExit)  && newQty == 1
                    {
                        product_row.qty  =  newQty
                      
                    }
                    else if  Int(newQty) <= Int(totalExit)  && newQty == 1
                    {
                        if product_index == count - 1
                        {
                            product_row.qty  = 1

                        }
                        else
                        {
                            product_row.qty  = 0

                        }
                    }
                    else if Int(newQty) < Int(totalExit) && newQty != 1
                    {
                        if count == 1
                        {
                             product_row.qty  = newQty
                        }
                        else
                        {
                            let def = product_row.qty  - (totalExit - newQty   )
                            if def < 0
                            {
                                 product_row.qty = 0
                            }
                            else
                            {
                                 product_row.qty  = def
                            }
                           

                        }
                        
//                        if  product_row.auto_select_num != 0
//                        {
//                            product_row.qty_app = totalExit - newQty // product_row.auto_select_num * newQty
//                            arr[product_index] = product_row
//                            list_collection[key] = arr
//                        }
                    }
                    else if Int(newQty) > Int(totalExit) && newQty != 1
                    {
                        if count == 1
                        {
                            if product_row.default_product_combo == true
                            {
                                 product_row.qty  = newQty
                            }
                            else
                            {
                                let products_default_arr = list_default_collection[key] ?? []
                                if products_default_arr.count > 0
                                {
                                    let product = products_default_arr[0]
                                    product.qty  = newQty - totalExit
                                    arr.append(product)
                                }
                                else
                                {
                                    product_row.qty  = newQty
                                }
                            }
 
                            
                        }
                        else
                        {
                             if  product_row.auto_select_num != 0
                            {
                             product_row.qty  =  product_row.qty  + ( newQty - totalExit)
                            }
                        }
                    }
                    
                    arr[product_index] = product_row
                    
                    
                    list_collection[key] = moveDefualtToTop(lst: arr)
                
                }
            }
            
            
        }
        
        reload_Table()
    }
    
    func moveDefualtToTop(lst:[pos_order_line_class]) -> [pos_order_line_class]
    {
        var new_list:[pos_order_line_class] = []
        for item in lst
        {
            if item.default_product_combo == true
            {
                new_list.insert(item, at: 0)
            }
            else
            {
                new_list.append(item)
            }
        }
        
        return new_list
    }
    
    func getTotalExitInSection(lst:[pos_order_line_class]) -> Double
    {
        var total = 0.0
        for item in lst
        {
            total = total + item.qty
        }
        
        return total
    }
    
    func selecteProduct(product:pos_order_line_class)
    {
        if list_collection_keys.count == 0
        {
            return
        }
        
        for key_index in 0...list_collection_keys.count - 1
        {
            let key = list_collection_keys[key_index]
            let arr = list_collection[key] ?? []
            
            if arr.count > 0
            {
                for product_index in 0...arr.count - 1
                {
                    let product_row = arr[product_index]
                    if product_row.id == product.product_id
                    {
                        tableview.selectRow(at: IndexPath.init(row: product_index, section: key_index), animated: true, scrollPosition: .bottom)
                        
                        
                    }
                }
            }
            
            
        }
        
        
    }
    
    
    func AddOrMinusQty(product:pos_order_line_class , plus:Bool)
    {
        let combo = product_combo_class.get_combo(ID: product.combo_id!)
        if combo.pos_category_id != 0
        {
            var key =   combo.pos_category_id_name
            key = getKey_ordered(key_categ: key)
             
            AddOrMinusQty(section_key: key, combo_id:combo.id,  product: product, plus: plus)
        }
    }
    
    func getKey_ordered(key_categ:String) -> String
      {
          var key = key_categ
          let filtered = list_collection_keys.filter { $0.contains(key) }
          if filtered.count > 0
          {
              key = filtered[0]
          }
          
          return key
          
      }
    
    func addItem(section_key:String,product:pos_order_line_class)
    {
        var list_items = list_collection[section_key] ?? []
        
//        product.qty_app  = 1
        list_items.append(product)
        list_collection[section_key] = list_items

//        getKeys()
        
    }
    
    func scaleView(view:UIView)
    {
        UIView.animate(withDuration: 0.3,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.3) {
                           view.transform = CGAffineTransform.identity
                        }
        })
    }
    
    func AddOrMinusQty(section_key:String ,combo_id: Int ,product:pos_order_line_class,plus:Bool)
    {
        var list_items = list_collection[section_key] ?? []
        
        
        if plus == true
        {
            
            let combo = product_combo_class.get_combo(ID: combo_id)
            
            if checkTotalOfSection(arr: list_items,combo: combo ) == false
            {
                
                let frist_item = list_items[0]
                if frist_item.auto_select_num != 0
                {
                    if  frist_item.qty  > 1
                    {
                        frist_item.qty  -= 1
                        list_items[0] = frist_item
                        list_collection[section_key]  = list_items
                        
                        do_AddOrMinusQty(section_key: section_key,   product: product, plus: plus, listitems: list_items)

  
                    }
                    else if qty == 1
                    {
                        product.qty  = frist_item.qty
                        list_items[0] = product
                        list_collection[section_key]  = list_items
                           reCheckCount()
                    }
                    else if frist_item.qty  == 1 && frist_item.default_product_combo == true
                    {
                        list_items.remove(at: 0)
                        list_collection[section_key]  = list_items

                        do_AddOrMinusQty(section_key: section_key,  product: product, plus: plus, listitems: list_items)

                    }
                
                }
                else if list_items.count == 1 && frist_item.auto_select_num == 0
                {
                    product.qty = frist_item.qty
                    list_items[0] = product
                    list_collection[section_key]  = list_items
                     reCheckCount()
                }
               
                
//               reCheckCount()
                
                selecteProduct(product: frist_item)
                
                scaleView(view: lblTitle)
          
           


                return
            }
          
            
        }
        
            
            do_AddOrMinusQty(section_key: section_key,   product: product, plus: plus, listitems: list_items)
      
        
        
    }
    
    
    func do_AddOrMinusQty(section_key:String   ,product:pos_order_line_class,plus:Bool,listitems: [pos_order_line_class])
    {
        var list_items = listitems
        
        
        var plus_val = 1.0
        if plus == false
        {
            plus_val = -1.0
        }
        
        
        let rowProduct =  checkProductExist(productSearch: product,list_items: list_items)
        
        if rowProduct == nil
        {
            product.qty = 1
            list_items.append(product)
            
        }
        else
        {
            rowProduct?.qty  += plus_val
            list_items[rowProduct!.index] = rowProduct!
        }
        
        list_collection[section_key] = list_items
        
        reCheckCount()
        
    }
    
    
    func checkTotalOfSection(arr: [pos_order_line_class] , combo:product_combo_class) -> Bool
    {
        let no_of_items = no_of_items_for_qty(combo:  combo)
        var checkTotal = 0.0
        
        for item in arr
        {
            if item.combo_id == combo.id
            {
                checkTotal = checkTotal + item.qty
            }
        }
        
        if checkTotal <  no_of_items
        {
            return true
        }
        else {
            return false
        }
        
    }
    
//    func checkTotalOfSection_old(arr: [product_product_class] , combo:product_combo_class) -> Bool
//    {
//        let no_of_items = no_of_items_for_qty(combo:  combo)
//        
//        if  no_of_items  == 1
//        {
//            //            for i in 0...arr.count - 1
//            //            {
//            //                let item = arr[i]
//            //                if  item.app_selected == true
//            //                {
//            //                    item.qty_app = 0
//            //                    item.app_selected = false
//            //                    arr[i] = item
//            //                    list_collection[key] = arr
//            //                    self.collection.reloadData()
//            //
//            //
//            //                }
//            //            }
//            
//            return true
//        }
//        else
//        {
//            var total:Double = 0
//            for item in arr
//            {
//                total = total + item.qty_app
//            }
//            
//            
//            
//            if no_of_items >  total  {
//                return true
//            }
//            else
//            {
//                return false
//            }
//            
//        }
//        
//        
//        
//    }
    
    func no_of_items_for_qty(combo:product_combo_class) -> Double
    {
        let t = Double( combo.no_of_items)  * qty
        return  t
    }
    
    func reCheckCount()
    {
        
        
        var seleted_items = 0.0
        var avalibale_items:Double = 0.0
 
        for key_sec in list_collection_keys
        {
//            let arr_key = key_sec.split(separator: "_")
//            var key = key_sec
//
//            if arr_key.count > 1
//            {
//              key =  String( arr_key[1] )
//            }
            let key = key_sec
            
            
            var arr = list_collection[key]
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
                        }
                        else
                        {
                            item.qty  = 0
                        }
                        
                        arr![i] = item
                        list_collection[key] = arr
                    }
                    else
                    {
                        seleted_items = seleted_items + item.qty
                    }
                    
                }
              
            }
            
        }
        
        avalibale_items = avalibale_total_items   - seleted_items
        lblTitle.text =  avalibale_items.toIntString()
        
        self.delegate?.selected_items(count: Int(seleted_items))
     
   
        
          reload_Table()
    }
    
    func add_note(line:pos_order_line_class? , indexPath: IndexPath)
    {
//        let storyboard = UIStoryboard(name: "notes", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "product_note_qty") as! product_note_qty
//
//
//        line?.index = indexPath.row
//        line?.section = indexPath.section
//
//        vc.delegate = self
//        vc.line = line
//
//        vc.modalPresentationStyle = .popover
//
//        let popover = vc.popoverPresentationController!
//        popover.permittedArrowDirections = .left
//        popover.sourceView = tableview
//        popover.sourceRect = tableview.cellForRow(at: indexPath)!.frame
//
//        self.present(vc, animated: true, completion: nil)
    }
    
    func note_added(line: pos_order_line_class?) {
        let key = list_collection_keys [line!.section]
        var arr = list_collection[key] ?? []
        arr[(line?.index)!] = line!
        
        list_collection[key] = arr
        
        tableview.reloadData()
    }
    
    func no_notes()
    {
        
    }
    
}
extension combo_seleted_items: UITableViewDelegate ,UITableViewDataSource ,combo_seleted_itemsCell_delegate{
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let key = list_collection_keys [indexPath.section]
        let arr = list_collection[key]
        let product = arr![indexPath.row]
        
        if !(product.note ?? "").isEmpty
        {
            return 90
            
        }
        
        return 65
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let key = list_collection_keys [section]
        let arr = list_collection[key] ?? []
        if arr.count == 0
        {
            return 0
        }
        else
        {
            return 44
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "combo_seleted_items_header_view") as! combo_seleted_items_header_view

        let key_sec = list_collection_keys [section]
        let arr = list_collection[key_sec] ?? []
        
 
           
              let arr_key = key_sec.split(separator: "_")
              var key = key_sec
              
              if arr_key.count > 1
              {
                key =  String( arr_key[1] )
              }
        
        
        if arr.count > 0
         {
           let obj = arr[0]
            let combo = product_combo_class.get_combo(ID: obj.combo_id!)
           header.lblTitle.text = String(format: "%@ - Choose Any %@", key , no_of_items_for_qty(combo:combo).toIntString())
        }
        
        header.lblSeletectItems.text = sumHeader(arr: arr).toIntString()  //String(format: "%d", arr.count)
        header.lblSeletectItems.layer.cornerRadius = 15
        header.lblSeletectItems.layer.masksToBounds = true
        
        return header
        
    }
    
    func sumHeader(arr: [pos_order_line_class]) -> Double
    {
        var total = 0.0
        
        for item in arr
        {
            total = total + item.qty
        }
        
        return total
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let key = list_collection_keys [section]
//        var arr = list_collection[key] ?? []
//
//        if arr.count > 0
//        {
//            let obj = arr[0]
//            return String(format: "%@ - Choose Any %@", key , no_of_items_for_qty(combo:obj.combo!).toIntString())
//        }
//
//
//
//        return key
//    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let key = list_collection_keys [indexPath.section]
        let arr = list_collection[key]
        let line = arr![indexPath.row]
        
        add_note(line: line ,indexPath: indexPath )
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list_collection_keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = list_collection_keys [section]
        let arr = list_collection[key] ?? []
        
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! combo_seleted_itemsCell
        
        let key = list_collection_keys [indexPath.section]
        let arr = list_collection[key]
        let product = arr![indexPath.row]
        
        product.index = indexPath.row
        product.section = indexPath.section
        
        product.combo_pos_category_id  = Int( key) ?? 0
        cell.product =  product
//        cell.parent_combo = self
        cell.delegate = self
        cell.updateCell()
        
        
        return cell
    }
    
    func deleteRow(product :pos_order_line_class)
    {
        let key = list_collection_keys [product.section]
        var arr = list_collection[key]
        arr?.remove(at: product.index)
        
        list_collection[key] = arr
        
        reCheckCount()
    }
    
}
