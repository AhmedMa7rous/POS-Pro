//
//  newCustomerTableViewCell.swift
//  pos
//
//  Created by Muhammed Elsayed on 02/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class newCustomerTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet var lblCustomerName: KLabel!
    @IBOutlet var lblPhone: KLabel!
    
    //MARK: Variables
    var parent: new_customers_listVC!
    var customer :res_partner_class!
    
    func updateCell() {
        lblCustomerName.text = customer.name
        lblPhone.text = customer.phone
    }
    
    @IBAction func btnEdit(_ sender: Any) {
        let storyboard = UIStoryboard(name: "customers", bundle: nil)
        let add_Customer = storyboard.instantiateViewController(withIdentifier: "addCustomerNew") as? addCustomerNew
        add_Customer!.modalPresentationStyle = .formSheet
        add_Customer!.delegate = parent
        add_Customer!.customer = customer
        parent.present(add_Customer!, animated: true, completion: nil)
    }
}
