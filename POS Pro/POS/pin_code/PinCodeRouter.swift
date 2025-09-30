//
//  PinCodeRouter.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/7/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import UIKit
class PinCodeRouter {
    weak var viewController: PinCodeVC?
    static func createModule() -> PinCodeVC {
        let vc:PinCodeVC = PinCodeVC()
        let router = PinCodeRouter()
        let vm = PinCodeVM()
        router.viewController = vc
        vm.API = SharedManager.shared.conAPI()
        vc.pinCodeVM = vm
        vc.router = router
        return vc
    }
    func openLoginVC() {
        let storyboard = UIStoryboard(name: "newloginStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! loginVC
        vc.re_login = false
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    func openLoadingSc(){
        AppDelegate.shared.loadLoading()
    }
   
      
}
extension AppDelegate {
    func initialPinCodeVC(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = PinCodeRouter.createModule()
        let navigation : UINavigationController = UINavigationController(rootViewController: rootViewController)
        navigation.isNavigationBarHidden = true
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
    }
}
