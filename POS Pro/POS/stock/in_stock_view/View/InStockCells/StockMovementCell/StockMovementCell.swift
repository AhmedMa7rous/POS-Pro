//
//  StockMovementCell.swift
//  pos
//
//  Created by M-Wageh on 16/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class StockMovementCell: UITableViewCell {
    @IBOutlet weak var partnerLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var sourceLbl: UILabel!
    @IBOutlet weak var nameStockLbl: UILabel!
    @IBOutlet weak var dateStockLbl: UILabel!
    
    @IBOutlet weak var fromToStack: UIStackView!
    @IBOutlet weak var nameDateStack: UIStackView!
    
    @IBOutlet weak var statusName: KLabel!
    @IBOutlet weak var statusNameLbl: KLabel!

    var item:InStockMoveModel?{
        didSet{
            if let item = item {
                if let partenerName =  item.partner_id.last{
                    partnerLbl.text = partenerName
                }else{
                    if let partenerName =  item.location_id.last{
                        partnerLbl.text = partenerName
                    }
                }
                let location = partnerLbl.text ?? ""
                if location.lowercased().contains("transit"){
                    partnerLbl.text =   (item.origin ?? "")
                }
                fromLbl.text = item.location_id.last ?? ""
                sourceLbl.text = item.origin ?? ""
                nameStockLbl.text = item.name ?? ""
                dateStockLbl.text = getDateTime(item.scheduled_date ?? "")
//                statusName.text = " " +  (InStockRootVM.InStockStateTypes(rawValue:(item.state ?? ""))?.toString() ?? "") + " "
                setStyleForStateLbl()
            }
        }
    }
    var inventory_item:StockInventoryModel?{
        didSet{
            if let item = inventory_item {
                nameStockLbl.text = (item.sequence ?? "") + " - " + (item.name ?? "")
                dateStockLbl.text =  getDateTime(item.date ?? "")
                let stateName = (item.state ?? "") + "  "
                if stateName.contains("confirm"){
                    statusNameLbl.text = " in-progress "
                }else{
                    statusNameLbl.text = stateName
                }
                partnerLbl.text =  "--------"
                fromLbl.text =  "--------"
                sourceLbl.text =  "-------"
              
                fromToStack.isHidden = true
                statusNameLbl.isHidden = false
                setStyleForStatusRequestStockLbl(item.state ?? "")


            }
        }
    }
    var stockRequestOrderMoveModel:StockRequestOrderMoveModel?{
        didSet{
            if let item = stockRequestOrderMoveModel {
                partnerLbl.text = item.warehouse_id.last ?? ""
                fromLbl.text = item.location_id.last ?? ""
                sourceLbl.text =  "source"
                
                nameStockLbl.text = item.name ?? ""
                dateStockLbl.text =  getDateTime(item.expected_date ?? "")
                statusNameLbl.text = (item.state ?? "") + "  "
                
                fromToStack.isHidden = true
                statusNameLbl.isHidden = false
                setStyleForStatusRequestStockLbl(item.state ?? "")
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
    func getDateTime(_ timeStamp:String)->String{
       return baseClass.get_date_local_to_search(DateOnly: timeStamp, format: "yyyy-MM-dd HH:mm:ss" ,returnFormate: "yyyy-MM-dd")
    }
    func setStyleForStateLbl(){
        if let typeState = InStockRootVM.InStockStateTypes(rawValue:(item?.state ?? "")){
            statusName.text = " " +  typeState.toString() + " "
            let colorState = typeState.colorStaus()
            self.statusName.textColor = colorState
            self.statusName.borderColor = colorState
        }
    }
    func setStyleForStatusRequestStockLbl(_ state:String){
        var colorState =  #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1)

        if state.contains("done") {
            colorState = #colorLiteral(red: 0.08631695062, green: 0.7602397203, blue: 0.491546452, alpha: 1)
        }
        if state.contains("cancel") {
            colorState = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        if state.contains("draft") {
            colorState = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
            self.statusNameLbl.textColor = colorState
            self.statusNameLbl.borderColor = colorState
        
    }
}
