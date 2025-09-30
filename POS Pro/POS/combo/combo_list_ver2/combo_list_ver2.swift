//
//  combo_list.swift
//  pos
//
//  Created by khaled on 10/12/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol combo_list_ver2_delegate {
    func combo_list_selected(line:pos_order_line_class)
}

class combo_list_ver2: UIViewController ,UICollectionViewDataSource ,UICollectionViewDelegate , combo_listCell_ver2_delegate,combo_seleted_items_delegate ,enterBalance_delegate{
    
    
    @IBOutlet var btnOK: KButton!
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var view_items_seleted: UIView!
    @IBOutlet weak var seq_qty: UISegmentedControl!
    
    private var list_collection: [String:[product_product_class]]! = [:]
//    var list_collection_keys:[String]! = []
    
    
    private let reuseIdentifier = "FlickrCell"
    let Require_header = "Require"
    
    var product_combo:pos_order_line_class?
    
    var order_id:Int!
    
    
    var list_combo_price:[Any]! = []
    
    var qty : Double = 1.0
    var last_qty : Double = 1.0
    
    
    let con = api()
    
    var delegate:combo_list_ver2_delegate?
    var avalabile_combos:[[String:Any]]!
    
    var comboSeletedItems:combo_seleted_items?
    //    var avalibale_total_items = 0.0
    
    var keyboard :enterBalance!
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        list_collection = nil
    
        product_combo = nil
        
        list_combo_price = nil
        avalabile_combos = nil
        keyboard = nil
        comboSeletedItems = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initcombo()
        getAvalalibeCombos()
        
        setSeqQty()
        initcomboSeletedItems()
        
        load_seleted_lines()
    }
    
    func getAvalalibeCombos()
    {
        let combos = product_product_class.getCombos(product_id: product_combo!.product_id!)
        list_combo_price = product_combo_price_class.getAll()
        
        let products_InCombo = get_products_InCombo_clac(avalabile_combos: combos)
        product_combo!.products_InCombo = products_InCombo.list
        product_combo!.products_InCombo_avalibale_total_items = products_InCombo.total_items
        
    }
    
    
    func load_seleted_lines()
    {
        for (key,value) in  product_combo!.products_InCombo
        {
//            list_collection_keys.append(key)
            var new_list:[product_product_class] = []
            for obj in value
            {
                //                let product = productProductClass(fromDictionary: obj )
                 
                new_list.append(obj)
            }
            list_collection[key] = new_list
        }
        
//        let sortedKeys = list_collection_keys.sorted(by: <)
//        list_collection_keys.removeAll()
//        list_collection_keys.append(contentsOf: sortedKeys)
        
        selectRequire()
        
        self.collection?.reloadData()
        
//        comboSeletedItems!.list_collection_keys = list_collection_keys
        //                 comboSeletedItems!.list_collection  = list_collection
        comboSeletedItems!.avalibale_total_items = product_combo!.products_InCombo_avalibale_total_items  * qty
        comboSeletedItems!.reCheckCount()
        
        if product_combo?.combo_edit == true
        {
            for p in product_combo!.list_product_in_combo
            {
  
                if p.qty > 0
                {
                    var key =  product_combo_class.get_combo(ID: p.combo_id!).pos_category_id_name  //p.combo!.pos_category_id_name
                                 key = getKey_ordered(key_categ: key)
                                 
                                 comboSeletedItems!.addItem(section_key: key, product: p)
                                 comboSeletedItems!.reCheckCount()
                }
             
            }
            
        }
        else
        {
            setSutoSelect()
        }
        
        
    }
    
    func getKey_ordered(key_categ:String) -> String
    {
        var key = key_categ
//        let filtered = list_collection_keys.filter { $0.contains(key) }
//        if filtered.count > 0
//        {
//            key = filtered[0]
//        }
        
        return key
        
    }
    
    
    func setSutoSelect()
    {
        for (_,value) in list_collection
        {
            let arr = value
            
            for product in arr
            {
                
                
                if product.default_product_combo == true
                {
                    if product.combo!.pos_category_id != 0
                    {
                        var key =   product.combo!.pos_category_id_name
                        
                        key = getKey_ordered(key_categ: key)
                        
 
                        
                        let line = create_line(product: product)
                      
                        comboSeletedItems!.addItem(section_key: key, product: line)
                    }}
                
                
               
                
            }
            
        }
        
        comboSeletedItems!.list_default_collection = comboSeletedItems!.list_collection
        comboSeletedItems!.reCheckCount()
    }
    
    func create_line(product:product_product_class) -> pos_order_line_class
    {
        let line = pos_order_line_class.create(order_id: order_id, product: product)

//        let line = pos_order_line_class.get_or_create(order_id: order_id, product: product)
                               line.parent_product_id = product_combo?.product_id
                               line.combo_id = product.combo?.id
                               line.qty = 1
                               line.auto_select_num = product.auto_select_num
                               line.extra_price = product.comob_extra_price
                               line.default_product_combo = product.default_product_combo
        
        return line
    }
    
    func initcomboSeletedItems()
    {
        
        
        let storyboard = UIStoryboard(name: "combo", bundle: nil)
        comboSeletedItems = storyboard.instantiateViewController(withIdentifier: "combo_seleted_items") as? combo_seleted_items
        //        orderVc = order_listVc()
        comboSeletedItems!.delegate = self
        
        let frm = view_items_seleted.bounds
        
        
        comboSeletedItems!.view.frame = frm
        comboSeletedItems!.qty = qty
        
        view_items_seleted.addSubview(comboSeletedItems!.view)
    }
    
    func setSeqQty()
    {
        seq_qty.frame = CGRect(x: seq_qty.frame.origin.x, y: seq_qty.frame.origin.y, width: seq_qty.frame.size.width, height: 60);
        
        if product_combo?.combo_edit == true
        {
            qty = product_combo!.qty
            if qty < 9
            {
                seq_qty.selectedSegmentIndex = Int(qty - 1)
                
            }
            else
            {
                seq_qty.selectedSegmentIndex = 10
                
            }
        }
    }
    
    func get_product_combo_prices()
    {
        
        
        self.list_combo_price    =  product_combo_price_class.getAll() // api.get_last_cash_result(keyCash: "get_product_combo_prices")
        
        
    }
    
    
