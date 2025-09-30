//
//  AddOperationRouter.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/31/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import UIKit
class AddOperationRouter {
    weak var viewController: AddOperationVC?
    static func createModule() -> AddOperationVC {
        let vc:AddOperationVC = AddOperationVC()
        let addOperationVM = AddOperationVM()
        let router = AddOperationRouter()
        addOperationVM.API = api()
        router.viewController = vc
        vc.addOperationVM = addOperationVM
        vc.addOperationRouter = router
    return vc
    }
   
}
