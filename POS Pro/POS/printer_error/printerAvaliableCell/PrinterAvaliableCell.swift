//
//  PrinterAvaliableCell.swift
//  pos
//
//  Created by M-Wageh on 30/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class PrinterAvaliableCell: UITableViewCell {
    @IBOutlet weak var testConnectionBtn: KButton!
    @IBOutlet weak var testPrintBtn: KButton!
    @IBOutlet weak var OutPrinterInfolbl: KLabel!
    
    @IBOutlet weak var errorIcon: UIImageView!
    @IBOutlet weak var errorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func doStyle(for status:TEST_PRINTER_Status){
        switch status {
        case .NONE:
            self.testPrintBtn.backgroundColor = #colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.431372549, alpha: 1)
        case .SUCCESS:
            self.testPrintBtn.backgroundColor = #colorLiteral(red: 0, green: 0.6274509804, blue: 0.6156862745, alpha: 1)
        case .FAIL:
            self.testPrintBtn.backgroundColor = #colorLiteral(red: 0.5294117647, green: 0.3529411765, blue: 0.4823529412, alpha: 1)
        }
    }
    
}
