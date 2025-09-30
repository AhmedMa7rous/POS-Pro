//
//  AddOnCell.swift
//  pos
//
//  Created by M-Wageh on 17/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class AddOnCell:UICollectionViewCell {
    
    @IBOutlet weak var titleCellLbl: UILabel!
    
    @IBOutlet weak var collection: UICollectionView!
    
    @IBOutlet weak var requireLbl: UILabel!
    //    @IBOutlet weak var heightCollection: NSLayoutConstraint!
    var isSelectedUI:Bool = false
    var mwComboVM:MWComboVM?
    var section:Int?
    var widthParent:CGFloat?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let borderColorUnSeleted = isSelectedUI ? #colorLiteral(red: 1, green: 0.358289957, blue: 0, alpha: 1) : #colorLiteral(red: 0.8235294118, green: 0.7921568627, blue: 0.7921568627, alpha: 1)
        let lblColorUnSeleted = isSelectedUI ? #colorLiteral(red: 1, green: 0.358289957, blue: 0, alpha: 1) : #colorLiteral(red: 0.4509803922, green: 0.4901960784, blue: 0.6078431373, alpha: 1)
        setupCollection()

    }
    func initalize(mwComboVM:MWComboVM?,section:Int?,widthParent:CGFloat?){
        self.widthParent = widthParent
        self.mwComboVM = mwComboVM
        self.section = section
        self.titleCellLbl.text =  ""
        self.requireLbl.isHidden = true

        if let section = section, let subProduct = self.mwComboVM?.getSubProduct(at: section){
            var nameString = subProduct.nameSubProduct
            self.titleCellLbl.text = nameString
            
            self.requireLbl.isHidden = !(subProduct.isRequire  ?? false)
            UIView.performWithoutAnimation {
                self.collection.reloadData()
//                self.collection.collectionViewLayout.invalidateLayout()
//                self.collection.layoutIfNeeded()
            }
        }
       
        
    }
    
}
extension AddOnCell:UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func setupCollection(){
        let nib = UINib(nibName: "SelectAddOnCell", bundle: nil)
        collection.register(nib, forCellWithReuseIdentifier: "SelectAddOnCell")
//        self.collectionView.register(DriverOrderCollectionCell.self, forCellWithReuseIdentifier:cellIdentifier)

        
        collection.delegate = self
        collection.dataSource = self
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let section = self.section{
            return self.mwComboVM?.getItemsProductCount(for: section ) ?? 0

        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectAddOnCell", for: indexPath) as! SelectAddOnCell
        if let section = self.section{
            cell.initalize(from: self.mwComboVM?.getItemProduct(for: section, at:indexPath.row),attributeValues: self.mwComboVM?.getSelectedVariantIds() ?? [])
            cell.minsQtyBtn.tag = indexPath.row
            cell.qtyAndPlusBtn.tag = indexPath.row
            cell.qtyAndPlusBtn.addTarget(self, action: #selector(tapOnqtyAndPlusBtn(_:)), for: .touchUpInside)
            cell.minsQtyBtn.addTarget(self, action: #selector(tapOnminsQtyBtn(_:)), for: .touchUpInside)

        }
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTapCell(recognizer:)))
        cell.contentView.tag = indexPath.row
        cell.contentView.isUserInteractionEnabled = true
        cell.contentView.addGestureRecognizer(tapGesture)
        
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var   cls = ""
        if let section = self.section{
            cls = self.mwComboVM?.getItemProduct(for: section, at:indexPath.row)?.nameItemProduct ?? "test name button"
        }
        let width = ((widthParent ?? 823) - 20)/3
        
        return CGSize(width: width, height: 72)
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        
    }
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    */
    func getWidthLblFor(_ name:String) -> CGFloat{
        let label = KLabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = name
        label.sizeToFit()
        let widthLbl = label.frame.width + 130
        return widthLbl
    }
    @objc func tapOnminsQtyBtn(_ sender:UIButton){
        if let section = self.section, let item = self.mwComboVM?.getItemProduct(for: section, at:sender.tag){
            if item.mwAddOnList?[0].require == true {
                if item.selectQty > Double(item.mwAddOnList?[0].auto_select_num ?? Int.min) {
                    item.decreaseQty()
                    if item.selectQty <= 0{
                        self.mwComboVM?.removeAddOnSelect(item)
                    }
                    UIView.performWithoutAnimation {
                        self.collection.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                    }
                } else {
                    SharedManager.shared.initalBannerNotification(title: "", message: "You can not change a required quantity items".arabic("لايمكنك تغيير الكميه المحدده للعناصر المطلوبة"), success: false, icon_name: "")
                    SharedManager.shared.banner?.dismissesOnTap = true
                    SharedManager.shared.banner?.show(duration: 3.0)
                }
            } else {
                item.decreaseQty()
                if item.selectQty <= 0{
                    self.mwComboVM?.removeAddOnSelect(item)
                }
                UIView.performWithoutAnimation {
                    self.collection.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                }
            }
            
//            self.collection.reloadData()
        }
    }
    @objc func tapOnqtyAndPlusBtn(_ sender:UIButton){
        self.increaseQty(for: sender.tag)
    }
    @objc func handleTapCell(recognizer:UITapGestureRecognizer){
        if let index = recognizer.view?.tag {
            self.increaseQty(for: index)
        }
    }
    func increaseQty(for index:Int){
        if let section = self.section{
            if self.mwComboVM?.canIncreaseQty(for: section) ?? false{
                if let item = self.mwComboVM?.getItemProduct(for: section, at:index){
                    if item.type == .note {
                        item.selectQty = 1
                        item.isSelect = true
                        self.mwComboVM?.addAddOnSelect(item)
                        UIView.performWithoutAnimation {
                            
                            self.collection.reloadItems(at: [IndexPath(row: index, section: 0)])
                        }
                        return
                    }
                    
                    let isRadioSelect = self.mwComboVM?.resetAddOnSecion(at: section,excludeProduct: item) ?? false
                    if isRadioSelect {
                        item.selectQty = self.mwComboVM?.getSelectedQty() ?? 1.0
                    }else{
                        item.increaseQty()
                    }
                    self.mwComboVM?.addAddOnSelect(item)
                    if isRadioSelect {
                        UIView.performWithoutAnimation {
                            
                            self.collection.reloadData()
                        }
                    }else{
                        UIView.performWithoutAnimation {
                            
                            self.collection.reloadItems(at: [IndexPath(row: index, section: 0)])
                        }
                    }
                   return
                }
            }else if self.mwComboVM?.canSwitch(for: section) ?? false{
                if let item = self.mwComboVM?.getItemProduct(for: section, at:index){
                    if item.type == .combo {
                        let subProductQty =  self.mwComboVM?.getQty(for: section) ?? 1.0
                        let isRadioSelect = self.mwComboVM?.resetAddOnSecion(at: section,excludeProduct: item) ?? false
                        if isRadioSelect {
                            item.selectQty = subProductQty
                            self.mwComboVM?.addAddOnSelect(item)
                            UIView.performWithoutAnimation {
                                self.collection.reloadData()
                            }
                            return
                        }

                    }
                }
            }
            self.mwComboVM?.showValidQtyMessage(for: section)
            
        }
        
    }
}
