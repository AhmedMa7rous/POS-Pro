//
//  return_ordersTableViewCell.swift
//  pos
//
//  Created by Khaled on 4/9/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class split_orderTableViewCell: UITableViewCell {
    
    @IBOutlet var lblTitle: KLabel!
    @IBOutlet var lblCateg: KLabel!
    @IBOutlet var lblPrice: KLabel!
    @IBOutlet var img_select: KSImageView!
    @IBOutlet var lbl_qty: UILabel!
    @IBOutlet var stepper: UIStepper!

    var parent:split_order?
    var list_items:[pos_order_line_class] = []
    private var product :pos_order_line_class!
    var index:Int?
    var total_extra_price:Double = 0
    var moveItemModel: MoveItemModel?{
        didSet{
            if let moveItemModel = moveItemModel{
                if let movesLine = moveItemModel.movesLine{
                    self.updateCell(with:movesLine )
                }
                img_select.isHighlighted = moveItemModel.isSelected

            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCell(with productLine:pos_order_line_class) {
        total_extra_price = 0
        
        product = productLine
        
        if   product.tag_temp != nil
        {
            img_select.isHighlighted = true
        }
        else
        {
            img_select.isHighlighted = false
        }
        
        
        
        
        
        let currency = product.product.currency_name   ?? ""
        
        
        
        let normalText =  product.product.title  //String( format: "%@  %@  %@" ,product.qty_app.toIntString(), "x" , product.title )
        
 
        
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
        let qty =  product.qty
        
        if product.max_qty_app == nil
        {
            product.max_qty_app = qty

            stepper.maximumValue = qty

        }

 
        stepper.value = product.qty
          lbl_qty.text = String(format: " %@/%@", product.qty.toIntString(),  product.max_qty_app!.toIntString())
 
 
        get_combo()
        
        get_notes()
        
        if currency.lowercased().contains("sar"){
            
            lblPrice?.attributedText = SharedManager.shared.getRiayalSymbol(total: baseClass.currencyFormate(product.price_subtotal_incl! + total_extra_price))


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
            if !line.isEmpty {
                lblCateg.text = String(format: "%@ - %@", lblCateg.text ?? "", line)
            } else {
                // Handle the case where line is empty
                lblCateg.text = lblCateg.text ?? ""
            }
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
        
        if !note_promotion.isEmpty {
            lblCateg.text = String(format: "%@ - %@", lblCateg.text ?? "", note_promotion)
        } else {
            lblCateg.text = lblCateg.text ?? ""
        }
        
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
                        line = String(format: "-> %@ %@",    p.qty.toIntString() , p.product.title)
                        
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
   
   
    
    @IBAction func stepper_changed(_ sender: Any) {
        
        product.qty = stepper.value
        product.tag_temp = "selected"
        
        list_items[index!] = product
        
        parent!.tableview.reloadData()
        
        
//        let current_qty = product.qty
//        let new_qty = stepper.value
//        var qty: Double = 0
//
//        parent!.sub_orders.forEach { order_item in
//            let pos_line_array = order_item.pos_order_lines.filter { $0.product_id ==  product.product_id }
//            pos_line_array.forEach({ product_item in
//                qty += product_item.qty
//            })
//
//
//        }
//        qty += product.qty
//        if qty <= 0 {
//            return
//        }
////        list_items.forEach { product_item in
////            if product_item.id == product.id {
////
////            }
////        }
//        if new_qty != current_qty {
//            let current_price_subtotal_per_item = (product.price_subtotal ?? 0) / current_qty
//            let current_price_subtotal_incl_per_item = (product.price_subtotal_incl ?? 0) / current_qty
//
//            let new_price_subtotal = current_price_subtotal_per_item * new_qty
//            let new_price_subtotal_incl = current_price_subtotal_incl_per_item * new_qty
//
//
//            product.qty = stepper.value
//            product.price_subtotal = new_price_subtotal
//            product.price_subtotal_incl = new_price_subtotal_incl
//
//            product.tag_temp = "selected"
//
//            list_items[index!] = product
//
//            parent!.tableview.reloadData()
//        }
//

    }
 
    
}
