//
//  InStockDetailsVC.swift
//  pos
//
//  Created by M-Wageh on 16/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class InStockDetailsVC: UIViewController {
    @IBOutlet weak var movementsStockTable: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var validateBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addStoreItemBtn: UIButton!

    @IBOutlet weak var confirmStack: UIStackView!
    
    @IBOutlet weak var cancelBtn: KButton!
    
    @IBOutlet weak var printtMovementBtn: UIButton!
    var inStockDetailsVM:InStockDetailsVM?
    var inStockRouter:InStockRouter?
    var isLoadMore = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        initalState()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func tapOnCancel(_ sender: KButton) {
        self.inStockDetailsVM?.hitCancelMovement()

    }
    
    @IBAction func tapOnAddStoreItem(_ sender: UIButton) {
        self.inStockRouter?.openLinesListVC()
    }
    
    
    @IBAction func tapOnValidateBtn(_ sender: UIButton) {
        self.inStockDetailsVM?.hitUpdateQtyAndValidate()
    }
    
    
    @IBAction func tapOnPrintMovementBtn(_ sender: UIButton) {
        self.inStockDetailsVM?.printReport(restResult: false)

    }
    
    //MARK:- inital State Lines List  screen
    func initalState(){
        self.inStockDetailsVM?.updateLoadingStatusClosure = { (state, message, isSucess) in
           
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
                    self.movementsStockTable.reloadData()
                    loadingClass.hide(view:self.view)

                }
                return
            case .report:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.confirmStack.isHidden = true
                    self.inStockRouter?.openViewReportVC(htmlReport:message ?? "")
                }
         
            case .addOperationLineSucess:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)

                    self.inStockDetailsVM?.resetTitleResult()
                    self.movementsStockTable.reloadData()

//                    self.inStockDetailsVM?.hitGetInOperations()

                }
            case .setTitle:
                DispatchQueue.main.async {
                    self.titleLbl.text = message
                    self.confirmStack.isHidden = self.inStockDetailsVM?.inStockStateTypes !=  InStockRootVM.InStockStateTypes.READY
                    self.addStoreItemBtn.isHidden = self.inStockDetailsVM?.inStockStateTypes != InStockRootVM.InStockStateTypes.READY
                    self.printtMovementBtn.isHidden = self.inStockDetailsVM?.inStockStateTypes != InStockRootVM.InStockStateTypes.DONE

                }
            }
            
        }
    }
   
    func loadMoreData(){
        if !isLoadMore {
            self.isLoadMore = true
            inStockDetailsVM?.hitGetInOperations()
        }
    }
}
extension InStockDetailsVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, UITableViewDataSourcePrefetching{
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
     
        if  inStockDetailsVM?.isEnded() ?? true{
            return
        }
        let upcomingRows = indexPaths.map { $0.row }
        
