//
//  itemTableViewCell.swift
//  pos
//
//  Created by khaled on 8/16/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class itemTableViewCell: UITableViewCell {

        @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblCateg: KLabel!
       @IBOutlet var lblPrice: KLabel!
    
    @IBOutlet var lblQty: KLabel!
 
    @IBOutlet var lblDiscount: KLabel!

    @IBOutlet var photo: KSImageView!
    @IBOutlet var img_status: KSImageView!
    @IBOutlet weak var statusShadowView: ShadowView!
    
    var product :pos_order_line_class!
    var priceList :product_pricelist_class?


    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        SetPriceLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func SetPriceLayout() {
//        lblPrice.translatesAutoresizingMaskIntoConstraints = false
//        lblPrice.topAnchor.constraint(equalTo: self.topAnchor , constant: 10).isActive = true
//        lblPrice.rightAnchor.constraint(equalTo: self.rightAnchor , constant: -16 ).isActive = true
//        lblPrice.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        lblPrice.widthAnchor.constraint(equalToConstant: 50 ).isActive = true
//    }
    
    func  get_status()  {
        // none,pendding,send,rececived
        
        switch product.pos_multi_session_status {
        case .none:
            img_status.image = nil
            img_status.backgroundColor = UIColor.clear
            
            break
        case .last_update_from_local:
 
            img_status.image = nil
               img_status.backgroundColor = UIColor.clear
            break
        case .last_update_from_server:
            img_status.image = UIImage.init(named: "arrow_down.png")
            img_status.backgroundColor = UIColor.green

            break
        case .sending_update_to_server:
                 img_status.image = UIImage.init(named: "arrow_up.png")
                img_status.backgroundColor = UIColor.yellow

                  break
        case .sended_update_to_server:
             img_status.image = UIImage.init(named: "arrow_up.png")
             img_status.backgroundColor = UIColor.green

            break
        default:
            break
        }
        
        if product.kitchen_status == .done
        {
            img_status.image = UIImage.init(named: "select.png")
            img_status.backgroundColor = UIColor.clear
        }
    }
    
    func updateCell() {
        img_status?.isHidden = true
//       get_status()
        if product.parent_product_id == 0 {
            if product.is_sent_to_kitchen() && product.is_void == false {
                statusShadowView.backgroundColor = #colorLiteral(red: 0.6862745098, green: 0.8980392157, blue: 0.6549019608, alpha: 1)
                lblQty.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            } else if !product.is_sent_to_kitchen() && product.is_void == false {
                statusShadowView.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.8078431373, blue: 0.6823529412, alpha: 1)
                lblQty.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            }
        }
        set_title()
        
//        lblTitle?.text = String( format: "%@  x  %@" ,product.qty_app.toIntString(), product.title )
        lblCateg?.text = "" //String( format:"%@ %@ at %@  %@/%@", product.qty_app.toIntString(), unite ,baseClass.currencyFormate(product.price_app_priceList) ,currency,unite)
        
//        lblQty.text = String(product.qty_app)
 
//        lblDiscount.isHidden = true
        if product.discount != 0
        {
            if product.discount_type == .percentage
            {
                if !(product.discount_display_name  ?? "").isEmpty
                {
                    lblCateg.text =  String( format:"%@ , %@", lblCateg.text! , product.discount_display_name!)

                }
                else
                {
                    lblCateg.text =  String( format:"%@ , With a %@ %@ discount", lblCateg.text! , product.discount!.toIntString(),"%")
                }

            }
            else
            {
                lblCateg.text =  String( format:"%@ , With a %@  discount", lblCateg.text! , product.discount!.toIntString())

            }
 
        }
        else
        {
            if !(product.discount_display_name  ?? "").isEmpty
            {
                lblCateg.text =  String( format:"%@ , %@", lblCateg.text! , product.discount_display_name!)

            }
        }
    
        
        
// lblCateg.backgroundColor = UIColor.red
//        let total = product.calcTotal()
         lblPrice?.text = ""
        if product.is_combo_line == true && product.parent_product_id != 0
        {
            if product.extra_price != 0
            {
                lblPrice?.text = String( format:"%@" , baseClass.currencyFormate(product.extra_price! * product.qty) )

            }

        }
        else
        {
            
            let isTaxFree = SharedManager.shared.posConfig().allow_free_tax || SharedManager.shared.appSetting().enable_show_price_without_tax
                      if isTaxFree == true
                      {
                        lblPrice?.text = String( format:"%@" , baseClass.currencyFormate(product.price_subtotal!) )

            }
                        
            else
                      {
            lblPrice?.text = String( format:"%@" , baseClass.currencyFormate(product.price_subtotal_incl!) )
            }
        }
        
//       get_combo()
        
         get_notes()
        
//        if(product.image != nil)
//        {
//            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:product.image )
//             photo.image = logoData
//        }
    }
    
    
    func set_title()
    {
 
        if product.is_combo_line == false
        {
            lblTitle.text = product.product.title
            lblQty.text = product.qty.toIntString()
            
//            if !product.product.attribute_names.isEmpty
//            {
//                let str  =  String( format: "%@ (%@) ",  product.product.title ,product.product.attribute_names  )
//
//               lblTitle.text = str
//            }
            
            
        }
        else
        {
            let normalText =  product.product.title  //+ String(product.id) //String( format: "%@  %@  %@" ,product.qty_app.toIntString(), "x" , product.title )
            
            lblTitle?.text  =  "> " + product.qty.toIntString() + " " + normalText
            
               
//                     if product.is_scrap == true
//                     {
//                         normalText = String(format: "%@ - (Scrap)", normalText)
//                     }
//
//                     var boldText  =  String( format: "%@  %@ " ,product.qty.toIntString(), "X" )
//                     if product.is_combo_line == true && product.parent_product_id != 0
//                            {
//                               boldText = "> " + boldText
//                           }
//
//
//                     let attributedString = NSMutableAttributedString(string:"")
//
//                     let font = UIFont(name: app_font_name , size: lblTitle.font.pointSize)
//                     let attrs = [NSAttributedString.Key.font : font! ] as [NSAttributedString.Key : Any]
//                     let boldString = NSMutableAttributedString(string: boldText, attributes:attrs )
//
//
//                     let normalString = NSMutableAttributedString(string: normalText)
//
//                     attributedString.append(boldString)
//                     attributedString.append(normalString)
//
//                     if !product.product.attribute_names.isEmpty
//                     {
//                         let str  =  String( format: " (%@) " ,product.product.attribute_names  )
//
//                         let attribute_namesString = NSMutableAttributedString(string:str , attributes:attrs)
//                         attributedString.append(attribute_namesString)
//
//                     }
//
//                     lblTitle?.attributedText = attributedString
        }
       
    }
    
    
    func get_notes()
    {
       var line:String = ""
        
        if !(product.note ?? "").isEmpty {
            line = product.note!.replacingOccurrences(of: "\n", with: " , ")
            line = line.replacingOccurrences(of: "-", with: " ")

            // Remove trailing comma and whitespaces
            line = line.trimmingCharacters(in: .whitespacesAndNewlines)
            line = line.replacingOccurrences(of: ",\\s*$", with: "", options: .regularExpression)
        }

        
        
        
//        for (_,valu) in product.notes
//        {
//
//            let note = noteClass(fromDictionary: valu)
//
//            if line.isEmpty {
//                line = String(format: "Notes : %@", note.display_name )
//
//            }
//            else
//            {
//                line = String(format: "%@,%@", line,note.display_name )
//
//            }
//
//        }
        
        
        
        if line.isEmpty {return}
        
        if   lblCateg.text!.isEmpty
        {
            lblCateg.text = line

        }
        else
        {
            lblCateg.text = String(format: "%@\n%@",    lblCateg.text!   , line)

        }

//        let h:CGFloat = 20
//        var frm = lblCateg.frame
//        frm.size.height = frm.size.height + h
//        lblCateg.frame = frm


        
    }
    
    func get_combo()
    {
          var frm = CGRect.init(x: 15, y: 38, width: 332, height: 20)
           lblCateg.frame = frm
        
        if product.selected_products_in_combo.count > 0 {
            var count:Int = 0

            var line:String = ""
            var line_notes:String = ""

            for p in product!.selected_products_in_combo
            {
//                let dic = item as? [String:Any]
//                let p = productProductClass(fromDictionary: dic!)
             
                if p.auto_select_num! == 0
                {
                    count += 1
                    
                    if line == ""
                    {
                        line = String(format: "->%@ %@",    p.qty.toIntString() , p.product.title)
                        
                    }
                    else
                    {
                        line = String(format: "%@\n-> %@ %@",  line  , p.qty.toIntString() , p.product.title)
                        
                    }
                    
                    if p.extra_price !=  0
                    {
                        line = String(format:"%@ (Extra price %@)", line , p.extra_price!.toIntString())
                    }
                }
                
                
                if !(p.note  ?? "").isEmpty
                {
                    line_notes = String(format: "%@-%@",  line_notes  , p.note!.replacingOccurrences(of: "\n", with: " - "))

                }
                
            }
            
            var h = CGFloat( (count * 25))
            
            if !line_notes.isEmpty
            {
                h  =  h + 30
            }
         
      
            
//            lblCateg.backgroundColor = UIColor.red
            let str = lblCateg.text!
            
            if str == ""
            {
                if line.isEmpty
                {
                     h  =  h + 10
                    lblCateg.text = String(format: "%@",   line_notes)

                }
                else
                {
                    lblCateg.text = String(format: "%@\n%@",   line, line_notes)

                }
                
            }
            else
            {
                 lblCateg.text = String(format: "%@\n%@\n%@",  str  , line,line_notes)
            }
            
            
            frm.size.height = h
                  lblCateg.frame = frm
            
        }
    }
    
    

}

 
