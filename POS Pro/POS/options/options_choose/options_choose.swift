//
//  return_orders.swift
//  pos
//
//  Created by Khaled on 4/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class options_choose: UIViewController , UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var btnSelectAll: UIButton!
    @IBOutlet var view_continer: UIView!
    
    @IBOutlet var lblTitle: KLabel!
    
    
    static let title_prefex = "title_options_listVC"
    static let image_prefex = "image_options_listVC"
    static let obj_prefex = "obj_options_listVC"
    static let selected_prefex = "tag_temp"

    var defualtSize:Bool = true
 
    var order:pos_order_class?
    
    var list_items:[[String:Any]] = []
    
    var didSelect : (([Any]) -> Void)?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if defualtSize
        {
            self.preferredContentSize = CGSize.init(width: 414, height: 700)

        }
        
        btnSelectAll.tag = 0
        
        
        tableview.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var itme =  list_items[indexPath.row]
        let title = itme[options_listVC.title_prefex] as? String ?? ""
        var tag_temp = itme["tag_temp"] as? String ?? ""

        if title == "All"
        {
            if  btnSelectAll.tag != 0
            {
                btnSelectAll.tag  = 0
                btnSelectAll.setTitle("Select all", for: .normal)

                tag_temp = ""
                itme["tag_temp"] = tag_temp
                
                list_items[indexPath.row] = itme
                tableView.reloadData()

            }
            else
            {
                btnSelectAll.tag  = 0
                btnSelectAll(AnyClass.self)
            }
      
            return
        }
        
        
        if !tag_temp.isEmpty
        {
            tag_temp = ""
            
        }
        else
        {
            tag_temp = "selected"
        }
        
        itme["tag_temp"] = tag_temp
        
        list_items[indexPath.row] = itme
        tableView.reloadData()
        
        
        
        
        //          didSelect?(itme)
        //           self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"
        var cell: options_chooseTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? options_chooseTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "options_chooseTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? options_chooseTableViewCell
        }
        
        
        let itme:[String:Any] =  list_items[indexPath.row]
        let title = itme[options_listVC.title_prefex] as? String ?? ""
        let tag_temp = itme["tag_temp"] as? String ?? ""
        
        cell.lblTitle.text = title
        
        if   !tag_temp.isEmpty
        {
            cell.img_select.isHighlighted = true
        }
        else
        {
            cell.img_select.isHighlighted = false
            
        }
        
        
        
        
        //        cell.product =  list_items[indexPath.row]
        //        cell.updateCell()
        
        //         if cell.product.can_return == false
        //            {
        //                cell.selectionStyle = .none
        //            }
        
        
        
        
        return cell
    }
    
    @IBAction func btnSelectAll(_ sender: Any) {
        
        var selected:String? = nil
        if btnSelectAll.tag == 0
        {
            btnSelectAll.tag = 1
            selected = "selected"
            btnSelectAll.setTitle("Un select all", for: .normal)
        }
        else
        {
            btnSelectAll.tag = 0
            btnSelectAll.setTitle("Select all", for: .normal)
            
        }
        
        for i in 0...list_items.count - 1
        {
            var item = list_items[i]
            
            item["tag_temp"] = selected
            list_items[i] = item
            
        }
        tableview.reloadData()
        
    }
    
    @IBAction func btnOk(_ sender: Any) {
        
        var arr_selected:[Any] =  []
        
        for i in 0...list_items.count - 1
        {
            let item = list_items[i]
            let tag_temp = item["tag_temp"] as? String ?? ""
            if tag_temp == "selected"
            {
                let obj = item[options_choose.obj_prefex]
                if obj != nil
                {
                    arr_selected.append(obj!)
                    
                }
            }
            
            
        }
        
        didSelect?(arr_selected)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
