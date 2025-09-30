//
//  ReturnOrderByUIDRouter.swift
//  pos
//
//  Created by M-Wageh on 04/09/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
import UIKit
class ReturnOrderByUIDRouter {
    weak var viewController: ReturnOrderByUIDVC?
    static func createModule() -> ReturnOrderByUIDVC {
        let vc:ReturnOrderByUIDVC = ReturnOrderByUIDVC()
        return vc
    }
  
    func openLoadingSc(){
        AppDelegate.shared.loadLoading()
    }
   
      
}
extension AppDelegate {
    func initialReturnOrderByUIDVC(){
        guard let targetVC =  UIApplication.getTopViewController() else {
            print("Error: Unable to find a valid view to show the loading animation.")
            return
        }
        rules.check_access_rule(rule_key.return_by_search,for: targetVC) {
            DispatchQueue.main.async {
                self.resetAllVC()
                self.returnOrderByUIDVC = ReturnOrderByUIDRouter.createModule()
                guard let returnOrderByUIDVC = self.returnOrderByUIDVC else{return}
                    self.centerNav = UINavigationController(rootViewController: returnOrderByUIDVC)
                    self.centerNav?.isNavigationBarHidden = true
                self.rootDrawer(for:"Return orders",delegate:returnOrderByUIDVC )
            }
        }
       
        
        
    }
    
}
