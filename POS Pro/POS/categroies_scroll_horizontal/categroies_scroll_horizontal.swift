//
//  categroies_scroll_horizontalViewController.swift
//  pos
//
//  Created by Khaled on 5/20/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

protocol categroies_scroll_horizontal_delegate {
    func categroies_scroll_horizontal_selected(categ:pos_category_class?)
}

class categroies_scroll_horizontal: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
   
    var delegate:categroies_scroll_horizontal_delegate?

    
    @IBOutlet var collectionView: UICollectionView!
    let cellIdentifier = "cellIdentifier"
    
    var list_categ:[Any] = []
    var main_categ:[Any] = []
    var all_categories:[Any]! = []
    
    var selected_index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCategory()
    }
    
   
    
    
    func getCategory() {
        
        if main_categ.count == 0
        {
            self.all_categories = pos_category_class.getAll()  //api.get_last_cash_result(keyCash: "get_pos_gategory")
            
            let   main_categ_org = pos_category_class.getCategoryTopLevel()
            main_categ.append(contentsOf: main_categ_org)
            
            
        }
        
        
//        self.list_categ.removeAll()
//        let all = ["id": 0, "name": "All" ] as [String : Any]
//        self.list_categ.append(all)
//        self.list_categ.append(contentsOf: main_categ)
        
        self.collectionView.reloadData()
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list_categ.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! categroies_scroll_horizontal_cell
        
        //in this example I added a label named "title" into the MyCollectionCell class
        
        let dic:[String:Any] = (self.list_categ[indexPath.item] as? [String:Any])!
        
        cell.categ  = pos_category_class(fromDictionary: dic)
        cell.setText(txt: cell.categ.name)
        
        if selected_index == indexPath.row
        {
            cell.setSelected()
        }
        else
        {
            cell.clearSelected()
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selected_index = indexPath.row
        
//        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! categroies_scroll_horizontal_cell
//        cell.setSelected()
        
        let dic:[String:Any] = (self.list_categ[indexPath.item] as? [String:Any])!
                  
         let categ  = pos_category_class(fromDictionary: dic)
        
        delegate?.categroies_scroll_horizontal_selected(categ: categ)
 
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize.init(width: 140, height: 50)
        
          let dic:[String:Any] = (self.list_categ[indexPath.item] as? [String:Any])!
           
          let categ  = pos_category_class(fromDictionary: dic)
            
            let label = KLabel(frame: CGRect.zero)
            label.font = UIFont.systemFont(ofSize: 16)
            label.text =  categ.name
             label.sizeToFit()
            return CGSize(width: label.frame.width + 50, height: 50)
        
    }
    
}
