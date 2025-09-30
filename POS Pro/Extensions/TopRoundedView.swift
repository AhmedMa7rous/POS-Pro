//
//  TopRoundedView.swift
//  pos
//
//  Created by Muhammed Elsayed on 03/01/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class TopRoundedView: UIView {

    override func didMoveToWindow() {
        self.layer.cornerRadius = 15
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
extension UIView {

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }

}
