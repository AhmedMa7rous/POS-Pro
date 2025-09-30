//
//  printer_status.swift
//  pos
//
//  Created by Khaled on 3/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class printer_status: UIViewController {

      var timer = Timer()
    
    @IBOutlet weak var lblStatus: KLabel!
    
    var completion: ((Bool) -> ())?
    override func viewDidDisappear(_ animated: Bool) {
         super.viewDidDisappear(animated)
     
        
         timer.invalidate()
      
     }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = CGSize.init(width: 600, height: 600)
        var count_job = 0
        // Do any additional setup after loading the view.
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            MWRunQueuePrinter.shared.getCountFilesInQueue()
        }else{
         count_job =  SharedManager.shared.epson_queue!.get_numbers_inQueue()
        }
        if count_job == 0
        {
           count_job = 1
        }

        lblStatus.text = String(format: "%d %@", count_job , " receipts in queues")


        timer = Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        timer.fire()
        
    }

    @objc func updateUI()
    {
        let count_job =  SharedManager.shared.epson_queue!.get_numbers_inQueue()
        if count_job == 0
        {
            self.btnClose(AnyClass.self)
        }
        else
        {
            lblStatus.text = String(format: "%d %@", count_job , " receipts in queues")

        }
    }

    @IBAction func btnClose(_ sender: Any) {
        completion?(true)
        self.dismiss(animated: true, completion: nil)
    }
    

}
