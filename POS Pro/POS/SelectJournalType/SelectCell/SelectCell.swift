//
//  SelectCell.swift
//  pos
//
//  Created by M-Wageh on 24/04/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SelectCell: UITableViewCell {

    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var selectLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        bindData(text:"",hideImage:true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func bindData(text:String,hideImage:Bool){
        self.selectLbl.text = text
        self.selectImage.isHidden = hideImage
        
    }
    func setLblCenter(){
        self.selectLbl.textAlignment = .center
    }
    
}
