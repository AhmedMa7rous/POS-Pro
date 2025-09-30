//
//  StockRequestVC.swift
//  pos
//
//  Created by M-Wageh on 18/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class CreateStockRequestVC: UIViewController {
    //MARK:-OUTLET
    @IBOutlet weak var schaduleDateValueLbl: UILabel!
    @IBOutlet weak var stockRequestTable: UITableView!
    @IBOutlet weak var selectItemView: ShadowView!
    @IBOutlet weak var emptyView: UIView!

    @IBOutlet weak var leftWidthConstraint: NSLayoutConstraint!
    //MARK:- variables
    var createStockRequestVM:CreateStockRequestVM?
    var completeHandler:(()->())?
    var productRequest:product_product_class?
    //MARK:- LIFE CYLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTable()
        initalState()
        getLineList()
        selectItemView.isHidden = false
        hideKeyboardWhenTappedAround()
        let curret_date = Date()
        self.createStockRequestVM?.sechadualDate = curret_date.toString(dateFormat:"yyyy-MM-dd HH:mm:ss")
        self.schaduleDateValueLbl.text = curret_date.toString(dateFormat:"yyyy-MM-dd")


    }
    //MARK:- inital State Lines List  screen
    func initalState(){
        self.createStockRequestVM?.updateLoadingStatusClosure = { (state) in
            switch state {
            case .empty:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.emptyView.isHidden = false
                    self.stockRequestTable.reloadData()
                }
                return
            case .loading:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
            case .error:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    messages.showAlert(self.createStockRequestVM?.errorMessage ?? "pleas, try again!")
                }
                return
            case .updated:
                DispatchQueue.main.async {
                    self.emptyView.isHidden = true
                    self.stockRequestTable.reloadData()
                    loadingClass.hide(view:self.view)
                }
                return
            case .populated:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.stockRequestTable.reloadData()
                    self.schaduleDateValueLbl.text = ""
                    self.emptyView.isHidden = false
                    self.dismiss(animated: true, completion: {
                        self.completeHandler?()
                    })

//                    messages.showAlert("Your request order stock done sucessfully".arabic("تم إنشاء طلب المخزون بنجاح"))

                }
                return
            }
            
        }
    }
    func showCalenderView(){
        let calendar = calendarVC()
        calendar.modalPresentationStyle = .formSheet
        calendar.didSelectDay = { [weak self] date in
            self?.createStockRequestVM?.sechadualDate = date.toString(dateFormat:"yyyy-MM-dd HH:mm:ss")
            self?.schaduleDateValueLbl.text = date.toString(dateFormat:"yyyy-MM-dd")
             calendar.dismiss(animated: true, completion: nil)
        }
      
      calendar.clearDay = {
                          calendar.dismiss(animated: true, completion: nil)
                      }
      
        self.present(calendar, animated: true, completion: nil)
    }
    
    @IBAction func tapOnScheduleDateBtn(_ sender: UIButton) {
        showCalenderView()
    }
    
    @IBAction func tapOnSelectItemsBtn(_ sender: UIButton) {
    }
    @IBAction func tapOnBackBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tapOnCreateBtn(_ sender: UIButton) {
        createStockRequestVM?.hitCreateStockRequest(updateProduct: self.productRequest)
    }
    func getLineList(){
       
        if let delegate = createStockRequestVM{
            let lineListVC = LinesListRouter.createModule(delegate:delegate,viewType: .VIEW_SELECT,productRequest: self.productRequest)
//            let productStorableListVC = ProductStorableListRouter.createModule(delegate:delegate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                if let view =  lineListVC.view{
                    self.selectItemView.addSubview(view)
                    view.center = self.selectItemView.center
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.topAnchor.constraint(equalTo: self.selectItemView.topAnchor, constant: 0).isActive = true
                    view.bottomAnchor.constraint(equalTo: self.selectItemView.bottomAnchor, constant: 0).isActive = true
                    view.leftAnchor.constraint(equalTo: self.selectItemView.leftAnchor, constant: 0).isActive = true
                    view.rightAnchor.constraint(equalTo: self.selectItemView.rightAnchor, constant: 0).isActive = true
                }

            })

        }
    }
    static func createModule(completeHandler:(()->())?,_ modalPresentationStyle:UIModalPresentationStyle = .fullScreen,productRequest:product_product_class? = nil) -> CreateStockRequestVC{
        let vc = CreateStockRequestVC()
        vc.modalPresentationStyle = modalPresentationStyle
        vc.createStockRequestVM = CreateStockRequestVM()
        vc.completeHandler = completeHandler
        vc.productRequest = productRequest
        return vc
    }
    
}

