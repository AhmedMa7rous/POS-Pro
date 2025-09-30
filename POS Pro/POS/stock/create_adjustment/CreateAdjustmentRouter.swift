//
//  CreateAdjustmentRouter.swift
//  pos
//
//  Created by M-Wageh on 26/07/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import UIKit
class CreateAdjustmentRouter {
    weak var viewController: CreateAdjustmentVC?
    static func createModule(adjustmentDetailsVMProtocol:AdjustmentDetailsVMProtocol) -> CreateAdjustmentVC {
        let vc:CreateAdjustmentVC = CreateAdjustmentVC()
        let createAdjustmentVM = CreateAdjustmentVM()
        let router = CreateAdjustmentRouter()
        createAdjustmentVM.delegate = adjustmentDetailsVMProtocol
        createAdjustmentVM.API = api()
        createAdjustmentVM.createAdjustmentModel = CreateAdjustmentModel()
        createAdjustmentVM.createAdjustmentModel?.products = []
        router.viewController = vc
        vc.createAdjustmentVM = createAdjustmentVM
        vc.createAdjustmentRouter = router
    return vc
    }
   
}

