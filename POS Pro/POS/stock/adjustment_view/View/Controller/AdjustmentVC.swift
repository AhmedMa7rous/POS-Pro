//
//  AdjustmentVC.swift
//  pos
//
//  Created by M-Wageh on 31/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class AdjustmentRootVC: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var adjustmentTable: UITableView!
    @IBOutlet weak var emptyView: UIView!
    var refreshControl = UIRefreshControl()

    var adjustmentRootVM:AdjustmentRootVM?
    var adjustmentRouter:AdjustmentRouter?
    var isLoadMore = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        initalState()
        refreshAdjustmentTable()
    }
    
    //MARK:- inital State Lines List  screen
    func initalState(){
        self.adjustmentRootVM?.updateLoadingStatusClosure = { (state, message, isSucess) in
           
            switch state {
            case .empty:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.emptyView.isHidden = false
                }
                return
            case .error:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    messages.showAlert(message ?? "pleas, try again!")
                }
                return
            case .loading:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
            case .populated:
                DispatchQueue.main.async {
                    self.emptyView.isHidden = true
                    self.isLoadMore = false
                    self.refreshControl.endRefreshing()
                    self.adjustmentTable.reloadData()
                    loadingClass.hide(view:self.view)

                }
                return
            }
            
        }
    }
    @objc func refreshAdjustmentTable(){
        adjustmentRootVM?.refershInventoryStateTypes()
    }
    func loadMoreData(){
        if !isLoadMore {
            self.isLoadMore = true
            adjustmentRootVM?.hitGetInventory()
        }
    }
    
    @IBAction func tapOnSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            //MARK:-Draft Status
            self.adjustmentRootVM?.didSelectInStockState(AdjustmentRootVM.AdjustmentStateTypes.DRAFT)
        case 1:
            //MARK:-Waiting Status
            self.adjustmentRootVM?.didSelectInStockState(AdjustmentRootVM.AdjustmentStateTypes.WAITING)

//        case 2:
//            //MARK:-Reay Status
//            self.adjustmentRootVM?.didSelectInStockState(AdjustmentRootVM.AdjustmentStateTypes.READY)

        case 3:
            //MARK:-Done Status
            self.adjustmentRootVM?.didSelectInStockState(AdjustmentRootVM.AdjustmentStateTypes.DONE)

//        case 4:
//            //MARK:-Cancelled Status
//            self.adjustmentRootVM?.didSelectInStockState(AdjustmentRootVM.AdjustmentStateTypes.CANCEL)

        default:
            return
        }
    }
    
    @IBAction func tapOnAddNewBtn(_ sender: KButton) {
        guard let adjustmentRootVM = self.adjustmentRootVM else {return}
        let vc = CreateAdjustmentRouter.createModule(adjustmentDetailsVMProtocol:  adjustmentRootVM)
        vc.modalPresentationStyle = .overCurrentContext
//        vc.modalTransitionStyle = .coverVertical
//        vc.preferredContentSize = CGSize(width: 900, height: 700)
        present(vc, animated: true, completion: nil)

//        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    

}
extension AdjustmentRootVC:UITableViewDelegate,UITableViewDataSource, UITableViewDataSourcePrefetching{
    func setupTable(){
        adjustmentTable.rowHeight = UITableView.automaticDimension
        adjustmentTable.estimatedRowHeight = 60
        adjustmentTable.register(UINib(nibName: "StockMovementCell", bundle: nil), forCellReuseIdentifier: "StockMovementCell")

        adjustmentTable.prefetchDataSource = self
        adjustmentTable.delegate = self
        adjustmentTable.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshAdjustmentTable), for: .valueChanged)
        adjustmentTable.addSubview(refreshControl)
    }
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if  adjustmentRootVM?.isEnded() ?? true{
            return
        }
        let upcomingRows = indexPaths.map { $0.row }
        
        if let maxIndex = upcomingRows.max() {
        let count = adjustmentRootVM?.getResultCount() ?? 0
        let currentPage = (count / 40)
        
        let nextPage: Int = Int(ceil(Double(maxIndex) / Double(40))) + 1

//        for index in indexPaths {
        if nextPage > currentPage  && !(adjustmentRootVM?.state == .loading )  {
            loadMoreData()
            
        }
   // }
        }
        
        
//        for index in indexPaths {
//            let count = adjustmentRootVM?.getResultCount() ?? 0
//            if index.row > count - 3 && !(adjustmentRootVM?.state == .loading )  {
//                loadMoreData()
//                break
//            }
//        }
        
    }
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return adjustmentRootVM?.getResultCount() ?? 0
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockMovementCell", for: indexPath) as! StockMovementCell
//        cell.fromToStack.isHidden = true
//        cell.nameDateStack.axis = .vertical
//        cell.nameStockLbl.numberOfLines = 0
        // Configure the cell...
        cell.inventory_item = adjustmentRootVM?.getItem(at:indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = adjustmentRootVM?.getItem(at:indexPath.row){
            adjustmentRootVM?.delegate?.didSelect(item)
        }
    }
    
    
}
