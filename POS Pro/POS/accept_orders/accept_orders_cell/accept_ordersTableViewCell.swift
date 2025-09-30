//
//  return_ordersTableViewCell.swift
//  pos
//
//  Created by Khaled on 4/9/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class accept_ordersTableViewCell: UITableViewCell {
    
    @IBOutlet var lblTitle: KLabel!
    @IBOutlet var lblCateg: KLabel!
    @IBOutlet var lblPrice: KLabel!
 
  
    var parent:accept_orders?
    var list_items:[pos_order_line_class] = []
   private var product :pos_order_line_class!

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
        
        
        let currency = product.product.currency_name   ?? ""
         
        let normalText =  product.product.title // String( format: "%@  %@  %@" ,product.qty.toIntString(), "x" , product.product.title )
         
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
        
        
        
        
        if line.isEmpty {return}
        
        if   lblCateg.text!.isEmpty
        {
            lblCateg.text = line
            
        }
        else
        {
            lblCateg.text = String(format: "%@\n%@",    lblCateg.text!   , line)
            
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
     
    
 
    
}
