//
//  ProductStorableListVC.swift
//  pos
//
//  Created by M-Wageh on 18/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class OrderSrockRquestListVC: UIViewController {
    @IBOutlet weak var StoredItemTable: UITableView!
    @IBOutlet weak var emptyView: UIView!
    var orderSrockRquestListVM:OrderSrockRquestListVM?

    @IBOutlet weak var emptyDetailsView: UIView!
    @IBOutlet weak var detailsTable: UITableView!
    
    @IBOutlet weak var printerBtn: UIButton!
    var orderSrockRquestListRouter:OrderSrockRquestListRouter?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        initalState()
        self.orderSrockRquestListVM?.getStockRequestOrder()
        resetPrinterBtn()
        
    }
    func resetPrinterBtn(){
        self.printerBtn.tag = -1
        self.printerBtn.isHidden = true

    }
    //MARK:- inital State Lines List  screen
    func initalState(){
        self.orderSrockRquestListVM?.updateLoadingStatusClosure = { (state, message, isSucess) in
           
            switch state {
            case .empty:
                DispatchQueue.main.async {
                    self.resetPrinterBtn()
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
                    self.resetPrinterBtn()
                    self.emptyView.isHidden = true
                    self.StoredItemTable.reloadData()
                    loadingClass.hide(view:self.view)
                }
                return
            case .fetchDetails:
                DispatchQueue.main.async {
                    self.detailsTable.reloadData()
                    loadingClass.hide(view:self.view)
                    self.emptyDetailsView.isHidden = true
                    self.printerBtn.isHidden = false

                }
                return
            case .emptyDeails:
                DispatchQueue.main.async {
                    self.resetPrinterBtn()
                    loadingClass.hide(view:self.view)
                    self.emptyDetailsView.isHidden = false
                }
                return
            case .reportPrinter:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.orderSrockRquestListRouter?.openViewReportVC(htmlReport:message ?? "")
                }
                return
            }
            
        }
    }
    
    @IBAction func tapOnBack(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)

    }
    
    @IBAction func tapOnCreateBtn(_ sender: Any) {
        let vc = CreateStockRequestVC.createModule(completeHandler: {
            self.orderSrockRquestListVM?.getStockRequestOrder()
            messages.showAlert("Your request order stock done sucessfully".arabic("تم إنشاء طلب المخزون بنجاح"))

        })
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func tapOnPrinter(_ sender: UIButton) {
        if sender.tag >= 0 {
            self.orderSrockRquestListVM?.printReport(at:IndexPath(row: sender.tag, section: 0))
        }
    }
    
}
extension OrderSrockRquestListVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
        StoredItemTable.rowHeight = UITableView.automaticDimension
        StoredItemTable.estimatedRowHeight = 300
        StoredItemTable.register(UINib(nibName: "StockMovementCell", bundle: nil), forCellReuseIdentifier: "StockMovementCell")
        detailsTable.register(UINib(nibName: "StockRequestCell", bundle: nil), forCellReuseIdentifier: "StockRequestCell")

    }
  
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if tableView.tag == 1 {
             return orderSrockRquestListVM?.stockDetailsResult?.count ?? 0
         }
        return orderSrockRquestListVM?.getResultCount() ?? 0
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if tableView.tag == 1 {
             let cell = tableView.dequeueReusableCell(withIdentifier: "StockRequestCell", for: indexPath) as! StockRequestCell
             // Configure the cell...
             cell.stockRequestOrderDetailsModel = orderSrockRquestListVM?.stockDetailsResult?[indexPath.row]
              cell.setHideRemoveBtn(with: true)
              cell.setHideContolerBtns(with: true)
             return cell
         }
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockMovementCell", for: indexPath) as! StockMovementCell
         cell.stockRequestOrderMoveModel = orderSrockRquestListVM?.getItem(at:indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            self.printerBtn.tag = indexPath.row
            orderSrockRquestListVM?.getStockRequestOrderDetails(at:indexPath)
        }
    }
    
}
