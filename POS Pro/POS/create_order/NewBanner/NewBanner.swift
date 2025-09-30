//
//  NewBanner.swift
//  pos
//
//  Created by Muhammed Elsayed on 03/01/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit
protocol NewBannerDelegate: class {
    func showListMenuOrder(sender: Any)
    func showTableManagement(sender: Any)
    func createNewOrder(sender: Any)
    func showListOfOrders(sender: Any)
    func showPrinter()
    func sendToKitchen(sender: Any)
    func showSideMenu(sender: Any)
    func onFailureSentToKitchen(sender: Any)
    func showPromotionCode(sender: Any)
    func addNotes()
    func printBill()
    func applyDiscount()
    func showSettings(sender: Any)
    func applyVoid()
    func showMessageAlert(message:String)
    func prevent_create_order_when_exist_is_empty() -> Bool
}
class NewBanner: UIView {
    @IBOutlet weak var menuOrderHolderview: TopRoundedView!
    @IBOutlet weak var menuOrderBadgeHolderview: UIView!
    @IBOutlet weak var addNewOrderButton: UIButton!
    @IBOutlet weak var lblMenuBadge: KLabel!
    @IBOutlet weak var ordersBadgeHolderview: UIView!
    @IBOutlet weak var lblOrderBadge: KLabel!
    @IBOutlet weak var badgePrinterLbl: KLabel!
    @IBOutlet weak var printerBadgeHolderviewl: UIView!
    @IBOutlet weak var printerBtn: KButton!
    @IBOutlet weak var btn_send_kitchen: KButton!
//    @IBOutlet weak var lblFailureIPBadge: KLabel!
//    @IBOutlet weak var ipBadgeHolderview: UIView!
    @IBOutlet weak var ipHolderview: UIView!
    @IBOutlet weak var iconPromotion: UIImageView!
    @IBOutlet weak var labelPromotionCode: KLabel!
    @IBOutlet weak var labelDiscount: KLabel!
    @IBOutlet weak var discountBtn: KButton!
    @IBOutlet weak var btn_more: KButton!
    @IBOutlet weak var btn_table: UIButton!
    @IBOutlet weak var labelTable: KLabel!
    @IBOutlet weak var sendToKitchenHolderView: TopRoundedView!
    @IBOutlet weak var createNewOrderView: TopRoundedView!
    
    @IBOutlet weak var barNewOrderView: UIView!
    @IBOutlet weak var barSentToKitchenView: UIView!
    @IBOutlet weak var tableImageView: UIImageView!
    @IBOutlet weak var discountHolderView: TopRoundedView!
    
    @IBOutlet weak var lblNewOrder: KLabel!
    
