//
//  ProductAvaliablityRouter.swift
//  pos
//
//  Created by M-Wageh on 20/03/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class ProductAvaliablityRouter{
    weak var mwCategoryVC: MWCategoryVC?
    weak var productAvaliablityVC: ProductAvaliablityVC?

    weak var mwProductsListVC: MWProductsListVC?
    weak var productAvaliablityVM:ProductAvaliablityVM?

    static func createMWCategoryModule() -> MWCategoryVC {
        let vc = MWCategoryVC.loadFromNib()
        let vm = ProductAvaliablityVM()
        vm.setCategoryList()
        let router = ProductAvaliablityRouter()
        router.mwCategoryVC = vc
        vc.router = router
        vc.productAvaliablityVM = vm
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
    func openProductAvaliablityVC(){
        if let vm = self.mwCategoryVC?.productAvaliablityVM{
            let vc = ProductAvaliablityRouter.createProductAvaliablityModule(vm:vm )
            vc.modalPresentationStyle = .fullScreen
            self.mwCategoryVC?.present(vc, animated: true)
        }
    }
    static func createProductAvaliablityModule(vm:ProductAvaliablityVM,complete: (()->())? = nil) -> ProductAvaliablityVC {
        let vc = ProductAvaliablityVC.loadFromNib()
        let router = ProductAvaliablityRouter()
        router.productAvaliablityVC = vc
        vc.router = router
        vc.productAvaliablityVM = vm
        vc.complete = complete
        return vc
    }
    
    func close(vc:UIViewController,completion: (() -> Void)? = nil){
        vc.dismiss(animated: true,completion:completion)

    }
}
extension AppDelegate {
    func initialMWCategoryVC(){
        self.resetAllVC()
        self.mwCategoryVC = ProductAvaliablityRouter.createMWCategoryModule()
        guard let mwCategoryVC = self.mwCategoryVC else{return}
            self.centerNav = UINavigationController(rootViewController: mwCategoryVC)
            self.centerNav?.isNavigationBarHidden = true
        self.rootDrawer(for:"Products avaliablity",delegate:memberShipVC )
        
    }
    
}
