//
//  SelectPickerCell.swift
//  pos
//
//  Created by  Mahmoud Wageh on 6/1/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class SelectPickerCell: UITableViewCell {
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var selectImage: KSImageView!
    var item:Codable?{
        didSet{
            if let item = item as? LocationModel{
                imageCell.isHidden = true
                titleLbl.text = item.display_name
                selectImage.isHighlighted = item.isSelected
                
            }
            if let item = item as? PickingTypeModel{
                imageCell.isHidden = true

                titleLbl.text = item.display_name
                selectImage.isHighlighted = item.isSelected


            }
            if let item = item as? PartnerModel{
                imageCell.isHidden = false
                if(!( item.image_128?.isEmpty ?? true))
                {
                    let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:(  item.image_128 ?? "") )
                    imageCell.image = logoData
                }
                else
                {
                    imageCell.image =     #imageLiteral(resourceName: "MWno_photo")
                }
                titleLbl.text = item.display_name
                selectImage.isHighlighted = item.isSelected


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
