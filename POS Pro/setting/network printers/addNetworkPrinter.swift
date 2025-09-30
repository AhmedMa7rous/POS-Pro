//
//  addNetworkPrinter.swift
//  pos
//
//  Created by khaled on 26/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class addNetworkPrinter: UIViewController {
    let _api = api()

    @IBOutlet weak var txtPrinterIp: UITextField!
    @IBOutlet weak var txtPrinterName: UITextField!
    
//    @IBOutlet weak var btnPos: UIButton!
    @IBOutlet weak var btnCategories: UIButton!
    @IBOutlet weak var btnOrderType: UIButton!
    @IBOutlet weak var btnDelete: UIButton!

    
    
    var printer:restaurant_printer_class?
    
    var list_categories:options_choose?
    var selected_categories:[Int] = []

    
    var list_orderType:options_choose?
    var selected_orderType:[Int] = []
    
    var list_pos:options_choose?
    var selected_pos:[Int] = []
    
    var reloadPrinters : (() -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if printer != nil
        {
            txtPrinterIp.text = printer?.printer_ip
            txtPrinterName.text = printer?.name
        }
        else
        {
            btnDelete.isHidden = true
        }

        categories()
        orderType()
//        poss()
     }
    
    func categories()
    {
      if printer == nil
      {
        return
      }
        
       let cats_ids = printer!.get_product_categories_ids()
        
        let cats =  pos_category_class.get(ids: cats_ids)
        var allCateg = ""
        
        for c in cats
        {
//             let key_name = c["name"]  as? String ?? ""
            let cat = pos_category_class(fromDictionary: c)
            selected_categories.append(cat.id)
            
            allCateg = allCateg  + cat.display_name + ","
        }
        
        btnCategories.setTitle(allCateg, for: .normal)
    }
    
    func orderType()
    {
      if printer == nil
      {
        return
      }
        
       let _ids = printer!.get_order_type_ids()
        
        let rows =  delivery_type_class.get(ids: _ids)
        var all = ""
        
        for c in rows
        {
             let ord = delivery_type_class(fromDictionary: c)
            selected_orderType.append(ord.id)

            all = all  + ord.display_name + ","
        }
        
        btnOrderType.setTitle(all, for: .normal)
    }
    
