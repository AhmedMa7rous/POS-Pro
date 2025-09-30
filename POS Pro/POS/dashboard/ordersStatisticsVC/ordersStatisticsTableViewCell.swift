//
//  paymentMethodTableViewCell.swift
//  pos
//
//  Created by khaled on 9/24/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class ordersStatisticsTableViewCell: UITableViewCell {

    @IBOutlet var lblName: KLabel!
    @IBOutlet var lblValue: KLabel!

    @IBOutlet weak var enable_sw: UISwitch!
    @IBOutlet weak var btn_cell: KButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var printerImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if LanguageManager.currentLang() == .ar {
            stackView.semanticContentAttribute = .forceRightToLeft
            lblName.textAlignment = .right
            lblValue.textAlignment = .left
        }else{
            stackView.semanticContentAttribute = .forceLeftToRight
            lblName.textAlignment = .left
            lblValue.textAlignment = .right

        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   

}
