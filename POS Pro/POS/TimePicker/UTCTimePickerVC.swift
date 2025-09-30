//
//  UTCTimePickerVC.swift
//  pos
//
//  Created by Ahmed Mahrous on 14/05/2025.
//  Copyright © 2025 khaled. All rights reserved.
//


import UIKit

class UTCTimePickerVC: UIViewController {

    // MARK: Public API
    var onTimePicked: ((Date) -> Void)?
    var initialDate: Date = Date()

    // MARK: Views
    private lazy var picker: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode  = .time
        p.timeZone        = TimeZone(secondsFromGMT: 0)!
        p.minuteInterval  = 5
        p.date            = initialDate
        if #available(iOS 13.4, *) {
            //p.preferredDatePickerStyle = .wheels
        }
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()

    private lazy var doneBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Done", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var stack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [picker, doneBtn])
        s.axis = .vertical
        s.alignment = .center
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        view.addSubview(contentView)
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 320),
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        doneBtn.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }

    @objc private func doneTapped() {
        onTimePicked?(picker.date)
        dismiss(animated: true)
    }
}

extension TimeZone {
    static let utc = TimeZone(secondsFromGMT: 0)!
}



extension Calendar {
    static let utc: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .utc
        return cal
    }()
}
