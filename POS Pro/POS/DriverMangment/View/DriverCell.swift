//
//  DriverCell.swift
//  pos
//
//  Created by M-Wageh on 16/09/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class DriverCell: UITableViewCell {

    @IBOutlet weak var codeLbl: KLabel!
    @IBOutlet weak var nameLbl: KLabel!
    var driver:pos_driver_class?{
        didSet{
            if let item = driver {
                self.nameLbl.text = item.name
                self.codeLbl.text = item.code
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
    
}
