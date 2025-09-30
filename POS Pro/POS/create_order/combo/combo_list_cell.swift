//
//  homeCollectionViewCell.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class combo_list_cell: UICollectionViewCell {
    
    
    
    @IBOutlet var combo_view: ShadowView!
    @IBOutlet var combo_view_selected: ShadowView!
    
    @IBOutlet var variant_view: ShadowView!
    
    
    @IBOutlet var btn_plus: UIButton!
    @IBOutlet var btn_minus: UIButton!
    @IBOutlet var combo_title: KLabel!
    @IBOutlet var combo_title_selected: KLabel!
    
    @IBOutlet var combo_qty: KLabel!
    
    @IBOutlet var variant_title: KLabel!
    
    
    
    var section:section_view?
    var indexPath: IndexPath!
    
    var note :pos_product_notes_class!
    
    var product :product_product_class!
    var combo_parent:combo_vc!
    
    //    override var isHighlighted: Bool{
    //        didSet{
    //            if isHighlighted{
    //                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
    //                    self.transform = self.transform.scaledBy(x: 0.75, y: 0.75)
    //                }, completion: nil)
    //            }else{
    //                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
    //                    self.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
    //                }, completion: nil)
    //            }
    //        }
    //    }
    
    func update_cell_note(row:pos_product_notes_class,selected:Bool)
    {
        note = row
        combo_view_selected.isHidden = true
        
        combo_view.isHidden = false
        variant_view.isHidden = true
        
        let get_note =  combo_parent?.list_notes_selected[row.id]
        
        if get_note != nil
        {
            if get_note!.qty > 0
            {
                combo_view.isHidden = true
                combo_view_selected.isHidden = false
                combo_qty.text = String( get_note!.qty)
            }
        }
        
        
        combo_title.text = row.display_name
        combo_title_selected.text = row.display_name
        
    }
    
    
    
    func getPrice(product_id:Int) -> Double
    {
        let calc :calculate_pricelist = calculate_pricelist()
        let temp_product = product_product_class.get(id: product_id)
         
        
        return   calc.get_price(product: temp_product!, rule: combo_parent.product_combo?.priceList, quantity: combo_parent.product_combo!.qty)
    }
    
    func getMinPrice(product_tmpl_id:Int) -> Double
    {
//        let calc :calculate_pricelist = calculate_pricelist()
        let temp_product = product_product_class.getWithMinPrice( product_tmpl_id)
         
        return temp_product!.list_price
        
//        return   calc.get_price(product: temp_product!, rule: combo_parent.product_combo?.priceList, quantity: combo_parent.product_combo!.qty)
    }
    
    func update_cell_variant(row:product_attribute_value_class,selected:Bool,list_price:Double? )
    {
        combo_view.isHidden = true
        combo_view_selected.isHidden = true
        
        variant_view.isHidden = false
        
        if selected
        {
            variant_title.textColor = UIColor.white
            variant_view.backgroundColor = UIColor.init(hexString: "#898989")
        }
        else
        {
            variant_title.textColor = UIColor.init(hexString: "#898989")
            variant_view.backgroundColor = UIColor.init(hexString: "#E5E5E5")
        }
        let extra_price =   row.price_extra //getMinPrice(product_tmpl_id: row.product_tmpl_id) +  row.price_extra //row.lst_price //+  row.price_extra
        if extra_price != 0
        {
            if let list_price = list_price{
                let total_price = list_price + extra_price
                variant_title.text = row.name + "   (" + total_price.toIntString()  + " \(SharedManager.shared.getCurrencyName()) "

            }else{
            variant_title.text = row.name + "   (+" + extra_price.toIntString()  + " \(SharedManager.shared.getCurrencyName()) "
            }
            
            //            let font = variant_title.font
            //
            //
            //            let attributedString = NSMutableAttributedString(string:"")
            //            let attrs = [NSAttributedString.Key.font : font! ] as [NSAttributedString.Key : Any]
            //            let normalString = NSMutableAttributedString(string: row.name, attributes:attrs)
            //
            //            attributedString.append(normalString)
            //
            //
            //                let currency =  " SAR " //product.currency_name
            //            let boldText  =  String( format: "  +%@ %@" ,extra_price.toIntString()  , currency)
            //
            //                let color = UIColor.init(hexFromString: "#FC7700")
            //                let attrs_bold = [NSAttributedString.Key.font : font! ,NSAttributedString.Key.foregroundColor : color ] as [NSAttributedString.Key : Any]
            //
            //                let boldString = NSMutableAttributedString(string: boldText, attributes:attrs_bold )
            //                attributedString.append(boldString)
            //
            //
            //            variant_title.attributedText = attributedString
            
        }
        else
        {
            variant_title.text = row.name
            
        }
        
    }
    
    func updateCell( )
    {
        combo_view.isHidden = false
        combo_view_selected.isHidden = true
        
        variant_view.isHidden = true
        
        let arr = combo_parent?.list_selected[product.section_name]
        let line = arr?.first (where: {$0.product_id  == product.id})
        if line != nil
        {
        
                if line!.qty > 0.0
                      {
                          combo_view.isHidden = true
                          combo_view_selected.isHidden = false
                          combo_qty.text = line!.qty.toIntString()
                          
                      }
         
      
        }
       
        if product.app_require == true
        {
            btn_plus.isHidden = true
            btn_minus.isHidden = true

        }
        else
        {
            btn_plus.isHidden = false
                 btn_minus.isHidden = false
        }
        
        //        if selected
        //        {
        //            combo_title.textColor = UIColor.white
        //            combo_view.backgroundColor = UIColor.init(hexString: "#79628A")
        //        }
        //        else
        //        {
        //            combo_title.textColor = UIColor.init(hexString: "#6A6A6A")
        //            combo_view.backgroundColor = UIColor.white
        //        }
        
        let normalText = product.title
        
        
        //        if product.comob_extra_price > 0
        //        {
        //            let currency = product.currency_name
        //
        //           normalText = String(format:"%@ (+%@ %@)",   combo_title.text!, product.comob_extra_price.toIntString() , currency!)
        //
        //        }
        
        let font = combo_title.font
        
        
        
        let attributedString = NSMutableAttributedString(string:"")
        let attrs = [NSAttributedString.Key.font : font! ] as [NSAttributedString.Key : Any]
        let normalString = NSMutableAttributedString(string: normalText, attributes:attrs)
        
        attributedString.append(normalString)
        
        if product.comob_extra_price > 0
        {
            let currency = product.currency_name ?? "SAR"
            if currency.lowercased().contains("sar"){
               
                let currency = product.currency_name ?? "SAR"

                let currencySymbol = "\u{E900}"

                let boldText  = String(format: " (+%@ %@)", product.comob_extra_price.toIntString(), currencySymbol)

                let color = UIColor(hexFromString: "#FC7700")
                let attrs_bold: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "saudi_riyal", size: 30) ?? UIFont.systemFont(ofSize: 30), // استخدم الخط المخصص
                    .foregroundColor: color
                ]

                let boldString = NSMutableAttributedString(string: boldText, attributes: attrs_bold)
                attributedString.append(boldString)
            }else{
                let boldText  =  String( format: " (+%@ %@)" ,product.comob_extra_price.toIntString() , currency)
                
                let color = UIColor.init(hexFromString: "#FC7700")
                let attrs_bold = [NSAttributedString.Key.font : font! ,NSAttributedString.Key.foregroundColor : color ] as [NSAttributedString.Key : Any]
                
                let boldString = NSMutableAttributedString(string: boldText, attributes:attrs_bold )
                attributedString.append(boldString)

            }
            
        }
        
        
        
        
        
        combo_title?.attributedText = attributedString
        combo_title_selected?.attributedText = attributedString
        
        
        
        
    }
    @IBAction func btn_plus(_ sender: Any) {
        
        if section?.type == .combo
        {
          

            combo_parent?.AddOrMinusQty(product: product,   plus: true,section: section!)
            
            
        }
        else if section?.type == .note
        {
            combo_parent?.add_note(note: note , plus: true)
            
        }
        //else{
        combo_parent?.done(removeFromSuperview: false)
      //  }
        
    }
    
    @IBAction func btn_minus(_ sender: Any) {
        
        //         if product.qty <= 1
        //                {
        //                    self.delegate?.deleteRow(product: product)
        //        //            self.isHidden = true
        //                    return
        //                }
        if section?.type == .combo
        {
            combo_parent?.AddOrMinusQty(product: product,   plus: false,section: section!)
        }
        else if section?.type == .note
        {
            combo_parent?.add_note(note: note , plus: false)
        }
        
        combo_parent?.done(removeFromSuperview: false)
        
    }
    
    
}