//    func poss()
//    {
//      if printer == nil
//      {
//        return
//      }
//
//       let _ids = printer!.get_config_ids()
//        let rows =  pos_config_class.get(ids: _ids)
//
//        var all = ""
//
//        for c in rows
//        {
//             let pos = pos_config_class(fromDictionary: c)
//            selected_pos.append(pos.id)
//
//            all = all  + pos.name! + ","
//        }
//
//        btnPos.setTitle(all, for: .normal)
//    }
    
    
//    @IBAction func btnPos(_ sender: Any) {
//
//        if list_pos == nil
//        {
//            list_pos = options_choose()
//            list_pos!.defualtSize = false
//
//            list_pos!.modalPresentationStyle = .formSheet
//
//            list_pos!.list_items.append([options_choose.title_prefex:"All"])
//
//            let   all:[[String:Any]] = pos_config_class.getAll()
//
//            for row in all
//            {
//                var dic = row
//                let item = pos_config_class(fromDictionary: row  )
//
//                dic[options_choose.title_prefex] = item.name
//                dic[options_choose.obj_prefex] = item
//
//
//                if (selected_pos.first(where: {item.id == $0}) != nil)
//                {
//                    dic[options_choose.selected_prefex] = "selected"
//                }
//
//                list_pos!.list_items.append(dic)
//
//            }
//
//        }
//
//
//        list_pos!.didSelect = { [weak self] data in
//            let list = data as! [pos_config_class]
//
//            self!.selected_pos.removeAll()
//
//            var selected_str :String = ""
//            for item in list
//            {
//                self!.selected_pos.append(item.id)
//                selected_str = selected_str  + item.name! + ","
//            }
//
//
//
//            self!.btnPos.setTitle(selected_str, for: .normal)
//
//        }
//
//        list_pos!.modalPresentationStyle = .formSheet
//        list_pos!.preferredContentSize = CGSize(width: 900, height: 700)
//        self.present(list_pos!, animated: true, completion: nil)
//        list_pos!.lblTitle.text = "Select POS"
//
//    }
    
    @IBAction func btnOrderType(_ sender: Any) {
        
        
        if list_orderType == nil
        {
            list_orderType = options_choose()
            list_orderType!.defualtSize = false
            
            list_orderType!.modalPresentationStyle = .formSheet
            
            list_orderType!.list_items.append([options_choose.title_prefex:"All"])
            
            let   all:[[String:Any]] = delivery_type_class.getAll()
            
            for row in all
            {
                var dic = row
                let item = delivery_type_class(fromDictionary: row  )
                
                dic[options_choose.title_prefex] = item.name
                dic[options_choose.obj_prefex] = item
                
                
                if (selected_orderType.first(where: {item.id == $0}) != nil)
                {
                    dic[options_choose.selected_prefex] = "selected"
                }
                
                list_orderType!.list_items.append(dic)
                
            }
            
        }
        
         
        list_orderType!.didSelect = { [weak self] data in
           let list = data as! [delivery_type_class]
            
            self!.selected_orderType.removeAll()

            var selected_str :String = ""
            for item in list
            {
                self!.selected_orderType.append(item.id)
                selected_str = selected_str  + item.name + ","
            }
            
           
            
            self!.btnOrderType.setTitle(selected_str, for: .normal)
       
        }
        
        list_orderType!.modalPresentationStyle = .formSheet
        list_orderType!.preferredContentSize = CGSize(width: 900, height: 700)
        self.present(list_orderType!, animated: true, completion: nil)
        list_orderType!.lblTitle.text = "Select Order type"
        
    }
    
    @IBAction func btnCategories(_ sender: Any) {
        
        if list_categories == nil
        {
            list_categories = options_choose()
            list_categories!.defualtSize = false

            list_categories!.modalPresentationStyle = .formSheet
            
            list_categories!.list_items.append([options_choose.title_prefex:"All"])
            
            let   main_categ_org = pos_category_class.getCategoryTopLevel() as? [[String : Any]] ?? []
            
            for item in main_categ_org
            {
                var dic = item
                let categ = pos_category_class(fromDictionary: item  )
                
                dic[options_choose.title_prefex] = categ.name
                dic[options_choose.obj_prefex] = categ
                
                if (selected_categories.first(where: {categ.id == $0}) != nil)
                {
                    dic[options_choose.selected_prefex] = "selected"
                }

 
                
                list_categories!.list_items.append(dic)
                
            }
            
        }
        
        
        
        
        
        list_categories!.didSelect = { [weak self] data in
            let list = data as! [pos_category_class]
            
            self!.selected_categories.removeAll()
            var selected_categ_str :String = ""
            for item in list
            {
                self!.selected_categories.append(item.id)
                selected_categ_str = selected_categ_str  + item.name + ","
            }
            
           
            
            self!.btnCategories.setTitle(selected_categ_str, for: .normal)
       
        }
        
        list_categories!.modalPresentationStyle = .formSheet
        list_categories!.preferredContentSize = CGSize(width: 900, height: 700)
        self.present(list_categories!, animated: true, completion: nil)
        list_categories!.lblTitle.text = "Select categories"
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
 
    @IBAction func btnSave(_ sender: Any) {
        
        loadingClass.show(view: self.view)
      var isNew = false
      if printer == nil
      {
        printer = restaurant_printer_class(fromDictionary: [:])
        printer?.company_id = SharedManager.shared.posConfig().company_id!
        
        selected_pos.append(SharedManager.shared.posConfig().id)
        isNew = true
        
      }
     
        
        printer!.printer_ip = txtPrinterIp.text ?? ""
        printer!.name = txtPrinterName.text ?? ""
        printer!.config_ids = selected_pos
        printer!.order_type_ids = selected_orderType
        printer!.product_categories_ids = selected_categories

        if isNew
        {
            create()

        }
        else
        {
            update()
        }
        
        
    }
    
    
    func dismissWithReload()
    {
        DispatchQueue.main.async {
        self.reloadPrinters?()
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        }
    }
    
    func create()
    {
        _api.create_restaurant_printer(printer: printer!) { [self] result in
            loadingClass.hide(view: self.view)

            if (result.success )
            {
            
                let id = result.response!["result"] as?  Int ?? 0
                if id != 0
                {
                    self.printer?.id = id
                    self.printer?.dbClass?.insertId = true
                    self.printer?.save(temp: false, is_update: false)
                }
               
                dismissWithReload()
           
            }
            else
            {
                messages.showAlert(result.message ?? "")
            }
            
        }

    }
    
    func update()
    {
        _api.write_restaurant_printer (printer: printer!) { [self] result in
            loadingClass.hide(view: self.view)

            if (result.success )
            {
            
                self.printer?.save(temp: false, is_update: false)
                dismissWithReload()
            }
            else
            {
                messages.showAlert(result.message ?? "")
            }
            
        }

    }
    
    
    func delete()
    {
        _api.delete_restaurant_printer (printer: printer!) { [self] result in
            loadingClass.hide(view: self.view)

            if (result.success )
            {
            
                self.printer?.delete()
                dismissWithReload()

            }
            else
            {
                messages.showAlert(result.message ?? "")
            }
            
        }

    }
    
    @IBAction func btnDelete(_ sender: Any) {
        
        let alert = UIAlertController(title: "Delete", message: "Are you sure to delete this printer ?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete" , style: .default, handler: { (action) in
            
            self.delete()
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel" , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        
        self .present(alert, animated: true, completion: nil)
        
    }
    
    
}
