//
//  InfoDeviceCell.swift
//  pos
//
//  Created by M-Wageh on 16/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class InfoDeviceCell: UITableViewCell {

    
    @IBOutlet weak var valueLbl: KLabel!
    @IBOutlet weak var infoLbl: KLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func bind(with info:String, value:String){
        self.infoLbl.text = info
        self.valueLbl.text = value
    }
    
}
