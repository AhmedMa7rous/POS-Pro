//
//  VareaintCollectionCell.swift
//  pos
//
//  Created by M-Wageh on 13/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class VareaintCollectionCell: UICollectionViewCell {

    @IBOutlet weak var titleCellLbl: UILabel!
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var heightOfCollection: NSLayoutConstraint!
    
    var mwComboVM:MWComboVM?
    var section:Int?
    
    var items: [ItemProductObject] = [] {
        didSet {
            collection.reloadData()
            updateHeightConstraint()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupCollection()
    }

    func updateHeightConstraint() {
        layoutIfNeeded()
        let contentHeight = collection.collectionViewLayout.collectionViewContentSize.height
        heightOfCollection.constant = contentHeight
    }
        
    func calculateWidth(for item: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 20)
        let width = item.size(withAttributes: [NSAttributedString.Key.font: font]).width
        return width + 40
    }
    
    func initalize(mwComboVM:MWComboVM?,section:Int?){
        self.mwComboVM = mwComboVM
        self.section = section
        self.titleCellLbl.text =  ""
        if let section = section, let items = mwComboVM?.getSubProduct(at: section)?.productItems {
            self.titleCellLbl.text = self.mwComboVM?.getSubProduct(at: section)?.nameSubProduct
            self.items = items
        }
        
        UIView.performWithoutAnimation {
            self.collection.reloadData()
            self.adjustHeightOfCollectionView()
            self.updateHeightConstraint()
//            self.collection.collectionViewLayout.invalidateLayout()
//            self.collection.layoutIfNeeded()

        }
        
    }
    func adjustHeightOfCollectionView() {
        if let section = self.section {
            let totalItems = mwComboVM?.getItemsProductCount(for: section) ?? 0
            let heightPerItem: CGFloat = 60
            let totalHeight = CGFloat(totalItems) * heightPerItem
            
            DispatchQueue.main.async {
                self.heightOfCollection.constant = totalHeight
                self.layoutIfNeeded()
            }
        }
    }

}
extension VareaintCollectionCell:UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, DynamicCollectionViewLayoutDelegate {
    func setupCollection(){
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 10
//        layout.minimumInteritemSpacing = 0
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        self.collection.setCollectionViewLayout(layout, animated: true)
        let layout = DynamicCollectionViewLayout()
        layout.delegate = self
        collection.collectionViewLayout = layout
        let nib = UINib(nibName: "SelectVariantCollectionCell", bundle: nil)
        collection.register(nib, forCellWithReuseIdentifier: "SelectVariantCollectionCell")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectVariantCollectionCell", for: indexPath) as! SelectVariantCollectionCell
        if let section = self.section{
            cell.initalize(from: self.mwComboVM?.getItemProduct(for: section, at:indexPath.row))
            cell.selectVariantBtn.tag = indexPath.row
            cell.selectVariantBtn.addTarget(self, action: #selector(changeSelect(_:)), for: .touchUpInside)

        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, displaySizeForItemAt indexPath: IndexPath) -> CGSize {
        if let section = self.section{
            guard let itemProduct = self.mwComboVM?.getItemProduct(for: section, at:indexPath.row) else {
                return CGSize(width: 30, height: 30)
            }
            let itemString = itemProduct.getTitleVariant()
            let width = calculateWidth(for: itemString)
            return CGSize(width: width + 20, height: 60)
        } else {
            return CGSize(width: 30, height: 30)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectVariantCollectionCell", for: indexPath) as! SelectVariantCollectionCell
//        cell.initalize(from: self.mwComboVM?.getItemProduct(for: self.section ?? 0, at:indexPath.row))
//        let width = cell.buttonWidth()
//
//
////        var   cls = ""
////        if let section = self.section{
////            cls = self.mwComboVM?.getItemProduct(for: section, at:indexPath.row)?.getTitleVariant() ?? "test name button"
////        }
//        return CGSize(width: width, height: 60)
//        guard let item = items[indexPath.item].nameItemProduct else { return CGSize(width: 30, height: 30)}
//        let width = calculateWidth(for: item)
//        return CGSize(width: width + 20, height: 60)
//    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        
    }
//    func getWidthLblFor(_ name:String) -> CGFloat{
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 20)
//        label.text = name
//        label.sizeToFit()
//        let widthLbl = label.frame.width + 90
//        return widthLbl
//    }
    @objc func changeSelect(_ sender:UIButton){
        if let section = self.section{
            if (self.mwComboVM?.getItemProduct(for: section, at: sender.tag)?.isSelect) ?? false{
                UIView.performWithoutAnimation {
                    
                    self.collection.reloadItems(at: [IndexPath(item: sender.tag, section: 0)])
                }
                return
            }
            self.mwComboVM?.setSelect(for: section, at:sender.tag)
            UIView.performWithoutAnimation {
                
                self.collection.reloadData()
                self.adjustHeightOfCollectionView()
            }
        }
    }
}
