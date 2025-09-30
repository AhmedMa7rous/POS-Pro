//
//  AdjustmentDetailsVC.swift
//  pos
//
//  Created by M-Wageh on 31/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class AdjustmentDetailsVC: UIViewController {
    @IBOutlet weak var movementsStockTable: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var validateBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addStoreItemBtn: UIButton!

    @IBOutlet weak var controlBtnsStack: UIStackView!
   
    @IBOutlet weak var startBtnStack: UIStackView!
    var adjustmentDetailsVM:AdjustmentDetailsVM?
    var adjustmentRouter:AdjustmentRouter?
    var isLoadMore = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        initalState()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func tapOnAddStoreItem(_ sender: UIButton) {
        self.adjustmentRouter?.openLinesListVC(filterCategoryID: self.adjustmentDetailsVM?.filterCategoryIds)
    }
    
    
    @IBAction func tapOnValidateBtn(_ sender: UIButton) {
        self.adjustmentDetailsVM?.hitUpdateQtyAndValidate()
    }
    
    func showToastError(msg:String,success:Bool){
        let titleToast = success ? "Success" : "Fail"
        let icon =  success ? "icon_done" : "icon_error"
        SharedManager.shared.initalBannerNotification(title:titleToast , message: msg, success: success, icon_name: icon)
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)

    }
    func resetScreenUI(){
        self.titleLbl.text = ""

        self.emptyView.isHidden = true
        //self.isLoadMore = false
        self.controlBtnsStack.isHidden = true
        self.startBtnStack.isHidden = true
        self.addStoreItemBtn.isHidden = true
    }
    //MARK:- inital State Lines List  screen
    func initalState(){
        self.adjustmentDetailsVM?.updateLoadingStatusClosure = { (state, message, isSucess) in
           
            switch state {
            case .empty:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.emptyView.isHidden = (self.adjustmentDetailsVM?.showStartBtnStack() ?? true)
                }
                return
            case .error:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.showToastError(msg:message ?? "pleas, try again!",success:false)
                }
                return
            case .loading:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
            case .reloading:
                DispatchQueue.main.async {
                    self.resetScreenUI()
                    loadingClass.hide(view:self.view)
                }
                return
        
            case .populated:
                DispatchQueue.main.async {
                    self.emptyView.isHidden = true
//                    self.isLoadMore = false
                    self.movementsStockTable.reloadData()
                    loadingClass.hide(view:self.view)

                }
                return
            case .report:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
//                    messages.showAlert(message ?? "")
                    self.showToastError(msg: "Adjustment has validate successfully".arabic("تم التحقق من الجرد بنجاح"),success:true)
                    self.resetScreenUI()
                    self.adjustmentRouter?.openViewReportVC(htmlReport:message ?? "")
                    
                }
         
            case .addLinesToAdjustmentSucess:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.adjustmentDetailsVM?.resetLineResult()
                    self.adjustmentDetailsVM?.hitGetInventoryLines()

                }
            case .setTitle:
                DispatchQueue.main.async {
                    self.titleLbl.text = message
                    self.controlBtnsStack.isHidden = !(self.adjustmentDetailsVM?.showControlBtnsStack() ?? true)
                    self.startBtnStack.isHidden = !(self.adjustmentDetailsVM?.showStartBtnStack() ?? true)

                    self.addStoreItemBtn.isHidden = !(self.adjustmentDetailsVM?.showControlBtnsStack() ?? true)
//                    self.addStoreItemBtn.isHidden = self.adjustmentDetailsVM?.adjustmentStateTypes != AdjustmentRootVM.AdjustmentStateTypes.READY

                }
                
            }
            
        }
    }
   
