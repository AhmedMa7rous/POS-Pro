//
//  UIButton+ext.swift
//  pos
//
//  Created by khaled on 9/18/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit


@IBDesignable class KButton: UIButton
{
    public  var backgroundColor_base: UIColor?
    
    
    @IBInspectable var backgroundColor_Highlighted: UIColor?
//    @IBInspectable var backgroundColor_Disabled: UIColor?

    
      override init(frame: CGRect) {
            super.init(frame: frame)

            self.commonInit()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)

            self.commonInit()
        }

        private func commonInit() {
 
            let lang = LanguageManager.currentLang()
            if lang == .ar {
                is_arabic = true
                if (self.titleLabel?.font.fontName.lowercased() ?? "" ).contains("alexandria"){
                    return
                }
                self.titleLabel?.font  = UIFont(name:  get_font(fontName:"cairo"), size:   (self.titleLabel?.font.pointSize)!)
            }
//            check_lang()
//
        }
    
   
    
    
    func get_font(fontName:String) -> String
    {
        let font_name =   self.titleLabel?.font.fontName
        var style = "-Regular"
        
        let split = font_name!.split(separator: "-")
        if split.count > 1
        {
            style = "-" +  String(split[1])
        }
        
        let font = fontName + style
        
        return font
    }
    
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGPoint {
        get {
            return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height)
        }
        set {
            layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
        }
        
    }
    
    @IBInspectable var shadowBlur: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue / 2.0
        }
    }
    
    @IBInspectable var shadowSpread: CGFloat = 0 {
        didSet {
            if shadowSpread == 0 {
                layer.shadowPath = nil
            } else {
                let dx = -shadowSpread
                let rect = bounds.insetBy(dx: dx, dy: dx)
                layer.shadowPath = UIBezierPath(rect: rect).cgPath
            }
        }
    }
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            if cornerRadius != 0 {
                layer.cornerRadius = cornerRadius
            }
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat
    {
        set (borderWidth) {
            self.layer.borderWidth = borderWidth
        }
        
        get {
            return self.layer.borderWidth
        }
    }
    
    @IBInspectable
    public var borderColor:UIColor?
    {
        set (color) {
            self.layer.borderColor = color?.cgColor
        }
        
        get {
            if let color = self.layer.borderColor
            {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
    
    
//    override var isHighlighted: Bool {
//        didSet {
//            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
//                self.alpha = self.isHighlighted ? 0.5 : 1
//
//            }, completion: nil)
//        }
//    }

    
//    override open var isHighlighted: Bool {
//        didSet {
//            if backgroundColor_base == nil
//            {
//                backgroundColor_base = backgroundColor
//            }
//
//             backgroundColor = isHighlighted ? backgroundColor_Highlighted : backgroundColor_base
//        }
//    }
    

//    override open var isHighlighted: Bool {
//        get {
//            return super.isHighlighted
//        }
//        set {
//            if backgroundColor_base == nil
//            {
//                backgroundColor_base = self.backgroundColor
//            }
//
//            if newValue {
//                 backgroundColor = backgroundColor_Highlighted
//             }
//            else {
//                backgroundColor = backgroundColor_base
//
//
//            }
//            super.isHighlighted = newValue
//        }
//    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
      {
       self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

       UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
           self.transform = CGAffineTransform.identity
       }, completion: nil)
       super.touchesBegan(touches, with: event)
     }

    
    override var isHighlighted : Bool {
        didSet {
          
            if backgroundColor_base == nil
                       {
                           backgroundColor_base = self.backgroundColor
                       }
            
            if ( isHighlighted == true ) {
          

                UIView.animate(withDuration: 0.07) {
//                    self.setTitleColor(UIColor.white, for: .normal)
                    self.backgroundColor = self.backgroundColor_Highlighted

                }

              

            } else {
          

                UIView.animate(withDuration: 0.07) {
//                    self.setTitleColor(UIColor.black, for: .normal)
                    self.backgroundColor = self.backgroundColor_base

                }



            }

        }

    }


    
//    override var isEnabled: Bool {
//        get {
//            return super.isEnabled
//        }
//        set {
//            if backgroundColor_base == nil
//            {
//                backgroundColor_base = self.backgroundColor
//            }
//
//            if newValue {
//                backgroundColor = backgroundColor_base
//            }
//            else {
//                backgroundColor = backgroundColor_Disabled
//
//            }
//            super.isEnabled = newValue
//        }
//    }
    
   public func setBackgroundColor_base(base:UIColor)
    {
        backgroundColor_base = base
        backgroundColor = base
    }
    
    // ==========================================
     var ـtext_ar:String?
     var ـtextSelected_ar:String?

    var is_arabic:Bool = false

    @IBInspectable var rtl:Bool = false

    @IBInspectable
    public var text_ar:String?
    {
        set (txt) {
            self.ـtext_ar = txt
            check_lang()
        }
        
        get {
            return ـtext_ar
        }
    }
    
    @IBInspectable
    public var textSelected_ar:String?
    {
        set (txt) {
            self.ـtextSelected_ar = txt
            if ـtextSelected_ar != nil {
                if is_arabic == true {
                self.setTitle(ـtextSelected_ar, for: .selected)

                   if rtl == true {
                    self.titleLabel!.textAlignment = .right
                   }

               }
            }
        }
        
        get {
            return ـtextSelected_ar
        }
    }
    
    
    func check_lang() {
           if ـtext_ar != nil {
            self.set_Lang_ar(text: ـtext_ar)
           }


       }

       func set_Lang_ar(text:String!) {

            if is_arabic == true {
            self.setTitle(text, for: .normal)

               if rtl == true {
                self.titleLabel!.textAlignment = .right
               }

           }
        
        

       }
    
}
