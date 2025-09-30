//
//  addPromoCodeVC.swift
//  pos
//
//  Created by khaled on 12/04/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit
enum PROMO_CODE_TYPES{
    case DGTERA,BONATE, Coupon
    func getTitle()->String{
        switch self {
        case .DGTERA:
            return "Dgtera - ديجترا"
        case .BONATE:
            return "Bonat - بونات"
        case .Coupon:
            return "Coupon - كوبون"
        }
    }
}
class addPromoCodeVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var resetButton: KButton!
    @IBOutlet weak var txt: UITextField!
    var typeCode:PROMO_CODE_TYPES = .DGTERA

    var code:String?
    
    var didSelect  : ((String,PROMO_CODE_TYPES) -> Void)?
  

    override func viewDidLoad() {
        super.viewDidLoad()
        txt.delegate = self
        resetButton.setTitle("Cancel".arabic("الغاء"), for: .normal)
        txt.text = code ?? ""
        
    }


    @IBAction func btnSave(_ sender: Any) {
        let code = txt.text ?? ""
        
        if code == "" {
            messages.showAlert("Code is empty.".arabic("يجب إدخال الكود اولا"))
            return
        }
        
        if self.typeCode == .DGTERA{
            if !promotionSelectFilter.checkPromotionCode(code:code) && code.isEmpty == false
            {
                messages.showAlert("Code not exist.")
                return
            }
        }
                
        
        didSelect!(code,self.typeCode)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnReset(_ sender: Any) {
        didSelect!("",self.typeCode)
        self.dismiss(animated: true, completion: nil)

    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resetButton.setTitle("Cancel", for: .normal)
    }

}
