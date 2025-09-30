//
//  customerTableViewCell.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class STCLogCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBOutlet var lblNAme: KLabel!
    @IBOutlet var lblSessionStatus: KLabel!
    @IBOutlet var lblTime: KLabel!
    @IBOutlet var lblTotal: KLabel!

    var dic:[String:Any]?
    
    var parent_vc:STCLogViewController?

 
    func updateCell() {
         let RefNum = dic!["RefNum"] as? String ?? ""
          let mobile = dic!["DeviceID"] as? String ?? ""
        
        if mobile == "1"
        {
            self.lblNAme.text = RefNum

        }
        else
        {
            self.lblNAme.text = RefNum + "    (" +   mobile + ")"

        }
        
        self.lblSessionStatus.text = dic?["PaymentStatusDesc"] as? String
        let amount = dic?["Amount"] as? Double
        self.lblTotal.text = amount?.toIntString()

        let time =  dic?["PaymentDate"] as? String
//        2020-01-08T20:22:20.79"
        
        let dt = Date(strDate: time!, formate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",UTC: true)
        let time_str = dt.toString(dateFormat:  "dd/MM/yyyy hh:mm:ss a", UTC: false)
        
//       let time_str =  ClassDate.getWithFormate(time, formate: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", returnFormate: "dd/MM/yyyy hh:mm:ss a")
        
        lblTime.text = time_str
        
    }


    @IBAction func btn_get_update(_ sender: Any) {
          let RefNum = dic!["RefNum"] as? String ?? ""

          parent_vc?.checkPayment(ref: RefNum)
      }



}

