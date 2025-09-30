//
//  addressFieldCell.swift
//  pos
//
//  Created by M-Wageh on 12/10/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class addressFieldCell: UITableViewCell {

    @IBOutlet weak var fieldValueTF: UITextField!
    @IBOutlet weak var fieldNameLbl: UILabel!
    @IBOutlet weak var fieldBtn: UIButton!
    
    var cellField:AddressField?{
        didSet{
            if let cellField = cellField {
                self.fieldValueTF.isHidden = cellField.type == .CHOOSE
                self.fieldBtn.isHidden = cellField.type != .CHOOSE
                self.fieldNameLbl.text = cellField.name
                if let value = cellField.value as? String {
                    self.fieldValueTF.text = value
                }else{
                    if let value = cellField.value as? pos_delivery_area_class {
                        self.fieldBtn.setTitle(value.display_name, for: .normal)
                    }else{
                        self.fieldValueTF.text = ""
                        self.fieldBtn.setTitle("Choose delivery area".arabic("اختر منطقة التسليم"), for: .normal)
                    }
                }

            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func tapOnFieldBtn(_ sender: UIButton) {
        
    }
}
