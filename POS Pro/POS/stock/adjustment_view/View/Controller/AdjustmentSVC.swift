//
//  AdjustmentSVC.swift
//  pos
//
//  Created by M-Wageh on 31/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class AdjustmentSVC: UIViewController {
    
    
    
    
    var adjustmentDetailsVM:AdjustmentDetailsVM?
    var adjustmentRootVM:AdjustmentRootVM?
    var adjustmentRouter:AdjustmentRouter?
    var isLoadMore = true
//    var rootDelegate:InStockSVCProtocol?
//    var detailsDelegate:InStockSVCProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let vc = segue.destination as? AdjustmentRootVC {
                vc.adjustmentRootVM = self.adjustmentRootVM
            }
        if let vc = segue.destination as? AdjustmentDetailsVC {
            vc.adjustmentDetailsVM = self.adjustmentDetailsVM
            vc.adjustmentRouter = self.adjustmentRouter
        }
        
    }
    @IBAction func tapOnSideMenu(_ sender: UIButton) {
        self.adjustmentRouter?.openLeftMenu()
    }
    
    @IBAction func tapOnAddOperation(_ sender: UIButton) {
        self.adjustmentRouter?.openAddOperationVC()
    }
    
}
