//
//  product_info.swift
//  pos
//
//  Created by Khaled on 6/2/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_info: UIViewController {
    var product:product_product_class!
    var line:pos_order_line_class?

    
    @IBOutlet var photo: KSImageView!
    
    @IBOutlet var lblDescrption: KLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        read()
        self.preferredContentSize = CGSize(width: 310, height: 240)
        
    }
    
    
    func read()
    {
        if product != nil
        {
            var str_Descrption = ""
            
            
            let currency = product!.currency_name ?? ""
            let unite =  product!.uom_name   ?? ""
            
            
            str_Descrption = "Name : " +  ( product!.title)
            
            str_Descrption = str_Descrption + "\n" + "Price : " +  String( format:"%@ %@ / %@" , baseClass.currencyFormate(product.price) ,currency , unite)
            
            if line != nil
            {
                str_Descrption = str_Descrption + "\n" + "Tax : " +  String( format:"%@" , baseClass.currencyFormate(line!.price_subtotal_incl! - line!.price_subtotal!)  )
            }
            
            
            str_Descrption =  str_Descrption + "\n" +   "Category : " +  ( product!.pos_categ_name)!
            
            
            if  product?.calories != 0
            {
                str_Descrption = str_Descrption + "\n" +   "Calories : " + ( product?.calories.toIntString())!
            }
            
            if !( product?.description_.isEmpty)!
            {
                str_Descrption = str_Descrption + "\n" +  "Descrption : " + ( product!.description_)
                
            }
            
            lblDescrption.text = str_Descrption
            
            
            
            if(!( product!.image_small.isEmpty))
            {
//                let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:(  product!.image_small) )
//
//                photo.image = logoData
                SharedManager.shared.loadImageFrom(.images,
                                                   in:.product_product,
                                                   with: product.image_small,
                                                   for: self.photo,handleHiden: true)

            }
            else
            {
                photo.image = #imageLiteral(resourceName: "MWno_photo")
            }
        }
    }
    
    
}
