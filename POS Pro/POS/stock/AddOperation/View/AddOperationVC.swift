//
//  AddOperationVC.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/30/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class AddOperationVC: UIViewController {
    @IBOutlet weak var selectItemView: UIView!
    @IBOutlet weak var moveLineTable: UITableView!
    @IBOutlet weak var selectPickerTable: UITableView!
    @IBOutlet weak var titlePickerView: UILabel!
    @IBOutlet weak var pickerSelectView: ShadowView!
    @IBOutlet weak var pickingTypeValueLbl: UILabel!
    @IBOutlet weak var fromValueLbl: UILabel!
    @IBOutlet weak var toValueLbl: UILabel!
    @IBOutlet weak var partnerValueLbl: UILabel!
    @IBOutlet weak var schaduleDateValueLbl: UILabel!
    @IBOutlet weak var nextView: ShadowView!
    @IBOutlet weak var titlePickerLbl: UILabel!
    var refreshControl = UIRefreshControl()
    weak var pickerView: UIPickerView?
    var addOperationVM:AddOperationVM?
    var addOperationRouter:AddOperationRouter?
    var isLoadMore = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Operation".arabic("انشاء تحويل جديد")
        setupTable()
        getLineList()
        initalState()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create".arabic("انشاء"), style: .plain, target: self, action: #selector(addTapped))

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true

    }
    @objc func addTapped(){
        self.addOperationVM?.createOperation()
    }
   
    //MARK:- inital State Lines List  screen
    func initalState(){
        self.addOperationVM?.updateLoadingStatusClosure = { (state, message, isSucess) in

            switch state {
            case .empty:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
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
                    loadingClass.hide(view:self.view)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            case .updateItems:
                DispatchQueue.main.async {
                    self.moveLineTable.reloadData()
                    loadingClass.hide(view:self.view)
                }
            case .pickerDataFetch:
                DispatchQueue.main.async {
                    self.isLoadMore = false
                    self.refreshControl.endRefreshing()
                    self.selectPickerTable.reloadData()
                    loadingClass.hide(view:self.view)
                }
            }
            
        }
    }
    func getLineList(){
        let lineListVC = LinesListRouter.createModule(delegate:self,viewType: .DETECT_QTY)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            if let view =  lineListVC.view{
                self.selectItemView.addSubview(view)
                view.center = self.selectItemView.center
                view.translatesAutoresizingMaskIntoConstraints = false
                view.topAnchor.constraint(equalTo: self.selectItemView.topAnchor, constant: 10).isActive = true
                view.bottomAnchor.constraint(equalTo: self.selectItemView.bottomAnchor, constant: 10).isActive = true
                view.leftAnchor.constraint(equalTo: self.selectItemView.leftAnchor, constant: 15).isActive = true
                view.rightAnchor.constraint(equalTo: self.selectItemView.rightAnchor, constant: -15).isActive = true
            }

        })
    }
    
    @IBAction func tapOnPickType(_ sender: UIButton) {
        if let typeSelect:AddOperationVM.SelectTypeEnum = AddOperationVM.SelectTypeEnum(rawValue: sender.tag){
        if typeSelect == .MOVE_LINE {
            self.showSelectItems()
        }else{
            if typeSelect == .SCHEDULED_DATE {
                hidSelectItemsAndPicker()
                showCalenderView()
            }else{
                showSelectPicker(typeSelect)
            }
        }
        }
        
    }
    func showSelectPicker(_ typeSelect:AddOperationVM.SelectTypeEnum){
        self.addOperationVM?.setSelectType(typeSelect)
        self.selectItemView.isHidden = true
        nextView.isHidden = true
        self.pickerSelectView.isHidden = false
        self.titlePickerLbl.text = typeSelect.getTitle()
    }
    func showSelectItems(){
        self.pickerSelectView.isHidden = true
        nextView.isHidden = true
        self.selectItemView.isHidden = false
        
    }
    func hidSelectItemsAndPicker(){
        self.pickerSelectView.isHidden = true
        self.selectItemView.isHidden = true
        nextView.isHidden = false
    }
    func showCalenderView(){
        let calendar = calendarVC()
        calendar.modalPresentationStyle = .formSheet
        calendar.didSelectDay = { [weak self] date in
            self?.addOperationVM?.sechadualDate = date.toString(dateFormat:"yyyy-MM-dd HH:mm:ss")
            self?.schaduleDateValueLbl.text = date.toString(dateFormat:"yyyy-MM-dd")
             calendar.dismiss(animated: true, completion: nil)
        }
      
      calendar.clearDay = {
                          calendar.dismiss(animated: true, completion: nil)
                      }
      
        self.present(calendar, animated: true, completion: nil)
    }
    func loadMoreData() {
        if !isLoadMore {
            self.isLoadMore = true
            addOperationVM?.hitGetSelectPickerAPI()
        }
    }
  
    
}
extension  AddOperationVC: LinesListDelegate{
    func updateItems(_ items:[StorableItemModel]){
        addOperationVM?.didUpdatedSelectedItems(items)
    }
   

}
extension AddOperationVC:UITableViewDelegate,UITableViewDataSource, UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if tableView.tag == 1 {
            if  addOperationVM?.isEnded() ?? true{
                return
            }
            let upcomingRows = indexPaths.map { $0.row }
            