//    func get_combo()
//    {
//        let list_combo:[[String:Any]] =  productComboClass.getAll() // api.get_last_cash_result(keyCash: "get_porduct_combo") as? [[String:Any]] ?? [[:]]
//        avalabile_combos = self.get_avalalibe_combos(list_combo: list_combo)
//
//    }
    
    
    
    
    func selectRequire()
    {
        var list:[product_product_class] = list_collection[Require_header]   ?? []
        let count = list.count
        
        
        if count == 0
        {
            
            return
        }
        
        
        for i in 0...count - 1
        {
            let product = list[i]
            
            product.app_require = true
            
            // TODO
//            product.qty_app = 1.0
            
            list[i] = product
            
        }
        
        list_collection[Require_header] = list
        
    }
    
    
    
    func checkProductInList(product:pos_order_line_class ) -> pos_order_line_class
    {
        
        if product_combo!.list_product_in_combo.count > 0 {
            
            let combo = product_combo_class.get_combo(ID: product.combo_id!)
            let total_items = no_of_items_for_qty(combo:combo)
            var calc_total = 0.0
            
            for p in product_combo!.list_product_in_combo
            {
        
                if p.product_id == product.id
                {
                    
                    if total_items < calc_total + p.qty
                    {
                        p.qty  = 0
                        p.app_selected = true
                    }
                    else
                    {
                        calc_total = calc_total + p.qty
                    }
                    
                    return p
                }
                
            }
        }
        
        
        return product
    }
    
