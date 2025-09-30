//
//  combo_list.swift
//  pos
//
//  Created by khaled on 10/12/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol combo_list_ver2_old_delegate {
    func combo_list_selected(product:productClass)
}

class combo_list_ver2_old: UIViewController ,UICollectionViewDataSource ,UICollectionViewDelegate , combo_listCell_ver2_delegate,combo_seleted_items_delegate ,enterBalance_delegate{
    
    @IBOutlet var collection: UICollectionView!
    private var list_collection: [String:[productClass]] = [:]
    var list_collection_keys:[String] = []
    
    @IBOutlet weak var view_items_seleted: UIView!
    @IBOutlet weak var seq_qty: UISegmentedControl!
    private let reuseIdentifier = "FlickrCell"
    let Require_header = "Require"
    
    var product_combo:productClass?
    
    var list_product: [Any] = []
    var list_combo_price:[Any] = []
    
    var qty : Double = 1.0
    var last_qty : Double = 1.0

    
    let con = api()
    
    var delegate:combo_list_ver2_old_delegate?
    var avalabile_combos:[[String:Any]]!
    
    var comboSeletedItems:combo_seleted_items?
    var avalibale_total_items = 0.0
    
    var keyboard :enterBalance!


    override func viewDidLoad() {
        super.viewDidLoad()
        
 initcombo()
        
    }
    
    
    
    func initcombo()
    {
        setSeqQty()
        initcomboSeletedItems()
        
        get_product_combo_prices()
        get_combo()
        
        if avalabile_combos != nil
        {
            get_products_InCombo(avalabile_combos: avalabile_combos)
            
            selectRequire()
            
            self.collection?.reloadData()
            
            comboSeletedItems!.list_collection_keys.append(Require_header)
            comboSeletedItems!.list_collection[Require_header] = list_collection[Require_header]
            comboSeletedItems!.avalibale_total_items = avalibale_total_items * qty
            comboSeletedItems!.reCheckCount()
        }
        
        
        if product_combo?.combo_edit == true
        {
            for item in product_combo!.list_product_in_combo
            {
                let dic = item as? [String:Any]
                let p = productClass(fromDictionary: dic!)
                
                let key =   p.combo!.pos_category_id[1] as? String ?? ""
                comboSeletedItems!.addItem(section_key: key, product: p)
                comboSeletedItems!.reCheckCount()
            }
            
        }
        
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
            qty = product_combo!.qty_app
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
        
        
        self.list_combo_price    =  api.get_last_cash_result(keyCash: "get_product_combo_prices")
        
        
    }
    
    
    func get_combo()
    {
        let list_combo:[[String:Any]] = api.get_last_cash_result(keyCash: "get_porduct_combo") as? [[String:Any]] ?? [[:]]
        avalabile_combos = self.get_avalalibe_combos(list_combo: list_combo)
     
    }
    
    
    
    func get_products_InCombo(avalabile_combos:[[String:Any]])
    {
        
        list_collection.removeAll()
        list_collection_keys.removeAll()


        for combo  in avalabile_combos
        {
            var list:[productClass] = []
            
            //            let require = combo["require"] as? Bool ?? false
            //            let no_of_items = combo["no_of_items"] as? Bool ?? false
            //            let product_ids:[Int] = combo["product_ids"] as! [Int]
            
            let cls_combo = comboClass(fromDictionary: combo)
            avalibale_total_items = avalibale_total_items + cls_combo.no_of_items
            
            
            let arr_products = get_product_item(combo: cls_combo)
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
                
                if cls_combo.pos_category_id.count > 0
                {
                    categ_name =   cls_combo.pos_category_id[1] as? String ?? ""
                }
                
                
                var newList = list_collection[categ_name]   ?? []
                newList.append(contentsOf: list)
                
                list_collection[categ_name] = newList
                
                list_collection_keys.append(categ_name)
                
            }
            
        }
        
 
        
