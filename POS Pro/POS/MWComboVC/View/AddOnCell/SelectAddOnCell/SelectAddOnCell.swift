//
//  SelectAddOnCell.swift
//  pos
//
//  Created by M-Wageh on 17/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class SelectAddOnCell: UICollectionViewCell {

    @IBOutlet weak var cellView: ShadowView!
    
    @IBOutlet weak var minsQtyBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var qtyAndPlusBtn: KButton!
    
    var isSelectedUI:Bool? {
        didSet{
            if let isSelectedUI = isSelectedUI{
                self.updateUI(isSelectedUI)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func initalize(from itemProduct:ItemProductObject?,attributeValues:[Int]){
        guard let itemProduct = itemProduct else {
            updateUI(false)
            return
        }
        if itemProduct.type == .note {
            qtyAndPlusBtn.isHidden = true
            minsQtyBtn.isHidden = !(itemProduct.selectQty > 0)
            priceLbl.isHidden = true
        }else{
            qtyAndPlusBtn.isHidden = itemProduct.selectQty <= 0
            minsQtyBtn.isHidden = qtyAndPlusBtn.isHidden
            priceLbl.isHidden = !qtyAndPlusBtn.isHidden

        }

        UIView.performWithoutAnimation {
            qtyAndPlusBtn.setTitle("\(itemProduct.selectQty)", for: .normal)
        }
        nameLbl.text = itemProduct.nameItemProduct
        let extra_price = itemProduct.getExtraPrice(attributeValues)
        if  extra_price > 0 {
            let currency = SharedManager.shared.getCurrencyName()
            if currency.lowercased().contains("sar"){
                priceLbl.attributedText = SharedManager.shared.getRiayalSymbol(total:"(\(extra_price) ")

            }else{
                priceLbl.text = "(\(extra_price) " + SharedManager.shared.getCurrencyName()
            }
        }else{
            priceLbl.isHidden = true
        }
        isSelectedUI = itemProduct.isSelect

        
    }
    func updateUI(_ isSelectedUI:Bool){
        let colorBK = isSelectedUI ? #colorLiteral(red: 1, green: 0.358289957, blue: 0, alpha: 1) : #colorLiteral(red: 0.9764705882, green: 0.9803921569, blue: 0.9882352941, alpha: 1)
        let colorTitle = isSelectedUI ?  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.4509803922, green: 0.4901960784, blue: 0.6078431373, alpha: 1)
        UIView.performWithoutAnimation {
//            selectVariantBtn.setTitleColor( colorTitle, for: [.normal])
//            selectVariantBtn.backgroundColor = colorBK
//            selectVariantBtn.layoutIfNeeded()

        }

    }
}
