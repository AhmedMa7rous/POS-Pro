//
//  ReportWifiVC.swift
//  pos
//
//  Created by M-Wageh on 11/02/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit
//typealias ReportWifiVC = zReport
extension zReport{
    static func createReportWifiVC() -> zReport? {
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        if let z_report:zReport = storyboard.instantiateViewController(withIdentifier: "zReport") as? zReport {
            z_report.custom_header = LanguageManager.currentLang() == .ar ? "تقرير عمليات " : "Sales report"
            z_report.is_report_wifi = true
            return z_report
        }
        return nil
    }
}
