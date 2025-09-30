//
//  combo_seleted_itemsCell.swift
//  pos
//
//  Created by Khaled on 12/23/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol combo_seleted_itemsCell_delegate {
    func deleteRow(product :pos_order_line_class)
    func AddOrMinusQty(product:pos_order_line_class , plus:Bool)
}

class combo_seleted_itemsCell: UITableViewCell {

    @IBOutlet var lblTitle: KLabel!
     @IBOutlet var lblNotes: KLabel!
    
        var product :pos_order_line_class!
//       var parent_combo:combo_seleted_items?

    var delegate:combo_seleted_itemsCell_delegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func updateCell() {
        
        lblNotes.text = ""
     
        let currency = product.product.currency_name
     
        
        let normalText =  product.product.title  //String( format: "%@  %@  %@" ,product.qty_app.toIntString(), "x" , product.title )
        
        let boldText  =  String( format: "%@  %@ " ,product.qty.toIntString(), "X" )
        
        let attributedString = NSMutableAttributedString(string:"")
        
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
        let boldString = NSMutableAttributedString(string: boldText, attributes:attrs)
        let normalString = NSMutableAttributedString(string: normalText)
        
        attributedString.append(boldString)
        attributedString.append(normalString)
        
  
       
        
        if product.extra_price != 0
        {
            
            let price =   String( format:"  (+%@ %@)" , baseClass.currencyFormate(product.extra_price!) ,currency!)
            
            let attrs_price = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13) ,
                               NSAttributedString.Key.foregroundColor : UIColor.init(hexFromString: "#1B273D")
                            ]
            
            let boldString_price = NSMutableAttributedString(string: price, attributes:attrs_price)
            
            attributedString.append(boldString_price)

            
        }

        lblTitle?.attributedText = attributedString

        
        get_notes()
  
    }
    
    func get_notes()
    {
        lblNotes.isHidden = true
        
        var line:String = ""
        
        if !(product.note ?? "").isEmpty
        {
            line = product.note!
        }
        
//        
//        for (_,valu) in product.notes
//        {
//            
//            let note = noteClass(fromDictionary: valu)
//            
//            if line.isEmpty {
//                line = String(format: "Notes : %@", note.display_name )
//                
//            }
//            else
//            {
//                line = String(format: "%@,%@", line,note.display_name )
//                
//            }
//            
//        }
        
        if line.isEmpty {return}
        
        lblNotes.isHidden = false

        lblNotes.text = line.replacingOccurrences(of: "\n", with: " - ")

//        lblNotes.text = String(format: "%@\n%@",    lblNotes.text!   , line)
        
//        let h:CGFloat = 30
//        var frm = lblNotes.frame
//        frm.size.height = frm.size.height + h
//        lblNotes.frame = frm
        
        
        
    }
    
    @IBAction func btnPlus(_ sender: Any) {
        
        
       self.delegate?.AddOrMinusQty(product: product,   plus: true)
        //         product.app_selected = true
        //        product.qty_app = product.qty_app + 1
        //        delegate?.updateProduct(product:product ,indexPath: indexPath)
    }
    
    @IBAction func btnMinus(_ sender: Any) {
        
        if product.qty <= 1
        {
            self.delegate?.deleteRow(product: product)
//            self.isHidden = true
            return
        }
        
         self.delegate?.AddOrMinusQty(product: product,   plus: false)
        
        //          product.qty_app = product.qty_app  - 1
        //        if product.qty_app <= 0 {
        //
        //            delegate?.deleteProduct(indexPath: indexPath)
        //
        //        }
        //        else
        //        {
        //            delegate?.updateProduct(product:product ,indexPath: indexPath)
        //
        //        }
    }
    
    
}
