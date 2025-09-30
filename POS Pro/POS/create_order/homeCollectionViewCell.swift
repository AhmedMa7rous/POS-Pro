//
//  homeCollectionViewCell.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class homeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var photo: KSImageView!
    
    @IBOutlet var cell_view: ShadowView!

    
    @IBOutlet var lblTitle: KLabel!
    @IBOutlet var lblCategory: KLabel!

    @IBOutlet var lblPrice: KLabel!
    @IBOutlet var lblVariants: KLabel!
    
    @IBOutlet var lblCombo: KLabel!
    @IBOutlet var lblCalories: KLabel!
    
    @IBOutlet weak var qtyAvaliableBadge: KLabel!
    
    @IBOutlet weak var shadawView: ShadowView!
    @IBOutlet var lblPrice2: UILabel!
    @IBOutlet var lblTitle2: UILabel!

    @IBOutlet weak var stackViewNewStyle: UIStackView!
    var needToRequesStock:Bool = false
    var is_variant:Bool = false

    var product :product_product_class!
    var priceList :product_pricelist_class?
    var isOpenStyle = false
    var haveImage = false

 
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
          
 
            
            if ( isHighlighted == true ) {
          

                UIView.animate(withDuration: 0.07) {
                    self.cell_view.backgroundColor = UIColor.lightGray

                }

              

            } else {
          

                UIView.animate(withDuration: 0.07) {
                    self.cell_view.backgroundColor = UIColor.white

                }



            }

        }

    }
 
    func updateCell() {
        isOpenStyle = SharedManager.shared.appSetting().enable_new_product_style
        self.stackViewNewStyle.isHidden = true
         haveImage = !product.image_small.isEmpty
        let lblTitleColor = haveImage ? #colorLiteral(red: 0.3176470588, green: 0.3490196078, blue: 0.4431372549, alpha: 1)  :  #colorLiteral(red: 0.4509803922, green: 0.4901960784, blue: 0.6078431373, alpha: 1) // #colorLiteral(red: 1, green: 0.358289957, blue: 0, alpha: 1)
        let lblPriceColor = haveImage ?  #colorLiteral(red: 1, green: 0.358289957, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 0.358289957, blue: 0, alpha: 1)
        let shadwoColor = !haveImage ? .clear :  #colorLiteral(red: 0.942442596, green: 0.912717402, blue: 0.9089447856, alpha: 0.6597045068) // #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4492028061)  // #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4021045919) // #colorLiteral(red: 0.3058823529, green: 0.2235294118, blue: 0.6862745098, alpha: 0.5249787415)
        // image shadaw shedid #colorLiteral(red: 0.942442596, green: 0.912717402, blue: 0.9089447856, alpha: 0.6597045068) 
        if isOpenStyle &&  haveImage {
            lblTitle.isHidden = true
            lblPrice.isHidden = true

            self.stackViewNewStyle.isHidden = false

            lblTitle2.textColor = lblTitleColor
            lblPrice2.textColor = lblPriceColor
            stackViewNewStyle.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            shadawView.backgroundColor =  .clear
            shadawView.isHidden = true
            photo.alpha = 1.0


        }else{
            lblTitle.isHidden = false
            lblPrice.isHidden = false
            lblTitle.textColor = lblTitleColor
            lblPrice.textColor = lblPriceColor
            shadawView.backgroundColor =  shadwoColor
            shadawView.isHidden = !haveImage
            photo.isHidden = !haveImage
            photo.alpha = 0.7

        }
        qtyAvaliableBadge.isHidden = true
        self.needToRequesStock = false
        self.product.getQtyAvaliable { avaliableQty in
            DispatchQueue.main.async {
                if let avaliableQty = avaliableQty {
                    if avaliableQty > 0{
                        self.qtyAvaliableBadge.backgroundColor =  #colorLiteral(red: 0.9799297452, green: 0.5426478982, blue: 0.2181500196, alpha: 1)
                        self.qtyAvaliableBadge.text = "\(avaliableQty)"
                        self.qtyAvaliableBadge.isHidden = false
                    }else if avaliableQty <= 0 {
                        self.needToRequesStock = true
                        self.qtyAvaliableBadge.backgroundColor =  #colorLiteral(red: 1, green: 0.3727238178, blue: 0.3406059146, alpha: 1)
                        self.qtyAvaliableBadge.text = "0"
                        self.qtyAvaliableBadge.isHidden = false
                    }
                    
                }
            }
        }
       
        if(haveImage)
        {
//            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:product.image_small )
//
//            photo.image = logoData
            SharedManager.shared.loadImageFrom(.images,
                                               in:.product_product,
                                               with: product.image_small,
                                               for: self.photo,handleHiden: true)

//            photo.isHidden = false
            
            //lblTitle.frame = CGRect.init(x: 8, y: 142, width: 148, height: 56)
//            let font = lblTitle.font
//              lblTitle.font  = font?.withSize(17)
        }
        else
        {
//            photo.image = #imageLiteral(resourceName: "cafe.jpg")
             photo.isHidden = true
                 
            // lblTitle.frame = CGRect.init(x: 8, y: 8, width: 148, height: 190)
//            let font = lblTitle.font
//             lblTitle.font  = font?.withSize(25)
        }
        
        
        let currency = product.currency_name ?? ""

        if is_variant == true
        {
            self.setNameProduct(with: product.attribute_names)
//            lblTitle.text = product.attribute_names

        }
        else
        {
            if LanguageManager.currentLang() == .ar
            {
                if product.name_ar.isEmpty
                {
//                    lblTitle.text =   product.name
                    self.setNameProduct(with: product.name)


                }
                else
                {
//                    lblTitle.text = product.name_ar
                    self.setNameProduct(with: product.name_ar)


                }

            }
            else
            {
                self.setNameProduct(with: product.name)

//                lblTitle.text =   product.name

            }
//            lblTitle.text = LanguageManager.currentLang() == .ar ? product.name_ar : product.name

        }
        
        if currency.lowercased().contains("sar"){

            self.setPriceProductAttribute(with:SharedManager.shared.getRiayalSymbol(total:baseClass.currencyFormate(product.get_price(priceList: priceList))))

        }else{
        self.setPriceProduct(with: String( format:"%@ %@" , baseClass.currencyFormate(product.get_price(priceList: priceList)),currency))


        }
 
      
        
        
    }
    
    func setNameProduct(with name:String){
        if lblTitle.isHidden{
            lblTitle2.text = name
            lblTitle.text = ""

        }else{
            lblTitle.text = name
            lblTitle2.text = ""

        }

    }
    func setPriceProduct(with price:String){
        if lblPrice.isHidden{
            lblPrice2.text = price
            lblPrice.text = ""

        }else{
            lblPrice.text = price
            lblPrice2.text = ""

        }

    }

    func setPriceProductAttribute(with txt:NSMutableAttributedString){
        if lblPrice.isHidden{
            lblPrice2.attributedText = txt
            lblPrice.text = ""

        }else{
            lblPrice.attributedText = txt
            lblPrice2.text = ""

        }

    }
    
}
