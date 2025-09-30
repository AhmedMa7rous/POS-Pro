//
//  UIWindow+ext.swift
//  pos
//
//  Created by khaled on 8/15/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation
import MMDrawerController
extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIWindow.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                if let presentedViewController = vc as? MMDrawerController {
                    return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController.centerViewController)
                }else {
                    return vc
                }
            }
        }
    }
}
