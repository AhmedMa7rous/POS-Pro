//
//  combo_vc.swift
//  pos
//
//  Created by Khaled on 8/6/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
enum section_type {
    case variant,combo,note
}

protocol combo_vc_delegate {
    func combo_list_selected(line:pos_order_line_class,check_by_line: Bool,check_last_row:Bool,reload_list:Bool,show_promotion:Bool ,fristShow:Bool)
}
struct section_view {
    var index_row:Int = 0
    var title:String!
    var type:section_type!
    
    
    
}
class combo_vc: UIViewController {
    
    let con = SharedManager.shared.conAPI()
    
    @IBOutlet var view_info: UIView!
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet var btnOK: KButton!
    
    var parent_create_order:create_order?
    
    var list_collection: [String:[product_product_class]]! = [:]
    var list_attribute: [String:[product_attribute_value_class]]! = [:]
    var list_notes: [pos_product_notes_class] = []
    
    var list_collection_keys:[section_view]! = []
    
    var products_auto_select_default_combo:[String:[product_product_class]]! = [:]
    
//    var lines_defualt_select_combo: [pos_order_line_class]  = [ ]
    
    var list_selected:[String:[pos_order_line_class]] = [:]
    
    var list_attribute_selected:[Int:product_attribute_value_class] = [:]
    var list_notes_selected: [Int:pos_product_notes_class] = [:]
    
    
    let reuseIdentifier = "FlickrCell"
    let Require_header = "Require"
    
    var product_combo:pos_order_line_class?
    
    var order_id:Int!
    var fristShow:Bool = false

    //    var list_combo_price:[Any]! = []
    
    var qty : Double = 1.0
    var last_qty : Double = 1.0
    
    var delegate:combo_vc_delegate?
    var avalabile_combos:[[String:Any]]?
    //    var comboSeletedItems:combo_seleted_items?
    @IBOutlet var lbl_title: UILabel!
    
    @IBOutlet var btn_plus: KButton!
    @IBOutlet var txt_qty: UITextField!
    @IBOutlet var btn_minus: KButton!
    @IBOutlet var btn_new: KButton!
    
    @IBOutlet var btn_stock: KButton!
    
    @IBOutlet weak var btnEditPromotion: KButton!
    var numer_of_call_product_item_calc = 0
    let setting = SharedManager.shared.appSetting()
    var  newNote = ""

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        list_attribute_selected.removeAll()
        list_notes_selected.removeAll()
        list_selected.removeAll()
        products_auto_select_default_combo.removeAll()
        list_collection_keys.removeAll()
        list_notes.removeAll()
        list_attribute.removeAll()
        list_collection.removeAll()
        avalabile_combos?.removeAll()
        delegate = nil
        
//        list_collection = nil
//        list_collection_keys = nil
        product_combo = nil
        
        //        list_combo_price = nil
        avalabile_combos = nil
        
