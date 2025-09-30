//
//  paymentRowsCell.swift
//  pos
//
//  Created by khaled on 9/25/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class paymentRowsCell: UITableViewCell {

   weak var delegate:paymentRowsCell_delegate?
    
    @IBOutlet var lblTrndered: KLabel!
    @IBOutlet var lblDue: KLabel!
    @IBOutlet var lblPaymentMothod: KLabel!
    @IBOutlet var lblChange: KLabel!
    
    var object :account_journal_class!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func updateCell()
    {
        lblDue.text = baseClass.currencyFormate( object.due)
        lblTrndered.text =  baseClass.currencyFormate( object.tendered.toDouble()!)
        lblPaymentMothod.text = object.display_name
        lblChange.text = baseClass.currencyFormate(object.changes)

        
    }
    @IBAction func btnDeleteRow(_ sender: Any) {
        delegate?.deleteRow(row: object)
    }
    
}

protocol paymentRowsCell_delegate:class {
    func deleteRow(row:account_journal_class)
}

