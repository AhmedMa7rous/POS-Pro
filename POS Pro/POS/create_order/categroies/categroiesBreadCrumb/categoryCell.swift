//
//  categoryCell.swift
//  pos
//
//  Created by Khaled on 2/9/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class categoryCell: UICollectionViewCell {
    
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
        //        let str = NSAttributedString(string: txt, attributes: [
        //            NSAttributedString.Key.foregroundColor : UIColor.white,
        //            NSAttributedString.Key.strokeColor : UIColor.black,
        //            NSAttributedString.Key.strokeWidth : -5,
        //            NSAttributedString.Key.font : UIFont.boldSystemFont (ofSize: 30.0)
        //            ])
        //
        //        lblTtile.attributedText = str
        
        lblTtile.text = txt
        
        
        
        //           let contentSize = self.lblTtile.sizeThatFits(self.lblTtile.bounds.size)
        //
        //           if contentSize.width > 100
        //           {
        //               let frm:CGRect =  CGRect.init(x: self.frame.origin.x , y: self.frame.origin.y,
        //                                             width: 70 + contentSize.width, height: self.frame.size.height)
        //
        //
        //               self.frame = frm
        //           }
        //
        if(!categ.image.isEmpty)
        {
//            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:categ.image )
//            photoCateg.image = logoData
            SharedManager.shared.loadImageFrom(.images,
                                               in:.pos_category,
                                               with: categ.image,
                                               for: self.photoCateg,handleHiden: true)

            //                 photoCateg.isHidden = false
//            photoCateg.image = logoData
//            photoCateg.isHidden = false
            lblTtile.frame = CGRect.init(x: 0, y: 116, width: 164, height: 35)
            
            let font = lblTtile.font
            lblTtile.font  = font?.withSize(14)
        }
        else
        {
            photoCateg.isHidden = true
            lblTtile.frame = CGRect.init(x: 0, y: 8, width: 164, height: 143)
            let font = lblTtile.font
            lblTtile.font  = font?.withSize(20)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}