        if let maxIndex = upcomingRows.max() {
        let count = inStockDetailsVM?.getResultCount() ?? 0
        let currentPage = (count / 40)
        
        let nextPage: Int = Int(ceil(Double(maxIndex) / Double(40))) + 1

//        for index in indexPaths {
        if nextPage > currentPage  && !(inStockDetailsVM?.state == .loading )  {
            loadMoreData()
            
        }
   // }
        }
    }
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return inStockDetailsVM?.getResultCount() ?? 0
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockItemCell", for: indexPath) as! StockItemCell
        // Configure the cell...
        cell.operationLineItem = inStockDetailsVM?.getItem(at:indexPath.row)
        cell.appearnceAddMinsBtns(with:inStockDetailsVM?.inStockStateTypes != InStockRootVM.InStockStateTypes.READY)
        cell.setBtnsTag(with: indexPath)
        cell.btnMins.addTarget(self, action: #selector(decreaseQTY(_ :)), for: .touchUpInside)
        cell.btnPlus.addTarget(self, action: #selector(increaseQTY(_ :)), for: .touchUpInside)
         cell.removeBtn.addTarget(self, action: #selector(removeQTY(_ :)), for: .touchUpInside)

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
        //    cell.uomLbl.isUserInteractionEnabled = true
          //  let tapUOMGesture = UITapGestureRecognizer(target: self, action:  #selector(lblUOMTapped(_ :)))
         //   tapUOMGesture.numberOfTapsRequired = 1
           // cell.uomLbl.addGestureRecognizer(tapUOMGesture)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @objc func lblUOMTapped(_ sender : UITapGestureRecognizer){
        
        guard let row = sender.view?.tag  else {
            return
        }
//        let section = 0
//        let indexPath = IndexPath(row: row, section: section)
        let model = inStockDetailsVM?.getItem(at:row)
        let option1Title = model?.product_uom.last ?? ""
        let option2Title = model?.inv_uom_id.last ?? ""
        if option1Title == option2Title {
          //  return
        }
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        optionMenu.view.tintColor =  #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)
        let colorSelect = #colorLiteral(red: 0.9988561273, green: 0.4232195616, blue: 0.2168394923, alpha: 1)
        let option1 = UIAlertAction(title: option1Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.inStockDetailsVM?.changeUOM(at:row , with:model?.product_uom ?? [])
        })

        let option2 = UIAlertAction(title: option2Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.inStockDetailsVM?.changeUOM(at:row , with:model?.inv_uom_id ?? [])
        })
        if model?.inv_uom_id.last == model?.select_uom_id.last{
            option2.setValue( colorSelect , forKey: "titleTextColor")
        }
        if model?.product_uom.last == model?.select_uom_id.last{
            option1.setValue( colorSelect , forKey: "titleTextColor")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
           SharedManager.shared.printLog("Cancelled")
        })
        optionMenu.addAction(option1)
        optionMenu.addAction(option2)
        optionMenu.addAction(cancelAction)
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
        {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView =  sender.view
                currentPopoverpresentioncontroller.sourceRect =  sender.view?.bounds  ?? .zero
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up;
                self.present(optionMenu, animated: true, completion: nil)
            }
        }else{
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        
    }
    @objc func updateQTY(_ sender:UIStepper){
        inStockDetailsVM?.setQty(for: sender.tag,with: sender.value)
        self.movementsStockTable.reloadData()
    }
    @objc func decreaseQTY(_ sender:UIButton){
        if let currentQty = inStockDetailsVM?.getQty(for: sender.tag), currentQty > 0{
            inStockDetailsVM?.setQty(for: sender.tag,with: currentQty - 1)
            self.movementsStockTable.reloadData()
        }
    }
    @objc func increaseQTY(_ sender:UIButton){
        if let currentQty = inStockDetailsVM?.getQty(for: sender.tag){
            inStockDetailsVM?.setQty(for: sender.tag,with: currentQty + 1)
            self.movementsStockTable.reloadData()
        }
    }
    
    @objc func removeQTY(_ sender:UIButton){
            inStockDetailsVM?.setQty(for: sender.tag,with:0)
            self.movementsStockTable.reloadData()
        
    }
    @objc func lblQtyTapped(_ sender : UITapGestureRecognizer){
        guard let index = sender.view?.tag  else {
            return
        }
        if let cell =  self.movementsStockTable.cellForRow(at: IndexPath(row: index , section: 0)) as? StockItemCell {
            sender.view?.isHidden = true
            cell.qtyTF.isHidden = false
            if let operationLineItem = cell.operationLineItem{
                cell.qtyTF.text = operationLineItem.product_uom_qty?.toIntString()
            }else{
                cell.qtyTF.text = cell.qtyLbl.text
            }
            cell.qtyTF.becomeFirstResponder()
        }
            
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isHidden = true
        if let cell =  self.movementsStockTable.cellForRow(at: IndexPath(row: textField.tag , section: 0)) as? StockItemCell {
             cell.qtyLbl.isHidden = false
            if let newQty = Double(textField.text ?? "") {
                cell.operationLineItem?.product_uom_qty = newQty
                inStockDetailsVM?.setQty(for: textField.tag,with: newQty)


            }
         }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.isHidden = true
        if let cell =  self.movementsStockTable.cellForRow(at: IndexPath(row: textField.tag , section: 0)) as? StockItemCell {
             cell.qtyLbl.isHidden = false
            if let newQty = Double(textField.text ?? "") {
                cell.operationLineItem?.product_uom_qty = newQty
                inStockDetailsVM?.setQty(for: textField.tag,with: newQty)
            }
         }
        
       
        return true
    }

}
