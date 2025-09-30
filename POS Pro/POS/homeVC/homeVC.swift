//
//  homeVC.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class homeVC: UIViewController  ,UICollectionViewDataSource ,UICollectionViewDelegate  ,categroiesBC_delegate,menu_left_delegate,UIPopoverPresentationControllerDelegate,price_listVC_delegate,invoicesList_delegate,load_base_apis_delegate ,order_listVc_delegate,order_type_list_delegate,scrap_list_delegate,printer_delegate,disconutOption_delegate,enterBalance_delegate,variant_delegate,UIGestureRecognizerDelegate,promotion_helper_delegate
{
   
    
     
    
 
    
    private let reuseIdentifier = "FlickrCell"
    private let itemsPerRow: CGFloat = 5
    private let sectionInsets = UIEdgeInsets(top: 0.0,
                                             left: 0.0,
                                             bottom:  0.0,
                                             right:  0.0)
    
    @IBOutlet weak var view_collection_container: UIView!
    @IBOutlet weak var lblOrderBadge: KLabel!
    @IBOutlet weak var lblOrderBadge_notSync: KLabel!
    @IBOutlet weak var lblinfo: KLabel!
    @IBOutlet weak var categories: ShadowView!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var btnQty: UIButton!
    @IBOutlet weak var btnDisc: UIButton!
    @IBOutlet weak var btnPrice: UIButton!
    @IBOutlet weak var searchBarProducts: UISearchBar!
    @IBOutlet weak var btnWifi: UIButton!
    @IBOutlet weak var btnPrinter: UIButton!
    @IBOutlet weak var view_orderList: UIView!
    @IBOutlet weak var view_addCustomer: UIView!
    @IBOutlet weak var view_editCustomer: UIView!
    @IBOutlet weak var lblCustmoerPhone: KLabel!
    @IBOutlet weak var lblCustmerName: KLabel!
    @IBOutlet weak var lblcustomerFirstChar: KLabel!
    @IBOutlet weak var btnSelectCustomer: UIButton!
    @IBOutlet weak var btnPayment: KButton!
 @IBOutlet weak var btn_more: KButton!

    @IBOutlet weak var lblOrderID: KLabel!
    @IBOutlet var btn_send_kitchen: KButton!
    @IBOutlet weak var lbl_total_price: KLabel!
    @IBOutlet var lbl_date_time: KLabel!
    
    let con = api()
    let con_sync = api()
    let ordersList = pos_order_helper_class()
    
    
    var refreshControl_collection = UIRefreshControl()
    var keyboard:keyboardVC! = keyboardVC()
    
    private var org_list_product: [Any]! = []
    private var list_product: [[String:Any]]! = []
    private var list_product_search: [Any]! = []
    
    
    var list_order_products:  [pos_order_line_class]! = []
    var getBalance :enterBalance!
    
    var cls_load_all_apis:load_base_apis! = load_base_apis()
    
    var customerVC:customers_listVC! = customers_listVC()
    var priceListVC:price_listVC! = price_listVC()
    var orderTypeVC:order_type_list! = order_type_list()
    
    
//    var comboList_ver2:combo_list_ver2! = combo_list_ver2()
    
    
    var disconut_Option:disconutOption!
    
    var categories_top:categroiesBC! = categroiesBC()
    
    var list_order_created :[pos_order_class]! = []
    var lstInvoices:invoicesList! = invoicesList()
    var payment_Vc:paymentVc!
    
    var selectNewOption:Double = -1
    
    var orderVc:order_listVc!
    var otherPrinter:printersAvalibleClass? = printersAvalibleClass()
    
    var  promotion_helper:promotion_helper_class =  promotion_helper_class()

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //       clearMemory()
        
        remove_notificationCenter()
    }
    
    
    
    func clearMemory()
    {
        keyboard = nil
        org_list_product = nil
        list_product = nil
        list_product_search = nil
        list_order_products = nil
        getBalance = nil
        cls_load_all_apis = nil
        customerVC = nil
        priceListVC = nil
        orderTypeVC = nil
        
//        comboList_ver2 = nil
        disconut_Option = nil
        categories_top = nil
        list_order_created.removeAll()
        lstInvoices = nil
        payment_Vc = nil
        orderVc = nil
        otherPrinter = nil
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        scrollView.zoom()
        
        promotion_helper.delegate = self
        
        
//         FontBlaster.blast { fonts -> Void in
//              print("Loaded Fonts", fonts)
//
//          }
        
        view_addCustomer.isHidden = false
        view_editCustomer.isHidden  = true
        
        lblOrderBadge.layer.cornerRadius = 10
        lblOrderBadge.layer.masksToBounds = true
        
        lblOrderBadge_notSync.layer.cornerRadius = 10
        lblOrderBadge_notSync.layer.masksToBounds = true
        lblOrderBadge_notSync.isHidden = true
        initCollection()
        
        
        initSlideBar()
        
        loadCategories()
        
        
        
        DispatchQueue.main.async {
            self.getProduct()
            
            let pos = pos_config_class.getDefault()
                   if pos.iface_start_categ_id != 0
                   {
                       let categ = pos_category_class.get(id: pos.iface_start_categ_id!)
                       
                    self.categorySelected(categ: categ)
                   }
        }
        
   
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collection?.addGestureRecognizer(lpgr)
        
 
      

    }
    

    
    func loadHome()
    {
        
        //      clsPrinter.delegate = self
        //       clsPrinter.checkStatusPrinter()
        
        // Do any additional setup after loading the view.
        
        //      ordersListClass.clear()
        
        //       orderClass.resetGenerateInviceID()
        
        
        //        initOrder()
        
        
        
        getProduct()
        
        
        
        //      AppDelegate.shared().base_apis.loadAll()
        //        syncOrders()
        
        //  keyboard.delegate = self
        // keyboaed_view.addSubview(keyboard.view)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        init_notificationCenter()
        
        initViewOrderList()
        
        
        var reloadListOrder:Bool = true
        if payment_Vc != nil
        {
            
            reloadListOrder =  payment_Vc.clearHome
        }
        
        if reloadListOrder == true
        {
            showLastOrder()
            readOrder()
            reloadTableOrders()
        }
        
        
        checkCustomerSelected()
        //        checkCategorySelected()
        checkBadgeOrder()
    }
    
    /*
     func checkCategorySelected()
     {
     if categoriesVC.selectedCategory != nil
     {
     
     if categoriesVC.selectedCategory.id == 0
     {
     list_product_search = list_product
     self.collection.reloadData()
     
     return
     }
     
     let searchPredicate = NSPredicate { (dic, _) -> Bool in
     let item = dic as? [String:Any] ?? [:]
     let  pos_categ_id = item["pos_categ_id"] as? [Any]   ?? []
     
     if pos_categ_id.count > 0
     {
     let posid = pos_categ_id[0] as? Int ?? 0
     if  posid == self.categoriesVC.selectedCategory.id
     {
     return true
     }
     }
     
     return false
     }
     
     let array = (self.list_product as NSArray).filtered(using: searchPredicate)
     list_product_search = array
     
     self.collection.reloadData()
     }
     }
     
     
     @IBAction func btnCategory(_ sender: Any) {
     
     let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
     categoriesVC = storyboard.instantiateViewController(withIdentifier: "categories_listVC") as! categories_listVC
     
     self.present(categoriesVC, animated: true, completion: nil)
     }
     
     
     */
    
    func checkBadgeOrder()
    {
        let option   = ordersListOpetions()
        option.Closed = true
        option.orderSyncType = .order
        option.Sync = false
        option.getCount = true
        
        let count = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        
        //       let list = ordersListClass.getOrders_status_sorted(Closed: true, Sync: false)
        if count == 0 {
            lblOrderBadge_notSync.isHidden = true
            btnWifi.setImage(UIImage(named: "wifi"), for: .normal)
        }
        else
        {
            lblOrderBadge_notSync.isHidden = false
            lblOrderBadge_notSync.text = String(count)
            btnWifi.setImage(UIImage(named: "wifi_disable"), for: .normal)
            
        }
        
        
    }
    
    func initViewOrderList()
    {
        if orderVc != nil
        {
            return
        }
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        orderVc = storyboard.instantiateViewController(withIdentifier: "order_listVc") as? order_listVc
        
        //        orderVc = order_listVc()
        orderVc.delegate = self
        orderVc.parent_vc = self

        orderVc.view.frame = view_orderList.bounds
        
        view_orderList.addSubview(orderVc.view)
    }
    
    
    func loadCategories()
    {
        
        //    let frm :CGRect = CGRect.init(x: self.categories.frame.origin.x, y:  self.categories.frame.origin.y
        //        , width:  self.categories.frame.size.width , height: 75)
        
        let storyboard = UIStoryboard(name: "categroies", bundle: nil)
        categories_top = storyboard.instantiateViewController(withIdentifier: "categroiesBC") as? categroiesBC
        
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
 
    }
    
    func categorySelected(categ:pos_category_class?)
    {
        list_product_search.removeAll()
        
        if categ == nil
        {
            list_product_search.append(contentsOf: list_product)
            self.collection.reloadData()
            
            return
        }
        
        //        let allIDS:String = String(categ!.id)
        var parent = false
        categ!.child_id = categ!.getChildIds()
        if categ!.child_id.count > 0
        {
            parent = true
        }
        
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
    }
    
    
    //  func keyboard_returnedValue(Qty:Double,Disc:Double,price:Double,customPrice:Bool,item_indexPath_selected:IndexPath)
    //  {
    //
    //        print("Qty :" , Qty , "Disc :" , Disc , "price :" , price)
    //
    //         let product = order.products![item_indexPath_selected.row]
    //         product.discount = Disc
    //         product.price_app_priceList = price
    //         product.custome_price_app = customPrice
    //         product.qty_app = Qty
    //
    //         order.products![item_indexPath_selected.row] = product
    //
    //         order.saveOrder()
    //
    //        tableview.reloadRows(at: [item_indexPath_selected], with: .fade)
    //        tableview.selectRow(at: item_indexPath_selected, animated: false, scrollPosition: .none)
    //
    //        clacTotal()
    //
    //  }
    
    func pendding_options() -> ordersListOpetions
    {
            let ActiveSession = pos_session_class.getActiveSession()
                
                let session_id = ActiveSession!.id
                
                let opetions = ordersListOpetions()
                opetions.Closed = false
                opetions.Sync = false
                opetions.void = false
                
                
                opetions.sesssion_id = session_id
                opetions.parent_product = true
        //        opetions.parent_orderID = nil
                
                opetions.LIMIT = 10
                opetions.orderDesc = true
        
            opetions.order_by_products = true
        
        if lstInvoices.show_all_orders == false {
            opetions.create_pos_id = pos_config_class.getDefault().id
        }
        
        return opetions
    }
    
    
    func get_order_pendding()  {
        list_order_created.removeAll()
        
    
        
        let arr = pos_order_helper_class.getOrders_status_sorted(options: pendding_options())
        list_order_created.append(contentsOf: arr)
        
        //        list_order_created.append(contentsOf: ordersListClass.getOrders_status(Closed: false, Sync: false,order_Type: .order,session_id: session_id))
        
    }
    
    
    func showLastOrder ()  {
        
        let order_visible_id  = orderVc.order.id
        
        get_order_pendding()
        
        let count = list_order_created.count
        if  count == 0
        {
            setTitleInfo()
            resetOrderView()
            
            orderVc.order = pos_order_class()
            orderVc.resetVales()
            
            //            addNewOrder()
        }
        else
        {
            var index_in = 0
              
            index_in =  list_order_created.firstIndex(where:{  $0.id == order_visible_id} ) ?? 0
                
            
            orderVc.order =  list_order_created[index_in]
            if orderVc.order.pos_order_lines.count != 0
            {
                orderVc.order.cashier = res_users_class.getDefault()
                orderVc.order.session_id_local = pos_session_class.getActiveSession()!.id
            }
            
            readOrder()
       
        }
        
        reloadTableOrders()
        
        
        
    }
    @IBAction func btnCancel_customer(_ sender: Any) {
        
         orderVc.order.customer =  nil
         orderVc.order.save(write_info: true)
               
         customerVC.selectedCustomer = nil
        
        setTitleInfo()
          setupCustomerLayout()
        
     }
    
    func reloadOrders(line:pos_order_line_class?)
    {
        showLastOrder()
        
        if line != nil
        {
            handle_promotion(line: line!)

        }

        
    }
    
    @IBAction func btnDashBoard(_ sender: Any) {
        
        AppDelegate.shared().loadDashboard()
        
    }
    
    @IBAction func btnWifi(_ sender: Any) {
        checkBadgeOrder()
    }
    
    func checkCustomerSelected()
    {
        if customerVC.selectedCustomer != nil
        {
            //            orderCls.setCustomer(fromDictionary: customerVC.selectedCustomer.toDictionary())
            
            if orderVc.order.id == nil
            {
                orderVc.order = pos_order_helper_class.creatNewOrder()
                readOrder()
                
                reloadTableOrders()
            }
            
            
            if  customerVC?.selectedCustomer.property_product_pricelist_id != 0
            {
                let pricelist_id = customerVC?.selectedCustomer.property_product_pricelist_id ?? 0
                let pricelist = product_pricelist_class.get_pricelist(pricelist_id: pricelist_id)
                if pricelist != nil
                {
                    orderVc?.order.priceList = pricelist
                    orderVc?.priceList = pricelist
                    
                    
              
                }
            }
            
            
            orderVc.order.customer = customerVC.selectedCustomer
            orderVc.order.save()
            
            reloadTableOrders(re_calc: false)
            
            
//            btnSelectCustomer.setTitle(customerVC.selectedCustomer.name  , for: .normal)
            
            customerVC.selectedCustomer = nil
            
            
            
        }
        
        
              setTitleInfo()
        setupCustomerLayout()
        
    }
    
    func setupCustomerLayout()
    {
        if orderVc.order.customer != nil
        {
//            lblCustmerName.text = orderVc.order.customer?.name ?? ""
//            lblCustmoerPhone.text = orderVc.order.customer?.phone ?? ""
//
//            let char = orderVc.order.customer?.name.prefix(1) ?? ""
//            lblcustomerFirstChar.text = String(char)
//
//            view_addCustomer.isHidden = true
//            view_editCustomer.isHidden = false
            
            btnSelectCustomer.setTitle("Cancel", for: .normal)
        }
        else
        {
//            view_addCustomer.isHidden = false
//            view_editCustomer.isHidden = true
               btnSelectCustomer.setTitle("Customer", for: .normal)
        }
    }
    
    func order_selected(order_selected:pos_order_class)
    {
        orderVc.order = order_selected
        
        readOrder()
        
        reloadTableOrders()
        
        pageCurl_fromLeft()
    }
    
    
    func order_deleted(order_selected:pos_order_class)
    {
        
        get_order_pendding()
        
        if order_selected.id == orderVc.order.id
        {
            if list_order_created.count > 0
            {
                orderVc.order = list_order_created[0]
                //                orderVc.order = ordersListClass.getOrder(orderID: obj.id)
                readOrder()
                
                reloadTableOrders()
            }
            else
            {
                orderVc.order = pos_order_class()
                orderVc.resetVales()
                //                orderVc.tableview.reloadData()
                readOrder()
                reloadTableOrders()
            }
            
        }
        else if order_selected.id == nil
        {
            resetOrderView()
        }
        
        
        
        checkBadge()
        pageCurl_fromRight()
        
    }
    
    @IBAction func btnReloadAllApis(_ sender: Any) {
        
//        let storyboard = UIStoryboard(name: "apis", bundle: nil)
//        cls_load_all_apis = storyboard.instantiateViewController(withIdentifier: "load_base_apis") as? load_base_apis
//
//        cls_load_all_apis.delegate = self
//        cls_load_all_apis.userCash = .stopCash
//
//        self.present(cls_load_all_apis, animated: true, completion: nil)
//
//        cls_load_all_apis.runQueue()
        
        
        
        let alert = UIAlertController(title: "Option", message: "Sync mode.", preferredStyle: .alert)
              
              
              alert.addAction(UIAlertAction(title: "Get New only", style: .default, handler: { (action) in
                  
                self.sync(get_new: true)
                 
                  
              }))
        
             alert.addAction(UIAlertAction(title: "Reload all", style: .default, handler: { (action) in
                   
                   self.sync(get_new: false)

                  
                   
               }))
              
              alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
                  
              }))
              
           
        self.present(alert, animated: true, completion: nil)
              
        
        
    }
    
    func sync(get_new:Bool)
       {
           let storyboard = UIStoryboard(name: "apis", bundle: nil)
        cls_load_all_apis = storyboard.instantiateViewController(withIdentifier: "load_base_apis") as? load_base_apis
             
             cls_load_all_apis.delegate = self
             cls_load_all_apis.userCash = .stopCash
             cls_load_all_apis.forceSync = true
             cls_load_all_apis.get_new = get_new
             self.present(cls_load_all_apis, animated: true, completion: nil)
             
             cls_load_all_apis.startQueue()
       }
    
    func isApisLoaded(status:Bool)
    {
        cls_load_all_apis?.dismiss(animated: true, completion: nil)
        
        getProduct()
        
        categories_top.viewDidLoad()
    }
    
    
    func addNewOrder()
    {
        orderVc.order = pos_order_helper_class.creatNewOrder()
        //        get_order_pendding()
        showLastOrder()
        readOrder()
        reloadTableOrders()
    }
    
    @IBAction func btnAddNewOrder(_ sender: Any) {
        
        //        lblinfo.text = "Order list"
        
        addNewOrder()
        
        pageCurl_fromRight()
    }
    
    func pageCurl_fromRight()
    {
        UIView.animate(withDuration: 1.0, animations: {
            let animation = CATransition()
            animation.duration = 1.0
            animation.startProgress = 0.0
            animation.endProgress = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.type = CATransitionType(rawValue: "pageCurl")
            animation.subtype = CATransitionSubtype(rawValue: "fromRight")
            animation.isRemovedOnCompletion = false
            animation.fillMode = CAMediaTimingFillMode(rawValue: "extended")
            self.view.layer.add(animation, forKey: "pageFlipAnimation")
            //            self.animatedUIView.addSubview(tempUIView)
        })
    }
    func  pageCurl_fromLeft()
    {
        UIView.animate(withDuration: 1.0, animations: {
            let animation = CATransition()
            animation.duration = 1.0
            animation.startProgress = 0.0
            animation.endProgress = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.type = CATransitionType(rawValue: "pageCurl")
            animation.subtype = CATransitionSubtype(rawValue: "fromLeft")
            animation.isRemovedOnCompletion = false
            animation.fillMode = CAMediaTimingFillMode(rawValue: "extended")
            self.view.layer.add(animation, forKey: "pageFlipAnimation")
            //            self.animatedUIView.addSubview(tempUIView)
        })
    }
    
    
    
    @IBAction func btnShowListOrder(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        lstInvoices = storyboard.instantiateViewController(withIdentifier: "invoicesList") as? invoicesList
        lstInvoices.modalPresentationStyle = .popover
        //        invoices_List.delegate = self
        lstInvoices.preferredContentSize = CGSize(width: 460, height: 700)
        lstInvoices.delegate = self
        lstInvoices.option.sesssion_id = pos_session_class.getActiveSession()!.id
        lstInvoices.option.Closed = false
        lstInvoices.option.Sync = false
        lstInvoices.option.void = false
        
        //        lstInvoices.parent_id = "all"
        
        let popover = lstInvoices.popoverPresentationController!
        //        popover.delegate = self
        popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(lstInvoices, animated: true, completion: nil)
        
    }
    
    @IBAction func btnSelectCustomer(_ sender: Any) {
        
        if orderVc.order.id == nil
        {
            addNewOrder()
        }
        
         if orderVc.order.customer != nil
         {
            
            btnCancel_customer(sender)
            
             return
         }
        
        let storyboard = UIStoryboard(name: "customers", bundle: nil)
        customerVC = storyboard.instantiateViewController(withIdentifier: "customers_listVC") as? customers_listVC
        customerVC.modalPresentationStyle = .fullScreen
        customerVC.selectedCustomer = nil
        self.present(customerVC, animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnPriceList(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        priceListVC = storyboard.instantiateViewController(withIdentifier: "price_listVC") as? price_listVC
        priceListVC.modalPresentationStyle = .popover
        priceListVC.delegate = self
        
        let popover = priceListVC.popoverPresentationController!
        //        popover.delegate = self
        popover.permittedArrowDirections = .left //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(priceListVC, animated: true, completion: nil)
        
        
    }
    
    func priceListSelected()
    {
        
        if priceListVC.selectedItem != nil
        {
            orderVc.order.priceList = priceListVC.selectedItem
            orderVc.priceList = priceListVC.selectedItem
            orderVc.order.applyPriceList()
            orderVc.order.save()
            
            //            let text =  priceListVC.selectedItem
            //            lblinfo.text = "Price list :" +  priceListVC.selectedItem.name!
            
            setTitleInfo()
            
            orderVc.tableview.reloadData()
            collection.reloadData()
            
            reloadTableOrders(re_calc: false)

            priceListVC.selectedItem = nil
        }
        
        menu_left.closeMenu()
        
    }
    
    
    
    
    
    @IBAction func btnOrderTypeList(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        orderTypeVC = storyboard.instantiateViewController(withIdentifier: "order_type_list") as? order_type_list
        orderTypeVC.modalPresentationStyle = .popover
        orderTypeVC.delegate = self
        
        let popover = orderTypeVC.popoverPresentationController!
        //        popover.delegate = self
        popover.permittedArrowDirections = .left //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = btn_more //sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(orderTypeVC, animated: true, completion: nil)
        
        
    }
    
    func order_typeSelected()
    {
        
           btn_send_kitchen.isEnabled = true
                 btn_send_kitchen.alpha = 1
        
        
        if orderTypeVC.selectedItem != nil
        {
            NSLog("\n\n\n\n\n\n%@" , orderTypeVC.selectedItem.name )
            
            
            if orderVc.order.id == nil
            {
                orderVc.order = pos_order_helper_class.creatNewOrder()
                readOrder()
                reloadTableOrders()
            }
            
            
            if orderTypeVC.selectedItem.id == 0
            {
                orderVc.order.orderType = nil
                orderVc.order.priceList = nil
                self.orderVc.priceList = nil
                
                self.lblinfo.text = ""
                //                    btnSelectOrderType.setTitle("Order type", for: .normal)
                
                orderVc.order.save()
                orderVc.tableview.reloadData()
                collection.reloadData()
                reloadTableOrders(re_calc: false)
                orderTypeVC.selectedItem = nil
                
                
                
            }
            else
            {
                
                
                getPriceList_In_OrderType(orderType: orderTypeVC.selectedItem)
                
                
            }
            
            
        }
        
        NSLog("\n\n\n\n\n\n%@" , self.orderVc.order.orderType?.name ?? "")
        doPayment()
    }
    
    
    
    func getPriceList_In_OrderType(orderType: delivery_type_class!)
    {
        let pricelist_id:Int = orderType.pricelist_id
        let get_product_pricelist_arr:[[String:Any]] = product_pricelist_class.getAll() //  api.get_last_cash_result(keyCash: "get_product_pricelist")
        if  get_product_pricelist_arr.count > 0
        {
            
            for item:[String:Any] in get_product_pricelist_arr
            {
                let id = item["id"] as? Int ?? 0
                if id == pricelist_id
                {
                    self.orderVc.order.priceList = product_pricelist_class(fromDictionary: item)
                    self.orderVc.priceList = self.orderVc.order.priceList
                    self.lblinfo.text = "Price list :" +  self.orderVc.order.priceList!.name!
                }
            }
            
            self.orderVc.order.orderType = orderType
            
            
            if self.orderVc.order.orderType!.order_type == "delivery"
            {
                let delivery_product  = delivery_type_class.getDeliveryProduct()
                
                
                //                let arr =  api.get_last_cash_result(keyCash: "delivery_produc")
                if delivery_product.id != 0
                {
                    //                    let delivery_product = arr[0] as! [String:Any]
                    //                    self.orderVc.order.orderType!.delivery_product = product_product_class.getProduct(ID: delivery_product.id)
               
                    let product = product_product_class.get(id: delivery_product.delivery_product_id)
                    if product != nil
                    {
                        
                        self.orderVc.order.orderType!.delivery_product_id = delivery_product.id
                        
                        let d_product = pos_order_line_class.get_or_create(order_id: self.orderVc.order.id!, product:product!)
                        d_product.product = product
                        d_product.update_values()
                        _ = d_product.save()
                        
                        self.orderVc.order.delivery_amount = orderType.delivery_amount //d_product.get_price()
                    }
             
                        
               
                    
                   
                    
                    //productClass(fromDictionary: delivery_product)
                    //                    self.orderVc.order.orderType!.delivery_product?.product.priceList = self.orderVc.priceList
//                    self.orderVc.order.orderType!.delivery_product?.update_values()
                }
            }
            
            self.orderVc.order.save(write_info: true, updated_session_status: .last_update_from_local, re_calc: true)
            self.orderVc.tableview.reloadData()
            self.collection.reloadData()
            reloadTableOrders(re_calc: false)
            self.orderTypeVC.selectedItem = nil
        }
    }
    
    var orderTypePayment = false
    @IBAction func btnPayment(_ sender: Any)
    {
        if orderVc.order.id == nil
        {
            return
        }
        
        orderVc.order.amount_return =  0
        orderVc.order.amount_paid =  0
        
        if  orderVc.order.amount_total < 0
        {
            orderVc.order.amount_return =  orderVc.order.amount_total * -1
            orderVc.order.amount_paid =  orderVc.order.amount_total
            
            orderVc.order.calcAll()
            orderVc.order.save()
            
            
            openPayment()
        }
        else if settingClass.getSettingClass().enable_OrderType_InPayment == false
        {
            if orderVc.order.orderType == nil
            {
                let default_pricelist = product_pricelist_class.getDefault()
                if orderVc.order.pricelist_id == default_pricelist!.id // no custom price list
                {
                    let defalut_orderType = delivery_type_class.getDefault()
                    if defalut_orderType != nil
                    {
                        getPriceList_In_OrderType(orderType: defalut_orderType)
                    }
                }
                
                
            }
            
            
            openPayment()
        }
        else
        {
            if orderVc.order.orderType == nil
            {
                let default_pricelist = product_pricelist_class.getDefault()
                if orderVc.order.pricelist_id == default_pricelist!.id // no custom price list
                {
                    
                    let list:[[String:Any]] = delivery_type_class.getAll()
                    if list.count == 0
                    {
                        openPayment()
                    }
                    else
                    {
                        orderTypePayment = true
                        btnOrderTypeList(sender)
                    }
                }
                else
                {
                    openPayment()
                }
            }
            else
            {
                openPayment()
            }
            
        }
        
        
        
    }
    
    func doPayment()
    {
        if orderTypePayment == false
        {
            return
        }
        
        orderTypePayment = false
        
        if orderVc.order.pos_order_lines.count == 0
        {
            MessageView.show("Please add product.")
            return
        }
        
        openPayment()
        
        
    }
    
    func openPayment()
    {
        //        if payment_Vc == nil
        //        {
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        payment_Vc = storyboard.instantiateViewController(withIdentifier: "paymentVc") as? paymentVc
        //        }
        
        payment_Vc.clearHome = false
        payment_Vc.orderVc!.order = orderVc.order
        
        let activeSession = pos_session_class.getActiveSession()
        payment_Vc.orderVc!.order.session_id_local = activeSession!.id
        
        if payment_Vc != nil
        {
            payment_Vc.viewDidLoad()
        }
        self.navigationController?.pushViewController(payment_Vc, animated: true)
    }
    
    //    Scrap
    @IBAction func btnMore(_ sender: Any)
    {
        
        if orderVc.order.id == nil
        {
            return
        }
        
        
        let alert = UIAlertController(title: "More", message: "Pleas select action.", preferredStyle: .actionSheet)
        
     
        
        let pos = pos_config_class.getDefault()
        
        if  orderVc.order.amount_total > 0
        {
            let price_list:[[String:Any]] = product_pricelist_class.getAll()  // api.get_last_cash_result(keyCash:"get_product_pricelist")
            
            if price_list.count > 1
            {
                alert.addAction(UIAlertAction(title: "Price list" , style: .default, handler: { (action) in
                    
                    self.btnPriceList(sender)
                    
                }))
            }
            
            let ordertype_list:[[String:Any]] = delivery_type_class.getAll()  //api.get_last_cash_result(keyCash:"get_order_type")
            
            if ordertype_list.count > 1
            {
                alert.addAction(UIAlertAction(title: "Order type" , style: .default, handler: { (action) in
                    
                    self.btnOrderTypeList(sender)
                    
                }))
            }
            
            if pos.allow_discount_program == true
            {
                alert.addAction(UIAlertAction(title: "Discount" , style: .default, handler: { (action) in
                    
                    self.btnDiscount(sender)
                    
                }))
                
            }
            
            let line_discount = self.orderVc.order.get_discount_line()
            if line_discount != nil
            {
                alert.addAction(UIAlertAction(title: "Cancel Discount" , style: .default, handler: { (action) in
                    
//                    self.orderVc.order.discount_program_id = 0
//                    self.orderVc.order.discount = 0
                 
                    line_discount?.is_void = true
                  _ =  line_discount?.save(write_info: true, updated_session_status: .last_update_from_local)
//                    pos_order_line_class.delete_line(line_id: line_discount!.id)
                    
                    //                    self.orderVc.order.discountProgram!.discount_product?.update_values()
                    self.orderVc.order.save(write_info: true, updated_session_status: .last_update_from_local, re_calc: true)
                    self.reloadTableOrders(re_calc: false)
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                }))
            }
            
            
            
            alert.addAction(UIAlertAction(title: "Scrap" , style: .default, handler: { (action) in
                
                self.btnScrap(AnyClass.self)
                
            }))
            
        }
        
        alert.addAction(UIAlertAction(title: "Add order note", style: .default, handler: { (action) in
            if self.orderVc.order.pos_order_lines.count == 0
            {
                MessageView.show("Please add product.")
                return
            }
            
            self.add_note(product: nil)
        }))
        
        
        alert.addAction(UIAlertAction(title: "void", style: .default, handler: { (action) in
                  self.orderVc.order.is_void = true
                     self.orderVc.order.save(write_info: true,updated_session_status: .last_update_from_local)
                     self.order_deleted(order_selected: self.orderVc.order)
            
           }))
        
        //        alert.addAction(UIAlertAction(title: "Cash in" , style: .default, handler: { (action) in
        //
        //
        //            self.cash_in_out(cash_out: false)
        //
        //        }))
        //
        //        alert.addAction(UIAlertAction(title: "Cash out" , style: .default, handler: { (action) in
        //            self.cash_in_out(cash_out: true)
        //        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        
 
        alert.popoverPresentationController?.permittedArrowDirections = .left //UIPopoverArrowDirection(rawValue: 0)
        alert.popoverPresentationController?.sourceView = sender as? UIView
        alert.popoverPresentationController?.sourceRect =  (sender as AnyObject).bounds
        
        //        alert.popoverPresentationController?.sourceView = sender as? UIView// works for both iPhone & iPad
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func cash_in_out(cash_out:Bool)
    {
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "cash_in_out") as! cash_in_out
        vc.cash_out = cash_out
        
        
        vc.modalPresentationStyle = .overFullScreen
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func add_note(product:product_product_class?)
    {
        //        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "product_note") as! product_note
        //
        //        vc.orderVc.order = orderVc.order
        //        vc.delegate = self
        //
        //        vc.modalPresentationStyle = .overFullScreen
        //
        //        self.present(vc, animated: true, completion: nil)
        
//        let storyboard = UIStoryboard(name: "notes", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "product_note_qty") as! product_note_qty
//        
//        vc.delegate = self
//        vc.order = orderVc.order
//        
//        vc.modalPresentationStyle = .popover
//        
//        let popover = vc.popoverPresentationController!
//        popover.sourceView = view_orderList
//        popover.sourceRect = view_orderList.frame
//        
//        self.present(vc, animated: true, completion: nil)
    }
    
    func note_added(line: pos_order_line_class?) {
        
        orderVc.reload_footer()
        
        btn_send_kitchen.isEnabled = true
            btn_send_kitchen.alpha = 1
        
    }
    
    func no_notes()
    {
        
    }
    
    @IBAction func btnDiscount(_ sender: Any)
    {
        let alert = UIAlertController(title: "Discount", message: "Pleas select action.", preferredStyle: .alert)
        
        
        let arr_discount = pos_discount_program_class.getAll()  // api.get_last_cash_result(keyCash: "get_discount_program")
        if arr_discount.count > 0
        {
            alert.addAction(UIAlertAction(title: "Fixed" , style: .default, handler: { (action) in
                
                
                let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
                self.disconut_Option = storyboard.instantiateViewController(withIdentifier: "disconutOption") as? disconutOption
                self.disconut_Option.dicountType = .fixed
                self.disconut_Option.delegate = self
                self.disconut_Option.modalPresentationStyle = .popover
                
                let popover =  self.disconut_Option.popoverPresentationController!
                //        popover.delegate = self
                //            popover.permittedArrowDirections = .down //UIPopoverArrowDirection(rawValue: 0)
                popover.sourceView = sender as? UIView
                popover.sourceRect =  (sender as AnyObject).bounds
                //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                
                
                self.present( self.disconut_Option, animated: true, completion: nil)
                
                
                
                alert.dismiss(animated: true, completion: nil)
            }))
            
            
            alert.addAction(UIAlertAction(title: "Percentage" , style: .default, handler: { (action) in
                
                let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
                self.disconut_Option = storyboard.instantiateViewController(withIdentifier: "disconutOption") as? disconutOption
                self.disconut_Option.dicountType = .percentage
                self.disconut_Option.delegate = self
                self.disconut_Option.modalPresentationStyle = .popover
                
                let popover = self.disconut_Option.popoverPresentationController!
                //        popover.delegate = self
                //            popover.permittedArrowDirections = .down //UIPopoverArrowDirection(rawValue: 0)
                popover.sourceView = sender as? UIView
                popover.sourceRect =  (sender as AnyObject).bounds
                //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                
                
                self.present(self.disconut_Option, animated: true, completion: nil)
                
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Custom" , style: .default, handler: { (action) in
            
            let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
            self.getBalance = storyboard.instantiateViewController(withIdentifier: "enterBalance") as? enterBalance
            self.getBalance.modalPresentationStyle = .popover
            //        invoices_List.delegate = self
            self.getBalance.preferredContentSize = CGSize(width: 400, height: 715)
            self.getBalance.delegate = self
            self.getBalance.key = "custom_discount"
            
            let popover = self.getBalance.popoverPresentationController!
            //        popover.delegate = self
            //            popover.permittedArrowDirections = .left //UIPopoverArrowDirection(rawValue: 0)
            popover.sourceView = sender as? UIView
            popover.sourceRect =  (sender as AnyObject).bounds
            //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            
            self.present(self.getBalance, animated: true, completion: nil)
            
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        
        alert.addAction(UIAlertAction(title: "Cancel" , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func newBalance(key:String,value:String)
    {
        let productDiscount = pos_discount_program_class.get_discount_product()
        if  productDiscount != nil
        {
            if  value.toDouble() ?? 0 > orderVc.order.amount_total
            {
                MessageView.show_in_view("Discout is higvher than bill value", view: self.view)
                
            }
            else
            {
          
//                let currency = productDiscount!.product.currency_name ?? ""
                
//                let disocunt =  pos_discount_program_class()
////                disocunt.discount_product = productDiscount
//                disocunt.name = value + " " + currency
//                disocunt.amount = value.toDouble() ?? 0
//                disocunt.dicount_type = "fixed"
//
//
//                orderVc.order.discount_program_id = 0
//                orderVc.order.discount = -1 * (value.toDouble() ?? 0)
//                orderVc.order.discountProgram!.discount_product?.update_values()
                
                add_discount(value: -1 * (value.toDouble() ?? 0), is_fixed: true, product_discount: (productDiscount?.product)!)
              
                reloadTableOrders(re_calc: false)
            }
            
            
        }
    }
    
    
    func disconutOption_selected(disocunt:pos_discount_program_class)
    {
        let productDiscount = pos_discount_program_class.get_discount_product()
        if  productDiscount != nil
        {
            if disocunt.dicount_type == "fixed" && disocunt.amount > orderVc.order.amount_total
            {
                MessageView.show_in_view("Discout is higvher than bill value", view: self.view)
                
            }
            else if  disocunt.dicount_type == "fixed" && disocunt.amount < orderVc.order.amount_total
            {
                add_discount(value: -1 * disocunt.amount  , is_fixed: true, product_discount: (productDiscount?.product)!)
                reloadTableOrders(re_calc: false)
                
            }
            else if  disocunt.dicount_type == "percentage" && disocunt.amount < orderVc.order.amount_total
            {
                add_discount(value: -1 * disocunt.amount  , is_fixed: false, product_discount: (productDiscount?.product)!)
                reloadTableOrders(re_calc: false)
            }
            else
            {
                
                
                //                disocunt.discount_product = productDiscount
                
                //                orderVc.order.discountProgram = disocunt
                //                orderVc.order.discountProgram!.discount_product?.update_values()
                //                orderVc.order.save()
                //                reloadTableOrders(re_calc: false)
            }
            
        }
        
    }
    
    func add_discount( value:Double,is_fixed:Bool ,product_discount:product_product_class )
    {
        let line_discount = pos_order_line_class.get_or_create(order_id: orderVc.order.id!, product: product_discount)
                   line_discount.product = product_discount
                   line_discount.order_id = orderVc.order.id!
        
        
        if is_fixed
        {
           
             line_discount.product.lst_price = value
             line_discount.price_unit = value
             line_discount.update_values()
             
        }
        else
        {
             let discount_value = get_discount_percentage_value(percentage_value: value)
             line_discount.product.lst_price = discount_value
                   line_discount.price_unit = discount_value
                   line_discount.update_values()
        }

        _ =  line_discount.save(write_info: true, updated_session_status: .last_update_from_local)

        orderVc.order.save(write_info: true, updated_session_status: .last_update_from_local, re_calc: true)
    }
     
    func get_discount_percentage_value( percentage_value:Double) -> Double
    {
        var discount_value:Double  = 0
 
        for line in orderVc.order.pos_order_lines
        {
            let price_subtotal = line.price_subtotal
            let percentage = (price_subtotal! * percentage_value) / 100
            
            discount_value = discount_value + percentage
        }
        
        return discount_value
    }
    
    @IBAction func btnScrap(_ sender: Any)
    {
        if orderVc.order.pos_order_lines.count == 0
        {
            MessageView.show("Please add product.")
            return
        }
        
        let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "scrap_list") as! scrap_list
        
        vc.orderVc.order = orderVc.order
        vc.delegate = self
        
        let activeSession = pos_session_class.getActiveSession()
        vc.orderVc.order.session_id_local = activeSession!.id
        
        //        vc.preferredContentSize = CGSize(width: 800, height: 700)
        
        
        //        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .overFullScreen
        
        
        //        let popover = vc.popoverPresentationController!
        //        //        popover.delegate = self
        //        popover.permittedArrowDirections = .down //UIPopoverArrowDirection(rawValue: 0)
        //        popover.sourceView = sender as? UIView
        //        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func initSlideBar()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.MainView = self
        if (appDelegate.settingTheSideMenu == false)
        {
            appDelegate.settingTheSideMenu = true
            
            
        }
        
        
        
    }
    
 
    @IBAction func btnPrinter(_ sender: Any) {
        //        loadingClass.show(view: self.view)
        let Epos_printer = AppDelegate.shared().getDefaultPrinter()
        
        Epos_printer.checkStatusPrinter()
    }
    

    
    func printer_status(online:Bool)
    {
        if online == true
        {
            btnPrinter.setImage(UIImage(named: "printer"), for: .normal)
        }
        else
        {
            btnPrinter.setImage(UIImage(named: "printer_disable"), for: .normal)
        }
        
    }
    
    
    @IBAction func btnOpenMenu(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    
    @IBAction func btn_show_tables(_ sender: Any) {
 
        let storyboard = UIStoryboard(name: "TableManagement", bundle: nil)
          let vc = storyboard.instantiateViewController(withIdentifier: "TableManagementViewController") as! TableManagementViewController
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true, completion: nil)
        
    }
    @IBAction func unwindToHomeViewController(segue: UIStoryboardSegue) {
           if let source = segue.source as? TableManagementViewController {
               if orderVc.order.id == nil {
                      addNewOrder()
               }
               
               orderVc.order.floor_name = source.selectedTable?.floor_name
               orderVc.order.table_name = source.selectedTable?.name ?? ""
               
            
            orderVc.order.save(write_info: true, updated_session_status: .sending_update_to_server, kitchenStatus: .send)
           }
       }
    
    func combo_list_selected(line:pos_order_line_class)
    {
        
        
        
        if line.combo_edit == false
        {
            _ =  self.add_product(line: line,new_qty: line.qty,check_by_line: true)
            
        }
        else
        {
           _ =  self.saveProduct(line: line , rowIndex: line.index)
            
            self.readOrder();
            
            
            self.orderVc.tableview.selectRow(at: IndexPath.init(row: line.index, section: 0), animated: true, scrollPosition: .middle)
            
        }
        
        
        
    }
    
    @IBAction func btn_add_notes(_ sender: Any) {
        self.add_note(product: nil)
    }
    
    @IBAction func btn_to_kitchen(_ sender: Any) {
         
//        for line in orderVc.order.pos_order_lines
//        {
//            if line.kitchen_status != .done
//            {
//                line.kitchen_status = .send
//            }
//
//            line.pos_multi_session_status = .sending_update_to_server
//
//           _ = line.save(write_info: false)
//        }
//
//        orderVc.order.save(write_info: true)
        
        orderVc.order.save_and_send_to_kitchen()
        
        orderVc.tableview.reloadData()
        
        btn_send_kitchen.isEnabled = false
        btn_send_kitchen.alpha = 0.5
        
        
        DispatchQueue.global(qos: .background).async {
//            if self.orderVc.order!.amount_total > 0.0
//              {

                self.otherPrinter!.printToAvaliblePrinters(Order: self.orderVc.order)
                  
//              }
        }
        
        
    }
    
    
}

typealias search_products = homeVC
extension search_products : UISearchBarDelegate
{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            //            self.collectionView?.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!searchText.isEmpty){
            //reload your data source if necessary
            //            self.collectionView?.reloadData()
            
            //             if searchText == "enable_log_2020"
            //             {
            //                myuserdefaults.setitems("enable", setValue: "yes", prefix: "btnLog")
            //             }
            
            let searchPredicate = NSPredicate { (dic, _) -> Bool in
                let item = dic as? [String:Any] ?? [:]
                let  original_name = item["original_name"] as? String ?? ""
                let  barcode = item["barcode"] as? String ?? ""
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
                
                if  (search_txt  ).contains( searchText.lowercased())
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
    
}

typealias product_list = homeVC
extension product_list
{
    func initCollection()   {
        
        //        refreshControl_collection.attributedTitle = NSAttributedString(string: "Pull to refresh")
        //        refreshControl_collection.addTarget(self, action: #selector(refreshCollection(sender:)), for: UIControl.Event.valueChanged)
        //        collection.addSubview(refreshControl_collection) // not required when using UITableViewContr
    }
    
    @objc func refreshCollection(sender:AnyObject) {
        // Code to refresh table view
        
        con.userCash = .stopCash
        getProduct()
        
    }
    
    func getProduct()
    {
        self.org_list_product = product_product_class.getMainProduct()  // api.get_last_cash_result(keyCash: "Items_by_POS_Category2") as? [[String:Any]] ?? [[:]]
        self.filterProducts(list: self.org_list_product)
        
         
        
        
        //        loadingClass.show()
        //
        //        con.userCash = .useCash
        //
        //        con.get_Items_by_POS_Category { (results) in
        //            self.refreshControl_collection.endRefreshing()
        //            loadingClass.hide()
        //
        //            if (!results.success)
        //            {
        //                return
        //            }
        //
        //            let response = results.response
        //            //            let header = results.header
        //
        //            self.org_list_product = response?["result"] as? [Any] ?? []
        //            self.filterProducts(list: self.org_list_product)
        //
        //
        //        }
    }
    
    func filterProducts(list:[Any])
    {
        self.list_product = list as? [[String : Any]]
        
        if     self.list_product.count > 0
        {
            let obj =  self.list_product?[0]["invisible_in_ui"]
            
            if obj != nil
            {
                self.list_product = self.list_product.filter{$0["invisible_in_ui"]! as? Int == 0}
            }
        }
        
        
        //
        //         self.list_product.removeAll()
        //
        //         for item in list
        //         {
        //            let dic = item as? [String:Any]
        //            let invisible_in_ui = dic!["invisible_in_ui"] as? Bool ?? false
        //
        //            if invisible_in_ui == false
        //            {
        //                self.list_product.append(dic!)
        //            }
        //
        //         }
        
        
        let setting = settingClass.getSettingClass()
        
        if setting.show_all_products_inHome
        {
            self.list_product_search.removeAll()
            self.list_product_search.append(contentsOf:  self.list_product )
            
            self.collection?.reloadData()
        }
        
    }
 


}

typealias order_list = homeVC
extension order_list
{
    
    
    
    func checkBadge()
    {
        
        let ActiveSession = pos_session_class.getActiveSession()
        
        let session_id = ActiveSession!.id
        
        let opetions = ordersListOpetions()
        opetions.Closed = false
        opetions.Sync = false
        opetions.void = false
        
        opetions.sesssion_id = session_id
        opetions.parent_orderID = nil
        
        
        
        let count  = pos_order_helper_class.getOrders_status_sorted_count(options: opetions)
        if count == 0
        {
            lblOrderBadge.isHidden = true
        }
        else
        {
            lblOrderBadge.isHidden = false
            lblOrderBadge.text = String(count)
            
        }
        
    }
    
    func resetOrderView()
    {
        
        lblOrderID.text = "#"
        
        orderVc.order = pos_order_class()
        orderVc.resetVales()
        orderVc.tableview.reloadData();
        orderVc.refreshControl_tableview.endRefreshing()
        
        
    }
    
    
   
    

    
    
    func set_total_ui()
    {
        let total = baseClass.currencyFormate(orderVc.order.amount_total )
        let currency = pos_config_class.getDefault().currency_name ?? ""

         lbl_total_price.text = total  + " " + currency
        
        //        btnPayment.setTitle(String(format: "Payment (%@)", total), for: .normal)

    }
    
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        readOrder()
        reloadTableOrders()
        
    }
    
 
   
    
    func reloadTableOrders(re_calc:Bool = false)
    {
        if orderVc.order.pos_order_lines.count == 0 {
            
            orderVc.order.total_items = 0
            orderVc.order.amount_total = 0
            
        }
        
        
        if re_calc == true
        {
            orderVc.order.calcAll()
        }
        
      
        
        set_total_ui()
        
        orderVc.reload_footer()
        orderVc.tableview.reloadData()
        orderVc.refreshControl_tableview.endRefreshing()
        
      self.check_kitchen()
    }
    
    
    @objc func readOrder()   {
        
        if orderVc.order.id == nil
        {
            resetOrderView()
            
            return
        }
         
        
        
        setTitleInfo()
        
       
        checkBadge()
        
        
        if orderVc.order.sequence_number == 0
        {
            lblOrderID.text = "#"
        }
        else
        {
//            if orderVc.order.sequence_number_server != 0
//            {
//                lblOrderID.text = String(format: "#%d", orderVc.order.sequence_number_server)
//            }
//            else
//            {
//                lblOrderID.text = String(format: "#%d", orderVc.order.sequence_number)
//
//            }
        }
        
        
        list_order_products  =  orderVc.order.pos_order_lines
        
//        btnSelectCustomer.setTitle(orderVc.order.customer?.name ?? "Select  Customer", for: .normal)
 
        
        setupCustomerLayout()
        
        check_kitchen()
      
     
        
    }
    
    func check_kitchen()
    {
        let multi_session_id = pos_config_class.getDefault().multi_session_id  ?? 0
        if multi_session_id == 0
        {
            btn_send_kitchen.isHidden = true
            return
        }
        
        guard let _ = orderVc.order.id else {
            return
        }
        
        if orderVc.order.get_order_status() == .changed
        {
            btn_send_kitchen.isEnabled = true
            btn_send_kitchen.alpha = 1
        }
        else
        {
            btn_send_kitchen.isEnabled = false
            btn_send_kitchen.alpha = 0.5
        }
    }
    
    func setTitleInfo()
    {
          lblinfo.text =  ""
        
        if orderVc.order.priceList != nil
        {
            let def = product_pricelist_class.getDefault()
            if def!.id != orderVc.order.pricelist_id
            {
                lblinfo.text = "Price list : " +  orderVc.order.priceList!.name!
            }
            
        }
        else
        {
            lblinfo.text = ""
        }
        
        if orderVc.order.create_date != nil
        {
            let dt = Date(strDate: orderVc.order.create_date!, formate: baseClass.date_fromate_server ).toString(dateFormat:"yyyy-MM-dd / hh:mm a", UTC: false)
            
                 lbl_date_time.text = String(format: "%@"  , dt)
            
//            lblinfo.text = String(format: "%@\nDate : %@", lblinfo.text ?? "" , baseClass.getDateFormate(date: orderVc.order.create_date!,formate:baseClass.date_fromate_server))
        }
        
        
        if orderVc.order.table_name != nil
        {
            if !orderVc.order.table_name!.isEmpty
            {
                lblinfo.text =   String(format: "%@\n Table : %@", lblinfo.text ?? "" , orderVc.order.table_name!)

            }

        }
        
        
        if orderVc.order.customer != nil
        {
            lblinfo.text =   String(format: "%@\n Customer : %@", lblinfo.text ?? "" , orderVc.order.customer!.name)
        }
        

        
        
        
  set_total_ui()
        
    }
    
}

// MARK: - UICollectionViewDataSource
typealias collectionViewDataSource = homeVC
extension collectionViewDataSource {
    //1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return list_product_search.count
        
    }
    
    //3
    func collectionView(  _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath  ) -> UICollectionViewCell {
        let cell = collectionView  .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! homeCollectionViewCell
        //        cell.backgroundColor = .lightGray
        // Configure the cell
        
        let obj = list_product_search[indexPath.row]
        
        let product = product_product_class(fromDictionary: obj as! [String : Any])
        
        
        cell.priceList = priceListVC.selectedItem
        cell.product = product
        
        
        cell.updateCell()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        // check is return order
//        if   orderVc.order.parent_order_id != 0
//        {
//            return
//        }
        
        //          let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! homeCollectionViewCell
        
        let obj = list_product_search[indexPath.row]
        let ptemp = product_product_class(fromDictionary: obj as! [String : Any])
        
        
        //        let ptemp = cell.product
        
        if orderVc.order.id == nil  {
            addNewOrder()
        }
        
        
        if ptemp.is_combo == true
        {
//            let line = pos_order_line_class.get_or_create(order_id: orderVc.order.id!, product: ptemp)
            let line = pos_order_line_class.create(order_id: orderVc.order.id!, product: ptemp)

        
            
            show_combo(line: line,isEdit: false)
            
            return
        }
        else if ptemp.variants_count > 1 && ptemp.is_combo == false
        {
            let storyboard = UIStoryboard(name: "appStoryboard", bundle: nil)
            let  variant_cls = storyboard.instantiateViewController(withIdentifier: "variant") as! variant
            variant_cls.modalPresentationStyle = .popover
            variant_cls.product_variant_ids = ptemp.getProductVariantIds()
            variant_cls.delegate = self
            variant_cls.order_id = orderVc.order.id
            
            let popover = variant_cls.popoverPresentationController!
            //        popover.delegate = self
            popover.permittedArrowDirections = .any //UIPopoverArrowDirection(rawValue: 0)
            popover.sourceView = collectionView
            
            
            popover.sourceRect = collectionView.cellForItem(at: indexPath)!.frame
            
            
            self.present(variant_cls, animated: true, completion: nil)
            return
        }
        
        
       var line = pos_order_line_class.get_or_create(order_id: orderVc.order.id!, product: ptemp)
 
        
       line =  add_product(line: line,check_by_line: true)
          
        handle_promotion(line: line)
        
        NSLog("add")
        
        
        
        
    }
    
    func handle_promotion(line:pos_order_line_class)
    {
        promotion_helper.order = orderVc.order
              promotion_helper.line = line
              promotion_helper.get_promotion()
    }
    
    @objc  func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){

      if (gestureRecognizer.state != UIGestureRecognizer.State.ended){
             return
         }

      let p = gestureRecognizer.location(in: self.collection)

        if let indexPath = self.collection.indexPathForItem(at: p) {
             // get the cell at indexPath (the one you long pressed)
//             let cell = self.collection.cellForItem(at: indexPath)
          
           
          let obj = list_product_search[indexPath.row]
          let ptemp = product_product_class(fromDictionary: obj as! [String : Any])

          
                let info = product_info()
            info.product = ptemp
             
       
                  info.modalPresentationStyle = .popover
              
                  
                 
                 let popover = info.popoverPresentationController!
                 //        popover.delegate = self
                 popover.permittedArrowDirections = .any //UIPopoverArrowDirection(rawValue: 0)
                 popover.sourceView = self.collection
                 
                 
                 popover.sourceRect = self.collection.cellForItem(at: indexPath)!.frame
                 
                 
                 self.present(info, animated: true, completion: nil)
          
          
             // do stuff with the cell
         } else {
             print("couldn't find index path")
         }

     }
      
    
    func show_combo(line:pos_order_line_class,isEdit:Bool)
    {
     
//                    let storyboard = UIStoryboard(name: "combo", bundle: nil)
//                    comboList_ver2 = storyboard.instantiateViewController(withIdentifier: "combo_list_ver2") as? combo_list_ver2
//                    comboList_ver2.modalPresentationStyle = .fullScreen
//                    comboList_ver2.product_combo = line // product!.product_combo_ids!
//                    comboList_ver2.product_combo?.combo_edit = isEdit
//                    comboList_ver2.delegate = self
//                    comboList_ver2.order_id = orderVc.order.id
//
//                    self.present(comboList_ver2, animated: true, completion: nil)
        
        
    }
    
    func edit_combo(line:pos_order_line_class)
    {
    
        show_combo(line: line,isEdit: true)
        
        
        
    }
    
    func addProduct(line:pos_order_line_class,new_qty:Double,check_by_line:Bool,check_last_row:Bool)
    {
        _ = add_product(line: line,new_qty: new_qty,check_by_line:check_by_line)
    }

    func add_product(line:pos_order_line_class,new_qty:Double = 0,check_by_line:Bool) -> pos_order_line_class
    {
         var new_line = line
        
        let rowIndex = -1 // orderVc.order.checkProductExist(line: line)
        
        if rowIndex == -1
        {
            if  new_qty == 0
            {
                line.qty  = 1
            }
            else
            {
                line.qty = new_qty
            }
 
            line.discount = 0
            
            
           line.id = 0
            
          new_line =  saveProduct(line: line , rowIndex: -1)
            
       
            
            
//            let count = orderVc.order.pos_order_lines.count - 1
            //            orderVc.tableview.reloadRows(at: [IndexPath.init(row: count, section: 0)], with: UITableView.RowAnimation.bottom)
            orderVc.tableview.reloadData()
//            orderVc.tableview.selectRow(at: IndexPath.init(row: count, section: 0), animated: true, scrollPosition: .bottom)
            
        }
        else
        {
            let p = orderVc.order.pos_order_lines[rowIndex]
            
            if new_qty == 0
            {
                  p.qty += 1
            }
            else
            {
                  p.qty  = new_qty
            }
          
            
 
             
        
            orderVc.tableview.reloadRows(at: [IndexPath.init(row: rowIndex, section: 0)], with: UITableView.RowAnimation.middle)
            orderVc.tableview.selectRow(at: IndexPath.init(row: rowIndex, section: 0), animated: true, scrollPosition: .middle)
            
            
          new_line =  saveProduct(line: p , rowIndex: rowIndex)

            
        }
        
        return new_line
    }
    
    func saveProduct(line:pos_order_line_class,rowIndex:Int) -> pos_order_line_class
    {
        line.priceList = priceListVC.selectedItem
        line.update_values()
        line.pos_multi_session_status = .last_update_from_local
        line.write_info = true
        line.kitchen_status = .send
    
        if rowIndex == -1
        {
            orderVc.order.pos_order_lines.append(line)
            
        }
        else
        {
            orderVc.order.pos_order_lines[rowIndex] = line
            
        }
        
        
        if line.is_combo_line == false
        {
            var last_value =  self.orderVc.order.total_product_qty[line.product_id!] ?? 0
             if last_value == 0
               {
                               self.orderVc.order.section_ids.append(line)
             }
            
             last_value = last_value + line.qty
              self.orderVc.order.total_product_qty[line.product_id!] = last_value
        }
        else
        {
            self.orderVc.order.section_ids.append(line)

        }

        
        
        
//         let updated_session_status_new:updated_status_enum = .last_update_from_local
//         if self.orderVc.order.sequence_number_server == 0
//          {
//                       // send order to server to get invoice number
//                       updated_session_status_new = .sending_update_to_server
//           }
        
 
        
        
        DispatchQueue.main.async  {
 
                self.orderVc.order.save(write_info: true )
               
//                        self.readOrder()
         
                 self.reloadTableOrders()

        }
    
 
        return line
        
        
    }
    
    //      func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    //
    //        if (kind == UICollectionView.elementKindSectionHeader) {
    //            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
    //
    //            return headerView
    //        }
    //
    //        return UICollectionReusableView()
    //
    //    }
    
}

typealias notificationCenter = homeVC
extension notificationCenter
{
    
    func init_notificationCenter()
     {
         
         let Epos_printer = AppDelegate.shared().getDefaultPrinter()
         
         Epos_printer.checkStatusPrinter()
         
         NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("printer_status"), object: nil)
         
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_update_order"), object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector( poll_remove_order(notification:)), name: Notification.Name("poll_remove_order"), object: nil)
         
     }
    
    func remove_notificationCenter() {
         NotificationCenter.default.removeObserver(self, name: Notification.Name("printer_status"), object: nil)
         NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_update_order"), object: nil)
         NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_remove_order"), object: nil)

     }
    
    
     @objc func methodOfReceivedNotification(notification: NSNotification){
         // Take Action on Notification
         //        loadingClass.hide(view: self.view)
         
         let obj = notification.object as? Bool ?? false
         printer_status(online: obj)
     }
     
    
     @objc func poll_update_order(notification: Notification) {
        
          DispatchQueue.main.async {
        
            self.checkBadge()
            
            let uid = notification.object as? String ?? ""
            
//            if self.list_order_created.count == 0
//            {
//
//            self.showLastOrder()
//                return
//            }
            
             if self.orderVc.order == nil
             {
                return
            }
            
            
            if self.orderVc.order.uid == uid
            {
                let option = self.pendding_options()
                option.uid = uid
                
                let arr = pos_order_helper_class.getOrders_status_sorted(options:option)
                if arr.count > 0
                {
                    self.orderVc.order = arr[0]
                    
 
                    self.readOrder()
                    self.reloadTableOrders()
                }
                else
                {
                     self.showLastOrder()
                }
                
            }
        }
            
        }
        
        @objc func poll_remove_order(notification: Notification) {
              DispatchQueue.main.async {
                
                self.checkBadge()
                
                
            let uid = notification.object as? String ?? ""
            
                if self.orderVc.order.uid == uid
            {
                self.showLastOrder()
            }
            }
            
        }
     
    
}
