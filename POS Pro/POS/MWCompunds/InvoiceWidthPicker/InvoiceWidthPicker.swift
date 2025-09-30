//
//  InvoiceWidthPicker.swift
//  pos
//
//  Created by Muhammed Elsayed on 23/01/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

typealias MWWidthPickerClosure = (_ selectedWidth: String) -> Void

class InvoiceWidthPicker: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var toolbar: UIToolbar!

    var selectWidthClosure: MWWidthPickerClosure?
    var widths = ["7", "7.5", "8", "8.5", "9", "9.5", "10"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        configureUI()
        pickerView.reloadAllComponents()
    }

    static func createModule(_ sender: UIView?) -> InvoiceWidthPicker {
        let vc = InvoiceWidthPicker()
        if let sender = sender {
            vc.modalPresentationStyle = .popover
            vc.preferredContentSize = CGSize(width: 400, height: 300)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }

    private func configureUI() {
        toolbar.barTintColor = #colorLiteral(red: 0.3882360458, green: 0.2861049771, blue: 0.4954980612, alpha: 1)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pickerView.layer.borderColor = #colorLiteral(red: 0.986671865, green: 0.468683362, blue: 0, alpha: 1)
        pickerView.layer.borderWidth = 1.0
        pickerView.layer.cornerRadius = 7.0
        pickerView.layer.masksToBounds = true

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 0
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissPickerController))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let pickItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(confirmSelection))
        let toolBarTitle = ToolBarTitleItem(text: "Select Width", font: .systemFont(ofSize: 22), color: .white)

        toolbar.items = [cancelItem, space,toolBarTitle, space, pickItem]
        selectSavedWidth()
    }
    private func selectSavedWidth() {
        let savedWidth = SharedManager.shared.appSetting().width_invoice_to_set_new_dimensions
        if let savedWidthIndex = widths.firstIndex(of: savedWidth) {
            pickerView.selectRow(savedWidthIndex, inComponent: 0, animated: false)
        }
    }
    @objc func confirmSelection() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let selectedWidth = widths[selectedRow]
        selectWidthClosure?(selectedWidth)
        self.dismiss(animated: true)
    }

    @objc func dismissPickerController() {
        self.dismiss(animated: true)
    }
}

extension InvoiceWidthPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return widths.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return widths[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // You can handle immediate actions on selection here if needed
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
           let pickerLabel = UILabel()
           let titleData = widths[row] // Use the widths array here
           pickerLabel.text = titleData

           pickerLabel.backgroundColor = #colorLiteral(red: 0.986671865, green: 0.468683362, blue: 0, alpha: 1)
           pickerLabel.textAlignment = .center
           pickerLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
           pickerLabel.font = UIFont.boldSystemFont(ofSize: 22)
           return pickerLabel
       }
}
