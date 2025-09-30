//
//  CreateAdjustmentVC.swift
//  pos
//
//  Created by M-Wageh on 26/07/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class CreateAdjustmentVC: UIViewController {
    //MARK: - OutLet
    @IBOutlet weak var inventoryRefTF: UITextField!
    @IBOutlet weak var selectBySegment: UISegmentedControl!
    @IBOutlet weak var productBtn: KButton!
    @IBOutlet weak var categoryBtn: KButton!
    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var productsStackView: UIStackView!
    @IBOutlet weak var selectedItemsTable: UITableView!
    @IBOutlet weak var leftView: ShadowView!
    
    //MARK: - Variables
    var createAdjustmentVM:CreateAdjustmentVM?
    var createAdjustmentRouter:CreateAdjustmentRouter?
    
    //MARK: - LifeCyle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        initalState()
        getLineList(with :LINES_STORED_VIEW_TYPES.VIEW_SELECT)
        self.productBtn.titleLabel?.numberOfLines = 2
        
        self.categoryBtn.titleLabel?.numberOfLines = 2
        self.setTitleSelectBtn()
        
    }
    func restLeftView(){
        self.leftView.isHidden = true
        for subView in self.leftView.subviews {
            subView.removeFromSuperview()
        }
        self.leftView.isHidden = false
    }
    func getLineList(with viewType:LINES_STORED_VIEW_TYPES){
        if let delegate = createAdjustmentVM{
            let lineListVC = LinesListRouter.createModule(delegate:delegate,viewType: viewType)
            //            let productStorableListVC = ProductStorableListRouter.createModule(delegate:delegate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                if let view =  lineListVC.view{
                    self.leftView.addSubview(view)
                    view.center = self.leftView.center
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.topAnchor.constraint(equalTo: self.leftView.topAnchor, constant: 0).isActive = true
                    view.bottomAnchor.constraint(equalTo: self.leftView.bottomAnchor, constant: 0).isActive = true
                    view.leftAnchor.constraint(equalTo: self.leftView.leftAnchor, constant: 0).isActive = true
                    view.rightAnchor.constraint(equalTo: self.leftView.rightAnchor, constant: 0).isActive = true
                }
                
            })
            
        }
    }
    
    //MARK: - inital State Lines List  screen
    func initalState(){
        self.createAdjustmentVM?.updateLoadingStatusClosure = { (state) in
            switch state {
            case .empty:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                }
                return
            case .error(let message):
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
                    loadingClass.hide(view:self.view)
                    //self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: {
                        self.createAdjustmentVM?.delegate?.updateOralidateItems()
                    })
                }
                return
            case .updateItems:
                DispatchQueue.main.async {
                    self.selectedItemsTable.reloadData()
                    self.setTitleSelectBtn()
                    
                    loadingClass.hide(view:self.view)
                }
            }
            
        }
    }
    func setTitleSelectBtn(){
        let titleSelected = self.createAdjustmentVM?.createAdjustmentModel?.getNameSelectedItems()
        self.categoryBtn.setTitle(titleSelected, for: .normal)
        self.productBtn.setTitle(titleSelected, for: .normal)

    }
    
    func handleShowProductCategoryStack(){
        self.productsStackView.isHidden = self.selectBySegment.selectedSegmentIndex != 0
        self.categoryStackView.isHidden = self.selectBySegment.selectedSegmentIndex != 1
    }
    
    //MARK: - @IBAction
    @IBAction func tapOnCancelBtn(_ sender: KButton) {
        self.dismiss(animated: true)
    }
    @IBAction func tapOnCreatelBtn(_ sender: KButton) {
       // self.dismiss(animated: true)
        self.createAdjustmentVM?.createAdjustmentModel?.name = self.inventoryRefTF.text
        self.createAdjustmentVM?.hitCrateAdjustmentAPI()
    }
    @IBAction func tapOnProductsBtn(_ sender: KButton) {
        restLeftView()
        getLineList(with:.VIEW_SELECT)
    }
    @IBAction func tapOnCategoryBtn(_ sender: KButton) {
        restLeftView()
        getLineList(with:.SELECT_CATEGORIES)
    }
   
    
    @IBAction func tapOnSelectBySegment(_ sender: UISegmentedControl) {
        restLeftView()
        handleShowProductCategoryStack()
        self.createAdjustmentVM?.resetCategories()
        self.createAdjustmentVM?.restProducts()
        if self.selectBySegment.selectedSegmentIndex == 0 {
            self.createAdjustmentVM?.setAdjustmentType(with: .PRODUCT)
            self.createAdjustmentVM?.updateItems([])
            self.getLineList(with: .VIEW_SELECT)
        }else{
            self.createAdjustmentVM?.setAdjustmentType(with: .CATEGORY)
            self.createAdjustmentVM?.updateCategories([])
            self.getLineList(with: .SELECT_CATEGORIES)

        }
    }
    
    @IBAction func togleIncludeExhaustedProductes(_ sender: UISwitch) {
        self.createAdjustmentVM?.createAdjustmentModel?.exhausted = sender.isOn
    }
    
    
}
extension CreateAdjustmentVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    func setupTable(){
        selectedItemsTable.rowHeight = UITableView.automaticDimension
        selectedItemsTable.estimatedRowHeight = 300
        selectedItemsTable.register(UINib(nibName: "StockRequestCell", bundle: nil), forCellReuseIdentifier: "StockRequestCell")
    }
  
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return createAdjustmentVM?.getCountItems() ?? 0
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockRequestCell", for: indexPath) as! StockRequestCell
        // Configure the cell...
         let item = createAdjustmentVM?.getItem(at: indexPath)
         cell.storableProductModel = item?.0
         cell.storableCategoryModel = item?.1

         cell.setHideRemoveBtn(with: false)
         cell.setHideContolerBtns(with: true)
         addAction(for:cell,at:indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func addAction(for cell:StockRequestCell,at indexPath:IndexPath){
        cell.setBtnsTag(with: indexPath.row)
        cell.removeBtn.addTarget(self, action: #selector(removeItem(_ :)), for: .touchUpInside)
       
    }
  
    @objc func removeItem(_ sender:UIButton){
        self.createAdjustmentVM?.removeItem(at: IndexPath(row: sender.tag, section: 0))
    }
   
}
