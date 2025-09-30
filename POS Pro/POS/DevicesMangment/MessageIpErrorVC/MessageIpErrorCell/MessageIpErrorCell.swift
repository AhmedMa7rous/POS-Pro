//
//  MessageIpErrorCell.swift
//  pos
//
//  Created by M-Wageh on 21/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class MessageIpErrorCell: UITableViewCell {

    @IBOutlet weak var removeMessageBtn: KButton!
    @IBOutlet weak var titleMessageLbl: UILabel!
    @IBOutlet weak var resendBtn: KButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
