//
//  UISegmentedControl+ext.swift
//  pos
//
//  Created by Khaled on 10/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

extension UISegmentedControl {
 
    func removeBorders(tintColor:UIColor) {
          setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
          setBackgroundImage(imageWithColor(color: tintColor), for: .selected, barMetrics: .default)
          setDividerImage(imageWithColor(color: UIColor(hexFromString: "#E0E0E0")), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
      }

      // create a 1x1 image with this color
      private func imageWithColor(color: UIColor) -> UIImage {
          let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
          UIGraphicsBeginImageContext(rect.size)
          let context = UIGraphicsGetCurrentContext()
          context!.setFillColor(color.cgColor);
          context!.fill(rect);
          let image = UIGraphicsGetImageFromCurrentImageContext();
          UIGraphicsEndImageContext();
          return image!
      }
    
    
    func setSelectedSegmentForegroundColor(_ foregroundColor: UIColor, andTintColor tintColor: UIColor) {
            if #available(iOS 13.0, *) {
                self.setTitleTextAttributes([.foregroundColor: foregroundColor], for: .selected)
                self.selectedSegmentTintColor = tintColor;
            } else {
                self.tintColor = tintColor;
            }
        }
    
}