//    func get_avalalibe_combos( list_combo:[[String:Any]]) ->[[String:Any]]
//    {
//        var arr_avalalibe_combo:[[String:Any]] = []
//
//        for item:Int in product_combo!.product_combo_ids
//        {
//            for combo_item:[String:Any] in list_combo
//            {
//                let id = combo_item["id"] as? Int ?? 0
//
//                if item == id
//                {
//                    arr_avalalibe_combo.append(combo_item)
//                }
//
//            }
//        }
//
//        return arr_avalalibe_combo
//    }
    
    
    
    func deleteProduct(indexPath: IndexPath)
    {
//        let key = list_collection_keys [indexPath.section]
//        var arr = list_collection[key] ?? []
//        let obj = arr[indexPath.row]
//
////        obj.qty_app = 0
//        obj.app_selected = false
//
//        arr[indexPath.row] = obj
//        list_collection[key] = arr
//
//        self.collection.reloadData()
    }
    
    func updateProduct(product:product_product_class, indexPath: IndexPath)
    {
//        let key = list_collection_keys [indexPath.section]
//        var arr = list_collection[key] ?? []
//
//        arr[indexPath.row] = product
//        list_collection[key] = arr
//
//        self.collection.reloadData()
    }
    
    func selected_items(count:Int) {
        if count == 0
        {
            btnOK.isEnabled = false
            btnOK.setBackgroundColor_base(base: UIColor.lightGray)
            
        }
        else
        {
            btnOK.isEnabled = true
            btnOK.setBackgroundColor_base(base: UIColor.init(hexString: "#0CC579"))
            
        }
    }
    
    @IBAction func btnOk(_ sender: Any) {
        
        get_products_selected()
        update_products_void()
        
        if product_combo!.list_product_in_combo.count > 0
        {
            product_combo?.qty  = qty
            
            
            for combo_line in product_combo!.list_product_in_combo
             {
                    combo_line.write_info = true
            }
         
        
            delegate?.combo_list_selected(line: product_combo!)
            
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            btnCancel(AnyClass.self)
        }
        
        
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        
        if product_combo?.combo_edit == false
        {
            product_combo?.list_product_in_combo = []
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func update_products_void()
    {
        // in create
        if product_combo?.id == 0
        {
            return
        }
        
        var ids = ""
        for product in product_combo!.list_product_in_combo
        {
            ids = ids + "," + String( product.product_id!)
        }
        
        ids.removeFirst()
        
        pos_order_line_class.void_all_execlude(products: ids, order_id: order_id, parent_product_id: product_combo!.product_id!,pos_multi_session_status: nil,parent_line_id: (product_combo?.id)!)
     }
    
    func get_products_selected()
    {
        product_combo?.list_product_in_combo = []
        
        product_combo?.price_unit! =   product_combo!.product.lst_price
        
        var total_extraPrice:Double = 0.0
        
        for key in comboSeletedItems!.list_collection_keys
        {
            let arr = comboSeletedItems!.list_collection[key] ?? []
            
            for row in arr
            {
                if row.qty  == 0
                {
                    row.is_void = true
                }
                    
                    if row.extra_price != 0
                    {
                        total_extraPrice = total_extraPrice + ( row.extra_price! * row.qty )
                        //                        product_combo?.custome_price_app = true
                        ////                        product_combo?.price_app_priceList =  product_combo!.price_app_priceList + ( row.comob_extra_price * row.qty_app)
                        //                        product_combo?.price_app_priceList =  product_combo!.price_app_priceList +   row.comob_extra_price
                        
                    }
                    
 
                row.is_combo_line = true
                row.pos_multi_session_status = .last_update_from_local
                 
                product_combo?.list_product_in_combo.append(row)
                    
                    
//                }
            }
            
        }
        
        
        product_combo?.custome_price_app = true
        product_combo?.price_unit  = ( product_combo!.price_unit! * qty) +  total_extraPrice
        
    }
    
    
    
    
    
    
}

// MARK: - UICollectionViewDataSource

extension combo_list_ver2 {
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return list_collection_keys.count
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        let key = list_collection_keys [section]
        let arr = list_collection[key] ?? []
        
        return arr.count
        
    }
    
    //3
    func collectionView(  _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath  ) -> UICollectionViewCell {
        let cell = collectionView  .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! combo_listCell_ver2
        //        cell.backgroundColor = .lightGray
        // Configure the cell
        
        let key = list_collection_keys [indexPath.section]
        let arr = list_collection[key] ?? []
        let product = arr[indexPath.row]
        
        
        
        cell.product = product
        cell.delegate = self
        cell.indexPath = indexPath
        cell.combo_parent = self
        
        cell.updateCell()
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let key = list_collection_keys [indexPath.section]
        let arr = list_collection[key] ?? []
        let product = arr[indexPath.row]
        product.image = ""
        
        
      
        
      let line = create_line(product: product)
 
        comboSeletedItems!.AddOrMinusQty(section_key: key,combo_id:product.combo!.id, product: line, plus: true)
        
        
        
      
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            
            //                let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            //                let headerView = collectionView  .dequeueReusableCell(withReuseIdentifier: "combo_listHeaderCell", for: indexPath) as! combo_listHeaderCell
            
            let headerView:combo_listHeaderCell_ver2 =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "combo_listHeaderCell", for: indexPath) as! combo_listHeaderCell_ver2
            
            let key_sec = list_collection_keys[indexPath.section]
            
            let arr = list_collection[key_sec] ?? []
            let arr_key = key_sec.split(separator: "_")
            var key = key_sec
            
            if arr_key.count > 1
            {
                key =  String( arr_key[1] )
            }
            
            if key != Require_header
            {
                if arr.count > 0
                {
                    let obj = arr[0]
                    headerView.lblTitle.text = String(format: "%@ - Choose Any %@", key , no_of_items_for_qty(combo:obj.combo!).toIntString())
                }
                
            }
            else
            {
                headerView.lblTitle.text = String(format: "%@ ", key  )
                
            }
            
            return headerView
        }
        
        return UICollectionReusableView()
        
    }
    
    @IBAction func seq_changed(_ sender: Any) {
        
        if seq_qty.selectedSegmentIndex == 9
        {
            
            let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
            keyboard = storyboard.instantiateViewController(withIdentifier: "enterBalance") as? enterBalance
            keyboard.modalPresentationStyle = .popover
            //        invoices_List.delegate = self
            keyboard.preferredContentSize = CGSize(width: 400, height: 715)
            keyboard.delegate = self
            keyboard.title_vc = "Qty"
            keyboard.key = "qty"
            keyboard.disable_fraction = true
            
            let popover = keyboard.popoverPresentationController!
            //        popover.delegate = self
            popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
            popover.sourceView = sender as? UIView
            popover.sourceRect =  (sender as AnyObject).bounds
            //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            
            self.present(keyboard, animated: true, completion: nil)
            
            return
        }
        
        qty = Double(seq_qty.selectedSegmentIndex + 1)
        
        
        AplynewQty()
        
        
    }
    
    func AplynewQty()
    {
        comboSeletedItems!.qty = qty
        comboSeletedItems?.avalibale_total_items = product_combo!.products_InCombo_avalibale_total_items * qty
        
        //        if last_qty > qty
        //        {
        //            last_qty = qty
        comboSeletedItems!.setAutoSelect(newQty: qty)
        //        }
        
        
        comboSeletedItems!.reCheckCount()
        //        if avalabile_combos != nil
        //        {
        //            get_products_InCombo(avalabile_combos: avalabile_combos)
        //        }
        
        self.collection.reloadData()
    }
    
    func no_of_items_for_qty(combo:product_combo_class) -> Double
    {
        return   Double(combo.no_of_items)  * qty
    }
    
    func newBalance(key:String,value:String)
    {
        if !value.isEmpty
        {
            qty = Double(value) ?? 1
            
            AplynewQty()
        }
        
    }
    
}


