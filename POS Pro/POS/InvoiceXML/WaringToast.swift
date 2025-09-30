//
//  WaringToast.swift
//  pos
//
//  Created by M-Wageh on 16/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class WaringToast{
    private init(){}
    static let shared = WaringToast()
   let message_warring = "Check your internet connection ".arabic("يرجي التحقق من اتصال الانترنت     ")
    private func showWaringMessage(){
        SharedManager.shared.banner?.dismissesOnTap = false
        SharedManager.shared.banner?.show(duration: 3.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
//                        self.showBannerWaitingSearchIP()
            SharedManager.shared.initalBannerNotification(title: "", message: self.message_warring, success: false, icon_name: "icon_error" )
            SharedManager.shared.banner?.dismissesOnTap = true
            SharedManager.shared.banner?.show(duration: 3.0)
//            MWLocalNetworking.sharedInstance.discovery.is_loading = false
        })

    }
     func showWaringAlert(with complete: (()->Void)?){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.showWaringMessage()
            complete?()

            /*
            let alert = UIAlertController(title: "Attention!".arabic("تنبيه!"), message: self.message_warring,preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Continue...".arabic("استمرار..."), style: .default, handler: { (action) in
                self.showWaringMessage()
                complete?()
                //            self.showNotification()
            }))
            AppDelegate.shared.window?.visibleViewController()?.present(alert, animated: true, completion: nil)
            */
        })
    }
    func handleShowAlertWaring(complete: (()->Void)?){
        if SharedManager.shared.posConfig().isSupportEvoice(){
            let count = pos_e_invoice_class.getCountOrderLessThan()
            if count <= 0 {
                complete?()
            }else{
                //self.showWaringAlert(with:complete)
            }
        }
    }
}
