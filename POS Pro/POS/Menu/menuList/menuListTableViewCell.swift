//
//  customerTableViewCell.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class menuListTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
//    @IBOutlet var lblName: KLabel!
 
    @IBOutlet var lblTotal: KLabel!
    @IBOutlet var lblTable: KLabel!
    @IBOutlet var lblTime: KLabel!
    @IBOutlet var lblOrderID: KLabel!
   @IBOutlet var lblShiftID: KLabel!
    @IBOutlet var lbl_id: KLabel!

    
    var object :pos_order_class!

    func updateCell() {
        
 
        lblShiftID.text  = object.table_name == "" ? "-" : object.table_name
        lblOrderID.text = String( object.sequence_number_full )
        lbl_id.text = String( object.id ?? 0    )
        
//        let dateString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)
        
        let timeString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_time, UTC: false)
        var name_delivery = ((object?.pos_order_integration?.online_order_source) ?? "JAHEZ")
        if (object?.order_integration ?? .NONE) == .DELIVERY  {
            if let platFormName = object.platform_name , !platFormName.isEmpty{
                name_delivery = platFormName
            }else{
                name_delivery = ((object?.pos_order_integration?.online_order_source) ?? "JAHEZ")
            }
        }else{
            name_delivery =   "Menu"
        }
        lblTable.text =   name_delivery 
        lblTime.text = timeString
         lblTotal.text = baseClass.currencyFormate(object.amount_total  )
       
        if object.sub_orders_count != 0
        {
            self.contentView.layer.borderWidth = 1
            self.contentView.layer.borderColor = UIColor(hexString: "#FC7700").cgColor
        }
        else
        {
            self.contentView.layer.borderWidth = 0

        }
        
        if (!(object.pos_multi_session_write_date ?? "").isEmpty && object.is_closed == false ) || object.create_pos_id != SharedManager.shared.posConfig().id
        {
            
            let txt_color = UIColor(hexString: "#3A8B27")
            lblShiftID.textColor = txt_color
            lblOrderID.textColor = txt_color
            lbl_id.textColor = txt_color

            lblTable.textColor = txt_color
            lblTime.textColor = txt_color
            lblTotal.textColor = txt_color

        }
        
 
        
        
    }






}