            if let maxIndex = upcomingRows.max() {
            let count = addOperationVM?.getSelectPickerCount() ?? 0
            let currentPage = (count / 40)
            
            let nextPage: Int = Int(ceil(Double(maxIndex) / Double(40))) + 1

//        for index in indexPaths {
            if nextPage > currentPage  && !(addOperationVM?.state == .loading )  {
                loadMoreData()
                
            }
       // }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return addOperationVM?.getMoveLinesCount() ?? 0
        }else{
            return  addOperationVM?.getSelectPickerCount() ?? 0
        }
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
             return getStockItemCell(for: indexPath)
        }else{
            return getSelectPickerCell(for : indexPath)
        }
    }
    
    func setupTable(){
        moveLineTable.rowHeight = UITableView.automaticDimension
        moveLineTable.estimatedRowHeight = 300
        moveLineTable.register(UINib(nibName: "StockItemCell", bundle: nil), forCellReuseIdentifier: "StockItemCell")
        selectPickerTable.prefetchDataSource = self

        selectPickerTable.rowHeight = UITableView.automaticDimension
        selectPickerTable.estimatedRowHeight = 300
//        refreshControl.addTarget(self, action: #selector(refreshSelectPickerTable), for: .valueChanged)
//        selectPickerTable.addSubview(refreshControl)
        selectPickerTable.register(UINib(nibName: "SelectPickerCell", bundle: nil), forCellReuseIdentifier: "SelectPickerCell")
    }
    func getStockItemCell(for indexPath: IndexPath) -> StockItemCell {
        let cell = moveLineTable.dequeueReusableCell(withIdentifier: "StockItemCell", for: indexPath) as! StockItemCell
        let item = addOperationVM?.getMoveLineItem(for: indexPath.row)
        // Configure the cell...
        cell.btnMins.addTarget(self, action: #selector(decreaseQTY(_ :)), for: .touchUpInside)
        cell.btnPlus.addTarget(self, action: #selector(increaseQTY(_ :)), for: .touchUpInside)
        cell.storableItemModel = item
        cell.appearnceAddMinsBtns(with: true)
        return cell
    }
    func getSelectPickerCell(for indexPath: IndexPath) -> SelectPickerCell {
        let cell = selectPickerTable.dequeueReusableCell(withIdentifier: "SelectPickerCell", for: indexPath) as! SelectPickerCell
        cell.actionButton.tag = indexPath.row
        cell.actionButton.addTarget(self, action: #selector(didSelectItem(_:)), for: .touchUpInside)
        cell.item = addOperationVM?.getSelectPickerItem(for: indexPath.row)
        return cell
    }
    @objc func refreshSelectPickerTable(){
        self.addOperationVM?.resetPickerSelect()
    }
    @objc func didSelectItem(_ sender:UIButton){
        self.addOperationVM?.selectPickerItem(for:sender.tag)
        self.setSelectValueLbl(sender.tag)
    }
    func setSelectValueLbl(_ index:Int){
        let value =  self.addOperationVM?.getTitleSelectPickerItem(for:index)
        if let type = self.addOperationVM?.selectTypeEnum{
            if type == .FROM {
                self.fromValueLbl.text = value
            }
            if type == .TO {
                self.toValueLbl.text = value
            }
            if type == .PICKUP {
                self.pickingTypeValueLbl.text = value
            }
            if type == .PARTNER {
                self.partnerValueLbl.text = value
            }
        }
    }
    @objc func decreaseQTY(_ sender:UIButton){
        if let currentQty = addOperationVM?.getQty(for: sender.tag), currentQty > 0{
            addOperationVM?.setQty(for: sender.tag,with: currentQty - 1.0)
            self.moveLineTable.reloadData()
        }
    }
    @objc func increaseQTY(_ sender:UIButton){
        if let currentQty = addOperationVM?.getQty(for: sender.tag){
            addOperationVM?.setQty(for: sender.tag,with: currentQty + 1.0)
            self.moveLineTable.reloadData()
        }
    }
}

