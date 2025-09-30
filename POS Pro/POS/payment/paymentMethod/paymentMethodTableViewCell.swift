//
//  paymentMethodTableViewCell.swift
//  pos
//
//  Created by khaled on 9/24/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class paymentMethodTableViewCell: UITableViewCell {

    @IBOutlet var lblName: KLabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var object :account_journal_class!
    
    func updateCell() {
        
        lblName.text = object.display_name
    }

}