        let list:[productClass] = list_collection[Require_header]  ?? []
        if list.count > 0
        {
            list_collection_keys.insert(Require_header, at: 0)
            
        }
        
        comboSeletedItems?.list_collection_keys = list_collection_keys
        
 
//        let sortedKeys = list_collection_keys.sorted(by: <)

//        list_collection_keys.removeAll()
//        list_collection_keys.append(contentsOf: sortedKeys)
        
    }
    
    func selectRequire()
    {
        var list:[productClass] = list_collection[Require_header]   ?? []
        let count = list.count
        
        
        if count == 0
        {
            
            return
        }
        
        
        for i in 0...count - 1
        {
            let product = list[i]
            
            product.app_require = true
            product.qty_app = 1.0
            
            list[i] = product
            
        }
        
        list_collection[Require_header] = list
        
    }
    
    func get_product_item(combo:comboClass) -> [productClass]
    {
        var list:[productClass] = []
        
        for id:Int  in combo.product_ids
        {
            for item in list_product
            {
                var product = productClass(fromDictionary: item as! [String : Any])
                
                if product.id == id
                {
                    product.combo = combo
                    
                    product = get_extraPrice(product: product )
                    
                    
                    if product_combo?.combo_edit == true
                    {
                        product = checkProductInList(product: product  )
                        
                    }
                    
                    
                    list.append(product)
                }
            }
            
            
        }
        
        return list
    }
    
    func checkProductInList(product:productClass ) -> productClass
    {
        
        if product_combo!.list_product_in_combo.count > 0 {
            
            let total_items = no_of_items_for_qty(combo: product.combo!)
            var calc_total = 0.0
            
            for item in product_combo!.list_product_in_combo
            {
                let dic = item as? [String:Any]
                let p = productClass(fromDictionary: dic!)
               
                if p.id == product.id
                {
                    
                    if total_items < calc_total + p.qty_app
                    {
                        p.qty_app = 0
                        p.app_selected = true
                    }
                    else
                    {
                        calc_total = calc_total + p.qty_app
                    }
                    
                    return p
                }
                
            }
        }
        
        
        return product
    }
    
    func get_avalalibe_combos( list_combo:[[String:Any]]) ->[[String:Any]]
    {
        var arr_avalalibe_combo:[[String:Any]] = []
        
        for item:Int in product_combo!.product_combo_ids
        {
            for combo_item:[String:Any] in list_combo
            {
                let id = combo_item["id"] as? Int ?? 0
                
                if item == id
                {
                    arr_avalalibe_combo.append(combo_item)
                }
                
            }
        }
        
        return arr_avalalibe_combo
    }
    
    
    
    func deleteProduct(indexPath: IndexPath)
    {
        let key = list_collection_keys [indexPath.section]
        var arr = list_collection[key] ?? []
        let obj = arr[indexPath.row]
        
        obj.qty_app = 0
        obj.app_selected = false
        
        arr[indexPath.row] = obj
        list_collection[key] = arr
        
        self.collection.reloadData()
    }
    
    func updateProduct(product:productClass, indexPath: IndexPath)
    {
        let key = list_collection_keys [indexPath.section]
        var arr = list_collection[key] ?? []
        
        arr[indexPath.row] = product
        list_collection[key] = arr
        
        self.collection.reloadData()
    }
    
    @IBAction func btnOk(_ sender: Any) {
        
        get_products_selected()
        //        get_products_extra_price()
        
        product_combo?.qty_app = qty
        delegate?.combo_list_selected(product: product_combo!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        
        if product_combo?.combo_edit == false
        {
            product_combo?.list_product_in_combo = []
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func get_products_selected()
    {
        product_combo?.list_product_in_combo = []
        
        product_combo?.price_app_priceList =   product_combo!.lst_price
        
        
        for key in comboSeletedItems!.list_collection_keys
        {
            let arr = comboSeletedItems!.list_collection[key] ?? []
            
            for row in arr
            {
                if row.qty_app > 0
                {
                    
                    if row.comob_extra_price != 0
                    {
                        
                        product_combo?.custome_price_app = true
//                        product_combo?.price_app_priceList =  product_combo!.price_app_priceList + ( row.comob_extra_price * row.qty_app)
                        product_combo?.price_app_priceList =  product_combo!.price_app_priceList +   row.comob_extra_price

                    }
                    
                    
                    product_combo?.list_product_in_combo.append(row.toDictionary())
                    
                    
                }
            }
            
        }
    }
    
    func get_extraPrice(product:productClass ) -> productClass {
        var product_new = product
        let product_tmpl_id = product_new.combo?.product_tmpl_id ?? []
        
        if product_tmpl_id.count > 0
        {
            
            let combo_tmpl_id = product_new.combo!.product_tmpl_id[0] as? Int
            
            product_new = get_extra_price(tmpl_id: combo_tmpl_id!,product: product_new)
            
            //        if product_new.comob_extra_price != 0
            //        {
            //            product_new.price_app_priceList = product_new.get_price_custome()
            //
            //            product_new.custome_price_app = true
            //            product_new.price_app_priceList =  product_new.price_app_priceList + product_new.comob_extra_price
            //
            //
            //        }
        }
        
        return product_new
    }
    
    
    
    func get_extra_price(tmpl_id:Int,product:productClass) -> productClass
    {
        for item in list_combo_price
        {
            let combo = comboClass(fromDictionary: item as! [String : Any])
            let combo_tmpl_id = (combo.product_tmpl_id.count > 0) ? combo.product_tmpl_id[0]  as? Int ?? 0 : 0
            let product_id_temp = ( combo.product_id.count > 0) ? combo.product_id[0] : 0
            let combo_product_id = (combo.product_tmpl_id.count > 0) ?  product_id_temp as? Int ?? 0 : 0
            
            if tmpl_id == combo_tmpl_id && product.id == combo_product_id
            {
                product.comob_extra_price = combo.extra_price
                
                
                if combo.auto_select_num > 0 && product_combo?.combo_edit == false
                {
                    product.app_selected = true
                    product.qty_app = combo.auto_select_num
                    product.auto_select_num = combo.auto_select_num
                    product.default_product_combo = true
                    
                    if product.combo!.pos_category_id.count > 0
                    {
                        let key =   product.combo!.pos_category_id[1] as? String ?? ""
//                        comboSeletedItems!.AddOrMinusQty(section_key: key, arr: nil, product: product, plus: true)
                        product.qty_app = 1
                        comboSeletedItems!.addItem(section_key: key, product: product)
                    }
                    
                }
                
                
            }
            
        }
        
        return product
    }
    

}

// MARK: - UICollectionViewDataSource

extension combo_list_ver2_old {
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
//        cell.combo_parent = self
        
        cell.updateCell()
        
        return cell
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let key = list_collection_keys [indexPath.section]
        var arr = list_collection[key] ?? []
        let product = arr[indexPath.row]
        
        comboSeletedItems!.AddOrMinusQty(section_key: key,  arr: arr, product: product, plus: true)
       

  
        
//        arr[indexPath.row] = product
//        list_collection[key] = arr
//
//        self.collection.reloadData()
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            
            //                let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            //                let headerView = collectionView  .dequeueReusableCell(withReuseIdentifier: "combo_listHeaderCell", for: indexPath) as! combo_listHeaderCell
            
            let headerView:combo_listHeaderCell_ver2 =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "combo_listHeaderCell", for: indexPath) as! combo_listHeaderCell_ver2
            
            let key = list_collection_keys[indexPath.section]
            
            var arr = list_collection[key] ?? []
            
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
        comboSeletedItems?.avalibale_total_items = avalibale_total_items * qty
        
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
    
    func no_of_items_for_qty(combo:comboClass) -> Double
    {
        return   combo.no_of_items  * qty
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


