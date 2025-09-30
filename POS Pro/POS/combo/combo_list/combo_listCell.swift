//
//  homeCollectionViewCell.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class combo_listCell: UICollectionViewCell {
    
    
    @IBOutlet var photo: UIImageView!
    @IBOutlet weak var lblExraPrice: UILabel!

    @IBOutlet var lblCount: UILabel!
    @IBOutlet var lblTitle: UILabel!
 
//    @IBOutlet var btnDelete: UIButton!
    
    @IBOutlet weak var btnPlus: KButton!
    @IBOutlet weak var btnMinus: KButton!
    
    @IBOutlet weak var view_selected: ShadowView!
//    @IBOutlet var icon_selected: UIImageView!

    
    var indexPath: IndexPath!
    var delegate:combo_listCell_delegate?
  
    var product :productProductClass!
    var combo_parent:combo_list!
 
    func updateCell() {
        
        if(product.image != "")
        {
            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:product.image )
            
            photo.image = logoData
        }
        else
        {
            photo.image = UIImage(named: "no_photo.png")
        }
        

        lblTitle.text = product.title
        
        lblCount.layer.cornerRadius = 15
        lblCount.layer.masksToBounds = true

        if product.qty_app == 0
        {
           lblCount.isHidden = true
        }
        else
        {
            lblCount.isHidden = false
            lblCount.text  = String(format: "%@" , product.qty_app.toIntString()   )

        }

//        let extra_price = product.comob_extra_price ?? 0
//        if extra_price != 0
//        {
//            lblCount.text  = String(format: "%.f ( %.2f )" , product.qty_app , extra_price  )
//        }
//        else
//        {
//            lblCount.text  = String(format: "%.f" , product.qty_app   )
//        }
        
//        if product.qty_app == 0 {
////            btnDelete.isHidden = true
//        }
//        else
//        {
////            btnDelete.isHidden = false
//        }
        
        if product.app_require
        {
            product.app_selected = true
//            btnDelete.isHidden = true
        }
        
        if product.app_selected == true
        {
            view_selected.isHidden = false
//            icon_selected.image = UIImage(named: "icon_selected.png")

        }
        else
        {
            view_selected.isHidden = true
//            icon_selected.image = UIImage(named: "icon_unselected.png")

        }
        
        
         lblExraPrice.isHidden = true
        if product.comob_extra_price > 0
        {
            let currency = product.currency_name ?? ""

            lblTitle.text = String(format:"%@ (+%@ %@)",   lblTitle.text!, product.comob_extra_price.toIntString() , currency)
//            lblExraPrice.text = String(format:"(Extra price %@)",  product.comob_extra_price.toIntString())
//            lblExraPrice.isHidden = false
        }
//        else
//        {
//             lblExraPrice.text = ""
//             lblExraPrice.isHidden = true
//        }
        
 
    }
    
    @IBAction func btnPlus(_ sender: Any) {

        product = combo_parent.AddOrMinusQty(product: product, indexPath: indexPath, plus: true)
//         product.app_selected = true
//        product.qty_app = product.qty_app + 1
        delegate?.updateProduct(product:product ,indexPath: indexPath)
    }
    
    @IBAction func btnMinus(_ sender: Any) {
        
        if product.qty_app == 0
        {
            return
        }
        
        product = combo_parent.AddOrMinusQty(product: product, indexPath: indexPath, plus: false)

//          product.qty_app = product.qty_app  - 1
        if product.qty_app <= 0 {
         
            delegate?.deleteProduct(indexPath: indexPath)

        }
        else
        {
            delegate?.updateProduct(product:product ,indexPath: indexPath)

        }
    }
    
    @IBAction func btnDelete(_ sender: Any) {
        
        delegate?.deleteProduct(indexPath: indexPath)
    }
    
}

protocol combo_listCell_delegate {
    func deleteProduct(indexPath: IndexPath)
    func updateProduct(product:productProductClass, indexPath: IndexPath)

}
