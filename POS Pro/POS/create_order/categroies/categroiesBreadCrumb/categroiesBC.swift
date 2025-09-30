//
//  categroiesBC.swift
//  pos
//
//  Created by Khaled on 2/9/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

protocol categroiesBC_delegate {
    func breadcrumbSelected(categ:pos_category_class?)
    func categorySelected(categ:pos_category_class?)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
}


class categroiesBC: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    
    var delegate:categroiesBC_delegate?
    var view_collection_container: UIView!
    var view_container: UIView!
    
    @IBOutlet var collectionView_BC: UICollectionView!
    let cellIdentifier_BC = "cellIdentifier_BC"
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var widthPathCollection: NSLayoutConstraint!
    
    @IBOutlet weak var homeBtn: KButton!
    
    let cellIdentifier = "cellIdentifier"
    
    var list_categ_BC:[pos_category_class] = []
    var list_categ:[Any] = []
    
    var all_categories:[Any]! = []
    var main_categ:[Any] = []
    var categIsExpand = false
    
    var scroll_direction_vertical = false
    
    @IBOutlet var txt_search: UISearchBar!
    @IBOutlet weak var view_breadcurm: UIView!
    @IBOutlet var bg_cell: ShadowView!
    
    var view_list_hight:CGFloat = 0
    
    var minmum_hight:CGFloat = 260
    
    var parent_vc:UIViewController?
    
    var selected_categ:pos_category_class?

    
    func setTextSearch(txt:String)
    {
        txt_search.text = txt
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txt_search.backgroundImage = UIImage()
        txt_search.layer.borderWidth = 1
        txt_search.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
//        txt_search.setBackgroundImage(UIImage(), for: .any, barMetrics: UIBarMetrics.default)

        
        //        txt_search.delegate = parent_vc as? UISearchBarDelegate
 
        if LanguageManager.currentLang() == .ar {
            txt_search.placeholder = "ابحث هنا..."
        }
                
        
        init_AllCategBC()
        
        
        let setting = SharedManager.shared.appSetting()
        if !setting.show_all_products_inHome 
        {
            scroll_direction_vertical = setting.category_scroll_direction_vertical
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
                collectionView.alwaysBounceVertical = true
                collectionView.contentInsetAdjustmentBehavior = .automatic
                layout.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 200)
            }
        }
        else
        {
            scroll_direction_vertical = setting.category_scroll_direction_vertical
                   
                   if  scroll_direction_vertical == false
                   {
                       if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                           layout.scrollDirection = .horizontal
                           collectionView.alwaysBounceHorizontal = true

                       }
                   }
        }
        setTitleHome(with:SharedManager.shared.selected_pos_brand_name ?? "")
        NotificationCenter.default.addObserver(self, selector: #selector( update_qty_avaliable(notification:)), name: Notification.Name("update_qty_avaliable"), object: nil)

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("update_qty_avaliable"), object: nil)

    }
    @objc func update_qty_avaliable(notification: Notification) {
        
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.collectionView.reloadData()
                self.collectionView_BC.reloadData()
            }

        }
    }
    func setTitleHome(with brandNeme:String = ""){
       DispatchQueue.main.async {
           var title = "Home".arabic("الرئيسية")
           if !brandNeme.isEmpty {
               title += "(" + brandNeme + ")"
           }
           self.homeBtn.setTitle(title, for: .normal)
       }
    }
    
    func init_AllCategBC()
    {
        //        let all = ["id": 0, "name": "Home", "parent_id": false, "child_id": []] as [String : Any]
        //        list_categ_BC.append(pos_category_class(fromDictionary: all))
        
        self.collectionView_BC.reloadData()
    }
    
    @IBAction func btn_home(_ sender: Any) {
        
        delegate?.categorySelected(categ: nil)
        
        self.list_categ_BC.removeAll()
        
        init_AllCategBC()
        
        
        getCategory()
        expandAllCateg(checkIsExpand:true )
        
    }
    func resetCategory(_ sender: Any){
        main_categ.removeAll()
        btn_home(sender)
    }
    
    
    func getCategory() {
    
        
        
        if main_categ.count == 0
        {
            self.all_categories = pos_category_class.getAll()  //api.get_last_cash_result(keyCash: "get_pos_gategory")
            
            let   main_categ_org = pos_category_class.getCategoryTopLevel()
            main_categ.append(contentsOf: main_categ_org)
            
            //            for i in 0...6
            //            {
            //                main_categ.append(main_categ_org[i])
            //            }
        }
        
        
        self.list_categ.removeAll()
        //        let all = ["id": 0, "name": "All" ] as [String : Any]
        //           self.list_categ.append(all)
        self.list_categ.append(contentsOf: main_categ)
        
        self.collectionView.reloadData()

        
        
        //               breadCrumb(show: false)
        //        expandAllCateg(checkIsExpand:checkIsExpand,expand: true)
        
    }
    
    func set_start_category()
    {
        let pos = SharedManager.shared.posConfig()
        if pos.iface_start_categ_id != 0
        {
            let categ = pos_category_class.get(id: pos.iface_start_categ_id!)
            self.getChild(categ: categ,addToBreadCrumb: true)
            //                       delegate?.categorySelected(categ: categ)
        }
    }
    
    
    //    func breadCrumb(show:Bool)
    //    {
    //        if view_list_hight == 0
    //        {
    //            view_list_hight = collectionView.frame.size.height
    //        }
    //
    //        if show == false
    //        {
    //            view_breadcurm.isHidden = true
    //             collectionView.frame.origin.y = 10
    //             collectionView.frame.size.height = view_list_hight + 51
    //        }
    //        else
    //        {
    //            view_breadcurm.isHidden = false
    //             collectionView.frame.origin.y = 51 + 10
    //             collectionView.frame.size.height = 200 - 10
    //        }
    //
    //
    //    }
    //
    func expandAllCateg(checkIsExpand:Bool  )
    {
        return
        /*
        guard scroll_direction_vertical else { return }
//        if  scroll_direction_vertical == false
//        {
//            return
//        }
        
        
        if checkIsExpand == true
        {
            
            if categIsExpand ==  true
            {
                categIsExpand = false
                
                
                collapse()
                
                
                
                return
            }
            
        }
        
        
        
        categIsExpand = true
        
        var height = collectionView.collectionViewLayout.collectionViewContentSize.height
        let max_height:CGFloat = 500
        
        
        if height <= minmum_hight
        {
            self.collapse()
            
            return
        }
        
        
        
        if self.list_categ_BC.count > 1
        {
            
            view_breadcurm.isHidden = false
            //             self.collectionView.frame.origin.y = 50
            self.collectionView.frame.size.height =   self.view.frame.size.height - 50
            
        }
        else
        {
            view_breadcurm.isHidden = true
            //                 self.collectionView.frame.origin.y = 10
            self.collectionView.frame.size.height =   self.view.frame.size.height - 10
            
        }
        
        
        let height_parent = self.view_collection_container.superview?.frame.size.height ?? 0
        
        UIView.animate(withDuration: 0.3) {
            
            if height > self.minmum_hight && height < max_height
            {
                height = height - 20
                //            self.collectionView.frame.size.height = height
                self.view_container.frame.size.height = height
                self.view.frame.size.height = height
                
                
                let dif = height_parent - height
                self.view_collection_container.frame.size.height = dif
                self.view_collection_container.frame.origin.y = height
            }
            else
            {
                self.view_container.frame.size.height = max_height
                self.view.frame.size.height = max_height
                
                self.view_collection_container.frame.size.height = height_parent - max_height
                self.view_collection_container.frame.origin.y = max_height
            }
            
            
        }
        */
    }
    
    func collapse()
    {
        return
        /*
        guard scroll_direction_vertical else { return }
//        if  scroll_direction_vertical == false
//        {
//            return
//        }
        
        categIsExpand = false
        
        UIView.animate(withDuration: 0.3) {
            
            
            self.view_container.frame.size.height = self.minmum_hight
            
            
            self.view_collection_container.frame.origin.y = self.minmum_hight
            
            let height_parent = self.view_collection_container.superview?.frame.size.height ?? 0
            
            self.view_collection_container.frame.size.height = height_parent - self.minmum_hight
            
            
            //                self.collectionView.frame.size.height = 188
            
            self.view.frame.size.height = self.minmum_hight
            
            //                if self.list_categ_BC.count > 1
            //                     {
            //
            //                        self.view_breadcurm.isHidden = false
            //                          self.collectionView.frame.origin.y = 50
            //                      }
            //                       else
            //                        {
            //                            self.view_breadcurm.isHidden = true
            //                            self.collectionView.frame.origin.y = 10
            //                      }
            
        }
        
        */
    }
    
    
    //
    //
    //    func hideCateg()
    //    {
    //
    //
    //        UIView.animate(withDuration: 0.3) {
    //
    //         self.view_container.frame.size.height = 50
    //
    //         self.view_collection_container.frame.origin.y = 50
    //         self.view_collection_container.frame.size.height = 650
    //
    //        }
    //    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 0
        {
            return numberOfSections_BC(in: collectionView)
        }
        else
        {
            return numberOfSections_category(in: collectionView)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0
        {
            return collectionView_BC(collectionView, numberOfItemsInSection: section)
        }
        else
        {
            return collectionView_category(collectionView, numberOfItemsInSection: section)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 0
        {
            return collectionView_BC(collectionView, cellForItemAt: indexPath)
        }
        else
        {
            return collectionView_category(collectionView, cellForItemAt: indexPath)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView.tag == 0
        {
            
            collectionView_BC(collectionView, didSelectItemAt: indexPath)
        }
        else
        {
            collectionView_category(collectionView, didSelectItemAt: indexPath)
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0
        {
            
            return  collectionView_BC(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
        else
        {
            return  collectionView_category(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            
        }
        
    }
    
//    var last_parent_categ_selected:pos_category_class?
    func getChild(categ:pos_category_class?,addToBreadCrumb:Bool)
    {
        delegate?.categorySelected(categ: categ)
        
        get_path(categ: categ!, clear: true)
        
         self.list_categ_BC.reverse()
        
        let child:[Any] = pos_category_class.get_sub_category(parent_id: categ!.id )
        if child.count > 0
        {
            self.list_categ.removeAll()
            self.list_categ.append(contentsOf: child)
        }
        
        self.collectionView.reloadData()
        self.collectionView_BC.reloadData()
//        if categ == nil
//        {
//            //            let main_categ = categoryClass.getCategoryTopLevel(list: self.all_categories)
//            //
//            //                self.list_categ.removeAll()
//            //            self.list_categ.append(contentsOf: main_categ)
//            //            self.collectionView.reloadData()
//            //
//            //            initFrame()
//            //            expandAllCateg(checkIsExpand:true)
//
//        }
//        else
//        {
//            self.collectionView_BC.reloadData()
//
//            let child:[Any] = pos_category_class.get_sub_category(parent_id: categ!.id )
//
//
//            if child.count == 0
//            {
//
//                if addToBreadCrumb == true
//                {
//                    if categ?.parent_id != last_parent_categ_selected?.id
//                    {
//                        self.list_categ_BC.removeAll()
//                        self.list_categ_BC.append(categ!)
//
//                     }
//                     else
//                    {
//                        let filtered = self.list_categ_BC.filter { $0.id == categ!.id  }
//
//                        if filtered.count == 0
//                        {
//
//                           self.list_categ_BC.append(categ!)
//                        }
//
//                     }
//
//
//
//                            self.collectionView_BC.reloadData()
//
//
//
//                }
//
//            }
//            else
//            {
//
//
//                if addToBreadCrumb == true
//                {
//                    if categ?.parent_id != last_parent_categ_selected?.id
//                   {
//                     self.list_categ_BC.removeAll()
//                    }
//
//                    self.list_categ_BC.append(categ!)
//                    self.collectionView_BC.reloadData()
//
//
//                    self.last_parent_categ_selected = categ
//
//
//                }
//
//
//                self.list_categ.removeAll()
//                self.list_categ.append(contentsOf: child)
//
//                //             breadCrumb(show: addToBreadCrumb)
//
//
//                self.collectionView.reloadData()
//
//            }
//
//
//
//        }
//
    }
    
    //    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //        delegate?.searchBar(searchBar, textDidChange: searchText)
    //      }
    
    func get_path(categ:pos_category_class,clear:Bool)
    {
        if clear
        {
            self.list_categ_BC.removeAll()
            self.list_categ_BC.append(categ )

        }
        

        
        let parent_categ   = pos_category_class.get_up_category(parent_id: categ.parent_id!)
        if parent_categ != nil
        {
 
                self.list_categ_BC.append(parent_categ!)
                get_path(categ: parent_categ!, clear: false)
 
        }
        
        
        

 
    }
    
    
    
    
}



typealias BreadCrumb = categroiesBC
extension BreadCrumb
{
    
    func numberOfSections_BC(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView_BC(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        adjustPathCollectionWidth()
        return self.list_categ_BC.count
    }
    
    func collectionView_BC(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier_BC, for: indexPath) as! categoryBCCell
        
        //in this example I added a label named "title" into the MyCollectionCell class
        
        let cls =  self.list_categ_BC[indexPath.item]
        
        cell.categ  = cls
        cell.lblTtile.text = cell.categ.name
        
        if indexPath.row == self.list_categ_BC.count - 1
        {
            cell.lblTtile.textColor = UIColor.init(hexString: "#FC7700")
            cell.lblTtile.font =  UIFont.init(name: app_font_name + "-Medium", size: 15)

        }
        else
        {
            cell.lblTtile.textColor = UIColor.init(hexString: "#333333")
            cell.lblTtile.font =  UIFont.init(name: app_font_name + "-Light", size: 15)
        }
        
        return cell
    }
    
    func collectionView_BC(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! categoryBCCell
        
        let categ  = cell.categ!
        
        let count = self.list_categ_BC.count - 1
        


//        if indexPath.row == 0
//        {
//            //            breadCrumb(show: false)
//
//            self.list_categ_BC.removeAll()
//            init_AllCategBC()
//
//            self.collectionView_BC.reloadData()
//
//            getCategory()
//
//            self.getChild(categ: nil,addToBreadCrumb: false)
//
//            expandAllCateg(checkIsExpand:false )
//
//        }
//        else if indexPath.row != count
//        {
            let dif = count - indexPath.row
            self.list_categ_BC.removeLast(dif)
            
            self.collectionView_BC.reloadData()
            
            
            self.getChild(categ: categ,addToBreadCrumb: false)
            //           breadCrumb(show: true)
//        }
        
        
        delegate?.breadcrumbSelected(categ: categ)

    }
    
    func collectionView_BC(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cls =  self.list_categ_BC[indexPath.item]
        return CGSize(width: getWidthLblFor( cls.name), height: 50)
    }
    func getWidthLblFor(_ name:String) -> CGFloat{
        let label = KLabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = name
        label.sizeToFit()
        let widthLbl = label.frame.width + 30
        return widthLbl
    }
    func adjustPathCollectionWidth(){
        var widthPath:CGFloat = 0.0
        for item in self.list_categ_BC {
            widthPath += getWidthLblFor(item.name)
        }
        self.widthPathCollection.constant = widthPath
    }
}


typealias categroies = categroiesBC
extension categroies
{
    func numberOfSections_category(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView_category(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list_categ.count
    }
    
    func collectionView_category(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! categoryCell
        
        //in this example I added a label named "title" into the MyCollectionCell class
        
        let dic:[String:Any] = (self.list_categ[indexPath.item] as? [String:Any])!
        
        cell.categ  = pos_category_class(fromDictionary: dic)
        cell.setText(txt: cell.categ.name)
        
        if cell.categ.id == selected_categ?.id
        {
            cell.view_bg.backgroundColor = UIColor.init(hexString: "#FF7700")
            cell.lblTtile.textColor = UIColor.init(hexString: "#FFFFFF")
        }
        else
        {
            cell.view_bg.backgroundColor = UIColor.white
            cell.lblTtile.textColor = UIColor.init(hexString: "#676767")

        }
        
        
        return cell
    }
    
    func collectionView_category(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! categoryCell
        
        selected_categ  = cell.categ!
        
        if selected_categ?.id == 0
        {
            delegate?.categorySelected(categ: nil)
            
            self.list_categ_BC.removeAll()
            
            init_AllCategBC()
            
            
            getCategory()
            expandAllCateg(checkIsExpand:true )
            //                   self.getChild(categ: nil ,addToBreadCrumb: false)
            
        }
        else
        {
            
            
            self.getChild(categ: selected_categ,addToBreadCrumb: true)
            
            if self.list_categ_BC.count == 1
            {
                collapse()
            }
            else
            {
                expandAllCateg(checkIsExpand:false )
                
            }
            
            if  scroll_direction_vertical == true
            {
                DispatchQueue.main.async {
                guard indexPath.row < collectionView.numberOfItems(inSection: indexPath.section) else {return}
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
            }
            else
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                    guard indexPath.row < collectionView.numberOfItems(inSection: indexPath.section) else {return}
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                })
                
            }
            
            
        }
        
        
        
        
        
    }
    
    func collectionView_category(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 164, height: 151)
    }
}
