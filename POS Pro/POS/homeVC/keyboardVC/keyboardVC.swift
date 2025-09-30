//
//  keyboardVC.swift
//  pos
//
//  Created by khaled on 8/31/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class keyboardVC: UIViewController {
    
    var delegate:keyboardVC_delegate?
//    var parent_vc:product_note_qty_delegate?
    
    var line:pos_order_line_class?
    var order:pos_order_class?
    
    @IBOutlet var view_product_info: ShadowView!
    @IBOutlet weak var view_addNote: UIView!
    @IBOutlet var btnQty: KButton!
    @IBOutlet var btnDisc: KButton!
    @IBOutlet var btnPrice: KButton!
    @IBOutlet var btnDot: KButton!
    
    @IBOutlet var lblPrice: KLabel!
    @IBOutlet var lblTitle: KLabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet var lblCategory: KLabel!
    
    @IBOutlet weak var btnPlusMinus: KButton!
    
    @IBOutlet var lblDescrption: KLabel!
    
    @IBOutlet weak var container: UIView!
//    var note_vc:product_note_qty?
    
    var inputType_selected : inputType = inputType.qty
    var item_indexPath_selected : IndexPath? = nil
    
    var selectNewOption:Double = -1
    
    var Qty:Double?
    {
        get
        {
            if Qty_str == ""
            {
                return 0
            }
            else
            {
                return Qty_str?.toDouble()
            }
        }
        set(new)
        {
            Qty_str = new?.toIntString()
        }
    }
    
    
    var Disc:Double? = 0
    var price:Double? = 0
    var customPrice:Bool? = false
    
    var Qty_str:String? = ""
    var Disc_str:String? = ""
    var price_str:String? = ""
    
    var in_start:Bool = true
    var disable_btnInput:Bool = false
    var disable_notes:Bool = false
    var disable_price:Bool = false
    var disable_plusOrMinus:Bool = false
    var disable_discount:Bool = false
    var disable_qty:Bool = false
    var disable_dot:Bool = false
    
    enum numbers : Int {
        case zero = 0, one , two, three, four, five, six, seven,eight,nine,dot,backscpace,plusOrMinus
    }
    
    enum inputType : Int {
        case qty = 13, disc , price
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
        
        price_str = price?.toIntString()
        Disc_str = Disc?.toIntString()
        Qty_str = Qty?.toIntString()
        
        
        container.frame.origin.x = 10
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showInfo()
        
        
        initNotes()
        check_disable_notes()
    }
    
    func check_disable_notes()
    {
        if disable_notes == true
        {
            self.preferredContentSize = CGSize(width: 320, height: 630)
            
        }
        else
        {
            self.preferredContentSize = CGSize(width: 640, height: 630)
            
        }
        
    }
    
    func initNotes()
    {
        if disable_notes == true
        {
            return
        }
        
//        let storyboard = UIStoryboard(name: "notes", bundle: nil)
//        note_vc = storyboard.instantiateViewController(withIdentifier: "product_note_qty") as? product_note_qty
//        note_vc?.line = line
//        note_vc?.order = order
//        note_vc?.delegate = parent_vc
//        note_vc!.view.frame.origin.x = -10
//        view_addNote.addSubview(note_vc!.view)
        
    }
    
    func showInfo()
    {
        if line != nil
        {
            let info = product_info()
             info.product = line?.product!
            info.line  = line
             
            
            view_product_info.addSubview(info.view)
            
            
            
//            let currency = line?.product!.currency_name ?? ""
//            let unite = line?.product!.uom_name   ?? ""
//
//
//            lblTitle.text = line?.product!.title
//            lblPrice.text = String( format:"%@ %@ / %@" , baseClass.currencyFormate((line?.get_price())!) ,currency , unite)
//            lblCategory.text = line?.product?.pos_categ_name //((product?.pos_categ_id.count)! > 0) ? product?.pos_categ_id[1] as? String ?? "" : ""
//            //            lblQty.text = product?.qty_app.toIntString()
//
//            var str_Descrption = ""
//            if line?.product?.calories != 0
//            {
//                str_Descrption = "Calories : " + (line?.product?.calories.toIntString())!
//            }
//
//            if !(line?.product?.description_.isEmpty)!
//            {
//                if !str_Descrption.isEmpty { str_Descrption = str_Descrption + "\n"}
//                str_Descrption = str_Descrption + "Descrption : " + (line?.product!.description_)!
//
//            }
//            if !str_Descrption.isEmpty { str_Descrption = str_Descrption + "\n"}
//
//            str_Descrption = str_Descrption + "Tax : " + (line!.price_subtotal_incl! - line!.price_subtotal!).toIntString()
//
//
//            lblDescrption.text = str_Descrption
//
//            //            if product!.discount != 0
//            //            {
//            //                lblDisc.text =  String( format:"With a %@ %@ discount",   product!.discount.toIntString(),"%")
//            //            }
//
//
//            if(!(line?.product!.image_small.isEmpty)!)
//            {
//                let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:(line?.product!.image_small)! )
//
//                photo.image = logoData
//            }
//            else
//            {
//                photo.image = UIImage(named: "no_photo.png")
//            }
//
            
            check_disable_btnInput()
                
                check_disable_price()
                check_disable_plusOrMinus()
                check_disable_discount()
                check_disable_qty()
                
                
                // init values
                disable_dot = true
                check_disable_dot()
                btnQty.setBackgroundColor_base(base: UIColor.init(hexString: "#0CC579"))
        }
         
        
           check_disable_btnInput()
           
           check_disable_price()
           check_disable_plusOrMinus()
           check_disable_discount()
           check_disable_qty()
           
           
           // init values
           disable_dot = true
           check_disable_dot()
           btnQty.setBackgroundColor_base(base: UIColor.init(hexString: "#0CC579"))
    }
    
    func check_disable_btnInput()
          {
              
              if disable_btnInput == true
              {
                  btnQty.isEnabled = false
                  btnDisc.isEnabled = false
                  btnPrice.isEnabled = false
                  btnPlusMinus.isEnabled = false
                  btnDot.isEnabled = false
                  
                  
                  btnPrice.setBackgroundColor_base(base: UIColor.lightGray)
                  btnDisc.setBackgroundColor_base(base: UIColor.lightGray)
                  btnPlusMinus.setBackgroundColor_base(base: UIColor.lightGray)
                  btnDot.setBackgroundColor_base(base: UIColor.lightGray)
                  
              }
              else
              {
                  let casher = res_users_class.getDefault()
                  if casher.pos_user_type != "manager"
                  {
                      disable_discount = true
                      disable_price = true
                      //                disable_qty = true
                      
                      //                btnQty.isEnabled = false
                      //                btnDisc.isEnabled = false
                      //                btnPrice.isEnabled = false
                      //
                      //                btnPrice.setBackgroundColor_base(base: UIColor.lightGray)
                      //                btnDisc.setBackgroundColor_base(base: UIColor.lightGray)
                      
                  }
              }
          }
    
    func check_disable_dot()
       {
           if disable_dot == true
           {
               btnDot.isEnabled = false
               btnDot.setBackgroundColor_base(base: UIColor.lightGray)
               
           }
           else
           {
               btnDot.isEnabled = true
               btnDot.setBackgroundColor_base(base: UIColor.white)
               
           }
       }
     
     func check_disable_qty()
       {
           if disable_qty == true
           {
               btnQty.isEnabled = false
               btnQty.setBackgroundColor_base(base: UIColor.lightGray)
               
           }
           else
           {
               btnQty.isEnabled = true
               btnQty.setBackgroundColor_base(base: UIColor.white)
               
           }
       }
       
     
     func check_disable_price()
     {
         if disable_price == true
         {
             btnPrice.isEnabled = false
             btnPrice.setBackgroundColor_base(base: UIColor.lightGray)
             
         }
         else
         {
             btnPrice.isEnabled = true
             btnPrice.setBackgroundColor_base(base: UIColor.white)
             
         }
     }
     
     func check_disable_discount()
     {
         if disable_discount == true
         {
             btnDisc.isEnabled = false
             btnDisc.setBackgroundColor_base(base: UIColor.lightGray)
             
         }
         else
         {
             btnDisc.isEnabled = true
             btnDisc.setBackgroundColor_base(base: UIColor.white)
             
         }
     }
     
     func check_disable_plusOrMinus()
     {
         if disable_plusOrMinus == true
         {
             btnPlusMinus.isEnabled = false
             btnPlusMinus.setBackgroundColor_base(base: UIColor.lightGray)
             
         }
         else
         {
             btnPlusMinus.isEnabled = true
             btnPlusMinus.setBackgroundColor_base(base: UIColor.white)
             
         }
         
     }
     
    
    func setNewValue(val:String)  {
        if(inputType_selected == .price)
        {
            customPrice = true
            
            price_str = val
            
            price = Double( val)
        }
        else if(inputType_selected == .disc)
        {
            Disc_str = val
            Disc = Double( val)
            
            
            if Disc ?? 0 >  100
            {
                Disc = 100
            }
            
            if Disc ?? 0 <  0
            {
                Disc = 0
            }
            
            
        }
        else
        {
            Qty_str = val
            
            Qty = Double( val)
        }
    }
    
    func getOldValue() -> String
    {
        if in_start == true
        {
            in_start = false
            return ""
        }
        
        
        if(inputType_selected == .price)
        {
            return price_str ?? ""
        }
        else if(inputType_selected == .disc)
        {
            return Disc_str ?? ""
        }
        else
        {
            return Qty_str ?? ""
        }
    }
    
    @IBAction func btnEdit(_ sender: Any) {
        delegate?.edit_combo(line: line!)
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnVoid(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        delegate?.delete_Row(line: line!)
        
    }
    
    @IBAction func btn_keyboardAction(_ sender: Any) {
        
        let btn :UIButton = sender as! UIButton
        let newNumber = btn.tag
        
        var newValue = ""
        let oldValue = getOldValue()
        
        if (item_indexPath_selected == nil)
        {
            return
        }
        
        switch newNumber {
            
        case numbers.zero.rawValue...numbers.nine.rawValue:
            
            if selectNewOption == -1
            {
                newValue = String( newNumber)
            }
            else
            {
                newValue =  String(format:"%@%d", oldValue  , newNumber )
                if newValue.contains(".")
                {
                    let sp = newValue.split(separator: ".")
                    let firstnumbers:String = String(sp[0])
                    var lastnumber:String = String(sp[1])
                    if lastnumber.count > 2
                    {
                        let index = lastnumber.index(lastnumber.startIndex, offsetBy: 0)
                        let startChar =   lastnumber[index]
                        
                        lastnumber = String(startChar)
                        
                        newValue =  firstnumbers + "." + lastnumber + String(newNumber)
                    }
                    
                }
            }
            
            selectNewOption = Double(newNumber)
            
            setNewValue(val: newValue)
            
            
        case numbers.dot.rawValue:
            
            
            if !oldValue.contains(".")
            {
                newValue = String(format:"%@%@", oldValue, "." )
                setNewValue(val: newValue)
                
            }
            
        case numbers.backscpace.rawValue:
            
            var str :String! = oldValue
            if  str.count != 0
            {
                str = String(str.dropLast())
            }
            
            
            if str == "" {str = "0"}
            
            setNewValue(val: str)
            
            
        case numbers.plusOrMinus.rawValue:
            
            
                 var str :String! = oldValue
                 if str == "" {str = "1"}
                 
                 if str.hasPrefix("-")
                 {
                     str = String(str.dropFirst())
                 }
                 else
                 {
                     
                     
                     str = String(format:"%@%@", "-", str )
                     
                     
                 }
            
            setNewValue(val: str)
            
            
        default:
            print(newNumber)
        }
        
        
        self.delegate?.keyboard_returnedValue(Qty: Qty ?? 0, Disc: Disc ?? 0 , price: price ?? 0,customPrice: customPrice!,item_indexPath_selected: item_indexPath_selected!)
        
    }
    
    @IBAction func btn_TypeAction(_ sender: Any) {
        
        let btn :UIButton = sender as! UIButton
        
        //        btnPrice.isSelected = false
        //        btnDisc.isSelected = false
        //        btnQty.isSelected = false
//        btnPrice.backgroundColor = UIColor.white
//        btnDisc.backgroundColor = UIColor.white
//        btnQty.backgroundColor = UIColor.white
        
        check_disable_price()
           check_disable_plusOrMinus()
           check_disable_discount()
           check_disable_qty()
           
           disable_dot = false
        
        selectNewOption = -1
        
        switch btn.tag {
            
        case inputType.price.rawValue:
            inputType_selected = .price
            btnPrice.setBackgroundColor_base(base:  UIColor.init(hexString: "#0CC579"))
            
            btnPlusMinus.isEnabled = false
            btnPlusMinus.setBackgroundColor_base(base:  UIColor.init(hexString: "#B2B2B2"))
            
        case inputType.disc.rawValue:
            inputType_selected = .disc
            btnDisc.setBackgroundColor_base(base:  UIColor.init(hexString: "#0CC579"))
            
            btnPlusMinus.isEnabled = false
            btnPlusMinus.setBackgroundColor_base(base: UIColor.init(hexString: "#B2B2B2"))
            
            
        default:
               inputType_selected = .qty
                    btnQty.setBackgroundColor_base(base: UIColor.init(hexString: "#0CC579"))
                    disable_dot = true

                    if disable_plusOrMinus == false
                    {
                        btnPlusMinus.isEnabled = true
                        btnPlusMinus.setBackgroundColor_base(base:UIColor.white)
                    }
            
        }
        
            check_disable_dot()
        //        clacTotal()
    }
    
    
    
}

protocol keyboardVC_delegate :AnyObject{
    func keyboard_returnedValue(Qty:Double,Disc:Double,price:Double,customPrice:Bool,item_indexPath_selected:IndexPath)
    func delete_Row(line:pos_order_line_class)
    func edit_combo(line:pos_order_line_class)
    
}
