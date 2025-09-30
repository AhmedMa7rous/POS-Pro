//
//  BarcodeDeviceRouter.swift
//  pos
//
//  Created by M-Wageh on 15/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class BarcodeDeviceRouter {
    weak var viewController: BarcodeDeviceVC?
    static func createModule() -> BarcodeDeviceVC {
        let vc:BarcodeDeviceVC = BarcodeDeviceVC()
        let router = BarcodeDeviceRouter()
        vc.router = router
        vc.setting = SharedManager.shared.appSetting()
        let barcodeDeviceInteractor = BarcodeDeviceInteractor.shared
        barcodeDeviceInteractor.initalize()
        vc.barcodeDeviceInteractor = barcodeDeviceInteractor
        router.viewController = vc
        return vc
    }
     func setupVC() -> SetupBarcodeScannerVC {
        let viewControllers:[StepSetupVC] = viewController?.barcodeDeviceInteractor?.getStepsSetup().map {
            if $0.type == .table {
               return StepSetupVC(model: $0,barcodeDeviceInteractor: viewController?.barcodeDeviceInteractor, nibName: "StepSetupVC", bundle: nil)

            }else{
               return StepSetupVC(model: $0,barcodeDeviceInteractor:nil, nibName: "StepSetupVC", bundle: nil)
            }
            
        } ?? []
      return SetupBarcodeScannerVC(nibName: "SetupBarcodeScannerVC",
                                          bundle: nil,
                                          viewControllers: viewControllers)
    }
}

