//
//  customerTableViewCell.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class customerTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBOutlet var lblCustomerName: KLabel!
    @IBOutlet var lblPhone: KLabel!
    @IBOutlet var lblPriceList: KLabel!
    @IBOutlet var lblLoyaltyPoints: KLabel!
    @IBOutlet var lblAddress: KLabel!

    @IBOutlet var photo: KSImageView!
    
    
    var parent:customers_listVC!
    var customer :res_partner_class!

    func updateCell() {
        
         lblCustomerName.text = customer.name
    
        lblAddress.text = String( format: "%@ , %@, %@" ,customer.street ,customer.city ,customer.country_name)
        lblPhone.text = customer.phone
//        lblPriceList.text = customer.phone
//        lblLoyaltyPoints.text = "120\n(Points)"

//        if(customer.image != nil)
//        {
//            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:customer.image )
//            photo.image = logoData
//        }
        
        if (customer.blacklist)
        {
            photo.isHighlighted = true
        }
        else
        {
            photo.isHighlighted = false

        }
        
        
    }



    @IBAction func btnEdit(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "customers", bundle: nil)
        let add_Customer = storyboard.instantiateViewController(withIdentifier: "addCustomer") as? addCustomer
        add_Customer!.modalPresentationStyle = .formSheet
        add_Customer!.delegate = parent
        add_Customer!.customer = customer
        
        parent.present(add_Customer!, animated: true, completion: nil)
        
    }


}

