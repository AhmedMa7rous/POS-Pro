//
//  LinesListVC.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/30/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit
enum LINES_STORED_VIEW_TYPES{
    case DETECT_QTY
    case SAVE
    case VIEW_SELECT
    case SELECT_CATEGORIES
}
protocol LinesListDelegate {
    func updateItems(_ items:[StorableItemModel])
    func saveAddItems()
    func updateCategories(_ items:[StorableCategoryModel])

}
extension LinesListDelegate {
    func saveAddItems(){}
    func updateCategories(_ items:[StorableCategoryModel]){}

}

class LinesListVC: UIViewController {
   
    @IBOutlet weak var StoredItemTable: UITableView!
    @IBOutlet weak var emptyView: UIView!

    @IBOutlet weak var saveBtn: KButton!
    
    @IBOutlet weak var saveView: UIView!
    var refreshControl = UIRefreshControl()
    var linesListVM:LinesListVM?
    var linesListRouter:LinesListRouter?
    var isLoadMore = true
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        initalState()
        self.linesListVM?.hitGetStoredLinesAPI()
        if linesListVM?.viewType == .SAVE{
            saveBtn.isHidden = false
            saveView.isHidden = false
        }
        // Do any additional setup after loading the view.
    }
    //MARK:- inital State Lines List  screen
    func initalState(){
        self.linesListVM?.updateLoadingStatusClosure = { (state, message, isSucess) in
           
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
                    self.StoredItemTable.reloadData()
                    loadingClass.hide(view:self.view)

                }
                return
            }
            
        }
    }

    @objc func refreshStoredItemTable(){
        self.linesListVM?.resetResult()
        self.StoredItemTable.reloadData()
        self.linesListVM?.hitGetStoredLinesAPI()
    }
    func loadMoreData() {
        if !isLoadMore {
            self.isLoadMore = true
            linesListVM?.hitGetStoredLinesAPI()
        }
    }

    @IBAction func tapOnSaveBtn(_ sender: KButton) {
        self.linesListVM?.saveAddOperationLine()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tapOnCancelBtn(_ sender: KButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension LinesListVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, UITableViewDataSourcePrefetching{
    func setupTable(){
        StoredItemTable.allowsSelection =  self.linesListVM?.viewType == .VIEW_SELECT
        StoredItemTable.prefetchDataSource = self

        StoredItemTable.rowHeight = UITableView.automaticDimension
        StoredItemTable.estimatedRowHeight = 300
//        refreshControl.addTarget(self, action: #selector(refreshStoredItemTable), for: .valueChanged)
//        StoredItemTable.addSubview(refreshControl)
        StoredItemTable.register(UINib(nibName: "StockItemCell", bundle: nil), forCellReuseIdentifier: "StockItemCell")
        //SectionHeaderCell
        StoredItemTable.register(UINib(nibName: "SectionHeaderCell", bundle: nil), forCellReuseIdentifier: "SectionHeaderCell")

        
    }
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        return
        /*
        if  linesListVM?.viewType == .VIEW_SELECT {
            return
        }
        if  linesListVM?.isEnded() ?? true{
            return
        }
        let upcomingRows = indexPaths.map { $0.row }
        
        if let maxIndex = upcomingRows.max() {
        let count = linesListVM?.getCategoryResultCount() ?? 0
        let currentPage = (count / 40)
        
        let nextPage: Int = Int(ceil(Double(maxIndex) / Double(40))) + 1

//        for index in indexPaths {
        if nextPage > currentPage  && !(linesListVM?.state == .loading )  {
            loadMoreData()
            
        }
   // }
        }
        */
        
    }
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
         return linesListVM?.getCategoryResultCount() ?? 0
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if linesListVM?.viewType == .SELECT_CATEGORIES{
             return 0
         }
         if self.linesListVM?.getCategoryItem(at: section)?.isExpended ?? false {
             return linesListVM?.getLinesResultCount(for:section) ?? 0
            } else {
                return 0
            }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentQty = linesListVM?.getQty(for: indexPath){
            linesListVM?.setQty(for:indexPath,with: currentQty + 1)
            self.StoredItemTable.reloadData()
        }
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockItemCell", for: indexPath) as! StockItemCell
        // Configure the cell...
        cell.storableItemModel = linesListVM?.getItem(at:indexPath)
         cell.appearnceAddMinsBtns(with: self.linesListVM?.viewType == .VIEW_SELECT)
         cell.hidQtyLbl(with: self.linesListVM?.viewType == .VIEW_SELECT)
         addAction(for:cell,at:indexPath)
         cell.stackController.isHidden = self.linesListVM?.viewType == .VIEW_SELECT
         
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func addAction(for cell:StockItemCell,at indexPath:IndexPath){
        cell.setBtnsTag(with: indexPath)
        if !cell.isBtnsHiden() {
            cell.btnMins.addTarget(self, action: #selector(decreaseQTY(_ :)), for: .touchUpInside)
            cell.btnPlus.addTarget(self, action: #selector(increaseQTY(_ :)), for: .touchUpInside)
            cell.removeBtn.addTarget(self, action: #selector(removeQTY(_ :)), for: .touchUpInside)
            cell.qtyTF.delegate = self
            cell.qtyTF.isHidden = true
            //MARK:- Edit Qantity
            cell.qtyLbl.isUserInteractionEnabled = true
            let tapQtyGesture = UITapGestureRecognizer(target: self, action:  #selector(lblQtyTapped(_ :)))
            tapQtyGesture.numberOfTapsRequired = 1
            cell.qtyLbl.addGestureRecognizer(tapQtyGesture)
            //MARK:- Edit UOM
            cell.uomLbl.isUserInteractionEnabled = true
            let tapUOMGesture = UITapGestureRecognizer(target: self, action:  #selector(lblUOMTapped(_ :)))
            tapUOMGesture.numberOfTapsRequired = 1
            cell.uomLbl.addGestureRecognizer(tapUOMGesture)
        }
    }
    @objc func lblUOMTapped(_ sender : UITapGestureRecognizer){
        
        guard let row = sender.view?.tag  else {
            return
        }
        guard let section = sender.view?.superview?.tag  else {
            return
        }
        let indexPath = IndexPath(row: row, section: section)
        let model = linesListVM?.getItem(at:indexPath)
        let option1Title = model?.uom_id.last ?? ""
        let option2Title = model?.inv_uom_id.last ?? ""
        let option3Title = model?.uom_po_id.last ?? ""

        if Set([option1Title, option2Title, option3Title]).count == 1 {
            return
        }
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        optionMenu.view.tintColor =  #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)
        let colorSelect = #colorLiteral(red: 0.9988561273, green: 0.4232195616, blue: 0.2168394923, alpha: 1)

        let option1 = UIAlertAction(title: option1Title , style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.linesListVM?.changeUOM(at:indexPath , with:model?.uom_id ?? [])

        })
        
        let option2 = UIAlertAction(title: option2Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.linesListVM?.changeUOM(at:indexPath , with:model?.inv_uom_id ?? [])
        })
        let option3 = UIAlertAction(title: option3Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.linesListVM?.changeUOM(at:indexPath , with:model?.uom_po_id ?? [])
        })
        if model?.inv_uom_id.last == model?.select_uom_id.last{
            option2.setValue( colorSelect , forKey: "titleTextColor")
        }
        if model?.uom_id.last == model?.select_uom_id.last{
            option1.setValue( colorSelect , forKey: "titleTextColor")
        }
        if model?.uom_po_id.last == model?.select_uom_id.last{
            option3.setValue( colorSelect , forKey: "titleTextColor")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(option1)
        if option2Title != option1Title {
            optionMenu.addAction(option2)
        }
        if option3Title != option1Title && option2Title != option3Title  {
            optionMenu.addAction(option3)
        }

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
   
    @objc func removeQTY(_ sender:UIButton){
        let indexPath = IndexPath(row: sender.tag, section: sender.superview?.tag ?? 0)
        if let currentQty = linesListVM?.getQty(for:indexPath), currentQty > 0{
            linesListVM?.setQty(for: indexPath,with: 0)
            self.StoredItemTable.reloadData()
        }
    }
    @objc func decreaseQTY(_ sender:UIButton){
        let indexPath = IndexPath(row: sender.tag, section: sender.superview?.tag ?? 0)

        if let currentQty = linesListVM?.getQty(for: indexPath), currentQty > 0{
            linesListVM?.setQty(for: indexPath,with: currentQty - 1)
            self.StoredItemTable.reloadData()
        }
    }
    @objc func increaseQTY(_ sender:UIButton){
        let indexPath = IndexPath(row: sender.tag, section: sender.superview?.tag ?? 0)
        if let currentQty = linesListVM?.getQty(for: indexPath){
            linesListVM?.setQty(for: indexPath,with: currentQty + 1)
            self.StoredItemTable.reloadData()
        }
    }
    @objc func lblQtyTapped(_ sender : UITapGestureRecognizer){
        guard let row = sender.view?.tag  else {
            return
        }
        guard let section = sender.view?.superview?.tag  else {
            return
        }
        if let cell =  self.StoredItemTable.cellForRow(at: IndexPath(row: row , section: section)) as? StockItemCell {
            sender.view?.isHidden = true
            cell.qtyTF.isHidden = false
            cell.qtyTF.text = cell.qtyLbl.text
            cell.qtyTF.becomeFirstResponder()
        }
            
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
         let row = textField.tag
        guard let section = textField.superview?.tag  else {
            return
        }
        let indexPath = IndexPath(row:row, section:section)

        textField.isHidden = true
        if let cell =  self.StoredItemTable.cellForRow(at: indexPath) as? StockItemCell {
             cell.qtyLbl.isHidden = false
            if let newQty = Double(textField.text ?? "") {
                cell.storableItemModel?.qty = newQty
                linesListVM?.setQty(for: indexPath,with: newQty)


            }
         }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         let row = textField.tag
        guard let section = textField.superview?.tag  else {
            return false
        }
        let indexPath = IndexPath(row:row, section:section)
        textField.resignFirstResponder()
        textField.isHidden = true
        if let cell =  self.StoredItemTable.cellForRow(at: indexPath) as? StockItemCell {
             cell.qtyLbl.isHidden = false
            if let newQty = Double(textField.text ?? "") {
                cell.storableItemModel?.qty = newQty
                linesListVM?.setQty(for: indexPath,with: newQty)
            }
         }
        
       
        return true
    }
    //MARK: - Section Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //SectionHeaderCell
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as! SectionHeaderCell
        headerCell.tapHeaterBtn.tag = section
        headerCell.tapHeaterBtn.addTarget(self, action: #selector(selectHeader(_ :)), for: .touchUpInside)
        headerCell.storableCategoryModel =  linesListVM?.getCategoryItem(at: section)
        if linesListVM?.viewType == .SELECT_CATEGORIES{
            headerCell.arrowImage.isHidden = true
            headerCell.contentBKView.backgroundColor = .clear
            
        }
        return headerCell

    }
    @objc func selectHeader(_ sender:UIButton){
        if linesListVM?.viewType == .SELECT_CATEGORIES{
            linesListVM?.selectCategory(sender.tag)
        }else{
            linesListVM?.togleExpanded(at:sender.tag)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

}

extension LinesListVC:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String){
        linesListVM?.search(by:searchText)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        linesListVM?.search(by:"")
        

    }
 

}
