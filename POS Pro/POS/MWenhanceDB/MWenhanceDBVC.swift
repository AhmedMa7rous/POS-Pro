//
//  MWenhanceDBVC.swift
//  pos
//
//  Created by M-Wageh on 22/10/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class MWenhanceDBVC: UIViewController {

    @IBOutlet weak var timerLbl: UILabel!
    var countdownTimer: Timer?
    var totalTime = 300 //300 // 5 minutes in seconds
    var totalTimeOrgain = 300 //300 // 5 minutes in seconds

    override func viewDidLoad() {
        super.viewDidLoad()
        timerLbl.text = formatTime(totalTime)
        startTimer()
       

    }
    func excuteMaintance(){
        MaintenanceInteractor.shared.handleExcuteMaintanceFromFR(lastDate: Int(Date().timeIntervalSince1970 * 1000)) {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    func startTimer() {
            countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
        
        @objc func updateTimer() {
            if totalTime > 0 {
                if totalTime == (totalTimeOrgain - 10) {
                    self.excuteMaintance()
                }
                totalTime -= 1
                timerLbl.text = formatTime(totalTime)
            } else {
                countdownTimer?.invalidate()
                timerLbl.text = "Maintance Success".arabic("تم الانتهاء من الصيانه بنجاح")
                
                self.dismiss(animated: true)
            }
        }
        
        func formatTime(_ seconds: Int) -> String {
            let minutes = seconds / 60
            let seconds = seconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    
    static func createModule() -> MWenhanceDBVC {
        let vc:MWenhanceDBVC = MWenhanceDBVC()
        return vc
    }

}
