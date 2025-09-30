//
//  customerTableViewCell.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class loginUsersTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state.
        
        if selected
        {
            view_cell.backgroundColor = UIColor.init(hexString: "#5F2A8B")

        }
        else
        {
            view_cell.backgroundColor = UIColor.white

        }

    }

    
    @IBOutlet var lblNAme: KLabel!
 
    @IBOutlet var lblStatus: KLabel!
    @IBOutlet var lblLastLogin: KLabel!
     @IBOutlet var photo: KSImageView!
    @IBOutlet var view_cell: ShadowView!
    
    
    var object :res_users_class!

    func updateCell() {
        
         lblNAme.text = object.name
         lblLastLogin.text = ""
 
        if object.lastLogin  != "0"
         {
            let lastLogin:String = Date.init(millis:  Int64(object.lastLogin ?? "0" )! ).toString(dateFormat: "yyyy-MM-dd hh:mm a" , UTC: false) // myuserdefaults.getitem(String(object!.id), prefix:  "lastlogin_casher") as? String ?? ""
       
//            let dt = Date(millis: Int64(lastLogin)!)
//
//                 let day = dt.toString(dateFormat: "yyyy-MM-dd hh:mm a" , UTC: false)
            
             lblLastLogin.text = lastLogin // ClassDate.convertTimeStampTodate( lastLogin , returnFormate: "yyyy-MM-dd hh:mm a" , timeZone: NSTimeZone.local)
        }
       
        lblStatus.text = object.pos_user_type
        
//        if object.pos_security_pin == ""
//        {
//            lblStatus.text = "blocked"
//            lblStatus.textColor = UIColor.init(hexString: "#F55D55")
//        }
//        else
//        {
//            lblStatus.text = "Effective"
//            lblStatus.textColor = UIColor.init(hexString: "#0CC479")
//        }
        
        
        if(object.image != "")
        {
//            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:object.image! )
//            photo.image = logoData
            SharedManager.shared.loadImageFrom(.images,
                                               in:.res_users,
                                               with: object.image ?? "",
                                               for: self.photo)

        }
        
        
    }






}

