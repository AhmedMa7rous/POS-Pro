//
//  combo_list.swift
//  pos
//
//  Created by khaled on 10/12/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol combo_list_delegate {
    func combo_list_selected(product:productProductClass)
}

class combo_list: UIViewController ,UICollectionViewDataSource ,UICollectionViewDelegate , combo_listCell_delegate {
    
    @IBOutlet var collection: UICollectionView!
    private var list_collection: [String:Any] = [:]
    var list_collection_keys:[String] = []
    
    @IBOutlet weak var seq_qty: UISegmentedControl!
    private let reuseIdentifier = "FlickrCell"
    let Require_header = "Require"
    
    var product_combo:productProductClass?
    
    var list_product: [Any] = []
    var list_combo_price:[Any] = []
    
    var qty : Double = 1.0
    
    let con = api()
    
    var delegate:combo_list_delegate?
    var avalabile_combos:[[String:Any]]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSeqQty()
        
        get_product_combo_prices()
        get_combo()
        
        if avalabile_combos != nil
        {
            get_products_InCombo(avalabile_combos: avalabile_combos)
            
            selectRequire()
            
            self.collection?.reloadData()
            
         
        }
        
        
        
    }
    
    func setSeqQty()
    {
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
        
        
        self.list_combo_price    =  productComboPriceClass.getAll() //api.get_last_cash_result(keyCash: "get_product_combo_prices")
        
        
    }
    
    
    func get_combo()
    {
        let list_combo:[[String:Any]] = productComboClass.getAll() // api.get_last_cash_result(keyCash: "get_porduct_combo") as? [[String:Any]] ?? [[:]]
        avalabile_combos = self.get_avalalibe_combos(list_combo: list_combo)
     
    }
    
    
    
    func get_products_InCombo(avalabile_combos:[[String:Any]])
    {
        
        list_collection.removeAll()
        list_collection_keys.removeAll()

        
        for combo  in avalabile_combos
        {
            var list:[productProductClass] = []
            
            //            let require = combo["require"] as? Bool ?? false
            //            let no_of_items = combo["no_of_items"] as? Bool ?? false
            //            let product_ids:[Int] = combo["product_ids"] as! [Int]
            
            let cls_combo = productComboClass(fromDictionary: combo)
            
            let arr_products = get_product_item(combo: cls_combo)
            list.append(contentsOf: arr_products)
            
            if cls_combo.require == true
            {
                var newList = list_collection[Require_header] as? [Any] ?? []
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
                
                
                var newList = list_collection[categ_name] as? [Any] ?? []
                newList.append(contentsOf: list)
                
                list_collection[categ_name] = newList
                
                list_collection_keys.append(categ_name)
                
            }
            
        }
        
 
        
        let list:[productProductClass] = list_collection[Require_header] as? [productProductClass] ?? []
        if list.count > 0
        {
            list_collection_keys.insert(Require_header, at: 0)
            
        }
        
 
        
        
    }
    
    func selectRequire()
    {
        var list:[productProductClass] = list_collection[Require_header] as? [productProductClass] ?? []
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
    
    func get_product_item(combo:productComboClass) -> [productProductClass]
    {
        var list:[productProductClass] = []
        
        for id:Int  in combo.product_ids
        {
            for item in list_product
            {
                var product = productProductClass(fromDictionary: item as! [String : Any])
                
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
    
    func checkProductInList(product:productProductClass ) -> productProductClass
    {
        
        if product_combo!.list_product_in_combo.count > 0 {
            
            let total_items = no_of_items_for_qty(combo: product.combo!)
            var calc_total = 0.0
            
            for item in product_combo!.list_product_in_combo
            {
                let dic = item as? [String:Any]
                let p = productProductClass(fromDictionary: dic!)
               
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
    
    func checkTotalOfSection(indexPath: IndexPath ) -> Bool
    {
        let key = list_collection_keys [indexPath.section]
        var arr = list_collection[key] as! [productProductClass]
        
        let obj = arr[0]
        if no_of_items_for_qty(combo:  obj.combo!)  == 1
        {
            for i in 0...arr.count - 1
            {
                let item = arr[i]
                if  item.app_selected == true
                {
                    item.qty_app = 0
                    item.app_selected = false
                    arr[i] = item
                    list_collection[key] = arr
                    self.collection.reloadData()
                    
                    
                }
            }
            
            return true
        }
        else
        {
            var total:Double = 0
            for item in arr
            {
                total = total + item.qty_app
            }
            
            
            
            if no_of_items_for_qty(combo:obj.combo!)  > total {
                return true
            }
            else
            {
                return false
            }
            
        }
        
        
        
    }
    
    func deleteProduct(indexPath: IndexPath)
    {
        let key = list_collection_keys [indexPath.section]
        var arr = list_collection[key] as! [productProductClass]
        let obj = arr[indexPath.row]
        
        obj.qty_app = 0
        obj.app_selected = false
        
        arr[indexPath.row] = obj
        list_collection[key] = arr
        
        self.collection.reloadData()
    }
    
    func updateProduct(product:productProductClass, indexPath: IndexPath)
    {
        let key = list_collection_keys [indexPath.section]
        var arr = list_collection[key] as! [productProductClass]
        
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
        product_combo?.comob_extra_price = 0
        
        for key in list_collection_keys
        {
            let arr = list_collection[key] as? [productProductClass] ?? []
            
            for row in arr
            {
                if row.qty_app > 0
                {
                    
                    if row.comob_extra_price != 0
                    {
                        
                        product_combo?.custome_price_app = true
//                        product_combo?.price_app_priceList =  product_combo!.price_app_priceList + ( row.comob_extra_price * row.qty_app)
                        product_combo?.comob_extra_price =  product_combo!.comob_extra_price +  ( row.comob_extra_price * row.qty_app)
                    
                    }
                    
                    
                    product_combo?.list_product_in_combo.append(row.toDictionary())
                    
                    
                }
            }
            
        }
    }
    
    func get_extraPrice(product:productProductClass ) -> productProductClass {
        var product_new = product
        let product_tmpl_id = product_new.combo?.product_tmpl_id
        
        if product_tmpl_id != 0
        {
            
            let combo_tmpl_id = product_new.combo!.product_tmpl_id
            
            product_new = get_extra_price(tmpl_id: combo_tmpl_id,product: product_new)
            
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
    
    /*
     func get_products_extra_price()
     {
     if product!.list_product_in_combo.count == 0 {return}
     
     for i in 0...product!.list_product_in_combo.count - 1
     {
     let item = product!.list_product_in_combo[i]
     
     let p = productClass(fromDictionary: item as! [String : Any])
     let product_tmpl_id = p.combo?.product_tmpl_id ?? []
     
     if product_tmpl_id.count > 0
     {
     let combo_tmpl_id = p.combo?.product_tmpl_id[0] as? Int
     
     let extra_price = get_extra_price(tmpl_id: combo_tmpl_id!,product_id: p.id)
     
     if extra_price != 0
     {
     product?.price_app_priceList = product?.get_price()
     
     product?.custome_price_app = true
     product?.price_app_priceList =  product!.price_app_priceList + extra_price
     
     p.comob_extra_price = extra_price
     
     product!.list_product_in_combo[i] = p.toDictionary()
     
     }
     }
     
     
     
     }
     
     
     }
     */
    
    func get_extra_price(tmpl_id:Int,product:productProductClass) -> productProductClass
    {
        for item in list_combo_price
        {
            let combo = productComboClass(fromDictionary: item as! [String : Any])
            let combo_tmpl_id = combo.product_tmpl_id // (combo.product_tmpl_id.count > 0) ? combo.product_tmpl_id[0]  as? Int ?? 0 : 0
            let product_id_temp =  combo.product_id // ( combo.product_id.count > 0) ? combo.product_id[0] : 0
            var combo_product_id = combo.product_tmpl_id // (combo.product_tmpl_id.count > 0) ?  product_id_temp as? Int ?? 0 : 0
            if combo_product_id == 0
            {
                combo_product_id = product_id_temp
            }
            
            
            if tmpl_id == combo_tmpl_id && product.id == combo_product_id
            {
                product.comob_extra_price = combo.extra_price
                
                
                if combo.auto_select_num > 0 && product_combo?.combo_edit == false
                {
                    product.app_selected = true
                    product.qty_app = combo.auto_select_num
                    product.default_product_combo = true
                }
            }
            
        }
        
        return product
    }
    
    
}

// MARK: - UICollectionViewDataSource

extension combo_list {
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return list_collection_keys.count
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        let key = list_collection_keys [section]
        let arr = list_collection[key] as? [Any] ?? []
        
        return arr.count
        
    }
    
    //3
    func collectionView(  _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath  ) -> UICollectionViewCell {
        let cell = collectionView  .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! combo_listCell
        //        cell.backgroundColor = .lightGray
        // Configure the cell
        
        let key = list_collection_keys [indexPath.section]
        let arr = list_collection[key] as! [productProductClass]
        let product = arr[indexPath.row]
        
        
        
        cell.product = product
        cell.delegate = self
        cell.indexPath = indexPath
        cell.combo_parent = self
        
        cell.updateCell()
        
        return cell
    }
    
    func AddOrMinusQty(product:productProductClass ,indexPath: IndexPath,plus:Bool) -> productProductClass
    {
        if product.app_require == false
        {
            if plus == true
            {
                if checkTotalOfSection(indexPath: indexPath) == false
                {
                    return product
                }
            }
            
            
            if product.app_selected == true
            {
                if product.qty_app == 0
                {
                    product.app_selected  = false
                }
                else
                {
                    if plus == true
                    {
                        product.qty_app += 1
                        
                    }
                    else
                    {
                        product.qty_app -= 1
                        
                    }
                }
                
            }
            else
            {
                product.app_selected = true
                product.qty_app = 1
            }
            
            
            
        }
        
        return product
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let key = list_collection_keys [indexPath.section]
        var arr = list_collection[key] as! [productProductClass]
        var product = arr[indexPath.row]
        
        //        let product = productClass(fromDictionary: obj as! [String : Any])
        
        product =   AddOrMinusQty(product: product, indexPath: indexPath,plus: true)
        
        
        arr[indexPath.row] = product
        list_collection[key] = arr
        
        self.collection.reloadData()
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            
            //                let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            //                let headerView = collectionView  .dequeueReusableCell(withReuseIdentifier: "combo_listHeaderCell", for: indexPath) as! combo_listHeaderCell
            
            let headerView:combo_listHeaderCell =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "combo_listHeaderCell", for: indexPath) as! combo_listHeaderCell
            
            let key = list_collection_keys[indexPath.section]
            
            var arr = list_collection[key] as? [productProductClass] ?? []
            
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
        qty = Double(seq_qty.selectedSegmentIndex + 1)
        
        if avalabile_combos != nil
        {
            get_products_InCombo(avalabile_combos: avalabile_combos)
        }
        
        self.collection.reloadData()
        
    }
    
    func no_of_items_for_qty(combo:productComboClass) -> Double
    {
        return   Double(combo.no_of_items)  * qty
    }
    
}


