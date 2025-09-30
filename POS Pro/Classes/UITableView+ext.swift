//
//  UITableView+ext.swift
//  pos
//
//  Created by khaled on 9/16/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

extension UITableView {
    func scrollToLastCell(atscrollPosition: UITableView.ScrollPosition, animated : Bool ) {
        let lastSectionIndex = self.numberOfSections - 1 // last section
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1 // last row
        
        self.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: atscrollPosition, animated: animated)
    }
    
    static let shouldScrollSectionHeadersDummyViewHeight = CGFloat(60)

    var shouldScrollSectionHeaders: Bool {
        set {
            if newValue {
                tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: UITableView.shouldScrollSectionHeadersDummyViewHeight))
                contentInset = UIEdgeInsets(top: -UITableView.shouldScrollSectionHeadersDummyViewHeight, left: 0, bottom: 0, right: 0)
            } else {
                tableHeaderView = nil
                contentInset = .zero
            }
        }

        get {
            return tableHeaderView != nil && contentInset.top == UITableView.shouldScrollSectionHeadersDummyViewHeight
        }
    }
    
    
  
        func reloadData(completion: @escaping () -> ()) {
            UIView.animate(withDuration: 0, animations: { self.reloadData()})
            {_ in completion() }
        }
   
}
