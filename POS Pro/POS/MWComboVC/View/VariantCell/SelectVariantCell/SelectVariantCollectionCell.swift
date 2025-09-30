//
//  SelectVariantCollectionCell.swift
//  pos
//
//  Created by M-Wageh on 13/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class SelectVariantCollectionCell: UICollectionViewCell {

    @IBOutlet weak var selectVariantBtn: KButton!
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
        restUI()        
    }
    override func prepareForReuse() {
//        restUI()
    }
    func restUI(){
//        selectVariantBtn.setTitle("", for: .normal)
        updateUI(false)
    }
    func initalize(from itemProduct:ItemProductObject?){
        guard let itemProduct = itemProduct else {
            restUI()
            return
        }
        if (selectVariantBtn.titleLabel?.text ?? "") != itemProduct.getTitleVariant(){
            UIView.performWithoutAnimation {
                
                selectVariantBtn.setTitle(itemProduct.getTitleVariant(), for: [.normal])
                selectVariantBtn.layoutIfNeeded()
            }
        }
        isSelectedUI = itemProduct.isSelect
        
    }
    func updateUI(_ isSelectedUI:Bool){
        let colorBK = isSelectedUI ? #colorLiteral(red: 1, green: 0.358289957, blue: 0, alpha: 1) : #colorLiteral(red: 0.9764705882, green: 0.9803921569, blue: 0.9882352941, alpha: 1)
        let colorTitle = isSelectedUI ?  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.4509803922, green: 0.4901960784, blue: 0.6078431373, alpha: 1)
        UIView.performWithoutAnimation {
            selectVariantBtn.setTitleColor( colorTitle, for: [.normal])
            selectVariantBtn.backgroundColor = colorBK
            selectVariantBtn.layoutIfNeeded()

        }

    }

    func buttonWidth() -> CGFloat {
            return selectVariantBtn.intrinsicContentSize.width + 40
        }

}
