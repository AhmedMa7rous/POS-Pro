//
//  tableView.swift
//  pos
//
//  Created by Khaled on 11/19/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

class tableView: UIViewController {
    
    var tabel:restaurant_table_class!
 
    @IBOutlet var lblInfo: UILabel!
    @IBOutlet weak var tableItem: ShadowView!

//    var timer = Timer()

    
    func updateView()   {
        self.view.frame.origin.x = CGFloat(tabel.position_h!)
        self.view.frame.origin.y = CGFloat(tabel.position_v!)
        self.view.frame.size.width = CGFloat(tabel.width!)
        self.view.frame.size.height = CGFloat(tabel.height!)
        
        tableItem.frame.origin.x = 0
        tableItem.frame.origin.y = 0
        tableItem.frame.size.width = CGFloat(tabel.width!)
        tableItem.frame.size.height = CGFloat(tabel.height!)
        
        tableItem.backgroundColor = tabel.color
        
        if tabel.shape == .round
        {
            tableItem.cornerRadius = CGFloat(tabel.width!) / 2
        }
        else
        {
            tableItem.cornerRadius = 5
        }
        
        let title = (tabel.display_name ?? "") + "\n" + sequence_number_full
        lblInfo.text = title.uppercased()
        
        if tabel.order_id != 0
        {
            let cashierID = SharedManager.shared.activeUser().id
            let isMyTable = cashierID == (tabel.create_user_id ?? 0)
            tableItem.backgroundColor = isMyTable ?  #colorLiteral(red: 0.4352941176, green: 0.5098039216, blue: 0.9176470588, alpha: 1) : #colorLiteral(red: 0.9675033689, green: 0.5350341201, blue: 0.221409291, alpha: 1)

//            timer = Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
//                      timer.fire()
        }
    }
    
    
    @objc func refresh()
    {
        let def_duration = baseClass.compareTwoDate(tabel.create_date!,
                                                     dt2_new: Date().toString(dateFormat: baseClass.date_formate_database, UTC: true), formate: baseClass.date_formate_database)
         
       let time = Date.second_to_duration(seconds: def_duration, style: .abbreviated)
        
        let title = (tabel.display_name ?? "") + "\n" + sequence_number_full

        lblInfo.text =  title.uppercased() + "\n" + time
    }
    
    
    
    var sequence_number_full:String
    {
        get
        {
            if !tabel.uid!.isEmpty
            {
                let split = tabel.uid?.split(separator: "-")
                if split?.count == 3
                {
                    let full_seq = String( split![1] ) +  "-" + String( split![2])
                    
                    return "#" + full_seq
                }
            }
        
            
            return String( "")
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

 
