//
//  MWComboRouter.swift
//  pos
//
//  Created by M-Wageh on 09/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MWComboRouter {
    weak var viewController: MWComboVC?
    static func createModule(multiProductObject:MultiProductObject?,orderVc:order_listVc?,completeHandler:@escaping ((_ line:pos_order_line_class?,_ orginQty:Double?)->Void)) -> MWComboVC {
        let vc = MWComboVC.loadFromNib()
        
       let vm = MWComboVM(multiProductObject,orderVc: orderVc)
        vm.doneCompleteComboHandler = completeHandler
        vc.mwComboVM = vm
        let router = MWComboRouter()
        router.viewController = vc
        vc.router = router
        //        vc.modalPresentationStyle = .formSheet
        //        vc.preferredContentSize = CGSize(width: 900, height: 700)
        //
        //        vc.modalPresentationStyle = .popover
              //        vc.preferredContentSize = CGSize(width: 683, height: 700)
              //        let popover = vc.popoverPresentationController!
              //        popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
              //        popover.sourceView = sender
              //        popover.sourceRect =  (sender as AnyObject).bounds
        return vc
    }
    
    func closeVC(){
        self.viewController?.view.removeFromSuperview()

    }
   
}
extension UIViewController {
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
}