//    func loadMoreData(){
//        if !isLoadMore {
//            self.isLoadMore = true
//            adjustmentDetailsVM?.hitGetInventoryLines()
//        }
//    }
    
    @IBAction func tapOnCancelBtn(_ sender: UIButton) {
        self.adjustmentDetailsVM?.hitCancelInventory()

    }
    
    @IBAction func tapOnStartBtn(_ sender: KButton) {
        self.adjustmentDetailsVM?.hitStartInventory()
    }
    
}
extension AdjustmentDetailsVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, UITableViewDataSourcePrefetching{
    func setupTable(){
        movementsStockTable.prefetchDataSource = self
        movementsStockTable.delegate = self
        movementsStockTable.dataSource = self
        movementsStockTable.rowHeight = UITableView.automaticDimension
        movementsStockTable.estimatedRowHeight = 300
//        refreshControl.addTarget(self, action: #selector(refreshStoredItemTable), for: .valueChanged)
//        StoredItemTable.addSubview(refreshControl)
        movementsStockTable.register(UINib(nibName: "StockItemCell", bundle: nil), forCellReuseIdentifier: "StockItemCell")
    }
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        for index in indexPaths {
//            let count = adjustmentDetailsVM?.getResultCount() ?? 0
//            if index.row > count - 3 && !(adjustmentDetailsVM?.state == .loading )  {
//                loadMoreData()
//                break
//            }
//        }
        return
        /*if  adjustmentDetailsVM?.isEnded() ?? true{
            return
        }
        let upcomingRows = indexPaths.map { $0.row }
        
        if let maxIndex = upcomingRows.max() {
        let count = adjustmentDetailsVM?.getResultCount() ?? 0
        let currentPage = (count / 40)
        
        let nextPage: Int = Int(ceil(Double(maxIndex) / Double(40))) + 1

//        for index in indexPaths {
        if nextPage > currentPage  && !(adjustmentDetailsVM?.state == .loading )  {
            loadMoreData()
            
        }
   // }
        }
        */
    }
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return adjustmentDetailsVM?.getResultCount() ?? 0
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockItemCell", for: indexPath) as! StockItemCell
        // Configure the cell...
        cell.inventoryLineItem = adjustmentDetailsVM?.getItem(at:indexPath.row)
         cell.appearnceAddMinsBtns(with:!(self.adjustmentDetailsVM?.showControlBtnsStack() ?? true))
         cell.removeBtn.isHidden = true
        cell.setBtnsTag(with: indexPath)
        cell.btnMins.addTarget(self, action: #selector(decreaseQTY(_ :)), for: .touchUpInside)
        cell.btnPlus.addTarget(self, action: #selector(increaseQTY(_ :)), for: .touchUpInside)
        if !cell.isBtnsHiden() {
     
            cell.qtyTF.tag = indexPath.row
            cell.qtyLbl.tag = indexPath.row
            cell.qtyTF.delegate = self
            cell.qtyTF.isHidden = true
        cell.qtyLbl.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(lblQtyTapped(_ :)))
        tapGesture.numberOfTapsRequired = 1
        cell.qtyLbl.addGestureRecognizer(tapGesture)
            //MARK:- Edit UOM
            cell.uomLbl.isUserInteractionEnabled = true
            let tapUOMGesture = UITapGestureRecognizer(target: self, action:  #selector(lblUOMTapped(_ :)))
            tapUOMGesture.numberOfTapsRequired = 1
            cell.uomLbl.addGestureRecognizer(tapUOMGesture)
        }else{
            cell.qtyLbl.isUserInteractionEnabled = false
            cell.uomLbl.isUserInteractionEnabled = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @objc func lblUOMTapped(_ sender : UITapGestureRecognizer){
        if let senderView = sender.view   {
            loadingClass.show(view: senderView)

            let row = senderView.tag
            if let productStroable = adjustmentDetailsVM?.getItem(at: row){
                let stroableID = Int(productStroable.product_id.first ?? "0") ?? 0
                let selectUomID = Int(productStroable.uom_id.first ?? "0") ?? 0
                StorableUOMInteractor.shared.getUOM(sender: senderView,
                                                    productID:stroableID,
                                                    defaultUOM:selectUomID) { selectUOM in
                    self.adjustmentDetailsVM?.setUOM(for: row, with: selectUOM)
                    
                } completion: { alertController in
                    DispatchQueue.main.async {
                        loadingClass.hide(view:senderView)
                    }
                    if let alertController = alertController {
                     self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    @objc func updateQTY(_ sender:UIStepper){
        adjustmentDetailsVM?.setQty(for: sender.tag,with: sender.value)
        self.movementsStockTable.reloadData()
    }
    @objc func decreaseQTY(_ sender:UIButton){
        if let currentQty = adjustmentDetailsVM?.getQty(for: sender.tag), currentQty > 0{
            adjustmentDetailsVM?.setQty(for: sender.tag,with: currentQty - 1)
            self.movementsStockTable.reloadData()
        }
    }
    @objc func increaseQTY(_ sender:UIButton){
        if let currentQty = adjustmentDetailsVM?.getQty(for: sender.tag){
            adjustmentDetailsVM?.setQty(for: sender.tag,with: currentQty + 1)
            self.movementsStockTable.reloadData()
        }
    }
    @objc func lblQtyTapped(_ sender : UITapGestureRecognizer){
        guard let index = sender.view?.tag  else {
            return
        }
        if let cell =  self.movementsStockTable.cellForRow(at: IndexPath(row: index , section: 0)) as? StockItemCell {
            sender.view?.isHidden = true
            cell.qtyTF.isHidden = false
            cell.qtyTF.text = cell.qtyLbl.text
            cell.qtyTF.becomeFirstResponder()
        }
            
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isHidden = true
        if let cell =  self.movementsStockTable.cellForRow(at: IndexPath(row: textField.tag , section: 0)) as? StockItemCell {
             cell.qtyLbl.isHidden = false
            if let newQty = Double(textField.text ?? "") {
                cell.inventoryLineItem?.setQty(with:newQty)
                adjustmentDetailsVM?.setQty(for: textField.tag,with: newQty)


            }
         }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.isHidden = true
        if let cell =  self.movementsStockTable.cellForRow(at: IndexPath(row: textField.tag , section: 0)) as? StockItemCell {
             cell.qtyLbl.isHidden = false
            if let newQty = Double(textField.text ?? "") {
                cell.inventoryLineItem?.setQty(with: newQty)
                adjustmentDetailsVM?.setQty(for: textField.tag,with: newQty)
            }
         }
        
       
        return true
    }

}
