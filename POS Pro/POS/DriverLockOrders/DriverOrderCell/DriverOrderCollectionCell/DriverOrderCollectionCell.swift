//
//  DriverOrderCollectionCell.swift
//  pos
//
//  Created by M-Wageh on 26/01/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class DriverOrderCollectionCell: UICollectionViewCell {
    @IBOutlet var lblTtile: KLabel!
    @IBOutlet var lblValue: KLabel!

    override func prepareForReuse() {
     super.prepareForReuse()
     // clear any subview here
        lblTtile.text = ""
        lblValue.text = ""
//        lblValue.textColor = #colorLiteral(red: 0.3411764706, green: 0.3411764706, blue: 0.3411764706, alpha: 1)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
