//
//  PinCodeVC.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/5/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class PinCodeVC: UIViewController {
    //MARK:-Outlet
    @IBOutlet var pinField: KAPinField!
    
    @IBOutlet weak var backupBtn: KButton!
    @IBOutlet weak var skipBtn: KButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var infoUploadLbl: UILabel!
    //MARK:-Variables
    var router:PinCodeRouter?
    var pinCodeVM:PinCodeVM?
    //MARK:-Pin code VC Life cyle
    override func viewDidLoad() {
        super.viewDidLoad()
        doStyle()
        pinField.properties.delegate = self
        initalState()
        pinField.becomeFirstResponder()
        SharedManager.shared.printLog("comu_test_tomtom :- 585-587-385-478",force: true)
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
            /*
             461880238732 // pos1_afrad // rajhi_backup
             **/
            SharedManager.shared.printLog("585-587-385-478",force: true)
            pinField.text = "58558738547"//8
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    //MARK:- inital State Pin code screen
    func initalState(){
        self.pinCodeVM?.updateLoadingStatusClosure = { (state, message, isSucess) in
            switch state {
            case .empty:
                DispatchQueue.main.async {
                    loadingClass.hide()
                }
                return
            case .error:
                DispatchQueue.main.async {
                    loadingClass.hide()
                    messages.showAlert(message ?? "pleas, try again!")
                }
                return
            case .loading:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
            case .populated:
                DispatchQueue.main.async {
                    loadingClass.hide()
                    self.router?.openLoadingSc()
                }
                return
            }
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        remove_notificationCenter()
    }
    //MARK:-ACtion
    @IBAction func tapOnSkipBtn(_ sender: KButton) {
        router?.openLoginVC();
    }
    
    @IBAction func tapOnSubmitBtn(_ sender: KButton) {
        if let text = pinField.text , !text.isEmpty , text.count == 12{
        view.endEditing(true)
        pinCodeVM?.getPinInfoFor(code:text)
        }
    }
    
    @IBAction func tapOnBackUp(_ sender: KButton) {
       SharedManager.shared.printLog("do back up")
        if  self.progressView.isHidden  {
            self.infoUploadLbl.isHidden = true
            init_notificationCenter()
            AppDelegate.shared.auto_export.upload_all()
            self.progressView.isHidden = false
        }

       
    }
   
    //MARK:- Style
    private func doStyle(){
        logicPinField()
        stylePinField()
        addBorder(for:backupBtn, byCorner:  [UIRectCorner.bottomLeft , UIRectCorner.topLeft])
        addBorder(for:skipBtn, byCorner:  [UIRectCorner.bottomRight , UIRectCorner.topRight])
    }
    
    private func addBorder(for view:UIView, byCorner corners: UIRectCorner , cornerRadi:CGFloat = 20 ) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = view.frame
        rectShape.position = view.center
        rectShape.path = UIBezierPath(roundedRect: backupBtn.bounds,
                                      byRoundingCorners:  corners,
                                      cornerRadii: CGSize(width: cornerRadi, height: cornerRadi)).cgPath
        view.layer.mask = rectShape
    }

}
//MARK:- KAPinFieldDelegate
extension PinCodeVC : KAPinFieldDelegate {
    func logicPinField(){
        pinField.properties.token = "-"
        pinField.properties.numberOfCharacters = 12
        pinField.properties.validCharacters = "0123456789+#?٠١٢٣٤٥٦٧٨٩"
        pinField.properties.animateFocus = true
        pinField.properties.isSecure = false
        pinField.properties.secureToken = "*"
        pinField.properties.isUppercased = false
    }
    func stylePinField(){
        let appColor = UIColor(named: "DGTERA-purple") ?? #colorLiteral(red: 0.9598844647, green: 0.47515136, blue: 0, alpha: 1)
        let textColor = UIColor(named: "DGTERA-purple") ?? #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)
        let bkColor = UIColor(named: "E9E6F6") ?? UIColor.white
        pinField.appearance.font = .menloBold(40)
        pinField.appearance.kerning = 20
        pinField.appearance.textColor = textColor.withAlphaComponent(1.0)
        pinField.appearance.tokenColor = appColor.withAlphaComponent(0.3)
        pinField.appearance.tokenFocusColor = UIColor.black.withAlphaComponent(0.3)
        pinField.appearance.backOffset = 8
        pinField.appearance.backColor = UIColor.clear
        pinField.appearance.backBorderWidth = 1
        pinField.appearance.backBorderColor = bkColor.withAlphaComponent(0.2)
        pinField.appearance.backCornerRadius = 4
        pinField.appearance.backFocusColor = UIColor.clear
        pinField.appearance.backBorderFocusColor = bkColor.withAlphaComponent(0.8)
        pinField.appearance.backActiveColor = UIColor.clear
        pinField.appearance.backBorderActiveColor = appColor
        pinField.appearance.keyboardType = UIKeyboardType.asciiCapableNumberPad
    }
  func pinField(_ field: KAPinField, didFinishWith code: String) {
    view.endEditing(true)
   SharedManager.shared.printLog("didFinishWith : \(code)")
    pinCodeVM?.getPinInfoFor(code:code)
  }
}
//MARK:-Observal Notification
extension PinCodeVC {
    //MARK:-Observal Notification
    func init_notificationCenter()
    {
        NotificationCenter.default.addObserver(self, selector: #selector( upload_progress_listerner(notification:)), name: Notification.Name("upload_progress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( upload_success_listerner(notification:)), name: Notification.Name("upload_success"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( upload_failure_listerener(notification:)), name: Notification.Name("upload_failure"), object: nil)
    }
    
    func remove_notificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("upload_progress"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("upload_success"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("upload_failure"), object: nil)
    }
    @objc func upload_progress_listerner(notification:Notification){
        if let precent = notification.object as? Double{
            setProgressView(precent)
           SharedManager.shared.printLog("\(precent)")
        }
    }
    @objc func upload_success_listerner(notification:Notification){
        if let path = notification.object as? String,let split = path.components(separatedBy: "/").last{
            setInfoLbl(split)
        }else{
            setInfoLbl("Backup sucess")
        }
    }
    @objc func upload_failure_listerener(notification:Notification){
        self.progressView.isHidden = true
        if let error = notification.object as? String{
            setInfoLbl(error)
        }else{
            setInfoLbl("Backup Fail")
        }
        
    }
    func setInfoLbl(_ info:String){
        self.infoUploadLbl.isHidden = false
        self.infoUploadLbl.text = info
    }
    func setProgressView(_ value:Double){
        self.progressView.isHidden = false
        DispatchQueue.main.async {
            self.progressView.setProgress( value < 0.1 ? 0.1 :  Float(value), animated: true)
        }
    }
}
