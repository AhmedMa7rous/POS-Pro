//
//  SetupBarcodeScannerVC.swift
//  pos
//
//  Created by M-Wageh on 16/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

protocol SetupBarcodeScannerVCDelegate: class {
  func setupDidFinish(_ vc: SetupBarcodeScannerVC)
}

class SetupBarcodeScannerVC: UIViewController{

    @IBOutlet weak var viewContainerStep: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!

    weak var delegate: SetupBarcodeScannerVCDelegate?

    let viewControllers: [UIViewController]
    var pageIndex = 0
    let pageController: UIPageViewController

    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         viewControllers: [UIViewController]) {
      self.viewControllers = viewControllers
      self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
      super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//      self.pageController.dataSource = self
//      self.pageController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        pageController.setViewControllers([viewControllers[0]], direction: .forward, animated: true, completion: nil)
        self.addChildViewControllerWithView(pageController)
//        pageControl.numberOfPages = viewControllers.count
        pageControl.isHidden = true
        self.view.bringSubviewToFront(pageControl)
        self.view.bringSubviewToFront(nextStepBtn)
        self.view.bringSubviewToFront(skipBtn)

        super.viewDidLoad()
        setTitleBtn()

    }


    @IBAction func tapOnNextBtn(_ sender: UIButton) {
        if let vc = viewControllers[pageIndex] as? StepSetupVC{
            if vc.stepModel.type == .table {
//                let count_rows = vc.mainTableView.numberOfRows(inSection: 0)
                guard let _ = vc.mainTableView.indexPathForSelectedRow else {
                    return
                }
            }
        }
        pageIndex += 1
        if pageIndex < viewControllers.count {
            pageController.setViewControllers([viewControllers[pageIndex]], direction: .forward, animated: true, completion: nil)
        }else{
            self.removeChildViewController(self.pageController)
            self.delegate?.setupDidFinish(self)

            return
        }
        self.skipBtn.isHidden = pageIndex == (viewControllers.count - 1)
        setTitleBtn()
    }
    func setTitleBtn(){
        if let vc = viewControllers[pageIndex] as? StepSetupVC{
            self.nextStepBtn.setTitle(vc.stepModel.btntitle, for: .normal)
        }
    }
    @IBAction func tapOnSkipBtn(_ sender: UIButton) {
        self.removeChildViewController(self.pageController)
        self.delegate?.setupDidFinish(self)
    }
}

extension UIViewController {
  
  func addChildViewControllerWithView(_ childViewController: UIViewController, toView view: UIView? = nil) {
    let view: UIView = view ?? self.view
    childViewController.removeFromParent()
    childViewController.willMove(toParent: self)
    addChild(childViewController)
    childViewController.didMove(toParent: self)
    childViewController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(childViewController.view)
    view.addConstraints([
      NSLayoutConstraint(item: childViewController.view!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: -10),
      NSLayoutConstraint(item: childViewController.view!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: childViewController.view!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: childViewController.view!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
    ])
    view.layoutIfNeeded()
  }
  
  func removeChildViewController(_ childViewController: UIViewController) {
    childViewController.removeFromParent()
    childViewController.willMove(toParent: nil)
    childViewController.removeFromParent()
    childViewController.didMove(toParent: nil)
    childViewController.view.removeFromSuperview()
    view.layoutIfNeeded()
  }
  
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}
