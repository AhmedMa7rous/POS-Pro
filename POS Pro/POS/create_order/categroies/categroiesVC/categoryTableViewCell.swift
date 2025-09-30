//
//  categoryTableViewCell.swift
//  pos
//
//  Created by khaled on 9/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class categoryTableViewCell: UITableViewCell ,UICollectionViewDelegate, UICollectionViewDataSource  {

    weak  var delegate:categoryTableViewCell_delegate?

    
    var collectionView: UICollectionView!
    let cellIdentifier = "cellIdentifier"
    
    var list_categ:[Any] = []

   var last_categ_selected:[Int:[String:Int]] = [:]
    var last_categ_selected_level:Int = 0
    var didScrollToSecondIndex = false

    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
    func update()  {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 170, height: 140)
        layout.scrollDirection = .horizontal

        
        self.collectionView =  UICollectionView(frame:  .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self .addSubview(self.collectionView)

//        self.collectionView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: collectionView.topAnchor),
            self.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            ])

        
 
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
//        self.collectionView.register(categoryCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
                self.collectionView.register(UINib(nibName:"categoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)

        self.collectionView.alwaysBounceVertical = false
        self.collectionView.alwaysBounceHorizontal = false

        self.collectionView.backgroundColor = UIColor.init(hexString: "#F6F6F6")
        
        self.collectionView.reloadData()
        
    

    }
    
    func selectItem()
    {
        let level_categ_selected = last_categ_selected[last_categ_selected_level]
        let index_row = level_categ_selected?["index_row"] ?? 0
        
        if index_row <= list_categ.count - 1
        {
            let indexPath = IndexPath(item: index_row, section: 0)

            self.collectionView.scrollToItem(at: indexPath, at: [ .centeredHorizontally], animated: false)
            //        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /// this is done to set the index on start to 1 to have at index 0 the last image to have a infinity loop
        if !didScrollToSecondIndex {
            selectItem()
            didScrollToSecondIndex = true
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list_categ.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! categoryCollectionViewCell
        
        //in this example I added a label named "title" into the MyCollectionCell class
        
        let dic:[String:Any] = (self.list_categ[indexPath.item] as? [String:Any])!
        
        cell.categ  = categoryClass(fromDictionary: dic)
        
        cell.setText(txt:  cell.categ.name)
        
         let level = cell.categ.getLevel()
         let level_categ_selected = last_categ_selected[level]
        
        if level_categ_selected != nil
        {
            let categ_id_selected = level_categ_selected!["id"]
            if ( categ_id_selected == cell.categ.id )
            {
                cell.setSelected()
                
//                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)

            }
            else
            {
                cell.clearSelected()
            }
        }
        
   
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! categoryCollectionViewCell
        
       let categ  = cell.categ!
        
        didScrollToSecondIndex = false
        delegate?.get_child_categ(categ: categ ,didSelectItemAt: indexPath)
    }
    
}

protocol categoryTableViewCell_delegate:AnyObject {
    func get_child_categ(categ:categoryClass, didSelectItemAt indexPath: IndexPath)
}
//
//extension ViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.bounds.width, height: 44)
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//}
