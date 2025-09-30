//
//  keyboard_number.swift
//  pos
//
//  Created by khaled on 11/2/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class keyboard_number: UIViewController {

    var delegate:keyboard_number_delegate?
      var mobile_mode:Bool = false
    var disable_fraction: Bool = false

    var clearText:Bool = true

    var pin:String! = ""

    @IBOutlet var btnDot: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if mobile_mode == true
        {
            btnDot.setTitle("+", for: .normal)
        }
        
     }

    @IBAction func btn_keyboardAction(_ sender: Any) {
        
 
        let btn :UIButton = sender as! UIButton
        let newNumber = btn.tag
        
        if newNumber == 10
        {
            pin = ""
            
        }
        else if newNumber == 11
        {
            if mobile_mode == true
            {
                
                if !pin.starts(with: "+")
                {
                      pin = "+"
                }
              
            }
            else
            {
                if disable_fraction == false
                {
                    let isfranc = pin.toDouble()
                                  if (isfranc?.isInteger())!
                                 {
                                    if !pin.contains(".")
                                    {
                                         pin = pin + "."
                                    }
                                                    
                                  }
                }
              
            }
          
        
        }
        else
        {
            
            if clearText == true && mobile_mode == false
            {
              clearText = false
                pin = ""
             }
            
            pin = String(format: "%@%d", pin , newNumber)
            
            var newValue:String! =  pin
            /*
                           if newValue.contains(".")
                           {
                               let sp = newValue.split(separator: ".")
                            
                            if sp.count == 2
                            {
                                    let firstnumbers:String = String(sp[0])
                                                            let lastnumber:String = String(sp[1])
                                                               if lastnumber.count > 2
                                                               {
                                //                                   let index = lastnumber.index(lastnumber.startIndex, offsetBy: 0)
                                //                                   let startChar =   lastnumber[index]
                                //
                                //                                   lastnumber = String(startChar)
                                                                   
                                                                    newValue =  firstnumbers + "." +   String(newNumber)
                                                               }
                            }
                           
                               
                           }
             */
            
            pin = newValue
            
        }
        
        delegate?.keyboard_newValue(val: pin  )
     
    }
    

}

protocol keyboard_number_delegate {
    func keyboard_newValue(val:String)
}
