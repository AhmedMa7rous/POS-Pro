//
//  variant.swift
//  pos
//
//  Created by Khaled on 2/2/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

protocol variant_delegate {
    func addProduct(line:pos_order_line_class,new_qty:Double,check_by_line:Bool,check_last_row:Bool)
}
class variant: UIViewController {

    @IBOutlet var collection: UICollectionView!
    var product_variant_ids:[Int]?
    
      var list_product: [[String:Any]] = []

    var delegate:variant_delegate?
    
    var order_id:Int?
    
    @IBOutlet weak var seq_qty: UISegmentedControl!
    private let reuseIdentifier = "FlickrCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
       getPorducts()
        
        
        var width = 400
               if list_product.count == 2
               {
                   width = 280
               }
                
         
        var hieght:Float =  Float(list_product.count) / 3.0
        if hieght == 0
        {
            hieght = 1
        }
        
        
       let h = Int(hieght * 160) + 50
       
        self.preferredContentSize = CGSize.init(width: width, height:h )
        
        self.collection.reloadData()
    }
    
    
    func getPorducts()
    {
        var ids:String = ""
        for id in product_variant_ids ?? []
        {
            if ids == ""
            {
                ids =   String(id)

            }
            else
            {
                ids = ids + "," + String(id)

            }
        }
        
        
        
        let cls = product_product_class(fromDictionary: [:])
        list_product = cls.dbClass!.get_rows(whereSql: " where id in (\(ids)) ")
        
        
    }

  

}
extension variant :UICollectionViewDataSource ,UICollectionViewDelegate  {
    //1
      func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
      func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return list_product.count

    }
    
    //3
      func collectionView(  _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath  ) -> UICollectionViewCell {
        let cell = collectionView  .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! homeCollectionViewCell
//        cell.backgroundColor = .lightGray
        // Configure the cell
        
        let obj = list_product[indexPath.row]
        
        let product = product_product_class(fromDictionary: obj )
  
        
        cell.product = product
        
        cell.is_variant = true
        cell.updateCell()
        
        return cell
    }
    
      func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
      {
//          let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! homeCollectionViewCell
        
           let obj = list_product[indexPath.row]
        let ptemp = product_product_class(fromDictionary: obj )

        
        let line = pos_order_line_class.get_or_create(order_id:order_id!, product: ptemp)

 
    
        delegate?.addProduct(line: line,new_qty: 0,check_by_line: true,check_last_row: true)

      
   
    }
    
    
    
}
