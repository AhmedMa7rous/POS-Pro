//
//  countries_list.swift
//  pos
//
//  Created by Khaled on 12/5/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol countries_list_delegate {
    func country_selected(country:res_country_class)
}

class countries_list: UIViewController {

    @IBOutlet var tableview: UITableView!
    public var selectedCountry : res_country_class!

    var delegate:countries_list_delegate?
    
    let con = SharedManager.shared.conAPI()
    var list_items:  [Any] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        list_items =  res_country_class.getAll() // api.get_last_cash_result(keyCash: "get_countries")
        
        tableview.reloadData()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self .dismiss(animated: true, completion: nil)
    }
 
}

extension countries_list: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let customer = list_items[indexPath.row] as? [String : Any]
        
        selectedCountry = res_country_class(fromDictionary: customer!)
        
        if delegate != nil
        {
            delegate?.country_selected(country: selectedCountry)
        }
        
        self.btnBack(!)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! countriesTableViewCell
        
        let obj = list_items[indexPath.row]
        let customer = res_country_class(fromDictionary: obj as! [String : Any])
        
        cell.lblName.text = customer.name
      
        
        
        return cell
    }
}
