//
//  KLabel.swift
//  pos
//
//  Created by Khaled on 6/10/20.
//  Copyright © 2020 khaled. All rights reserved.
//cairo_regular

import UIKit

@IBDesignable class KLabel: UILabel {
    
//    static let  font_name = app_font_name// "cairo-Regular"
    
 
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        check_lang()
    }
    

    private func commonInit() {
 
        if LanguageManager.currentLang() == .ar
        {
            if self.font.fontName.lowercased().contains("alexandria"){
                return
            }
            self.font = UIFont(name:  get_font(fontName: "cairo") , size: self.font.pointSize)
        }
    
//       Almarai self.font = UIFont(name:  get_font() , size: self.font.pointSize)
    }
    
    
    func get_font(fontName:String) -> String
    {
        let font_name =   self.font.fontName
        var style = "-Regular"
        
        let split = font_name.split(separator: "-")
        if split.count > 1
        {
            style = "-" +  String(split[1])
        }
        
        let font = fontName + style
        
        return font
    }
    
    @IBInspectable var shadow_color: UIColor? {
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
       
       @IBInspectable var shadow_offset: CGPoint {
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
                      self.clipsToBounds = true
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
    
    
    // ==========================================
    @IBInspectable var text_ar:String?
    @IBInspectable var rtl:Bool = false
    var textValue:String?{
        didSet{
                self.text = textValue
                self.text_ar = textValue
        }
    }
    func check_lang() {
           if text_ar != nil {
            self.set_Lang_ar(text: text_ar)
           }


       }

       func set_Lang_ar(text:String!) {

           let lang = LanguageManager.currentLang()
           if lang == .ar {
               self.text = text

               if rtl == true {
                self.textAlignment = .right
               }

           }
        
        

       }
}

 

