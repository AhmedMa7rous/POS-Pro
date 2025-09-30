//
//  StockItemCell.swift
//  pos
//
//  Created by M-Wageh on 16/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class StockItemCell: UITableViewCell {
    
    @IBOutlet weak var qtyLbl: UILabel!
    @IBOutlet weak var nameStockLbl: UILabel!
    @IBOutlet weak var qtyTF: UITextField!
    @IBOutlet weak var btnMins: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var uomLbl: UILabel!
    
    @IBOutlet weak var stackController: UIStackView!
    var operationLineItem:OperationLineModel?{
        didSet{
            if let item = operationLineItem {
//                qtyLbl.text = item.product_uom_qty?.toIntString()
                setTitleForQtyLbl(item.product_uom_qty, item.total_quantity )
                qtyTF.text = item.product_uom_qty?.toIntString()
                nameStockLbl.text = item.product_id.last ?? ""
                uomLbl.text = item.product_uom.last ?? ""
            }
        }
    }
    var storableItemModel: StorableItemModel?{
        didSet{
            if let item = storableItemModel {
                qtyLbl.text = item.qty.toIntString()
                qtyTF.text = item.qty.toIntString()

                nameStockLbl.text = item.display_name ?? ""
                uomLbl.text  = item.select_uom_id.last ?? ""
            }
        }
    }
    var inventoryLineItem:StockInventoryLineModle?{
        didSet{
            if let item = inventoryLineItem {
                qtyLbl.text = item.getQty()?.toIntString()
                qtyTF.text = item.getQty()?.toIntString()
                nameStockLbl.text = (item.product_id.last ?? "")
                uomLbl.text = item.uom_id.last ?? ""
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
    func setTitleForQtyLbl(_ product_uom_qty:Double?, _ total_quantity:Double? ){
        var titleLbl = ""
        if let product_uom_qty = product_uom_qty {
            titleLbl = product_uom_qty.toIntString()
        
        if let total_quantity = total_quantity {
            titleLbl += "/" + (total_quantity).toIntString()
        }
    }
        self.qtyLbl.text = titleLbl
    }
    func appearnceAddMinsBtns(with flag:Bool){
        btnMins.isHidden = flag
        btnPlus.isHidden = flag
        removeBtn.isHidden = flag
        qtyTF.isHidden = flag
    }
    func hidQtyLbl(with flag:Bool){
        qtyLbl.isHidden = flag
    }
    func isBtnsHiden() -> Bool{
        return  btnMins.isHidden &&  btnPlus.isHidden
    }
    func setBtnsTag(with index:IndexPath){
        btnMins.superview?.tag = index.section
        btnPlus.superview?.tag = index.section
        removeBtn.superview?.tag = index.section
        uomLbl.superview?.tag = index.section

        btnMins.tag = index.row
        btnPlus.tag = index.row
        removeBtn.tag = index.row
        uomLbl.tag = index.row

        self.qtyTF.tag = index.row
        self.qtyLbl.tag = index.row
        self.qtyTF.superview?.tag = index.section
        self.qtyLbl.superview?.tag = index.section
        
    }
    
    
}
