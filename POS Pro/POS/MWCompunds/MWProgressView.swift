//
//  MWProgressView.swift
//  pos
//
//  Created by Mahmoud wageh on 28/11/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit
// UIColor(named: "DGTERA-purple") ?? #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)
class MWProgressView: UIView {
    
    private var progressLayer = CALayer()
        private var timer: Timer?
        private var progress: CGFloat = 0.1
        
        private let popupView = UIView()
        private let messageLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupPopup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupPopup()
        }
        
        private func setupPopup() {
            // Make the background transparent by setting the background color to clear
                   self.frame = UIScreen.main.bounds
                   self.backgroundColor = .clear // Make the background fully transparent
                   
                   let screenSize = UIScreen.main.bounds.size
                   let popupWidth = min(screenSize.width * 0.7, 500) // Max width 500 for iPads
                   let popupHeight: CGFloat = 120 // Keep the height consistent

                   // Ensure popup stays centered
                   popupView.frame = CGRect(x: (screenSize.width - popupWidth) / 2,
                                            y: ((screenSize.height - popupHeight) / 2) + 100,
                                            width: popupWidth,
                                            height: popupHeight)
                   
                   popupView.backgroundColor = .white // Set the popup background to white
                   popupView.layer.cornerRadius = 12
                   popupView.clipsToBounds = true
                   self.addSubview(popupView)
                   
                   // Setup message label
                   messageLabel.frame = CGRect(x: 0, y: 10, width: popupView.frame.width, height: 30)
            messageLabel.text = "Waiting...".arabic("إنتظر....")
                   messageLabel.textAlignment = .center
                   messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                   popupView.addSubview(messageLabel)
                   
                   // Progress bar background
                   let progressBarBackground = UIView(frame: CGRect(x: 20, y: 60, width: popupView.frame.width - 40, height: 20))
                   progressBarBackground.backgroundColor = UIColor.systemGray5
                   progressBarBackground.layer.cornerRadius = 10
                   popupView.addSubview(progressBarBackground)
                   
                   // Configure progress layer (initial width based on progress)
                   progressLayer.backgroundColor = (UIColor(named: "DGTERA-purple") ?? #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)).cgColor
                   progressLayer.frame = CGRect(x: 0, y: 0, width: (popupView.frame.width - 40) * progress, height: progressBarBackground.frame.height)
                   progressBarBackground.layer.addSublayer(progressLayer)
        }
        
        // Start progress updates
        func startProgress() {
            timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        }
        
        // Stop progress and remove the popup
        func stopProgress() {
            timer?.invalidate()
            timer = nil
            dismissPopup()
        }
        
        @objc private func updateProgress() {
            progress += 0.1
            if progress >= 1.0 {
              //  stopProgress()
                progress = 0.95
                timer?.invalidate()
                timer = nil
            }
            updateProgressLayer()
        }
        
        private func updateProgressLayer() {
            let newWidth = (popupView.frame.width - 40) * progress
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.frame.size.width = newWidth
            CATransaction.commit()
        }
        
        private func dismissPopup() {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            }) { _ in
                self.removeFromSuperview()
            }
        }
}
