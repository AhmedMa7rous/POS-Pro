//
//  MWCategoryVC.swift
//  pos
//
//  Created by M-Wageh on 20/03/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class MWCategoryVC: UIViewController {
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var syncAvailabilityButton: UIButton!
    
    @IBOutlet weak var categoryCollection: UICollectionView!
    
    
    @IBOutlet weak var selectCategoryLbl: UILabel!
    var productAvaliablityVM:ProductAvaliablityVM?
    var router:ProductAvaliablityRouter?
    var widthCell:Double?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLbl.text = "Products availability".arabic("توفر المنتجات")
        selectCategoryLbl.text = "Select Category".arabic("اختر الفئة")
        self.setupCollection()
        
    }
    
    @IBAction func syncAvailabilityButtonTapped(_ sender: UIButton) {
        productAvaliablityVM?.getProductsAvailability()
    }
    
    
    @IBAction func tapOnMenuBtn(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    

}
extension MWCategoryVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func setWidthCell(){
        let widthView = (self.view.frame.width)/6
        if widthView > 190 {
            self.widthCell = 190
        }else{
            self.widthCell = widthView
        }
        
    }
    func setupCollection(){
        categoryCollection.register(UINib(nibName: "MWCategoryCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        categoryCollection.delegate = self
        categoryCollection.dataSource = self
        self.setWidthCell()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productAvaliablityVM?.getCategoriesCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let categoryModel = productAvaliablityVM?.getCategoryModel(at: indexPath.row),
           let cell = self.categoryCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? MWCategoryCell{
            cell.initalize(categoryModel)
            return cell
        }
       
        return UICollectionViewCell()
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.productAvaliablityVM?.setSelectCategory(at: indexPath.row)
        if self.productAvaliablityVM?.setProductsData() ?? false{
            self.router?.openProductAvaliablityVC()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthCell ?? 70 , height: getHeight(for :indexPath.row))
        
    }
    func getHeight(for section:Int)-> CGFloat{
        let height = self.widthCell ?? 70
      
        return CGFloat(height * 1.28)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
     
}
