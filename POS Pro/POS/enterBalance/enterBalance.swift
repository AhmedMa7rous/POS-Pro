//
//  enterBalance.swift
//  pos
//
//  Created by khaled on 9/29/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class enterBalance: UIViewController ,keyboard_number_delegate{

    @IBOutlet var txtBalance: UITextField!
    var keyboard:keyboard_number = keyboard_number()

    @IBOutlet weak var lblTitle: KLabel!
    @IBOutlet var view_keyboard: UIView!
    var key:String?
     var title_vc:String = ""
    var delegate:enterBalance_delegate?
    
    var mobile_mode:Bool = false
    var initValue:String = ""
    var disable:Bool = false
    var disable_fraction: Bool = false
    
    var didSelect  : ((String,String) -> Void)?


    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = CGSize(width: 300, height: 560)

        txtBalance.isEnabled = false
        
        
         txtBalance.text = initValue
        lblTitle.text = title_vc
        setupKeyboard()
        // Do any additional setup after loading the view.
        
//        if key == "start_session"
//        {
//             txtBalance.text = ""
//
//            let lastSession = posSessionClass.getLastActiveSession()
//            let endBalance =2 lastSession.end_Balance
//            if endBalance != 0
//            {
//                 txtBalance.text = String( lastSession.end_Balance)
//            }
//
//        }
    }
    
 
    @IBAction func btnOk(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.newBalance(key: self.key!,value: self.txtBalance.text!)
            self.didSelect?(self.key!,self.txtBalance.text!)
        })

    }
    
    func setupKeyboard()
    {
        keyboard.pin = initValue
        keyboard.mobile_mode = mobile_mode
        keyboard.disable_fraction = disable_fraction
        keyboard.delegate = self;
        view_keyboard.addSubview(keyboard.view)
        
        view_keyboard.isUserInteractionEnabled = true

        if disable == true
        {
            view_keyboard.isUserInteractionEnabled = false
        }
        
    }
    func keyboard_newValue(val:String)
    {
        txtBalance.text = val
    }
    
 
    
}

protocol enterBalance_delegate {
    func newBalance(key:String,value:String)
}
