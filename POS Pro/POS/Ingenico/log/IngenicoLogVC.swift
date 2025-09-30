//
//  IngenicoLogVC.swift
//  pos
//
//  Created by M-Wageh on 22/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class IngenicoLogVC: UIViewController {
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    var refreshControl = UIRefreshControl()

    var data:[[String:Any]] = [[:]]

    let offest:Int = 40
    let cellReuseIdentifier:String = "IngenicoLogCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        segment.selectedSegmentIndex = 0
        tapOnSegment(segment)
        // Do any additional setup after loading the view.
    }

    @objc private func getIngenicoLogData(sender:AnyObject?) {
        tapOnSegment(segment)
    }

    @IBAction func tapOnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapOnShare(_ sender: Any) {
    }
    

    @IBAction func tapOnSegment(_ sender: UISegmentedControl) {
        data.removeAll()
        switch sender.selectedSegmentIndex {
        case 0:
            data = ingenico_log_class.getAll( limit: [0,1000])
        case 1:
            data = ingenico_log_class.getAll(prefix:"error", limit:[0,1000])
        default:
            return
        }
        self.table.reloadData()
        refreshControl.endRefreshing()
    }
}
extension IngenicoLogVC:UITableViewDelegate,UITableViewDataSource{
    private func setupTable(){
        self.table.register(UINib(nibName:cellReuseIdentifier , bundle: Bundle.main), forCellReuseIdentifier: cellReuseIdentifier)
        table.estimatedRowHeight = 120

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(getIngenicoLogData(sender:)), for: UIControl.Event.valueChanged)
        table.addSubview(refreshControl) // not required when using UITableViewContr
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:IngenicoLogCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! IngenicoLogCell
        let objc = ingenico_log_class(fromDictionary: data[indexPath.row])
        cell.textLbl.text = objc.key
        if ((objc.prefix?.lowercased().contains("error")) ?? false){
            cell.containerView.layer.borderWidth = 1
            cell.containerView.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        }else{
            cell.containerView.layer.borderWidth = 1
            cell.containerView.layer.borderColor = UIColor.clear.cgColor
        }
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.textView.text = ""
        let objc = ingenico_log_class(fromDictionary: data[indexPath.row])
        let data = objc.data?.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\", with: "") ?? ""
        let seperator = "\n" + "----------------------------------" + "\n"
        let value = "Date : \(objc.updated_at ?? "")"
            + seperator +
            "ingenico_id : \(String(describing: objc.ingenico_id ?? 0))"
            + seperator +
            "Key: \(objc.key ?? "")"
            + seperator +
            "prefix: \(objc.prefix ?? "")"
            + seperator +
            "Data: \(data)"
        self.textView.text = value
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension

    }
    
}
