//
//  homeCollectionViewCell.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class combo_listCell_ver2: UICollectionViewCell {
    
    
    @IBOutlet var photo: UIImageView!
    @IBOutlet weak var lblExraPrice: KLabel!

 
    @IBOutlet var lblTitle: KLabel!
 
  

    
    var indexPath: IndexPath!
    var delegate:combo_listCell_ver2_delegate?
  
    var product :product_product_class!
    var combo_parent:combo_list_ver2!
 
    override var isHighlighted: Bool{
        didSet{
            if isHighlighted{
                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                    self.transform = self.transform.scaledBy(x: 0.75, y: 0.75)
                }, completion: nil)
            }else{
                UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                    self.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                }, completion: nil)
            }
        }
    }
    
    func updateCell() {
        
        
        if(product.cover_image != "")
        {
            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:product.cover_image )
            
            photo.image = logoData
        }
        else
        {
            photo.image = UIImage(named: "no_photo.png")
        }
        

        lblTitle.text = product.display_name
        
      
        
         lblExraPrice.isHidden = true
        if product.comob_extra_price > 0
        {
            let currency = product.currency_name

            lblTitle.text = String(format:"%@ (+%@ %@)",   lblTitle.text!, product.comob_extra_price.toIntString() , currency!)
 
        }
 
        
 
    }
    


    @IBAction func btnDelete(_ sender: Any) {
        
        delegate?.deleteProduct(indexPath: indexPath)
    }
    
}

protocol combo_listCell_ver2_delegate {
    func deleteProduct(indexPath: IndexPath)
    func updateProduct(product:product_product_class, indexPath: IndexPath)

}
