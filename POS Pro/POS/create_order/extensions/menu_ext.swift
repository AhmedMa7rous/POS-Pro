//
//  menu+ext.swift
//  pos
//
//  Created by khaled on 27/03/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
 
typealias menu_ext = create_order
extension menu_ext: menuList_delegate
{
    
    func menu_order_selected(order_selected:pos_order_class)
    {
        showOrderAccept(order: order_selected)
    }

    func menu_order_deleted(order_selected:pos_order_class)
    {
        
    }
    
    
    func showOrderAccept(order:pos_order_class?)
    {
 
        if order != nil
        {
 
           
             let accept = accept_orders()
            
            let option = ordersListOpetions()
            option.parent_product = true
            
            accept.parent_vc = self
            accept.order = order
         
            accept.modalPresentationStyle = .overFullScreen
            
            accept.didSelect  = {  order in
                
                self.checkBadge()
            }
            
            
            self.present(accept, animated: true, completion: nil)
 
            
            
        }
        
        
    }
    
}
