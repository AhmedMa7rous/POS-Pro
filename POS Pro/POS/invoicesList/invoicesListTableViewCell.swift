//
//  customerTableViewCell.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class invoicesListTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        referenceNumberStack.isHidden = true
        referenceNumberLineView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBOutlet weak var referenceNumberLineView: UIView!
    @IBOutlet weak var referenceNumberStack: UIStackView!
    //    @IBOutlet var lblName: KLabel!
    @IBOutlet var lblReferenceNumber: KLabel!
    @IBOutlet var lblTotal: KLabel!
    @IBOutlet var lblTable: KLabel!
    @IBOutlet var lblTime: KLabel!
    @IBOutlet var lblOrderID: KLabel!
   @IBOutlet var lblShiftID: KLabel!
    @IBOutlet var lbl_id: KLabel!

//    @IBOutlet weak var channelView: UIView!
    
    @IBOutlet weak var channelStack: UIStackView!
    var object :pos_order_class!

    override func prepareForReuse() {
        super.prepareForReuse()
        lblShiftID.text = ""
        lblOrderID.text = ""
        lbl_id.text = ""
        lblReferenceNumber.text = ""
        lblTable.text = ""
        lblTime.text = ""
        lblTotal.text = ""
    }
    func updateCell(_ showDriver:Bool) {
        
        if let referenceNumber = object.delivery_type_reference, !referenceNumber.isEmpty {
            referenceNumberStack.isHidden = false
            referenceNumberLineView.isHidden = false
            lblReferenceNumber.text = referenceNumber
        } else {
            referenceNumberStack.isHidden = true
            referenceNumberLineView.isHidden = true
        }
        lblShiftID.text  = object.table_name == "" ? "-" : object.table_name
        lblOrderID.text = String( object.sequence_number )
        if let creat_pos_code = object.create_pos_code , !creat_pos_code.isEmpty {
            lbl_id.text = creat_pos_code
        }else{
                if object.order_integration == .DELIVERY {
                    if let platFormName = object.platform_name , !platFormName.isEmpty{
                        lbl_id.text  = platFormName
                    }else{
                        lbl_id.text = (object.pos_order_integration?.online_order_source ?? "Online")
                    }
                }else{
                    lbl_id.text =  "Menu"
                }
            

        }
//        lbl_id.text = String( object.id ?? 0    )
        
//        let dateString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)
        
        let timeString = Date(strDate: object.create_date!, formate: baseClass.date_formate_database,UTC: true ).toString(dateFormat: baseClass.date_fromate_time, UTC: false)

//        lblTable.text = object.pos_multi_session_channel ?? "-"  //dateString
        lblTime.text = timeString
         lblTotal.text = baseClass.currencyFormate(object.amount_total  )
       
        if object.parent_order_id != 0
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
            lblReferenceNumber.textColor = txt_color
            lblTable.textColor = txt_color
            lblTime.textColor = txt_color
            lblTotal.textColor = txt_color

        }
        
        lblTable.text = object.driver?.name ?? " - "
//        channelView.isHidden = !showDriver
        channelStack.isHidden = !showDriver
        
 
        
        
    }






}

