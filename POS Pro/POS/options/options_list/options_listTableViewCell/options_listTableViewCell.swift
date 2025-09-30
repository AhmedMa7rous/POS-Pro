//
//  options_listTableViewCell.swift
//  pos
//
//  Created by Khaled on 4/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class options_listTableViewCell: UITableViewCell {

    @IBOutlet var img_arrow: KSImageView!
    @IBOutlet var lblTtile: KLabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
