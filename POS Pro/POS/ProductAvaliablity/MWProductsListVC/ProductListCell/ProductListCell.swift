//
//  ProductListCell.swift
//  pos
//
//  Created by M-Wageh on 20/03/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class ProductListCell: UITableViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var stockLbl: UILabel!
    var productItem:ProductAvalibleModel?{
        didSet{
            if let item = productItem?.product_class{
                stockLbl.text = ""
                stockLbl.backgroundColor = .clear

                let englishName =  item.name
                let arabicName = item.name_ar
                if englishName != arabicName {
                    nameLbl.text = englishName + "/" + arabicName
                }else{
                    nameLbl.text = item.display_name
                }
                if  let avaliable = productItem?.avaliable_class{
                    if avaliable.avaliable_status == .ACTIVE{
                        let qty = avaliable.avaliable_qty ?? 0
                        stockLbl.text = "\(qty)"
                        let violetColor = #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1)
                        let redColor = #colorLiteral(red: 1, green: 0.3727239072, blue: 0.3453367949, alpha: 1)
                        
                        stockLbl.backgroundColor = qty <= 0 ? redColor :violetColor
                    }
                }
                

            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stockLbl.layer.masksToBounds = true
//        let lblHeight = stockLbl.frame.height
//        let lblWidth = stockLbl.frame.width

        stockLbl.layer.cornerRadius =  15

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
