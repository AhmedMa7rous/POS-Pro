//
//  RestaurantTableViewCell.swift
//  pos
//
//  Created by Muhammed Elsayed on 04/02/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UICollectionViewCell {
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var tableItem: ShadowView!
    
    var tabel: restaurant_table_class? {
        didSet {
            updateView()
        }
    }
//    var order: pos_order_class?
    
    var countOrder: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.updateTitle()
            }
        }
    }
    
   /* private var sequence_number_full: String {
        guard let uid = tabel?.uid, !uid.isEmpty else {
            return ""
        }
        
        let split = uid.split(separator: "-")
        if split.count == 3 {
            let full_seq = String(split[1]) + "-" + String(split[2])
            return "#" + full_seq
        }
        
        return ""
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    private func updateView() {
        guard let tabel = self.tabel else { return }
//        let order = pos_order_class.get(order_id: tabel.order_id)

        tableItem.backgroundColor = tabel.color
        
        if tabel.shape == .round {
            tableItem.cornerRadius =  CGFloat(tabel.width!) / 2 //tableItem.frame.width / 2
        } else {
            tableItem.cornerRadius = 5
        }
        DispatchQueue.main.async {
            self.updateTitle()
        }
        
        if tabel.order_id != 0
        {
            guard let order = pos_order_class.get(order_id: tabel.order_id) else { return }
            if SharedManager.shared.activeUser().id == order.create_user_id {
                tableItem.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.5098039216, blue: 0.9176470588, alpha: 1)
            } else {
                tableItem.backgroundColor = #colorLiteral(red: 0.9111976624, green: 0.4929889441, blue: 0, alpha: 1)
            }
            /*
            for line in order.pos_order_lines {
                if !line.is_sent_to_kitchen() {
                    tableItem.borderWidth = 3
                    tableItem.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                }
            }
            */
            
            //            timer = Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
            //                      timer.fire()
        }
    }
    private func updateTitle() {
        guard let tabel = self.tabel else {
            lblInfo.text = ""
            return}
        var title = ""
        if let seq = tabel.sequence_number ,seq != 0 {
            title += "#\(seq)\n"

        }
         title += (tabel.display_name ?? "")
        
        if countOrder > 1 {
            title += "\n(\(countOrder))"
        }
        if SharedManager.shared.appSetting().enable_make_user_resposiblity_for_order{
            if let user_name = tabel.create_user_name  {
                title += "\n"
                title += user_name
            }
        }
        lblInfo.text = title.uppercased()
    }
    
    @objc func refresh()
    {
        guard let tabel = self.tabel else {return}
        
        let def_duration = baseClass.compareTwoDate(tabel.create_date!,
                                                    dt2_new: Date().toString(dateFormat: baseClass.date_formate_database, UTC: true), formate: baseClass.date_formate_database)
        
        let time = Date.second_to_duration(seconds: def_duration, style: .abbreviated)
        var title = (tabel.display_name ?? "")
        if let seq = tabel.sequence_number ,seq != 0 {
            title += "\n#\(seq)"

        }
        lblInfo.text =  title.uppercased() + "\n" + time
    }
}
