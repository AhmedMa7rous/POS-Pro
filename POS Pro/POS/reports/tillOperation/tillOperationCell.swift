//
//  customerTableViewCell.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class tillOperationCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBOutlet var lblNAme: KLabel!
    @IBOutlet var lblSessionStatus: KLabel!
    @IBOutlet var lblTime: KLabel!
    @IBOutlet var lblTotal: KLabel!

    
 
    
    func updateCell(shift :pos_session_class) {
        
//       let shift = getFirstShift()
 
        if shift.show_as == showAs.end
        {
//            let EndDate =  ClassDate.convertTimeStampTodate(String(shift.date_endShift  ) ,
//                                                                returnFormate: "yyyy-MM-dd hh:mm a" , timeZone: NSTimeZone.local)
            
//            let EndDate = ClassDate.getWithFormate(shift.end_shift, formate: ClassDate.satnderFromate(), returnFormate: "yyyy-MM-dd hh:mm a", use_UTC: false)

            let dt = Date(strDate: shift.end_session!, formate: baseClass.date_fromate_satnder,UTC: true)
            let EndDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
            
//            let EndDate =  ClassDate.getWithFormate(shift.end_session, formate: ClassDate.satnderFromate(), returnFormate: ClassDate.satnderFromate_12H(),use_UTC: false)

            lblNAme.text = shift.cashier().name
            lblSessionStatus.text = "Close"
            lblTime.text = EndDate
           lblTotal.text = String(format: "%@"  , shift.end_Balance.toIntString() )
        }
//        else if shift.show_as == showAs.cashOut
//        {
//             let cashbox = cashbox_class(fromDictionary: shift.cashbox_list[0] as? [String:Any] ?? [:] )
//
////            let EndDate =  ClassDate.convertTimeStampTodate(String(cashbox.date  ) ,
////                                                            returnFormate: "yyyy-MM-dd hh:mm a" , timeZone: NSTimeZone.local)
//
//            let EndDate =  ClassDate.getWithFormate(cashbox.date, formate: ClassDate.satnderFromate(), returnFormate: ClassDate.satnderFromate_12H(),use_UTC: false)
//
//
//            lblNAme.text = shift.cashier().name
//            lblSessionStatus.text = "Cash Out"
//            lblTime.text = EndDate
//
//            lblTotal.text = String(format: "%@"  , cashbox.cashbox_amount.toIntString()  )
//        }
//       else if shift.show_as == showAs.cashIn
//        {
//            let cashbox = cashbox_class(fromDictionary: shift.cashbox_list[0] as? [String:Any] ?? [:] )
//
////            let EndDate =  ClassDate.convertTimeStampTodate(String(cashbox.date ) ,
////                                                            returnFormate: "yyyy-MM-dd hh:mm a" , timeZone: NSTimeZone.local)
//
//            let EndDate =  ClassDate.getWithFormate(cashbox.date, formate: ClassDate.satnderFromate(), returnFormate: ClassDate.satnderFromate_12H(),use_UTC: false)
//
//            lblNAme.text = shift.cashier().name
//            lblSessionStatus.text = "Cash In"
//            lblTime.text = EndDate
//            lblTotal.text = String(format: "%@"  , cashbox.cashbox_amount.toIntString()  )
//        }
    
        else
        {
//               let StartDate =  ClassDate.convertTimeStampTodate(String(shift.id ) ,
//                                                                        returnFormate: "yyyy-MM-dd hh:mm a" , timeZone: NSTimeZone.local)
            
            
            let dt = Date(strDate: shift.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
                let StartDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
            
//            let StartDate =  ClassDate.getWithFormate(shift.start_session, formate: ClassDate.satnderFromate(), returnFormate: ClassDate.satnderFromate_12H(),use_UTC: false)
            lblNAme.text = shift.cashier().name
                 lblTime.text = StartDate
                 lblSessionStatus.text = "Open"
                 lblTotal.text = String( format: "%@"  , shift.start_Balance.toIntString())
        }
        
 

        
        
    }

     func updateCell(cash_box :cashbox_class) {
        
        let dt = Date(strDate: cash_box.date!, formate: baseClass.date_fromate_satnder,UTC: true)
            let EndDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
        
        
//            let EndDate =  ClassDate.getWithFormate(cash_box.date, formate: ClassDate.satnderFromate(), returnFormate: ClassDate.satnderFromate_12H(),use_UTC: false)

        lblNAme.text = cash_box.cashier!.name

        lblSessionStatus.text = cash_box.cashbox_in_out
               lblTime.text = EndDate
           
        lblTotal.text = String(format: "%@"  ,cash_box.cashbox_amount.toIntString()  )
            
            
        }




}