    @IBOutlet weak var lblSentKitchen: KLabel!
    weak var delegate: NewBannerDelegate?
    func loadFromNib() {
        let xibType = type(of: self)
        let bundle = Bundle(for: xibType)
        guard let contentView = bundle.loadNibNamed(String(describing: xibType), owner: self, options: nil)?.first as? UIView else { return }
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        menuOrderBadgeHolderview.roundCorners(corners: [.topLeft, .bottomRight], radius: 10)
        ordersBadgeHolderview.roundCorners(corners: [.topLeft, .bottomRight], radius: 10)
        printerBadgeHolderviewl.roundCorners(corners: [.topLeft, .bottomRight], radius: 10)
//        ipBadgeHolderview.roundCorners(corners: [.topLeft, .bottomRight], radius: 10)
//        ipBadgeHolderview.roundCorners(corners: [.topLeft, .bottomRight], radius: 10)
        self.setEnableSendKitchen(with:false)
        setEnableNewOrder(with: !SharedManager.shared.appSetting().prevent_new_order_if_empty)
    }
    @IBAction func menuOrdersBtnTapped(_ sender: Any) {
//        if !MWMasterIP.shared.isOnLine(){
//            delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
//            return
//        }
        delegate?.showListMenuOrder(sender: sender)
    }
    @IBAction func tableManagementBtnTapped(_ sender: Any) {
//        if !MWMasterIP.shared.isOnLine(){
//            delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
//            return
//        }
        delegate?.showTableManagement(sender: sender)
    }
    @IBAction func addNewOrderBtnTapped(_ sender: Any) {
        if delegate?.prevent_create_order_when_exist_is_empty() == false {
            if !MWMasterIP.shared.isOnLine(){
                delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
                return
            }
            delegate?.createNewOrder(sender: sender)
            setEnableNewOrder(with: false)
        } else {
            if !MWMasterIP.shared.isOnLine(){
                delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
                return
            }
            SharedManager.shared.initalBannerNotification(title:  "Not Allowed".arabic("غير مسموح"), message: "Can't Add new order. current order is empty".arabic("لا يمكنك انشاء طلب جديد والطلب الحالي مازال فارغ"), success: false, icon_name: "icon_error")
            SharedManager.shared.banner?.dismissesOnTap = true
            SharedManager.shared.banner?.show(duration: 3)
        }
    }
    @IBAction func showOrdersBtnTapped(_ sender: Any) {
//        if !MWMasterIP.shared.isOnLine(){
//            delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
//            return
//        }
        delegate?.showListOfOrders(sender: sender)
    }
    @IBAction func printerBtnTapped() {
        if !MWMasterIP.shared.isOnLine(){
            delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
            return
        }
        shakeAnimation(for: ipHolderview)
        delegate?.showPrinter()
    }
    @IBAction func sendToKitchenBtnTapped(_ sender: Any) {
        if !MWMasterIP.shared.isOnLine(){
            delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
            return
        }
        shakeAnimationWitoutChangeColor(for: sendToKitchenHolderView)
        delegate?.sendToKitchen(sender: sender)
    }
    @IBAction func btnOpenMenu(_ sender: Any) {
        delegate?.showSideMenu(sender: sender)
    }
//    @IBAction func onFailureSentToKitchenBtnTapped(_ sender: Any) {
//        delegate?.onFailureSentToKitchen(sender: sender)
//    }
    @IBAction func printBillBtnTapped(_ sender: Any) {
        delegate?.printBill()
    }
    @IBAction func promotionCodeBtnTapped(_ sender: Any) {
        if !MWMasterIP.shared.isOnLine(){
            delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
            return
        }
        delegate?.showPromotionCode(sender: sender)
    }
    @IBAction func addNotesBtnTapped() {
        if !MWMasterIP.shared.isOnLine(){
            delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
            return
        }
        delegate?.addNotes()
    }
    @IBAction func discountBtnTapped(_ sender: Any) {
        if !MWMasterIP.shared.isOnLine(){
            delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
            return
        }
        shakeAnimation(for: discountHolderView)
        delegate?.applyDiscount()
    }
    @IBAction func settingBtnTapped(_ sender: Any) {
        delegate?.showSettings(sender: sender)
    }
    @IBAction func voidBtnTapped() {
        if !MWMasterIP.shared.isOnLine(){
            delegate?.showMessageAlert(message: "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"))
            return
        }
        delegate?.applyVoid()
    }
    func setEnableSendKitchen(with value:Bool){
        DispatchQueue.main.async {
        let colorBKEnable = #colorLiteral(red: 0.6862745098, green: 0.8980392157, blue: 0.662745098, alpha: 1)
        let colorEnable = #colorLiteral(red: 0.1843137255, green: 0.4392156863, blue: 0.1568627451, alpha: 1)
        let colorDisable = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        self.lblSentKitchen.textColor = value ? colorEnable : colorDisable
        self.btn_send_kitchen.isEnabled = value
//        self.sendToKitchenHolderView.backgroundColor = value ? colorBKEnable : colorDisable
        self.barSentToKitchenView.backgroundColor = value ? colorEnable : colorDisable
        self.sendToKitchenHolderView.alpha = value ? 1 : 0.5

        }
    }
    
    func setEnableNewOrder(with value: Bool) {
        if SharedManager.shared.appSetting().prevent_new_order_if_empty {
            DispatchQueue.main.async { [weak self] in
                let colorEnable = #colorLiteral(red: 1, green: 0.3582900465, blue: 0, alpha: 1)
                let colorDisable = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self?.lblNewOrder.textColor = value ? colorEnable : colorDisable
                self?.barNewOrderView.backgroundColor = value ? colorEnable : colorDisable
                self?.createNewOrderView.alpha = value ? 1 : 0.5
            }
        }
    }
    
}
extension NewBanner {
    func shakeAnimationWitoutChangeColor(for view: UIView) {
        // Shake animation
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10, 10, -10, 10, -5, 5, -2.5, 2.5, 0]
        view.layer.add(animation, forKey: "shake")
//        // After the shake animation, set the background color back to white
//        DispatchQueue.main.asyncAfter(deadline: .now() + animation.duration) {
//            UIView.animate(withDuration: 0.3) {
//                view.backgroundColor = UIColor.white
//            }
//        }
       
    }
    func shakeAnimation(for view: UIView) {
        // Change background color to light gray before shaking
        view.backgroundColor = UIColor.lightGray
        
        // Shake animation
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-10, 10, -10, 10, -5, 5, -2.5, 2.5, 0]
        view.layer.add(animation, forKey: "shake")

        // After the shake animation, set the background color back to white
        DispatchQueue.main.asyncAfter(deadline: .now() + animation.duration) {
            UIView.animate(withDuration: 0.3) {
                view.backgroundColor = UIColor.white
            }
        }
    }
}
