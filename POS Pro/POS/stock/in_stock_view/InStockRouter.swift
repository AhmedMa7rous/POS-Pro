//
//  InStockRouter.swift
//  pos
//
//  Created by M-Wageh on 16/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import UIKit
import MMDrawerController
class InStockRouter {
    weak var viewController: InStockSVC?
    static func createModule(with stock_type:STOCK_TYPES = .IN_STOCK_ALL) -> InStockSVC {
        let inStockSB = UIStoryboard(name: "InStockSB", bundle: nil)
        let vc = inStockSB.instantiateViewController(withIdentifier: "InStockSVC") as! InStockSVC
       let rootVM = InStockRootVM()
        rootVM.API = api()
        rootVM.stock_type = stock_type

        let detailsVM = InStockDetailsVM()
        detailsVM.API = api()
        detailsVM.delegate = rootVM
        rootVM.delegate = detailsVM
        vc.inStockDetailsVM = detailsVM
        vc.inStockRootVM = rootVM
//        vc.rootDelegate = rootVM
//        vc.detailsDelegate = detailsVM
        let router = InStockRouter()
        router.viewController = vc
        vc.inStockRouter = router
    return vc
    }
    func openLinesListVC(){
        if let delegate = viewController?.inStockDetailsVM{
            let linesListVC = LinesListRouter.createModule(delegate:delegate,viewType: .SAVE)
            linesListVC.modalPresentationStyle = .pageSheet
            linesListVC.modalTransitionStyle = .coverVertical
            viewController?.present(linesListVC, animated: true, completion: nil)
        }
    }
    func openViewReportVC(htmlReport:String){
            let viewReportVC = ViewAndPrintReportVCRouter.createModule(htmlReport:htmlReport)
        viewReportVC.modalPresentationStyle = .formSheet
        viewReportVC.modalTransitionStyle = .coverVertical
            viewController?.present(viewReportVC, animated: true, completion: nil)
        
    }
    func openAddOperationVC(){
            let vc = AddOperationRouter.createModule()
        viewController?.navigationController?.pushViewController(vc, animated: true)
        
    }
    func openLeftMenu(){
//        viewController?.navigationController?.popViewController(animated: true)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)

    }
   
}

extension AppDelegate{
    func loadInStock(){
        DispatchQueue.main.async {
            
            let controller = InStockRouter.createModule()
            self.centerNav = UINavigationController(rootViewController: controller)
            self.centerNav?.isNavigationBarHidden = true
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "appStoryboard", bundle: nil)
            let leftSideNav = mainStoryboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! menu_left
//            leftSideNav.delegate = controller
            leftSideNav.parentViewConroller =   self.centerNav
            leftSideNav.parentName = "In Stock"
            
            
            self.centerContainer = MMDrawerController(center: self.centerNav, leftDrawerViewController: leftSideNav,rightDrawerViewController:nil)
            
            //            self.centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView;
            self.centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.tapCenterView;
            self.centerContainer!.maximumLeftDrawerWidth = 210
            
            
            self.centerContainer?.shouldStretchDrawer = false
            
            
            
            self.window!.rootViewController =  self.centerContainer
            self.window!.makeKeyAndVisible()
        }
    }
}
