//
//  UIImageView+ext.swift
//  pos
//
//  Created by khaled on 9/21/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

@IBDesignable class KSImageView: UIImageView {
//   let tag:String = "KSImageView"
    
    
   func clear()
    {
        self.image = nil
        self.highlightedImage = nil
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            if cornerRadius != 0 {
                layer.cornerRadius = cornerRadius
            }
        }
    }
    
    @IBInspectable   var imageFileName : String? {
        didSet {
//            if imageFileName != nil
//            {
//
//                self.image = UIImage.init(name: imageFileName!)
//
//            }

         }
    }

    @IBInspectable   var HighlightedFileName : String? {
        didSet {
//            if HighlightedFileName != nil
//            {
// 
//                self.highlightedImage = UIImage.init(name: HighlightedFileName!)
//
//            }

         }
    }
    
}
