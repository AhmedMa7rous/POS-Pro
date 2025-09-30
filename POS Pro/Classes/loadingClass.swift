//
//  loadingClass.swift
//  pos
//
//  Created by khaled on 8/15/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import Lottie
class loadingClass: NSObject {
    
    private static let animationName = "loading"
    private static let animationTag = 123456
    private static let animationView = AnimationView()
    
    static func show(view: UIView? = nil, addToSuperview: Bool = false) {
        guard let targetView = view ?? UIApplication.getTopViewController()?.view else {
            print("Error: Unable to find a valid view to show the loading animation.")
            return
        }
        
        let starAnimation = Animation.named(animationName)
        animationView.animation = starAnimation
        animationView.contentMode = .scaleAspectFill
        animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        animationView.center = targetView.center
        animationView.loopMode = .loop
        animationView.play()
        animationView.tag = animationTag
        
        if addToSuperview {
            targetView.superview?.addSubview(animationView)
        } else {
            targetView.addSubview(animationView)
        }
    }
    
    static func hide(view: UIView? = nil) {
        guard let targetView = view ?? UIApplication.getTopViewController()?.view else {
            print("Error: Unable to find a valid view to hide the loading animation.")
            return
        }
        animationView.removeFromSuperview()
        for subview in targetView.subviews where subview.tag == animationTag {
            subview.removeFromSuperview()
        }
    }
}
/*
class loadingClass: NSObject {
    
    static  let animation_name = "loading"
    static   var starAnimationView = AnimationView()
    
    static func show(){
        
        if let topVC = UIApplication.getTopViewController() {
            show(view: topVC.view)
        }
        
    }
    
    
    static   func show(view:UIView)   {
        
        if #available(iOS 10.0, *)
        {
            let starAnimation = Animation.named(animation_name)
            
            starAnimationView.animation = starAnimation
            
            starAnimationView.contentMode = UIView.ContentMode.scaleAspectFill
            
            starAnimationView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
            
            
            starAnimationView.center = view .center
            
            
            //        starAnimationView.backgroundBehavior = .forceFinish
            starAnimationView.loopMode = .loop
            
            starAnimationView.play()
            
            starAnimationView.tag = 123456
            view.superview?.addSubview(starAnimationView)
        }
        
        
    }
    
    static   func show_in(view:UIView)   {
        
        if #available(iOS 10.0, *)
        {
            let starAnimation = Animation.named(animation_name)
            
            starAnimationView.animation = starAnimation
            
            starAnimationView.contentMode = UIView.ContentMode.scaleAspectFill
            
            starAnimationView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
            
            
            starAnimationView.center = view .center
            
            
            //        starAnimationView.backgroundBehavior = .forceFinish
            starAnimationView.loopMode = .loop
            
            starAnimationView.play()
            
            starAnimationView.tag = 123456
            view.addSubview(starAnimationView)
        }
        
        
    }
    
    
    static  func hide()   {
        
        let vc = UIApplication.getTopViewController()
        
        hide(view: vc!.view)
        
        
    }
    
    static  func hide(view:UIView)   {
        
        
        if #available(iOS 10.0, *)
        {
            
            for view in (view.superview?.subviews ?? []) as [UIView] {
                
                if view.isKind(of: UIView.self)
                {
                    starAnimationView.removeFromSuperview()
                    if(view.tag == 123456)
                    {
//                        starAnimationView.stop()
                        view.removeFromSuperview()
                    }
                }
                
            }
        }
        
    }
    
    
    
    
    
    
}
*/
