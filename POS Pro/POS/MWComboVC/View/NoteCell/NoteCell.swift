//
//  NoteCell.swift
//  pos
//
//  Created by M-Wageh on 04/06/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class NoteCell: UICollectionViewCell {
    @IBOutlet weak var titleCellLbl: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var requireLbl: UILabel!
    
    @IBOutlet weak var noteTF: UITextView!
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
        self.noteTF.text = mwComboVM?.getNote()

        if let section = section, let subProduct = self.mwComboVM?.getSubProduct(at: section){
            self.requireLbl.isHidden = !(subProduct.isRequire  ?? false)
            self.titleCellLbl.text = subProduct.nameSubProduct
            UIView.performWithoutAnimation {
                
                self.collection.reloadData()
                self.collection.collectionViewLayout.invalidateLayout()
                self.collection.layoutIfNeeded()

            }
        }
        self.noteTF.delegate = self
        
    }
    
}
extension NoteCell:UICollectionViewDelegate,UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
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
        var  cls = ""
        if let section = self.section{
            cls = self.mwComboVM?.getItemProduct(for: section, at:indexPath.row)?.nameItemProduct ?? "test name button"
        }//170.6 903
        let width = ((self.widthParent ?? 450 ) - 30 )/5
        
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
        if let section = self.section{
            if let item = self.mwComboVM?.getItemProduct(for: section, at:sender.tag){
                if item.type == .note {
                    removeFromTextView(item)

                    item.selectQty = 0
                    item.isSelect = false
                    self.mwComboVM?.removeAddOnSelect(item)
                    UIView.performWithoutAnimation {
                        
                        self.collection.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
                    }
                    return
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
                    if item.isSelect ?? false {
                        return
                    }
                    addTOTextView(item)
                        item.selectQty = 1
                        item.isSelect = true
                        self.mwComboVM?.addAddOnSelect(item)
                    UIView.performWithoutAnimation {
                        
                        self.collection.reloadItems(at: [IndexPath(row: index, section: 0)])
                    }
                        return
                }
            }
        }
        
    }
    func addTOTextView(_ item: ItemProductObject){
        self.noteTF.text += ((item.nameItemProduct ?? "") + "\n")
        self.mwComboVM?.setNote(self.noteTF.text ?? "")
    }
    func removeFromTextView(_ item: ItemProductObject){
        let newString = ( self.noteTF.text ?? "").replacingOccurrences(of: item.nameItemProduct ?? "", with: "").components(separatedBy: "\n").filter({$0 != "" && $0 != "\n"}).joined(separator: "\n")
        self.noteTF.text = newString
        self.mwComboVM?.setNote(self.noteTF.text ?? "")
    }
   
}
extension NoteCell:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        self.mwComboVM?.setNote(textView.text ?? "")


     }
}
