//
//  UIView+ext.swift
//  pos
//
//  Created by khaled on 8/24/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
//    func asImage() -> UIImage {
//        let renderer = UIGraphicsImageRenderer(bounds: bounds)
//        return renderer.image { rendererContext in
//            layer.render(in: rendererContext.cgContext)
//        }
//    }
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
    public func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
           var all = [T]()
           func getSubview(view: UIView) {
               if let wrapped = view as? T, wrapped != self{
                   all.append(wrapped)
               }
               guard view.subviews.count>0 else { return }
               view.subviews.forEach{ getSubview(view: $0) }
           }
           getSubview(view: self)
           return all
       }
}
