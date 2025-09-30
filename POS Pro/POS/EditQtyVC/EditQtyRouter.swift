//
//  EditQtyRouter.swift
//  pos
//
//  Created by M-Wageh on 16/09/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
class EditQtyRouter{
    static func createModule(_ sender:UIView? , initQty:String?) -> EditQtyVC {
        let vc:EditQtyVC = EditQtyVC()
        if let sender = sender{
            vc.modalPresentationStyle = .popover
            vc.qty = initQty?.toDouble() ?? 1
            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
}
