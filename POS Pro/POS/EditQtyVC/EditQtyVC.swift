//
//  EditQtyVC.swift
//  pos
//
//  Created by M-Wageh on 16/09/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class EditQtyVC: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var qtyTF: UITextField!
    var qty = 0.0
    var completionBlock:((String?)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        qtyTF.text = qty.toIntString()
        qtyTF.delegate = self
        qtyTF.becomeFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !(qtyTF.text?.isEmpty ?? true){
            completionBlock?(qtyTF.text)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

