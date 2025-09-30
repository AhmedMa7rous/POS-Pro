//
//  File.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

typealias search_product = create_order
extension search_product : UISearchBarDelegate
{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            //            self.collectionView?.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var txt = searchText
        
        if(!txt.isEmpty){
            txt  = searchText.toEnglishNumber()
            //reload your data source if necessary
            //            self.collectionView?.reloadData()
            
            //             if searchText == "enable_log_2020"
            //             {
            //                myuserdefaults.setitems("enable", setValue: "yes", prefix: "btnLog")
            //             }
            
            let searchPredicate = NSPredicate { (dic, _) -> Bool in
                let item = dic as? [String:Any] ?? [:]
                let  original_name = item["original_name"] as? String ?? ""
                let  barcode = (item["barcode"] as? String ?? "")
                let  default_code = item["default_code"] as? String ?? ""
                let  name = item["name"] as? String ?? ""
                let  name_ar = item["name_ar"] as? String ?? ""
                let  id = String( item["id"] as? Int ?? 0)
                
                let search_txt = String(format: "%@ %@ %@ %@ %@ %@", original_name.lowercased(),barcode.lowercased(),default_code.lowercased(),name.lowercased(),id,name_ar)
                //                if original_name is  String
                //                {
                //
                //                }
                //                else
                //                {
                //                            original_name = item["name"]
                //                }
                
                if  (search_txt  ).contains( txt.lowercased())
                {
                    return true
                }
                
                
                return false
            }
            
            //            let searchPredicate = NSPredicate(format: "original_name CONTAINS[c] %@", searchBarProducts.text! )
            let array = (self.list_product as NSArray).filtered(using: searchPredicate)
            list_product_search = array
            
            self.collection.reloadData()
            
        }
        else
        {
            list_product_search = list_product
            
            self.collection.reloadData()
        }
    }
    
    
    func getProductByBarCode( barCode: String) -> ( product:[String:Any]? , index:Int?)
    {
        var txt = barCode
        
        if(!txt.isEmpty){
            txt  = barCode.toEnglishNumber()
     
//
//            let searchPredicate = NSPredicate { (dic, _) -> Bool in
//                let item = dic as? [String:Any] ?? [:]
//
//                let  barcode = (item["barcode"] as? String ?? "")
//
//
//                let search_txt = String(format: "%@",  barcode.lowercased() )
//
//                if  (search_txt  ).contains( txt.lowercased())
//                {
//                    return true
//                }
//
//
//                return false
//            }
//
            
            let _index = self.list_product.firstIndex(where: {$0["barcode"] as! String ==  txt})
            if _index != nil
            {
                let _product = self.list_product.getIndex(_index!) as? [String:Any]
                
                return (_product,_index)
            }
     

//            let filterIndex = (self.list_product as NSArray).enumerated().filter { $0.["barcode"] == barcode }.map { $0.offset }
//
//            if filterIndex > 0

//             let array = (self.list_product as NSArray).filtered(using: searchPredicate)
//            if array.count > 0
//            {
////                return array.first as? [String : Any]
//
//            }
            
 
 
        }
      
          return (nil,nil)
       
    }
    
}

 
