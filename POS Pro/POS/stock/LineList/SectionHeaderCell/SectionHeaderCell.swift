//
//  SectionHeaderCell.swift
//  pos
//
//  Created by M-Wageh on 19/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SectionHeaderCell: UITableViewCell {

    @IBOutlet weak var titleHeaderLbl: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var tapHeaterBtn: UIButton!
    
    @IBOutlet weak var contentBKView: UIView!
    var storableCategoryModel:StorableCategoryModel?{
        didSet{
            if let storableCategoryModel = storableCategoryModel {
                titleHeaderLbl.text = storableCategoryModel.categoryName
                arrowImage.image = storableCategoryModel.isExpended ? #imageLiteral(resourceName: "ic_chevron_left_24px-3") : #imageLiteral(resourceName: "ic_chevron_left_24px-4")
                
            }
        }
    }
    var orginOrderMoveModel:OrginOrderMoveModel?{
        didSet{
            if let orginOrderMoveModel = orginOrderMoveModel{
                let sequence = orginOrderMoveModel.moveOrder?.sequence_number ?? 0
                let tableName = orginOrderMoveModel.moveOrder?.table_name ?? ""
                titleHeaderLbl.text = "#Order[\(sequence)] - Table[\(tableName)]"
                arrowImage.image = orginOrderMoveModel.isExpanded ? #imageLiteral(resourceName: "ic_chevron_left_24px-3") : #imageLiteral(resourceName: "ic_chevron_left_24px-4")
            }
        }
    }
    var settingSectionModel:SettingSectionModel?{
        didSet{
            if let settingSectionModel = settingSectionModel{
                let name = settingSectionModel.settingSection.getSettingName()
                titleHeaderLbl.text =  name
                
                let arrowImageName =  settingSectionModel.isExpanded ? "ic_chevron_left_24px-3" : "ic_chevron_left_24px-4"
                if let arrowIcon: UIImage = UIImage(named:arrowImageName)?.withRenderingMode(.alwaysTemplate)
                {
                    arrowImage.image = arrowIcon
                    arrowImage.tintColor = .white
                }
                self.contentBKView.backgroundColor = settingSectionModel.settingSection.getBKColor()
                self.titleHeaderLbl.textColor = settingSectionModel.settingSection.getTextColor()
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
    func bind(with title:String){
        self.titleHeaderLbl.text = title
        tapHeaterBtn.isHidden = true
        arrowImage.isHidden = true
        contentBKView.clipsToBounds = true
        contentBKView.layer.cornerRadius = 20
        contentBKView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        contentBKView.backgroundColor =  #colorLiteral(red: 0, green: 0.5704021454, blue: 0.4179805815, alpha: 1)
        self.titleHeaderLbl.textColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }
    
}
