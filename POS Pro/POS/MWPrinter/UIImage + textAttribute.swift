//
//  UIImage + textAttribute.swift
//  pos
//
//  Created by M-Wageh on 06/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
extension UIImage {
    func getImage(for textFontAttributes: NSAttributedString,with size :CGSize, at point: CGPoint) -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: point, size: size)
        textFontAttributes.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        guard let _ = UIGraphicsGetCurrentContext() else {
          SharedManager.shared.printLog("graphic context is not available so you can not create an image.")
            UIGraphicsEndImageContext()
            return textFontAttributes.getImage(with:size , at: point)
        }
        UIGraphicsEndImageContext()
        return newImage
         
    }
    
}


extension NSAttributedString {
    func getImage(with size :CGSize, at point: CGPoint) -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: point, size: size)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        guard let _ = UIGraphicsGetCurrentContext() else {
          SharedManager.shared.printLog("graphic context is not available so you can not create an image.")
            UIGraphicsEndImageContext()
           return newImage
        }
        UIGraphicsEndImageContext()
        return newImage
    }
}
