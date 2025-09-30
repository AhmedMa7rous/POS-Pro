//
//  MWComboVC.swift
//  pos
//
//  Created by M-Wageh on 09/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class MWComboVC: UIViewController {
    
    @IBOutlet weak var nameMultiProductLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var qtyBtn: UIButton!
    
    @IBOutlet weak var collection: UICollectionView!
    
    var mwComboVM:MWComboVM?
    var router:MWComboRouter?
    var widthCell:CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollection()
        self.intializeState()
        self.nameMultiProductLbl.text = (self.mwComboVM?.getNameProduct() ?? "").removeParam()
        self.qtyBtn.setTitle("\(self.mwComboVM?.getSelectedQty() ?? 1.0)", for: .normal)
        self.mwComboVM?.fetchSubProduct()
        NotificationCenter.default.addObserver(self, selector: #selector( change_order_type(notification:)), name: Notification.Name("change_order_type"), object: nil)


    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("change_order_type"), object: nil)
    }
    func intializeState(){
        self.mwComboVM?.updateLoadingStatusClosure = { state in
            switch state {
            case .EMPTY:
                SharedManager.shared.printLog("empty")
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                }
            case .CLOSE:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.mwComboVM?.orderVc?.refreshTableView()
                    self.router?.closeVC()
                }
            case .SHOW_MESSAGE(let msg):
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.showMessage(msg)

                    
                }
            case .UPDATE_PRICE(let price):
                DispatchQueue.main.async {
                    let currency = SharedManager.shared.getCurrencyName()
                    if currency.lowercased().contains("sar"){
                        self.titleLbl.attributedText = SharedManager.shared.getRiayalSymbol(total:price)
                    }else{
                        self.titleLbl.text = price  + " \(SharedManager.shared.getCurrencyName())"
                    }
                    
                }
            case .LOADING:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
            case .VOID_DONE:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.router?.closeVC()
                }
                return
            case .POPULATED:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.widthCell =  self.view.frame.width - 80

                    UIView.performWithoutAnimation {
                        var indexPaths:[IndexPath] = []
                        for i in 0...(self.mwComboVM?.getSubProductsCount() ?? 0){
                            indexPaths.append(IndexPath(row: i, section: 0))
                        }
                        self.collection.reloadData()
//                        self.collection.reloadItems(at: indexPaths)
//                        self.collection.reloadData()
                    }
                }
                return
            case .CHANGE_QTY(let qty):
                DispatchQueue.main.async {
                    
                    UIView.performWithoutAnimation {
                        self.qtyBtn.setTitle(qty, for: .normal)
                        self.qtyBtn.layoutIfNeeded()
                        self.collection.reloadData()
                        
                    }
                }
            }
            
        }
    }
    @objc func change_order_type(notification: Notification){
        self.mwComboVM?.changeOrderType()
//        if let data = notification.object as? [String:Any]{
//            let cls = delivery_type_category_class(fromDictionary: data)
//        }

    }
    func showMessage(_ message:String){
        SharedManager.shared.initalBannerNotification(title: "", message: message, success: false, icon_name: "icon_error")
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
    }


    @IBAction func tapOnCloseBtn(_ sender: UIButton) {
        if let vc = parent as? create_order {
            vc.btnPayment.isEnabled = true
        }
        self.router?.closeVC()
    }
    
    @IBAction func tapOnVoidBtn(_ sender: UIButton) {
        self.mwComboVM?.void(vc:self)
    }
    @IBAction func tapOnNewBtn(_ sender: UIButton) {
        self.mwComboVM?.makeNewMultiProduct()
    }
    @IBAction func tapOnIncreaseBtn(_ sender: UIButton) {
        self.mwComboVM?.changeQty(operation: "+")

    }
    @IBAction func tapOnQtyBtn(_ sender: UIButton) {
//        let editQtyVC = EditQtyRouter.createModule(sender, initQty:self.qtyBtn.titleLabel?.text )
//        editQtyVC.completionBlock = { (qty) in
//            if let qtyDouble =  qty?.toDouble() {
//                self.mwComboVM?.updateQty(with:qtyDouble )
//            }
//
//        }
//        present(editQtyVC, animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        guard let enterBalanceVC = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew else{return}
        enterBalanceVC.modalPresentationStyle = .popover
        
        enterBalanceVC.delegate = self
        enterBalanceVC.key = "edit_qty"
        enterBalanceVC.title_vc =  LanguageManager.text("Enter new quantity", ar: "أدخل كمية جديدة")
            enterBalanceVC.initValue  = self.qtyBtn.titleLabel?.text ?? "1.0"
            
        enterBalanceVC.disable = false
        
        let popover = enterBalanceVC.popoverPresentationController!
        popover.permittedArrowDirections = .up
        popover.sourceView = sender
        popover.sourceRect =  sender.bounds
        
        self.present(enterBalanceVC, animated: true, completion: nil)
        
    }
    @IBAction func tapOnDecreaseBtn(_ sender: UIButton) {
        self.checkDecreaseRule {
            self.mwComboVM?.changeQty(operation: "-")
        }
    }
    @IBAction func tapOnDoneBtn(_ sender: UIButton) {
        self.mwComboVM?.done()
    }
   
    
    
}
extension MWComboVC: enterBalance_delegate{
    func newBalance(key:String,value:String){
        if let qtyDouble =  Double(value) {
            let qty = Double((self.qtyBtn.titleLabel?.text ?? "1.0")) ?? 1.0
            if qtyDouble < qty  {
                checkDecreaseRule {
                    self.mwComboVM?.updateQtyManule(with: qtyDouble )
                }
            }else{
                self.mwComboVM?.updateQtyManule(with: qtyDouble )
            }
        }
    }
    
