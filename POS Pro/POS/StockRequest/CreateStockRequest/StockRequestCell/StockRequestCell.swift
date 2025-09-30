//
//  StockRequestCell.swift
//  pos
//
//  Created by M-Wageh on 18/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class StockRequestCell: UITableViewCell {
    @IBOutlet weak var qtyLbl: UILabel!
    @IBOutlet weak var nameStockLbl: UILabel!
    @IBOutlet weak var qtyTF: UITextField!
    @IBOutlet weak var btnMins: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var uomLbl: UILabel!
    
    @IBOutlet weak var controllerStack: UIStackView!
    var storableProductModel:StorableItemModel?{
        didSet{
            if let item = storableProductModel {
                qtyLbl.text = item.qty.toIntString()
                qtyTF.text = item.qty.toIntString()
                nameStockLbl.text = item.display_name ?? ""
                uomLbl.text = item.select_uom_id.last ?? ""
            }
        }
    }
    var storableCategoryModel:StorableCategoryModel?{
        didSet{
            if let item = storableCategoryModel {
                qtyLbl.text = ""
                qtyTF.text = ""
                nameStockLbl.text = item.categoryName ?? ""
                uomLbl.text =  ""
            }
        }
    }
    var stockRequestOrderDetailsModel:StockRequestOrderDetailsModel?{
        didSet{
            if let item = stockRequestOrderDetailsModel {
                qtyLbl.text = "\(item.product_uom_qty ?? 0)"
                qtyTF.text = "\(item.product_uom_qty ?? 0)"
                nameStockLbl.text = item.product_id.last ?? ""
                uomLbl.text =  item.product_uom_id.last ?? ""
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setHideContolerBtns(with isHide:Bool){
        self.btnMins.isHidden = isHide
        self.btnPlus.isHidden = isHide
        self.qtyTF.isHidden = isHide
    }
    func setHideRemoveBtn(with isHide:Bool){
        self.removeBtn.isHidden = isHide
        
    }
    func setBtnsTag(with value:Int){
        btnMins.tag = value
        btnPlus.tag = value
        removeBtn.tag = value
        uomLbl.tag = value
        self.qtyTF.tag = value
        self.qtyLbl.tag = value
    }
    func isBtnsHiden() -> Bool{
        return  btnMins.isHidden &&  btnPlus.isHidden
    }
    
    
}
struct StorableProductModel  {
    let product : product_product_class?
    var qty : Double = 0.0

    init(from productDic:[String:Any]){
        self.product = product_product_class(fromDictionary: productDic)
    }
}
