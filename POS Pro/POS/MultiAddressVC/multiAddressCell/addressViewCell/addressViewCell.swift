//
//  addressViewCell.swift
//  pos
//
//  Created by M-Wageh on 12/10/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class addressViewCell: UITableViewCell {

    @IBOutlet weak var nameAddressLbl: UILabel!
    
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var areaLbl: UILabel!

    var partner:res_partner_class?{
        didSet{
            if let partner = partner {
                removeBtn.isHidden = (partner.parent_id != 0 || partner.row_parent_id != 0 )
                self.nameAddressLbl.text = partner.name
                self.areaLbl.text = partner.pos_delivery_area_name
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
