//
//  pinCode.swift
//  pos
//
//  Created by khaled on 9/30/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol pinCode_delegate {
    func closeWith(pincode:String)
}
class pinCode: baseViewController {
    
      @IBOutlet var lblNAme: KLabel!
 
        @IBOutlet var photo: KSImageView!
    
    
    @IBOutlet var lblPin: KLabel!
    @IBOutlet var pin1: KSImageView!
    @IBOutlet var pin2: KSImageView!
    @IBOutlet var pin3: KSImageView!
    @IBOutlet var pin4: KSImageView!
    
    @IBOutlet weak var lblTitle: KLabel!
    
    var delegate:pinCode_delegate?
    var mode_get_only:Bool = false
    var title_vc:String = ""
    
    var pin:String! = ""
    var completionEnterPin:((_ code:String)->())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let casher = SharedManager.shared.activeUser()
        lblTitle.text = "Pin Code "
        
             lblNAme.text = casher.name
        
        if(casher.image != "")
               {
//                   let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:casher.image! )
//                   photo.image = logoData
            SharedManager.shared.loadImageFrom(.images,
                                               in:.res_users,
                                               with: casher.image ?? "",
                                               for: self.photo)

               }
        
        // Do any additional setup after loading the view.
        if title_vc != ""
        {
            lblTitle.text = title_vc
        }
        
        //        self.preferredContentSize = CGSize.init(width: 400, height: 800)
        

    }
    
    @IBAction func btn_keyboardAction(_ sender: Any) {
        
        lblPin.textColor = UIColor.black
        
        let btn :UIButton = sender as! UIButton
        let newNumber = btn.tag
        
        if newNumber == 10
        {
            pin = ""
            
        }
        else
        {
            pin = String(format: "%@%d", pin , newNumber)
            
        }
        
        drawPin()
    }
    
    func drawPin()
    {
        
        
        lblPin.text = ""
        
        if pin.count  ==  0 {return}
        
        for _ in 0...pin.count - 1 {
            lblPin.text = String(format: "%@%@", lblPin.text! , "*")
        }
        
        
        
    }
    
    @IBAction func btn_login(_ sender: Any) {
        if mode_get_only == true
        {
            self.dismiss(animated: true) {
                if let completionEnterPin = self.completionEnterPin {
                    completionEnterPin(self.pin)
                }else{
                    self.delegate?.closeWith(pincode: self.pin)
                }
            }
        }
        else
        {
            #if DEBUG
                AppDelegate.shared.loadDashboard()
                return
            #endif
            let casher = SharedManager.shared.activeUser().pos_security_pin
//            SharedManager.shared.printLog(casher)
            
            if casher == pin
            {
                let time:Int64  = baseClass.getTimeINMS()

                cash_data_class.set(key: "pin_code_last_login", value: String( time))

                if AppDelegate.shared.load_kds == true
                               {
                                AppDelegate.shared.loadKDS()

                }
                else
                {
                    AppDelegate.shared.loadDashboard()

                }
            }
            else
            {
                pin = ""
                lblPin.text = ""
                SharedManager.shared.printLog(casher)
                messages.showAlert("Invalid pin code .")
            }
        }
    }
    
    @IBAction func btn_change_user(_ sender: Any) {
        
          AppDelegate.shared.login_users(activeSession: nil )
    }
    
    func drawPin_old()
    {
        let imagename_empty = "pin_empty.png"
        let pin_selected = "pin_selected.png"
        
        pin1.image = UIImage(name:imagename_empty)
        pin2.image = UIImage(name:imagename_empty)
        pin3.image = UIImage(name:imagename_empty)
        pin4.image = UIImage(name:imagename_empty)
        
        if pin.count >= 1
        {
            pin1.image = UIImage(name:pin_selected)
        }
        
        if pin.count >= 2
        {
            pin2.image = UIImage(name:pin_selected)
        }
        
        if pin.count >= 3
        {
            pin3.image = UIImage(name:pin_selected)
        }
        
        if pin.count >= 4
        {
            pin4.image = UIImage(name:pin_selected)
            
            if mode_get_only == true
            {
//                delegate?.closeWith(pincode: pin)
                self.dismiss(animated: true, completion: {
                    if let completion = self.completionEnterPin {
                        completion(self.pin)
                    }else{
                        self.delegate?.closeWith(pincode: self.pin)
                    }
                })
            }
            else
            {
                let casher = SharedManager.shared.activeUser().pos_security_pin
                if casher == pin
                {
                    AppDelegate.shared.loadDashboard()
                }
                else
                {
                    pin = ""
                    pin1.image = UIImage(name:imagename_empty)
                    pin2.image = UIImage(name:imagename_empty)
                    pin3.image = UIImage(name:imagename_empty)
                    pin4.image = UIImage(name:imagename_empty)
                    messages.showAlert("Invalid pin code .")
                }
            }
            
            
            
        }
        
    }
}