    func checkDecreaseRule(completion:@escaping()->()){
        if let line =  self.mwComboVM?.getSelectedLine(), line.id > 0 {
        SharedManager.shared.premission_for_decrease_qty(line:line, vc: self) {
            DispatchQueue.main.async {
                completion()
            }
        }
        }else{
            completion()
        }

    }
}

extension MWComboVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func setupCollection(){
        collection.register(UINib(nibName: "VareaintCollectionCell", bundle: nil), forCellWithReuseIdentifier: "VareaintCollectionCell")
        collection.register(UINib(nibName: "AddOnCell", bundle: nil), forCellWithReuseIdentifier: "AddOnCell")
        collection.register(UINib(nibName: "NoteCell", bundle: nil), forCellWithReuseIdentifier: "NoteCell")

//        self.collectionView.register(DriverOrderCollectionCell.self, forCellWithReuseIdentifier:cellIdentifier)

        collection.delegate = self
        collection.dataSource = self
//        self.collection.reloadData()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mwComboVM?.getSubProductsCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let typeCell = mwComboVM?.getSubProduct(at: indexPath.row)?.type ?? .variant
        if typeCell == .variant{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VareaintCollectionCell", for: indexPath) as! VareaintCollectionCell
            cell.initalize(mwComboVM: self.mwComboVM, section:indexPath.row )
            return cell
        }
        if typeCell == .combo{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddOnCell", for: indexPath) as! AddOnCell
            cell.initalize(mwComboVM: self.mwComboVM, section:indexPath.row,widthParent: widthCell )
            return cell
        }
        if typeCell == .note{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath) as! NoteCell
            cell.initalize(mwComboVM: self.mwComboVM, section:indexPath.row ,widthParent: widthCell)
            return cell
        }
        return UICollectionViewCell()
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let subProduct = self.mwComboVM?.getSubProduct(at: indexPath.row)
        if subProduct?.type == .variant {
            let width = collectionView.bounds.width
            guard let items = mwComboVM?.getSubProduct(at: indexPath.item)?.productItems else { return CGSize(width: 0, height: 0) }
            let totalHeight = calculateTotalHeight(for: items, in: collectionView) + 40
            return CGSize(width: width, height: totalHeight)
        } else {
            return CGSize(width: widthCell ?? 850 , height: getHeight(for :indexPath.row))
        }
    }
    func getHeight(for section:Int)-> CGFloat{
        let subProduct = self.mwComboVM?.getSubProduct(at: section)
        if  subProduct?.type == .note{
            let itemCount = self.mwComboVM?.getItemsProductCount(for: section) ?? 1
            var countRow = Int(itemCount/5)
            if countRow <= 0 && itemCount < 5 {
                return CGFloat(250)
            }else{
                if ( (Double(itemCount)/5.0) - Double(countRow) ) > 0 {
                    countRow += 1
                }
               return CGFloat(countRow * 82) + 140
//                return CGFloat(2 * 70) + 70

            }
        }
        if subProduct?.type == .combo {
            let itemCount = self.mwComboVM?.getItemsProductCount(for: section) ?? 1
            var countRow = Int(itemCount/3)
            if countRow <= 0 && itemCount < 3 {
                return CGFloat(150)
            }else{
                if ( (Double(itemCount)/3.0) - Double(countRow) ) > 0 {
                    countRow += 1
                }
               return CGFloat(countRow * 82) + 70
//                return CGFloat(2 * 70) + 70

            }
        }
//        if subProduct?.type == .variant {
//            let itemCount = self.mwComboVM?.getItemsProductCount(for: section) ?? 0
//            let itemsPerRow: CGFloat = 3
//            let rows = ceil(CGFloat(itemCount) / itemsPerRow)
//            let heightPerRow: CGFloat = 60
//            let spacing: CGFloat = 10
//            let totalHeight = rows * heightPerRow + (rows - 1) * spacing
//            return totalHeight + 10
//        }
        return CGFloat(130)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func calculateTotalHeight(for items: [ItemProductObject], in collectionView: UICollectionView) -> CGFloat {
        guard let collectionView = collection else { return 0 }
        
        let layout = DynamicCollectionViewLayout()
        let contentWidth = collectionView.bounds.width - CGFloat(100)
        let spacing: CGFloat = 40
        var currentRowWidth: CGFloat = 0
        var numberOfRows: Int = 1
        
        for item in items {
            let itemWidth = calculateWidth(for: item.getTitleVariant())
            if currentRowWidth + itemWidth > contentWidth {
                numberOfRows += 1
                currentRowWidth = itemWidth
            } else {
                currentRowWidth += itemWidth + spacing
            }
        }
        
        switch numberOfRows {
        case 1:
            return 50
        default:
            return CGFloat(numberOfRows) * 70 + CGFloat(numberOfRows - 1) * spacing
        }
    }
        
    func calculateWidth(for item: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 17)
        let width = item.size(withAttributes: [NSAttributedString.Key.font: font]).width
        return width + CGFloat(30)
    }
}
