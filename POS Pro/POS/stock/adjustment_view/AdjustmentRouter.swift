//
//  AdjustmentRouter.swift
//  pos
//
//  Created by M-Wageh on 31/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import UIKit
import MMDrawerController
class AdjustmentRouter {
    weak var viewController: AdjustmentSVC?
    static func createModule() -> AdjustmentSVC {
        let inStockSB = UIStoryboard(name: "AdjustmentSB", bundle: nil)
        let vc = inStockSB.instantiateViewController(withIdentifier: "AdjustmentSVC") as! AdjustmentSVC
       let rootVM = AdjustmentRootVM()
        rootVM.API = api()
        let detailsVM = AdjustmentDetailsVM()
        detailsVM.API = api()
        detailsVM.delegate = rootVM
        rootVM.delegate = detailsVM
        vc.adjustmentDetailsVM = detailsVM
        vc.adjustmentRootVM = rootVM
//        vc.rootDelegate = rootVM
//        vc.detailsDelegate = detailsVM
        let router = AdjustmentRouter()
        router.viewController = vc
        vc.adjustmentRouter = router
    return vc
    }
    func openLinesListVC(filterCategoryID: [Int]?){
        if let delegate = viewController?.adjustmentDetailsVM{
            let linesListVC = LinesListRouter.createModule(delegate:delegate,viewType: .SAVE,filterCategoryID: filterCategoryID)
            linesListVC.preferredContentSize = CGSize(width: 683, height: 700)
            linesListVC.modalPresentationStyle = .overCurrentContext
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
    func loadAdjustment(){
        DispatchQueue.main.async {
            
            let controller = AdjustmentRouter.createModule()
            self.centerNav = UINavigationController(rootViewController: controller)
            self.centerNav?.isNavigationBarHidden = true
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "appStoryboard", bundle: nil)
            let leftSideNav = mainStoryboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! menu_left
//            leftSideNav.delegate = controller
            leftSideNav.parentViewConroller =   self.centerNav
            leftSideNav.parentName = "Adjustments"
            
            
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
