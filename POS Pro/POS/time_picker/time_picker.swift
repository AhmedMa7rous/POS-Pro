//
//  calendarVC.swift
//  pos
//
//  Created by Khaled on 4/7/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class time_picker: UIViewController {

      var didSelectDay: ((String) -> Void)?
  
      @IBOutlet var timePicker:UIDatePicker!
    
    var minTime:String?

    override func viewDidLoad() {
        super.viewDidLoad()

 
        self.preferredContentSize = CGSize.init(width: 420, height: 470)
        
        
        let dt:Date = Date.init(strDate: minTime!, formate: "hh:mm a",UTC: false)
        timePicker.setDate(dt, animated: true)

    }

    @IBAction func btnOK(_ sender: Any) {
        
        let time_str = timePicker.date.toString(dateFormat: "hh:mm a",UTC: false)
        
        didSelectDay!(time_str)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
 
    
  
}
