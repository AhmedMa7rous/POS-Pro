//
//  dashboardTableViewCell.swift
//  pos
//
//  Created by khaled on 9/30/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class setting_homeTableViewCell: UITableViewCell {

    @IBOutlet var photo: KSImageView!
    @IBOutlet var lblTitle: KLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
