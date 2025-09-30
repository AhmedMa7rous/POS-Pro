//
//  zoomClass.swift
//  pos
//
//  Created by Khaled on 8/4/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class zoom_scrollView: UIScrollView ,UIScrollViewDelegate{
    
    
    
    func zoom(viewController:UIViewController)
    {
//        viewController.view.backgroundColor = UIColor.red
        
        let rec = viewController.view.frame
        
//        scrollView = zoom_scrollView()
        self.frame = rec
        
        
        for i in viewController.view.subviews
        {
            
            self.addSubview(i)
            
        }
        
        let img = KSImageView()
        img.frame = rec
//        img.image = UIImage()
        viewController.view .addSubview(img)
        
        
        viewController.view .addSubview(self)
        self.autoresizingMask = [.flexibleBottomMargin,.flexibleWidth,.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin]
        
        
        self.zoom()
    }
    
        func zoom() {
        
//            self.backgroundColor = UIColor.red
        
        self.delegate = self
        self.minimumZoomScale = 0.1
        self.maximumZoomScale = 1.0
        self.zoomScale = 1.0
        
        self.pinchGestureRecognizer?.require(toFail: self.panGestureRecognizer)

        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        //        let screenHeight = screenRect.size.height
        
        if screenWidth != 1366
        {
            if screenWidth == 1194
            {
                self.zoomScale = 0.82

            }
            else
            {
                self.zoomScale = screenWidth / 1366.0 //0.75

            }
        }
            
        
        
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return super.superview
    }
    
}
