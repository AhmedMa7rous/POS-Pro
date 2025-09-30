//
//  MultiAddressRouter.swift
//  pos
//
//  Created by M-Wageh on 12/10/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MultiAddressRouter {
    weak var viewController: MultiAddressVC?
    static func createModule(parentCustomer:res_partner_class?,listConntectAddressAdded:[res_partner_class]?,completeHandler:@escaping ((_ listConntectAddressAdded:[res_partner_class]?)->Void)) -> MultiAddressVC {
        let vc = MultiAddressVC.loadFromNib()
        let router = MultiAddressRouter()
        router.viewController = vc
        vc.parentCustomer = parentCustomer
        var listConntectAddress:[res_partner_class] = []
        if let listConntectAddressAdded = listConntectAddressAdded, listConntectAddressAdded.count > 0{
            listConntectAddress.append(contentsOf: listConntectAddressAdded)
        }
        if let parentCustomer = parentCustomer{
            listConntectAddress.append(contentsOf: parentCustomer.getDeliveryContacts())
        }
        vc.listConntectAddressAdded = listConntectAddress
        vc.router = router
        vc.completeAddAddress = completeHandler
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = CGSize(width: 900, height: 700)
        // vc.modalPresentationStyle = .popover
        // vc.preferredContentSize = CGSize(width: 683, height: 700)
        // let popover = vc.popoverPresentationController!
        // popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
        // popover.sourceView = sender
        // popover.sourceRect =  (sender as AnyObject).bounds
        return vc
    }
    
    func closeVC(isCompleted:Bool = false){
        if isCompleted{
            self.viewController?.completeAddAddress?(self.viewController?.listConntectAddressAdded)
        }
        self.viewController?.view.removeFromSuperview()
        self.viewController?.dismiss(animated: true)
    }
   
}
