//
//  InStockRootVC.swift
//  pos
//
//  Created by M-Wageh on 16/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit
enum STOCK_TYPES{
    case IN_STOCK_SEQMENT,IN_STOCK_ALL
}
class InStockRootVC: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var InStockTable: UITableView!
    @IBOutlet weak var emptyView: UIView!
    var refreshControl = UIRefreshControl()

    var inStockRootVM:InStockRootVM?
    var inStockRouter:InStockRouter?
    var isLoadMore = true

    override func viewDidLoad() {
        super.viewDidLoad()
        handleUI()
        setupTable()
        initalState()
        refreshInStockTable()
    }
    func handleUI(){
        segmentControl.isHidden = inStockRootVM?.stock_type == .IN_STOCK_ALL
    }
    //MARK:- inital State Lines List  screen
    func initalState(){
        self.inStockRootVM?.updateLoadingStatusClosure = { (state, message, isSucess) in
           
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
                    self.InStockTable.reloadData()
                    loadingClass.hide(view:self.view)

                }
                return
            }
            
        }
    }
    @objc func refreshInStockTable(){
        inStockRootVM?.refershInStockStateTypes()
    }
    func loadMoreData(){
        if !isLoadMore {
            self.isLoadMore = true
            if inStockRootVM?.stock_type == .IN_STOCK_ALL {
                inStockRootVM?.hitGetAllInOperations()
            }else{
                inStockRootVM?.hitGetInOperations()
            }
        }
    }
    @IBAction func tapOnAddNew(_ sender: KButton) {
        self.inStockRouter?.openAddOperationVC()

    }
    
    @IBAction func tapOnSegment(_ sender: UISegmentedControl) {
        if inStockRootVM?.stock_type == .IN_STOCK_ALL {
            return
        }
        switch sender.selectedSegmentIndex {
        case 0:
            //MARK:-Draft Status
            self.inStockRootVM?.didSelectInStockState(InStockRootVM.InStockStateTypes.DRAFT)
        case 1:
            //MARK:-Waiting Status
            self.inStockRootVM?.didSelectInStockState(InStockRootVM.InStockStateTypes.WAITING)

        case 2:
            //MARK:-Reay Status
            self.inStockRootVM?.didSelectInStockState(InStockRootVM.InStockStateTypes.READY)

        case 3:
            //MARK:-Done Status
            self.inStockRootVM?.didSelectInStockState(InStockRootVM.InStockStateTypes.DONE)

        case 4:
            //MARK:-Cancelled Status
            self.inStockRootVM?.didSelectInStockState(InStockRootVM.InStockStateTypes.CANCEL)

        default:
            return
        }
    }
    

}
extension InStockRootVC:UITableViewDelegate,UITableViewDataSource, UITableViewDataSourcePrefetching{
    func setupTable(){
        InStockTable.prefetchDataSource = self
        InStockTable.delegate = self
        InStockTable.dataSource = self
        InStockTable.rowHeight = UITableView.automaticDimension
        InStockTable.estimatedRowHeight = 300
        refreshControl.addTarget(self, action: #selector(refreshInStockTable), for: .valueChanged)
        InStockTable.addSubview(refreshControl)
        InStockTable.register(UINib(nibName: "StockMovementCell", bundle: nil), forCellReuseIdentifier: "StockMovementCell")
    }
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
       
        if  inStockRootVM?.isEnded() ?? true{
            return
        }
        let upcomingRows = indexPaths.map { $0.row }
        
        if let maxIndex = upcomingRows.max() {
        let count = inStockRootVM?.getResultCount() ?? 0
        let currentPage = (count / 40)
        
        let nextPage: Int = Int(ceil(Double(maxIndex) / Double(40))) + 1

//        for index in indexPaths {
        if nextPage > currentPage  && !(inStockRootVM?.state == .loading )  {
            loadMoreData()
            
        }
   // }
        }
        
    }
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return inStockRootVM?.getResultCount() ?? 0
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockMovementCell", for: indexPath) as! StockMovementCell
        // Configure the cell...
        cell.item = inStockRootVM?.getItem(at:indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = inStockRootVM?.getItem(at:indexPath.row){
            inStockRootVM?.delegate?.didSelect(item)
        }
    }
    
    
}
