//
//  load_api.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
typealias load_api = create_order
extension load_api
{

    @IBAction func btnReloadAllApis(_ sender: Any) {
    alter_database_enum.loadingApp.setIsDone(with: false)

      self.sync(get_new: false)

        
        
//        let alert = UIAlertController(title: "Option", message: "Sync mode.", preferredStyle: .alert)
//        
//        
//        alert.addAction(UIAlertAction(title: "Get New only", style: .default, handler: { (action) in
//            
//            self.sync(get_new: true)
//            
//            
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Reload all", style: .default, handler: { (action) in
//            
//            self.sync(get_new: false)
//            
//            
//            
//        }))
//        
//        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
//            
//        }))
//        
//        
//        self.present(alert, animated: true, completion: nil)
//        
        
        
    }
    
    func sync(get_new:Bool)
    {
//        let storyboard = UIStoryboard(name: "apis", bundle: nil)
//        cls_load_all_apis = storyboard.instantiateViewController(withIdentifier: "load_base_apis") as? load_base_apis
//
//        cls_load_all_apis.delegate = self
//        cls_load_all_apis.userCash = .stopCash
//        cls_load_all_apis.forceSync = true
//        cls_load_all_apis.get_new = get_new
//
//        cls_load_all_apis.modalPresentationStyle = .overFullScreen
//
//        self.present(cls_load_all_apis, animated: true, completion: nil)
//
//        cls_load_all_apis.startQueue()
//        cls_load_all_apis.scrollView.zoom()

        AppDelegate.shared.loadLoading(forceSync: true, get_new: get_new)

    }
    
    func isApisLoaded(status:Bool)
    {
       // cls_load_all_apis?.dismiss(animated: true, completion: nil)
        
        getProduct()
        
        if categories_top != nil
        {
            categories_top.viewDidLoad()
        }
    }
    
    
    
}
