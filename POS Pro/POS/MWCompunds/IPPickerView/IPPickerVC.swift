//
//  IPPickerVC.swift
//  pos
//
//  Created by M-Wageh on 04/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit
typealias MWIPPickerClosure = (_: String, _: String, _: String, _: String) -> Void

class IPPickerVC: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    var selectIPClosure : MWIPPickerClosure?
    var selectedIP : String?
    var options = [String]()
    var isForGeidea = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        configUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(removePickerController))
        view.addGestureRecognizer(tap)
        
        for index in 0...255 {
            options.append("\(index)")
        }
        pickerView.reloadAllComponents()
        refreshIP()

    }
    static func createModule(_ sender:UIView?,selectIP:String?) -> IPPickerVC {
        let vc:IPPickerVC = IPPickerVC()
        vc.selectedIP = (selectIP ?? "").isEmpty ? "192.168.1.1" : selectIP
        if let sender = sender{
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 600, height: 300)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
    func refreshIP() {
        
        if let temp = selectedIP {
            let ips = temp.split(separator: ".").map({String($0)})
            if ips.count >= 4 {
                pickerView.selectRow(Int(ips[0])! + options.count * 25, inComponent: 0, animated: true)
                pickerView.selectRow(Int(ips[1])! + options.count * 25, inComponent: 1, animated: true)
                pickerView.selectRow(Int(ips[2])! + options.count * 25, inComponent: 2, animated: true)
                pickerView.selectRow(Int(ips[3])! + options.count * 25, inComponent: 3, animated: true)
            }else {
                pickerView.selectRow(0 + options.count * 25, inComponent: 0, animated: true)
                pickerView.selectRow(0 + options.count * 25, inComponent: 1, animated: true)
                pickerView.selectRow(0 + options.count * 25, inComponent: 2, animated: true)
                pickerView.selectRow(0 + options.count * 25, inComponent: 3, animated: true)
            }
        }else {
            pickerView.selectRow(0 + options.count * 25, inComponent: 0, animated: true)
            pickerView.selectRow(0 + options.count * 25, inComponent: 1, animated: true)
            pickerView.selectRow(0 + options.count * 25, inComponent: 2, animated: true)
            pickerView.selectRow(0 + options.count * 25, inComponent: 3, animated: true)
        }
    }
    private func configUI() {
        
        self.toolbar.barTintColor = #colorLiteral(red: 0.3882360458, green: 0.2861049771, blue: 0.4954980612, alpha: 1)

        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pickerView.layer.borderColor = #colorLiteral(red: 0.986671865, green: 0.468683362, blue: 0, alpha: 1)
        
//        UIColor(colorLiteralRed: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0).CGColor
        pickerView.layer.borderWidth = 1.0
        pickerView.layer.cornerRadius = 7.0
        pickerView.layer.masksToBounds = true
        
        let fixedSpace = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 0
        let cancelItem = UIBarButtonItem.init(title: "Cancel", style: .done, target: self, action: #selector(removePickerController))
        let space = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let pickItem = UIBarButtonItem.init(title: "OK", style: .done, target: self, action: #selector(confirmSelect))
        var text = ""
        if isForGeidea {
            text = "Select Geidea ip".arabic("جهاز الدفع ip حدد")
        } else {
            text = "Select printer ip".arabic("الطابعة ip حدد")
        }
        let toolBarTitle = ToolBarTitleItem(text: text, font: .systemFont(ofSize: 22), color: .white)

        //toolbar.items = [fixedSpace,cancelItem,space,pickItem,fixedSpace]
        toolbar.items = [space,toolBarTitle,space]
    }
    @objc func confirmSelect() {
        
        let ip1 = pickerView.selectedRow(inComponent: 0)
        let ip2 = pickerView.selectedRow(inComponent: 1)
        let ip3 = pickerView.selectedRow(inComponent: 2)
        let ip4 = pickerView.selectedRow(inComponent: 3)
        selectIPClosure?(options[Int(Float(ip1).truncatingRemainder(dividingBy: Float(options.count)))],options[Int(Float(ip2).truncatingRemainder(dividingBy: Float(options.count)))],options[Int(Float(ip3).truncatingRemainder(dividingBy: Float(options.count)))],options[Int(Float(ip4).truncatingRemainder(dividingBy: Float(options.count)))])
      //  removePickerController()
    }
    @objc func removePickerController() {
//        view.removeFromSuperview()
//        removeFromParent()
        self.dismiss(animated: true)
    }


}

extension IPPickerVC : UIPickerViewDelegate,UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return options.count * 50
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[Int(Float(row).truncatingRemainder(dividingBy: Float(options.count)))]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let pickerLabel = UILabel()
        var titleData : String = String()

        if pickerView == pickerView {
            titleData = options[Int(Float(row).truncatingRemainder(dividingBy: Float(options.count)))]
        }
        pickerLabel.text = titleData

        pickerLabel.backgroundColor = #colorLiteral(red: 0.986671865, green: 0.468683362, blue: 0, alpha: 1)
        pickerLabel.textAlignment = .center
        pickerLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pickerLabel.font = UIFont.boldSystemFont(ofSize: 22)
        return pickerLabel

    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        confirmSelect()
    }
}
class ToolBarTitleItem: UIBarButtonItem {

    init(text: String, font: UIFont, color: UIColor) {
        let label =  UILabel(frame: UIScreen.main.bounds)
        label.text = text
        label.sizeToFit()
        label.font = font
        label.textColor = color
        label.textAlignment = .center
        super.init()
        customView = label
    }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}
