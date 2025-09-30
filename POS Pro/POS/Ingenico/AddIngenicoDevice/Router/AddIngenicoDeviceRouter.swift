//
//  AddIngenicoDeviceRouter.swift
//  pos
//
//  Created by M-Wageh on 07/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
class AddIngenicoDeviceRouter {
    weak var viewController: AddIngenicoDeviceVC?
    static func createModule(for deviceType:DEVICE_PAYMENT_TYPES) -> AddIngenicoDeviceVC {
        let vc:AddIngenicoDeviceVC = AddIngenicoDeviceVC()
        let router = AddIngenicoDeviceRouter()
        vc.device_type = deviceType
        vc.router = router
        vc.setting = SharedManager.shared.appSetting()
        vc.paymentDeviceProtocol =  deviceType == .GEIDEA ? GeideaInteractor.shared : IngenicoInteractor.shared
    
        return vc
    }
}
