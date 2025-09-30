//
//  calendarVC.swift
//  pos
//
//  Created by Khaled on 4/7/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class calendarVC: UIViewController {

      var didSelectDay: ((Date) -> Void)?
    var clearDay: (() -> Void)?
      var startDate = Date()

 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

 
        self.preferredContentSize = CGSize.init(width: 420, height: 470)
        
        view.addSubview(calendarPopup)

    }

    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnClear(_ sender: Any) {
        clearDay?()

          self.dismiss(animated: true, completion: nil)
      }
    
 private lazy var calendarPopup: CalendarPopUpView = {
       let frame = CGRect(
           x:10,
           y: 60,
           width: 400,
           height: 400
       )
       let calendar = CalendarPopUpView(frame: frame,_startDate: startDate)
       calendar.backgroundColor = .white
       calendar.layer.shadowColor = UIColor.black.cgColor
       calendar.layer.shadowOpacity = 0.4
       calendar.layer.shadowOffset = .zero
       calendar.layer.shadowRadius = 5
 
      calendar.didSelectDay = didSelectDay
     //  calendar.didSelectDay = { [weak self] date in
//           self?.setSelectedDate(date)
        
     //  }

       return calendar
   }()

}
