//
//  InfoPopUpVC.swift
//  pos
//
//  Created by M-Wageh on 17/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class InfoPopUpVC: UIViewController {

    @IBOutlet weak var InfoPopUpVC: UILabel!
    var messagePopup:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let messagePopup = self.messagePopup{
            InfoPopUpVC.text = messagePopup
        }else{
            InfoPopUpVC.text = ""
        }
        // Do any additional setup after loading the view.
    }
    

}
class InfoPopUpRouter{
    static func createModule(_ sender:UIView?,messagePopup:String?) -> InfoPopUpVC {
        let vc:InfoPopUpVC = InfoPopUpVC()
        vc.messagePopup = messagePopup
        if let sender = sender{
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 200, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
}
