//
//  categories.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
typealias categories = create_order
extension categories: categroiesBC_delegate
{

    func loadCategories()
       {
           
           //    let frm :CGRect = CGRect.init(x: self.categories.frame.origin.x, y:  self.categories.frame.origin.y
           //        , width:  self.categories.frame.size.width , height: 75)
           
           let storyboard = UIStoryboard(name: "categroies", bundle: nil)
           categories_top = storyboard.instantiateViewController(withIdentifier: "categroiesBC") as? categroiesBC
           
//        let frm =  self.categories.bounds
           categories_top.view.frame = self.categories.bounds
           categories_top.delegate = self
           categories_top.parent_vc = self
           
           self.categories_top.view_container = self.categories
           self.categories_top.view_collection_container = view_collection_container
           self.categories_top.getCategory()
           self.categories_top.set_start_category()
           
           self.categories_top.expandAllCateg(checkIsExpand:false )
           
           //     categories_top.view.autoresizingMask  = [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
           
           // self.categories.addSubview(categories_top.view)
           
           self.categories.insertSubview(categories_top.view, at: 0)
           
           categories_top.txt_search.delegate = self
           
        removeBackground(from:  categories_top.txt_search)
       
        categeory_full_screen()
        
       }
    
    private func removeBackground(from searchBar: UISearchBar) {
        guard let BackgroundType = NSClassFromString("_UISearchBarSearchFieldBackgroundView") else { return }

        for v in searchBar.allSubViewsOf(type: UIView.self) where v.isKind(of: BackgroundType){
            v.removeFromSuperview()
        }
    }
    
    func breadcrumbSelected(categ:pos_category_class?)
    {

        categeory_full_screen()
    }
    func categeory_full_screen(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let showProducts = SharedManager.shared.appSetting().show_all_products_inHome
            
            if !showProducts {
                // Ensure outlets are loaded before accessing
                guard let categoriesTop = self.categories_top,
                      let categoriesView = self.categories,
                      let containerView = self.view_collection_container else {
                    return
                }
                
                categoriesTop.collectionView.isHidden = false
                categoriesView.frame = CGRect(x: 0, y: 0, width: 911, height: 956)
                containerView.frame = CGRect(x: 0, y: 70, width: 911, height: 956 - 70)
            }
            
            completion?()
        }
    }
    
    func close_full_screen()
    {
         DispatchQueue.main.async {
        let show_products = SharedManager.shared.appSetting().show_all_products_inHome
        if !show_products
        {
            self.categories_top.collectionView.isHidden = true

            self.categories.frame = CGRect(x: 0, y: 0, width: 911 ,height: 70  )
            
    
        }
        }
    }
    
    func categorySelected(categ:pos_category_class?)
    {
        list_product_search.removeAll()
        
        if categ == nil
        {
            categeory_full_screen { [weak self] in
                guard let self = self else {return}
                self.list_product_search.append(contentsOf: self.list_product)
                self.collection.reloadData()
            }
            return
        }
        
        //        let allIDS:String = String(categ!.id)
        var parent = false
        categ!.child_id = categ!.getChildIds()
        if categ!.child_id.count > 0
        {
            parent = true
            
            let setting = SharedManager.shared.appSetting()
            if setting.show_all_products_inHome == false
            {
                return
            }
            
        }
        
        close_full_screen()
        
        for item in list_product
        {
            let product = product_product_class(fromDictionary: item )
            let catid = product.pos_categ_id // String( (product.pos_categ_id.count > 0) ? product.pos_categ_id[0] as? Int ?? 0 : 0)
            //   the problem is that contains return true if 3 is a part of 13
            if ( parent == true )
            {
                for itemchild in categ!.child_id
                {
                    //                    let child  = String()
                    if  itemchild == catid {
                        list_product_search.append(item)
                    }
                }
            }
            else if  categ!.id == catid
            {
                list_product_search.append(item)
            }
            
            
        }
        self.collection.reloadData()
        let setting = SharedManager.shared.appSetting()
        if !setting.show_all_products_inHome
        {
            DispatchQueue.main.async{
                if let layout = self.collection.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .vertical
                    self.collection.isScrollEnabled = true
                    layout.footerReferenceSize = CGSize(width: self.collection.frame.width, height: 200)
                    
                }
            }
        }
    }
    
    
}
