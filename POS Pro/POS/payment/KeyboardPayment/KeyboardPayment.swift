//
//  KeyboardPayment.swift
//  pos
//
//  Created by Muhammed Elsayed on 13/02/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit
protocol KeyboardPaymentDelegate: class {
    func keyboardAction(sender: Any)
}
class KeyboardPayment: UIView {
    weak var delegate: KeyboardPaymentDelegate?
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
    }
    @IBAction func btn_keyboardAction(_ sender: Any) {
        delegate?.keyboardAction(sender: sender)
    }
}
