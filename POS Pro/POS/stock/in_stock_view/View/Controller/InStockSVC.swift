//
//  InStockSVC.swift
//  pos
//
//  Created by M-Wageh on 16/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class InStockSVC: UIViewController {
    
    
    
    
    var inStockDetailsVM:InStockDetailsVM?
    var inStockRootVM:InStockRootVM?
    var inStockRouter:InStockRouter?
    var isLoadMore = true
//    var rootDelegate:InStockSVCProtocol?
//    var detailsDelegate:InStockSVCProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let vc = segue.destination as? InStockRootVC {
                vc.inStockRouter = self.inStockRouter
                vc.inStockRootVM = self.inStockRootVM
            }
        if let vc = segue.destination as? InStockDetailsVC {
            vc.inStockDetailsVM = self.inStockDetailsVM
            vc.inStockRouter = self.inStockRouter
        }
        
    }
    @IBAction func tapOnSideMenu(_ sender: UIButton) {
        self.inStockRouter?.openLeftMenu()
    }
    
    @IBAction func tapOnAddOperation(_ sender: UIButton) {
        self.inStockRouter?.openAddOperationVC()
    }
    
}
