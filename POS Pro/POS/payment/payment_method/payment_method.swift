//
//  payment_method.swift
//  pos
//
//  Created by Khaled on 8/12/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

protocol  payment_method_delegate:class {
    func payment_selected(payment:account_journal_class)
}


class payment_method: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    let cellIdentifier = "FlickrCell"
    
    var list_items:  [[String:Any]] = []
    var filterby_journal_ids:[Int] = []
    var item_selected:account_journal_class?
    
    @IBOutlet var lbl_order_type: UILabel!
   weak var delegate:payment_method_delegate?
    
     var orderType :delivery_type_class?
    
    
    // loyalty
    var loyalty_amount_remaining:Double = 0
    var loyalty_amount_remaining_used:Double = 0
    var showCashMethodOnly:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func reload()
    {
        self.collectionView.reloadData()
    }
    func getPaymentMethod() {
        
        let arr = account_journal_class.getAll(delet: false,showCashMethodOnly: self.showCashMethodOnly)  // api.get_last_cash_result(keyCash: "get_account_Journals") as? [[String:Any]] ?? []
        
        self.list_items.removeAll()
        
        if self.filterby_journal_ids.count == 0
        {
            self.list_items.append(contentsOf: arr)
        }
        else
        {
            for item:[String:Any] in arr
            {
                let id = item["id"] as? Int ?? 0
                
                if  self.filterby_journal_ids.contains(id) {
                    self.list_items.append(item)
                }
                
            }
        }
        
        if orderType != nil
        {
            lbl_order_type?.text = "Order type : " +  orderType!.display_name
        }
        else
        {
             lbl_order_type?.text = ""
        }

        self.collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list_items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! payment_method_cell
        
        //in this example I added a label named "title" into the MyCollectionCell class
        
        let cls = list_items[indexPath.row]
        
        let payment = account_journal_class(fromDictionary: cls)
        cell.lbl_ttile.text = payment.display_name
        
         cell.icon.isHidden = false
             cell.lbl_ttile.isHidden = false
        
        if payment.code == "CSH1"
        {
            cell.icon.image =   #imageLiteral(resourceName: "mw_icon_bank") //UIImage(name: "mw_icon_bank.png")
        }
        else if payment.code == "MDA" ||  payment.code == "BNK1"
        {
            
            cell.icon.image =  payment.is_support_geidea ? UIImage(name: "gediea-log.png") : #imageLiteral(resourceName: "mw_icon_bank")
        }
        else if payment.code == "STC"
        {
            cell.icon.image = UIImage(name: "icon_stcpay.png")
//            cell.lbl_ttile.isHidden = true
            //             cell.icon.frame = CGRect.init(x: 0, y: 8, width: 129, height:98)
        }
//        else if payment.code == "ING1"
        else if payment.is_support_geidea
        {
            cell.icon.image = UIImage(name: "gediea-log.png")
        }
        else if payment.payment_type == "loyalty"
        {
            cell.icon.isHidden = true
            cell.lbl_ttile.text = payment.display_name + "\n\((loyalty_amount_remaining - loyalty_amount_remaining_used).toIntString())"
        }
        else
        {
            cell.icon.isHidden = true
            //            cell.lbl_ttile.frame = CGRect.init(x: 8, y: 8, width: 113, height:104)
        }
                
        
    
        if payment.id == item_selected?.id
        {
            
            cell.bg_view.backgroundColor = UIColor.init(hexString: "#FC7700")
            cell.lbl_ttile.textColor = UIColor.init(hexString: "#FFFFFF")
            if payment.code != "STC"
            {
                cell.icon.image = cell.icon.image?.withRenderingMode(.alwaysTemplate)
                cell.icon.tintColor = UIColor.init(hexString: "#FFFFFF")
            }
            
            cell.bg_view.frame = CGRect.init(x: 0, y: 0, width: 129, height: 114)
            cell.lbl_ttile.frame = CGRect.init(x: 8, y: 82, width: 113, height:30)
            cell.icon.frame = CGRect.init(x: 0, y: 8, width: 129, height:66)
            
           
            
        }
        else
        {
            cell.bg_view.backgroundColor = UIColor.init(hexString: "#FFFFFF")
            cell.lbl_ttile.textColor = UIColor.init(hexString: "#676767")
            
            if payment.code != "STC"
            {
                cell.icon.image = cell.icon.image?.withRenderingMode(.alwaysTemplate)
                cell.icon.tintColor = UIColor.init(hexString: "#A3A3A3")
            }
            
            cell.bg_view.frame = CGRect.init(x: 8 , y: 11, width: 113  , height: 92)
            cell.icon.frame = CGRect.init(x: 0, y: 8, width: 113, height:44)
            cell.lbl_ttile.frame = CGRect.init(x:0, y: 60, width: 113, height:30)
             
        }
        
       
            if let image = payment.image_small , !image.isEmpty{
                cell.icon.image = UIImage.ConvertBase64StringToImage(imageBase64String:payment.image_small! )
                cell.icon.isHidden = false
            }
           
        
        
        
        if cell.icon.isHidden
        {
            cell.lbl_ttile.frame =  cell.bg_view.bounds
            
        }
        
        if cell.lbl_ttile.isHidden
        {
            cell.icon.frame =  cell.bg_view.bounds
        
        }

      
        
       
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
    
        
        let dic = list_items[indexPath.row]
               
        let selected = account_journal_class(fromDictionary: dic )

        if selected.type == "bank"
        {
            rules.check_access_rule(rule_key.journal_bank,for: self)  {
                self.completeDidSelect(selected:selected)
            }
            return
        }
        else if selected.type == "cash"
        {
              rules.check_access_rule(rule_key.journal_cash,for: self)  {
                  self.completeDidSelect(selected:selected)
            }
            return
        }else{
            self.completeDidSelect(selected:selected)
        }
 
        
    
        
        
    }
    func completeDidSelect(selected: account_journal_class){
        item_selected = selected
//        item_selected!.loyalty_amount_remaining =  loyalty_amount_remaining
        
        delegate?.payment_selected(payment: item_selected!)
        
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        if item_selected != nil
//        {
//            let dic = list_items[indexPath.row]
//
//            let row = account_journal_class(fromDictionary: dic )
//
//            if item_selected?.id == row.id
//            {
//                return CGSize.init(width: 129, height: 114)
//            }
//
//        }
//        return CGSize.init(width: 105, height: 92)
 
            return CGSize.init(width: 129, height: 114)
    }
    
 func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
     let totalWidth = cellWidth * numberOfItems
     let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
     var leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
     if leftInset < 0 {
         leftInset = 0
     }
     let rightInset = leftInset
     return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
 

        
        return centerItemsInCollectionView(cellWidth: 129, numberOfItems: Double(self.list_items.count), spaceBetweenCell: 0, collectionView: collectionView)
//        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
}
