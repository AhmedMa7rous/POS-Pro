//
//  notification_list_cell.swift
//  pos
//
//  Created by khaled on 28/03/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class notification_list_cell: UITableViewCell {

    @IBOutlet var lbl_date: UILabel!
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var lblMessage: UILabel!
 

    @IBOutlet var icon: UIImageView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateView(obj:notifications_messages_class)
    {
        lbl_title.text = obj.title
        lbl_date.text = obj.date
        lblMessage.text = obj.message
        
        icon?.image = UIImage(name: obj.icon_name)
    }
    
}
