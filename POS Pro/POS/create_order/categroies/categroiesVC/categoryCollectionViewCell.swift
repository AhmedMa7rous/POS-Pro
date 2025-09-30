//
//  categoryCollectionViewCell.swift
//  pos
//
//  Created by khaled on 9/16/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class categoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet var photoCateg: UIImageView!
    @IBOutlet var lblTtile: UILabel!
    
 
    var categ:categoryClass!
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
        
        let contentSize = self.lblTtile.sizeThatFits(self.lblTtile.bounds.size)

        if contentSize.width > 100
        {
            let frm:CGRect =  CGRect.init(x: self.frame.origin.x , y: self.frame.origin.y,
                                          width: 70 + contentSize.width, height: self.frame.size.height)
       
            
            self.frame = frm
        }
        
        if(!categ.image.isEmpty)
        {
            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:categ.image )
            
            photoCateg.image = logoData
              photoCateg.isHidden = false
        }
        else
        {
            photoCateg.image = UIImage(named: "no_photo.png")
            photoCateg.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
}