        //           comboSeletedItems = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        
    }
    
    @IBAction func btnEditPromotion(_ sender: Any) {
        
        parent_create_order!.handle_promotion(line: product_combo)
    }
    
    func reload_combo()
    {
        if product_combo!.id != 0
        {
            pos_order_line_class.void_lines_combo(line_id: product_combo!.id ,order_id:product_combo!.order_id,void_status: .update_from_query)
            
        }
        
        product_combo!.combo_edit = false
        product_combo?.products_InCombo.removeAll()
        product_combo?.selected_products_in_combo.removeAll()
        product_combo?.product_id =   get_protduct_id()
        product_combo?.product_tmpl_id = product_combo?.product_tmpl_id
        
        
        let list_variants_key  = list_collection_keys.filter({$0.type == .variant})
        
        //        let exist_variants_key =  list_collection_keys.first(where: {$0.type == .variant})
        let exist_note_key =  list_collection_keys.first(where: {$0.type == .note})
        var list_variants:[String:[product_product_class]] = [:]
        var list_notes:[product_product_class] = []
        
        if list_variants_key.count > 0
        {
            
            for v in list_collection_keys
            {
                //                list_variants =   list_collection[exist_variants_key!.title!] ?? []
                let arr = list_collection[v.title!] ?? []
                list_variants[v.title!] = arr
            }
            
        }
        
        if exist_note_key != nil
        {
            list_notes =   list_collection[exist_note_key!.title!] ?? []
            
        }
        
        list_notes_selected.removeAll()
        product_combo?.note = ""
        
        list_collection.removeAll()
        list_collection_keys.removeAll()
        
        //        list_collection_keys.append(exist_variants_key!)
        //        list_collection[exist_variants_key!.title!] = list_variants
        
        list_collection_keys.append(contentsOf: list_variants_key)
        for v in list_variants_key
        {
            list_collection[v.title!] = list_variants[v.title]
        }
        
        
        
        
        products_auto_select_default_combo.removeAll()
        
        list_selected.removeAll()
//        lines_defualt_select_combo.removeAll()
        
        init_combo(reload: true)
        
        
        list_collection_keys.append(exist_note_key!)
        list_collection[exist_note_key!.title!] = list_notes
        
        
        if  product_combo!.id != 0
        {
            product_combo!.combo_edit = true
        }
        
    }
    
    
    @IBAction func tapOnEditQtyBtn(_ sender: UIButton) {
       // if setting.enable_UOM_kg {
            self.show_edit_qty_popup(qty:Double(self.txt_qty.text ?? "0") ?? 0, sender)
      //  }
    }
    
    func show_edit_qty_popup(qty:Double,_ sender: UIView)
    {
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        guard let enterBalanceVC = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew else{return}
        enterBalanceVC.modalPresentationStyle = .popover
        
        enterBalanceVC.delegate = self
        enterBalanceVC.key = "edit_qty"
        enterBalanceVC.title_vc =  LanguageManager.text("Enter new quantity", ar: "أدخل كمية جديدة")
        if qty != 0
        {
            enterBalanceVC.initValue  = "\(qty.rounded_double(toPlaces: 3))"
            
        }
        enterBalanceVC.disable = false
        
        let popover = enterBalanceVC.popoverPresentationController!
        popover.permittedArrowDirections = .up
        popover.sourceView = sender
        popover.sourceRect =  sender.bounds
        
        self.present(enterBalanceVC, animated: true, completion: nil)
    }
    func openEditQtyVC(_ sender: UIView){
        let editQtyVC = EditQtyRouter.createModule(sender, initQty:self.txt_qty.text )
        editQtyVC.completionBlock = { (qty) in
            if let qtyDouble =  qty?.toDouble() {
                self.txt_qty.text = qty
                self.qty = qtyDouble
                self.change_qty(new_value: qtyDouble)
                self.collection.reloadData()
                self.done(removeFromSuperview: false,show_promotion: false)
            }
            
        }
        present(editQtyVC, animated: true, completion: nil)


    }
    
    
    func checkBtnPromotion()
    {
        btnEditPromotion.isHidden = true
        
        if let order_type_id =  parent_create_order?.orderVc?.order.orderType?.id {
        if product_combo?.id != 0
        {
            let filter = promotionSelectFilter(_product_id: product_combo!.product_id!,_podId: parent_create_order!.orderVc!.order.pos_id!,_orderType: order_type_id, _promotion_id: nil )
         
            if filter.isHavePromotion() //product_combo!.is_promotion && product_combo!.promotion_row_parent == product_combo!.id
            {
                btnEditPromotion.isHidden = false
            }
        }
        }
    }
    func init_combo(reload:Bool = false)
    {

        checkBtnPromotion()
         
        
        qty = product_combo?.qty ?? 1
        
        if qty == 0
        {
            qty =  1
        }
        
        lbl_title?.text = product_combo?.product.title
        txt_qty?.text = "\(qty)"
        
        if product_combo?.is_combo_line == true && product_combo?.parent_line_id != 0
        {
            view_info.isHidden = true
        }
        else
        {
            view_info.isHidden = false
            
        }
        
        if product_combo?.product.type != "product"
        {
            btn_stock.isHidden = true
            
        }
        else
        {
            btn_stock.isHidden = false
            
        }
        
        
        
        if reload == false
        {
            load_variant()
            
            let selected_variant = get_variant_item_selected()
            if selected_variant != nil
            {
                product_combo?.attribute_value_id = selected_variant?.id
            }
            
            
        }
        
        
        load_combo()
        
        if reload == false
        {

                self.load_notes()
        }
        
        
        
        
    }
    
    
    
    //       func deleteProduct(indexPath: IndexPath)
    //        {
    //            let key = list_collection_keys [indexPath.section]
    //            var arr = list_collection[key] ?? []
    //            let obj = arr[indexPath.row]
    //
    //    //        obj.qty_app = 0
    //            obj.app_selected = false
    //
    //            arr[indexPath.row] = obj
    //            list_collection[key] = arr
    //
    //            self.collection.reloadData()
    //        }
    //
    //        func updateProduct(product:product_product_class, indexPath: IndexPath)
    //        {
    //            let key = list_collection_keys [indexPath.section]
    //            var arr = list_collection[key] ?? []
    //
    //            arr[indexPath.row] = product
    //            list_collection[key] = arr
    //
    //            self.collection.reloadData()
    //        }
    
    //        func selected_items(count:Int) {
    //            if count == 0
    //            {
    //                btnOK.isEnabled = false
    //                btnOK.setBackgroundColor_base(base: UIColor.lightGray)
    //
    //            }
    //            else
    //            {
    //                btnOK.isEnabled = true
    //                btnOK.setBackgroundColor_base(base: UIColor.init(hexString: "#0CC579"))
    //
    //            }
    //        }
    
    @IBAction func btnOk(_ sender: Any) {
        
        
   
        if product_combo?.id == 0
        {
            done(removeFromSuperview: true,show_promotion:true)
            
        }
        else
        {
            if fristShow
            {
                done(removeFromSuperview: true,show_promotion:true)
            }
        }
     
        
        parent_create_order?.clear_right()
        
    }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        
        if product_combo?.combo_edit == false
        {
            product_combo?.selected_products_in_combo = []
        }
        
        self.view.removeFromSuperview()
        //            self.dismiss(animated: true, completion: nil)
        
    }
    
    func done(removeFromSuperview:Bool,show_promotion: Bool = false) {
        if product_combo?.is_combo_line == true
        {
            combo_done(removeFromSuperview,show_promotion:show_promotion)
        }
        else if product_combo?.is_combo_line == true  && product_combo?.parent_line_id != 0
        {
            product_done(removeFromSuperview,show_promotion:show_promotion)
        }
        else
        {
            product_done(removeFromSuperview,show_promotion:show_promotion)
        }
    }
    
    func product_done(_ removeFromSuperview:Bool,show_promotion: Bool)
    {
        self.view.endEditing(true)
        let product_id =   get_protduct_id()
        if product_id != nil
        {
            product_combo?.last_product_id =  product_combo?.product_id
            product_combo?.product_id = product_id
        }
        
        //        if product_combo?.pos_multi_session_status == .sended_update_to_server
        //        {
        //            product_combo?.last_qty = product_combo?.qty ?? 0
        //
        //        }
        
        product_combo?.write_info = true
        
//        if product_combo?.promotion_row_parent == 0
//        {
            product_combo?.qty  = qty
            product_combo?.price_unit = product_combo?.product.price
            product_combo?.update_values()
//        }
//        else if product_combo?.promotion_row_parent != 0 && product_combo?.discount != 0
//        {
//
//            product_combo?.qty  = qty
//            product_combo?.update_values_discount_line()
//
//        }

        
        delegate?.combo_list_selected(line: product_combo!,check_by_line: true,check_last_row:false,reload_list: true,show_promotion: show_promotion,fristShow:fristShow)
        if removeFromSuperview
        {
            
            self.view.removeFromSuperview()
            parent_create_order?.clear_right()
            
        }
        
    }
    
    func combo_done(_ removeFromSuperview:Bool,show_promotion: Bool)
    {
        
        let product_id =   get_protduct_id()
        if product_id != nil
        {
            product_combo?.product_id = product_id
        }
        
        product_combo?.printed = .none
        
        get_products_selected()
        
        if product_combo!.selected_products_in_combo.count > 0
        {
            product_combo?.qty  = qty
            
            product_combo!.selected_products_in_combo = product_combo!.selected_products_in_combo.sorted(by: {$0.id < $1.id})
            for combo_line in product_combo!.selected_products_in_combo
            {
                combo_line.write_info = true
                
                combo_line.update_values()
            }
            
            product_combo?.update_values()
            
            
            delegate?.combo_list_selected(line: product_combo!,check_by_line: true,check_last_row:false,reload_list: false,show_promotion: show_promotion,fristShow:fristShow)
            
            
            
        }
        else
        {
            product_combo?.qty  = qty
            
            delegate?.combo_list_selected(line: product_combo!,check_by_line: true,check_last_row:false,reload_list: false,show_promotion: show_promotion,fristShow:fristShow)
            
        }
        
        
        if removeFromSuperview
        {
            self.view.removeFromSuperview()
            parent_create_order?.clear_right()
            
        }
        
    }
    
    //    func update_products_void()
    //    {
    //        // in create
    //        if product_combo?.id == 0
    //        {
    //            return
    //        }
    //
    //        var ids =  String(  product_combo!.id)
    //        for line in product_combo!.list_product_in_combo
    //        {
    //            ids = ids + "," + String( line.id)
    //        }
    //
    ////        ids.removeFirst()
    //
    //        pos_order_line_class.void_all_execlude(lines: ids)
    //        //            pos_order_line_class.void_all_execlude(products: ids, order_id: order_id, parent_product_id: product_combo!.product_id!,pos_multi_session_status: nil,parent_line_id: (product_combo?.id)!)
    //    }
    //
    
    
    
    
    func get_products_selected()
    {
        
        
        product_combo?.selected_products_in_combo.removeAll()
        
        if product_combo?.pos_promotion_id == 0
        {
            product_combo?.price_unit! =   product_combo!.product.price
        }
        
        var total_extraPrice:Double = 0.0
        
        var ids =  String(  product_combo!.id)
        
        
        for (key,val) in list_selected
        {
            let arr = val //list_selected[key] ?? []
            var lst:[pos_order_line_class] = []
            
            for row in arr
            {
                
                if row.qty  == 0
                {
                   // row.void_status = .update_from_query
                    row.is_void = true
                    _ = row.save(write_info: true )
                    
                }
                
                
                if row.is_void == false
                {
                    
                    
                    lst.append(row)
                    
                    ids = ids + "," + String( row.id)
                    
                    if row.extra_price != 0
                    {
                        total_extraPrice = total_extraPrice + ( row.extra_price! * row.qty )
                        
                    }
                    
                    
                    row.parent_product_id = product_combo?.product_id
                    row.is_combo_line = true
                    row.pos_multi_session_status = .last_update_from_local
                    
                    product_combo?.selected_products_in_combo.append(row)
                }
                
                
                
            }
            
            
            
            list_selected[key] = lst
            
            
            
        }
        
        
        
        //        product_combo?.custome_price_app = true
        //        product_combo?.price_unit  = ( product_combo!.price_unit! * qty) +  total_extraPrice
        product_combo?.qty = qty
        
        if product_combo?.pos_promotion_id == 0
        {
            product_combo?.price_unit! =   product_combo!.product.price
            
        }
        
        // exclude dilervey id
        let orderTypeID = self.parent_create_order?.orderVc?.order.orderType?.id
        let delivery_id = delivery_type_class.getDeliveryProduct(for: orderTypeID)
        let lineDelivery = pos_order_line_class.get(order_id: order_id, product_id: delivery_id.delivery_product_id)
        if(lineDelivery != nil)
        {
            ids = ids + "," + String(  lineDelivery!.id)
        }


        pos_order_line_class.void_all_execlude(lines: ids,order_id:order_id, order_uid: nil ,_delete_discount: false,void_status: .update_from_query)
        
        
    }
    
    
    
    @IBAction func btn_void(_ sender: Any) {
        
        if  self.product_combo?.id == 0
        {
            btnCancel(AnyClass.self)
            
            return
        }
        
        self.parent_create_order?.orderVc?.delete_Row(line:  self.product_combo!)
        self.view.removeFromSuperview()
    }
    
    @IBAction func btn_new(_ sender: Any) {
        
        if product_combo?.promotion_row_parent != 0
        {
            messages.showAlert("Can't edit qty in promotion item")
            return
        }
        
        
        if  self.product_combo?.id == 0
        {
            
            done(removeFromSuperview: false,show_promotion: false)
            
            //                btnOk(AnyClass.self)
            //                  return
        }
        
        //        if product_combo?.qty == 1
        //        {
        //            return
        //        }
        //
        //        product_combo?.qty -= 1
        self.product_combo?.update_values()
        
        //        let q = txt_qty.text?.toDouble() ?? 1
        
        let new_product = pos_order_line_class(fromDictionary: (product_combo?.toDictionary())!)
        new_product.qty = 1
        new_product.last_qty = 0
        new_product.id = 0
        new_product.combo_edit = false
        new_product.is_combo_line = product_combo?.is_combo_line
        new_product.selected_products_in_combo = []
        new_product.uid = ""
        if let repeat_line = new_product.get_max_line_repeat(){
            new_product.line_repeat = repeat_line + 1
        }
 
        
        for (_,list) in products_auto_select_default_combo
        {
            for product in list
            {
                let line = create_line(product: product)
                new_product.selected_products_in_combo.append(line)
            }
            
        }
        
        
//        new_product.selected_products_in_combo.append(contentsOf: lines_defualt_select_combo)
        
        //        new_product.selected_products_in_combo.append(contentsOf: product_combo!.selected_products_in_combo)
        
//                if new_product.selected_products_in_combo.count > 0
//                {
//                    for i in  0...new_product.selected_products_in_combo.count  - 1
//                         {
//                             let line = new_product.selected_products_in_combo[i]
//                             line.id = 0
////                             line.parent_line_id = 0
////                             line.qty = q
//                             new_product.selected_products_in_combo[i] = line
//                         }
//
//                }
        
        new_product.note = ""
        
        delegate?.combo_list_selected(line: new_product,check_by_line: true,check_last_row:false,reload_list: true,show_promotion: false,fristShow:fristShow)
        //        self.view.removeFromSuperview()
        
    }
    
    
    
    func add_defualt_combo_with_increases()
    {
        
        
        for (key,list) in products_auto_select_default_combo
        {
            for product in list
            {
                let sec = section_view.init(index_row: 0, title: key, type: .combo)
                AddOrMinusQty(product: product, plus: true, section: sec)
            }
            
        }
        
    }
    
    func change_qty(new_value:Double)
    {
        list_selected.removeAll()
        setSutoSelect(get_defualt: false,multiply_qty: Int(new_value))
        //        product_combo?.selected_products_in_combo.append(contentsOf: lines_defualt_select_combo)
        
        //        for item in  lines_defualt_select_combo
        //        {
        //            let new_line = pos_order_line_class(fromDictionary: item.toDictionary())
        //            new_line.qty = new_line.qty * new_value
        ////            product_combo?.selected_products_in_combo.append(new_line)
        //        }
        
    }
    
    @IBAction func btn_plus(_ sender: Any) {
        
        if (product_combo?.pos_promotion_id != 0 && product_combo?.discount == 0) || product_combo!.is_promotion
        {
            messages.showAlert("Can't edit qty in promotion item")
            return
        }
        
        qty = Double(txt_qty.text ?? "0.0") ?? 0
        qty += 1
        
        txt_qty.text = "\(qty)"
        
        change_qty(new_value: qty)
        //        add_defualt_combo_with_increases()
        
        
        collection.reloadData()
        
        done(removeFromSuperview: false,show_promotion: false)
        
        checkBtnPromotion()
    }
    func completationDecreaseQty(){
        if (product_combo?.pos_promotion_id != 0 && product_combo?.discount == 0) || product_combo!.is_promotion
        {
            messages.showAlert("Can't edit qty in promotion item")
            return
        }
        
        qty = Double(txt_qty.text ?? "0.0") ?? 0
        qty -= 1
        if qty <= 0
        {
            qty =  1
        }
        
        txt_qty.text = "\(qty)"
        
        //        reCheckCount()
        change_qty(new_value: qty)
        
        collection.reloadData()
        done(removeFromSuperview: false,show_promotion: false)
            
    }
    func checkDecreaseRule(completion:@escaping()->()){
        if let line =  self.product_combo, line.id > 0 {
            SharedManager.shared.premission_for_decrease_qty(line: line,vc: self) {
            DispatchQueue.main.async {
                completion()
            }
        }
        }else{
            completion()
        }

    }
    
    @IBAction func btn_minus(_ sender: Any) {
        checkDecreaseRule {
            self.completationDecreaseQty()
        }
    }
    
    @IBAction func btn_stock(_ sender: Any) {
        
       // get_stock(product_id:product_combo!.product_id!)
    }
    
}


extension combo_vc: enterBalance_delegate{
    func newBalance(key:String,value:String){
        if let qtyDouble =  Double(value) {
            if qtyDouble < self.qty  {
                checkDecreaseRule {
                    self.completeEnterQty(value:value,qtyDouble:qtyDouble)
                }
            }else{
                self.completeEnterQty(value:value,qtyDouble:qtyDouble)
            }
        }
    }
    func completeEnterQty(value:String,qtyDouble:Double){
        self.txt_qty.text = value
        self.qty = qtyDouble
        self.change_qty(new_value: qtyDouble)
        self.collection.reloadData()
        self.done(removeFromSuperview: false,show_promotion: false)
    }
}
