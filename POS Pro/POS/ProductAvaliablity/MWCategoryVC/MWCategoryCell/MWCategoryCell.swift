//
//  MWCategoryCell.swift
//  pos
//
//  Created by M-Wageh on 20/03/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class MWCategoryCell: UICollectionViewCell {

    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    func setStyle(){
        self.mainView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.mainView.layer.cornerRadius = 8
        self.mainView.layer.borderWidth = 1
        self.mainView.layer.borderColor =  #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1)
    }
    func initalize(_ model:pos_category_class){
        self.setStyle()
        self.categoryLbl.text = model.display_name
        let imageName = model.image

        if imageName.isEmpty{
            self.categoryImage.isHidden = true
        }else{
            SharedManager.shared.loadImageFrom(.images,
                                               in:.pos_category,
                                               with: model.image,
                                               for: self.categoryImage,handleHiden: true)
        }
    }

}
