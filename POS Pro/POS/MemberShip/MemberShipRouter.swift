//
//  MemberShipRouter.swift
//  pos
//
//  Created by M-Wageh on 26/02/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
import UIKit
class MemberShipRouter {
    weak var viewController: MemberShipVC?
    static func createModule() -> MemberShipVC {
        let vc:MemberShipVC = MemberShipVC()
        let memberShipVM = MemberShipVM()
        
        let calendar  = calendarVC()
        calendar.modalPresentationStyle = .formSheet
        calendar.didSelectDay = memberShipVM.didSelectDay
        calendar.clearDay = memberShipVM.clearDay
        
        vc.calendar = calendar
        vc.memberShipVM = memberShipVM
        return vc
    }
  
    func openLoadingSc(){
        AppDelegate.shared.loadLoading()
    }
   
      
}
extension AppDelegate {
    func initialMemberShipVC(){
        guard let targetVC =  UIApplication.getTopViewController() else {
            print("Error: Unable to find a valid view to show the loading animation.")
            return
        }
        rules.check_access_rule(rule_key.memberShips,for: targetVC) {
            DispatchQueue.main.async {
                self.resetAllVC()
                self.memberShipVC = MemberShipRouter.createModule()
                guard let memberShipVC = self.memberShipVC else{return}
                    self.centerNav = UINavigationController(rootViewController: memberShipVC)
                    self.centerNav?.isNavigationBarHidden = true
                self.rootDrawer(for:"MemberShips",delegate:memberShipVC )
            }
        }
       
        
    }
    
}
