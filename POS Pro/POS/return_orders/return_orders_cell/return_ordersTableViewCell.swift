//
//  return_ordersTableViewCell.swift
//  pos
//
//  Created by Khaled on 4/9/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class return_ordersTableViewCell: UITableViewCell {
    
    @IBOutlet var lblTitle: KLabel!
    @IBOutlet var lblCateg: KLabel!
    @IBOutlet var lblPrice: KLabel!
    @IBOutlet var img_select: KSImageView!
    
    @IBOutlet var lbl_qty: UILabel!

    @IBOutlet var btn_scrap: KButton!
    @IBOutlet var stepper: UIStepper!
    //     var priceList :product_pricelist?
    
    var parent:return_orders?
    var list_items:[pos_order_line_class] = []
   private var product :pos_order_line_class!
    var orderClass:pos_order_class?

    var index:Int?
    var total_extra_price:Double = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCell() {
        total_extra_price = 0
        
        product = list_items[index!]
        
        if   product.tag_temp != nil
        {
            img_select.isHighlighted = true
        }
        else
        {
            img_select.isHighlighted = false
        }
        
        
        
        
        
        let currency = product.product.currency_name   ?? ""
        
        
        
        var normalText =  product.product.title  //String( format: "%@  %@  %@" ,product.qty_app.toIntString(), "x" , product.title )
        
        btn_scrap.isEnabled = true
        stepper.isEnabled = true

        if (product.tag_temp ?? "") == "returned"
        {
            normalText = "Returned  -> " + normalText
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            btn_scrap.isEnabled = false
            stepper.isEnabled = false
        }
        if product.is_scrap == true {
            btn_scrap.setTitleColor(UIColor.white, for: .normal)
//            btn_scrap.backgroundColor_base = UIColor.init(hexString: "#FF7600")
            btn_scrap.backgroundColor = UIColor.init(hexString: "#FF7600")
        }else{
            btn_scrap.setTitleColor(UIColor.init(hexString: "#898989"), for: .normal)
//            btn_scrap.backgroundColor_base = UIColor.init(hexString: "#E5E5E5")
            btn_scrap.backgroundColor = UIColor.init(hexString: "#E5E5E5")

        }
        
        let boldText  =  String( format: "%@  %@ " ,product.qty.toIntString(), "X" )
        
        let attributedString = NSMutableAttributedString(string:"")
        
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
        let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
        let normalString = NSMutableAttributedString(string: normalText)
        
        attributedString.append(boldString)
        attributedString.append(normalString)
        
        lblTitle?.attributedText = attributedString
        lblCateg?.text = "" //String( format:"%@ %@ at %@  %@/%@", product.qty_app.toIntString(), unite
        if product.discount != 0
        {
            lblCateg.text =  String( format:"%@ , With a %@ %@ discount", lblCateg.text! , product.discount!.toIntString(),"%")
            
        }
        
        
        
        stepper.minimumValue = 1
//        let qty =  product.qty
        let productQty = getQty(for:product)

        product.max_qty_app =  product.max_qty_app ?? productQty
        stepper.maximumValue = product.max_qty_app ?? productQty
        stepper.value = productQty
          lbl_qty.text = String(format: " %@/%@", productQty.toIntString(),  product.max_qty_app!.toIntString())
        
        get_combo()
        
        get_notes()
        
        if currency.lowercased().contains("sar"){
            lblPrice?.attributedText = SharedManager.shared.getRiayalSymbol(total: baseClass.currencyFormate(product.price_subtotal_incl! + total_extra_price) )

        }else{
            lblPrice?.text = String( format:"%@ %@" , baseClass.currencyFormate(product.price_subtotal_incl! + total_extra_price) ,currency)
        }

        
    }
    
    func get_notes()
    {
        var line:String = ""
        
        if !(product.note ?? "").isEmpty
        {
            line = product.note!.replacingOccurrences(of: "\n", with: " - ")
        }
        
        
        
        
//        if line.isEmpty {return}
        
        if   lblCateg.text!.isEmpty
        {
            lblCateg.text = line
            
        }
        else
        {
            lblCateg.text = String(format: "%@ - %@",    lblCateg.text!   , line)
            
        }
        
        var note_promotion = ""
        if product.discount != 0
        {
            if product.discount_type == .percentage
            {
                if !(product.discount_display_name  ?? "").isEmpty
                {
                    note_promotion = product.discount_display_name!

                }
                else
                {
                    note_promotion  =  String( format:" With a %@ %@ discount"  , product.discount!.toIntString(),"%")
                }

            }
            else
            {
                note_promotion  =  String( format:" With a %@ %@ discount"  , product.discount!.toIntString(),"%")

            }
 
        }
        else
        {
            if !(product.discount_display_name  ?? "").isEmpty
            {
                note_promotion =  product.discount_display_name!

            }
        }
        lblCateg.text = String(format: "%@ - %@",    lblCateg.text!   , note_promotion)
 
        
//        let h:CGFloat = 20
//        var frm = lblCateg.frame
//        frm.size.height = frm.size.height + h
//        lblCateg.frame = frm
        
        
        
    }
    
    func get_combo()
    {
//        var frm = CGRect.init(x: 8, y: 38, width: 332, height: 20)
//        lblCateg.frame = frm
        
        if product.selected_products_in_combo.count > 0 {
            
         
            
            var count:Int = 0
            
            var line:String = ""
            var line_notes:String = ""
            
            for p in product!.selected_products_in_combo
            {
                
                
                if p.default_product_combo == false
                {
                    count += 1
                    
                    if line == ""
                    {
                        line = String(format: "->%@ %@",    p.qty.toIntString() , p.product.title)
                        
                    }
                    else
                    {
                        line = String(format: "%@\n-> %@ %@",  line  , p.qty.toIntString() , p.product.title)
                        
                    }
                    
                    if p.extra_price !=  0
                    {
                        total_extra_price  = total_extra_price + p.price_subtotal_incl!
                        
                        line = String(format:"%@ (Extra price %@)", line , p.price_subtotal_incl!.toIntString())
                    }
                }
                
                
                if !(p.note ?? "") .isEmpty
                {
                    line_notes = String(format: "%@-%@",  line_notes  , p.note!.replacingOccurrences(of: "\n", with: " - "))
                    
                }
                
            }
            
            var h = CGFloat( (count * 18))
            
            if !line_notes.isEmpty
            {
                h  =  h + 30
            }
            
            
            
            var str = lblCateg.text!
            
            if str == ""
            {
                if line.isEmpty
                {
                    h  =  h + 10
                    str = String(format: "%@",   line_notes)
                    
                }
                else
                {
                    str = String(format: "%@\n%@",   line, line_notes)
                    
                }
                
            }
            else
            {
              str = String(format: "%@\n%@\n%@",  str  , line,line_notes)
            }
            
              lblCateg.text  = str
//            frm.size.height = h
//            lblCateg.frame = frm
            
        }
    }
    @IBAction func btn_scrap(_ sender: Any) {
        
           if  product.is_scrap == true
             {
                 product.is_scrap = false
                
                btn_scrap.setTitleColor(UIColor.init(hexString: "#898989"), for: .normal)
//                btn_scrap.backgroundColor_base = UIColor.init(hexString: "#E5E5E5")
               btn_scrap.backgroundColor = UIColor.init(hexString: "#E5E5E5")

             }
             else
             {
                 product.is_scrap = true
                
                btn_scrap.setTitleColor(UIColor.white, for: .normal)
//               btn_scrap.backgroundColor_base = UIColor.init(hexString: "#FF7600")
                 btn_scrap.backgroundColor = UIColor.init(hexString: "#FF7600")

              }
             
             product.tag_temp = "selected"

             
             list_items[index!] = product
        parent?.list_items = list_items
             parent!.tableview.reloadData()
    }
    
   
    func getQty(for line:pos_order_line_class) -> Double{
        return line.qty
        /*
        var qty = 0.0
        parent?.sub_orders.forEach { order_item in
            let pos_line_array = order_item.pos_order_lines.filter { $0.product_id ==  line.product_id }
            pos_line_array.forEach({ product_item in
                qty += (product_item.qty * -1)
            })
        }
        if qty > 0 && line.qty > 0 {
            qty = line.qty - qty
        }
        return qty > 0 ? qty : line.qty
         */
    }
    
    @IBAction func stepper_changed(_ sender: Any) {
//        if product.is_combo_line ?? false {
//
//            return
//        }
        if  !btn_scrap.isEnabled{
            return
        }
        if !(orderClass?.canReturnLineFromOrder() ?? true) {
            
            return
        }
        let current_qty = product.qty //getQty(for: product)
        let new_qty = stepper.value
        
        if new_qty <= 0 {
            return
        }
        /*
        var qty: Double = 0
        parent!.sub_orders.forEach { order_item in
            let pos_line_array = order_item.pos_order_lines.filter { $0.product_id ==  product.product_id }
            pos_line_array.forEach({ product_item in
                qty += product_item.qty
            })
                
            
        }
        qty += current_qty
        if qty <= 0 {
            return
        }
         */
//        list_items.forEach { product_item in
//            if product_item.id == product.id {
//                
//            }
//        }
        if new_qty != current_qty {
            let current_price_subtotal_per_item = (product.price_subtotal ?? 0) / current_qty
            let current_price_subtotal_incl_per_item = (product.price_subtotal_incl ?? 0) / current_qty
            
            let new_price_subtotal = current_price_subtotal_per_item * new_qty
            let new_price_subtotal_incl = current_price_subtotal_incl_per_item * new_qty
            
            if (product.is_combo_line ?? false) && (product.selected_products_in_combo.count > 0) {
                for addon in product.selected_products_in_combo {
                    //BUG ISSUE:- if combo containe not_require_addon May addon_qty not match combo_qty
                    //BUG ISSUE:- if combo containe require_addon May addon_qty not match combo_qty
                    let currentQtyAddOn = addon.qty
                  /*
                    if current_qty != currentQtyAddOn || currentQtyAddOn <= 0 {
                        continue
                    }
                   */
                    let newQtyAddOn = currentQtyAddOn - (current_qty - new_qty)
                    let current_price_subtotal_per_item_addon = (addon.price_subtotal ?? 0) / currentQtyAddOn
                    let current_price_subtotal_incl_per_item_addon = (addon.price_subtotal_incl ?? 0) / currentQtyAddOn
                    
                    let new_price_subtotal_addon = current_price_subtotal_per_item_addon * newQtyAddOn
                    let new_price_subtotal_incl_addon = current_price_subtotal_incl_per_item_addon * newQtyAddOn
                    addon.qty = newQtyAddOn
                    addon.price_subtotal = new_price_subtotal_addon
                    addon.price_subtotal_incl = new_price_subtotal_incl_addon

                }
            }
            product.qty = stepper.value
            product.price_subtotal = new_price_subtotal
            product.price_subtotal_incl = new_price_subtotal_incl
            
            product.tag_temp = "selected"
            
            list_items[index!] = product
            parent?.list_items = list_items

            parent!.tableview.reloadData()
        }
       

    }
    
}