extension CreateStockRequestVC:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    func setupTable(){
        stockRequestTable.rowHeight = UITableView.automaticDimension
        stockRequestTable.estimatedRowHeight = 300
        stockRequestTable.register(UINib(nibName: "StockRequestCell", bundle: nil), forCellReuseIdentifier: "StockRequestCell")
    }
  
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return createStockRequestVM?.getResultCount() ?? 0
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StockRequestCell", for: indexPath) as! StockRequestCell
        // Configure the cell...
        cell.storableProductModel = createStockRequestVM?.getItem(at:indexPath)
         cell.setHideRemoveBtn(with: false)
         cell.setHideContolerBtns(with: false)
         addAction(for:cell,at:indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func addAction(for cell:StockRequestCell,at indexPath:IndexPath){
        cell.setBtnsTag(with: indexPath.row)
        cell.btnMins.addTarget(self, action: #selector(decreaseQTY(_ :)), for: .touchUpInside)
        cell.btnPlus.addTarget(self, action: #selector(increaseQTY(_ :)), for: .touchUpInside)
        cell.removeBtn.addTarget(self, action: #selector(removeQTY(_ :)), for: .touchUpInside)
        if !cell.isBtnsHiden() {
            cell.qtyTF.delegate = self
            cell.qtyTF.isHidden = true
            //MARK:- Edit Qantity
            cell.qtyLbl.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(lblQtyTapped(_ :)))
            tapGesture.numberOfTapsRequired = 1
            cell.qtyLbl.addGestureRecognizer(tapGesture)
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
        let section = 0
        let indexPath = IndexPath(row: row, section: section)
        let model = createStockRequestVM?.getItem(at:indexPath)
        let option1Title = model?.uom_id.last ?? ""
        let option2Title = model?.inv_uom_id.last ?? ""
        let option3Title = model?.uom_po_id.last ?? ""
        if Set([option1Title, option2Title, option3Title]).count == 1 {
            return
        }
       
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        optionMenu.view.tintColor =  #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)
        let colorSelect = #colorLiteral(red: 0.9988561273, green: 0.4232195616, blue: 0.2168394923, alpha: 1)
        let option1 = UIAlertAction(title: option1Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.createStockRequestVM?.changeUOM(at:indexPath , with:model?.uom_id ?? [])
        })

        let option2 = UIAlertAction(title: option2Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.createStockRequestVM?.changeUOM(at:indexPath , with:model?.inv_uom_id ?? [])
        })
        let option3 = UIAlertAction(title: option3Title, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.createStockRequestVM?.changeUOM(at:indexPath , with:model?.uom_po_id ?? [])
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
           SharedManager.shared.printLog("Cancelled")
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
    @objc func updateQTY(_ sender:UIStepper){
        createStockRequestVM?.setQty(for: sender.tag,with: sender.value)
        self.stockRequestTable.reloadData()
    }
    @objc func removeQTY(_ sender:UIButton){
        DispatchQueue.main.async {
            if let currentQty = self.createStockRequestVM?.getQty(for: sender.tag), currentQty > 0{
            self.createStockRequestVM?.setQty(for: sender.tag,with: 0)
            self.stockRequestTable.reloadData()
        }
        }
    }
    @objc func decreaseQTY(_ sender:UIButton){
        if let currentQty = createStockRequestVM?.getQty(for: sender.tag),  currentQty > 0{
            createStockRequestVM?.setQty(for: sender.tag,with: currentQty - 1)
            self.stockRequestTable.reloadData()
        }
    }
    @objc func increaseQTY(_ sender:UIButton){
        if let currentQty = createStockRequestVM?.getQty(for: sender.tag){
            createStockRequestVM?.setQty(for: sender.tag,with: currentQty + 1)
            self.stockRequestTable.reloadData()
        }
    }
    @objc func lblQtyTapped(_ sender : UITapGestureRecognizer){
        guard let index = sender.view?.tag  else {
            return
        }
        if let cell =  self.stockRequestTable.cellForRow(at: IndexPath(row: index , section: 0)) as? StockRequestCell {
            sender.view?.isHidden = true
            cell.qtyTF.isHidden = false
            cell.qtyTF.text = cell.qtyLbl.text
            cell.qtyTF.becomeFirstResponder()
        }
            
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isHidden = true
        if let cell =  self.stockRequestTable.cellForRow(at: IndexPath(row: textField.tag , section: 0)) as? StockRequestCell {
             cell.qtyLbl.isHidden = false
            if let newQty = Double(textField.text ?? "") {
                cell.storableProductModel?.qty = newQty
                createStockRequestVM?.setQty(for: textField.tag,with: newQty)


            }
         }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.isHidden = true
        if let cell =  self.stockRequestTable.cellForRow(at: IndexPath(row: textField.tag , section: 0)) as? StockRequestCell {
             cell.qtyLbl.isHidden = false
            if let newQty = Double(textField.text ?? "") {
                cell.storableProductModel?.qty = newQty
                createStockRequestVM?.setQty(for: textField.tag,with: newQty)

            }
         }
        
       
        return true
    }
}
