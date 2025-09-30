//
//  return_ordersTableViewCell.swift
//  pos
//
//  Created by Khaled on 4/9/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_choose_cell: UITableViewCell {
    
    @IBOutlet var lblTitle: KLabel!
    @IBOutlet var lblCateg: KLabel!
    @IBOutlet var lblPrice: KLabel!
    @IBOutlet var img_select: KSImageView!
    
    @IBOutlet var lbl_qty: UILabel!
    
    @IBOutlet var btnPlus: UIButton!
    @IBOutlet var btnMinus: UIButton!
    
    
    
    
    var line :pos_order_line_class!
    var product:product_product_class!
    
    
    var selectedhelper:promotionSelectHelper!
    
    var order :pos_order_class!
    
    var index:Int?
    var parent:promotionSelect?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCell() {
        //        stepper.minimumValue = 1
        img_select.isHighlighted = false
        
        lbl_qty.isHidden = false
        btnPlus.isHidden = false
        btnMinus.isHidden = false
        
        selectedhelper.qty = (line?.qty ?? 1)
        if selectedhelper.promotion.promotionType == .Buy_X_Get_Y_Free
        {
            
            let condtion = selectedhelper.pos_condition //pos_conditions_class(fromDictionary: condtion)
            product = product_product_class.get(id: condtion!.product_y_id)
            
            
            //                     lblTitle.text = product!.display_name //condtion.display_name
            lblCateg.text = "Get it free".arabic("مجانى")
            lblPrice.text = "0"
            lbl_qty.text = "\((line?.qty ?? 1).toIntString())/\(selectedhelper.maxValue)"
            
            
        }
        else if selectedhelper.promotion.promotionType  == .Buy_X_Get_Discount_On_Y
        {
            let  condtion = selectedhelper.get_discount //get_discount_class(fromDictionary: condtion)
            product = product_product_class.get(id: condtion!.product_id_dis_id)
            
            //                    lblTitle.text = product!.display_name
            lblCateg.text = "Get discount \(condtion!.discount_dis_x.toIntString()) %".arabic("خصم \(condtion!.discount_dis_x.toIntString()) %")
            
            let price = product!.get_price(priceList: order.priceList)
            let discount_value = (price * condtion!.discount_dis_x) / 100
            lblPrice.text = (price - discount_value).toIntString()
            
            lbl_qty.text = "\((line?.qty ?? 1).toIntString())/\(selectedhelper.maxValue)"
            
        }
        else if selectedhelper.promotion.promotionType  == .Buy_X_Get_Fix_Discount_On_Y
        {
            let  condtion = selectedhelper.get_discount // get_discount_class(fromDictionary: condtion)
            product = product_product_class.get(id: condtion!.product_id_dis_id)
            
            //                    lblTitle.text =  product!.display_name
            let currencyName = SharedManager.shared.getCurrencyName().arabic(SharedManager.shared.getCurrencyName(true))
            lblCateg.text = "Get discount \(condtion!.discount_fixed_x.toIntString()) \(currencyName)".arabic("خصم \(condtion!.discount_fixed_x.toIntString()) \(currencyName)"  )
            
            let price = product!.get_price(priceList:  order.priceList)
            let discount_value = condtion!.discount_fixed_x
            lblPrice.text = (price - discount_value).toIntString()
            
            lbl_qty.text = "\((line?.qty ?? 1).toIntString())/\(selectedhelper.maxValue)"
        }
        else if selectedhelper.promotion.promotionType  == .Percent_Discount_on_Quantity
        {
            let  condtion = selectedhelper.quantity_discount // quantity_discount_class(fromDictionary: condtion)
            product = product_product_class.get(id: selectedhelper.promotion.product_id_qty)
            
            //                    lblTitle.text =  product!.display_name
            
            lblCateg.text = "Get discount on quantity \(condtion!.discount_dis.toIntString()) %".arabic("خصم على الكميه \(condtion!.discount_dis.toIntString()) %")
            
            let price = product!.get_price(priceList:  order.priceList)
            let discount_value = (price * condtion!.discount_dis) / 100
            lblPrice.text = (price - discount_value).toIntString()
            
            //                    lbl_qty.text = "\((line?.qty ?? 1).toIntString())/\(selectedhelper.maxValue)"
            
            lbl_qty.isHidden = true
            btnPlus.isHidden = true
            btnMinus.isHidden = true
        }
        else if selectedhelper.promotion.promotionType  == .Fix_Discount_on_Quantity
        {
            let  condtion = selectedhelper.quantity_discount_amt //quantity_discount_amt_class(fromDictionary: condtion)
            product = product_product_class.get(id: selectedhelper.promotion.product_id_amt)
            
            //                    lblTitle.text = product!.display_name
            let currencyName = SharedManager.shared.getCurrencyName().arabic(SharedManager.shared.getCurrencyName(true))

            lblCateg.text = "Get discount on quantity \(condtion!.discount_price.toIntString()) \(currencyName)".arabic("خصم على الكميه \(condtion!.discount_price.toIntString()) \(currencyName)")
            
            let price = product!.get_price(priceList:  order.priceList)
            let discount_value = condtion!.discount_price
            lblPrice.text = (price - discount_value).toIntString()
            
            //                    lbl_qty.text = "\((line?.qty ?? 1).toIntString())/\(selectedhelper.maxValue)"
            lbl_qty.isHidden = true
            btnPlus.isHidden = true
            btnMinus.isHidden = true
        }
        
        
        if LanguageManager.currentLang() == .ar
        {
            if product.name_ar.isEmpty
            {
                lblTitle.text =   product.name
                
            }
            else
            {
                lblTitle.text = product.name_ar
                
            }
            
        }
        else
        {
            lblTitle.text =   product.name
            
        }
        
        //        stepper.maximumValue = Double(selectedhelper.maxValue)
        
        if   line != nil
        {
            if line!.tag_temp == "selected" &&  line!.is_void == false
            {
                img_select.isHighlighted = true
            }
        }
        
        
        checkEnable()
    }
    
    
    func checkEnable()
    {
        self.selectionStyle = .default
        self.isUserInteractionEnabled = true
        self.contentView.alpha = 1
        
        if selectedhelper.promotion.promotionType == .Buy_X_Get_Y_Free
        {
            
            let condtion = selectedhelper.pos_condition
            
            if promotionValidate.pos_conditions_check(condtion!, line: parent!.parent_line) == false
            {
                self.selectionStyle = .none
                self.isUserInteractionEnabled = false
                self.contentView.alpha = 0.5               }
            
        }
        else if selectedhelper.promotion.promotionType  == .Buy_X_Get_Discount_On_Y
        {
            let  condtion = selectedhelper.get_discount
            
            if promotionValidate.get_discount_check (condtion!, line:  parent!.parent_line) == false
            {
                self.selectionStyle = .none
                self.isUserInteractionEnabled = false
                self.contentView.alpha = 0.5                    }
            
        }
        else if selectedhelper.promotion.promotionType  == .Buy_X_Get_Fix_Discount_On_Y
        {
            let  condtion = selectedhelper.get_discount
            if promotionValidate.get_discount_check (condtion!, line:  parent!.parent_line) == false
            {
                self.selectionStyle = .none
                self.isUserInteractionEnabled = false
                self.contentView.alpha = 0.5                    }
        }
        else if selectedhelper.promotion.promotionType  == .Percent_Discount_on_Quantity
        {
            let  condtion = selectedhelper.quantity_discount
            
            if promotionValidate.quantity_discount_check (condtion!, line:  parent!.parent_line) == false
            {
                self.selectionStyle = .none
                self.isUserInteractionEnabled = false
                self.contentView.alpha = 0.5                    }
        }
        else if selectedhelper.promotion.promotionType  == .Fix_Discount_on_Quantity
        {
            let  condtion = selectedhelper.quantity_discount_amt
            if promotionValidate.quantity_discount_amt_check (condtion!, line:  parent!.parent_line) == false
            {
                self.selectionStyle = .none
                self.isUserInteractionEnabled = false
                self.contentView.alpha = 0.5                    }
        }
    }
    
    
    @IBAction func btnPlus(_ sender: Any) {
        
        plusOrMinus(value: 1)
    }
    
    @IBAction func btnMinus(_ sender: Any) {
        plusOrMinus(value: -1)
        
    }
    
    
    
    func plusOrMinus(value:Double)
    {
        
        if line == nil
        {
            
            parent!.apply(_selectedhelper: selectedhelper)
            
            return
        }
        
        let current_qty = line.qty
        let new_qty = line.qty + value
        //        var qty: Double = 0
        
        //        qty += line.qty
        if new_qty <= 0 {
            return
        }
        
        if new_qty.toInt() > selectedhelper.maxValue
        {
            btnPlus.setBackgroundImage(UIImage(named: "btnplus_dismiss"), for: .normal)
            return
        }
        else
        {
            btnPlus.setBackgroundImage(UIImage(named: "btnplus"), for: .normal)
        }
        
        if new_qty != current_qty {
            let current_price_subtotal_per_item = (line.price_subtotal ?? 0) / current_qty
            let current_price_subtotal_incl_per_item = (line.price_subtotal_incl ?? 0) / current_qty
            
            let new_price_subtotal = current_price_subtotal_per_item * new_qty
            let new_price_subtotal_incl = current_price_subtotal_incl_per_item * new_qty
            
            
            line.qty = new_qty
            line.price_subtotal = new_price_subtotal
            line.price_subtotal_incl = new_price_subtotal_incl
            
            line.tag_temp = "selected"
            
            parent!.list_selected[index!] = line
            parent!.tableCondtions.reloadData()
            
        }
        
        
    }
    
}
