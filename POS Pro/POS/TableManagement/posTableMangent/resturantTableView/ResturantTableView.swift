//
//  ResturantTableView.swift
//  pos
//
//  Created by M-Wageh on 15/12/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class ResturantTableView: UIView {
    weak var tabel:restaurant_table_class?
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var tableItem: ShadowView!

    var countOrder:Int = 0
    
    var sequence_number_full:String
    {
        get
        {
            if !(tabel?.uid!.isEmpty ?? true )
            {
                let split = tabel?.uid?.split(separator: "-")
                if split?.count == 3
                {
                    let full_seq = String( split![1] ) +  "-" + String( split![2])
                    return "#" + full_seq
                }
            }
            return String( "")
        }
    }
    
    class func getViewInstance(table:restaurant_table_class)->ResturantTableView {
            let view = UINib(nibName: "ResturantTableView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ResturantTableView
            view.setupView(table)
            return view
     }
    
    fileprivate func setupView(_ tabel:restaurant_table_class) {
            // do your setup here
        self.tabel = tabel
        updateView()
    }

    
   
    func updateView()   {
        guard let tabel = self.tabel else {return}
        self.frame.origin.x = CGFloat(tabel.position_h!)
        self.frame.origin.y = CGFloat(tabel.position_v!)
        self.frame.size.width = CGFloat(tabel.width!)
        self.frame.size.height = CGFloat(tabel.height!)
        
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
        var title = (tabel.display_name ?? "") + "\n" + sequence_number_full        
        if countOrder > 1 {
             title = (tabel.display_name ?? "") + "\n" + "(\(countOrder)" + "\n" + sequence_number_full

        }
        lblInfo.text = title.uppercased()
        
        if tabel.order_id != 0
        {
            if tabel.order_amount <= 0 {
                tableItem.backgroundColor = #colorLiteral(red: 0.3019607843, green: 0.7450980392, blue: 0.4549019608, alpha: 1)

            }else{
                //            guard let order = pos_order_class.get(order_id: tabel.order_id) else { return }
                if SharedManager.shared.activeUser().id ==  (tabel.create_user_id ?? 0) {
                    tableItem.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.5098039216, blue: 0.9176470588, alpha: 1)
                } else {
                    tableItem.backgroundColor = #colorLiteral(red: 0.9141775966, green: 0.4684327245, blue: 0.1456616521, alpha: 1)
                }
            }
            /*
            for line in order.pos_order_lines {
                if !line.is_sent_to_kitchen() {
                    tableItem.borderWidth = 1.5
                    tableItem.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                }
            }
            */
            
            //            timer = Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
            //                      timer.fire()
        }
    }

    func updateTitle(){
        if countOrder > 1 {
            lblInfo.text = (tabel?.display_name ?? "") + "\n" + "(\(countOrder)" + "\n" + sequence_number_full

        }
    }
    
    @objc func refresh()
    {
        guard let tabel = self.tabel else {return}
        
        let def_duration = baseClass.compareTwoDate(tabel.create_date!,
                                                    dt2_new: Date().toString(dateFormat: baseClass.date_formate_database, UTC: true), formate: baseClass.date_formate_database)
        
        let time = Date.second_to_duration(seconds: def_duration, style: .abbreviated)
        
        let title = (tabel.display_name ?? "") + "\n" + sequence_number_full
        
        lblInfo.text =  title.uppercased() + "\n" + time
    }
    
    
    
    
    
    
}
