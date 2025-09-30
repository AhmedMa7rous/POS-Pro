//
//  PrinterErrorCell.swift
//  pos
//
//  Created by M-Wageh on 30/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class PrinterErrorCell: UITableViewCell {

    @IBOutlet weak var printerInfoLbl: UILabel!
    @IBOutlet weak var orderNumberLbl: UILabel!
    @IBOutlet weak var testPtinterBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
