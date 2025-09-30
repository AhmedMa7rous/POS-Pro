//
//  ProductAvaliablityVC.swift
//  pos
//
//  Created by M-Wageh on 20/03/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class ProductAvaliablityVC: UIViewController {
    var productAvaliablityVM:ProductAvaliablityVM?
    var router:ProductAvaliablityRouter?
    
    @IBOutlet weak var titleLbl: KLabel!
    @IBOutlet weak var selectProductsView: UIView!
    @IBOutlet weak var addAvaliablityView: ShadowView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var selectProductLbl: UILabel!
    @IBOutlet weak var productsTable: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var avaliableSwitch: UISwitch!
    @IBOutlet weak var nameStockLbl: UILabel!
    @IBOutlet weak var qtyLbl: KLabel!
    @IBOutlet weak var qtyTF: UITextField!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnMins: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    @IBOutlet weak var addAvaliablityStackView: UIStackView!
    var complete:(()->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture()
        self.productAvaliablityVM?.selectProduct = nil
        doStyle()
        self.setupTable()
        self.updateAddAvaliablityView()
        self.productAvaliablityVM?.updateListHandler = {
            DispatchQueue.main.async {
                self.productsTable.reloadData()
            }
        }
        
    }
    func addGesture(){
        let tapGesture = UITapGestureRecognizer(target: self,
                                                         action: #selector(handleTapQtyTF(recognizer:)))
        qtyLbl.isUserInteractionEnabled = true
        qtyLbl.addGestureRecognizer(tapGesture)
    }
    
    func doStyle(){
        self.updateBtn.setTitle("Update".arabic("تحديث"), for: .normal)
        self.selectProductLbl.text = "Select product".arabic("اختر المنتج")
        self.categoryLbl.text = self.productAvaliablityVM?.selectCategoryName ?? ""
        let whiteColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.backBtn.setTitleColor(whiteColor, for: .normal)
        self.backBtn.layer.cornerRadius = 8
        
        self.mainView.layer.cornerRadius = 8
        self.mainView.layer.borderWidth = 1
        self.mainView.layer.borderColor =  #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1)
        selectProductsView.layer.shadowColor = UIColor.gray.cgColor
        selectProductsView.layer.shadowOffset = CGSize(width: 1, height: 1)
        selectProductsView.layer.shadowOpacity = 1
        
        
    }
    @IBAction func tapOnClose(_ sender: UIButton) {
        self.router?.close(vc: self)
    }
    
    
    @IBAction func tapOnAvaliableSW(_ sender: UISwitch) {
        self.productAvaliablityVM?.updateStatus(by:sender.isOn)
    }
    @IBAction func tapOnMinsBtn(_ sender: UIButton) {
        if self.avaliableSwitch.isOn{
            
            self.productAvaliablityVM?.decreaseQty()
            self.updateAddAvaliablityView()
        }
    }
    
    
    @IBAction func tapOnPlusBtn(_ sender: UIButton) {
        if self.avaliableSwitch.isOn{
            
            self.productAvaliablityVM?.increaseQty()
            self.updateAddAvaliablityView()
        }
    }
    
    @IBAction func qtyTFDidEnd(_ sender: UITextField) {
        if self.avaliableSwitch.isOn{
            self.setQty(qty: sender.text ?? "0")
            self.qtyTF.isHidden = true
            self.qtyLbl.isHidden = false
        }
    }
    func setQty(qty:String){
        if self.productAvaliablityVM?.updateQty(by: qty) ?? false{
            self.qtyTF.text = qty
            self.qtyLbl.text = qty
        }
    }
    
    
    
    func updateAddAvaliablityView(){
        if let productSelect = self.productAvaliablityVM?.selectProduct{
            let englishName = productSelect.product_class?.name ?? ""
            let arabicName = productSelect.product_class?.name_ar ?? ""
            var fullName = productSelect.product_class?.display_name ?? ""

            if englishName != arabicName{
                 fullName = englishName + "/" + arabicName
            }
            self.titleLbl.text = ("Update " + fullName + " avaliablity").arabic("تعديل الكميه المتوفره ل \(fullName)")
            self.qtyTF.text = "\(productSelect.avaliable_class?.avaliable_qty ?? 0)"
            self.qtyLbl.text = "\(productSelect.avaliable_class?.avaliable_qty ?? 0)"
            self.avaliableSwitch.isOn = (productSelect.avaliable_class?.avaliable_status ?? .NONE) == .ACTIVE
            self.addAvaliablityStackView.isHidden = false
            self.updateBtn.isHidden = false

        }else{
            self.addAvaliablityStackView.isHidden = true
            self.updateBtn.isHidden = true
        }
    }
    
    @IBAction func tapOnUpdateBtn(_ sender: UIButton) {
        self.productAvaliablityVM?.saveUpdateQty()
        self.updateAddAvaliablityView()
        if let complete = self.complete{
            self.router?.close(vc: self,completion:complete)
        }
    }
    
}
extension ProductAvaliablityVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
        productsTable.delegate = self
        productsTable.dataSource = self
        productsTable.rowHeight = UITableView.automaticDimension
        productsTable.estimatedRowHeight = 80
        productsTable.register(UINib(nibName: "ProductListCell", bundle: nil), forCellReuseIdentifier: "ProductListCell")
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productAvaliablityVM?.getProductsCount() ?? 0
    }
    
   
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! invoicesListTableViewCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell", for: indexPath) as! ProductListCell
//         let tapGesture = UITapGestureRecognizer(target: self,
//                                                 action: #selector(handleTapTableCell(recognizer:)))
//         cell.contentView.tag = indexPath.row
//         cell.contentView.isUserInteractionEnabled = true
//         cell.contentView.addGestureRecognizer(tapGesture)

         cell.productItem = self.productAvaliablityVM?.getProduct(at: indexPath.row)
         
         return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.productAvaliablityVM?.setSelectProduct(at: indexPath.row)
        self.updateAddAvaliablityView()

    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60//UITableView.automaticDimension
    }
 
    
  
    @objc func handleTapQtyTF(recognizer:UITapGestureRecognizer){
        if self.avaliableSwitch.isOn{
            let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
            guard let enterBalanceVC = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew else{return}
            //storyboard.instantiateViewController(withIdentifier: "enterBalance") as? enterBalance else{return}
            enterBalanceVC.modalPresentationStyle = .popover
            
            enterBalanceVC.key = "edit_qty"
            enterBalanceVC.title_vc =  LanguageManager.text("Enter new quantity", ar: "أدخل كمية جديدة")
                enterBalanceVC.initValue  = self.qtyLbl.text ?? "1.0"
                
            enterBalanceVC.disable = false
            
            let popover = enterBalanceVC.popoverPresentationController!
            popover.permittedArrowDirections = .up
            popover.sourceView = recognizer.view
            popover.sourceRect =  recognizer.view?.bounds ?? CGRect()
            
            self.present(enterBalanceVC, animated: true, completion: nil)
            enterBalanceVC.didSelect = {    key,value in
                self.setQty(qty: value)
            }
            /*
            self.qtyTF.becomeFirstResponder()
            self.qtyTF.isHidden = false
            self.qtyLbl.isHidden = true
             */
        }
    }
}
