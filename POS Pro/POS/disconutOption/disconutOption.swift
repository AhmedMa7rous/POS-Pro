//
//  disconutOption.swift
//  pos
//
//  Created by Khaled on 11/26/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

enum dicount_type: String {
    case fixed,percentage
}
class disconutOption: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var delegate:disconutOption_delegate?
    
    var list_items:  [Any]! = []
 
    
    var dicountType:dicount_type = .fixed
    var deleted:Bool = false
    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        
        list_items = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width: 320, height: 400)

        self.tableview.reloadData()
//        getDisconutOption()
    }
    
    
    func getDisconutOption() {
        
        
        let arr = pos_discount_program_class.getAll(delet:self.deleted) // api.get_last_cash_result(keyCash: "get_discount_program")
        
        for item in arr
        {
            let obj = pos_discount_program_class(fromDictionary: item )
            if obj.dicount_type == dicountType.rawValue
            {
                self.list_items.append(obj)
            }
        }
        
        
            
    
        }
    }
    



extension disconutOption: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let obj =   list_items[indexPath.row] as! pos_discount_program_class
        delegate?.disconutOption_selected(disocunt: obj)

        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! disconutOptionTableViewCell
        
        let obj =   list_items[indexPath.row] as! pos_discount_program_class
        cell.lblName.text = obj.name
 
        
        
        return cell
    }
    
    
}

protocol  disconutOption_delegate {
    func disconutOption_selected(disocunt:pos_discount_program_class)
    func didApplyDiscount()
}
