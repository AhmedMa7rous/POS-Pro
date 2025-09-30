//
//  categroies_scroll_horizontal_cell.swift
//  pos
//
//  Created by Khaled on 5/20/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class categroies_scroll_horizontal_cell: UICollectionViewCell {
    
     @IBOutlet var photoCateg: KSImageView!
           @IBOutlet var lblTtile: KLabel!
           
        
           var categ:pos_category_class!
           @IBOutlet var view_bg: ShadowView!
           
           func setSelected()   {
               view_bg.backgroundColor = UIColor.init(hexString: "#EBEFF0")
           }
           func clearSelected()   {
               view_bg.backgroundColor = UIColor.white
           }
           
           func setText(txt:String)
           {
 
            
            lblTtile.text = txt
    
 
               if(!categ.image.isEmpty)
               {
//                   let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:categ.image )
//
//                   photoCateg.image = logoData
//                photoCateg.isHidden = false
                SharedManager.shared.loadImageFrom(.images,
                                                   in:.pos_category,
                                                   with: categ.image,
                                                   for: self.photoCateg,handleHiden: true)

                photoCateg.frame = CGRect.init(x: 0, y: 116, width: 164, height: 35)
               }
               else
               {
                 photoCateg.isHidden = true
                photoCateg.frame = CGRect.init(x: 0, y: 8, width: 164, height: 143)

                
                }
           }
}