extension combo_list_ver2 {
    
    func get_products_InCombo_clac(avalabile_combos:[[String:Any]]) -> (list:[String:[product_product_class]] , total_items:Double)
    {
        
        var list_collection: [String:[product_product_class]] = [:]
        var avalibale_total_items = 0.0
        let Require_header = "0_Require"
        
        var index = 1
        for combo  in avalabile_combos
        {
            var list:[product_product_class] = []
            
            //            let require = combo["require"] as? Bool ?? false
            //            let no_of_items = combo["no_of_items"] as? Bool ?? false
            //            let product_ids:[Int] = combo["product_ids"] as! [Int]
            
            let cls_combo = product_combo_class(fromDictionary: combo)
            avalibale_total_items = avalibale_total_items + Double(cls_combo.no_of_items)
            
            
            let arr_products = get_product_item_calc(combo: cls_combo)
            list.append(contentsOf: arr_products)
            
            if cls_combo.require == true
            {
                var newList = list_collection[Require_header]  ?? []
                newList.append(contentsOf: list)
                
                list_collection[Require_header] = newList
            }
            else
            {
                var categ_name = ""
                
                if cls_combo.pos_category_id != 0
                {
                    categ_name =   cls_combo.pos_category_id_name
                }
                
                categ_name = String(format: "%d_%@" , index , categ_name)
                
                var newList = list_collection[categ_name]   ?? []
                newList.append(contentsOf: list)
                
                list_collection[categ_name] = newList
                
                
                index += 1
            }
            
        }
        
        return (list_collection , avalibale_total_items)
    }
    
    
    func get_product_item_calc(combo:product_combo_class) -> [product_product_class]
    {
        var list:[product_product_class] = []
        
        for id:Int  in combo.productProductIDS()
        {
            
            //                for item in all_products
            //                {
            var product = product_product_class.getProduct(ID: id)
            
            //                    if product.id == id
            //                    {
            if combo.pos_category_id == 0
            {
                //                        combo.pos_category_id = [ 0 ,"Default"]
                combo.pos_category_id_name = "Default"
            }
            
            product.combo = combo
            
            product = get_extra_price_calc(product: product )
            
            
            list.append(product )
            //                    }
            //                }
            
            
        }
        
        return list
    }
    
 
    
    
    func get_extra_price_calc(product:product_product_class) -> product_product_class
    {
        if  product.combo?.product_tmpl_id == 0
        {
            return product
        }
        
    
        let compo_price = product.getComboPrice(product_id: product.id ,product_tmpl_id:product.combo!.product_tmpl_id) ?? [:]
        let combo = product_combo_price_class(fromDictionary: compo_price)
        product.comob_extra_price = combo.extra_price
        
        if combo.auto_select_num > 0
        {
            product.app_selected = true
//            product.qty_app = Double(combo.auto_select_num)
            product.auto_select_num = combo.auto_select_num
            product.default_product_combo = true
            
        }
        
        return product
        /*
         for item in list_combo_price
         {
         let combo = productComboPriceClass(fromDictionary: item as! [String : Any] )
         let combo_tmpl_id = combo.product_tmpl_id // (combo.product_tmpl_id.count > 0) ? combo.product_tmpl_id[0]  as? Int ?? 0 : 0
         //            let product_id_temp =  ( combo.product_id.count > 0) ? combo.product_id[0] : 0
         var combo_product_id = combo.product_tmpl_id // (combo.product_tmpl_id.count > 0) ?  product_id_temp as? Int ?? 0 : 0
         if combo_product_id == 0
         {
         combo_product_id = combo.product_id
         }
         
         if tmpl_id == combo_tmpl_id  && product.id == combo_product_id
         {
         product.comob_extra_price = combo.extra_price
         
         
         if combo.auto_select_num > 0
         {
         product.app_selected = true
         product.qty_app = product.combo!.auto_select_num
         product.auto_select_num = product.combo!.auto_select_num
         product.default_product_combo = true
         
         //                        if product.combo!.pos_category_id.count > 0
         //                        {
         //                            let key =   product.combo!.pos_category_id[1] as? String ?? ""
         //    //                        comboSeletedItems!.AddOrMinusQty(section_key: key, arr: nil, product: product, plus: true)
         //                            product.qty_app = 1
         //                            comboSeletedItems!.addItem(section_key: key, product: product)
         //                        }
         
         }
         
         
         }
         
         }
         
         return product
         */
        
    }
    
}


