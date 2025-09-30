//
//  MWSegmentVC.swift
//  pos
//
//  Created by M-Wageh on 09/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class MWSegmentVC: UIViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    var segmentTitles:[String] = []
    var segmentVC:[UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeUI()
    }
    func initalizeUI(){
        segment.ensureiOS12Style()
        segment.replaceSegments(withTitles: segmentTitles)
        add_View(segmentVC[0])
        segment.selectedSegmentIndex = 0

    }

    @IBAction func tapOnSegment(_ sender: UISegmentedControl) {
        add_View(segmentVC[sender.selectedSegmentIndex])
    }
    
    func add_View(_ vc:UIViewController)
    {
        addChild(vc)
        vc.view.frame = containerView.bounds
        vc.view.layer.cornerRadius = 20
        containerView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    static func createModule(segmentTitles:[String],segmentVC:[UIViewController]) -> MWSegmentVC?{
        if segmentTitles.count != segmentVC.count || segmentVC.count <= 1 || segmentTitles.count <= 1 {
            return nil
        }
        let vc:MWSegmentVC = MWSegmentVC()
        vc.segmentTitles = segmentTitles
        vc.segmentVC = segmentVC
        return vc
    }
}
class MWSegmentRouter{
    static func createMWprinterMangerWithErrorPrinter() -> MWSegmentVC?{
        var segmentTitles:[String] = []
        var segmentVC:[UIViewController] = []
        let printerErrorVC = PrinterErrorVC()
        printerErrorVC.hideSegment = true
        segmentVC.append(printerErrorVC)
        segmentTitles.append("Error Log".arabic("سجل الاخطاء"))
        var devicesTypes:[DEVICES_TYPES_ENUM] = []
        if !SharedManager.shared.cannotPrintBill(){
            devicesTypes.append(.POS_PRINTER)
        }
        if !SharedManager.shared.cannotPrintKDS(){
            devicesTypes.append(.KDS_PRINTER)
        }
        if devicesTypes.count <= 0 {
            return nil
        }
        segmentVC.append(DevicesMangmentVC.createModule(devicesTypes:devicesTypes))
        segmentTitles.append("Devices Managment".arabic("إدارة الاجهزه"))
        if SharedManager.shared.appSetting().enable_add_kds_via_wifi {
            segmentVC.append(MessageIpErrorVC.createModule(nil))
            segmentTitles.append("IP Log".arabic("سجل الIP"))
        }
        
        let vc:MWSegmentVC = MWSegmentVC()
        vc.segmentTitles = segmentTitles
        vc.segmentVC = segmentVC
        return vc

    }
    
}
extension UISegmentedControl {
    
    /// Replace the current segments with new ones using a given sequence of string.
    /// - parameter withTitles:     The titles for the new segments.
    public func replaceSegments<T: Sequence>(withTitles: T) where T.Iterator.Element == String {
        removeAllSegments()
        for title in withTitles {
            insertSegment(withTitle: title, at: numberOfSegments, animated: false)
        }
    }
    /// Tint color doesn't have any effect on iOS 13.
    func ensureiOS12Style() {
        if #available(iOS 13, *)
               {
                   let bg = UIImage(color: .clear, size: CGSize(width: 1, height: 32))
                    let devider = UIImage(color: tintColor, size: CGSize(width: 1, height: 32))

                    //set background images
                    self.setBackgroundImage(bg, for: .normal, barMetrics: .default)
                    self.setBackgroundImage(devider, for: .selected, barMetrics: .default)

                    //set divider color
                    self.setDividerImage(devider, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

                    //set border
                    self.layer.borderWidth = 1
                    self.layer.borderColor = tintColor.cgColor

                    //set label color
                    self.setTitleTextAttributes([.foregroundColor: tintColor], for: .normal)
                    self.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
               }
               else
               {
                   self.tintColor = tintColor
               }
    }
    
    
}
extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.set()
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.init(data: image.pngData()!)!
    }
}
